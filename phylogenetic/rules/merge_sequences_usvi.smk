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
        | tsv-select -H -f accession --rest last \
        > {output.metadata}
        """