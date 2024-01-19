# Nextstrain repository for Zika virus

This repository contains two workflows for the analysis of Zika virus data:

- [`ingest/`](./ingest) - Download data from GenBank, clean and curate it and upload it to S3
- [`phylogenetic/`](./phylogenetic) - Filter sequences, align, construct phylogeny and export for visualization

Each folder contains a README.md with more information. The results of running both workflows are publicly visible at [nextstrain.org/zika](https://nextstrain.org/zika).

## Installation

Follow the [standard installation instructions](https://docs.nextstrain.org/en/latest/install.html) for Nextstrain's suite of software tools.

## Quickstart

Run the default phylogenetic workflow via:
```
cd phylogenetic/
nextstrain build .
nextstrain view .
```

## Documentation

- [Running a pathogen workflow](https://docs.nextstrain.org/en/latest/tutorials/running-a-workflow.html)
- [Contributor documentation](./CONTRIBUTING.md)
