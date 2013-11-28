To do:

0) VV Generate ppl table from Observatory (gln/data/cultural_production/get_observatory_tables.R)

1) Use ppl table from observatory:
VV Update country table to lang table (gln/data/lang_tools/country_to_lang/convert_country_to_lang_data.py)
VV Convert GDP to language (using the same script)
VV Combine population and GDP for language
-V Convert notablilty by country to lang
-V Calculate regressions for new people table. Remove English.
-V Re-do Fig 4 (correlations) WIKI
-V Update F-score in main text
-V Update total number of ppl in main text and SM
-V Tables 1 & 2 (regression) and corresponding text
VV Table S5 (gdp pc for langs)
VV Table S7
-V Tables S8-S11 (ppl by country and ppl by lang) WIKI ONLY
-V Tables S12-13 (alternative regression) WIKI ONLY

-- Updates online SOM tables: Added some countries to GDP-pop, changed lang conversion
-- Upload figures

REMOVED: Figure S3 (num people on "Wikipedia N" vs. N)


2) Robustness -- change network thresholds: 
-- Redo Fig 2-3
-- Tables S6 (EV cent. in networks)

3) Optional: 
VV !!NO!!: Consider: set a 5% minimum for conversion?
-- Use new mappings with filters ("2013-07-18_2", w/ higher min. expressions per user) 
-- Use the Murray entries matched with Wikipeida ("final_resolved_murray_4-16-2013_%s_%s_exports.tsv, imported from old net-langs repo)
-- Manually map Greece / Rome / Arab World to countries