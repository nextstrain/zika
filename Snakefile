from pathlib import Path
from collections import Mapping

# XXX TODO: I expect similar logic will be desired in other pathogen builds, so
# this really belongs in a shared Python library which can be imported or in a
# shared Snakefile file which can be included.  For now it's here for
# demonstration purposes without even further scaffolding necessary.
#   -trs, 27 June 2018
def field_map(fields):
    """
    Normalize a list of fields which map input names to output names as a list
    of (input, output) tuples.  The original list items may be simple strings,
    in which case the input and output field names are the same, or a single
    key-value map which specify the individual names.  This exists to make the
    config.yaml entries more concise and readable.
    """
    def first_pair(mapping):
        return [ *mapping.items() ][0]

    return [
        first_pair(f) if isinstance(f, Mapping) else (f, f)
            for f in fields
    ]


# Config
configfile: "config.yaml"

if Path("config_local.yaml").is_file():
    configfile: "config_local.yaml"

build = Path(config.get("build_dir", "build"))

fasta_fields = field_map(config['fasta_fields'])


# Rules
rule all:
    input:
        auspice_tree = build / "auspice/zika_tree.json",
        auspice_meta = build / "auspice/zika_meta.json",

rule download:
    message: "Downloading sequences from fauna"
    output:
        build / "data/zika.fasta"
    params:
        fields = [ f[0] for f in fasta_fields ],

        rethink_host     = config["credentials"]["rethink"]["host"],
        rethink_auth_key = config["credentials"]["rethink"]["auth_key"],
    shell:
        """
        env PYTHONPATH=../fauna \
            RETHINK_HOST={params.rethink_host:q} \
            RETHINK_AUTH_KEY={params.rethink_auth_key:q} \
                python2 ../fauna/vdb/download.py \
                    --database vdb \
                    --virus zika \
                    --fasta_fields {params.fields:q} \
                    --resolve_method choose_genbank \
                    --path $(dirname {output:q}) \
                    --fstem $(basename {output:q} .fasta)
        """

rule parse:
    message: "Parsing sequences and metadata"
    input:
        rules.download.output,
    output:
        sequences = build / "results/sequences.fasta",
        metadata  = build / "results/metadata.tsv",
    params:
        fields = [ f[1] for f in fasta_fields ],
    shell:
        """
        augur parse \
            --sequences {input:q} \
            --fields {params.fields:q} \
            --output-sequences {output.sequences:q} \
            --output-metadata {output.metadata:q}
        """

rule filter:
    message:
        """
        Filtering to
          - {params.sequences_per_category} sequence(s) per {params.categories!s}
          - from {params.min_date} onwards
        """
    input:
        sequences = rules.parse.output.sequences,
        metadata  = rules.parse.output.metadata,
        exclude   = config['filter']['exclude'],
    output:
        build / "results/filtered.fasta"
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
    message: "Aligning sequences"
    input:
        sequences = rules.filter.output,
        reference = config['reference'],
    output:
        build / "results/aligned.fasta"
    shell:
        """
        augur align \
            --sequences {input.sequences:q} \
            --reference-sequence {input.reference:q} \
            --fill-gaps \
            --output {output:q}
        """

rule tree:
    message: "Building tree"
    input:
        alignment = rules.align.output,
    output:
        tree = build / "results/tree_raw.nwk"
    shell:
        """
        augur tree \
            --alignment {input.alignment:q} \
            --output {output.tree:q}
        """

rule timetree:
    message: "Building timetree (filtering nodes with IQD > {params.n_iqd})"
    input:
        tree      = rules.tree.output.tree,
        alignment = rules.align.output,
        metadata  = rules.parse.output.metadata,
    output:
        tree      = build / "results/tree.nwk",
        node_data = build / "results/node_data.json",
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
    message: "Inferring ancestral traits {params.columns!s}"
    input:
        tree     = rules.timetree.output.tree,
        metadata = rules.parse.output.metadata,
    output:
        build / "results/traits.json",
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
    message: "Identifying amino acid changes"
    input:
        tree      = rules.timetree.output.tree,
        node_data = rules.timetree.output.node_data,
        reference = config['reference'],
    output:
        build / "results/aa_muts.json"
    shell:
        """
        augur translate \
            --tree {input.tree:q} \
            --node-data {input.node_data:q} \
            --reference-sequence {input.reference:q} \
            --output {output:q}
        """

rule export:
    message: "Exporting data files for for auspice"
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

rule clean:
    message: "Removing directories: {params}"
    params:
        build / "data",
        build / "results",
        build / "auspice",
    shell:
        "rm -rfv {params:q}"
