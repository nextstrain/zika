*****************************************************************
Nextstrain's Zika pathogen analysis pipeline
*****************************************************************

This is the documentation for the Zika pathogen analysis which is behind `nextstrain.org/zika <https://nextstrain.org/zika>`_ and which can be used to run your own customised analyses.
Etc etc etc.


Our analysis of `nextstrain.org/zika <https://nextstrain.org/zika>`_ is achieved via two workflows:

1. :doc:`ingest <./ingest-workflow>` -- Download data from GenBank, clean and curate it to produce a metadata file and a sequences file
2. :doc:`phylogenetic <./phylo-workflow>` -- Filter sequences, align, construct phylogeny, and export for visualization


For a quickstart tutorial, including installation instructions, which will run through each of these workflows see here TKTK.

To see a full description of each of the workflows see the :doc:`ingest <./ingest-workflow>` and :doc:`phylogenetic <./phylo-workflow>` pages.

For a detailed list of all configuration options and docs see :doc:`config <./phylogenetic-config>`.


.. toctree::
    :maxdepth: 1
    :hidden:

    self


.. toctree::
    :maxdepth: 1
    :titlesonly:
    :caption: Tutorials
    :hidden:

    quickstart
    customise

.. toctree::
    :maxdepth: 1
    :titlesonly:
    :caption: Workflow details
    :hidden:

    ingest-workflow
    phylo-workflow



.. toctree::
    :maxdepth: 1
    :titlesonly:
    :caption: Customisation & configuration
    :hidden:

    phylogenetic-config
    shared-vendored-snakemake-config
    shared-vendored-inputs

