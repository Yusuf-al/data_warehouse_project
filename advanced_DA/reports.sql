/*
                    ================================
                            Customer Report
                    ================================
Purpose:
    This report consolidates key customer metrics and behaviors
Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
    2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
            -- total orders
            -- total sales
            -- total quantity purchased
            -- total products
            -- lifespan (in months)
    4. Calculates valuable KPIs:
            -- recency (months since last order)
            -- average order value
            -- average monthly spend

*/

-- 🔹 View: gold.report_customers
-- Purpose: Generate a summarized customer-level report 
--          including purchase behavior, lifetime metrics,
--          segmentation, and demographic insights.
----------------------------------------------------------

CREATE VIEW gold.report_customers AS

-- CTE #1: Base query combining sales and customer details
-- Includes derived age and ensures only valid orders.

WITH base_query AS (

    SELECT
        fs.order_number,
        fs.order_date,
        fs.product_key,
        fs.total_sales,
        fs.quantity,
        dc.customer_key,
        dc.customer_number,
        CONCAT(dc.first_name,' ',dc.last_name) as customer_name,

        -- Derived column: customer age
        DATEDIFF(YEAR, dc.birthdate, CAST('2015-12-31' as DATE)) as age
    FROM gold.fact_sales_details fs  
    LEFT JOIN gold.dim_customers dc  
    ON fs.customer_key =dc.customer_key
    WHERE fs.order_date IS NOT NULL
), aggregated_queries AS(

    -- CTE #2: Aggregates metrics per customer
    -- Aggregation includes total orders, sales, quantity, product count, and lifespan.
SELECT 
    customer_key,
    customer_name,
    customer_number,
    age,

    -- Aggregation: number of unique orders, total spending, total items purchased, number of different products purchased
    COUNT(DISTINCT order_number) as total_order, 
    SUM(total_sales) as total_sales,
    SUM(quantity) as total_quantity,
    COUNT(DISTINCT product_key) as total_product,

    -- Derived customer lifespan in months
    DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) as life_span,

    -- Most recent order
    MAX(order_date) as last_order
FROM base_query
GROUP BY customer_key,customer_name,customer_number,age
)
-- Final SELECT: Calculates key KPIs and customer segmentation
    SELECT 
        customer_key,
        customer_name,
        customer_number,
        total_quantity,
        total_product,
        total_order, 
        total_sales,

        -- CASE: handles division by zero while calculating average order value
        CASE WHEN total_sales = 0 then 0
             ELSE total_sales / total_order 
        END as 'avg_order_value',

        -- CASE: computes average monthly spend considering inactive customers
        CASE WHEN total_sales = 0 then 0
             WHEN life_span = 0 then total_sales
             ELSE total_sales / life_span
        END as 'avg_monthly_spend',

        -- CASE: segments customers by sales and engagement duration
        CASE 
            WHEN life_span >= 12 AND total_sales >= 5000 THEN 'VIP'
            WHEN life_span >= 12 AND total_sales < 5000 THEN 'REGULAR'
            ELSE 'NEW'
        END 'customer_segment',

        -- Handle NULL ages for missing birthdates
        COALESCE(age,0) as age,

        -- CASE: categorize customers into age groups
        CASE 
            WHEN COALESCE(age,0) < 20 THEN 'Below 20'
            WHEN age between 20 and 30 THEN '20-30'
            WHEN age between 31 and 40 THEN '31-40'
            WHEN age between 41 and 50 THEN '41-50'
            WHEN age > 50 THEN 'Above 50'
        END 'age_group',
        life_span,
        last_order,

         -- Derived metric: months since last purchase (recency)
        DATEDIFF(MONTH,last_order, CAST('2014-12-31' as DATE)) as recency
    FROM aggregated_queries

