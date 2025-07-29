# nextstrain.org/zika

This is the [Nextstrain](https://nextstrain.org) build for Zika, visible at
[nextstrain.org/zika](https://nextstrain.org/zika).

## Software requirements

Follow the [standard installation instructions](https://docs.nextstrain.org/en/latest/install.html)
for Nextstrain's suite of software tools.

## Usage

If you're unfamiliar with Nextstrain builds, you may want to follow our
[Running a Pathogen Workflow guide][] first and then come back here.

### With `nextstrain run`

If you haven't set up the zika pathogen, then set it up with:

    nextstrain setup zika

Otherwise, make sure you have the latest set up with:

    nextstrain update zika

Run the phylogenetic workflow with:

    nextstrain run zika phylogenetic <analysis-directory>

Your `<analysis-directory>` will contain the workflow's intermediate files
and the final output `auspice/zika.json`.

You can view the result with

    nextstrain view <analysis-directory>

### With `nextstrain build`

If you don't have a local copy of the zika repository, use Git to download it

    git clone https://github.com/nextstrain/zika.git

Otherwise, update your local copy of the workflow with:

    cd zika
    git pull --ff-only origin master

Run the phylogenetic workflow workflow with

    cd phylogenetic
    nextstrain build .

The `phylogenetic` directory will contain the workflow's intermediate files
and the final output `auspice/zika.json`.

Once you've run the build, you can view the results with:

    nextstrain view .

## Configuration

The default configuration is in [`defaults/config.yaml`](./defaults/config.yaml).
The workflow is contained in [Snakefile](Snakefile) with included [rules](rules).
Each rule specifies its file inputs and output and pulls its parameters from the config.
There is little redirection and each rule should be able to be reasoned with on its own.

### Using GenBank data

This build starts by pulling preprocessed sequence and metadata files from:

* https://data.nextstrain.org/files/workflows/zika/sequences.fasta.zst
* https://data.nextstrain.org/files/workflows/zika/metadata.tsv.zst

The above datasets have been preprocessed and cleaned from GenBank using the
[ingest/](../ingest/) workflow and are updated at regular intervals.

### Using USVI data

This build also merges in USVI data from:

* https://data.nextstrain.org/files/workflows/zika/sequences_usvi.fasta.zst
* https://data.nextstrain.org/files/workflows/zika/metadata_usvi.tsv.zst

The above dataset was pulled from https://github.com/blab/zika-usvi/ with [additional processing steps to remove duplicates](https://github.com/nextstrain/zika/blob/f8a6423a7f6b6f1b30b6496d8433b99eff0d54ff/phylogenetic/data/README.md).

### Using example data

Alternatively, you can run the build using the example data provided in this
repository by running:

    nextstrain build .  --configfile build-configs/ci/config.yaml

### Deploying build

To run the workflow and automatically deploy the build to nextstrain.org,
you will need to have AWS credentials to run the following:

```
nextstrain build \
    --env AWS_ACCESS_KEY_ID \
    --env AWS_SECRET_ACCESS_KEY \
    . \
        deploy_all \
        --configfile build-configs/nextstrain-automation/config.yaml
```

[Nextstrain]: https://nextstrain.org
[augur]: https://docs.nextstrain.org/projects/augur/en/stable/
[auspice]: https://docs.nextstrain.org/projects/auspice/en/stable/index.html
[Installing Nextstrain guide]: https://docs.nextstrain.org/en/latest/install.html
[Running a Pathogen Workflow guide]: https://docs.nextstrain.org/en/latest/tutorials/running-a-workflow.html
