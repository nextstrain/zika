# nextstrain.org/zika/ingest

This is the ingest pipeline for zika virus sequences.

## Software requirements

Follow the [standard installation instructions](https://docs.nextstrain.org/en/latest/install.html) for Nextstrain's suite of software tools.

## Usage

> NOTE: All command examples assume you are within the `ingest` directory.
> If running commands from the outer `zika` directory, please replace the `.` with `ingest`

Fetch sequences with

```sh
nextstrain build . data/sequences.ndjson
```

Run the complete ingest pipeline with

```sh
nextstrain build .
```

This will produce two files (within the `ingest` directory):

- `results/metadata.tsv`
- `results/sequences.fasta`

Run the complete ingest pipeline and upload results to AWS S3 with

```sh
nextstrain build \
    --env AWS_ACCESS_KEY_ID \
    --env AWS_SECRET_ACCESS_KEY \
    . \
        upload_all \
        --configfile build-configs/nextstrain-automation/config.yaml
```

## Configuration

Configuration takes place in `defaults/config.yaml` by default.


## Input data

### GenBank data

GenBank sequences and metadata are fetched via [NCBI datasets](https://www.ncbi.nlm.nih.gov/datasets/docs/v2/download-and-install/).
