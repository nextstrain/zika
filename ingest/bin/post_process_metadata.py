#! /usr/bin/env python3

import argparse
import json
from sys import stdin, stdout

import re

def parse_args():
    parser = argparse.ArgumentParser(
        description="Reformat a NCBI Virus metadata.tsv file for a pathogen build."
    )
    parser.add_argument("--accession-field", default='accession',
        help="Field from the records to use as the sequence ID in the FASTA file.")

    return parser.parse_args()


def _set_strain_name(record):
    """Replace spaces, dashes, and periods with underscores in strain name."""
    strain_name = record["strain"]
    
    strain_name = strain_name.replace('Zika_virus', '').replace('Zikavirus', '').replace('Zika virus', '').replace('Zika', '').replace('ZIKV', '')
    strain_name = strain_name.replace('Human', '').replace('human', '').replace('H.sapiens_wt', '').replace('H.sapiens-wt', '').replace('H.sapiens_tc', '').replace('Hsapiens_tc', '').replace('H.sapiens-tc', '').replace('Homo_sapiens', '').replace('Homo sapiens', '').replace('Hsapiens', '').replace('H.sapiens', '')
    strain_name = strain_name.replace('/Hu/', '')
    strain_name = strain_name.replace('_Asian', '').replace('_Asia', '').replace('_asian', '').replace('_asia', '')
    strain_name = strain_name.replace('_URI', '').replace('-URI', '').replace('_SER', '').replace('-SER', '').replace('_PLA', '').replace('-PLA', '').replace('_MOS', '').replace('_SAL', '')
    strain_name = strain_name.replace('Aaegypti_wt', 'Aedes_aegypti').replace('Aedessp', 'Aedes_sp')
    strain_name = strain_name.replace(' ', '').replace('\'', '').replace('(', '').replace(')', '').replace('//', '/').replace('__', '_').replace('.', '').replace(',', '')
    strain_name = re.sub('^[\/\_\-]', '', strain_name)

    try:
        strain_name = 'V' + str(int(strain_name))
    except ValueError:
        pass

    return (
        strain_name.replace(" ", "_")
        .replace("-", "_")
        .replace(".", "_")
        .replace("(", "_")
        .replace(")", "_")
    )


def main():
    args = parse_args()

    for index, record in enumerate(stdin):
        record = json.loads(record)
        record["strain"] = _set_strain_name(record)
        record["authors"] = record["abbr_authors"]
        stdout.write(json.dumps(record) + "\n")


if __name__ == "__main__":
    main()