*****************************************************************
Customisation of workflow
*****************************************************************

.. note::
   Text mostly lifted from Avian flu docs for expediency



The aim is to allow easy customisation of the workflow via config overlays. This includes defining the data inputs, modification of parameters (e.g. clock rates, minimum lengths, subsampling criteria, DTA metadata) is possible through overlays without needing to modify the underlying base config or Snakemake pipeline itself.

Config overlays allow you to essentially maintain one or more modifications of the workflow for your own purposes. Using an overlay keeps this change separate from the config used for Nextstrain automation


We'll start by creating a config (overlay) YAML, ``config.yaml`` in our analysis directory

.. note::
    You can choose a different name for the file, but if you do you'll have to supply it to the command via --configfile <filename> as only config.yaml will be automatically detected.

