"""
Rules to merge inputs based on what is defined in the config.

RULES:

    merge_metadata   - merges metadata across all inputs
    merge_sequences  - merges sequences across all inputs

Output paths are workflow-specific. Consume this file as a Snakemake module
and override the `output:` block of each rule, e.g.:

    module merge_inputs:
        snakefile: "path/to/shared/vendored/snakemake/merge_inputs.smk"
        config: config

    use rule merge_metadata from merge_inputs with:
        output:
            metadata = "results/metadata.tsv"

    use rule merge_sequences from merge_inputs with:
        output:
            sequences = "results/sequences.fasta"

The config dict is expected to have a top-level `inputs` list that defines the
separate inputs' name, metadata, and sequences. Optionally, the config can have
a top-level `additional-inputs` list that is used to define additional data that
are combined with the default inputs:

```yaml
inputs:
    - name: default
      metadata: <path-or-url>
      id_field: <metadata-id-field-name>
      sequences: <path-or-url>

additional_inputs:
    - name: private
      metadata: <path-or-url>
      id_field: <metadata-id-field-name>
      sequences: <path-or-url>
```

The `id_field` key for each input is passed through to `augur merge
--metadata-id-columns`. The merged metadata's id field is always named `id`.

Supports any of the compression formats that are supported by `augur read-file`,
see <https://docs.nextstrain.org/projects/augur/page/usage/cli/read-file.html>

WILDCARDS:

The default outputs are are written for workflows that do not use wildcards.
Workflows that need wildcards can add them as shown below.

1. If your workflow needs wildcards for both metadata and sequences,
e.g. serotypes for dengue, then you will need to edit the `output`, `log`, and
`benchmark` paths of the metadata and sequences rules.

    use rule merge_metadata from merge_inputs with:
        output:
            metadata = "results/{serotype}/metadata.tsv"
        log:
            "logs/{serotype}/merge_metadata.txt"
        benchmark:
            "benchmarks/{serotype}/merge_metadata.txt"

    use rule merge_sequences from merge_inputs with:
        output:
            sequences = "results/{serotype}/sequences.fasta"
        log:
            "logs/{serotype}/merge_sequences.txt"
        benchmark:
            "benchmarks/{serotype}/merge_sequences.txt"

The wildcards can then be directly used in the config for inputs:

```yaml
inputs:
    - name: default
      metadata: https://data.nextstrain.org/files/workflows/dengue/metadata_{serotype}.tsv.zst
      id_field: accession
      sequences: https://data.nextstrain.org/files/workflows/dengue/sequences_{serotype}.fasta.zst

```
Note: this does _not_ support different `id_field` per wildcard.

2. If your workflow only needs wildcards for sequences, e.g. segments for influenza,
then you will only need to edit the paths for the sequences rules.
The wildcards can then be directly used in the config for inputs:

```yaml
inputs:
    - name: default
      metadata: s3://nextstrain-data-private/files/workflows/avian-flu/metadata.tsv.zst
      id_field: accession
      sequences: s3://nextstrain-data-private/files/workflows/avian-flu/{segment}/sequences.fasta.zst
```
"""
# These include statements are required since any included variables/functions
# from calling workflows are not visible inside this module.
include: "config.smk"
include: "remote_files.smk"

from pathlib import Path


def _gather_inputs():
    all_inputs = [*config['inputs'], *config.get('additional_inputs', [])]

    if len(all_inputs)==0:
        raise InvalidConfigError("Config must define at least one element in config.inputs or config.additional_inputs lists")
    if not all([isinstance(i, dict) for i in all_inputs]):
        raise InvalidConfigError("All of the elements in config.inputs and config.additional_inputs lists must be dictionaries. "
            "If you've used a command line '--config' double check your quoting.")
    if len({i['name'] for i in all_inputs})!=len(all_inputs):
        raise InvalidConfigError("Names of inputs (config.inputs and config.additional_inputs) must be unique")
    if not all(['name' in i and ('sequences' in i or 'metadata' in i) for i in all_inputs]):
        raise InvalidConfigError("Each input (config.inputs and config.additional_inputs) must have a 'name' and 'metadata' and/or 'sequences'")
    if not any(['metadata' in i for i in all_inputs]):
        raise InvalidConfigError("At least one input must have 'metadata'")
    if not any (['sequences' in i for i in all_inputs]):
        raise InvalidConfigError("At least one input must have 'sequences'")
    if not all(['id_field' in i for i in all_inputs if 'metadata' in i]):
        raise InvalidConfigError("Each input with 'metadata' must also have an 'id_field'")

    available_keys = set(['name', 'metadata', 'id_field', 'sequences'])
    if any([len(set(el.keys())-available_keys)>0 for el in all_inputs]):
        raise InvalidConfigError(f"Each input (config.inputs and config.additional_inputs) can only include keys of {', '.join(available_keys)}")

    return {el['name']: {k:(v if k=='name' else path_or_url(v)) for k,v in el.items()} for el in all_inputs}

input_sources = _gather_inputs()


rule merge_metadata:
    """
    Merges the metadata inputs (config.inputs + config.additional_inputs).
    """
    input:
        **{name: info['metadata'] for name,info in input_sources.items() if info.get('metadata', None)}
    params:
        metadata = lambda w, input: list(map("=".join, input.items())),
        id_field = [f"{name}={info['id_field']}" for name,info in input_sources.items() if info.get('metadata', None)],
    output:
        metadata = "results/metadata.tsv"
    log:
        "logs/merge_metadata.txt",
    benchmark:
        "benchmarks/merge_metadata.txt"
    shell:
        r"""
        exec &> >(tee {log:q})

        augur merge \
            --metadata {params.metadata:q} \
            --metadata-id-columns {params.id_field:q} \
            --output-metadata {output.metadata:q} \
            --output-metadata-id-column id
        """


rule merge_sequences:
    """
    Merges the sequences inputs (config.inputs + config.additional_inputs).
    """
    input:
        **{name: info['sequences'] for name,info in input_sources.items() if info.get('sequences', None)}
    output:
        sequences = "results/sequences.fasta",
    log:
        "logs/merge_sequences.txt",
    benchmark:
        "benchmarks/merge_sequences.txt"
    shell:
        r"""
        exec &> >(tee {log:q})

        augur merge \
            --sequences {input:q} \
            --output-sequences {output.sequences:q}
        """
