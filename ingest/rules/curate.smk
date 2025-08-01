"""
This part of the workflow handles curating the data into standardized
formats and expects input file

    sequences_ndjson = "data/ncbi.ndjson"

This will produce output files as

    metadata = "results/metadata.tsv"
    sequences = "results/sequences.fasta"

Parameters are expected to be defined in `config.curate`.
"""


def format_field_map(field_map: dict[str, str]) -> list[str]:
    """
    Format entries to the format expected by `augur curate --field-map`.
    When used in a Snakemake shell block, the list is automatically expanded and
    spaces are handled by quoted interpolation.
    """
    return [f'{key}={value}' for key, value in field_map.items()]


rule curate:
    input:
        sequences_ndjson="data/ncbi.ndjson",
        geolocation_rules=resolve_config_path(config["curate"]["local_geolocation_rules"]),
        annotations=resolve_config_path(config["curate"]["annotations"]),
    output:
        metadata="data/all_metadata.tsv",
        sequences="results/sequences.fasta",
    params:
        field_map=format_field_map(config["curate"]["field_map"]),
        strain_regex=config["curate"]["strain_regex"],
        strain_backup_fields=config["curate"]["strain_backup_fields"],
        date_fields=config["curate"]["date_fields"],
        expected_date_formats=config["curate"]["expected_date_formats"],
        genbank_location_field=config["curate"]["genbank_location_field"],
        articles=config["curate"]["titlecase"]["articles"],
        abbreviations=config["curate"]["titlecase"]["abbreviations"],
        titlecase_fields=config["curate"]["titlecase"]["fields"],
        authors_field=config["curate"]["authors_field"],
        authors_default_value=config["curate"]["authors_default_value"],
        annotations_id=config["curate"]["annotations_id"],
        id_field=config["curate"]["output_id_field"],
        sequence_field=config["curate"]["output_sequence_field"],
    benchmark:
        "benchmarks/curate.txt"
    log:
        "logs/curate.txt"
    shell:
        r"""
        exec &> >(tee {log:q})

        cat {input.sequences_ndjson:q} \
            | augur curate rename \
                --field-map {params.field_map:q} \
            | augur curate normalize-strings \
            | augur curate transform-strain-name \
                --strain-regex {params.strain_regex:q} \
                --backup-fields {params.strain_backup_fields:q} \
            | augur curate format-dates \
                --date-fields {params.date_fields:q} \
                --expected-date-formats {params.expected_date_formats:q} \
            | augur curate parse-genbank-location \
                --location-field {params.genbank_location_field:q} \
            | augur curate titlecase \
                --titlecase-fields {params.titlecase_fields:q} \
                --articles {params.articles:q} \
                --abbreviations {params.abbreviations:q} \
            | augur curate abbreviate-authors \
                --authors-field {params.authors_field:q} \
                --default-value {params.authors_default_value:q} \
            | augur curate apply-geolocation-rules \
                --geolocation-rules {input.geolocation_rules:q} \
            | {workflow.basedir}/scripts/fix-zika-strain-names.py \
            | augur curate apply-record-annotations \
                --annotations {input.annotations:q} \
                --id-field {params.annotations_id:q} \
                --output-metadata {output.metadata:q} \
                --output-fasta {output.sequences:q} \
                --output-id-field {params.id_field:q} \
                --output-seq-field {params.sequence_field:q}
        """


rule add_metadata_columns:
    """Add columns to metadata
    Notable columns:
    - [NEW] url: URL linking to the NCBI GenBank record ('https://www.ncbi.nlm.nih.gov/nuccore/*').
    """
    input:
        metadata = "data/all_metadata.tsv"
    output:
        metadata = temp("data/all_metadata_added.tsv")
    params:
        accession=config['curate']['genbank_accession']
    benchmark:
        "benchmarks/add_metadata_columns.txt"
    log:
        "logs/add_metadata_columns.txt"
    shell:
        r"""
        exec &> >(tee {log:q})

        csvtk mutate2 -t \
          -n url \
          -e '"https://www.ncbi.nlm.nih.gov/nuccore/" + ${params.accession:q}' \
          {input.metadata:q} \
        > {output.metadata:q}
        """


rule subset_metadata:
    input:
        metadata="data/all_metadata_added.tsv",
    output:
        subset_metadata="results/metadata.tsv",
    params:
        metadata_fields=",".join(config["curate"]["metadata_columns"]),
    benchmark:
        "benchmarks/subset_metadata.txt"
    log:
        "logs/subset_metadata.txt"
    shell:
        r"""
        exec &> >(tee {log:q})

        csvtk cut -t -f {params.metadata_fields:q} \
            {input.metadata:q} > {output.subset_metadata:q}
        """
