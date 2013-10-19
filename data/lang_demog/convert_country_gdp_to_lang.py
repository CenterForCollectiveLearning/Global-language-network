#!/usr/bin/python
# -*- coding: utf-8 -*-

### gln/data/gln/data/lang_demog/convert_country_gdp_to_lang.py

"""
Convert country GDP to language GDP
Usage: python convert_country_data_to_lang infile outfiley

Uses the conversion table in ../lang_tools/country_to_lang/,
which lists for each country (2-letter code) its languages (by 3-letter code)
their shares

Gl, the GDP per language l, is calculated as follows:

Gl = sum_over_c_of ( Gc*(Nlc/Nc) ) / sum_over_c_of(Nlc)

Where Gc is the GDP of country c, Nlc is the number of speakers of language_data
in coutnry c, and Nc is the total population of c. 
"""

import os, sys, codecs
import simplejson
import csv
from collections import defaultdict
from collections import Counter
import operator # for dict sorting
# sys.path.append('../lang_tools/country_to_lang')

# 
COUNTRY_TO_LANGS_CONVERSION_FILE = "../../data/lang_tools/country_to_lang/country_to_lang_mapping.json"
COUNTRY_TO_LANGS = \
    simplejson.load(open(COUNTRY_TO_LANGS_CONVERSION_FILE, "rU"))

# Number of speakers by language, to be added to output
LANG_POPULATION = "population/gold/speakers_families_iso639-3.tsv"

# Convert # of illustrious people
COUNTRY_INPUT_PATH = "../lang_demog/country_gdp_pop.tsv"
LANG_OUTPUT_PATH = "../lang_demog/language_gdp_pop.tsv"

def calc_lang_gdps(infile, outfile):
    country_gdps = defaultdict()
    country_pops = defaultdict()
    
    input_dataset = codecs.open(infile, "rU")
    input_dataset.readline() # skip header

    # Aggregating country GDP and population
    for line in input_dataset:
        c_name, c_gdp, c_pop = line.strip().split('\t')
        #print c_name, c_gdp, c_pop # debug print
        country_pops[c_name] = int(c_pop)
        country_gdps[c_name] = float(c_gdp)
    
    agg_lang_pop = defaultdict(float)
    agg_lang_income = defaultdict(float)
    lang_gdp = defaultdict(float)

    for cntry, lang_shares in COUNTRY_TO_LANGS.iteritems():
        # lang_shares has two keys: "name" (of country) and "langs"
        for lang, share in lang_shares['langs'].iteritems():
            # aggregate number of speakers for each language over countries
            try:
                agg_lang_pop[lang] += (share/100.) * country_pops[cntry]
                # aggregate income for each language over countries
                agg_lang_income[lang] += (share/100.) * country_gdps[cntry] * country_pops[cntry]
            except KeyError:
                # No GDP and population for coutnry - print name and code and skip
                # We assume the countries in agg_lang_pop are equal to agg_lang_income:
                # They're generated from the same original population and GDP table 
                print "No data for country {0} ({1})".format(cntry, lang_shares["name"])
                break


    for lang in agg_lang_income:
        lang_gdp[lang] = agg_lang_income[lang] / agg_lang_pop[lang]
        # print lang, agg_lang_income[lang], agg_lang_pop[lang], lang_gdp[lang] # debug printout
    
    # Sort dictionary by values: returns a list of tuples
    lang_gdp = sorted(lang_gdp.iteritems(), 
        key=operator.itemgetter(1),
        reverse=True)
    
    # Write sorted table
    output_dataset = codecs.open(outfile, "w")
    output_dataset.write("lagnuage\tgdp\taggregated_speakers\tactual_speakers\n")

    # Add population for language
    pop_data = codecs.open(LANG_POPULATION, "rU")
    dr = csv.DictReader(pop_data, delimiter="\t")
    act_lang_pop = defaultdict(float)
    for row in dr:
        act_lang_pop[row['Lang_Code']] = row['Num_Speakers_M']

    for lang, gdp in lang_gdp:
        output_dataset.write('{0}\t{1}\t{2}\t{3}\n'.format(
            lang, gdp, agg_lang_pop[lang]/1e6, act_lang_pop[lang]))
    output_dataset.close()


if __name__ == '__main__':
    # Convert countries to languages:
    calc_lang_gdps(COUNTRY_INPUT_PATH, LANG_OUTPUT_PATH)