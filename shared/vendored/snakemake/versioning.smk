"""
Shared functions to be used within a Snakemake workflow for enforcing
versions of dependencies the repo defines within its `nextstrain-pathogen.yaml`
"""

from os import path
from sys import stderr
from packaging.specifiers import SpecifierSet, InvalidSpecifier # snakemake dependency
from packaging.version    import Version, InvalidVersion        # snakemake dependency
from importlib.metadata import version as importlib_version, PackageNotFoundError
from snakemake.common import __version__ as snakemake_version
import subprocess
from shutil import which
import re

class ProgramNotFoundError(Exception):
    pass

class DependencyChecker():
    def __init__(self, registration):
        super().__init__()
        self.error_attrs = ["version_incompatibilities", "not_found_dependencies", "declaration_errors", "unexpected_errors"]
        for attr in self.error_attrs:
            setattr(self, attr, [])
        self.declared_dependencies = self.parse_dependencies(registration)

    def parse_dependencies(self, registration):
        declared_dependencies = {}
        dependencies = registration.get('dependencies', {})
        if type(dependencies) is not dict:
            raise WorkflowError(f"Within `nextstrain-pathogen.yaml` the dependencies must be a dict of <name>: <specifier>. You provided {type(dependencies).__name__}")
        for name, spec in dependencies.items():
            try:
                declared_dependencies[name] = SpecifierSet(spec)
            except InvalidSpecifier:
                self.declaration_errors.append(f"This pathogen declared an invalid version specification for CLI program {name!r} of {spec}")
        return declared_dependencies

    def check(self):
        for name, specifier in self.declared_dependencies.items():
            try: # First assume it's a python package
                self.check_python_package(name, specifier)
            except PackageNotFoundError:
                try: # if it's not a python package, maybe it's a CLI?
                    self.check_cli_version(name, specifier)
                except ProgramNotFoundError:
                    self.not_found_dependencies.append(f"{name!r} is not installed as a python dependency nor a CLI program. This pathogen requires a version satisfying {str(specifier)!r}")

    def report_errors(self) -> bool:
        if sum([len(getattr(self, attr)) for attr in self.error_attrs])==0:
            print("All dependencies declared by this pathogen satisfied", file=stderr)
            return False
        
        print(file=stderr)
        print('_'*80, file=stderr)
        print(f"This pathogen declares dependencies which were not met.", file=stderr)
        for attr in self.error_attrs:
            errors = getattr(self, attr)
            if len(errors)==0:
                continue
            print(attr.replace('_', ' ').capitalize() + ":", file=stderr)
            print("-"*(len(attr)+1), file=stderr)
            for msg in errors:
                print(f"\t{msg}", file=stderr)
        print('_'*80, file=stderr)
        print(file=stderr)
        return True

    def check_python_package(self, name: str, specifier: SpecifierSet):
        """
        Check whether the installed python library *name* meets the specifier *specifier*.
        This uses importlib.metadata to check the available version which avoids importing
        the top-level import.

        If the package is found but the version doesn't satisfy the provided *specifier*
        we log an error. Raises `PackageNotFoundError` if the package is not found.
        """
        try:
            if name=='snakemake':
                # in conda environments importlib reports a snakemake version of 0.0.0,
                # so follow the approach of Snakemake's own min_version function
                version = Version(snakemake_version)
            else:
                version = Version(importlib_version(name))
        except InvalidVersion: # <https://packaging.pypa.io/en/stable/version.html#packaging.version.InvalidVersion>
            self.unexpected_errors.append(f"Python dependency {name!r} reported a version of {output} which we were unable to parse")
            return

        ok = specifier.contains(version)
        # print(f"[DEBUG] Checking python dependency: {name!r} installed: {version} requirements: {specifier} OK? {ok}", file=stderr)
        if not ok:
            self.version_incompatibilities.append(f"Python dependency {name!r} version incompatibility. You have {version} but this pathogen declares {specifier}")

    def check_cli_version(self, name: str, specifier: SpecifierSet) -> None:
        """
        Check whether the requested *name* is (a) installed and (b) reports a version
        which satisfies the *specifier*. Both (a) and (b) are achieved by calling
        `<name> --version`.
        
        If *name* isn't found (or is not executable) we raise a ProgramNotFoundError.
        If the package is found but the version doesn't satisfy the provided *specifier*
        we log an error. 
        """
        if which(name) is None:
            raise ProgramNotFoundError()

        cmd = [name, "--version"]
        try:
            proc = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, check=True)
            output = ((proc.stdout or "") + " " + (proc.stderr or "")).strip()
        except subprocess.CalledProcessError as e:
            self.unexpected_errors.append(f"CLI program {name!r} exited code {e.returncode} when called using {' '.join(cmd)!r}")
            return

        m = re.search(r"\d+(\.\d+(\.\d+)?)?([.-][0-9A-Za-z]+)*", output)
        #                1   . 2   . 3           alpha etc
        if not m:
            self.unexpected_errors.append(f"CLI program {name!r} didn't report a parseable version when called via {' '.join(cmd)!r}")
            return

        try:
            version = Version(m.group(0))
        except InvalidVersion: # <https://packaging.pypa.io/en/stable/version.html#packaging.version.InvalidVersion>
            self.unexpected_errors.append(f"CLI program {name!r} reported a version of {m.group(0)} which we were unable to parse")

        ok = specifier.contains(version)
        # print(f"[DEBUG] Checking CLI program: {name!r} installed: {version} requirements: {specifier} OK? {ok}", file=stderr)
        if not ok:
            self.version_incompatibilities.append(f"CLI program {name!r} version incompatibility. You have {version} but this pathogen declares {specifier}")


