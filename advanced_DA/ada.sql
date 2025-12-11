----------------------------------------------------------
-- 🔹 CHANGES OVER YEARS
-- Provides a high-level overview of yearly and monthly sales trends.
-- Useful for identifying long-term growth and seasonal sales patterns.
----------------------------------------------------------
SELECT 
    YEAR(order_date) as Sales_year,
    FORMAT(order_date,'MMM') as Sales_month,
    SUM(total_sales) as total_revenue,
    COUNT(customer_key) as total_customer,
    SUM(quantity) as total_quantity
FROM gold.fact_sales_details
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), FORMAT(order_date,'MMM')
ORDER BY YEAR(order_date) DESC, FORMAT(order_date,'MMM') DESC, SUM(total_sales) DESC 

----------------------------------------------------------
-- 🔹 CUMULATIVE ANALYSIS
-- Calculate the total sales per month
-- and the running total of sales over time
----------------------------------------------------------

SELECT
    order_date,
    each_month_sales,
    SUM(each_month_sales) OVER(PARTITION BY order_date ORDER BY order_date) as running_total
 FROM(
        SELECT
            DATETRUNC(MONTH,order_date) as order_date,
            SUM( total_sales) as each_month_sales
        FROM gold.fact_sales_details
        WHERE  DATETRUNC(MONTH,order_date) is NOT NULL
        GROUP BY  DATETRUNC(MONTH,order_date) 

)t
----------------------------------------------------------
-- 🔹 YEARLY CUMULATIVE TRENDS
-- Aggregates sales and calculates yearly running totals and average price trends.
-- Useful for comparing overall annual performance.
----------------------------------------------------------
SELECT 
    YEAR(order_date) as Sales_year,
    SUM(total_sales) --OVER(ORDER BY YEAR(order_date)) as total_revenue
FROM gold.fact_sales_details
WHERE YEAR(order_date) IS NOT NULL
GROUP BY YEAR(order_date)


SELECT
    order_date,
    each_month_sales,
    SUM(each_month_sales) OVER(ORDER BY order_date) as running_total,
    AVG(avg_price) OVER (ORDER BY order_date) as running_avg
 FROM (
        SELECT
            DATETRUNC(YEAR,order_date) as order_date,
            SUM( total_sales) as each_month_sales,
            AVG(price) as avg_price
        FROM gold.fact_sales_details
        WHERE  DATETRUNC(YEAR,order_date) is NOT NULL
        GROUP BY  DATETRUNC(YEAR,order_date)
)t

----------------------------------------------------------
-- 🔹 PERFORMANCE ANALYSIS
-- Analyze the yearly performance of products by comparing each product's sales to both 
-- its average sales performance and the previous year's sales.
----------------------------------------------------------

WITH yearly_prodcut_sales AS (

SELECT 
    YEAR(s.order_date) as Sales_year,
    p.product_name,
    SUM(s.total_sales) as current_sales
FROM gold.fact_sales_details s
LEFT JOIN gold.dim_products p  
ON s.product_key = p.product_key
WHERE YEAR(s.order_date) IS NOT NULL
GROUP BY YEAR(s.order_date), p.product_name

)
SELECT 
Sales_year,
product_name,
current_sales,
AVG(current_sales) OVER(PARTITION BY product_name) as avg_sales,
current_sales - AVG(current_sales) OVER(PARTITION BY product_name) as diff_avg,
CASE 
    WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) > 0 THEN 'Above_AVG'
    WHEN current_sales - AVG(current_sales) OVER(PARTITION BY product_name) < 0 THEN 'Below_AVG'
    ELSE 'AVG'
END Avg_Change,
LAG(current_sales) OVER(PARTITION BY product_name ORDER BY Sales_year) as prev_sales,
current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY Sales_year) as sales_diff_yearly,
CASE 
    WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY Sales_year) > 0 THEN 'Increase'
    WHEN current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY Sales_year) < 0 THEN 'Decrease'
    ELSE 'No Change'
END 'Diff_PY_Sales'
FROM yearly_prodcut_sales
ORDER BY product_name 

----------------------------------------------------------
-- 🔹 PART-TO-WHOLE ANALYSIS (BY CATEGORY)
-- Determines which product categories contribute the most to total sales.
-- Useful for prioritizing high-impact product groups.
----------------------------------------------------------

