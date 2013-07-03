# lang-country-mapping/mapping-script.py
'''
This module receives Ethnologue language index data in CSV-format and returns a mapping of languages
to countries, and vice-versa.

The output is in CSV format, and has a layout as follows:
lang1, COUNTRY1, COUNTRY2, ... , COUNTRYN
lang2, COUNTRY1, COUNTRY2, ... , COUNTRYN
'''
import sys
import csv

# List containing the 3-character codes for the full set oflanguages detected in the Twitter data set
# (See userlang_data_statistics.xlsx
LANGS_IN_TWITTER = [
	'eng', 'jpn', 'por', 'spa', 'zlm', 'ind', 'nld', 'ara', 'kor', 'rus', 'tha', 'tur', 'fra', 'fil', 'ita', \
	'deu', 'ell', 'dan', 'swe', 'ces', 'cat', 'cmn', 'fin', 'nob', 'glg', 'ron', 'slk', 'afr', 'pol', \
	'lav', 'hrv', 'vie', 'hun', 'als', 'lit', 'swa', 'heb', 'bul', 'slv', 'per', 'mlt', 'est', 'hat', \
	'ukr', 'srp', 'urd', 'tam', 'eus', 'aze', 'mkd', 'hin', 'isl', 'gle', 'cym', 'bel', 'hye', 'kat', \
	'mya', 'sin', 'tel', 'pan', 'guj', 'kan', 'chr', 'mya', 'khm', 'lao', 'bod', 'div', 'yid', 'amh', \
	'iku', 'ori', 'syr', 'mon' 
]

# Dictionary containing mapping of the previous language codes to their 2-character equivalents
LANGS_DICT = {
	'eng' : 'en', 'jpn' : 'ja', 'por' : 'pt', 'spa' : 'es', 'zlm' : 'ms', 'ind' : 'id', 'nld' : 'nl', \
	'ara' : 'ar', 'kor' : 'ko', 'rus' : 'ru', 'tha' : 'th', 'tur' : 'tr', 'fra' : 'fr', 'fil' : 'fil', \
	'ita' : 'it', 'deu' : 'de', 'ell' : 'el', 'dan' : 'da', 'swe' : 'sv', 'ces' : 'cs', 'cat' : 'ca', \
	'cmn' : 'zh-zh-TW', 'fin' : 'fi', 'nob' : 'nb', 'glg' : 'gl', 'ron' : 'ro', 'slk' : 'sk', 'afr' : 'af', \
	'pol' : 'pl', 'lav' : 'lv', 'hrv' : 'hr', 'vie' : 'vi', 'hun' : 'hu', 'als' : 'sq', 'lit' : 'lt', \
	'swa' : 'sw', 'heb' : 'he', 'bul' : 'bg', 'slv' : 'sk', 'per' : 'fa', 'mlt' : 'mt', 'est' : 'et', \
	'hat' : 'ht', 'ukr' : 'uk', 'srp' : 'sr', 'urd' :'ur', 'tam' : 'ta', 'eus' : 'eu', 'aze' : 'az', \
	'mkd' : 'mk' , 'hin' : 'hi', 'isl' : 'is', 'gle' : 'ga', 'cym' : 'cy', 'bel' : 'be', 'hye' : 'hy', \
	'kat' : 'ka', 'mya' : 'ml', 'sin' : 'si', 'tel' : 'te', 'pan' : 'pa', 'guj' : 'gu', 'kan' : 'kn', \
	'chr' : 'chr', 'mya' : 'my', 'khm' : 'km', 'lao' : 'lo', 'bod' : 'bo', 'div' : 'dv', 'yid' : 'yi', \
	'amh' : 'am', 'iku' : 'iu', 'ori' : 'or', 'syr' : 'syr', 'mon' : 'mn'
}

def remove_dups(inputList):
	return list(set(inputList))

if __name__ == "__main__":
	inputfilename = sys.argv[1]

	inputCSV = csv.reader(open(inputfilename, 'rb'), delimiter=',')

	open('languages-to-countries.csv', 'w').close()
	output = open('languages-to-countries.csv', 'w')
	
	# Create a key:value(list) pairing for each relevant language in the input file
	MAPPING_DICT = {}
	for line in inputCSV:
		if line[0] in LANGS_IN_TWITTER:
			MAPPING_DICT[line[0]] = []
	
	# Add all countries to list
	inputCSV = csv.reader(open(inputfilename, 'rb'), delimiter=',')
	for line in inputCSV:
		if line[0] in LANGS_IN_TWITTER:
			MAPPING_DICT[line[0]].append(line[1])
	
	for key, value in MAPPING_DICT:
		MAPPING_DICT[key] = list(set(value))

	# Write to CSV file
	for language, countries in MAPPING_DICT.items():
		output.write(language)
		for country in countries:
			output.write("," + country)
		output.write("\n")

	output.close()
		
	print "Created files: languages-to-countries.csv"

# FIltered data
