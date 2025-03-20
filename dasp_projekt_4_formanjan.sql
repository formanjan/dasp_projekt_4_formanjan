-- POMOCNÉ | PRÁVA UŽIVATELE
-- Zobrazí práva pro uživatele, který příkaz spouští
show grants for current_user() 

;


-- POMOCNÉ | ANALÝZA A PŘÍPRAVA ZDROJOVÝCH DAT S UNION ALL

-- Pomocná tabulka - Payroll
select cp.id, "Mzdy" zdroj, /*cp.value_type_code,*/ cpvt.name value_type_name, /*cp.calculation_code,*/ cpc.name calculation_name, cp.value, 
"" price_value, /*cp.unit_code,*/ vjccpu.name unit_name,
/*"" region_code, "" region_name, cp.industry_branch_code,*/ cpib.name industry_branch_name,
cp.payroll_year, cp.payroll_quarter /*, "" date_from, "" date_to*/

from czechia_payroll cp
left join czechia_payroll_calculation cpc 				on cp.calculation_code = cpc.code 
left join czechia_payroll_industry_branch cpib 			on cp.industry_branch_code = cpib.code 
left join czechia_payroll_value_type cpvt  				on cp.value_type_code = cpvt.code
-- czechia_payroll_unit měla chybu, tak jsem vytvořil korekturované VIEW
left join v_jf12_corrected_czechia_payroll_unit vjccpu 	on cp.unit_code = vjccpu.corrected_code

where cpc.code = "200" -- Zajímá mě pouze přepočtený stav na FTE.
and cpvt.code = "5958" -- Zajímají mě pouze mzdy, nikoliv počet ZAM.
and cp.industry_branch_code is not null -- Nezajímá mě mzda, pokud nemám informace, do kterého odvětví patří.
and cp.value is not null -- Pokud bude hodnota prázdná, tak mě záznam nezajímá.

union all

-- Pomocná tabulka - Price
select cp.id, "Ceny" zdroj, /*cp.category_code,*/ cpc.name category_name, /*"" calculation_code,*/ "" calculation_name, cp.value,
cpc.price_value, /*"" unit_code,*/ cpc.price_unit, 
/*cp.region_code, cr.name region_name, "" industry_branch_code,*/ "" industry_branch_name,
YEAR(cp.date_from) year, "" quarter/*, cp.date_from, cp.date_to*/ -- od-do je rok stejný, ale měsíc ne --> kvartál identifikovat 100% nejde (ne jednoduše)

from czechia_price cp
left join czechia_price_category cpc on cp.category_code = cpc.code 
left join czechia_region cr on cp.region_code = cr.code 

where cp.value is not null -- Pokud bude hodnota prázdná, tak mě záznam nezajímá.

;


-- POMOCNÉ | SELECT NA TABULKU, KTERÁ BUDE FINÁLNÍM KÓDEM VYTVOŘENA POMOCÍ CREATE

with spol_roky as (
    -- Určení společných let dynamicky
    select s.year
    from (
        select distinct payroll_year as year from czechia_payroll
        union all
        select distinct year(date_from) as year from czechia_price
    	 ) s
    group by s.year
    having count(*) = 2 -- Roky musí být přítomné v obou tabulkách
				   )

select m.zdroj, m.kategorie, ROUND(AVG(m.hodnota),2) prumerna_hodnota_czk, m.mnozstvi, m.jednotka, m.odvetvi, m.rok

