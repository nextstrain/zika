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

rule download:
    """Downloading sequences and metadata from data.nextstrain.org"""
    output:
        sequences = "data/sequences.fasta.zst",
        metadata = "data/metadata.tsv.zst"
    params:
        sequences_url = "https://data.nextstrain.org/files/workflows/zika/sequences.fasta.zst",
        metadata_url = "https://data.nextstrain.org/files/workflows/zika/metadata.tsv.zst"
    shell:
        """
        curl -fsSL --compressed {params.sequences_url:q} --output {output.sequences}
        curl -fsSL --compressed {params.metadata_url:q} --output {output.metadata}
        """

rule decompress:
    """Decompressing sequences and metadata"""
    input:
        sequences = "data/sequences.fasta.zst",
        metadata = "data/metadata.tsv.zst"
    output:
        sequences = "data/sequences.fasta",
        metadata = "data/metadata.tsv"
    shell:
        """
        zstd -d -c {input.sequences} > {output.sequences}
        zstd -d -c {input.metadata} > {output.metadata}
        """

rule filter:
    """
    Filtering to
      - from {params.min_date} onwards
      - excluding strains in {input.exclude}
      - minimum genome length of {params.min_length} (50% of Zika virus genome)
    """
    input:
        sequences = "data/sequences_all.fasta",
        metadata = "data/metadata_all.tsv",
        exclude = "config/dropped_strains.txt",
    output:
        sequences = "results/filtered.fasta",
        metadata = "results/filtered.tsv"
    params:
        min_date = 2012,
        min_length = 5385,
        strain_id = config.get("strain_id_field", "strain"),
    shell:
        """
        augur filter \
            --sequences {input.sequences} \
            --metadata {input.metadata} \
            --metadata-id-columns {params.strain_id} \
            --exclude {input.exclude} \
            --output-sequences {output.sequences} \
            --output-metadata {output.metadata} \
            --min-date {params.min_date} \
            --min-length {params.min_length}
        """

rule align:
    """
    Aligning sequences to {input.reference}
      - filling gaps with N
    """
    input:
        sequences = "results/filtered.fasta",
        reference = "config/zika_reference.gb"
    output:
        alignment = "results/aligned.fasta"
    shell:
        """
        augur align \
            --sequences {input.sequences} \
            --reference-sequence {input.reference} \
            --output {output.alignment} \
            --fill-gaps \
            --remove-reference
        """

rule subsample:
    input:
        metadata = "results/filtered.tsv",
        sequences = "results/aligned.fasta",
        reference = "config/reference.fasta",
        config = "config/subsampling.yaml",
    output:
        metadata = "results/subsampled.tsv",
        sequences = "results/subsampled.fasta",
    params:
        tmpdir = "results/subsampling",
        strain_id = config.get("strain_id_field", "strain"),
    shell:
        """
        augur subsample \
            --config {input.config} \
            --metadata {input.metadata} --sequences {input.sequences} --reference {input.reference} \
            --output-metadata {output.metadata} --output-sequences {output.sequences} \
            --tmpdir {params.tmpdir} \
            --metadata-id-columns {params.strain_id}
        """
