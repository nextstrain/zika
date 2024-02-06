# Zika Data

The primary source of data for this build is GenBank. However, there are instances where certain records, crucial for phylogenetic analysis, are not yet present in GenBank. This is particularly true for some USVI records, as detailed in a previous analysis documented at https://github.com/blab/zika-usvi/.

### Integration of USVI data

This Zika build incorporates data from https://github.com/blab/zika-usvi/. The sequences and metadata for USVI from that GitHub repository have undergone curation and were uploaded to https://github.com/nextstrain/fauna. Subsequently, they were downloaded as sequences and metadata, and a filter was applied to include only those records not yet submitted to NCBI GenBank. The resulting records are now available as a pair of metadata and sequences files in this directory.

The process of merging the USVI data into the GenBank dataset is facilitated through the `append_usvi` rule.

Steps to create the `metadata_usvi.tsv` and `sequences_usvi.fasta` files were as follows:

1. Sequences were uploaded to the fauna database following [these instructions](https://github.com/nextstrain/fauna/blob/f9e7955cb4381d5e881c337e005778ed43b7c56c/builds/ZIKA.md#fred-hutch-sequences).
2. Sequences were downloaded from the fauna database following [these instructions](https://github.com/nextstrain/fauna/blob/5d5a1f3faf06805a5f31e91df2c76b06e6f3bf6a/builds/ZIKA.md#download-from-fauna-parse-compress-and-push-to-s3) and saved as `zika.fasta`
3. Sequences were ingested from GenBank following [these instructions](../README.md) and saved as `sequences.fasta`
4. [NCBI Blastn](https://www.ncbi.nlm.nih.gov/books/NBK279690/) was used to identify fauna sequences that were not one hundred percent identical to GenBank sequences using the following commnads:


```bash
GENBANK_SEQUENCES=sequences.fasta
FAUNA_SEQUENCES=zika.fasta

# Create a local blast database
makeblastdb \
  -in ${GENBANK_SEQUENCES} \  
  -dbtype nucl

# Blast fauna against GenBank
blastn \
  -db ${GENBANK_SEQUENCES} \
  -query ${FAUNA_SEQUENCES} \
  -num_alignments 1 \
  -outfmt 6 \
  -out blast_output.txt

# USVI strains that
# + match at 100%
# + match at least a 5000nt region (to filter out short substring matches)
cat blast_output.txt \
| awk -F'\t' '$1~"USVI" && $3>=100 && $4>5000 , OFS="\t" {print $1}' \
> USVI_100_match.txt

less USVI_100_match.txt
# USVI/5/2016|zika|MW165881|2016-10-17|north_america|usvi|saint_thomas|saint_thomas|genbank|genome|Santiago
# USVI/43/2016|zika|MW165884|2016-07-19|north_america|usvi|saint_thomas|saint_thomas|genbank|genome|Santiago
# USVI/4/2016|zika|MW165880|2016-10-14|north_america|usvi|saint_thomas|saint_thomas|genbank|genome|Santiago
# USVI/35/2016|zika|MW165883|2016-09-08|north_america|usvi|saint_thomas|saint_thomas|genbank|genome|Santiago
# USVI/25/2016|zika|MW165882|2016-09-27|north_america|usvi|saint_thomas|saint_thomas|genbank|genome|Santiago

# USVI strains that are not in the 100 match list
cat blast_output.txt \
| awk -F'\t' '$1~"USVI" , OFS="\t" {print}' \
| grep -Fvf USVI_100_match.txt \
| awk -F'\t' '{print $1}' \
| sort \
| uniq \
> USVI_not_match.txt

head USVI_not_match.txt
# USVI/1/2016|zika|VI1_1d|2016-09-28|north_america|usvi|saint_croix|saint_croix|fh|genome|Black
# USVI/11/2016|zika|VI11|2016-03-22|north_america|usvi|saint_thomas|saint_thomas|fh|genome|Black
# USVI/12/2016|zika|VI12|2016-11-04|north_america|usvi|saint_croix|saint_croix|fh|genome|Black
# USVI/13/2016|zika|VI13|2016-08-13|north_america|usvi|saint_thomas|saint_thomas|fh|genome|Black
# USVI/19/2016|zika|VI19_12plex|2016-11-21|north_america|usvi|saint_croix|saint_croix|fh|genome|Black
# ...
```

5. Pull out the corresponding `metadata_usvi.tsv` and `sequences_usvi.fasta` using a combination of [smof](https://github.com/incertae-sedis/smof) and [augur parse](https://docs.nextstrain.org/projects/augur/en/stable/usage/cli/parse.html)

```bash
# Pulls out sequences based on a match against header strings
smof grep -f USVI_not_match.txt zika.fasta > usvi.fasta

# Splits file into metadata_usvi.tsv and sequences_usvi.fasta
augur parse \
  --sequences usvi.fasta \
  --output-sequences sequences_usvi.fasta \
  --output-metadata raw_metadata_usvi.tsv \
  --fields strain virus accession date region country division location institution segment authors url title journal paper_url \
  --prettify-fields region country division location

augur parse \
  --sequences usvi.fasta \
  --output-sequences sequences_usvi.fasta \
  --output-metadata no.tsv \
  --fields a b strain c d e f g h i j k l m n

# Add sequence lengths to metadata
echo "accession|length" | tr '|' '\t' > lengths_usvi.tsv
smof stat --length --byseq sequences_usvi.fasta >> lengths_usvi.tsv

tsv-join -H \
  --filter-file lengths_usvi.tsv\
  --key-fields accession \
  --append-fields length \
  raw_metadata_usvi.tsv \
  | tsv-select -H \
  --fields accession,strain,date,region,country,division,location,length,authors,institution,url \
  > metadata_usvi.tsv
```

