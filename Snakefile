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
       config["input_fasta"]
    output:
       sequences = "results/sequences.fasta",
       metadata = "results/metadata.tsv"
    params:
        fasta_fields = config["fasta_fields"]
    shell:
        'augur parse --sequences {input} --output-sequences {output.sequences} --output-metadata {output.metadata} '
            '--fields {params.fasta_fields}'

rule filter:
    input:
        sequences = rules.parse.output.sequences,
        metadata = rules.parse.output.metadata,
        exclude = config["filter"]["exclude"]
    output:
        "results/filtered.fasta"
    params:
        sequences_per_category = config['filter']['sequences_per_category'],
        categories             = config['filter']['category_fields'],
        min_date               = config['filter']['min_date'],
    shell:
        'augur filter --sequences {input.sequences} --output {output} --metadata {input.metadata} '
            '--sequences-per-category {params.sequences_per_category} '
            '--exclude {input.exclude} --categories {params.categories} --min-date {params.min_date}'

rule align:
    input:
        sequences = rules.filter.output,
        ref = config["reference"]
    output:
        "results/aligned.fasta"
    shell:
        'augur align --sequences {input.sequences} --output {output} '
         '--reference-sequence {input.ref}  --fill-gaps'

rule tree:
    input:
        alignment = rules.align.output
    output:
        tree = "results/tree_raw.nwk",
    shell:
        'augur tree --alignment {input.alignment} --output {output.tree}'

rule timetree:
    input:
        alignment = rules.align.output,
        metadata = rules.parse.output.metadata,
        tree = rules.tree.output.tree,
    output:
        node_data = "results/node_data.json",
        tree = "results/tree.nwk",
    params:
        n_iqd = config['timetree']['n_iqd'],
    shell:
        'augur treetime --tree {input.tree} --alignment {input.alignment} '
            '--metadata {input.metadata}'
            ' --output {output.tree} --node-data {output.node_data}'
            ' --timetree --date-confidence --time-marginal --coalescent opt'
            ' --n-iqd {params.n_iqd}'

rule traits:
    input:
        tree = rules.timetree.output.tree,
        metadata = rules.parse.output.metadata
    output:
        "results/traits.json",
    params:
        columns = config['traits'],
    shell:
        'augur traits --confidence --tree {input.tree} --metadata {input.metadata} --output {output} --columns {params.columns}'

rule translate:
    input:
        tree = rules.timetree.output.tree,
        ref = config["reference"],
        node_data = rules.timetree.output.node_data,
    output:
        "results/aa_muts.json"
    shell:
        'augur translate --tree {input.tree} --node-data {input.node_data} --output {output} --reference-sequence {input.ref}'

rule export:
    input:
        tree = rules.timetree.output.tree,
        node_data = rules.timetree.output.node_data,
        metadata = rules.parse.output.metadata,
        traits = rules.traits.output,
        aa_muts = rules.translate.output,
        colors = config["auspice"]["colors"],
        auspice_config = config["auspice"]["auspice_config"]
    output:
        auspice_tree = rules.all.input.auspice_tree,
        auspice_meta = rules.all.input.auspice_meta
    shell:
        'augur export --tree {input.tree} --metadata {input.metadata}'
            ' --node-data {input.node_data} {input.traits} {input.aa_muts}' # node decorations for the tree JSON
            ' --colors {input.colors} --auspice-config {input.auspice_config}' #for the meta JSON
            ' --output-tree {output.auspice_tree} --output-meta {output.auspice_meta}'
