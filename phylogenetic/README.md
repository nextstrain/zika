# nextstrain.org/zika

This is the [Nextstrain](https://nextstrain.org) build for Zika, visible at
[nextstrain.org/zika](https://nextstrain.org/zika).

## Software requirements

Follow the [standard installation instructions](https://docs.nextstrain.org/en/latest/install.html)
for Nextstrain's suite of software tools.

## Usage

If you're unfamiliar with Nextstrain builds, you may want to follow our
[Running a Pathogen Workflow guide][] first and then come back here.

The easiest way to run this pathogen build is using the Nextstrain
command-line tool from within the `phylogenetic/` directory:

    cd phylogenetic/
    nextstrain build .

Build output goes into the directories `data/`, `results/` and `auspice/`.

Once you've run the build, you can view the results with:

    nextstrain view .

## Configuration

Configuration for the workflow takes place entirely within the [defaults/config_zika.yaml](defaults/config_zika.yaml).
The analysis pipeline is contained in [Snakefile](Snakefile) with included [rules](rules).
Each rule specifies its file inputs and output and pulls its parameters from the config.
There is little redirection and each rule should be able to be reasoned with on its own.

### Using GenBank data

This build starts by pulling preprocessed sequence and metadata files from:

* https://data.nextstrain.org/files/zika/sequences.fasta.zst
* https://data.nextstrain.org/files/zika/metadata.tsv.zst

The above datasets have been preprocessed and cleaned from GenBank using the
[ingest/](../ingest/) workflow and are updated at regular intervals.

### Using example data

Alternatively, you can run the build using the
example data provided in this repository.  To run the build by copying the
example sequences into the `data/` directory, use the following:

    nextstrain build .  --configfile build-configs/ci/profiles_config.yaml

[Nextstrain]: https://nextstrain.org
[augur]: https://docs.nextstrain.org/projects/augur/en/stable/
[auspice]: https://docs.nextstrain.org/projects/auspice/en/stable/index.html
[Installing Nextstrain guide]: https://docs.nextstrain.org/en/latest/install.html
[Running a Pathogen Workflow guide]: https://docs.nextstrain.org/en/latest/tutorials/running-a-workflow.html