from
(
-- Payroll
select "Mzdy" zdroj, cpvt.name kategorie, cp.value hodnota, "" mnozstvi, vjccpu.name jednotka,
cpib.name odvetvi, cp.payroll_year rok

from czechia_payroll cp
left join czechia_payroll_calculation cpc 				on cp.calculation_code = cpc.code 
left join czechia_payroll_industry_branch cpib 			on cp.industry_branch_code = cpib.code 
left join czechia_payroll_value_type cpvt  				on cp.value_type_code = cpvt.code
-- czechia_payroll_unit měla chybu, tak jsem vytvořil korekturované VIEW
left join v_jf12_corrected_czechia_payroll_unit vjccpu 	on cp.unit_code = vjccpu.corrected_code

where cpc.code = "200" -- Zajímá mě pouze přepočtený stav na FTE.
and cpvt.code = "5958" -- Zajímají mě pouze mzdy, nikoliv počet ZAM.
and cp.industry_branch_code is not null -- Nezajímá mě mzda, pokud nemám informace, do kterého odvětví patří.
and cp.value is not null -- Pokud bude hodnota prázdná, tak mě záznam nezajímá.

union all

-- Price
select "Ceny" zdroj, cpc.name kategorie, cp.value hodnota, cpc.price_value mnozstvi, cpc.price_unit jednotka, 
"" odvetvi, year(cp.date_from) rok

from czechia_price cp

left join czechia_price_category cpc on cp.category_code = cpc.code 
left join czechia_region cr on cp.region_code = cr.code 

where cp.value is not null -- Pokud bude hodnota prázdná, tak mě záznam nezajímá.
) m

where m.rok in (select year from spol_roky) -- Pouze společné roky
group by m.zdroj, m.kategorie, m.mnozstvi, m.jednotka, m.odvetvi, m.rok

;





-- ------------------------------------------------------------------------------------------------------------
-- ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓  F I N Á L N Í  S K R I P T Y  K  O D E V Z D Á N Í  ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
-- ------------------------------------------------------------------------------------------------------------


-- PŘÍPRAVA PRO HLAVNÍ KÓD (t_jan_forman_project_SQL_primary_final) OPRAVA CZECHIA_PAYROLL_UNIT
-- -------------------------------------------------------------------------------------------------------------
-- --------------------------------------------- P O Z O R -----------------------------------------------------
-- -------------------------------------------------------------------------------------------------------------
-- ------------------------------- R E Á L N Á  T V O R B A  V I E W -------------------------------------------
-- -------------------------------------------------------------------------------------------------------------
-- Vytvoří VIEW na korekci tabulky, kde jsou prohozené hodnoty

-- create view v_jf12_corrected_czechia_payroll_unit as -- zakomentování, ochrana před vytvořením tabulky omylem
select *,
    case
        when cpu.code = 80403 then 200
        when cpu.code = 200 then 80403
        else cpu.code
    end as corrected_code
from czechia_payroll_unit cpu

-- -------------------------------------------------------------------------------------------------------------
-- --------------------------------------------- P O Z O R -----------------------------------------------------
-- -------------------------------------------------------------------------------------------------------------
-- ------------------------------- R E Á L N Á  T V O R B A  V I E W -------------------------------------------
-- -------------------------------------------------------------------------------------------------------------

;





-- PŘÍPRAVA PRO HLAVNÍ KÓD (t_jan_forman_project_SQL_primary_final) SPOLEČNÉ ROKY
-- -------------------------------------------------------------------------------------------------------------
-- --------------------------------------------- P O Z O R -----------------------------------------------------
-- -------------------------------------------------------------------------------------------------------------
-- ------------------------------- R E Á L N Á  T V O R B A  V I E W -------------------------------------------
-- -------------------------------------------------------------------------------------------------------------
-- Vytvoří VIEW na zjištění společných let, protože MariaDB nerozumí kombinaci create .. as with

-- create view v_jf12_spol_roky as -- zakomentování, ochrana před vytvořením tabulky omylem
    -- Určení společných let dynamicky
    select s.year
    from (
        select distinct payroll_year as year from czechia_payroll
        union all
        select distinct year(date_from) as year from czechia_price
    	 ) s
    group by s.year
    having count(*) = 2 -- Roky musí být přítomné v obou tabulkách
    
-- -------------------------------------------------------------------------------------------------------------
-- --------------------------------------------- P O Z O R -----------------------------------------------------
-- -------------------------------------------------------------------------------------------------------------
-- ------------------------------- R E Á L N Á  T V O R B A  V I E W -------------------------------------------
-- -------------------------------------------------------------------------------------------------------------
;





