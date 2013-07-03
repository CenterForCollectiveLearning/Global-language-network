'''
Data augmentation:
1) add continents names to countries
2) add language families to languages
'''

from csv import DictReader

'''
Language family and sub-branch for each language, taken from Wikipeia.

Notes:
1) Identification of Turkish and Japanese as Macro-Altaic is still in debate
http://en.wikipedia.org/wiki/Altaic_language#Controversy
2) Korean is isolated or Altaic.
'''
LANGUAGE_FAMILIES = {
	'en' : ('Indo-European', 'Germanic'),
	'es' : ('Indo-European', 'Romance'),
	'tr' : ('Macro-Altaic', 'Turkic'),
	'ja' : ('Macro-Altaic', 'Japonic'),
	'it' : ('Indo-European', 'Romance'),
	'zh' : ('Sino-Tibetan', 'Sinitic'),
	'zh-zh-TW' : ('Sino-Tibetan', 'Sinitic'),
	'fr' : ('Indo-European', 'Romance'),
	'de' : ('Indo-European', 'Germanic'),
	'ru' : ('Indo-European', 'Slavic'),
	'nl' : ('Indo-European', 'Germanic'),
	'iw' : ('Afro-Asiatic', 'Semitic'),
	'ar' : ('Afro-Asiatic', 'Semitic'),
	'el' : ('Indo-European', 'Hellenic'), 
	'pt' : ('Indo-European', 'Romance'), 
	'hi' : ('Indo-European', 'Indo-Iranian'),
	'ko' : ('Macro-Altaic', 'Korean'), 
	'vi' : ('Austro-Asiatic', 'Vietic'), 
	'uk' : ('Indo-European', 'Slavic'),
	'ml' : ('Dravidian', 'Tamil'),
	'hu' : ('Uralic', 'Ugric'), 
	'no' : ('Indo-European', 'Germanic'),
	'pl' : ('Indo-European', 'Slavic'), 
	'sv' : ('Indo-European', 'Germanic'),
	}


