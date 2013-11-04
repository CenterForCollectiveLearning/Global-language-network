#!/usr/bin/python
# -*- coding: utf-8 -*-

### gln/analysis/paper-2013-10/si-table7-lang-by-country/pretty_country_lang_demog.py

"""
Output a tab-delimited containing for each country the languages 
spoken in it and their shares, to use in the SM.
Use the JSON language demographics file and the three-letter code
to full language name conversion.

# NOTE: may want to sort output table in e.g., Excel


"""

import os, sys, codecs
import simplejson
import csv
from collections import defaultdict
import operator # for dict sorting
 
COUNTRY_TO_LANGS_CONVERSION_FILE = "../../../data/lang_tools/country_to_lang/country_to_lang_mapping.json"
LANG_NAMES_CONVERSION_FILE = \
    "../../../data/lang_tools/lang_conversion/gold/iso-639-3-20120726_conversion_nogeneric.txt"
OUTFILE = "si-table7-lang-by-country.tsv"

def load_conversion_table(filename):
    fin = codecs.open(filename, "rU")
    dr = csv.DictReader(fin, delimiter="\t")
    lang_name_dict = defaultdict(float)
    for row in dr:
        lang_name_dict[row['Final_Code']] = row['Final_Name']
    return lang_name_dict


def write_country_to_lang(infile, outfile, convfile):
    # Load the original country-to-lang JSON file as a dictionary
    country_to_langs = simplejson.load(open(infile, "rU"))

    # Load the lang code to lang name conversion table
    lang_name_conv = load_conversion_table(convfile)

    # open output file
    fout = codecs.open(outfile, "w")
    fout.write("Coutnry\tLanguages\n")

    for cnt_code, vals in country_to_langs.iteritems():
        #init a string with coutnry name
        cnt_line_text = "{0}\t".format(vals['name'])

        # sort langs by share
        sorted_vals = sorted(vals['langs'].iteritems(), 
            key=operator.itemgetter(1), reverse=True)

        # add the language distribution to the string
        lang_shares = []
        for lang_code,lang_share in sorted_vals:
            lang_shares.append("{0} {1}%".format(lang_name_conv[lang_code], str(lang_share)))
        cnt_line_text += ", ".join(lang_shares)

        # write country info to file
        print cnt_line_text
        fout.write(cnt_line_text + "\n")

    fout.close()

if __name__ == '__main__':
    # Convert countries to languages:
    write_country_to_lang(COUNTRY_TO_LANGS_CONVERSION_FILE,
        OUTFILE, LANG_NAMES_CONVERSION_FILE)