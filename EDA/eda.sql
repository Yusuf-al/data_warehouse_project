-- =====================================================================
-- PROJECT: SALES & CUSTOMER DATA EXPLORATORY DATA ANALYSIS (EDA)
-- DESCRIPTION:
-- This script performs a full Exploratory Data Analysis (EDA) on a
-- multi-layered Data Warehouse (GOLD Layer) containing:
-- ✔ fact_sales_details
-- ✔ dim_customers
-- ✔ dim_products
--
-- The EDA covers the following analytical tasks:
--
-- 1. **Metadata Exploration**
-- - Explore tables, columns, countries, categories
-- - Inspect date boundaries (MIN/MAX)
--
-- 2. **Measure Exploration (Big Numbers)**
-- - Total Sales
-- - Total Quantity Sold
-- - Avg Selling Price
-- - Distinct Orders, Products, Customers
-- - Summary metrics consolidated into a single table
--
-- 3. **Magnitude Analysis**
-- - Sales by Country
-- - Customers by Country / Gender
-- - Revenue & Avg Price by Category
-- - Product distribution and customer spending
--
-- 4. **Ranking Analysis**
-- - Top/Bottom Products
-- - Top Customers by Revenue
-- - Bottom Customers by Orders
--
-- 5. **Extras**
-- - Additional helpful checks for validation
--
-- NOTE:
-- All analytical steps are intentionally kept modular for clarity.
-- =====================================================================

--explore all objects in the database
SELECT * FROM INFORMATION_SCHEMA.TABLES

--explore all columns in the database
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers'

--explore all distinct countries from customers
SELECT DISTINCT country FROM gold.dim_customers

--- explore all distinct categories from the product table

SELECT DISTINCT product_category, product_subcategory,product_name FROM gold.dim_products
ORDER BY 1,2,3

---Explore Data column
-- Identify the earliest and latest dates (boundaries).
-- Understand the scope of data and the timespan.
-- MIN/MAX [ Date Dimension]
-- MIN Order date
-- MAX Create-date
-- MIN Birthdate

SELECT MAX( order_date) as Last_order_date,
       MIN(order_date) as First_order_date,
       DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) as order_ragne_year
FROM gold.fact_sales_details

SELECT MAX(birthdate) youngest_customer, 
       DATEDIFF(YEAR, MIN(birthdate),GETDATE()) as O_age,
       MIN(birthdate) oldest_customer,
       DATEDIFF(YEAR,MAX(birthdate), GETDATE()) as Y_age
FROM gold.dim_customers


                -- Measures Exploration
-- Calculate the key metric of the business (Big Numbers)
-- Highest Level of Aggregation | Lowest Level of Details -

--TASKS
-- Find the Total Sales
SELECT SUM(total_sales) AS total_sales FROM gold.fact_sales_details
-- Find how many items are sold
SELECT SUM(quantity) as total_quantity from gold.fact_sales_details
-- Find the average selling price
SELECT AVG(price) as avg_selling_price FROM gold.fact_sales_details 
-- Find the Total number of Orders
SELECT COUNT(order_number) as total_order FROM gold.fact_sales_details
SELECT COUNT(DISTINCT order_number) as total_order FROM gold.fact_sales_details
-- Find the total number of products
SELECT COUNT(DISTINCT product_key) as total_product FROM gold.dim_products
-- Find the total number of customers
SELECT COUNT(DISTINCT customer_key) as total_customer FROM gold.dim_customers
-- Find the total number of customers that has placed an order
SELECT COUNT(DISTINCT customer_key) FROM gold.fact_sales_details

---combine this in a single table

SELECT 'Total Sales' as measure_name , SUM(total_sales) as measure_vale FROM gold.fact_sales_details
UNION ALL 
SELECT 'Total Sales Quantity' as measure_name, SUM(quantity) as measure_vale FROM gold.fact_sales_details
UNION ALL
SELECT 'Average Price', AVG(price) from gold.fact_sales_details
UNION ALL 
SELECT 'Total distinct order', COUNT(DISTINCT order_number) FROM gold.fact_sales_details
UNION ALL
SELECT 'Total Nr Products', COUNT(distinct product_key) from gold.dim_products
UNION ALL 
SELECT 'Total Nr Customers',COUNT(DISTINCT customer_key) FROM gold.dim_customers
UNION ALL
SELECT 'Total Customers by orders', COUNT(DISTINCT customer_key) FROM gold.fact_sales_details

            ----- Magnitude ----
-- Compare the measure values by categories.
-- It helps us understand the importance of different categories.
-- Formula for finding Magnitude [Measure] By [Dimension]

