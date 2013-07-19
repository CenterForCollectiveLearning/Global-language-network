import sys
import codecs
import csv
from collections import defaultdict

LGN_HOME = '../../../' # fix this path to work for you!!!!
sys.path.append(LGN_HOME+'mapping/load/')
import convert_lang

# header: 'language\tlangcode\tnumber of speakers\tMacrogroup\tSource\tComments'

fin = codecs.open('Wikipedia_Languages_by_Speakers.txt', 'rU')
fout = codecs.open('Wikipedia_Languages_by_Speakers_iso639-3.txt', 'w')
reader = csv.DictReader(fin, delimiter='\t')

conversion_table, code_to_name = \
	convert_lang.init_conversion_table_iso3(LGN_HOME+ \
	'data/lang_tools/lang_conversion/gold/iso-639-3-20120726_conversion_nogeneric.txt')

speakers = defaultdict(float)
fout.write('Lang_Code\tLang_Name\tNum_Speakers_M\n') # header

for row in reader:
	try:
		iso_langcode = conversion_table[row['langcode'].replace("-", "_")]
	except KeyError as e:
		print "Can't convert %s" % e
		continue
		
	try:
		num_speakers = row['number of speakers'] # merge into macrolanguages if necessary
		speakers[iso_langcode] += float(num_speakers) 
	except ValueError:
		print "%s: '%s' is not a number, skipping" % (iso_langcode, num_speakers)
		continue

for langcode, people in speakers.iteritems():
	langname = code_to_name[langcode]
	fout.write( '\t'.join([langcode, langname, str(people)]) +'\n')

	
fout.close()
	
	