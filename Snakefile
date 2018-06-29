from pathlib import Path


# Config
configfile: "config.yaml"

if Path("config_local.yaml").is_file():
    configfile: "config_local.yaml"


# Rules
rule all:
    input:
        auspice_tree = "auspice/zika_tree.json",
        auspice_meta = "auspice/zika_meta.json"

rule parse:
    input:
        config["input_fasta"],
    output:
        sequences = "results/sequences.fasta",
        metadata  = "results/metadata.tsv",
    params:
        fasta_fields = config["fasta_fields"],
    shell:
        """
        augur parse \
            --sequences {input:q} \
            --fields {params.fields:q} \
            --output-sequences {output.sequences:q} \
            --output-metadata {output.metadata:q}
        """

rule filter:
    input:
        sequences = rules.parse.output.sequences,
        metadata  = rules.parse.output.metadata,
        exclude   = config['filter']['exclude'],
    output:
        "results/filtered.fasta"
    params:
        sequences_per_category = config['filter']['sequences_per_category'],
        categories             = config['filter']['category_fields'],
        min_date               = config['filter']['min_date'],
    shell:
        """
        augur filter \
            --sequences {input.sequences:q} \
            --metadata {input.metadata:q} \
            --exclude {input.exclude:q} \
            --sequences-per-category {params.sequences_per_category:q} \
            --categories {params.categories:q} \
            --min-date {params.min_date:q} \
            --output {output:q}
        """

rule align:
    input:
        sequences = rules.filter.output,
        reference = config['reference'],
    output:
        "results/aligned.fasta"
    shell:
        """
        augur align \
            --sequences {input.sequences:q} \
            --reference-sequence {input.reference:q} \
            --fill-gaps \
            --output {output:q}
        """

rule tree:
    input:
        alignment = rules.align.output,
    output:
        tree = "results/tree_raw.nwk",
    shell:
        """
        augur tree \
            --alignment {input.alignment:q} \
            --output {output.tree:q}
        """

rule timetree:
    input:
        tree      = rules.tree.output.tree,
        alignment = rules.align.output,
        metadata  = rules.parse.output.metadata,
    output:
        tree      = "results/tree.nwk",
        node_data = "results/node_data.json",
    params:
        n_iqd = config['timetree']['n_iqd'],
    shell:
        """
        augur treetime \
            --tree {input.tree:q} \
            --alignment {input.alignment:q} \
            --metadata {input.metadata:q} \
            --timetree \
            --date-confidence \
            --time-marginal \
            --coalescent opt \
            --n-iqd {params.n_iqd:q} \
            --output {output.tree:q} \
            --node-data {output.node_data:q}
        """

rule traits:
    input:
        tree     = rules.timetree.output.tree,
        metadata = rules.parse.output.metadata,
    output:
        "results/traits.json",
    params:
        columns = config['traits'],
    shell:
        """
        augur traits \
            --confidence \
            --tree {input.tree:q} \
            --metadata {input.metadata:q} \
            --columns {params.columns:q} \
            --output {output:q}
        """

rule translate:
    input:
        tree      = rules.timetree.output.tree,
        node_data = rules.timetree.output.node_data,
        reference = config['reference'],
    output:
        "results/aa_muts.json"
    shell:
        """
        augur translate \
            --tree {input.tree:q} \
            --node-data {input.node_data:q} \
            --reference-sequence {input.reference:q} \
            --output {output:q}
        """

rule export:
    input:
        tree      = rules.timetree.output.tree,
        node_data = rules.timetree.output.node_data,
        metadata  = rules.parse.output.metadata,
        traits    = rules.traits.output,
        aa_muts   = rules.translate.output,

        colors    = config['auspice']['colors'],
        config    = config['auspice']['config'],
    output:
        auspice_tree = rules.all.input.auspice_tree,
        auspice_meta = rules.all.input.auspice_meta,
    shell:
        """
        augur export \
            --tree {input.tree:q} \
            --metadata {input.metadata:q} \
            --node-data {input.node_data:q} {input.traits:q} {input.aa_muts:q} \
            --colors {input.colors:q} \
            --auspice-config {input.config:q} \
            --output-tree {output.auspice_tree:q} \
            --output-meta {output.auspice_meta:q}
        """