--TASKS
--Find total customers by countries
SELECT country, COUNT(customer_key) as customer_by_country 
FROM gold.dim_customers
GROUP BY country

--Find the total sales by countries
SELECT country, sum(total_sales) FROM (
    SELECT 
        s.order_number,
        s.order_date,
        s.product_key,
        s.total_sales as total_sales,
        c.country as country 
    FROM gold.fact_sales_details s
    LEFT JOIN gold.dim_customers c  
    ON s.customer_key = c.customer_key
)t GROUP BY country ORDER BY SUM(total_sales) DESC

--Find total customers by gender
SELECT 
    gender, 
    COUNT(customer_key) 
FROM gold.dim_customers 
GROUP BY gender
--Find total products by category
SELECT 
    product_category, 
    -- product_name, 
    COUNT(product_key) 
FROM gold.dim_products 
GROUP BY product_category ORDER BY product_category DESC
--What is the average costs in each category?
SELECT 
    product_category, 
    AVG(product_price) as avg_price
FROM gold.dim_products
GROUP BY product_category
ORDER BY AVG(product_price) DESC
--What is the total revenue generated for each category?
SELECT 
    p.product_category,
    SUM(s.total_sales) as total_revenue
FROM gold.fact_sales_details s 
LEFT JOIN gold.dim_products p 
on s.product_key = p.product_key
GROUP BY p.product_category
ORDER BY SUM(s.total_sales) DESC
--Find total revenue is generated by each customer
SELECT 
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(total_sales) as total_sales_by_customer
FROM gold.fact_sales_details s 
LEFT JOIN gold.dim_customers c 
ON s.customer_key = c.customer_key 
GROUP BY  c.customer_key,
          c.first_name,
          c.last_name
ORDER BY SUM(total_sales) DESC
--What is the distribution of sold items across countries?
SELECT 
    c.country,
    sum(s.quantity) as total_quantity_by_country
FROM gold.fact_sales_details s 
LEFT JOIN gold.dim_customers c
ON s.customer_key = c.customer_key
GROUP BY c.country
ORDER BY SUM(s.quantity) DESC


   ----------- Ranking -----------
--Order the values of dimensions by measure.
--Top N performers | Bottom N Performers
-- Rank [Dimension] By E[Measure]
-- Rank Countries By Total Sales
-- Top 5 Products By Quantity
-- Bottom 3 Customers By Total Orders
--TASKS:
--Which 5 products generate the highest revenue?
SELECT TOP 5
    p.product_name,
    SUM(s.total_sales) as total_revenue
FROM gold.fact_sales_details s  
LEFT JOIN gold.dim_products p   
ON s.product_key = p.product_key
GROUP BY p.product_name
ORDER BY SUM(s.total_sales) DESC

--Which 5 product subcategories generate the highest revenue?
SELECT * FROM(

SELECT
    p.product_subcategory,
    SUM(s.total_sales) as total_sales,
    ROW_NUMBER() OVER(order by SUM(s.total_sales) DESC) as rank
FROM gold.fact_sales_details s  
LEFT JOIN gold.dim_products p   
ON s.product_key = p.product_key
GROUP BY p.product_subcategory
)t WHERE rank <= 5




--What are the 5 worst-performing products in terms of sales?
SELECT TOP 5
    p.product_name,
    SUM(s.total_sales) as total_revenue
FROM gold.fact_sales_details s  
LEFT JOIN gold.dim_products p   
ON s.product_key = p.product_key
GROUP BY p.product_name
ORDER BY SUM(s.total_sales)

--Find the top 10 customers who have generated the highest revenue 
SELECT * FROM (

SELECT
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(s.total_sales) as total_revenue_by_customers,
    ROW_NUMBER() OVER(ORDER BY SUM(s.total_sales) DESC) as rank 
FROM gold.fact_sales_details s  
LEFT JOIN gold.dim_customers c  
ON c.customer_key = s.customer_key 
GROUP BY c.customer_key,
         c.first_name,
         c.last_name
)t WHERE rank <=5

--The 3 customers with the fewest orders placed

SELECT TOP 3
    c.customer_key,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT s.order_number) as Total_orders
    -- ROW_NUMBER() OVER(ORDER BY(COUNT(DISTINCT s.order_number))) as rank 
FROM gold.fact_sales_details s  
LEFT JOIN gold.dim_customers c  
ON c.customer_id = s.customer_key 
GROUP BY c.customer_key,
    c.first_name,
    c.last_name
ORDER BY Total_orders 


----------------------- EXTRA -----------------------------------------------
SELECT 'total Sales' , SUM(total_sales) FROM gold.fact_sales_details

SELECT * FROM gold.fact_sales_details
SELECT * FROM gold.dim_products
