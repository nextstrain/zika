# Nextstrain repository for Zika virus


## Cloud Native Buildpacks (WIP!)

Create the image via `pack build test-pack-zika --path ./zika/ --builder heroku/builder:24`

The `requirements.txt` is picked up by Heroku's python buildpack and installs augur & snakemake.

The image is c. 1GB so not insubstantial, and not something that'll be trivial to host.

## Run the image

`docker run --rm  test-pack-zika`

The Procfile is the command started by the launcher (default entrypoint) - right now we just print out the phylo build steps: `snakemake --cores 1 -npf`

To start an interactive session you need the launcher to set the PATH: `docker run --rm --entrypoint launcher -it test-pack-zika -- bash`. From here we can run workflow commands etc. 

### Running zika via external analysis directory

```
mkdir zika-analysis-dir
docker run -v ./zika-analysis-dir/:/pathogen --rm --entrypoint launcher -it test-pack-zika -- bash
# next commands from the docker interactive prompt
cd /pathogen
snakemake --cores 1 --snakefile ../workspace/phylogenetic/Snakefile -pf data/m
etadata.tsv # proof-of-principle
```


---


This repository contains two workflows for the analysis of Zika virus data:

- [`ingest/`](./ingest) - Download data from GenBank, clean and curate it and upload it to S3
- [`phylogenetic/`](./phylogenetic) - Filter sequences, align, construct phylogeny and export for visualization

Each folder contains a README.md with more information. The results of running both workflows are publicly visible at [nextstrain.org/zika](https://nextstrain.org/zika).

## Installation

Follow the [standard installation instructions](https://docs.nextstrain.org/en/latest/install.html) for Nextstrain's suite of software tools.

After you've installed the Nextstrain CLI, you can set up zika with

    nextstrain setup zika


## Quickstart

Run the default phylogenetic workflow via:

    nextstrain run zika phylogenetic zika-analysis
    nextstrain view zika-analysis


## Documentation

- [Running a pathogen workflow](https://docs.nextstrain.org/en/latest/tutorials/running-a-workflow.html)
- [Contributor documentation](./CONTRIBUTING.md)
