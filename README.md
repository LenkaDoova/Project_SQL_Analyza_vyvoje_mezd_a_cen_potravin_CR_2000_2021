# Projekt z SQL - Životní úroveň obyvatelstva ČR v letech 2000 - 2021

## Shrnutí projektu

Cílem projektu bylo analyzovat vývoj mezd a cen potravin v České republice a posoudit jejich vliv na dostupnost základních potravin pro obyvatelstvo v letech 2000–2021. Analýza vychází z veřejně dostupných datových sad a zaměřuje se na porovnání kupní síly napříč odvětvími.

Výstupem projektu jsou dvě finální tabulky obsahující agregovaná data o mzdách, cenách potravin a makroekonomických ukazatelích. Na jejich základě je zodpovězeno pět výzkumných otázek týkajících se vývoje mezd, cen a jejich vztahu k HDP.

## Zadání projektu

Na vašem analytickém oddělení nezávislé společnosti, která se zabývá životní úrovní občanů, jste se dohodli, že se pokusíte odpovědět na pár definovaných výzkumných otázek, které adresují dostupnost základních potravin široké veřejnosti. Kolegové již vydefinovali základní otázky, na které se pokusí odpovědět a poskytnout tuto informaci tiskovému oddělení. Toto oddělení bude výsledky prezentovat na následující konferenci zaměřené na tuto oblast.  

Potřebují k tomu od vás připravit robustní datové podklady, ve kterých bude možné vidět porovnání dostupnosti potravin na základě průměrných příjmů za určité časové období.

Jako dodatečný materiál připravte i tabulku s HDP, GINI koeficientem a populací dalších evropských států ve stejném období, jako primární přehled pro ČR.  

*  **Výstupem** by měly být dvě tabulky v databázi, ze kterých se požadovaná data dají získat. Tabulky pojmenujte: *t_{jmeno}_{prijmeni}_project_SQL_primary_final* (pro data mezd a cen potravin za Českou republiku sjednocených na totožné porovnatelné období – společné roky) a *t_{jmeno}_{prijmeni}_project_SQL_secondary_final* (pro dodatečná data o dalších evropských státech ve stejném období, jako primární přehled pro ČR).

## Výzkumné otázky

- 1) Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
- 2) Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
- 3) Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)? 
- 4) Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd(větší než 10 %)?
- 5) Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

## Zdroje dat

* Datové sady pocházejí z Portálu otevřených dat ČR:

- czechia_payroll – Informace o mzdách v různých odvětvích za několikaleté období. 
- czechia_payroll_calculation – Číselník kalkulací v tabulce mezd.
- czechia_payroll_industry_branch – Číselník odvětví v tabulce mezd.
- czechia_payroll_unit – Číselník jednotek hodnot v tabulce mezd.
- czechia_payroll_value_type – Číselník typů hodnot v tabulce mezd.

- czechia_price – Informace o cenách vybraných potravin za několikaleté období. 
- czechia_price_category – Číselník kategorií potravin, které se vyskytují v našem přehledu.

* Číselníky sdílených informací o ČR:

- czechia_region – Číselník krajů České republiky dle normy CZ-NUTS 2.
- czechia_district – Číselník okresů České republiky dle normy LAU.

* Dodatečné tabulky:

- countries - Různé informace o zemích na světě, například hlavní město, měna, národní jídlo nebo průměrná výška populace.
- economies - HDP, GINI, daňová zátěž, atd. pro daný stát a rok.

## Omezení analýzy

- chybějící data o cenách potravin (2000–2005, 2019–2021)
- rozdílná granularita dat (kvartální vs. roční)
- omezený počet pozorování pro korelaci s HDP (úkol č. 5)

## Řešení projektu:

## Pořadí skriptů:


- 1) Script1 Tab1, Task1 Wage Decrease FV
- 2) Script2 Task2 Milk, Bread FV
- 3) Script3 Task3 Slowest Price Rate FV
- 4) Script4 Task4 Price Growth Over 10 Pct FV
- 5) Script5 Tab2, Task5 GDP FV

## Pořadí náhledů výsledků:

- 1) Output Task1
- 2) Output Task2 A
     Output Task2 B
- 3) Output Task3
- 4) Output Task4
- 5) Output Task5


## Vytvoření dvou základních tabulek:

- A) Vytvoření společné tabulky k 1.-4. úkolu: *t_{jmeno}_{prijmeni}_project_SQL_primary_final*

* Průměrné ceny sledovaných potravin:

