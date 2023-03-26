-- REQUEST 1
-- SELECT DISTINCT market FROM gdb023.dim_customer WHERE customer = 'Atliq Exclusive' AND region = 'APAC';


-- REQUEST 2
-- WITH cte20 AS(
-- 	SELECT COUNT(DISTINCT(product_code)) AS cnt FROM gdb023.fact_sales_monthly WHERE fiscal_year = '2020'
--  ),
-- cte21 AS(
-- 	SELECT COUNT(DISTINCT(product_code)) AS cnt FROM gdb023.fact_sales_monthly WHERE fiscal_year = '2021'
-- )
-- SELECT t0.cnt AS unique_products_2020, t1.cnt AS unique_products_2021, ROUND(((((t1.cnt - t0.cnt)/t0.cnt)) *100), 2) AS percentage_chg 
-- FROM cte20 t0 CROSS JOIN cte21 t1; 


-- REQUEST 3
-- SELECT segment, COUNT(DISTINCT(product_code)) AS product_count
-- FROM gdb023.dim_product 
-- GROUP BY segment 
-- ORDER BY product_count DESC;


-- REQUEST 4
-- WITH cte20 AS(
-- 	SELECT p.segment AS segment, COUNT(DISTINCT(s.product_code)) AS cnt FROM gdb023.fact_sales_monthly s LEFT JOIN gdb023.dim_product p ON  s.product_code = p.product_code WHERE fiscal_year = '2020' GROUP BY p.segment
--  ),
-- cte21 AS(
-- 	SELECT p.segment AS segment, COUNT(DISTINCT(s.product_code)) AS cnt FROM gdb023.fact_sales_monthly s LEFT JOIN gdb023.dim_product p ON  s.product_code = p.product_code WHERE fiscal_year = '2021' GROUP BY p.segment
-- )
-- SELECT t0.segment AS segment, t0.cnt AS product_count_2020, t1.cnt AS product_count_2021, t1.cnt - t0.cnt AS difference 
-- FROM cte20 t0 INNER JOIN cte21 t1 ON t0.segment = t1.segment
-- ORDER BY difference DESC; 
 
 
-- REQUEST 5
-- SELECT mc.product_code AS product_code, p.product AS product, mc.manufacturing_cost AS manufacturing_cost 
-- FROM fact_manufacturing_cost mc LEFT JOIN dim_product p ON mc.product_code = p.product_code 
-- WHERE mc.manufacturing_cost IN (SELECT MAX(manufacturing_cost) FROM fact_manufacturing_cost UNION SELECT MIN(manufacturing_cost) FROM fact_manufacturing_cost);


-- REQUEST 6
-- SELECT c.customer_code, c.customer, ROUND(AVG(d.pre_invoice_discount_pct)*100,2) AS average_discount_percentage 
-- FROM fact_pre_invoice_deductions d LEFT JOIN dim_customer c ON d.customer_code = c.customer_code
-- WHERE d.fiscal_year = 2021 AND c.market = 'India'
-- GROUP BY c.customer_code, c.customer
-- ORDER BY average_discount_percentage DESC 
-- LIMIT 5; 


-- REQUEST 7
-- SELECT MONTH(s.date) AS Month, s.fiscal_year AS Year, ROUND(SUM(s.sold_quantity*gp.gross_price), 2) AS 'Gross sales Amount' 
-- FROM fact_sales_monthly s LEFT JOIN fact_gross_price gp ON s.product_code = gp.product_code
-- LEFT JOIN dim_customer c ON s.customer_code = c.customer_code 
-- WHERE c.customer = "Atliq Exclusive"
-- GROUP BY s.fiscal_year, MONTH(s.date)
-- ORDER BY s.fiscal_year, MONTH(s.date);


-- REQUEST 8
-- WITH cte1 AS(
-- 	SELECT sold_quantity, 
--     CASE 
-- 		WHEN MONTH(date) >= 9 AND MONTH(date)<= 11 THEN 1
--         WHEN MONTH(date) >= 3 AND MONTH(date)<= 5 THEN 3
--         WHEN MONTH(date) >= 6 AND MONTH(date)<= 8 THEN 4
--         ELSE 2
-- 	END AS Quarter
--     FROM fact_sales_monthly
--     WHERE fiscal_year = 2020
-- )
-- SELECT Quarter, SUM(sold_quantity) AS total_sold_quantity FROM cte1 GROUP BY Quarter ORDER BY total_sold_quantity DESC;


-- REQUEST 9
-- WITH cte1 AS(
-- 	SELECT DISTINCT c.channel, ROUND((SUM(s.sold_quantity*gp.gross_price) OVER(PARTITION BY c.channel) /POWER(10,6)), 2) AS gross_sales__mln  
--     FROM fact_sales_monthly s LEFT JOIN dim_customer c ON s.customer_code = c.customer_code LEFT JOIN fact_gross_price gp ON s.product_code = gp.product_code
--     WHERE s.fiscal_year = 2021
-- )
-- SELECT channel, gross_sales__mln, ROUND((gross_sales__mln/(SELECT SUM(gross_sales__mln) FROM cte1))*100, 2) AS percentage
-- FROM cte1
-- ORDER BY percentage DESC;  

-- REQUEST 10 
-- WITH cte1 AS (
-- 	SELECT p.division, s.product_code, p.product, SUM(s.sold_quantity) AS total_sold_quantity 
-- 	FROM fact_sales_monthly s LEFT JOIN dim_product p ON s.product_code = p.product_code
-- 	WHERE s.fiscal_year = 2021
-- 	GROUP BY p.division, s.product_code, p.product
-- )
-- SELECT * 
-- FROM (SELECT *, dense_rank() OVER(PARTITION BY division ORDER BY total_sold_quantity DESC) AS rank_order FROM cte1)t1
-- WHERE rank_order <= 3; 
