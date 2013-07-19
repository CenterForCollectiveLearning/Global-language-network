"""
Module used as entry-point of automated mapping pipeline
of Global Lanuage Network that deals with top-level program logic,
data flow, logging, profiling, argument and configuration parsing.
Delegates most work to three other modules: load, process, and visualize.

Run using 'python mapping' in directory containing root mapping directory

Configuration is specified in mapping/settings.py.

Output is stored in mapping_results/{date} directory
"""

import re
import os
import sys
import time
import shutil
import logging
import argparse
import datetime

from load import load
from load import convert_lang
from process import process
from visualize import visualize

from common_utils import *

today = get_current_date_formatted()

log = logging.getLogger("main")

from settings import SETTINGS, VISUAL_SETTINGS, LANG_SETTINGS


def parse_arguments():
    "Parse command-line arguments (passed after file name)"
    parser = argparse.ArgumentParser()
    parser.add_argument('-v', '--verbose', dest='verbose',
                        action='store_true',
                        help="increase output verbosity")
    return parser.parse_args()


def get_paths():
    """
    Create dictionary of relevant absolute paths to avoid
    ambiguity.
    """
    paths = {}

    # ../gln/
    paths['gln'] = os.path.abspath(os.path.relpath(os.path.join(__file__, '../../')))

    # ../gln/mapping
    paths['mapping'] = os.path.join(paths['gln'], 'mapping')

    # ../gln/settings.py
    paths['settings'] = os.path.join(paths['mapping'], 'settings.py')

    # ../gln/mapping_results/
    paths['results_root'] = os.path.join(paths['gln'], 'mapping_results')


    # ../gln/mapping/{load || process || visualize}
    for mapping_child in ['load', 'process', 'visualize']:
        paths[mapping_child] = os.path.join(paths['mapping'], mapping_child)

    # Add subfolder in results directory with date, suffix (for multiple \
    #    analyses on the same day)
    # ../gln/mapping_results/{date}_{suffix}
    suffix = 1
    while True:
         # ../gln/results/{date}
        temp = os.path.join(paths['results_root'], today) # "_" + str(SETTINGS['extraction']['probability_cutoff']) + "_" + str(SETTINGS['extraction']['weight_cutoff']))
        if not os.path.exists(temp + '_{}/'.format(suffix)) and \
        not os.path.exists(temp + '_{}-incomplete/'.format(suffix)):
            os.makedirs(temp + '_{}/'.format(suffix))
            break
        else:
            suffix += 1

    # ../gln/mapping_results/{date}_{suffix}, i.e the
    # closest parent directory to where the results are actually stored
    paths['results'] = temp + '_{}/'.format(suffix)

    # ../gln/results/all/{preprocessed || processed || final || visualizations}
    for result_child in ['preprocessed', 'processed', 'normalized', 'final', 'visualizations']:
        paths[result_child] = os.path.join(paths['results'], result_child)
        os.makedirs(paths[result_child])

    # Serialized versions of results of load
    paths['populations_pkl'] = os.path.join(paths['preprocessed'], 'populations.pkl')
    paths['networks_pkl'] = os.path.join(paths['preprocessed'], 'networks.pkl')

    # Final statistics of network
    paths['stats'] = os.path.join(paths['final'], 'stats.txt')

    # ../gln/mapping_results/all/{merged || extracted}
    if SETTINGS['general']['merge_first']:
        merge_or_extract = 'merged'
    else:
        merge_or_extract = 'extracted'
    paths[merge_or_extract] = os.path.join(paths['results'], merge_or_extract)
    os.makedirs(paths[merge_or_extract])

    # Number of speakers per language file
    paths['num_speakers_per_lang_file'] = \
        os.path.join(paths['gln'], VISUAL_SETTINGS['num_speakers_per_lang_file'])

    # Datasets
    infiles = { dataset_name : os.path.join(paths['gln'], 
        SETTINGS['dataset_locations'][dataset_name]) 
        for dataset_name in SETTINGS['general']['datasets_to_use'] }    # }
    paths.update(infiles)

    return paths


def write_property_file(paths):
    "Write property file for visual properties to be used by Main.java"
    prop_file_name = os.path.join(paths['visualize'], 'temp.properties')
    prop_file = open(prop_file_name, 'w')
    for key, val in VISUAL_SETTINGS.iteritems():
        prop_file.write('{}={}\n'.format(key, val))
    prop_file.close()


def incomplete(paths):
    "Append -incomplete to results directory if mapping incomplete"
    print "Incomplete, appending incomplete"
    shutil.move(paths['results'], paths['results'][:-1] + '-incomplete')


def main():
    "Entry point to actual mapping"
    args = parse_arguments()
    paths = get_paths()
    shutil.copy(paths['settings'], paths['results'])

    try:
        if args.verbose:
            print args
            print paths

        start_time = time.time()
        print "\nSTARTING MAPPING\n"

        # Initialize language conversion tables. TODO: since one of these tables
        # is used in the viz section, consider moving convert_lang to common_utils
        iso639_conversion, iso3_codes_to_name = \
            convert_lang.init_conversion_table_iso3(\
            LANG_SETTINGS['lang_conversion_file'])

        langinfos, networks = load(args, paths)
        final_network = process(langinfos, networks, args, paths)

        # Regex pattern to remove text within parentheses and space before (e.g. ' (macrolanguage)')
        pattern = re.compile(r' \(.*?\)')
        # Convert ISO codes to full language names
        final_network_full_names = defaultdict(float)
        # for (src, tgt), weight in final_network.iteritems():
        #     src_full_name = re.sub(pattern, '', iso3_codes_to_name[src])
        #     tgt_full_name = re.sub(pattern, '', iso3_codes_to_name[tgt])
        #     final_network_full_names[(src_full_name, tgt_full_name)] = weight

        if VISUAL_SETTINGS['visualize']:
            write_property_file(paths)
            visualize(final_network_full_names, paths) # note the name change here!

        # TODO: Call R script

        total_time = round((time.time() - start_time), 3)
        print "\nFINISHED MAPPING\n"
        print "\tTotal mapping time:", total_time, "seconds"

    except (KeyboardInterrupt, SystemExit, Exception):
        print "***********************************"
        incomplete(paths)
        raise

def sweep():
    for prob_cutoff in [x / 100. for x in range(0, 100, 5)]:
        SETTINGS['extraction']['probability_cutoff'] = prob_cutoff
        for weight_cutoff in range(0, 200, 10):
            SETTINGS['extraction']['weight_cutoff'] = weight_cutoff
            print "******************************"
            print "Probability cut-off:", prob_cutoff
            print "Weight cut-off:", weight_cutoff
            main()

if __name__ == "__main__":
    main()
