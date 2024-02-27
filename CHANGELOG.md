# CHANGELOG

We use this CHANGELOG to document breaking changes, new features, bug fixes,
and config value changes that may affect both the usage of the workflows and
the outputs of the workflows.

## 2024

* 24 February 2024: Move accession to the first column of `metadata_all.tsv`. ([PR #36](https://github.com/nextstrain/zika/pull/36))
* 05 February 2024: Harmonize with [pathogen repo guide](https://github.com/nextstrain/pathogen-repo-guide) ([PR #31](https://github.com/nextstrain/zika/pull/31))
* 19 January 2024: Add a Quickstart section to the top level README. ([PR #30](https://github.com/nextstrain/zika/pull/30))
* 19 January 2024: Add ingest pipeline and restructure phylogeny pipeline. ([PR #28](https://github.com/nextstrain/zika/pull/28))
  * The addition of the ingest pipeline is a major change. Instead of relying on the `fauna` database, this introduces retrieving data from NCBI datasets directly and conducting subsequent curation.
  * The restructuring of the `phylogenetic` pipeline into a dedicated directory keeps the two workflows modular, and conforms to the [pathogen repo guide](https://github.com/nextstrain/pathogen-repo-guide).
  * Documenting and providing the USVI data in the `phylogenetic/data` directory.

## 2023

* 04 May 2023: Stylistic changes to make the Snakemake code conform to documented [Nextstrain Snakemake Styleguide](https://docs.nextstrain.org/en/latest/reference/snakemake-style-guide.html). ([PR #27](https://github.com/nextstrain/zika/pull/27))

## 2022

* 14 October 2022: Use zstd compression instead of xz and gzip. ([PR #23](https://github.com/nextstrain/zika/pull/23))
* 26 August 2022: Remove cores flag as it is no longer needed in nextstrain cli. ([PR #22](https://github.com/nextstrain/zika/pull/22))
* 14 April 2022: Specify `--cores all` for `nextstrain build .` to be compatible with snakemake>5.11.0. ([PR #19](https://github.com/nextstrain/zika/pull/19))
* 01 April 2022: CI: Use a centralized pathogen repo CI workflow. ([PR #17](https://github.com/nextstrain/zika/pull/17))
* 01 April 2022: Migrate CI to GitHub Actions. ([PR #16](https://github.com/nextstrain/zika/pull/16))
* 22 March 2022: Use Snakemake HTTP remote to download starting points and switch to uncompressed example data. ([PR #15](https://github.com/nextstrain/zika/pull/15))
* 14 March 2022: Use the python 3.7 miniconda installer to fix error in travis test. ([PR #14](https://github.com/nextstrain/zika/pull/14))

## 2021

* 09 November 2021: CI: Upgrade setuptools suite prior to installation. ([PR #13](https://github.com/nextstrain/zika/pull/13))
* 28 October 2021: Update outliers and broaden subsampling. ([7a2dba5](https://github.com/nextstrain/zika/commit/7a2dba5ac298e8edecacd5e19124399f713af33f))

## 2020

* 13 December 2020: Update zika build to use `--output-node-data` instead of `--output`. ([4c47f43](https://github.com/nextstrain/zika/commit/4c47f439ba714cbf5e25a81462de2819ac16f9d0))

## 2019

* 14 December 2019: Add footer description to export. ([PR #11](https://github.com/nextstrain/zika/pull/11))
* 10 December 2019: Switch to augur export v2. ([PR #10](https://github.com/nextstrain/zika/pull/10))

## 2018

* 27 December 2018: Move vdb download call from python2 to python3. ([12d35b2](https://github.com/nextstrain/zika/commit/12d35b281fcb9b0482b58e1247dad2ee500e83b4))
* 29 October 2018: Updates to Zika reference, dropped strains, min-length, and sampling bias correction. ([9e50fe2](https://github.com/nextstrain/zika/commit/9e50fe2dc6ac8209e829278007a938bba7ea7b32))
* 06 July 2018: Attempt at streamlining the snakefile ([PR #8](https://github.com/nextstrain/zika/pull/8))
* 29 June 2018: Travis CI configuration to run the example data build. ([5c4f6f6](https://github.com/nextstrain/zika/commit/5c4f6f6b682422f568280093d8548e7c77428d6f))
* 29 June 2018: Download sequences from fauna automatically. ([ee8cc38](https://github.com/nextstrain/zika/commit/ee8cc38ff5ab46db2bd5f4ac136811bcead5f003))
* 15 June 2018: Initial commit ([5640dba](https://github.com/nextstrain/zika/commit/5640dba33661365c0a9cf8614d2c04b01d227b15))