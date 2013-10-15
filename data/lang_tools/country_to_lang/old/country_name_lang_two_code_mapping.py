'''
Breakdown of languages in each country accoding to CIA World Fact Book, or, if missing, from Wikipedia articles.

-Percentages may not add to 100, and may be missing altogehter in certain cases. I wouldn't trust it with my life...
'''

import sys
import operator # for sorting dictionary by values

LGN_HOME = '../../../' # fix this path to work for you!!!!
sys.path.append(LGN_HOME+'mapping/load/')
import convert_lang

LANG_CONVERSION_FILE = LGN_HOME+\
  "/data/lang_tools/lang_conversion/gold/iso-639-3-20120726_conversion_nogeneric.txt"


# Print the dictionary: leave blank to print to screen, or pass a filename
OUTPUT_FILENAME = "" 

COUNTRY_NAME_TO_LANGS_TWO = {
 ('Afghanistan',): {'fa': 50},
 ('Albania',): {'ro': 5, 'sq': 95},
 ('Algeria',): {'ar': 73, 'fr': 5},
 ('American_Samoa',): {'en' : 2.9},
 ('Andorra',): {'ca': 50, 'es': 40, 'fr': 10},
 ('Angola',): {'pt': 80},
 ('Anguilla',): {'en': 100},
 ('Antarctica',): {},
 ('Antigua and Barbuda','Antigua_&_Barbuda',): {'en': 100},
 ('Argentina',): {'es': 85, 'it': 3.8},
 ('Armenia',): {'hy': 97.7, 'ru': 0.9},
 ('Aruba',): {'en': 7.7, 'es': 12.6, 'nl': 5.8},
 ('Australia',): {'ar': 1.2,
  'el': 1.3,
  'en': 78.5,
  'it': 1.6,
  'zh-zh-TW': 2.5},
 ('Austria',): {'de': 88.6, 'hr-sr': 2.2, 'tr': 2.3},
 ('Azerbaijan',): {'az': 90.3, 'hy': 1.5, 'ru': 1.8},
 ('Bahamas, The','Bahamas'): {'en': 100},
 ('Bahrain',): {'ar': 100},
 ('Bangladesh',): {'bn': 98, 'en': 2},
 ('Barbados',): {'en': 100},
 ('Belarus',): {'be': 36.7, 'ru': 62.8},
 ('Belgium',): {'fr': 40, 'nl': 60},
 ('Belize',): {'en': 3.9, 'es': 46, 'ht': 32.9},
 ('Benin',): {'fr': 40},
 ('Bermuda',): {'en': 91.8, 'pt': 4},
 ('Bhutan',): {},
 ('Bolivia',): {'ay': 14.6, 'es': 60.7, 'qu': 21.2},
 ('Bosnia and Herzegovina', 'Bosnia_Herzegovina',): {'hr-sr': 11.9, 'hr-sr': 33.2},
 ('Botswana',): {'en' : 2.1},
 ('Brazil',): {'pt' : 100},
 ('Brunei Darussalam','Brunei_Darussalam', 'Brunei'): {'id-ms' : 80, 'en' : 20},
 ('Bulgaria',): {'bg': 84.5, 'tr': 9.6},
 ('Burkina Faso', 'Burkina_Faso'): {'fr': 100},
 ('Burundi',): {'fr': 0.02},
 ('Cambodia',): {'en': 2.5, 'fr': 2.5, 'km': 95},
 ('Cameroon',): {'en': 50, 'fr': 50},
 ('Canada',): {'en': 65, 'fr': 35},
 ('Cape Verde', 'Cape_Verde_Islands',): {'pt': 100},
 ('Caroline_Is',): {},
 ('Cayman Islands', 'Cayman_Islands',): {'en': 95, 'es': 5},
 ('Central African Republic', 'Central_African_Rep',): {'fr': 100},
 ('Chad',): {'ar': 50, 'fr': 50},
 ('Channel Islands',): {'en': 100},
 ('Chile',): {'en': 100},
 ('China', 'Mainland_China',): {'zh-zh-TW': 100},
 ('Christmas_Island',): {},
 ('Cocos_Islands',): {},
 ('Colombia',): {'es': 100},
 ('Comoros',): {'ar': 100},
 ('Congo, Dem. Rep.', 'Democratic_Rep_of_Congo', 'Democratic Republic of Congo'): {'fr': 100},
 ('Congo, Republic', 'Congo',): {'fr': 100},
 ('Cook_Islands',): {},
 ('Costa Rica', 'Costa_Rica',): {'es': 100},
 ("Cote d'Ivoire", 'Cote_DIvoire',): {'fr': 100},
 ('Croatia',): {'hr-sr': 100},
 ('Cuba',): {'es': 100},
 ('Cyprus',): {'el': 50, 'fr': 50},
 ('Czech Republic', 'Czech', 'Czech_Republic',): {'cs': 100},
 ("Democratic People's Republic of Korea", 'North Korea', 'Korea_Dem_Peoples_Rep',): {'ko': 100},
 ('Denmark',): {'da': 100},
 ('Djibouti',): {'ar': 50, 'fr': 50},
 ('Dominica',): {'en': 100},
 ('Dominican Republic', 'Dominican_Rep',): {'es': 100},
 ('Ecuador',): {'es': 100},
 ('Egypt, Arab Rep.','Egypt'): {'ar': 100},
 ('El Salvador', 'El_Salvador',): {'es': 100},
 ('Equatorial Guinea', 'Equatorial_Guinea',): {'es': 75, 'fr': 25},
 ('Eritrea',): {'ar': 70, 'en': 30},
 ('Erythrea',): {},
 ('Estonia',): {'et': 70, 'ru': 30},
 ('Ethiopia',): {'am': 32.7, 'om': 31.6, 'en':7.5, 'ar':7.5},
 ('Faeroe Islands',): {'da': 100},
 ('Falkland Islands', 'Falkland_Islands',): {'en': 100},
 ('Fiji',): {'en': 50, 'hi': 50},
 ('Finland',): {'fi': 95, 'sv': 5},
 ('France',): {'fr': 100},
 ('French Guiana', 'French_Guyana',): {'fr': 100},
 ('French_Polynesia',): {'fr' : 61.1},
 ('Gabon',): {'fr': 100},
 ('Gambia, The','Gambia',): {'en': 100},
 ('Georgia',): {'hy': 10, 'ka': 80, 'ru': 10},
 ('Germany',): {'de': 100},
 ('Ghana',): {'en': 100},
 ('Gibraltar',): {'en' : 100},
 ('Greece',): {'el': 100},
 ('Greenland',): {'da': 13.7},
 ('Grenada',): {'en': 100},
 ('Guadeloupe',): {},
 ('Guam',): {'ch': 22.2, 'en': 38.3, 'fil': 22.2},
 ('Guatemala',): {'es': 100},
 ('Guinea',): {'fr': 100},
 ('Guinea-Bissau', 'Guinea_Bissau',): {'pt': 100},
 ('Guyana',): {'en': 100},
 ('Haiti',): {'fr': 25.2, 'ht': 74.8},
 ('Honduras',): {'es': 100},
 ('Hong Kong', 'Hong_Kong_SAR_China', 'Hong-Kong'): {'en': 2.8, 'zh-zh-TW': 91.7},
 ('Hungary',): {'hu': 93.6},
 ('Iceland',): {'is': 100},
 ('India',): {'bn': 8.1, 'hi': 41, 'mr': 7, 'pa': 2.8, 'ta': 5.9, 'te': 7.2, 'ur': 5, 'ml':3.2},
 ('Indonesia',): {'id-ms': 100},
 ('Iran, Islamic Rep.','Iran',): {'ar': 5, 'fa': 75, 'ku': 20},
 ('Iraq',): {'ar': 80, 'ku': 20},
 ('Ireland',): {'en': 95, 'ga': 5},
 ('Israel', 'Israel (Israeli territory)'): {'he': 80, 'ar':20},
 ('Italy',): {'it': 100},
 ('Jamaica',): {'en': 100},
 ('Japan',): {'ja': 100},
 ('Johnston_Island',): {},
 ('Jordan',): {'ar': 100},
 ('Kazakhstan',): {'kk': 60, 'ru': 40},
 ('Kenya',): {'en': 20, 'sw': 80},
 ('Kiribati',): {},
 ('Kuwait',): {'ar': 50, 'en': 50},
 ('Kyrgyzstan',): {'ky': 64.7, 'ru': 12.5, 'uz': 13.6},
 ("Lao People's Democratic Republic", 'Laos', 'Lao_Peoples_Rep',): {'lo': 100},
 ('Latvia',): {'lv': 58.2, 'ru': 37.5, 'lt': 4.3},
 ('Lebanon',): {'ar': 100},
 ('Lesotho',): {'en': 10},
 ('Liberia',): {'en': 20},
 ('Libya',): {'ar': 90, 'en': 5, 'it': 5},
 ('Lithuania',): {'lt': 80, 'pl': 10, 'ru': 10},
 ('Luxembourg',): {'lb':77, 'de': 4, 'en': 1, 'fr': 6},
 ('Macao SAR, China','Macao','Macau'): {'zh-zh-TW': 97, 'en': 1.5, 'fil': 1.3},
 ('Macedonia, Former Yugoslav Republic of', 'Macedonia'): {'mk': 66.5,
  'sq': 25.1,
  'tr': 8.4},
 ('Madagascar',): {'fr': 100},
 ('Malawi',): {'en': 100},
 ('Malaysia',): {'id-ms': 100},
 ('Maldives',): {'dv': 95, 'en': 5},
 ('Mali',): {'bm': 80},
 ('Malta',): {'mt': 90.2, 'en': 6},
 ('Marshall Islands', 'Marshall_Islands',): {'en': 100},
 ('Martinique',): {'fr': 100},
 ('Mauritania',): {'ar': 100},
 ('Mauritius',): {'en': 1, 'fr': 3.5, 'ht': 80.5},
 ('Mayotte',): {'fr': 100},
 ('Mexico',): {'es': 100},
 ('Micronesia, Federated States of',): {'en': 100},
 ('Moldova',): {'ro': 75.17, 'ru': 15.99, 'uk': 3.85, 'bg': 1.14},
 ('Monaco',): {},
 ('Mongolia',): {'mn': 100},
 ('Montenegro',): {'hr-sr': 91, 'sq': 5,}, # hr-sr = sr + bs
 ('Morocco',): {'ar': 100},
 ('Mozambique',): {'pt': 10.7},
 ('Myanmar', 'Burma'): {'my': 66.7},
 ('Namibia',): {'af': 4.4, 'de': 32, 'en': 7},
 ('Nauru',): {},
 ('Nepal',): {},
 ('Netherlands',): {'nl': 100},
 ('Neth_Antilles',): {},
 ('New_Caledonia',): {'fr' : 100},
 ('New Zealand', 'New_Zealand'): {'en': 91.2},
 ('Nicaragua',): {'es': 97.5},
 ('Niger',): {'fr': 100},
 ('Nigeria',): {'en': 100},
 ('Niue',): {},
 ('Norfolk Island', 'Norfolk_Island',): {'en': 100},
 ('Northern_Mariana_Islands',): {},
 ('Norway',): {'nb': 100},
 ('Oman',): {'ar': 100},
 ('Pakistan',): {'pa': 48, 'ur': 8},
 ('Palau','Palau_Island',): {'fil': 13.5, 'en': 9.4, 'zh-zh-TW': 5.7, 'ja': 1.5},
 ('Palestinian Authority', 'Palestinian Territories'): {'ar': 100},
 ('Panama',): {'en': 14, 'es': 86},
 ('Papua New Guinea', 'Papua_New_Guinea',): {'en': 1},
 ('Paraguay',): {'es': 3.1},
 ('Peru',): {'es': 84.1},
 ('Philippines',): {'en': 4, 'fil': 55},
 ('Poland',): {'pl': 97.8},
 ('Portugal',): {'pt': 100},
 ('Puerto Rico', 'Puerto_Rico'): {'en': 2.5, 'es': 87},
 ('Qatar',): {'ar': 50, 'en': 50},
 ('Reunion',): {'fr':100},
 ('Republic of Korea', 'Korea_Republic_of', 'South_Korea'): {'ko': 100},
 ('Romania',): {'hu': 6.7, 'ro': 91},
 ('Russia', 'Russian_Federation',): {'ru': 100},
 ('Rwanda',): {'en': 20, 'fr': 20},
 ('Saint Pierre and Miquelon','St_Pierre_&_Miquelon',): {'fr': 100},
 ('Sao Tome and Principe', 'Sao_Tome_&_Principe',): {'pt': 100},
 ('Saudi Arabia', 'Saudi_Arabia',): {'ar': 100},
 ('Senegal',): {'fr': 100},
 ('Serbia', 'Serbia_&_Montenegro', 'Yugoslavia'): {'hu': 5, 'hr-sr': 95},
 ('Seychelles',): {'en': 5, 'ht': 95},
 ('Sierra Leone', 'Sierra_Leone',): {'en': 100},
 ('Singapore',): {'en': 23, 'id-ms': 14.1, 'zh-zh-TW': 40.7},
 ('Slovakia',): {'hu': 10, 'sk': 90},
 ('Slovenia',): {'sl': 100},
 ('Somalia',): {'ar': 10, 'en': 5, 'it': 5, 'so': 80},
 ('Solomon_Islands',): {'en' : 2},
 ('South Africa', 'South_Africa',): {'af': 13.35,
  'en': 8.2,
  'nso': 9.39,
  'xh': 17.64,
  'zu': 23.83},
 ('South Sudan',): {'ar': 50, 'en': 50},
 ('Spain',): {'ca': 17, 'es': 74, 'eu':2, 'gl':7},
 ('Sri Lanka', 'Sri_Lanka',): {'si': 74, 'ta': 18},
 ('St. Helena', 'St_Helena',): {'en': 100},
 ('St. Kitts and Nevis', 'St_Kitts_&_Nevis',): {'en': 100},
 ('St. Lucia', 'St_Lucia',): {'en': 100},
 ('St. Vincent and the Grenadines', 'St_Vincent_Grenadine',): {'en': 100},
 ('Sudan',): {'ar': 50, 'en': 50},
 ('Suriname', 'Surinam'): {'nl': 100},
 ('Swaziland',): {'en': 100},
 ('Sweden',): {'sv': 100},
 ('Switzerland',): {'de': 66.7, 'en': 1, 'fr': 23.4, 'it': 8.9},
 ('Syrian Arab Republic', 'Syrian_Arab_Rep', 'Syria'): {'ar': 100},
 ('Taiwan', 'Chinese_Taipei',): {'zh-zh-TW': 100},
 ('Tajikistan',): {'tg': 100},
 ('Tanzania',): {'en': 10, 'sw': 90},
 ('Thailand',): {'th': 100},
 ('Togo',): {'fr': 100},
 ('Tonga',): {},
 ('Trinidad and Tobago', 'Trinidad_&_Tobago',): {'en': 100},
 ('Tunisia',): {'ar': 100},
 ('Turkey',): {'ar': 1.2, 'ku': 6, 'tr': 90},
 ('Turkmenistan',): {'ru': 12, 'tk': 72, 'uz': 9},
 ('Turks and Caicos Islands', 'Turks_&_Caicos_Is',): {'en': 100},
 ('Tuvalu',): {},
 ('Uganda',): {'sw':80, 'en': 20},
 ('Ukraine',): {'ru': 24, 'uk': 67},
 ('United Arab Emirates', 'United_Arab_Emirates',): {'ar': 100},
 ('United Kingdom', 'United_Kingdom', 'Britain', 'Great Britain'): {'en': 96.3, 'gd':2.5, 'cy':1.2},
 ('United States', 'United_States', 'United States of America', 'USA'): {'en': 82.1, 'es': 10.7},
 ('Uruguay',): {'es': 100},
 ('Uzbekistan',): {'ru': 14.2, 'tg': 4.4, 'uz': 74.3},
 ('Vanuatu',): {'en':2},
 ('Venezuela',): {'es': 100},
 ('Vietnam',): {'vi': 100},
 ('Virgin Islands, U.S.', 'US_Virgin_Islands',): {'en': 74.7, 'es': 16.8, 'fr': 6.6},
 ('Virgin Islands, U.K.', 'British_Virgin_Islands',): {},
 ('Wallis_&_Futuna_Is',): {'fr' : 10.8},
 ('Western Sahara',): {'ar': 100},
 ('Samoa', 'Western Samoa', 'Western_Samoa'): {},
 ('Yemen, Rep.','Yemen'): {'ar': 100},
 ('Zambia',): {'en': 1.7},
 ('Zimbabwe',): {'en': 100},
 ('Rome',): {'la': 100}, # Murray
 ('Anc Greece',): {'grc': 100}, # Murray
 ('Arab World',): {'ar': 100}, # Murray
 }

