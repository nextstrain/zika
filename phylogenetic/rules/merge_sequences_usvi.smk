"""
This part of the workflow appends USVI data to the main dataset.

REQUIRED INPUTS:

    usvi_sequences  = data/sequences_usvi.fasta
    usvi_metadata   = data/metadata_usvi.tsv
    main_sequences  = data/sequences.fasta
    main_metadata   = data/metadata.tsv

OUTPUTS:

    merged_sequences = data/sequences_all.fasta
    merged_metadata  = data/metadata_all.tsv


This part of the workflow usually includes the following steps:

    - Any transformation to match the columns of the tsv files
    - Concatenation of the tsv and the sequences files

"""


# ------------- helper functions to collect, merge & download input files ------------------- #
NEXTSTRAIN_PUBLIC_BUCKET = "s3://nextstrain-data/"

def _parse_config_input(input):
    """
    Parses information from an individual config-defined input, i.e. an element within `config.inputs` or `config.additional_inputs`
    and returns information snakemake rules can use to obtain the underlying data.

    The structure of `input` is a dictionary with keys:
    - name:string (required)
    - metadata:string (optional) - a s3 URI or a local file path
    - sequences:string|dict[string,string] (optional) - either a s3 URI or a local file path, in which case
      it must include a '{segment}' wildcard substring, or a dict of segment → s3 URI or local file path,
      in which case it must not include the wildcard substring.

    Returns a dictionary with optional keys:
    - metadata:string - the relative path to the metadata file. If the original data was remote then this represents
      the output of a rule which downloads the file
    - metadata_location:string - the URI for the remote file if applicable else `None`
    - sequences:function. Takes in wildcards and returns the relative path to the sequences FASTA for the provided
      segment wildcard, or returns `None` if this input doesn't define sequences for the provided segment.
    - sequences_location:function. Takes in wildcards and returns the URI for the remote file, or `None`, where applicable.

    Raises InvalidConfigError
    """
    name = input['name']
    lambda_none = lambda w: None

    info = {'metadata': None, 'metadata_location': None, 'sequences': lambda_none, 'sequences_location': lambda_none}

    def _source(uri, *,  s3, local):
        if uri.startswith('s3://'):
            return s3
        elif uri.lower().startswith('http://') or uri.lower().startswith('https://'):
            raise InvalidConfigError("Workflow cannot yet handle HTTP[S] inputs")
        # USVI files are expected to be part of the workflow source,
        # and is _not_ expected to be provided via the analysis directory
        elif uri.startswith('data/metadata_usvi.tsv') or uri.startswith('data/sequences_usvi.fasta'):
            return workflow.source_path("../" + uri)
        return local

    if location:=input.get('metadata', False):
        info['metadata'] = _source(location,  s3=f"data/{name}/metadata.tsv", local=location)
        info['metadata_location'] = _source(location,  s3=location, local=None)

    if location:=input.get('sequences', False):
        info['sequences'] = _source(location,  s3=f"data/{name}/sequences.fasta", local=location)
        info['sequences_location'] = _source(location,  s3=location, local=None)

    return info


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

    return {i['name']: _parse_config_input(i) for i in all_inputs}

input_sources = _gather_inputs()

def input_metadata(wildcards):
    inputs = [info['metadata'] for info in input_sources.values() if info.get('metadata', None)]
    return inputs[0] if len(inputs)==1 else "results/metadata_merged.tsv"

def input_sequences(wildcards):
    inputs = [info['sequences'] for info in input_sources.values() if info.get('sequences', None)]
    return inputs[0] if len(inputs)==1 else "results/sequences_merged.fasta"

# def input_sequences(wildcards):
#     inputs = list(filter(None, [info['sequences'](wildcards) for info in input_sources.values() if info.get('sequences', None)]))
#     return inputs[0] if len(inputs)==1 else "results/sequences_merged_{segment}.fasta"

rule download_s3_sequences:
    output:
        sequences = "data/{input_name}/sequences.fasta",
    log:
        "logs/{input_name}/download_s3_sequences.txt",
    benchmark:
        "benchmarks/{input_name}/download_s3_sequences.txt"
    params:
        address = lambda w: input_sources[w.input_name]['sequences_location'],
        no_sign_request=lambda w: "--no-sign-request" \
            if input_sources[w.input_name]['sequences_location'].startswith(NEXTSTRAIN_PUBLIC_BUCKET) \
            else "",
    shell:
        r"""
        exec &> >(tee {log:q})

        aws s3 cp {params.no_sign_request:q} {params.address:q} - | zstd -d > {output.sequences}
        """

rule download_s3_metadata:
    output:
        metadata = "data/{input_name}/metadata.tsv",
    log:
        "logs/{input_name}/download_s3_metadata.txt",
    benchmark:
        "benchmarks/{input_name}/download_s3_metadata.txt"
    params:
        address = lambda w: input_sources[w.input_name]['metadata_location'],
        no_sign_request=lambda w: "--no-sign-request" \
            if input_sources[w.input_name]['metadata_location'].startswith(NEXTSTRAIN_PUBLIC_BUCKET) \
            else "",
    shell:
        r"""
        exec &> >(tee {log:q})

        aws s3 cp {params.no_sign_request:q} {params.address:q} - | zstd -d > {output.metadata}
        """

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