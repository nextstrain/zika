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

rule add_metadata_columns:
    """Add columns to metadata

    Notable columns:
    - genbank_accession: GenBank accession for Auspice to generate a URL to the NCBI GenBank record.
    - [NEW] accession: The GenBank accession. Added to go alongside USVI accession.
    - [NEW] url: URL linking to the NCBI GenBank record ('https://www.ncbi.nlm.nih.gov/nuccore/*'). Added to go alongside USVI url.
    """
    input:
        metadata = "data/metadata.tsv"
    output:
        metadata = "data/metadata_modified.tsv"
    shell:
        """
        csvtk mutate2 -tl \
          -n url \
          -e '"https://www.ncbi.nlm.nih.gov/nuccore/" + $genbank_accession' \
          {input.metadata} \
        | csvtk mutate2 -tl \
          -n accession \
          -e '$genbank_accession' \
        > {output.metadata}
        """

rule append_usvi:
    """Appending USVI sequences"""
    input:
        sequences = "data/sequences.fasta",
        metadata = "data/metadata_modified.tsv",
        usvi_sequences = "data/sequences_usvi.fasta",
        usvi_metadata = "data/metadata_usvi.tsv"
    output:
        sequences = "data/sequences_all.fasta",
        metadata = "data/metadata_all.tsv"
    shell:
        """
        cat {input.sequences} {input.usvi_sequences} > {output.sequences}

        csvtk concat -tl {input.metadata} {input.usvi_metadata} \
        | tsv-select -H -f accession --rest last \
        > {output.metadata}
        """