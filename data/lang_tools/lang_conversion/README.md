Source files
************

ISO639-3 General:
Download page: http://www.sil.org/iso639-3/download.asp.
http://www.sil.org/iso639-3/iso-639-3_20120614.tab: stored locally as orig/iso-639-3_table_20120614.txt

ISO639-3 Macrolanguages:
http://www.sil.org/iso639-3/iso-639-3-macrolanguages_20120228.tab
http://www.sil.org/iso639-3/macrolanguages.asp (contains 7 langs missing from the download version): stored locally as iso-639-3_macro_table.txt


ISO-639-2: 
http://www.loc.gov/standards/iso639-2/php/code_list.php
http://www.loc.gov/standards/iso639-2/ascii_8bits.html (Download): UTF-8 version stored locally as orig/iso-639_2_table.txt

CLD language codes: orig/langcodes_twitter_cld.txt
Wikipedia language codes: orig/langcodes_wikipedia.txt

Conversion
***********

iso-639-3-20120726_conversion_nogeneric.txt: prepared 7/23/2012 using the ISO-639-3 files from above (6/14/2012 release)
All datasets were converted to macrolanguages before we started processing and analyzing them. 

Twitter and Wikipedia (roughly ISO639-1)
*********************

Twitter: CLD detects 205 languages, of which 86 feature in our Twitter data set.
Wikipedia: our dataset featured 284 language editions (actually, that's the number of languages on Bruno's conversion table)

Of the above:
145 languages are common to Twitter/CLD and Wikipedia. All are converted to 639-3, except for Bihari.
60 languages are on Twitter but not on Wikipedia. Of which, six (6) are converted to ISO639-3:
CLD_Code	CLD_Name	ISO639-3_Code	ISO639-3_Name
fil	TAGALOG	fil	Filipino
jw	JAVANESE	jav	Javanese (Macro)
kha	KHASI	kha	Khasi
nb	NORWEGIAN	nob	Norwegian Bokomal)
syr	SYRIAC	syr	Syriac (Macro)
zh-TW	ChineseT	zho	Chinese (Macro)

fil	TAGALOG -> fil	Filipino
jw	JAVANESE -> jav	Javanese
nb	NORWEGIAN -> Bokomal)
syr	SYRIAC
zh-TW	CHINESE (TRADITIONAL) -> Chinese (macrolanguge)


139 languages are on Wikipedia but not on Twitter:
Of which, the following 43 were converted: (TODO: add ISO639-3 code)
ak	Akan
an	Aragonese
arz	Egyptian Arabic
av	Avar
bm	Bambara
bat_smg	Samogitian
ce	Chechen
ch	Chamorro
cr	Cree
cu	Old Church Slavonic
cv	Chuvash
ee	Ewe
ff	Fula
ho	Hiri Motu
ig	Igbo
ii	Sichuan Yi
io	Ido
jv	Javanese
kg	Kongo
ki	Kikuyu
kj	Kuanyama
kr	Kanuri
kv	Komi
kw	Cornish
li	Limburgian
mh	Marshallese
ng	Ndonga
no	Norwegian
nv	Navajo
ny	Chichewa
os	Ossetian
pi	Pali
sc	Sardinian
se	Northern Sami
tl	Tagalog
ty	Tahitian
ve	Venda
wa	Walloon
zh_classical	Classical Chinese
zh_min_nan	Min Nan
zh_yue	Cantonese
roa_rup	Aromanian (Macedo-Romanian)
fiu_vro Võro


Macrolanguages
*******
Languages were consolidated to ISO639-3 macrolanguages, thus all variants of Chinese appear under "zho" ("Chinese"); all variants of Arabic under "ara" ("Arabic"), "Malay"etc. There are two notable additions: (1) Serbian, Croatian, and Bosnian were consolidated into "Serbo-Croatian" even though the latter had been deprecated as a macrolanguage; this is mostly because CLD cannot distinguish the written forms of the three languages. (2) Filipino ("fil" in CLD) and Tagalog ("tl" in Wikipedia) were merged into one Filipino language "fil" ("Filipino"), as they are essentially the same language.      


>>>>> IGNORE THE FOLLOWING -- this has been changed:
The following languages are merged at source level. They are converted like the rest:
id + ms -> msa	Malay (Macro)
zh + zh-TW (both listed as zh) - > zho	Chinese (Macro)	
hr + sr -> Serbo-Croatian-Bosnian (Macro)
>>>>> STOP IGNORING...

Conversion
**********
Twitter: of the 5/5/2012 stripped/90% certainty set, the following 9 languages were not converted:
'xx-Nkoo', 'xx-Copt', 'xx-Tfng', 'xxx', 'xx-Yiii', 'xx-Phnx', 'xx-Ogam', 'xx-Dsrt', 'xx-Runr'

TODO: Number of users/tweets before ...
Number of users/tweets after ...


Wikipedia
**********
Of the 6/12/2012 (data of processing, not retrieval!) set, the following 10 langs were not converted:

Notable languages that weren't converted are:
-be-x-old: classical orthography. The "Classical Belarusian" edition spawned from the "Official" one and has a few articles more, but also fewer views, so decided to go with new one. Seems like the same audience anyway. http://stats.wikimedia.org/EN/Sitemap.htm
-Simple English: not converted
-no 639-3: roa_tara, tokipona, bh, map_bms, nds_nl (a family individual ISO639-3 languages)
-Multiple dialects on ISO639-3 without a macrolanguage, cannot map to a specific variant: nah
-Spanish-Philipino Creole: cbk_zam
-Wikipedia no longer exists: hz

TODO: Number of users before/after...
Number of edits before/after...


Index Translationum
*******************
The following langs are not converted:

41 dialects that should be merged into the main languages:
fra-di, gsw-di, pdc-di, naq-di, udi-di, slv-di, tam-di, yuf-di, ron-di, lmo-di, wln-di, swb-di, kjh-di, lol-di, arg-di, ita-di, snp-di, eng-di, deu-di, rmy-di, uig-di, spa-di, sba-di, roh-di, ijs-di, vls-di, prv-di, yua-di, ubu-di, nld-di, dar-di, bar-di, hrv-di, gur-di, pcd-di, dak-di, mwp-di, iku-di, ara-di, ces-di, aoj-di

4 ISO639-3 generic codes were removed:
mis	uncoded languages
mul	multiple languages
und	undetermined languages
zxx	no linguistic content

1 code unique to the Index Translationum was removed:
not supplied

46 do not conform with ISO639-3. Altogether there are 680 translations from these languages (200 of which to "Catalan, Valencian") and 329 to these languages (229 to "Catalan, Valencian"). 
san-pr	Pankrit
cat-va	Catalan, Valencian
cat-ba	Catalan, Balear
-Many of these 46 languages are aggregations of unclassified languages that belong to the same group/region, e.g. 
afl	"African languages, other"
cai	"Central American Indian Languages (Other)" 
aka-fa, gev, gll, obe, obn, ocs, ogj, oha, opg, osw, rno, scm, ath, bnt, oit, ouz, nub, aka-as, ber, aus, cop-bo, nic, ouk, onl, sai, kbd-ch, ohy, gsw-al, ois, oct, nai, quiche, wen, cro , enga, gsc-ar, idn, mno, rho, smi

TODO: As a result, XXX translations to and YYY translations from were removed
