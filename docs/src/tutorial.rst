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

Input data was downloaded from :configvalue:`phylogenetic/defaults/config.yaml:inputs[0].metadata` and :configvalue:`phylogenetic/defaults/config.yaml:inputs[0].sequences`.

We then ...

To see how you can customise this analysis see the :doc:`config/TKTK` page.



