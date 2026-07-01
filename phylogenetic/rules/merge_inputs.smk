"""
This part of the workflow merges inputs based on what is defined in the config.

OUTPUTS:

    metadata  = results/metadata.tsv
    sequences = results/sequences.fasta

The config dict is expected to have a top-level `inputs` list that defines the
separate inputs' name, metadata, and sequences. Optionally, the config can have
a top-level `additional-inputs` list that is used to define additional data that
are combined with the default inputs:

```yaml
inputs:
    - name: default
      metadata: <path-or-url>
      id_field: <metadata-id-field-name>
      sequences: <path-or-url>

additional_inputs:
    - name: private
      metadata: <path-or-url>
      id_field: <metadata-id-field-name>
      sequences: <path-or-url>
```

The `id_field` key for each input is passed through to `augur merge
--metadata-id-columns`.

Supports any of the compression formats that are supported by `augur read-file`,
see <https://docs.nextstrain.org/projects/augur/page/usage/cli/read-file.html>
"""
from pathlib import Path


def _gather_inputs():
    all_inputs = [*config['inputs'], *config.get('additional_inputs', [])]

    if len(all_inputs)==0:
        raise InvalidConfigError("Config must define at least one element in config.inputs or config.additional_inputs lists")
    if not all([isinstance(i, dict) for i in all_inputs]):
        raise InvalidConfigError("All of the elements in config.inputs and config.additional_inputs lists must be dictionaries. "
            "If you've used a command line '--config' double check your quoting.")
    if len({i['name'] for i in all_inputs})!=len(all_inputs):
        raise InvalidConfigError("Names of inputs (config.inputs and config.additional_inputs) must be unique")
    if not all(['name' in i and ('sequences' in i or 'metadata' in i) for i in all_inputs]):
        raise InvalidConfigError("Each input (config.inputs and config.additional_inputs) must have a 'name' and 'metadata' and/or 'sequences'")
    if not any(['metadata' in i for i in all_inputs]):
        raise InvalidConfigError("At least one input must have 'metadata'")
    if not any (['sequences' in i for i in all_inputs]):
        raise InvalidConfigError("At least one input must have 'sequences'")
    if not all(['id_field' in i for i in all_inputs if 'metadata' in i]):
        raise InvalidConfigError("Each input with 'metadata' must also have an 'id_field'")

    available_keys = set(['name', 'metadata', 'id_field', 'sequences'])
    if any([len(set(el.keys())-available_keys)>0 for el in all_inputs]):
        raise InvalidConfigError(f"Each input (config.inputs and config.additional_inputs) can only include keys of {', '.join(available_keys)}")

    return {el['name']: {k:(v if k=='name' else path_or_url(v)) for k,v in el.items()} for el in all_inputs}

input_sources = _gather_inputs()


rule merge_metadata:
    """
    Merges the metadata inputs (config.inputs + config.additional_inputs).
    """
    input:
        **{name: info['metadata'] for name,info in input_sources.items() if info.get('metadata', None)}
    params:
        metadata = lambda w, input: list(map("=".join, input.items())),
        id_field = [f"{name}={info['id_field']}" for name,info in input_sources.items() if info.get('metadata', None)],
    output:
        metadata = "results/metadata.tsv"
    log:
        "logs/merge_metadata.txt",
    benchmark:
        "benchmarks/merge_metadata.txt"
    shell:
        r"""
        exec &> >(tee {log:q})

        augur merge \
            --metadata {params.metadata:q} \
            --metadata-id-columns {params.id_field:q} \
            --output-metadata {output.metadata:q}
        """


rule merge_sequences:
    """
    Merges the sequences inputs (config.inputs + config.additional_inputs).
    """
    input:
        **{name: info['sequences'] for name,info in input_sources.items() if info.get('sequences', None)}
    output:
        sequences = "results/sequences.fasta",
    log:
        "logs/merge_sequences.txt",
    benchmark:
        "benchmarks/merge_sequences.txt"
    shell:
        r"""
        exec &> >(tee {log:q})

        augur merge \
            --sequences {input:q} \
            --output-sequences {output.sequences:q}
        """
