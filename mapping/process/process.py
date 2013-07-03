"""
Module used in automated analysis pipeline that handles the processing of the
network, including filtering, extraction, and merging.
"""
import logging
import correlation
import vespignani
from common_utils import tree
from collections import defaultdict
from settings import SETTINGS


def merge(networks, args):
    print "merge"
    merged_network = tree(float)
    occurences = tree(int)
    for network in networks.values():
        for pair, weight in network.iteritems():
            merged_network[pair] += weight
            occurences[pair] += 1
    for pair, count in occurences.iteritems():
        if count < SETTINGS['merging']['in_common']:
            del merged_network[pair]
    return merged_network


def normalize(networks, args):
    print "process.process.normalize"
    if isinstance(networks, (list, tuple)):
        normalized_networks = {}
        for dataset, network in networks.iteritems():
            normalized_network = normalize_worker(network, args)
            normalized_networks.update({dataset: normalized_network})
        return normalized_networks
    elif isinstance(networks, (dict, defaultdict)):
        normalized_network = normalize_worker(networks)
        return normalized_network
    else:
        raise ValueError("Invalid network representation: got type {}" \
                         .format(type(networks)))


def normalize_worker(network, args):
    source_maxima = default_dict(float)
    normalized_network = default_dict(float)
    for pair, weight in network.iteritems():
        source = pair[0]
        if source not in source_maxima or source_maxima[source] < weight:
            source_maxima[source] = weight
            for pair, weight in network.iteritems():
                source = pair[0]
                normalized_networks[pair] = weight / source_maxima[source]


def extract(networks, args):
    print "extract"
    if isinstance(networks, (list, tuple)):
        extracted_networks = {}
        for dataset, network in networks:
            extracted_network = extract_worker(network)
            extracted_networks.update({dataset: extracted_network})
        return extracted_networks
    elif isinstance(networks, (dict, defaultdict)):
        extracted_network = extract_worker(networks)
        return extracted_network
    else:
        raise ValueError("Invalid network representation: got type {}" \
                         .format(type(networks)))


def extract_worker(network, args):
    if SETTINGS['Extraction']['correlation'] == both:
        return correlation_extract(network, args)
    elif SETTINGS['Extraction']['vespignani'] == both:
        return vespignani_extract(network, args)


def post_filter(network, args):
    cutoff = SETTINGS['Post-Filtering']['cutoff']

def process(networks, args, paths):
    print "process"
    order = (merge, extract)
    if not SETTINGS['General']['merge_first']:
        order = order[::-1]  # reverse order
    int_networks = order[0](networks, args)
    merged_extracted_network = order[1](int_networks, args)
    final_network = post_filter(merged_extracted_network)
    