-- ÚKOL 3) Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)? 


WITH cte_price AS (
SELECT
	year_P,
	food,
	ROUND(AVG(avg_price_norm::NUMERIC), 2) AS avg_price_norm
FROM t_Lenka_Doova_project_SQL_primary_final
GROUP BY 
	year_P,
	food
), 
cte_price_last_year AS ( 
SELECT 
	*,
	LAG(avg_price_norm) OVER (PARTITION BY food ORDER BY year_P) AS price_last_year,
	avg_price_norm - LAG(avg_price_norm) OVER (PARTITION BY food ORDER BY year_P) AS price_diff
FROM cte_price
),
cte_price_diff_ration AS (
SELECT  
	year_P,
	food,
	avg_price_norm,
	price_last_year,
	price_diff,
	ROUND((price_diff::NUMERIC / NULLIF(price_last_year::NUMERIC, 0)) * 100, 2) AS price_diff_pct,
	CASE 
		WHEN avg_price_norm < price_last_year THEN 1
		ELSE 0
	END AS price_decrease	
FROM cte_price_last_year
),
cte_first_last_prices_years AS (
SELECT
	*,
	FIRST_VALUE(avg_price_norm) OVER (PARTITION BY food ORDER BY year_P) AS first_price,
	LAST_VALUE(avg_price_norm) OVER (PARTITION BY food ORDER BY year_P ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_price,
	MIN(year_P) OVER (PARTITION BY food ORDER BY year_P) AS min_year,
	MAX(year_P) OVER (PARTITION BY food ORDER BY year_P ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS max_year
FROM cte_price_diff_ration
), 
cte_CAGR AS (
SELECT 
	*,
	max_year - min_year AS num_years,
	ROUND((POWER(last_price::NUMERIC / first_price::NUMERIC, 1.0 / (max_year - min_year)) - 1)::NUMERIC, 3) AS CAGR 
FROM cte_first_last_prices_years
),
cte_rank_CAGR AS (
SELECT 
	*,
	DENSE_RANK() OVER (ORDER BY CAGR) AS rank_CAGR
FROM cte_CAGR
),
cte_rank_CAGR_1 AS (
SELECT * 
FROM cte_rank_CAGR 
WHERE rank_CAGR = 1 
) 
SELECT
	year_P,
	food,
	avg_price_norm,
	price_diff_pct,
	CAGR,
	rank_CAGR
FROM cte_rank_CAGR_1
ORDER BY year_P;