-- FINÁLNÍ HLAVNÍ KÓD K ODEVZDÁNÍ 1/2 (t_jan_forman_project_SQL_primary_final)
-- -------------------------------------------------------------------------------------------------------------
-- --------------------------------------------- P O Z O R -----------------------------------------------------
-- -------------------------------------------------------------------------------------------------------------
-- ------------------------------- R E Á L N Á  T V O R B A  T A B L E -----------------------------------------
-- -------------------------------------------------------------------------------------------------------------
-- MariaDB nerozumí kombinaci s with, tak jsem si musel vytvořit pomocné VIEW

-- create table t_jan_forman_project_SQL_primary_final as -- zakomentování, ochrana před vytvořením tabulky omylem

select m.zdroj, m.kategorie, round(avg(m.hodnota),2) prumerna_hodnota_czk, m.mnozstvi, m.jednotka, m.odvetvi, m.rok

from
(
-- Payroll
select "Mzdy" zdroj, cpvt.name kategorie, cp.value hodnota, "" mnozstvi, vjccpu.name jednotka,
cpib.name odvetvi, cp.payroll_year rok

from czechia_payroll cp
left join czechia_payroll_calculation cpc 				on cp.calculation_code = cpc.code 
left join czechia_payroll_industry_branch cpib 			on cp.industry_branch_code = cpib.code 
left join czechia_payroll_value_type cpvt  				on cp.value_type_code = cpvt.code
-- czechia_payroll_unit měla chybu, tak jsem vytvořil korekturované VIEW
left join v_jf12_corrected_czechia_payroll_unit vjccpu 	on cp.unit_code = vjccpu.corrected_code

where cpc.code = "200" -- Zajímá mě pouze přepočtený stav na FTE.
and cpvt.code = "5958" -- Zajímají mě pouze mzdy, nikoliv počet ZAM.
and cp.industry_branch_code is not null -- Nezajímá mě mzda, pokud nemám informace, do kterého odvětví patří.
and cp.value is not null -- Pokud bude hodnota prázdná, tak mě záznam nezajímá.

union all

-- Price
select "Ceny" zdroj, cpc.name kategorie, cp.value hodnota, cpc.price_value mnozstvi, cpc.price_unit jednotka, 
"" odvetvi, YEAR(cp.date_from) rok

from czechia_price cp
left join czechia_price_category cpc					on cp.category_code = cpc.code 
left join czechia_region cr 							on cp.region_code = cr.code 

where cp.value is not null -- Pokud bude hodnota prázdná, tak mě záznam nezajímá.
) m

where m.rok in (select year from v_jf12_spol_roky) -- Pouze společné roky
group by m.zdroj, m.kategorie, m.mnozstvi, m.jednotka, m.odvetvi, m.rok

-- -------------------------------------------------------------------------------------------------------------
-- --------------------------------------------- P O Z O R -----------------------------------------------------
-- -------------------------------------------------------------------------------------------------------------
-- ------------------------------- R E Á L N Á  T V O R B A  T A B L E -----------------------------------------
-- -------------------------------------------------------------------------------------------------------------

;





-- FINÁLNÍ HLAVNÍ KÓD K ODEVZDÁNÍ 2/2 (t_jan_forman_project_SQL_secondary_final)
-- -------------------------------------------------------------------------------------------------------------
-- --------------------------------------------- P O Z O R -----------------------------------------------------
-- -------------------------------------------------------------------------------------------------------------
-- ------------------------------- R E Á L N Á  T V O R B A  T A B L E -----------------------------------------
-- -------------------------------------------------------------------------------------------------------------

-- create table t_jan_forman_project_SQL_secondary_final as -- zakomentování, ochrana před vytvořením tabulky omylem

select c.iso2 iso_kod, e.country zeme, e.year rok, e.GDP hdp_czk, round((e.gdp/1000000000),2) hdp_mld_czk, e.gini, e.population populace

from economies e
left join countries c on c.country = e.country 

where c.continent = "Europe"
and e.year in (select year from v_jf12_spol_roky) -- Pouze společné roky

order by e.year

-- -------------------------------------------------------------------------------------------------------------
-- --------------------------------------------- P O Z O R -----------------------------------------------------
-- -------------------------------------------------------------------------------------------------------------
-- ------------------------------- R E Á L N Á  T V O R B A  T A B L E -----------------------------------------
-- -------------------------------------------------------------------------------------------------------------

