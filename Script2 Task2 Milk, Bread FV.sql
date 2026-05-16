-- ÚKOL 2) Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

WITH cte_wages AS (
SELECT 
	year_W,
	industry,
	avg_wage,	
    MIN(year_W) OVER (PARTITION BY industry ORDER BY year_W) AS min_year,
    MAX(year_W) OVER (PARTITION BY industry ORDER BY year_W ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS max_year
FROM t_Lenka_Doova_project_SQL_primary_final
GROUP BY 
	year_W,
	industry,
	avg_wage
), 
cte_milk AS (
SELECT
	year_P,
	food,
	avg_price_norm,
	FIRST_VALUE(avg_price_norm) OVER (PARTITION BY food ORDER BY year_P) AS first_price,
	LAST_VALUE(avg_price_norm) OVER (PARTITION BY food ORDER BY year_P ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_price,
    MIN(year_P) OVER (PARTITION BY food ORDER BY year_P) AS min_year,
    MAX(year_P) OVER (PARTITION BY food ORDER BY year_P ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS max_year
FROM t_Lenka_Doova_project_SQL_primary_final
WHERE food = 'Mléko polotučné pasterované'
GROUP BY 
	year_P,
	food,
	avg_price_norm
), 
cte_bread AS (
SELECT 
	year_P,
	food,
	avg_price_norm,
	FIRST_VALUE(avg_price_norm) OVER (PARTITION BY food ORDER BY year_P) AS first_price,
	LAST_VALUE(avg_price_norm) OVER (PARTITION BY food ORDER BY year_P ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_price,
    MIN(year_P) OVER (PARTITION BY food ORDER BY year_P) AS min_year,
    MAX(year_P) OVER (PARTITION BY food ORDER BY year_P ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS max_year
FROM t_Lenka_Doova_project_SQL_primary_final
WHERE food = 'Chléb konzumní kmínový' 
GROUP BY 
	year_P,
	food,
	avg_price_norm
),
cte_final AS (
SELECT  
	cw.year_W,
	cw.industry,
	ROUND(cw.avg_wage::NUMERIC, 2),
	cm.food,
	ROUND(cm.avg_price_norm::NUMERIC, 2),
	ROUND(cw.avg_wage::NUMERIC / cm.avg_price_norm::NUMERIC, 2) AS milk_per_wage,
	CASE 
		WHEN cw.year_W IN (cm.min_year, cm.max_year) THEN 1
	END AS flag	
FROM cte_wages cw
JOIN cte_milk cm ON cw.year_W = cm.year_P
UNION
SELECT 
	cw.year_W,
	cw.industry,
	ROUND(cw.avg_wage::NUMERIC, 2),
	cb.food,
	ROUND(cb.avg_price_norm::NUMERIC, 2),
	ROUND(cw.avg_wage::NUMERIC / cb.avg_price_norm::NUMERIC, 2) AS bread_per_wage,
	CASE 
		WHEN cw.year_W IN (cb.min_year, cb.max_year) THEN 1
	END AS flag	
FROM cte_wages cw
JOIN cte_bread cb ON cw.year_W = cb.year_P
) 
SELECT * 
FROM cte_final cf
WHERE flag = 1
ORDER BY 
	year_W, 
	industry;


