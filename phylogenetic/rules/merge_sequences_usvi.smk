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
    """Appending USVI sequences

    Notable columns:
    - accession: Either the GenBank accession or USVI accession.
    - genbank_accession: GenBank accession for Auspice to generate a URL to the NCBI GenBank record. Empty for USVI sequences.
    - url: URL used in Auspice, to either link to the USVI github repo (https://github.com/blab/zika-usvi/) or link to the NCBI GenBank record ('https://www.ncbi.nlm.nih.gov/nuccore/*')
    """
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