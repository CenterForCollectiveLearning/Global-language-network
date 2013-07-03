# -*- coding: utf-8 -*-
# twitter/data_prep.py

'''
This module receives a pipe-delimited text file with Bruno-style headers
(see below), and returns a cleaned, tab-delimited text file containing
the userid and the language for each individual tweet.

Cleaning includes:
-- Removal of null bytes (\x00), which cause "_csv.Error: line contains NULL byte"
when processed by Google's Compact Language Detector
-- Removal of lines with an unexpected (too many/few) number of delimiters.
This may be caused by, e.g., parsing errors (fields appear more than once); or
linebreaks within the tweet text, which cause the information of a tweet to be
spread over more than one line, and thus identified as multiple tweets with missing
information. TODO: merge truncated lines whenever possible to create full lines.
-- Removal of artifacts: hastags, mentions, and URLs
'''

import os, sys, string, re
import HTMLParser

LGN_HOME = os.path.abspath(os.path.relpath(os.path.join(__file__, '../../../')))
ANALYSIS_HOME = os.path.join(LGN_HOME, 'analysis')
sys.path.append(ANALYSIS_HOME)

from common_utils import *

BRUNO_DELIMITER = '|'
BRUNO_HEADER = ['user', 'status', 'time', 'text', 'location', 'source', \
	'followers', 'reply_status', 'reply_use', 'screen_name', 'retweet_status',\
	'retweet_user', 'latitude', 'longitude']
TEXT_ITEM = 3 # The index of the list item that stores text
LENGTH_CUTOFF = 0


def clean_data_line_by_line(infile, outfile):
	# Does all necessary cleaning in one iteration --
	# should be faster than previous vrsion.
	fin = open(infile, 'rU')
	fout = open(outfile, 'w')

	lines_shorter_than_cutoff = {}
	lines_truncated = {}
	lines_with_null_bytes = {}
	lines_with_hashtags = {}
	lines_with_mentions = {}
	lines_with_urls = {}
	lines_empty_text = {}
	lines_bad_breaks = {}

	num_lines_written = 0

	for line_num, line_old in enumerate(fin):
		line_list = line_old[:-1].split(BRUNO_DELIMITER) # remove EOL
		if line_num % 100000 == 0:
			print "Processing line", line_num

		# Some lines with have a irregular linebreaks: at the middle of a line,
		# Mac instead of UNIX, etc. They appear truncated for some purposes but
		# not for others (look, e.g., for the a line with the text "FROM Heewa").
		# With read mode set to 'rU', Python throws exceptions on such lines,
		# so they can be removed, resulting in truncated lines that are in turn
		# removed as well.
		# The following UNIX script for converting linebreak doesn't handle all
		# cases: tr '\r' '\n' < input_file > output_file
		try:
			text = line_list[TEXT_ITEM]
			if _get_escaped_length(text) < LENGTH_CUTOFF:
				lines_shorter_than_cutoff[line_num] = text
				continue
		except IndexError:
			# Skip this line and don't write it to cleaned file
			lines_bad_breaks[line_num] = line_old
			continue

		# Delimiters:
		# This is the only stage where we check the entire line,
		# not just the text field
		if _identify_wrong_number_of_delimiters(line_old)==True:
			#print ">>> delimiter:", line_num, ":", line_old
			lines_truncated[line_num] = line_old
			continue # discard this line

		# Null bytes
		changed, text_new = _remove_null_bytes(text)
		if changed==True:
			lines_with_null_bytes[line_num] = line_old

		# hashtags
		changed, text_new = _remove_hashtags(text_new)
		if changed==True:
			lines_with_hashtags[line_num] = line_old

		# mentions
		changed, text_new = _remove_mentions(text_new)
		if changed==True:
			lines_with_mentions[line_num] = line_old

		# URLs
		changed, text_new = _remove_urls(text_new)
		if changed==True:
			lines_with_urls[line_num] = line_old

		# Write updated line to file if there's anything left
		if text_new!="" and text_new!=None:
			line_list[TEXT_ITEM] = text_new
			fout.write(BRUNO_DELIMITER.join(line_list) + '\n')
			num_lines_written += 1
		else:
			# print ">>>", line_num, ":", line_old
			lines_empty_text[line_num] = line_old

	fin.close()
	fout.close()

	return lines_bad_breaks, lines_truncated, lines_with_null_bytes, \
		lines_with_hashtags, lines_with_mentions, lines_with_urls, \
		lines_empty_text, num_lines_written, lines_shorter_than_cutoff


def _remove_null_bytes(line):
	# Removes null bytes (\x00) which cause "_csv.Error: line contains NULL byte"
	# when processed by Compact Language Detector
	new_line = line.replace('\x00', '')
	changed = False if new_line==line else True
	return changed, new_line


def _get_escaped_length(text):
	htmlparser = HTMLParser.HTMLParser()
	a = string.split(text, " ")
	b = filter(lambda x: "@" not in x and "#" not in x and "http" not in x, a)
	text = " ".join(b)
	converted_text = htmlparser.unescape(text.decode('utf-8'))
	return len(converted_text)


def _identify_wrong_number_of_delimiters(text):
	# Remove lines that have too few/many delimiters, and thus assumed to be
	# truncated/incorrectly parsed. The expected number of delimiters is taken
	# from BRUNO_HEADER (always one fewer than number of column header);
	# the delimiter character is defined in BRUNO_DELIMITER.
	delimiters_expected_in_line = len(BRUNO_HEADER)-1 #

	if text.count(BRUNO_DELIMITER) == delimiters_expected_in_line:
		return False
	else:
		return True


# removes hashtags
def _remove_hashtags(text):
	pattern = re.compile('#\S+')
	new_text = pattern.sub("", text)
	changed = False if new_text==text else True
	return changed, new_text


# removes mentions
def _remove_mentions(text):
	pattern = re.compile('@\S+')
	new_text = pattern.sub("", text)
	changed = False if new_text==text else True
	return changed, new_text


# removes URLS
def _remove_urls(text):
	pattern = re.compile('(http|www)\S+')
	new_text = pattern.sub("", text)
	changed = False if new_text==text else True
	return changed, new_text


if __name__ == "__main__":
	rawfile = sys.argv[1]
	cleanfile = append_to_filename(rawfile, 'clean')

	lines_bad_breaks, lines_truncated, lines_with_null_bytes, \
		lines_with_hashtags, lines_with_mentions, lines_with_urls, \
		lines_empty, num_lines_written, lines_shorter_than_cutoff = clean_data_line_by_line(rawfile, cleanfile)

	print "lines_bad_breaks", len(lines_bad_breaks)
	print "lines_truncated", len(lines_truncated)
	print "lines_with_null_bytes", len(lines_with_null_bytes)
	print "lines_with_hashtags", len(lines_with_hashtags)
	print "lines_with_mentions", len(lines_with_mentions)
	print "lines_with_urls", len(lines_with_urls)
	print "lines_empty", len(lines_empty)
	print "lines written to file:", num_lines_written
	print "lines shorter than cutoff:", len(lines_shorter_than_cutoff)

	print "\nCreated files:"
	print cleanfile
	print
