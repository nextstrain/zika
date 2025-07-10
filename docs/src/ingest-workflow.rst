*****************************************************************
Detailed overview of the ingest workflow
*****************************************************************

I'm not sure how much we can automate this... We could (of course) manually document the steps, but then it's on us to keep it up to date.


- Generate the Snakemake DAG and embed it here (via Graphviz).
- Write inline documentation in the Snakemake rules (e.g., docstrings), and write a custom Sphinx extension (similar to ``:configvalue:``) to parse the rules and walk through each rule here.
- 

---

Some example text:

We use NCBI Datasets to download the data filtering to taxon ID :configvalue:`ingest/defaults/config.yaml:ncbi_taxon_id` and fetch the following fiels:

:configvalue:`ingest/defaults/config.yaml:ncbi_datasets_fields`