def _read_nextstrain_pathogen_yaml(path: str) -> dict:
    """
    Reads a ``nextstrain-pathogen.yaml`` file at *path* and returns a dict of
    its deserialized contents.

    Taken from <https://github.com/nextstrain/cli/blob/4dbac262b22a3db9c48267e23f713ad56251ffd0/nextstrain/cli/pathogens.py#L843C1-L858C24>
    with modifications. (Note: pathogen repos don't need the nextstrain CLI to be installed and thus we can't import the code.)
    """
    import yaml
    with open(path, encoding = "utf-8") as f:
        registration = yaml.safe_load(f)

    if not isinstance(registration, dict):
        raise ValueError(f"nextstrain-pathogen.yaml not a dict (got a {type(registration).__name__}): {str(path)!r}")

    return registration

def pathogen_yaml(*, subdir_max=3):
    _searched_paths = []
    for i in range(0, subdir_max):
        p = path.normpath(path.join(workflow.basedir, *['..']*i, "nextstrain-pathogen.yaml"))
        _searched_paths.append(p)
        if path.isfile(p):
            try:
                registration = _read_nextstrain_pathogen_yaml(p)
            except Exception as e:
                raise WorkflowError(f"Unable to parse {p} (as YAML). Error: {e}")
            break
    else:
        print("Could not find a nextstrain-pathogen.yaml file to check version dependencies.\n"
            "Searched paths:\n\t" + "\n\t".join(_searched_paths))
        raise WorkflowError()
    return registration


def check_pathogen_required_versions(*, fatal=True):
    """
    Checks if dependencies declared via the pathogen's 'nextstrain-pathogen.yaml'
    are satisfied. Dependencies should be defined within the YAML like so:

        dependencies:
            <name>: <specification>    

    The syntax of <specification> is detailed in <https://packaging.python.org/en/latest/specifications/version-specifiers/#id5>

    We first check if the <name> is a python package. If it is not installed
    as a python package we check if it's an installed CLI and attempt to
    get the version by running `<name> --version`.

    If *fatal* is True (default) we raise a WorkflowError if
    all conditions are not satisfied.
    """
    if config.get('skip_dependency_version_checking', False) is True:
        print("Skipping dependency version checking as per config setting", file=stderr)
        return
    checker = DependencyChecker(pathogen_yaml())
    checker.check()
    errors = checker.report_errors()
    if errors and fatal:
        raise WorkflowError("Dependencies not satisfied")
