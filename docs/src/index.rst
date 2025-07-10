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
   :caption: Visualization & Interpretation
   :hidden:

   visualization/sharing
   visualization/interpretation
   visualization/narratives

.. toctree::
   :maxdepth: 1
   :titlesonly:
   :caption: Guides
   :hidden:

   guides/update-workflow
   guides/data-prep/index
   guides/workflow-config-file
   guides/customizing-visualization
   guides/run-analysis-on-terra

.. toctree::
   :maxdepth: 1
   :caption: Reference
   :hidden:

   reference/nextstrain-overview
   reference/files
   reference/workflow-config-file
   reference/remote_inputs
   reference/metadata-fields
   reference/naming_clades
   reference/data_submitter_faq
   reference/troubleshoot
   reference/change_log
   reference/glossary

.. toctree::
   :maxdepth: 1
   :titlesonly:
   :hidden:

   Stuck? Ask us on the discussion board. We're happy to help! <https://discussion.nextstrain.org/>
