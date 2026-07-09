"""
Merges inputs based on what is defined in the config.

OUTPUTS:

    metadata  = results/metadata.tsv
    sequences = results/sequences.fasta

See shared/vendored/snakemake/merge_inputs.smk for input config schema.
"""

module merge_inputs:
    snakefile: "../../shared/vendored/snakemake/merge_inputs.smk"
    config: config


use rule merge_metadata from merge_inputs with:
    output:
        metadata = "results/metadata.tsv"


use rule merge_sequences from merge_inputs with:
    output:
        sequences = "results/sequences.fasta"
