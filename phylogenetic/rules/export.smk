"""
This part of the workflow collects the phylogenetic tree and annotations to
export a Nextstrain dataset.

REQUIRED INPUTS:

    metadata        = results/metadata.tsv
    tree            = results/tree.nwk
    branch_lengths  = results/branch_lengths.json
    node_data       = results/*.json

OUTPUTS:

    auspice_json = auspice/${build_name}.json

    There are optional sidecar JSON files that can be exported as part of the dataset.
    See Nextstrain's data format docs for more details on sidecar files:
    https://docs.nextstrain.org/page/reference/data-formats.html

This part of the workflow usually includes the following steps:

    - augur export v2
    - augur frequencies

See Augur's usage docs for these commands for more details.
"""

rule export:
    """Exporting data files for for auspice"""
    input:
        tree = "results/tree.nwk",
        metadata = "results/metadata.tsv",
        branch_lengths = "results/branch_lengths.json",
        traits = "results/traits.json",
        nt_muts = "results/nt_muts.json",
        aa_muts = "results/aa_muts.json",
        colors = resolve_config_path(config["colors"]),
        auspice_config = resolve_config_path(config["auspice_config"]),
        description = resolve_config_path(config["description"]),
    output:
        auspice_json = "auspice/zika.json"
    params:
        strain_id = config.get("strain_id_field", "strain"),
    log:
        "logs/export.txt",
    benchmark:
        "benchmarks/export.txt"
    shell:
        r"""
        exec &> >(tee {log:q})

        augur export v2 \
            --tree {input.tree:q} \
            --metadata {input.metadata:q} \
            --metadata-id-columns {params.strain_id:q} \
            --node-data {input.branch_lengths:q} {input.traits:q} {input.nt_muts:q} {input.aa_muts:q} \
            --colors {input.colors:q} \
            --auspice-config {input.auspice_config:q} \
            --description {input.description:q} \
            --include-root-sequence-inline \
            --output {output.auspice_json:q}
        """