;





-- ######################################### Výzkumné otázky #########################################

-- OTÁZKA 1: Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
select concat(min(rok),"-",max(rok)) obdobi, odvetvi, 
round(((max(case when rok = (select max(rok) from t_jan_forman_project_SQL_primary_final) then prumerna_hodnota_czk end) -
        max(case when rok = (select min(rok) from t_jan_forman_project_SQL_primary_final) then prumerna_hodnota_czk end)) /
        max(case when rok = (select min(rok) from t_jan_forman_project_SQL_primary_final) then prumerna_hodnota_czk end)) * 100, 1) zmena_pct,
repeat('*', round(((max(case when rok = (select max(rok) from t_jan_forman_project_SQL_primary_final) then prumerna_hodnota_czk end) -
                    max(case when rok = (select min(rok) from t_jan_forman_project_SQL_primary_final) then prumerna_hodnota_czk end)) /
                    max(case when rok = (select min(rok) from t_jan_forman_project_SQL_primary_final) then prumerna_hodnota_czk end)) * 10)) vizualizace,
max(case when rok = (select min(rok) from t_jan_forman_project_SQL_primary_final) then prumerna_hodnota_czk end) prvni_prumerna_hodnota,
max(case when rok = (select max(rok) from t_jan_forman_project_SQL_primary_final) then prumerna_hodnota_czk end) posledni_prumerna_hodnota,
(max(case when rok = (select max(rok) from t_jan_forman_project_SQL_primary_final) then prumerna_hodnota_czk end) -
 max(case when rok = (select min(rok) from t_jan_forman_project_SQL_primary_final) then prumerna_hodnota_czk end)) zmena_czk


from t_jan_forman_project_SQL_primary_final

where zdroj = 'Mzdy' -- zajištění, že analyzujeme pouze mzdy

group by odvetvi

order by zmena_pct desc;

/* ODPOVĚĎ 1: Ve sledovaném období 2006-2018 rostou mzdy ve všech sledovaných odvětvích. TOP 3 odvětví z pohledu tempa růstu mezd jsou Zdravotní a sociální péče,
   Zpracovatelský průmysl a Zemědělství, lesnictví, rybářství. Naopak nejpomaleji roste mzda v odvětví Peněžnictví a pojišťovnictví, které je však v roce 2018
   druhým odvětvím s nejvyšší průměrnou měsíční mzdou.*/

;


-- OTÁZKA 2: Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
with
avg_mzda as (
			 select rok, round(avg(prumerna_hodnota_czk),1) prumerna_mzda
		     from t_jan_forman_project_SQL_primary_final
		     where kategorie = 'Průměrná hrubá mzda na zaměstnance'
		     group by rok
		    ),

ceny 	 as (
			 select rok, kategorie, prumerna_hodnota_czk cena
			 from t_jan_forman_project_SQL_primary_final
			 where kategorie in ('Mléko polotučné pasterované', 'Chléb konzumní kmínový')
			)

-- Spojíme data o mzdách a cenách a vypočítáme množství, které lze koupit
select c.rok, c.kategorie, m.prumerna_mzda, c.cena,
case when c.kategorie = 'Mléko polotučné pasterované' then round(m.prumerna_mzda / c.cena, 1)
     when c.kategorie = 'Chléb konzumní kmínový' 	  then round(m.prumerna_mzda / c.cena, 1)
end mnozstvi_ke_koupi
    
from ceny c
inner join avg_mzda m on c.rok = m.rok

-- Omezíme výstup na první a poslední srovnatelné období
where c.rok in ((select min(rok) from t_jan_forman_project_SQL_primary_final),
				(select max(rok) from t_jan_forman_project_SQL_primary_final))
				
order by c.kategorie, c.rok

/* ODPOVĚĎ 2: V roce 2006 bylo možné za tehdejší průměrnou měsíční mzdu pořídit 1313,0 ks 1kg chlebů a 1465,7 l mléka.
   Spolu s cenou potravin rostla také průměrná měsíční mzda a v roce 2018 bylo možné pořídit o 52,2 ks 1kg chleba a o 203,9 l mléka více.*/

;


