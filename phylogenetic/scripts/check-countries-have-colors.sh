#!/usr/bin/env bash

countries=();
while IFS="" read -r line; do
  countries+=( "$line" );
done < <( grep '>' data/zika.fasta | cut -d'|' -f 6 | sort | uniq );

for i in "${countries[@]}"; do
  j=${i//_/ }
  ( grep -q "$j" config/colors.tsv  || echo "No colour for \"$j\"" );
done