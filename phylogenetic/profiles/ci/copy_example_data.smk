rule copy_example_data:
    input:
        sequences="example_data/sequences.fasta",
        metadata="example_data/metadata.tsv",
        usvi_sequences="example_data/sequences_usvi.fasta",
        usvi_metadata="example_data/metadata_usvi.tsv",
    output:
        sequences="data/sequences.fasta",
        metadata="data/metadata.tsv",
        usvi_sequences="data/sequences_usvi.fasta",
        usvi_metadata="data/metadata_usvi.tsv",
    shell:
        """
        cp -f {input.sequences} {output.sequences}
        cp -f {input.metadata} {output.metadata}
        cp -f {input.usvi_sequences} {output.usvi_sequences}
        cp -f {input.usvi_metadata} {output.usvi_metadata}
        """

ruleorder: copy_example_data > decompress
ruleorder: copy_example_data > decompress_usvi