-- OTÁZKA 3: Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
-- Má problém s with, tak to udělám přes sub-selecty
select x.kategorie, round(avg(x.narust_pct),1) prumerny_narust_pct
    
from (
	    select kategorie, rok, prumerna_hodnota_czk,
	    lag(prumerna_hodnota_czk) over (partition by kategorie order by rok) predchozi_hodnota,
	    (prumerna_hodnota_czk - lag(prumerna_hodnota_czk) over (partition by kategorie order by rok)) / 
	    lag(prumerna_hodnota_czk) over (partition by kategorie order by rok) * 100 narust_pct
	   
	    from t_jan_forman_project_SQL_primary_final
	    
	    where zdroj = 'Ceny'
	) x

group by x.kategorie

order by prumerny_narust_pct

/* ODPOVĚĎ 3: Nejpomaleji zdražující potravinou jsou banány, které zdražují průměrně o 0,8 % ročně. Ve sledovaném období byl zaznamenán
   i opačný trend a to u dvou kategorií potravin, kterými jsou cukr a rajčata. Cukr s průměrným tempem rústu -1,9 % ročně je tak
   v relevantním srovnání čím dál dostupnější surovinou.*/

;



-- OTÁZKA 4: Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
-- Má problém s with, tak to udělám přes sub-selecty
select y.rok, round(y.narust_cen,1) narust_cen_pct, round(y.narust_mezd,1) narust_mezd_pct, round((y.narust_cen-y.narust_mezd),1) rozdil_tempa

from (
    -- Výpočet meziročního nárůstu cen potravin
	  select c.rok,
		       (c.prumerna_cena - lag(c.prumerna_cena) over (order by c.rok)) / 
		       lag(c.prumerna_cena) over (order by c.rok) * 100 narust_cen,
		       (m.prumerna_mzda - lag(m.prumerna_mzda) over (order by m.rok)) / 
		       lag(m.prumerna_mzda) over (order by m.rok) * 100 narust_mezd
	  from (
	        -- Výpočet průměrné ceny potravin dle roku
	        select rok, 
	               avg(prumerna_hodnota_czk) as prumerna_cena
	        from t_jan_forman_project_SQL_primary_final
	        where zdroj = 'Ceny'
	        group by rok
	       ) c
	  inner join (
			        -- Výpočet průměrné mzdy dle roku
			        select rok, avg(prumerna_hodnota_czk) prumerna_mzda
			        from t_jan_forman_project_SQL_primary_final
			        where zdroj = 'Mzdy'
			        group by rok
			      ) m on c.rok = m.rok

	) y
-- where y.narust_cen > y.narust_mezd + 10
order by rozdil_tempa desc 

 /* ODPOVĚĎ 4: Ve sledovaném období nedošlo k tomu, že by meziroční nárůst cen potravin dosáhl tempa o více jak 10 % oproti růstu mezd.
    Nejvyšší rozdíl v tempu růstu cen potravin oproti růstu mezd byl v roce 2013, kdy byl rozdíl 6,7 %.*/

;



-- OTÁZKA 5: Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
-- 			 projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

-- POMOCNÝ SKRIPT, KTERÝ POUŽIJU V DALŠÍM KROKU
select
    y.rok,
    round(y.narust_cen, 1) as narust_cen_pct,
    round(y.narust_mezd, 1) as narust_mezd_pct,
    round(y.hdp_narust, 1) as hdp_narust_pct
