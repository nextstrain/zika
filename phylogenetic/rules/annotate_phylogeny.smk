"""
This part of the workflow creates additonal annotations for the phylogenetic tree.

REQUIRED INPUTS:

    metadata            = data/metadata_all.tsv
    prepared_sequences  = results/aligned.fasta
    tree                = results/tree.nwk

OUTPUTS:

    node_data = results/*.json

    There are no required outputs for this part of the workflow as it depends
    on which annotations are created. All outputs are expected to be node data
    JSON files that can be fed into `augur export`.

    See Nextstrain's data format docs for more details on node data JSONs:
    https://docs.nextstrain.org/page/reference/data-formats.html

This part of the workflow usually includes the following steps:

    - augur traits
    - augur ancestral
    - augur translate
    - augur clades

See Augur's usage docs for these commands for more details.

Custom node data files can also be produced by build-specific scripts in addition
to the ones produced by Augur commands.
"""
from collections.abc import Iterable

rule ancestral:
    """Reconstructing ancestral sequences and mutations"""
    input:
        tree = "results/tree.nwk",
        alignment = "results/aligned.fasta"
    output:
        node_data = "results/nt_muts.json"
    params:
        inference = config["ancestral"]["inference"]
    log:
        "logs/ancestral.txt",
    benchmark:
        "benchmarks/ancestral.txt"
    shell:
        r"""
        exec &> >(tee {log:q})

        augur ancestral \
            --tree {input.tree:q} \
            --alignment {input.alignment:q} \
            --output-node-data {output.node_data:q} \
            --inference {params.inference:q}
        """

rule translate:
    """Translating amino acid sequences"""
    input:
        tree = "results/tree.nwk",
        node_data = "results/nt_muts.json",
        reference = resolve_config_path(config["reference"]),
    output:
        node_data = "results/aa_muts.json"
    log:
        "logs/translate.txt",
    benchmark:
        "benchmarks/translate.txt"
    shell:
        r"""
        exec &> >(tee {log:q})

        augur translate \
            --tree {input.tree:q} \
            --ancestral-sequences {input.node_data:q} \
            --reference-sequence {input.reference:q} \
            --output {output.node_data:q}
        """

def conditional(option_str, argument):
    """Used for config-defined arguments whose presence necessitates a command-line option
    (e.g. --foo) prepended and whose absense should result in no option/arguments in the CLI command.
    """
    if not argument:
        return ""
    if isinstance(argument, Iterable) and not isinstance(argument, str):
        return [option_str, *argument]
    else:
        return [option_str, argument]

rule traits:
    """
    Inferring ancestral traits for {params.columns!s}
      - increase uncertainty of reconstruction by {params.sampling_bias_correction} to partially account for sampling bias
    """
    input:
        tree = "results/tree.nwk",
        metadata = input_metadata,
    output:
        node_data = "results/traits.json",
    params:
        columns = as_list(config["traits"]["columns"]),
        sampling_bias_correction = config["traits"]["sampling_bias_correction"],
        strain_id = config.get("strain_id_field", "strain"),
        branch_labels = conditional('--branch-labels', config['traits'].get('branch_labels', False)),
        branch_confidence = conditional('--branch-confidence', config['traits'].get('branch_confidence', False)),
    log:
        "logs/traits.txt",
    benchmark:
        "benchmarks/traits.txt"
    shell:
        r"""
        exec &> >(tee {log:q})

        augur traits \
            --tree {input.tree:q} \
            --metadata {input.metadata:q} \
            --metadata-id-columns {params.strain_id:q} \
            --output {output.node_data:q} \
            --columns {params.columns:q} \
            --confidence \
            {params.branch_labels:q} \
            {params.branch_confidence:q} \
            --sampling-bias-correction {params.sampling_bias_correction:q}
        """
