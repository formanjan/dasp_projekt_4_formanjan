Název souboru, který obsahuje veškeré skripty a odpovědi na jednom místě: dasp_projekt_4_formanjan

Soubor v první části obsahuje pomocné skripty a následně přechází k produktivním skriptům, které zpracovávají zadání.

Pomocné skripty:
> -- POMOCNÉ | PRÁVA UŽIVATELE
> -- POMOCNÉ | ANALÝZA A PŘÍPRAVA ZDROJOVÝCH DAT S UNION ALL
> -- POMOCNÉ | SELECT NA TABULKU, KTERÁ BUDE FINÁLNÍM KÓDEM VYTVOŘENA POMOCÍ CREATE

Tato část je oddělena bannerem níže.

-- ------------------------------------------------------------------------------------------------------------
-- ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓  F I N Á L N Í  S K R I P T Y  K  O D E V Z D Á N Í  ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
-- ------------------------------------------------------------------------------------------------------------

Pod tímto bannerem jsou skripty, které jsou určeny k hodnocení za účelem splnění/nesplnění projektu

Skripty, na které se odkazují hlavní dva skripty vytvářející finální tabulky:
> -- PŘÍPRAVA PRO HLAVNÍ KÓD (t_jan_forman_project_SQL_primary_final) OPRAVA CZECHIA_PAYROLL_UNIT "v_jf12_corrected_czechia_payroll_unit"
> -- PŘÍPRAVA PRO HLAVNÍ KÓD (t_jan_forman_project_SQL_primary_final) SPOLEČNÉ ROKY "v_jf12_spol_roky"


Hlavní skripty:
> -- FINÁLNÍ HLAVNÍ KÓD K ODEVZDÁNÍ 1/2 (t_jan_forman_project_SQL_primary_final)
> -- FINÁLNÍ HLAVNÍ KÓD K ODEVZDÁNÍ 2/2 (t_jan_forman_project_SQL_secondary_final)


Dále pokračují skripty pro zodpovězení výzkumných otázek. Odpovědi jsou součástí skriptů na konci.
> -- OTÁZKA 1: Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
> -- OTÁZKA 2: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
> -- OTÁZKA 3: Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
> -- OTÁZKA 4: Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
> -- OTÁZKA 5: Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?


Odpovědi:
>> ODPOVĚĎ 1: Ve sledovaném období 2006-2018 rostou dlouhodobě mzdy ve všech sledovaných odvětvích. TOP 3 odvětví z pohledu tempa růstu mezd jsou Zdravotní a sociální péče, Zpracovatelský průmysl a Zemědělství, lesnictví, rybářství. Naopak nejpomaleji roste mzda v odvětví Peněžnictví a pojišťovnictví, které je však v roce 2018 druhým odvětvím s nejvyšší průměrnou měsíční mzdou.

>> ODPOVĚĎ 2: V roce 2006 bylo možné za tehdejší průměrnou měsíční mzdu pořídit 1313,0 ks 1kg chleba a 1465,7 l mléka.
Spolu s cenou potravin rostla také průměrná měsíční mzda a v roce 2018 bylo možné pořídit o 52,2 ks 1kg chleba a o 203,9 l mléka více.

>> ODPOVĚĎ 3: Nejpomaleji zdražující kategorií potravin jsou banány, které zdražují průměrně o 0,8 % ročně. Ve sledovaném období byl zaznamenán i opačný trend a to u dvou kategorií potravin, kterými jsou cukr a rajčata. Cukr s průměrným tempem rústu -1,9 % ročně je tak v relevantním srovnání čím dál dostupnější surovinou.

>> ODPOVĚĎ 4: Ve sledovaném období nedošlo k tomu, že by meziroční nárůst cen potravin dosáhl tempa o více jak 10 % oproti růstu mezd. Nejvyšší rozdíl v kladném tempu růstu cen potravin oproti růstu mezd byl v roce 2013, kdy byl rozdíl 6,7 %.

>> ODPOVĚĎ 5: Ve sledovaném období nebyla prokázána jednoznačná korelace mezi změnou HDP a vývojem cen a mezd. Obě oblasti jsou ve vztahu k HDP v středné silné kladné korelaci.

