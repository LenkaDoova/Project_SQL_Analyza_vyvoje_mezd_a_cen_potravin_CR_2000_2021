-- 4) Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?

WITH cte_avg_price_per_year AS (
SELECT 
    year_P,
    AVG(avg_price_norm) AS avg_price_year
FROM t_Lenka_Doova_project_SQL_primary_final
GROUP BY year_P
), 
cte_price_last_year AS ( 
SELECT 
    year_P,
    avg_price_year,
    LAG(avg_price_year) OVER (ORDER BY year_P) AS price_last_year,
    avg_price_year - LAG(avg_price_year) OVER (ORDER BY year_P) AS price_diff
FROM cte_avg_price_per_year
),
cte_price_diff_pct AS (
SELECT  
    year_P,
    avg_price_year,
    price_last_year,
    price_diff,
    ROUND((price_diff::NUMERIC / NULLIF(price_last_year::NUMERIC, 0)) * 100, 2) AS price_diff_pct
FROM cte_price_last_year
) ,
cte_avg_wage_per_year AS (
SELECT
    year_W,
    AVG(avg_wage) AS avg_wage_year
FROM t_Lenka_Doova_project_SQL_primary_final
GROUP BY 
	year_W
),
cte_wage_diff AS (
SELECT
    year_W,
    avg_wage_year,
    LAG(avg_wage_year) OVER (ORDER BY year_W) AS wage_last_year,
    avg_wage_year - LAG(avg_wage_year) OVER (ORDER BY year_W) AS wage_diff
FROM cte_avg_wage_per_year
),
cte_wage_diff_pct AS (
SELECT *,
	   ROUND((wage_diff::NUMERIC / NULLIF(wage_last_year::NUMERIC, 0)) * 100, 2) AS wage_diff_pct
FROM cte_wage_diff
),
cte_final AS ( 
SELECT
	cp.year_P,
	cp.price_diff_pct,
	cw.wage_diff_pct,
	cp.price_diff_pct - cw.wage_diff_pct AS diff
FROM cte_price_diff_pct cp 
JOIN cte_wage_diff_pct cw ON cp.year_P = cw.year_W
) SELECT * FROM cte_final
WHERE diff > 10
ORDER BY year_P;