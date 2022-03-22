# nextstrain.org/zika

This is the [Nextstrain](https://nextstrain.org) build for Zika, visible at
[nextstrain.org/zika](https://nextstrain.org/zika).

The build encompasses fetching data, preparing it for analysis, doing quality
control, performing analyses, and saving the results in a format suitable for
visualization (with [auspice][]).  This involves running components of
Nextstrain such as [fauna][] and [augur][].

All Zika-specific steps and functionality for the Nextstrain pipeline should be
housed in this repository.

_This build requires Augur v6._

[![Build Status](https://travis-ci.com/nextstrain/zika.svg?branch=master)](https://travis-ci.com/nextstrain/zika)

## Usage

If you're unfamiliar with Nextstrain builds, you may want to follow our
[quickstart guide][] first and then come back here.

There are two main ways to run & visualise the output from this build:

The first, and easiest, way to run this pathogen build is using the [Nextstrain
command-line tool][nextstrain-cli]:
```
nextstrain build .
nextstrain view auspice/
```

See the [nextstrain-cli README][] for how to install the `nextstrain` command.

The second is to install augur & auspice using conda, following [these instructions](https://nextstrain.org/docs/getting-started/local-installation#install-augur--auspice-with-conda-recommended).
The build may then be run via:
```
snakemake
auspice --datasetDir auspice/
```

Build output goes into the directories `data/`, `results/` and `auspice/`.


## Configuration

Configuration takes place entirely with the `Snakefile`. This can be read top-to-bottom, each rule
specifies its file inputs and output and also its parameters. There is little redirection and each
rule should be able to be reasoned with on its own.


## Input data

This build starts by downloading sequences from
[https://data.nextstrain.org/files/zika/sequences.fasta.xz](data.nextstrain.org/files/zika/sequences.fasta.xz)
and metadata from
[https://data.nextstrain.org/files/zika/metadata.tsv.gz](data.nextstrain.org/files/zika/metadata.tsv.gz).
These are publicly provisioned data by the Nextstrain team by pulling sequences
from NCBI GenBank via ViPR and performing additional bespoke curation. Our
curation is described
[here](https://github.com/nextstrain/fauna/blob/master/builds/ZIKA.md).

Data from GenBank follows Open Data principles, such that we can make input data
and intermediate files available for further analysis. Open Data is data that
can be freely used, re-used and redistributed by anyone - subject only, at most,
to the requirement to attribute and sharealike.

We gratefully acknowledge the authors, originating and submitting laboratories
of the genetic sequences and metadata for sharing their work in open databases.
Please note that although data generators have generously shared data in an open
fashion, that does not mean there should be free license to publish on this
data. Data generators should be cited where possible and collaborations should
be sought in some circumstances. Please try to avoid scooping someone else's
work. Reach out if uncertain. Authors, paper references (where available) and
links to GenBank entries are provided in the metadata file.

[Nextstrain]: https://nextstrain.org
[fauna]: https://github.com/nextstrain/fauna
[augur]: https://github.com/nextstrain/augur
[auspice]: https://github.com/nextstrain/auspice
[snakemake cli]: https://snakemake.readthedocs.io/en/stable/executable.html#all-options
[nextstrain-cli]: https://github.com/nextstrain/cli
[nextstrain-cli README]: https://github.com/nextstrain/cli/blob/master/README.md
[quickstart guide]: https://nextstrain.org/docs/getting-started/quickstart
