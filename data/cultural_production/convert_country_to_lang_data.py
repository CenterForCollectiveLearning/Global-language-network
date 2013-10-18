#!/usr/bin/python
# -*- coding: utf-8 -*-

### gln/data/cultural_production/generate_cultural_exports.py

"""
Convert per-country data to per-language data (cultural exports, etc.)
Usage: python convert_country_data_to_lang infile outfiley

Uses the conversion table in ../lang_tools/country_to_lang/,
which lists for each country (2-letter code) its languages (by 3-letter code)
their shares
"""

import os
import sys
import simplejson
import codecs
from collections import Counter
import operator # for dict sorting
# sys.path.append('../lang_tools/country_to_lang')

# 
COUNTRY_TO_LANGS_CONVERSION_FILE = "../../data/lang_tools/country_to_lang/country_to_lang_mapping.json"
COUNTRY_TO_LANGS = \
    simplejson.load(open(COUNTRY_TO_LANGS_CONVERSION_FILE, "rU"))


# Convert # of illustrious people
WIKI_COUNTRY_INPUT_PATH = "wikipedia/wiki_observ_langs26_{0}_country_exports.tsv"
WIKI_LANG_OUTPUT_PATH = "wikipedia/wiki_observ_langs26_{0}_language_exports.tsv"

MURRAY_COUNTRY_INPUT_PATH = "murray/HA_unique_countries_resolved_{0}_country_exports.tsv"
MURRAY_COUNTRY_INPUT_PATH = "murray/HA_unique_countries_resolved_{0}_country_exports.tsv"


def convert_country_data(country_data):
    'Converting country data to language data'
    language_data = dict()

    for country_name, country_value in country_data.iteritems():
        #for country_code, vals in COUNTRY_TO_LANGS.iteritems():
            langs_proportions = COUNTRY_TO_LANGS[country_name]['langs']
            print country_name, country_value, langs_proportions # debug print
            for lang, proportion in langs_proportions.iteritems():
                if lang in language_data:
                    language_data[lang] += (proportion / 100.) * country_value
                else:
                    language_data[lang] = (proportion / 100.) * country_value        
                #debug print 
                print "{0}-->{1}: {2}-->{3}".format(country_name, lang, country_value,language_data[lang])
            print # debug print
    return language_data



def write_lang_exports_table(infile, outfile):
    country_data = Counter()
    
    input_dataset = codecs.open(infile, "rU")
    input_dataset.readline() # skip header

    # Aggregating country exports for legit years
    for line in input_dataset:
        country_name, total_exports = line.strip().split('\t')
        print country_name, total_exports # debug print
        country_data[country_name] = float(total_exports)

    print "Total people:", sum(country_data.values())


    # Convert
    language_data = convert_country_data(country_data)
    
    # Sort dictionary by values: returns a list of tuples
    language_data_sorted = sorted(language_data.iteritems(), 
        key=operator.itemgetter(1),
        reverse=True)
    
    # Write sorted table
    output_dataset = codecs.open(outfile, "w")
    output_dataset.write("lagnuage\tvals\n")

    for lang, total_exports in language_data_sorted:
        output_dataset.write('{0}\t{1}\n'.format(lang, total_exports))
    output_dataset.close()


if __name__ == '__main__':
    # Convert countries to languages:
    for year in ["all", "1800_1950"]:
        write_lang_exports_table(
            WIKI_COUNTRY_INPUT_PATH.format(year), 
            WIKI_LANG_OUTPUT_PATH.format(year)
            )

        write_lang_exports_table(
            MURRAY_COUNTRY_INPUT_PATH.format(year),
            MURRAY_COUNRY_LANG_OUTPUT_PATH.format(year)
            )