from (
    -- Výpočet meziročního nárůstu cen, mezd a HDP
    select 
        c.rok,
        (c.prumerna_cena - lag(c.prumerna_cena) over (order by c.rok)) / 
        lag(c.prumerna_cena) OVER (ORDER BY c.rok) * 100 as narust_cen,
        
        (m.prumerna_mzda - lag(m.prumerna_mzda) over (order by m.rok)) / 
        lag(m.prumerna_mzda) OVER (ORDER BY m.rok) * 100 as narust_mezd,
        
        (g.hdp_mld_czk - lag(g.hdp_mld_czk) over (order by g.rok)) / 
        lag(g.hdp_mld_czk) over (order by g.rok) * 100 as hdp_narust,
        
        ((c.prumerna_cena - lag(c.prumerna_cena) over (order by c.rok)) / 
        lag(c.prumerna_cena) over (order by c.rok) * 100) - 
        ((m.prumerna_mzda - lag(m.prumerna_mzda) over (order by m.rok)) / 
        lag(m.prumerna_mzda) over (order by m.rok) * 100) as rozdil_tempa
    from (
        -- Výpočet průměrné ceny potravin dle roku
        select 
            rok, 
            avg(prumerna_hodnota_czk) as prumerna_cena
        from t_jan_forman_project_SQL_primary_final
        where zdroj = 'Ceny'
        group by rok
    ) c
    inner join (
        -- Výpočet průměrné mzdy dle roku
        select 
            rok, 
            avg(prumerna_hodnota_czk) as prumerna_mzda
        from t_jan_forman_project_SQL_primary_final
        where zdroj = 'Mzdy'
        group by rok
    ) m on c.rok = m.rok
    inner join (
        -- Výpočet meziročního nárůstu HDP
        select 
            rok, 
            hdp_mld_czk
        from t_jan_forman_project_SQL_secondary_final
        where iso_kod = 'CZ'
        ) g on c.rok = g.rok
) y
-- where y.hdp_narust > 10 -- Například, můžu filtrovat roky s výrazným růstem HDP
order by y.rok;


-- SKRIPT_1 NA ZÍSKÁNÍ ODPOVĚDI (TŘEBA DALŠÍ ANALÝZY Z TABULKY)
with HDP_A_CENY_MZDY as (
    select 
        y.rok,
        round(y.narust_cen, 1) as narust_cen_pct,
        round(y.narust_mezd, 1) as narust_mezd_pct,
        round(y.hdp_narust, 1) as hdp_narust_pct,
        -- Hodnocení vztahu ve stejném roce CENY
        case 
            when y.hdp_narust > 0 and y.narust_cen > 0 then 'stejné'
            when y.hdp_narust <= 0 and y.narust_cen <= 0 then 'stejné'
            else 'opačné'
        end as vztah_stejny_rok_ceny,
        -- Hodnocení vztahu v následujícím roce (LAG pro předchozí rok HDP) CENY
        case 
            when lag(y.hdp_narust) over (order by y.rok) > 0 and y.narust_cen > 0 then 'stejné'
            when lag(y.hdp_narust) over (order by y.rok) <= 0 and y.narust_cen <= 0 then 'stejné'
            else 'opačné'
        end as vztah_nasledujici_rok_ceny,
        
        -- Hodnocení vztahu ve stejném roce MZDY
        case 
            when y.hdp_narust > 0 and y.narust_mezd > 0 then 'stejné'
            when y.hdp_narust <= 0 and y.narust_mezd <= 0 then 'stejné'
            else 'opačné'
        end as vztah_stejny_rok_mzdy,
        
        -- Hodnocení vztahu v následujícím roce (LAG pro předchozí rok HDP) MZDY
        case 
            when LAG(y.hdp_narust) over (order by y.rok) > 0 and y.narust_mezd > 0 then 'stejné'
            when LAG(y.hdp_narust) over (order by y.rok) <= 0 and y.narust_mezd <= 0 then 'stejné'
            else 'opačné'
        end as vztah_nasledujici_rok_mzdy
        
    from (
        -- Výpočet meziročního nárůstu cen, mezd a HDP
        select 
            c.rok,
            (c.prumerna_cena - lag(c.prumerna_cena) over (order by c.rok)) / 
            lag(c.prumerna_cena) over (order by c.rok) * 100 as narust_cen,
            
            (m.prumerna_mzda - lag(m.prumerna_mzda) over (order by m.rok)) / 
            lag(m.prumerna_mzda) over (order by m.rok) * 100 as narust_mezd,
            
            (g.hdp_mld_czk - lag(g.hdp_mld_czk) over (order by g.rok)) / 
            lag(g.hdp_mld_czk) over (order by g.rok) * 100 as hdp_narust
        from (
            -- Výpočet průměrné ceny potravin dle roku
            select 
                rok, 
                avg(prumerna_hodnota_czk) as prumerna_cena
            from t_jan_forman_project_SQL_primary_final
            where zdroj = 'Ceny'
            group by rok
        ) c
        inner join (
            -- Výpočet průměrné mzdy dle roku
            select 
                rok, 
                avg(prumerna_hodnota_czk) as prumerna_mzda
            from t_jan_forman_project_SQL_primary_final
            where zdroj = 'Mzdy'
            group by rok
        ) m on c.rok = m.rok
        inner join (
            -- Výpočet meziročního nárůstu HDP
            select 
                rok, 
                hdp_mld_czk
            from t_jan_forman_project_SQL_secondary_final
            where iso_kod = 'CZ'
        ) g on c.rok = g.rok
    ) y
)
select 
    rok,
    narust_cen_pct,
    narust_mezd_pct,
    hdp_narust_pct,
    vztah_stejny_rok_ceny,
    vztah_nasledujici_rok_ceny,
    vztah_stejny_rok_mzdy,
    vztah_nasledujici_rok_mzdy
