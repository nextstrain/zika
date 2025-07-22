"""
This part of the workflow merges inputs from any of:
    curated NCBI dataset: via s3 remote
    additional local data: via path to files

based on what is defined in the config YAML file.

REQUIRED INPUTS:

    config.yaml  = defines input files within a dictionary in either 'inputs' or 'additional_inputs'

OUTPUTS:

    input_sequences = gathered and merged sequences
    input_metadata  = gathered and merged metadata


This part of the workflow usually includes the following steps:

    - Any transformation to match the columns of the tsv files
    - Concatenation of the tsv and the sequences files

"""

def _gather_inputs():
    all_inputs = [*config['inputs'], *config.get('additional_inputs', [])]

    if len(all_inputs)==0:
        raise InvalidConfigError("Config must define at least one element in config.inputs or config.additional_inputs lists")
    if not all([isinstance(i, dict) for i in all_inputs]):
        raise InvalidConfigError("All of the elements in config.inputs and config.additional_inputs lists must be dictionaries"
            "If you've used a command line '--config' double check your quoting.")
    if len({i['name'] for i in all_inputs})!=len(all_inputs):
        raise InvalidConfigError("Names of inputs (config.inputs and config.additional_inputs) must be unique")
    if not all(['name' in i and ('sequences' in i or 'metadata' in i) for i in all_inputs]):
        raise InvalidConfigError("Each input (config.inputs and config.additional_inputs) must have a 'name' and 'metadata' and/or 'sequences'")

    available_keys = set(['name', 'metadata', 'sequences'])
    if any([len(set(el.keys())-available_keys)>0 for el in all_inputs]):
        raise InvalidConfigError(f"Each input (config.inputs and config.additional_inputs) can only include keys of {', '.join(available_keys)}")

    return {el['name']: {k:(v if k=='name' else path_or_url(v)) for k,v in el.items()} for el in all_inputs}

input_sources = _gather_inputs()

def input_metadata(wildcards):
    inputs = [info['metadata'] for info in input_sources.values() if info.get('metadata', None)]
    return inputs[0] if len(inputs)==1 else "results/metadata_merged.tsv"

def input_sequences(wildcards):
    inputs = [info['sequences'] for info in input_sources.values() if info.get('sequences', None)]
    return inputs[0] if len(inputs)==1 else "results/sequences_merged.fasta"

rule merge_metadata:
    """
    This rule should only be invoked if there are multiple defined metadata inputs
    (config.inputs + config.additional_inputs)
    """
    input:
        **{name: info['metadata'] for name,info in input_sources.items() if info.get('metadata', None)}
    params:
        metadata = lambda w, input: list(map("=".join, input.items())),
        id_field = config['strain_id_field'],
    output:
        metadata = "results/metadata_merged.tsv"
    log:
        "logs/merge_metadata.txt",
    benchmark:
        "benchmarks/merge_metadata.txt"
    shell:
        r"""
        exec &> >(tee {log:q})

        augur merge \
            --metadata {params.metadata:q} \
            --metadata-id-columns {params.id_field} \
            --output-metadata {output.metadata}
        """

rule merge_sequences:
    """
    This rule should only be invoked if there are multiple defined sequences inputs
    (config.inputs + config.additional_inputs) for this particular segment
    """
    input:
        **{name: info['sequences'] for name,info in input_sources.items() if info.get('sequences', None)}
    output:
        sequences = "results/sequences_merged.fasta"
    log:
        "logs/merge_sequences.txt",
    benchmark:
        "benchmarks/merge_sequences.txt"
    shell:
        r"""
        exec &> >(tee {log:q})

        seqkit rmdup {input:q} > {output.sequences:q}
        """

# -------------------------------------------------------------------------------------------- #