*****************************************************************
Simple walkthrough of the Zika pathogen analysis pipeline
*****************************************************************

Prerequisites
=============

Follow the `standard installation instructions <https://docs.nextstrain.org/en/latest/install.html>`_ for Nextstrain's suite of software tools.

Install the zika pathogen repo:

.. code-block:: bash

   nextstrain setup zika
   nextstrain update zika # run this periodically

Run the phylo pipeline
======================

We assume that you have created an analysis directory somewhere where input files will be stored, intermediate files created and final outputs saved.
Furthermore, we assume that you are in this directory and that it is empty.


.. code-block:: bash

   nextstrain run --docker zika phylogenetic .


What just happened?
-------------------

Input data was downloaded from :configvalue:`phylogenetic/defaults/config.yaml:inputs[0].metadata` and :configvalue:`phylogenetic/defaults/config.yaml:inputs[0].sequences` (these files were produced by the ingest pipeline, BTW).

We then ran through a number of analysis steps, for full details see the :doc:`phylo-workflow` page.

To see how you can customise this analysis, by using your own data or changing some of the analysis parameters, see the :doc:`customise` page.

View the results
======================

Either ``nextstrain view ???`` or take the produced files and drag and drop em on to auspice.us











