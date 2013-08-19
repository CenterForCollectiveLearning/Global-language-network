import codecs, csv, sys

'''
Standardize language codes from multiple sources.

The default table we use converts language codes used by CLD (Twitter dataset)
and Wikipedia language edition (both roughly equivalent to ISO639-1) and the
UNESCO's Index Translationum (roughly ISO639-2) to ISO639-3 language codes.
This table also merges individual languages into ISO639-3 macrolanguages (cf. http://www.sil.org/iso639-3/macrolanguages.asp), including seven language codes
that were changed/retired but are still used in the Index Translationum.

The conversion table was created semi-manualy using Excel. 
See data/conversion_table. --> TODO: update path!
'''

DELIM = '\t'

def init_conversion_table_iso3(table_file):
	'''
	Load into a dictionary a table that maps all language codes (Twitter/CLD, 
	Wikipedia, and UNESCO's ISO639-2) to ISO 639-3 codes, with mapping to 
	Macrolanguauges as well.
	
	-Input: a tab-delimited file with a header and the following colums:
	 Final_Code	Final_Name	Status	Partner_Agency	639_3	639_2	639_2_B	639_1
	 Common_Twitter_Wiki_Code	Twitter_CLD_Only_Code	Wiki_Only_Code	
	 Reference_Name	Element_Scope	Language_Type	Documentation
	
	-Return: a dictionary that maps language codes in different formats (keys)
	 to ISO639-3 language codes.
	'''
	conversion_table = {}
	code_to_name = {}
	
	reader = csv.DictReader(codecs.open(table_file, 'rU'), delimiter='\t')
	for line in reader:
		final_code = line['Final_Code']
		final_name = line['Final_Name']
		
		code_to_name[final_code] = final_name
		
		conversion_table[ line['Common_Twitter_Wiki_Code'] ] = final_code
		conversion_table[ line['Wiki_Only_Code'] ] = final_code
		conversion_table[ line['Twitter_CLD_Only_Code'] ] = final_code
		conversion_table[ line['639_3'] ] = final_code
		conversion_table[ line['639_2_B'] ] = final_code
			
	return conversion_table, code_to_name


def convert(iso3conversionfile, infiles, outfile):
	iso3_table, code_to_name = init_conversion_table_iso3(iso3conversionfile)
	
	all_lang_names = set()

	# get langauge names from all files
	for infofile in infiles:
		fin = codecs.open(infofile, 'rU')
		fin.readline() # skip header
		for line in fin:
			langname = line[:-1].split(DELIM)[0]
			all_lang_names.add(langname)
	
	fout = codecs.open(outfile, 'w')
	
	# write to file
	for lang in all_lang_names:
		try: 
			# convert to ISO 639-3 code (with macrolanguage support)
			iso3_code = iso3_table[lang]
			lang_name = code_to_name[iso3_code]
		except KeyError as e:
			iso3_code = "#N/A"
			lang_name = "#N/A"
			
		fout.write('\t'.join([lang, iso3_code, lang_name])+'\n')
	

if __name__ == "__main__":
	#INPUT_FILES = [
	#	"input/v6_langinfo_unfiltered.txt", \
	#	"input/v7_wiki_langinfo_5-edits-lang-user_20-edits-user_1000-userslang.txt", \
	#	"all_langs_iso639-2_20120722.txt" ]



	ISO639_3_FILE = "../../data/lang_tools/lang_conversion/gold/iso-639-3-20120726_conversion_nogeneric.txt"
	INPUT_FILES = [sys.argv[1]] # Note that more than one file can be used
	OUTPUT_FILE = sys.argv[2]
	
	convert(ISO639_3_FILE, INPUT_FILES, OUTPUT_FILE)

	