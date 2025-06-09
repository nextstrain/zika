# nextstrain.org/zika/ingest

This is the ingest pipeline for zika virus sequences.

## Software requirements

Follow the [standard installation instructions](https://docs.nextstrain.org/en/latest/install.html) for Nextstrain's suite of software tools.

## Usage

### With `nextstrain run`

If you haven't set up the zika pathogen, then set it up with:

    nextstrain setup zika

Otherwise, make sure you have the latest set up with:

    nextstrain update zika

Run the ingest workflow with:

    nextstrain run zika ingest <analysis-directory>

Your `<analysis-directory>` will contain the workflow's intermediate files
and two final outputs:

- `results/metadata.tsv`
- `results/sequences.fasta`

### With `nextstrain build`

If you don't have a local copy of the zika repository, use Git to download it

    git clone https://github.com/nextstrain/zika.git

Otherwise, update your local copy of the workflow with:

    cd zika
    git pull --ff-only origin master

Run the ingest workflow with

    cd ingest
    nextstrain build .

The `ingest` directory will contain the workflow's intermediate files
and two final outputs:

- `results/metadata.tsv`
- `results/sequences.fasta`

## Configuration

The default configuration is in [`defaults/config.yaml`](./defaults/config.yaml).
The workflow is contained in [Snakefile](Snakefile) with included [rules](rules).
Each rule specifies its file inputs and output and pulls its parameters from the config.
There is little redirection and each rule should be able to be reasoned with on its own.

### Nextstrain automated workflow

The Nextstrain automated workflow uploads results to AWS S3 with

    nextstrain build \
        --env AWS_ACCESS_KEY_ID \
        --env AWS_SECRET_ACCESS_KEY \
        . \
            upload_all \
            --configfile build-configs/nextstrain-automation/config.yaml

## Input data

### GenBank data

GenBank sequences and metadata are fetched via [NCBI datasets](https://www.ncbi.nlm.nih.gov/datasets/docs/v2/download-and-install/).
