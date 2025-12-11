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
### 🔹 **Data Modeling Diagram**
##Data Warehouse
<img width="761" height="530" alt="DWH" src="https://github.com/user-attachments/assets/721b6097-c5d8-4b1f-9f89-62b709e7d9aa" />

##Data Integration
<img width="981" height="476" alt="intregation-model" src="https://github.com/user-attachments/assets/fb914748-ed6d-4cbf-bde7-37733be2cc54" />

##Data Flow
<img width="861" height="570" alt="data-flow" src="https://github.com/user-attachments/assets/7ee4285b-0c97-4a51-af69-b89ae6fa132c" />

##Data Model
<img width="791" height="481" alt="data-model" src="https://github.com/user-attachments/assets/019b9246-32b1-4b15-b0c2-61a5fda91ca5" />

## Author

**Yusuf Naiem**
GitHub:*github.com/Yusuf-al*

------------------------------------------------------------------------
