--Jako dodatečný materiál připravte i tabulku s HDP, GINI koeficientem a populací dalších evropských států ve stejném období, jako primární přehled pro ČR.
--  t_{jmeno}_{prijmeni}_project_SQL_secondary_final


CREATE TABLE t_economies_countries AS
SELECT 
	e.year AS year_E, 
	e.country,
	e.gdp,
	e.gini,
	c.population
FROM economies e 
JOIN countries c ON e.country = c.country
WHERE c.continent = 'Europe' AND e.year BETWEEN 2000 AND 2021
ORDER BY year_E; 

-- SLOUČENÍ S TABULKAMI CEN A MEZD:

CREATE TABLE t_Lenka_Doova_project_SQL_secondary_final AS 
SELECT * FROM t_wages tw
LEFT JOIN t_prices_norm tpn ON tw.year_W = tpn.year_P
JOIN t_economies_countries tec ON tw.year_W = tec.year_E;


-- 5) Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?

WITH cte_gdp AS (
SELECT 
	year_W, 
	country, 
	AVG(gdp) AS gdp,
	LAG(AVG(gdp)) OVER (ORDER BY year_W) AS gdp_last_year,
	AVG(gdp) - LAG(AVG(gdp)) OVER (ORDER BY year_W) AS gdp_diff
FROM t_Lenka_Doova_project_SQL_secondary_final 
WHERE country = 'Czech Republic'
GROUP BY 
	year_W, 
	country
ORDER BY year_W
), 
cte_gdp_pct AS (
SELECT 
	*, 
	ROUND((gdp_diff::NUMERIC / NULLIF(gdp_last_year::NUMERIC, 0)) * 100, 2) AS gdp_diff_pct,
	CASE 
		WHEN ROUND((gdp_diff::NUMERIC / NULLIF(gdp_last_year::NUMERIC, 0)) * 100, 2) > 3 THEN 1
		ELSE 0
	END AS gdp_flag_3_pct
FROM cte_gdp 
),	
cte_wages AS (
SELECT 
	year_W,
	AVG(avg_wage) AS avg_wage,
	LAG(AVG(avg_wage)) OVER (ORDER BY year_W) AS avg_wage_last_year,
	AVG(avg_wage) - LAG(AVG(avg_wage)) OVER (ORDER BY year_W) AS wage_diff,
	LEAD(AVG(avg_wage)) OVER (ORDER BY year_W) AS avg_wage_next_year,
	LEAD(AVG(avg_wage)) OVER (ORDER BY year_W) - AVG(avg_wage) AS wage_diff_next_year
FROM t_Lenka_Doova_project_SQL_primary_final
GROUP BY 
	year_W
),
cte_wage_pct AS (
SELECT 
	*,
	ROUND((wage_diff::NUMERIC / NULLIF(avg_wage_last_year::NUMERIC, 0)) * 100, 2) AS wage_diff_pct,
	ROUND((wage_diff_next_year::NUMERIC / NULLIF(avg_wage::NUMERIC, 0)) * 100, 2) AS wage_diff_pct_next_year
FROM cte_wages
),
cte_prices AS (
SELECT 
	year_W,
	AVG(avg_price_norm) AS avg_price,
	LAG(AVG(avg_price_norm)) OVER (ORDER BY year_W) AS avg_price_last_year,
	AVG(avg_price_norm) - LAG(AVG(avg_price_norm)) OVER (ORDER BY year_W) AS price_diff,
	LEAD(AVG(avg_price_norm)) OVER (ORDER BY year_W) AS avg_price_next_year,
	LEAD(AVG(avg_price_norm)) OVER (ORDER BY year_W) - AVG(avg_price_norm) AS price_diff_next_year
FROM t_Lenka_Doova_project_SQL_primary_final
GROUP BY 
	year_W
),
cte_price_pct AS (
SELECT 
	*,
	ROUND((price_diff::NUMERIC / NULLIF(avg_price_last_year::NUMERIC, 0)) * 100, 2) AS price_diff_pct,
	ROUND((price_diff_next_year::NUMERIC / NULLIF(avg_price::NUMERIC, 0)) * 100, 2) AS price_diff_pct_next_year
FROM cte_prices
),
cte_final AS (
SELECT
	cgp.year_W,
	cgp.country,
	cgp.gdp_diff_pct,
	cgp.gdp_flag_3_pct,
	cwp.wage_diff_pct,
	cwp.wage_diff_pct_next_year,
	cpp.price_diff_pct,
	cpp.price_diff_pct_next_year
FROM cte_gdp_pct cgp
JOIN cte_wage_pct cwp ON cgp.year_W = cwp.year_W
JOIN cte_price_pct cpp ON cgp.year_W = cpp.year_W 
WHERE cgp.gdp_diff_pct IS NOT NULL
) SELECT * FROM cte_final; 