def print_country_to_langs_mapping(outfile=""):
  # Format the dictionary nicely and print it, to given file 
  # or to screen (outfile="")

  # Load conversion table
  iso3_table, code_to_name = \
    convert_lang.init_conversion_table_iso3(LANG_CONVERSION_FILE)

  # Hacks for non-standard two-letter codes for merged languages
  iso3_table['hr-sr'] = 'hbs' 
  iso3_table['id-ms'] = 'msa'
  iso3_table['zh-zh-TW'] = 'zho'

  if outfile!="":
    fout = open(outfile, 'w')

  for country, langs in COUNTRY_NAME_TO_LANGS_TWO.iteritems():
    # prepare a tab-separatd string of "lang:percent"
    spoken_langs = []

    # Sort languages from most spoken to least
    sorted_langs = sorted(langs.iteritems(), 
                          key=operator.itemgetter(1),
                          reverse=True)

    # The result is a list - format it nicely
    for (lang_code, pcent) in sorted_langs:
      spoken_langs.append(
        "{0}: {1}%".format(code_to_name[iso3_table[lang_code]], pcent)) 

    # Now add the first alternative for country name 
    langs_string = country[0] + "\t" + ", ".join(spoken_langs)

    if outfile=="":
      print langs_string
    else:
      #write to file
      fout.write(langs_string + "\n")

  if outfile!="":
    fout.close()

    
if __name__ == "__main__":
  print_country_to_langs_mapping(outfile=OUTPUT_FILENAME)

