To do:

0) VV Generate ppl table from Observatory (gln/data/cultural_production/get_observatory_tables.R)

1) Use ppl table from observatory:
VV Convert country table to lang table (gln/data/lang_tools/country_to_lang/convert_country_to_lang_data.py)
VV Convert GDP to language (using the same script)
VV NO!: Consider: set a 5% minimum for conversion?
VV Combine population and GDP for language
VV Calculate regressions for new people table. Remove English.
VV Re-do Fig 4 (correlations)
VV Tables 1 & 2 (regression)
VV Table S5 (gdp pc for langs)
-- Table S7
-- Tables S8-S11 (ppl by country and ppl by lang)
VV Tables S12-14 (alternative regression)
VV Figure S3 (num people on "Wikipedia N" vs. N)
-- Updates online SOM tables: Added some countries to GDP-pop  


2) Robustness -- change network thresholds: 
-- Redo Fig 2-3
-- Tables S6 (EV cent. in networks)

3) Optional: 
-- Use new mappings with filters ("2013-07-18_2", w/ higher min. expressions per user) 
-- Use the Murray entries matched with Wikipeida ("final_resolved_murray_4-16-2013_%s_%s_exports.tsv, imported from old net-langs repo)
-- Manually map Greece / Rome / Arab World to countries