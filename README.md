# nextstrain.org/zika

**This is currently a preliminary example of moving pathogen builds to
independent repositories.  It is not currently used for the live site.**

This is the [Nextstrain][] build for Zika, visible at
<https://nextstrain.org/zika>.

The build encompasses fetching data, preparing it for analysis, doing quality
control, performing analyses, and saving the results in a format suitable for
visualization (with [auspice][]).  This involves running components of
Nextstrain such as [fauna][] and [augur][].

All Zika-specific steps and functionality for the Nextstrain pipeline should be
housed in this repository.


## Usage

The easiest way to run this pathogen build is using the [Nextstrain
command-line tool][nextstrain-cli]:

    nextstrain build .

See the [nextstrain-cli README][] for how to install the `nextstrain` command.

Alternatively, you should be able to run the build using `snakemake` within an
suitably-configured local environment.  Details of setting that up are not yet
well-documented, but will be in the future.

All build output files will go into a new `build/` directory.

Once you've run the build, you can view the results in auspice:

    nextstrain view build/auspice/


## Configuration

The main configuration file is `config.yaml`, with supporting files in the
`config/` directory.

To override any part of the config, you can create a file named
`config_local.yaml` and add the bits you want you change.  For example, it's
useful during development to speed up build times by very heavily subsampling
the dataset.  You can use this `config_local.yaml` to do that:

```yaml
---
filter:
    sequences_per_category: 1
```

### fauna / RethinkDB credentials

This build starts by pulling sequences from our live [fauna][] database (a
RethinkDB instance).  For data privacy and security reasons, you'll need to
provide credentials to the database yourself, using a `config_local.yaml`
snippet like so:

```yaml
---
credentials:
  rethink:
    host: ...
    auth_key: ...
```

If you don't have access to our database, you can run the build using the
example data provided in this repository.  Before running the build, copy the
sequences into the `build/` directory like so:

    mkdir -p build/data/
    cp example_data/zika.fasta build/data/

### Per-run config

It is also possible to override config values for each run by passing
`--config` or `--configfile` options to `snakemake`.  See the [`snakemake`
command-line options documentation][snakemake cli].


[Nextstrain]: https://nextstrain.org
[fauna]: https://github.com/nextstrain/fauna
[augur]: https://github.com/nextstrain/augur
[auspice]: https://github.com/nextstrain/auspice
[snakemake cli]: https://snakemake.readthedocs.io/en/stable/executable.html#all-options
[nextstrain-cli]: https://github.com/nextstrain/cli
[nextstrain-cli README]: https://github.com/nextstrain/cli/blob/master/README.md