Spojení tabulek *czechia_price* a *czechia_price_category* inner joinem pro propojení kódů s konkrétními názvy jednotlivých potravin. Zde bylo třeba získat průměrnou cenu každé potraviny za rok bez ohledu na jejich granularitu (cena potravin byla sledována v jednotlivých regionech ČR v odlišných časových úsecích, zpravidla několika týdenních). Tabulka s cenami byla též normalizována tak, aby došlo ke sjednocení cen kategorií přibližně za 1 kg a 1 l (viz např. cena 1 vejce velikosti M-L byla standardizována na 0,06 kg). Ceny kategorií byly sledovány většinou za období 2006-2018, s výjimkou jakostního vína (2015-2018). Tabulka nazvána *t_prices_norm*. 

* Průměrné mzdy v jednotlivých obdobích:

Spojení tabulky *czechia_payroll* a *czechia_payroll_industry_branch* inner joinem pro propojení kódů s konkrétními názvy jednotlivých odvětví. V tabulce byla ponechána pouze data týkající se mezd a odstraněna granularita dat na úrovni kvartálů. Mzdy byly sledovány za období 2000-2021. Tabulka nazvána *t_wages*.

* Finální tabulka k 1.-4. úkolu:

K průměrné roční mzdě každého odvětví (sloupce *year*, *industry*, *avg_wage*) byla left joinem připojena tabulka průměrných ročních cen potravin (sloupce *year*, *food*, *avg_price_norm*).

- B) Vytvoření společné tabulky k 5. úkolu: *t_{jmeno}_{prijmeni}_project_SQL_secondary_final*

* Spojení tabulek *economies* a *countries* inner joinem (sloupce *year*, *country*, *gdp*, *gini*, *population*), dále selekce evropských zemí dle sloupce *continent* a omezení na období odpovídající sledování mezd a cen potravin (2000-2021, resp. do r. 2020, neboť v tabulce *economies* jsou sledované hodnoty uváděné pouze do r. 2020).

Tato tabulka byla inner joinem připojena k tabulkám *t_wages* a *t_prices_norm*

## ÚKOL 1) Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

### Postup:

- v tabulce byla užita Window Function LAG() pro získání průměrné roční loňské mzdy
- získán zaokrouhlený procentuální rozdíl mezi aktuální a loňskou mzdou
- ošetřen případ dělení nulou
- za pomocí CASE získány roky a odvětví, v nichž průměrné roční mzdy klesaly

### Shrnutí výsledků:
* Pokles průměrné roční mzdy se týkal celkem 30 případů:
- tří odvětví v r. 2009 (Těžba a dobývání; Ubytování, stravování a pohostinství; Zemědělství, lesnictví, rybářství)
- tří odvětví v r. 2010 (Profesní, vědecké a technické činnosti; Veřejná správa a obrana; Vzdělávání)
- tří odvětví v r. 2011 (Kulturní, zábavní a rekreační činnosti; Ubytování, stravování a pohostinství a opět druhý rok za sebou Veřejná správa a obrana)
- **nejhorší období poklesu mezd/platů je spojeno s r. 2013, který se negativně dotkl 11 odvětví (Administrativní a podpůrné činnosti; Činnosti v oblasti nemovitostí; Informační a komunikační činnosti; Kulturní, zábavní a rekreační činnosti; Peněžnictví a pojišťovnictví; Profesní, vědecké a technické činnosti; Stavebnictví; Těžba a dobývání; Velkoobchod a maloobchod; Výroba a rozvod elektřiny, plynu, tepla a klimatiz. vzduchu; Zásobování vodou; činnosti související s odpady a sanacemi)**
- v r. 2014 pokles mezd pokračoval pouze v jediném odvětví (Těžba a dobývání) 
- v r. 2015 zasáhl též jediný sektor (Výroba a rozvod elektřiny, plynu, tepla a klimatiz. vzduchu) 
- v r. 2016 (Těžba a dobývání) 
- r. 2020 zasáhl negativně jen 2 sektory (Činnosti v oblasti nemovitostí a Ubytování, stravování a pohostinství)
- **druhým nejhorším období na pokles mezd/platů byl r. 2021, který se dotkl 5 odvětví (Kulturní, zábavní a rekreační činnosti; Stavebnictví; Veřejná správa a obrana; Vzdělávání; Zemědělství, lesnictví, rybářství)**

## ÚKOL 2) Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

### Postup:
- v tabulce byly užity Window Functions MIN(), MAX(), FIRST_VALUE(), LAST_VALUE(), tyto analytické funkce byly využity pro získání nejstaršího a nejmladšího sledovaného roku průměrných cen a mezd (2006-2018) s přihlédnutím k faktu, že sledování průměrné ceny jakostního vína probíhalo pouze v letech 2015-2018