'''
Originally from http://www.worldatlas.com/cntycont.htm, 
adapted upon exceptions to match conuntry names we currently use.
Changed 'Russia' to 'Europe'
-- Armenia, Azerbaijan, Georgia listed as Europe, consider changing to Asia
'''
COUNTRIES_BY_CONTINENT = {
 'Afghanistan': 'ASIA', 'Albania': 'EUROPE', 'Algeria': 'AFRICA', 
 'Andorra': 'EUROPE', 'Angola': 'AFRICA', 'Antigua and Barbuda': 'N_AMERICA',
 'Argentina': 'S_AMERICA', 'Armenia': 'EUROPE', 'Australia': 'OCEANIA',
 'Austria': 'EUROPE', 'Azerbaijan': 'EUROPE', 'Bahamas': 'N_AMERICA',
 'Bahrain': 'ASIA', 'Bangladesh': 'ASIA', 'Barbados': 'N_AMERICA', 
 'Belarus': 'EUROPE', 'Belgium': 'EUROPE', 'Belize': 'N_AMERICA', 
 'Benin': 'AFRICA', 'Bhutan': 'ASIA', 'Bolivia': 'S_AMERICA', 
 'Bosnia and Herzegovina': 'EUROPE', 'Botswana': 'AFRICA', 'Brazil': 'S_AMERICA',
 'Brunei': 'ASIA', 'Bulgaria': 'EUROPE', 'Burkina Faso': 'AFRICA', 'Burma': 'ASIA', 'Myanmar': 'ASIA',
 'Burundi': 'AFRICA', 'Cambodia': 'ASIA', 'Cameroon': 'AFRICA', 'Canada': 'N_AMERICA',
 'Cape Verde': 'AFRICA', 'Central African Republic': 'AFRICA', 'Chad': 'AFRICA', 
 'Chile': 'S_AMERICA', 'China': 'ASIA', 'Taiwan': 'ASIA', 'Colombia': 'S_AMERICA', 'Comoros': 'AFRICA',
 'Congo, Republic of the': 'AFRICA', 'Republic of the Congo': 'AFRICA', 'Congo, Democratic Republic of the': 'AFRICA', 'Democratic Republic of the Congo': 'AFRICA', 
 'Costa Rica': 'N_AMERICA', 'Croatia': 'EUROPE', 'Cuba': 'N_AMERICA', 
 'Cyprus': 'EUROPE', 'Czech Republic': 'EUROPE', 'Denmark': 'EUROPE',
 'Djibouti': 'AFRICA', 'Dominica': 'N_AMERICA', 'Dominican Republic': 'N_AMERICA', 
 'East Timor': 'ASIA', 'Ecuador': 'S_AMERICA', 'Egypt': 'AFRICA', 
 'El Salvador': 'N_AMERICA', 'Equatorial Guinea': 'AFRICA', 'Eritrea': 'AFRICA',
 'Estonia': 'EUROPE', 'Ethiopia': 'AFRICA', 'Fiji': 'OCEANIA', 'Finland': 'EUROPE',
 'France': 'EUROPE', 'Gabon': 'AFRICA', 'Gambia': 'AFRICA', 'Georgia': 'EUROPE',
 'Germany': 'EUROPE', 'Ghana': 'AFRICA', 'Greece': 'EUROPE',
 'Grenada': 'N_AMERICA', 'Guatemala': 'N_AMERICA', 'Guinea': 'AFRICA',
 'Guinea-Bissau': 'AFRICA', 'Guyana': 'S_AMERICA', 'Haiti': 'N_AMERICA',
 'Honduras': 'N_AMERICA', 'Hungary': 'EUROPE', 'Iceland': 'EUROPE',
 'India': 'ASIA', 'Indonesia': 'ASIA', 'Iran': 'ASIA', 'Iraq': 'ASIA',
 'Ireland': 'EUROPE', 'Israel': 'ASIA', 'Italy': 'EUROPE', 'Cote d\'Ivoire': 'AFRICA', 'Ivory Coast': 'AFRICA',
 'Jamaica': 'N_AMERICA', 'Japan': 'ASIA', 'Jordan': 'ASIA', 'Kazakhstan': 'ASIA',
 'Kenya': 'AFRICA', 'Kiribati': 'OCEANIA', 'North Korea': 'ASIA', 'Korea, North': 'ASIA',
 'South Korea': 'ASIA', 'Korea, South': 'ASIA', 'Kuwait': 'ASIA', 'Kyrgyzstan': 'ASIA', 'Laos': 'ASIA', 
 'Latvia': 'EUROPE', 'Lebanon': 'ASIA', 'Lesotho': 'AFRICA', 'Liberia': 'AFRICA',
 'Libya': 'AFRICA', 'Liechtenstein': 'EUROPE', 'Lithuania': 'EUROPE',
 'Luxembourg': 'EUROPE', 'Macedonia': 'EUROPE', 'Madagascar': 'AFRICA',
 'Malawi': 'AFRICA', 'Malaysia': 'ASIA', 'Maldives': 'ASIA', 'Mali': 'AFRICA',
 'Malta': 'EUROPE', 'Marshall Islands': 'OCEANIA', 'Mauritania': 'AFRICA',
 'Mauritius': 'AFRICA', 'Mexico': 'N_AMERICA', 'Micronesia': 'OCEANIA', 
 'Moldova': 'EUROPE', 'Monaco': 'EUROPE', 'Mongolia': 'ASIA', 'Montenegro': 'EUROPE',
 'Morocco': 'AFRICA', 'Mozambique': 'AFRICA', 'Namibia': 'AFRICA',
 'Nauru': 'OCEANIA', 'Nepal': 'ASIA', 'Netherlands': 'EUROPE',
 'New Zealand': 'OCEANIA', 'Nicaragua': 'N_AMERICA', 'Niger': 'AFRICA',
 'Nigeria': 'AFRICA', 'Norway': 'EUROPE', 'Oman': 'ASIA',
 'Pakistan': 'ASIA', 'Palau': 'OCEANIA', 'Panama': 'N_AMERICA',
 'Papua New Guinea': 'OCEANIA', 'Paraguay': 'S_AMERICA', 'Peru': 'S_AMERICA',
 'Philippines': 'ASIA', 'Poland': 'EUROPE', 'Portugal': 'EUROPE',
 'Qatar': 'ASIA', 'Romania': 'EUROPE', 'Russia': 'EUROPE', 'Russian Federation': 'EUROPE', 
 'Rwanda': 'AFRICA', 'Saint Kitts and Nevis': 'N_AMERICA',
 'Saint Lucia': 'N_AMERICA', 'Saint Vincent and the Grenadines': 'N_AMERICA',
 'Samoa': 'OCEANIA', 'San Marino': 'EUROPE', 'Sao Tome and Principe': 'AFRICA',
 'Saudi Arabia': 'ASIA', 'Senegal': 'AFRICA', 'Serbia': 'EUROPE',
 'Seychelles': 'AFRICA', 'Sierra Leone': 'AFRICA', 'Singapore': 'ASIA',
 'Slovakia': 'EUROPE', 'Slovenia': 'EUROPE', 'Solomon Islands': 'OCEANIA',
 'Somalia': 'AFRICA', 'South Africa': 'AFRICA', 'South Sudan': 'AFRICA',
 'Spain': 'EUROPE', 'Sri Lanka': 'ASIA', 'Sudan': 'AFRICA', 'Suriname': 'S_AMERICA', 
 'Swaziland': 'AFRICA', 'Sweden': 'EUROPE', 'Switzerland': 'EUROPE', 'Syria': 'ASIA',
 'Tajikistan': 'ASIA', 'Tanzania': 'AFRICA', 'Thailand': 'ASIA', 'Togo': 'AFRICA', 
 'Tonga': 'OCEANIA', 'Trinidad and Tobago': 'N_AMERICA', 'Tunisia': 'AFRICA',
 'Turkey': 'ASIA', 'Turkmenistan': 'ASIA', 'Tuvalu': 'OCEANIA', 'Uganda': 'AFRICA',
 'Ukraine': 'EUROPE', 'United Arab Emirates': 'ASIA', 'United Kingdom': 'EUROPE', 
 'United States': 'N_AMERICA', 'Uruguay': 'S_AMERICA', 'Uzbekistan': 'ASIA', 
 'Vanuatu': 'OCEANIA', 'Vatican City': 'EUROPE', 'Venezuela': 'S_AMERICA',
 'Vietnam': 'ASIA', 'Yemen': 'ASIA', 'Zambia': 'AFRICA', 'Zimbabwe': 'AFRICA', 'West Bank': 'ASIA', 'Puerto Rico': 'N_AMERICA', 'Greenland': 'N_AMERICA', 'Hong Kong': 'ASIA', 'Macau': 'ASIA', 'French Guiana': 'S_AMERICA'}


