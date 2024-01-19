rule download_usvi:
    """Downloading sequences and metadata from data.nextstrain.org"""
    output:
        sequences = "data/sequences_usvi.fasta.zst",
        metadata = "data/metadata_usvi.tsv.zst"
    params:
        sequences_url = "https://data.nextstrain.org/files/zika/sequences_usvi.fasta.zst",
        metadata_url = "https://data.nextstrain.org/files/zika/metadata_usvi.tsv.zst"
    shell:
        """
        curl -fsSL --compressed {params.sequences_url:q} --output {output.sequences}
        curl -fsSL --compressed {params.metadata_url:q} --output {output.metadata}
        """

rule decompress_usvi:
    """Decompressing sequences and metadata"""
    input:
        sequences = "data/sequences_usvi.fasta.zst",
        metadata = "data/metadata_usvi.tsv.zst"
    output:
        sequences = "data/sequences_usvi.fasta",
        metadata = "data/metadata_usvi.tsv"
    shell:
        """
        zstd -d -c {input.sequences} > {output.sequences}
        zstd -d -c {input.metadata} > {output.metadata}
        """

rule append_usvi:
    """Appending USVI sequences"""
    input:
        sequences = "data/sequences.fasta",
        metadata = "data/metadata.tsv",
        usvi_sequences = "data/sequences_usvi.fasta",
        usvi_metadata = "data/metadata_usvi.tsv"
    output:
        sequences = "data/sequences_all.fasta",
        metadata = "data/metadata_all.tsv"
    shell:
        """
        cat {input.sequences} {input.usvi_sequences} > {output.sequences}

        csvtk mutate2 -tl \
          -n url \
          -e '"https://www.ncbi.nlm.nih.gov/nuccore/" + $genbank_accession' \
          {input.metadata} \
        | csvtk mutate2 -tl \
          -n accession \
          -e '$genbank_accession' \
        | csvtk concat -tl - {input.usvi_metadata} \
        > {output.metadata}
        """