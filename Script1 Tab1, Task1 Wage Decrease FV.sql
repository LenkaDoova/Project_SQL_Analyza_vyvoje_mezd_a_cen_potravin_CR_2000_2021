-- vytvoření společné tabulky k 1.-4. úkolu: t_{jmeno}_{prijmeni}_project_SQL_primary_final:

-- PRICES:
CREATE TABLE t_prices_norm AS
WITH cte_price_normalized AS (
SELECT
    date_part('year', date_from) AS year_P,
    cpc.name AS food,
    CASE 
        WHEN price_unit = 'g' THEN cp.value / cpc.price_value * 1000 -- jogurt 150g
        WHEN price_unit = 'kg' THEN cp.value / cpc.price_value
        WHEN price_unit = 'ml' THEN cp.value / cpc.price_value * 1000
        WHEN price_unit = 'l' THEN cp.value / cpc.price_value -- pivo 0.5l, víno 0.75l
        WHEN price_unit = 'ks' THEN cp.value / cpc.price_value * 0.06 -- avg váha 1 vejce (M-L) = cca 60g 
    END AS price_per_unit
FROM czechia_price cp
JOIN czechia_price_category cpc ON cp.category_code = cpc.code
ORDER BY year_P 
),
cte_avg_price_per_unit AS (
SELECT 
	year_P,
	food,
	AVG(price_per_unit) AS avg_price_norm
FROM cte_price_normalized
GROUP BY year_P, food
) SELECT * FROM cte_avg_price_per_unit
ORDER BY year_P, food;

-- WAGES:

CREATE TABLE t_wages AS
SELECT 
	cpay.payroll_year AS year_W,
	cpib.name AS industry,
	AVG(value) AS avg_wage
FROM czechia_payroll cpay
JOIN czechia_payroll_industry_branch cpib ON cpay.industry_branch_code = cpib.code AND cpay.value_type_code = 5958
GROUP BY 
	year_W,
	industry
ORDER BY 
	year_W, 
	industry;
SELECT * FROM t_wages;

-- VYTVOŘENÍ FINÁLNÍ TABULKY:

CREATE TABLE t_Lenka_Doova_project_SQL_primary_final AS 
SELECT * FROM t_wages tw
LEFT JOIN t_prices_norm tpn ON tw.year_W = tpn.year_P;

SELECT * FROM t_Lenka_Doova_project_SQL_primary_final;

-- ÚKOL 1) Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

WITH cte_wage_last_year AS (
SELECT 
	year_W,
	industry,
	avg_wage,
	LAG(avg_wage) OVER (PARTITION BY industry ORDER BY year_W) AS wage_last_year
FROM t_Lenka_Doova_project_SQL_primary_final
),
cte_wage_diff AS (
SELECT 
	year_W,
	industry,
	avg_wage,
	wage_last_year,
	avg_wage - wage_last_year AS wage_diff
FROM cte_wage_last_year
),
cte_wage_diff_ration AS (
SELECT 
	year_W,
	industry,
	ROUND(avg_wage::NUMERIC, 2),
	ROUND(wage_last_year::NUMERIC, 2),
	ROUND(avg_wage::NUMERIC - wage_last_year::NUMERIC, 2) AS wage_diff,
	ROUND((wage_diff::NUMERIC / NULLIF(wage_last_year::NUMERIC, 0)) * 100, 2) AS "wage_diff_pct",
	CASE 
		WHEN avg_wage < wage_last_year THEN 1
		ELSE 0
	END AS wage_decrease	
FROM cte_wage_diff
) 
SELECT * 
FROM cte_wage_diff_ration 
WHERE wage_decrease = 1 
ORDER BY 
	year_W, 
	 industry;

