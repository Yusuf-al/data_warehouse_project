# Data Warehouse Project

## Overview

This project demonstrates a complete end-to-end **Data Warehouse
Architecture** and **Advanced Data Analytics** solution designed using
SQL-based ETL pipelines, dimensional modeling, and analytical reporting.

The project follows a multi-layered architecture: - **Bronze Layer:**
Raw data ingestion - **Silver Layer:** Cleaned and conformed data -
**Gold Layer:** Analytics-ready fact and dimension tables

It includes: - Schema creation - Stored procedures for ETL automation -
EDA (Exploratory Data Analysis) - Advanced Data Analytics (ADA) -
Automated reporting SQL scripts - Data modeling diagrams in `.drawio`
format

## Key Features

### 🔹 **1. Data Warehouse Schema Design**

Includes three layers: - **Bronze:** Raw ingestion tables - **Silver:**
Cleaned and standardized tables - **Gold:** Star-schema optimized for
analytics
- Fact table: `fact_sales_details` - Dimensions: `dim_customers`,
`dim_products`, etc.

### 🔹 **2. ETL Pipeline Automation**

-   Stored procedures for:
    -   Data loading
    -   Data cleaning/standardization
    -   Upsert logic
    -   Gold-layer population

### 🔹 **3. Exploratory Data Analysis (EDA)**

File: `EDA/eda.sql` Includes: - Metadata exploration - Date boundary
analysis - Customer & product demographics - Global KPIs (Total Sales,
Orders, Products, Customers) - Magnitude analysis by country, gender,
category - Ranking analysis (Top-N/Bottom-N)

### 🔹 **4. Advanced Data Analytics**

Files: - `advanced_DA/ada.sql` - `advanced_DA/reports.sql`

Contains: - Window functions
- Change-over-time metrics
- Cumulative calculations
- Moving averages
- Product & customer performance
- Executive-level reporting metrics

### 🔹 **5. Data Modeling Diagrams (.drawio files)**

Includes: - Full ERD for the DW - Star schema visualization - ETL flow
diagram - Architecture overview

------------------------------------------------------------------------

## How to Use the Project

### 1️⃣ **Set up the database**

Run:

    create-db-alter-name.sql
    DW-Create-Schemas.sql

### 2️⃣ **Load raw data into Bronze**

### 3️⃣ **Execute ETL stored procedures**

    all-store-procedure.sql

### 4️⃣ **Run EDA**

    EDA/eda.sql

### 5️⃣ **Run Advanced Analytics**

    advanced_DA/ada.sql
    advanced_DA/reports.sql

------------------------------------------------------------------------

## Technologies Used

-   **SQL Server**
-   **T-SQL stored procedures**
-   **Data Warehouse (ETL + Star Schema)**
-   **Draw.io diagrams**

------------------------------------------------------------------------

## Author

**Yusuf Naiem**
GitHub: *github.com/Yusuf-al*

------------------------------------------------------------------------
