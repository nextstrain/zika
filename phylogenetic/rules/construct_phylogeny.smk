"""
This part of the workflow constructs the phylogenetic tree.

REQUIRED INPUTS:

    metadata            = results/metadata.tsv
    prepared_sequences  = results/aligned.fasta

OUTPUTS:

    tree            = results/tree.nwk
    branch_lengths  = results/branch_lengths.json

This part of the workflow usually includes the following steps:

    - augur tree
    - augur refine

See Augur's usage docs for these commands for more details.
"""

rule tree:
    """Building tree"""
    input:
        alignment = "results/aligned.fasta"
    output:
        tree = "results/tree_raw.nwk"
    log:
        "logs/tree.txt",
    benchmark:
        "benchmarks/tree.txt"
    threads: 8
    shell:
        r"""
        exec &> >(tee {log:q})

        augur tree \
            --nthreads {threads} \
            --alignment {input.alignment:q} \
            --output {output.tree:q}
        """

rule refine:
    """
    Refining tree
      - estimate timetree
      - use {params.coalescent} coalescent timescale
      - estimate {params.date_inference} node dates
      - filter tips more than {params.clock_filter_iqd} IQDs from clock expectation
    """
    input:
        tree = "results/tree_raw.nwk",
        alignment = "results/aligned.fasta",
        metadata = "results/metadata.tsv",
    output:
        tree = "results/tree.nwk",
        node_data = "results/branch_lengths.json"
    params:
        coalescent = config["refine"]["coalescent"],
        date_inference = config["refine"]["date_inference"],
        clock_filter_iqd = config["refine"]["clock_filter_iqd"],
        strain_id = config.get("strain_id_field", "strain"),
    log:
        "logs/refine.txt",
    benchmark:
        "benchmarks/refine.txt"
    shell:
        r"""
        exec &> >(tee {log:q})

        augur refine \
            --tree {input.tree:q} \
            --alignment {input.alignment:q} \
            --metadata {input.metadata:q} \
            --metadata-id-columns {params.strain_id:q} \
            --output-tree {output.tree:q} \
            --output-node-data {output.node_data:q} \
            --timetree \
            --coalescent {params.coalescent:q} \
            --date-confidence \
            --date-inference {params.date_inference:q} \
            --clock-filter-iqd {params.clock_filter_iqd:q}
        """
