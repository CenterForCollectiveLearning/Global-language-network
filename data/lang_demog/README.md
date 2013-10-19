convert_country_gdp_to_lang.py: convert GDP by country to GDP by language (input is country_gdp_pop.tsv, output is language_gdp.tsv)

language_gdp_pop.tsv: GDP per capita (PPP) by language, along with aggregated number of speakers per language (for testing purposes) and population by language. Last two may differ.

language_gdp_pop_May.tsv: same as above, but with the data used for the May submission to Science. 

country_gdp_pop.tsv: GDP per capita (PPP) and population by country. Values were retrieved mostly from IMF (2011 values from April 2012 WEO), with additions from CIA world factbook (mostly 2011 factbook).

weo_april_2012_gdppcpp_pop.tsv: GDP and population by country (2010-2013) according to WEO April 2012. Includes country codes in ISO2 and ISO3. Note that not all population values overlap gdp_pop_combined.tsv.