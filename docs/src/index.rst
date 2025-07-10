*****************************************************************
Nextstrain's Zika pathogen analysis pipeline
*****************************************************************

This is the documentation for the Zika pathogen analysis which is behind `nextstrain.org/zika <https://nextstrain.org/zika>`_ and which can be used to run your own customised analyses.
Etc etc etc.


Our analysis of `nextstrain.org/zika <https://nextstrain.org/zika>`_ is achieved via two workflows:

1. :doc:`ingest <./TKTK>` -- Download data from GenBank, clean and curate it to produce a metadata file and a sequences file
2. :doc:`phylogenetic <./TKTK>` -- Filter sequences, align, construct phylogeny, and export for visualization


For a quickstart tutorial, including installation instructions, which will run through each of these workflows see here TKTK.

To see a full description of each of the workflows see the :doc:`ingest <./TKTK>` and :doc:`phylogenetic <./TKTK>` pages.

For a detailed list of all configuration options and docs see :doc:`config/TKTK`.


.. toctree::
    :maxdepth: 1
    :titlesonly:
    :caption: Tutorials
    :hidden:

    tutorial

.. toctree::
    :maxdepth: 1
    :titlesonly:
    :caption: Detailed workflow descriptions
    :hidden:

    ingest-workflow
    phylogenetic-workflow

.. toctree::
    :maxdepth: 1
    :titlesonly:
    :caption: Customisation
    :hidden:

    phylogenetic-config


.. toctree::
   :maxdepth: 1
   :titlesonly:
   :hidden:

   Stuck? Ask us on the discussion board. We're happy to help! <https://discussion.nextstrain.org/>