### Shrnutí výsledků
* Průměrná cena mléka v r. 2006 byla 14,44 Kč, chléb stál 16,12 Kč. Zaměstnanci nejlépe placeného sektoru (Peněžnictví a pojišťovnictví) si v tomto roce mohli zakoupit 2749 l mléka a 2461,6 kg chleba. Zaměstnanci nejhůře placeného sektoru (Ubytování, stravování a pohostinství) si v tomto roce mohli zakoupit 788,9 l mléka a 706,4 kg chleba.  

Průměrná cena mléka v r. 2018 činila 19,82 Kč, chléb stál 24,24 Kč. Zaměstnanci nejlépe placeného sektoru (Informační a komunikační činnosti) si v tomto roce mohli zakoupit 2830,9 l mléka a 2314,6 kg chleba. Zaměstnanci nejhůře placeného sektoru (opět Ubytování, stravování a pohostinství) si v tomto roce mohli zakoupit 947,1 l mléka a 774,4 kg chleba. 

## ÚKOL 3) Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?

### Postup:

- v tabulce byla užita Window Function LAG() pro získání průměrné roční loňské ceny potravin, dále analytické funkce MIN(), MAX(), FIRST_VALUE(), LAST_VALUE() byly využity pro získání nejstaršího a nejmladšího sledovaného roku průměrných cen
- získán zaokrouhlený procentuální rozdíl mezi aktuální a loňskou cenou
- ošetřen případ dělení nulou
- CASE byl použit pro porovnání ceny s předchozím rokem
- *Funkce POWER() byla užita pro získání meziročního průměrného růstu cen (CAGR - Compound Annual Growth Rate) všech potravin*
- Window Function DENSE_RANK() seřadila potraviny dle nejnižší hodnoty CAGR

### Shrnutí výsledků:
* Nejpomaleji rostoucí cena byla přiřazena *cukru krystalovému* (- 0,026) za sledované období r. 2006-2018, kdy původní cena klesla z 21,73 Kč na 15,75 Kč.

## ÚKOL 4) Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

### Postup:

- v tabulce byla užita Window Function LAG() pro získání průměrných ročních loňských mezd a cen potravin 
- získán zaokrouhlený procentuální rozdíl mezi aktuální a loňskou mzdou a cenou
- ošetřen případ dělení nulou

### Shrnutí výsledků:

* V žádném ze sledovaných roků nebyl rozdíl cen potravin vyšší o 10% nežli růst mezd.
(Nejvíce se tomuto trendu přiblížil r. 2013, kdy cena potravin převýšila mzdy o 7,22%.)

## ÚKOL 5) Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

### Postup:

- v tabulce byla užita Window Function LAG() a LEAD() pro získání předchozích a následujících hodnot HDP pro ČR 
- získán zaokrouhlený procentuální rozdíl mezi aktuální a loňskou hodnotou HDP
- ošetřen případ dělení nulou
- výraznější růst HDP stanoven od 3%
- pro korelaci není dostatečné množství dat (2000-2006 NULL hodnoty pro průměrné ceny potravin, totéž od r. 2019 do 2021)

### Shrnutí výsledků:

* analýza neprokázala jednoznačný vztah mezi růstem HDP a růstem mezd či cen potravin. Růst mezd sice s HDP částečně koreluje, ale bez výrazné závislosti a často se zpožděním. U cen potravin se žádná systematická vazba neprokázala. Výsledky naznačují, že na vývoj mezd a zejména cen potravin působí i další faktory mimo HDP

## Závěr/Shrnutí projektu:

Projekt se zaměřuje na analýzu vývoje mezd a cen potravin v České republice v letech 2000–2021 s cílem posoudit změny kupní síly obyvatelstva. Na základě integrace a úpravy dat z více zdrojů (Portál otevřených dat ČR) byly vytvořeny dvě finální tabulky, které sloužily jako podklad pro zodpovězení pěti výzkumných otázek. Analýza ukázala, že mzdy ve většině odvětví dlouhodobě rostly, avšak v některých obdobích docházelo k jejich poklesu, zejména kolem roku 2013. Kupní síla se mezi lety 2006 a 2018 mírně zlepšila, přestože ceny základních potravin rostly. Nejpomalejší růst cen byl zaznamenán u cukru, jehož cena dokonce v průměru klesala. Nebyl identifikován žádný rok, kdy by růst cen potravin výrazně převýšil růst mezd o více než 10 %. Analýza rovněž neprokázala jednoznačný vztah mezi vývojem HDP a změnami mezd či cen potravin, což naznačuje vliv dalších ekonomických faktorů. Celkově projekt poskytuje ucelený pohled na vývoj životní úrovně v ČR a zároveň upozorňuje na limity dostupných dat.
