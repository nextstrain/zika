"""
This part of the workflow collects the phylogenetic tree and annotations to
export a Nextstrain dataset.

REQUIRED INPUTS:

    metadata        = data/metadata_all.tsv
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
        tree = "results/{gene}/tree.nwk",
        metadata = "data/metadata_all.tsv",
        branch_lengths = "results/{gene}/branch_lengths.json",
        traits = "results/{gene}/traits.json",
        nt_muts = "results/{gene}/nt_muts.json",
        aa_muts = "results/{gene}/aa_muts.json",
        colors = "defaults/colors.tsv",
        auspice_config = "defaults/auspice_config.json",
        description = "defaults/description.md"
    output:
        auspice_json = "results/{gene}/raw_zika.json"
    params:
        strain_id = config.get("strain_id_field", "strain"),
    shell:
        """
        augur export v2 \
            --tree {input.tree} \
            --metadata {input.metadata} \
            --metadata-id-columns {params.strain_id} \
            --node-data {input.branch_lengths} {input.traits} {input.nt_muts} {input.aa_muts} \
            --colors {input.colors} \
            --auspice-config {input.auspice_config} \
            --description {input.description} \
            --include-root-sequence-inline \
            --output {output.auspice_json}
        """

rule final_strain_name:
    input:
        auspice_json="results/{gene}/raw_zika.json",
        metadata="data/metadata_all.tsv"
    output:
        auspice_json="auspice/zika_{gene}.json"
    params:
        strain_id=config["strain_id_field"],
        display_strain_field=config.get("display_strain_field", "strain"),
    shell:
        """
        python3 scripts/set_final_strain_name.py \
            --metadata {input.metadata} \
            --metadata-id-columns {params.strain_id} \
            --input-auspice-json {input.auspice_json} \
            --display-strain-name {params.display_strain_field} \
            --output {output.auspice_json}
        """
