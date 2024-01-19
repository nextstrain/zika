# Nextstrain repository for Zika virus

This repository contains two workflows for the analysis of Zika virus data:

- [`ingest/`](./ingest) - Download data from GenBank, clean and curate it and upload it to S3
- [`phylogenetic/`](./phylogenetic) - Make phylogenetic trees for nextstrain.org

Each folder contains a README.md with more information.

## Quickstart

Follow the [standard installation instructions](https://docs.nextstrain.org/page/install.html) for Nextstrain's suite of software tools.

Then run the default phylogenetic workflow via:
```
cd phylogenetic/
nextstrain build .
nextstrain view .
```

## Documentation

- [Contributor documentation](./CONTRIBUTING.md)