def populate_countries_continents(infile='countries_by_continent.csv'):
	'''
	Used this to create the initial COUNTRIES_BY_CONTINENT dictionary
	'''
	countries_by_continents = {}
	reader = csv.DictReader( open(infile, 'rU'), delimiter=',' )
	
	for row in reader:
		for continent in reader.fieldnames:
			if row[continent]!='':
				countries_by_continents[row[continent]] = continent
			
	return countries_by_continents


def augment_table(infile, outfile):
	'''
	Add continent info to conuntries and language family info to languages in table.
	'''
	delim = ','
	
	fin = open(infile, 'rU')
	fout = open(outfile, 'w')
	
	# Find headers and original indices, used to add values
	headers = fin.readline()[:-1].split(delim)
	index_lang = headers.index('orig_lang') # index_lang=2
	
	# Headers for language info: family precedes branch, thus added later 
	headers.insert(index_lang, 'lang_branch')
	headers.insert(index_lang, 'lang_family')
	
	# Headers for country info
	index_country = headers.index('dest_country') # index_country=5
	headers.insert(index_country, 'dest_continent')
	
	fout.write(delim.join(headers) + '\n')
	
	for line in fin:
		values = line[:-1].split(delim)
		lang_name = values[index_lang]
		
		print "before:", values
		
		# Add language family and sub-branch, respectively
		values.insert(index_lang, LANGUAGE_FAMILIES[lang_name][1])
		values.insert(index_lang, LANGUAGE_FAMILIES[lang_name][0])
			
		# Add continent
		country_name = values[index_country]
		values.insert(index_country, COUNTRIES_BY_CONTINENT[country_name])
		
		print "after:", values
		
		fout.write(delim.join(values) + '\n')
		
	fout.close()


if __name__ == "__main__":
	augment_table(infile='../googlenews/time_resolution/annual_all_2012-04-23.csv', outfile='../googlenews/time_resolution/anunual_all_2012-04-23_augmented.csv')