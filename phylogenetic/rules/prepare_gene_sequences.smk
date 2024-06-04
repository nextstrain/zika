"""
This part of the workflow prepares reference files and sequences for constructing the gene phylogenetic trees.
REQUIRED INPUTS:
    reference   = path to reference sequence or genbank
    sequences   = path to all sequences from which gene sequences can be extracted

OUTPUTS:
    gene_fasta = reference fasta for the gene (e.g. E gene)
    gene_genbank = reference genbank for the gene (e.g. E gene)
    sequences = sequences with gene sequences extracted and aligned to the reference gene sequence
This part of the workflow usually includes the following steps:
    - newreference.py: Creates new gene genbank and gene reference FASTA from the whole genome reference genbank
    - nextclade: Aligns sequences to the reference gene sequence and extracts the gene sequences to ensure the reference files are valid
See Nextclade or script usage docs for these commands for more details.
"""

rule generate_gene_reference_files:
    """
    Generating reference files for gene builds
    """
    input:
        reference = "defaults/zika_reference.gb",
    output:
        fasta = "results/config/reference_{gene}.fasta",
        genbank = "results/config/reference_{gene}.gb",
    shell:
        """
        python3 scripts/newreference.py \
            --reference {input.reference} \
            --output-fasta {output.fasta} \
            --output-genbank {output.genbank} \
            --gene {wildcards.gene}
        """


rule align_and_extract_gene:
    """
    Cutting sequences to the length of the gene reference sequence
    """
    input:
        sequences = "data/sequences_all.fasta",
        reference = "results/config/reference_{gene}.fasta"
    output:
        sequences = "results/{gene}/sequences.fasta"
    params:
        min_length = lambda wildcard: config["filter"]["min_length"][wildcard.gene],
    shell:
        """
        nextclade run \
           -j 1 \
           --input-ref {input.reference} \
           --output-fasta {output.sequences} \
           --min-seed-cover 0.01 \
           --min-length {params.min_length} \
           --silent \
           {input.sequences}
        """