from HDP_A_CENY_MZDY
order by rok;


-- SKRIPT_2 NA ZÍSKÁNÍ ODPOVĚDI (JASNÝ VÝSLEDEK O VZTAHOVOSTI)
with Data as (
    select 
        y.rok,
        y.narust_cen AS narust_cen_pct,
        y.narust_mezd AS narust_mezd_pct,
        y.hdp_narust AS hdp_narust_pct
    from (
        select 
            c.rok,
            (c.prumerna_cena - lag(c.prumerna_cena) over (order by c.rok)) / 
            lag(c.prumerna_cena) over (order by c.rok) * 100 as narust_cen,
            
            (m.prumerna_mzda - lag(m.prumerna_mzda) over (order by m.rok)) / 
            lag(m.prumerna_mzda) over (order by m.rok) * 100 as narust_mezd,
            
            (g.hdp_mld_czk - lag(g.hdp_mld_czk) over (order by g.rok)) / 
            lag(g.hdp_mld_czk) over (order by g.rok) * 100 as hdp_narust
        from (
            select 
                rok, 
                avg(prumerna_hodnota_czk) as prumerna_cena
            from t_jan_forman_project_SQL_primary_final
            where zdroj = 'Ceny'
            group by rok
        ) c
        inner join (
            select 
                rok, 
                avg(prumerna_hodnota_czk) as prumerna_mzda
            from t_jan_forman_project_SQL_primary_final
            where zdroj = 'Mzdy'
            group by rok
        ) m on c.rok = m.rok
        inner join (
            select 
                rok, 
                hdp_mld_czk
            from t_jan_forman_project_SQL_secondary_final
            where iso_kod = 'CZ'
        ) g on c.rok = g.rok
    ) y
),
Korelacni_Cen as (
    select 
        sum((hdp_narust_pct - (select avg(hdp_narust_pct) from Data)) * 
            (narust_cen_pct - (select avg(narust_cen_pct) from Data))) / 
        (sqrt(sum(pow(hdp_narust_pct - (select avg(hdp_narust_pct) from Data), 2))) * 
         sqrt(sum(pow(narust_cen_pct - (select avg(narust_cen_pct) from Data), 2)))) as korelace_ceny
    from Data
),
Korelacni_Mzdy as (
    select 
        sum((hdp_narust_pct - (select avg(hdp_narust_pct) from Data)) * 
            (narust_mezd_pct - (select avg(narust_mezd_pct) from Data))) / 
        (sqrt(sum(pow(hdp_narust_pct - (select avg(hdp_narust_pct) from Data), 2))) * 
         sqrt(sum(pow(narust_mezd_pct - (select avg(narust_mezd_pct) from Data), 2)))) as korelace_mzdy
    from Data
)
select 
    (select korelace_ceny from Korelacni_Cen) as korelace_ceny,
    (select korelace_mzdy from Korelacni_Mzdy) as korelace_mzdy;
   
   
 /* ODPOVĚĎ 5: Ve sledovaném období nebyla prokázána jednoznačná korelace mezi změnou HDP a vývojem cen a mezd.
  * Obě oblasti jsou ve vztahu k HDP v středné silné kladné korelaci.*/


