"""
This part of the workflow prepares sequences for constructing the phylogenetic tree.

REQUIRED INPUTS:

    metadata_url    = url to metadata.tsv.zst
    sequences_url   = url to sequences.fasta.zst
    reference   = path to reference sequence or genbank

OUTPUTS:

    prepared_sequences = results/aligned.fasta

This part of the workflow usually includes the following steps:

    - augur index
    - augur filter
    - augur align
    - augur mask

See Augur's usage docs for these commands for more details.
"""

rule filter:
    """
    Filtering to
      - {params.sequences_per_group} sequence(s) per {params.group_by!s}
      - from {params.min_date} onwards
      - excluding strains in {input.exclude}
      - minimum genome length of {params.min_length} (50% of Zika virus genome)
    """
    input:
        sequences = input_sequences,
        metadata = input_metadata,
        exclude = resolve_config_path(config["exclude"]),
    output:
        sequences = "results/filtered.fasta"
    params:
        group_by = as_list(config["filter"]["group_by"]),
        sequences_per_group = config["filter"]["sequences_per_group"],
        min_date = config["filter"]["min_date"],
        min_length = config["filter"]["min_length"],
        strain_id = config.get("strain_id_field", "strain"),
    log:
        "logs/filter.txt",
    benchmark:
        "benchmarks/filter.txt"
    shell:
        r"""
        exec &> >(tee {log:q})

        augur filter \
            --sequences {input.sequences:q} \
            --metadata {input.metadata:q} \
            --metadata-id-columns {params.strain_id:q} \
            --exclude {input.exclude:q} \
            --output {output.sequences:q} \
            --group-by {params.group_by:q} \
            --sequences-per-group {params.sequences_per_group:q} \
            --min-date {params.min_date:q} \
            --min-length {params.min_length:q}
        """


# rule upload_filter:
#     """TESTING ONLY TODO XXX REMOVE"""
#     input:
#         sequences = input_sequences,
#         metadata = input_metadata,
#         exclude = resolve_config_path(config["exclude"]),
#     output:
#         sequences = path_or_url("s3://nextstrain-scratch/zika-pr-89/filtered.fasta")
#     params:
#         group_by = as_list(config["filter"]["group_by"]),
#         sequences_per_group = config["filter"]["sequences_per_group"],
#         min_date = config["filter"]["min_date"],
#         min_length = config["filter"]["min_length"],
#         strain_id = config.get("strain_id_field", "strain"),
#     log:
#         "logs/filter.txt",
#     benchmark:
#         "benchmarks/filter.txt"
#     shell:
#         r"""
#         exec &> >(tee {log:q})

#         augur filter \
#             --sequences {input.sequences:q} \
#             --metadata {input.metadata:q} \
#             --metadata-id-columns {params.strain_id:q} \
#             --exclude {input.exclude:q} \
#             --output-sequences {output.sequences:q} \
#             --group-by {params.group_by:q} \
#             --sequences-per-group {params.sequences_per_group:q} \
#             --min-date {params.min_date:q} \
#             --min-length {params.min_length:q}
#         """


rule align:
    """
    Aligning sequences to {input.reference}
      - filling gaps with N
    """
    input:
        sequences = "results/filtered.fasta",
        reference = resolve_config_path(config["reference"]),
    output:
        alignment = "results/aligned.fasta"
    log:
        "logs/align.txt",
    benchmark:
        "benchmarks/align.txt"
    shell:
        r"""
        exec &> >(tee {log:q})

        augur align \
            --sequences {input.sequences:q} \
            --reference-sequence {input.reference:q} \
            --output {output.alignment:q} \
            --fill-gaps \
            --remove-reference
        """
