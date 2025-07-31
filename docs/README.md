# Docs about Zika Docs


## Dependencies

in `conda.yml` - install these in the same environment you run augur in

## Testing (WIP!)

To test with nextstrain run we either need to symlink the checked out repo:

```bash
mkdir ~/.nextstrain/pathogens/zika
ln -sv ~/github/nextstrain/zika ~/.nextstrain/pathogens/zika/local=NRXWGYLM
```

and check it's installed:

```console
$ nextstrain version --pathogens
Nextstrain CLI 10.2.1.post1+git 

Pathogens
  ...

  zika
    zika@local (default)
```

or you should be able to use `nextstrain setup` from this branch (UNTESTED!)

```bash
nextstrain setup 'zika@james/docs-prototyping'
```

> Assumptions:
> 1. That we installed using the symlink method, if not replace `zika@local` with `zika@james/docs-prototyping`
> 2. That you've installed the docs dependencies (see above) into the nextstrain runtime you want to use. The following commands use `--ambient`
> 3. That you're running from an external analysis directory (shouldn't matter, but easier to clean up if things go wrong)

We then need to build the docs - in the future this step will be done during `nextstrain setup`, or when we build the image for a repo (via buildpacks etc etc), or some other way - but for now we can achieve this in a ad-hoc way:

```bash
nextstrain run --ambient zika@local docs . build
```

And then open the docs (might only work on MacOS). Long term we wouldn't use `nextstrain run` for this, we'd have a nicer interface like `nextstrain docs zika@local`.

```bash
nextstrain run --ambient zika@local docs . open
```

## Helpful commands:
* `make html && open build/html/index.html`
* `make livehtml`
* `make clean`