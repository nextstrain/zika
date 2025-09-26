# CHANGELOG

We use this CHANGELOG to document breaking changes, new features, bug fixes,
and config value changes that may affect both the usage of the workflows and
the outputs of the workflows.

## 2025

* 26 September 2025: Updated workflow compatibility declaration in `nextstrain-pathogen.yaml`.
  **This requires Nextstrain CLI >=10.3.0** to setup and update the pathogen without error messages.
  However, workflows will still run with Nextstrain CLI <10.3.0 [#101][]
* 25 July 2025: phylogenetic - Major update to the definition of inputs. ([#80][])

The configuration has been updated from top level keys:

```yaml
sequences_url: "https://data.nextstrain.org/files/workflows/zika/sequences.fasta.zst"
metadata_url: "https://data.nextstrain.org/files/workflows/zika/metadata.tsv.zst"
```

to named dictionary key of multiple inputs:

```yaml
inputs:
  - name: ncbi
    metadata: "s3://nextstrain-data/files/workflows/zika/metadata.tsv.zst"
    sequences: "s3://nextstrain-data/files/workflows/zika/sequences.fasta.zst"
  - name: usvi
    metadata: "s3://nextstrain-data/files/workflows/zika/metadata_usvi.tsv.zst"
    sequences: "s3://nextstrain-data/files/workflows/zika/sequences_usvi.fasta.zst"
```

* 06 June 2025: Updated workflows to support the `nextstrain run` command. ([#85][])
  * See individual workflow's `README.md` for detailed instructions on how to use `nextstrain run`.
* 06 June 2025: phylogenetic - convert config params `filter.group_by` and `traits.columns` to lists. ([#84][])
  * Backwards compatible with string param values, which are automatically split into a list.
* 06 June 2025: ingest - removed path for separate data sources. ([#84][])
  * The config param `sources` is no longer supported
* 06 June 2025: Updated workflows to latest internal guidelines. ([#84][])
  * ingest - fixed handling of TSVs
  * ingest/phylogenetic - added logs and benchmarks for all rules
* 04 March 2025: ingest - ncov-ingest geolocation rules with built-in `augur curate` geolocation rules ([#79][])
  *  The config param `curate.geolocation_rules_url` is no longer supported.

[#79]: https://github.com/nextstrain/zika/pull/79
[#80]: https://github.com/nextstrain/zika/pull/80
[#84]: https://github.com/nextstrain/zika/pull/84
[#85]: https://github.com/nextstrain/zika/pull/85
[#101]: https://github.com/nextstrain/zika/pull/101

## 2024

* 17 December 2024: ingest - metadata columns updated. ([#78][])
  * renamed `genbank_accession` to `accession`
  * renamed `genbank_accession_rev` to `accession_version`
  * added column `url`, which includes the automated generated link to the NCBI GenBank record
* 09 December 2024: phylogenetic - use `augur merge` to merge USVI data. This should not affect final workflow outputs. ([#75][])
* 26 November 2024: phylogenetic - final Auspice JSON uses config param `strain_id_field` as internal `name` and
  `defaults/auspice_config.json` defines the default `tip_label` as `strain`. ([#72][])
  * The config param `display_strain_field` is no longer supported.
* 16 July 2024: ingest - replace custom scripts with `augur curate` commands. ([#69][])
  * Requires a new `genbank_location_field` config param.
* 02 July 2024: phylogenetic - updated `defaults/description.md`. ([#67][])
* 13 June 2024: phylogenetic - added data provenance in `defaults/auspice_config.json`. ([#65][])
* 07 June 2024: phylogenetic - updated maintainers in `defaults/auspice_config.json`. ([#64][])
* 02 May 2024: ingest - fixed handling of internal quotes in NCBI TSVs. ([#58][])
* 16 April 2024: phylogenetic - updated to export Auspice JSON with an inline root sequence. ([#57][])
* 08 March 2024: phylogenetic - updated maintainers in `defaults/auspice_config.json`. ([#49][])
* 08 March 2024: phylogenetic - moved hardcoded params to the config file so they can be overridden with custom config files. ([#48][])
  * See `defaults/config_zika.yaml` for available config params.
* 04 March 2024: ingest - added config param `custom_rules` to extend or override the core rules. ([#46])
* 01 March 2024: ingest/phylogenetic - workflows' default files moved from `/config` to `/defaults`. ([#43][])
* 24 February 2024: Move accession to the first column of `metadata_all.tsv`. ([PR #36](https://github.com/nextstrain/zika/pull/36))
* 05 February 2024: Harmonize with [pathogen repo guide](https://github.com/nextstrain/pathogen-repo-guide) ([PR #31](https://github.com/nextstrain/zika/pull/31))
* 19 January 2024: Add a Quickstart section to the top level README. ([PR #30](https://github.com/nextstrain/zika/pull/30))
* 19 January 2024: Add ingest pipeline and restructure phylogeny pipeline. ([PR #28](https://github.com/nextstrain/zika/pull/28))
  * The addition of the ingest pipeline is a major change. Instead of relying on the `fauna` database, this introduces retrieving data from NCBI datasets directly and conducting subsequent curation.
  * The restructuring of the `phylogenetic` pipeline into a dedicated directory keeps the two workflows modular, and conforms to the [pathogen repo guide](https://github.com/nextstrain/pathogen-repo-guide).
  * Documenting and providing the USVI data in the `phylogenetic/data` directory.

[#43]: https://github.com/nextstrain/zika/pull/43
[#46]: https://github.com/nextstrain/zika/pull/46
[#48]: https://github.com/nextstrain/zika/pull/48
[#49]: https://github.com/nextstrain/zika/pull/49
[#57]: https://github.com/nextstrain/zika/pull/57
[#58]: https://github.com/nextstrain/zika/pull/58
[#64]: https://github.com/nextstrain/zika/pull/64
[#65]: https://github.com/nextstrain/zika/pull/65
[#67]: https://github.com/nextstrain/zika/pull/67
[#69]: https://github.com/nextstrain/zika/pull/69
[#72]: https://github.com/nextstrain/zika/pull/72
[#75]: https://github.com/nextstrain/zika/pull/75
[#78]: https://github.com/nextstrain/zika/pull/78


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
