*****************************************************************
Phylogenetic configuration
*****************************************************************

General idea would be to somehow document all of the config values available to the workflow, and do so in a way that won't fall out of sync with the code.

In avian-flu `I prototyped <https://github.com/nextstrain/avian-flu/pull/107>`_ implementing a full schema (not easy!) and then automatically generating HTML from it. It wasn't pretty, and would be a lot of work I think.

An easier solution would be to document the config options here (in the rst file), use the custom ``:configvalue:`` role (or similar) to show the default values, and have some custom sphinx built-time code to check that all values in the config are documented.