WITH sales_by_cat AS (
    -- CTE to calculate total sales by product category
    -- Using LEFT JOIN which might include NULL product categories
    SELECT 
        p.product_category,
        SUM(total_sales) as sales_by_category
    FROM gold.fact_sales_details s  
    LEFT JOIN gold.dim_products  p  
    ON p.product_key = s.product_key
    GROUP BY product_category
)
SELECT
    product_category,
    sales_by_category,

    -- Window function calculating grand total
    SUM(sales_by_category) OVER() as total_sales, 

    -- Multiple type conversions (FLOAT → DECIMAL → NVARCHAR) could impact performance
    CAST (ROUND ((cast (sales_by_category as float) / SUM(sales_by_category) OVER()) * 100,2) as nvarchar)+'%' as sales_percent
FROM sales_by_cat
GO

----------------------------------------------------------
-- 🔹 PART-TO-WHOLE ANALYSIS (BY YEAR)
-- Shows which years contributed the highest percentage of overall revenue.
-- Helps identify the strongest financial years.
----------------------------------------------------------

--Which Year contribute the most to overall sales
WITH sales_by_yr AS (
    -- CTE to calculate total sales by year
    SELECT 
        YEAR(order_date) as sales_year,
        SUM(total_sales) as sales_by_year
    FROM gold.fact_sales_details 
    WHERE YEAR(order_date) IS NOT NULL
    GROUP BY YEAR(order_date)
)
SELECT
    sales_year,
    sales_by_year,
    SUM(sales_by_year) OVER() as total_sales,
    CAST (ROUND ((cast (sales_by_year as float) / SUM(sales_by_year) OVER()) * 100,2) as nvarchar)+'%' as sales_percent
FROM sales_by_yr
ORDER BY sales_percent DESC
GO

----------------------------------------------------------
-- 🔹 DATA SEGMENTATION (PRODUCTS)
-- Categorizes products based on price range for cost-based segmentation.
-- Helps identify product distribution across pricing tiers.
----------------------------------------------------------

WITH product_segments AS (

SELECT 
    product_key,
    product_name,
    product_price,
    AVG(product_price) OVER () as avg_p_price,
    CASE
        WHEN product_price < 100 THEN 'Below 100'
        WHEN product_price BETWEEN 100 AND 500 THEN '100-500'
        WHEN product_price BETWEEN 500 AND 1000 THEN '500-1000'
        ELSE 'Above 1000'
    END 'Segement'
FROM gold.dim_products
WHERE product_name IS NOT NULL AND product_price IS NOT NULL
)
SELECT 

    Segement,
    COUNT(*)

FROM product_segments
GROUP BY Segement
GO

----------------------------------------------------------
-- 🔹 DATA SEGMENTATION (CUSTOMERS)
-- Group customers into three segments based on their spending behavior:
-- VIP: at least 12 months of history and spending more than €5,000.
-- Regular: at least 12 months of history but spending €5,000 or less.
-- New: lifespan less than 12 months.
-- And the total customer in each group
----------------------------------------------------------

WITH customer_segments_sales AS(

    SELECT 
        c.customer_key,
        SUM(s.total_sales) as total_sales,
        MIN(s.order_date) as first_order,
        MAX(s.order_date) as last_order,
        DATEDIFF(MONTH ,MIN(s.order_date), MAX(s.order_date)) as montth_deff
    FROM gold.fact_sales_details s
    LEFT JOIN gold.dim_customers c
    ON s.customer_key = c.customer_key
    GROUP BY c.customer_key
    HAVING MIN(s.order_date) is not null or MAX(s.order_date) is not null
), segmets_count as (

SELECT 
    customer_key,
    total_sales,
    montth_deff,
    CASE 
        WHEN montth_deff >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN montth_deff >= 12 AND total_sales <= 5000 THEN 'Regular'
        WHEN montth_deff < 12 THEN 'New'       
    END 'customer_segments'
FROM customer_segments_sales

)
SELECT 
    sc.customer_segments,
    COUNT(*) as segemnt_count

FROM
customer_segments_sales cs LEFT JOIN segmets_count sc
ON cs.customer_key =sc.customer_key
WHERE sc.customer_segments is not NULL
GROUP BY sc.customer_segments
