# Retail Business Intelligence Platform

A portfolio **Data Analyst / Business Intelligence** project built on the **Brazilian Olist E-commerce Dataset**.

The project focuses on **SQL analytics, dimensional modeling, Data Warehouse, Power BI, DAX, and business insights**, rather than building an over-engineered data engineering pipeline.

> **Current status:** Data Warehouse and Power BI data model are completed. The next step is to build the core **DAX Measures**, followed by dashboard development and business insights.

---

## Project Objective

The objective is to transform raw Olist e-commerce data into an analytical model that can answer business questions around:

- Sales performance and growth
- Customer behavior
- Product performance
- Seller performance
- Order performance
- Marketing-related analysis
- KPI monitoring
- Business insights

This project is designed to demonstrate practical skills for:

**Data Analyst | BI Analyst | BI Developer**

---

# Tech Stack

| Area | Technology |
|---|---|
| Source databases | PostgreSQL, SQL Server |
| Analytical database | SQL Server |
| Database tools | pgAdmin, SQL Server Management Studio (SSMS) |
| Data analysis | SQL |
| Data modeling | Star Schema / Dimensional Modeling |
| BI & Visualization | Microsoft Power BI |
| BI calculations | DAX |
| Programming | Python |
| Environment | Docker / Docker Compose |
| Dataset | Olist Brazilian E-commerce Dataset |

---

# High-Level Architecture

```text
                    OLIST DATASET
                         |
             +-----------+-----------+
             |                       |
             v                       v
        PostgreSQL               SQL Server
        olist_crm                olist_sales
             |                       |
       Customer/Seller        Orders / Items /
             |                Products / Payments
             |                       |
             +-----------+-----------+
                         |
                         | SQL / ELT
                         v
                  SQL Server DW
                  olist_analytics
                         |
                    Star Schema
                         |
             +-----------+-----------+
             |           |           |
          Dimensions  Fact Sales   Date
             |           |           |
             +-----------+-----------+
                         |
                         v
                    Power BI
                         |
                      DAX
                         |
                    Dashboards
                         |
                  Business Insights
```

### Design Principle

The project intentionally **does not introduce a full staging layer or orchestration pipeline**.

The focus is on:

- Analytical SQL
- Dimensional modeling
- Data Warehouse
- Power BI
- DAX
- Business analysis

---

# Source Data

The project uses the **Olist Brazilian E-commerce Dataset**.

## PostgreSQL — `olist_crm`

### `crm`

- `customers`
- `sellers`

### `marketing`

- `marketing_qualified_leads`
- `closed_deals`

### `reference`

- `geolocation`
- `product_category_translation`

---

## SQL Server — `olist_sales`

### `sales`

- `orders`
- `order_items`
- `order_payments`

### `catalog`

- `products`

The Olist order reviews dataset was intentionally excluded because the source file contained significant data-quality/import issues.

---

# Database Architecture

## PostgreSQL

```text
olist_crm
|
+-- crm
|   +-- customers
|   +-- sellers
|
+-- marketing
|   +-- marketing_qualified_leads
|   +-- closed_deals
|
+-- reference
    +-- geolocation
    +-- product_category_translation
```

PostgreSQL is mainly used for CRM, customer/seller, marketing, and reference data.

---

## SQL Server

```text
olist_sales
|
+-- sales
|   +-- orders
|   +-- order_items
|   +-- order_payments
|
+-- catalog
    +-- products
```

SQL Server contains the transactional sales/order data used for the main sales analysis.

---

# SQL Analytics Layer

Before building the Data Warehouse, analytical SQL was developed to understand the source data and generate business analysis.

```text
sql/
└── analytics/
    ├── 01_sales_analysis.sql
    ├── 02_customer_analysis.sql
    ├── 03_product_analysis.sql
    ├── 04_order_analysis.sql
    └── 05_marketing_analysis.sql
```

### SQL techniques used

- Aggregation
- CTEs
- Window Functions
- `LAG()`
- Ranking
- Month-over-Month analysis
- Customer analysis
- Product analysis
- Seller analysis
- Revenue analysis
- Order analysis

Example:

```sql
LAG(total_sales) OVER (
    ORDER BY order_year, order_month
)
```

This is used to compare current-month sales with the previous month.

---

# SQL Views

Reusable analytical views were created in SQL Server.

```text
sales.vw_monthly_sales
sales.vw_order_performance
```

For example, `vw_monthly_sales` provides:

- Total orders
- Total items
- Product revenue
- Freight revenue
- Total sales
- Average item price

### Views vs Analytics SQL

**Views**

Provide reusable database-level analytical datasets.

**Analytics SQL files**

Contain specific analytical queries and business analysis using techniques such as:

- CTE
- Window Functions
- Ranking
- Comparisons

---

# Data Warehouse

Database:

```text
olist_analytics
```

Schema:

```text
dw
```

The analytical model follows a **Star Schema**.

```text
                 Dim_Date
                    |
                    |
Dim_Customer ---- Fact_Sales ---- Dim_Product
                    |
                    |
                 Dim_Seller
```

---

# Fact Table

## `dw.Fact_Sales`

### Grain

> **One row represents one order item.**

Therefore:

```text
order_id + order_item_id
```

identifies one business transaction line.

### Main columns

```text
sales_key
date_key
customer_key
product_key
seller_key
order_id
order_item_id
price
freight_value
total_item_value
```

### Total Item Value

```text
total_item_value = price + freight_value
```

### Payment Design Decision

`order_payments` is **not directly joined** to `Fact_Sales`.

The reason is that one order can contain multiple payment records.

A direct join could create:

```text
1 order item
      +
multiple payment rows
      =
multiple fact rows
```

This would inflate sales metrics.

---

# Dimension Tables

The Data Warehouse contains four dimensions.

## `dw.Dim_Date`

Provides calendar attributes such as:

- Date
- Day
- Month
- Quarter
- Week
- Weekend indicator

---

## `dw.Dim_Customer`

Contains:

```text
customer_key
customer_id
```

`customer_key` is a warehouse-generated surrogate key.

---

## `dw.Dim_Product`

Contains product attributes such as:

- Product ID
- Product category
- Product dimensions
- Product weight
- Product photos quantity
- Product name length
- Product description length

---

## `dw.Dim_Seller`

Contains:

```text
seller_key
seller_id
```

---

# Customer & Seller Data Movement

Customer and seller data originate from PostgreSQL, while the Data Warehouse is hosted in SQL Server.

A lightweight Python bridge is used:

```text
PostgreSQL
    |
    | Python export
    v
data/dw/
    |
    +-- dw_customers.csv
    +-- dw_sellers.csv
    |
    v
SQL Server
    |
    v
DW Dimensions
```

This is a simple bridge between the two DBMSs rather than a full staging architecture.

---

# Import Helper Tables

Two helper tables were used during dimension loading:

```text
dw.Import_Customer
dw.Import_Seller
```

These tables are **not part of the final Star Schema**.

They provide a CSV-shaped target for `BULK INSERT` before loading the actual dimensions.

```text
CSV
 |
 v
Import Table
 |
 | Clean / Transform
 v
Dimension
```

This approach was useful because the CSV contains the business identifier while the dimension also contains a warehouse-generated surrogate key.

---

# Data Validation

Before connecting Power BI, the fact table was validated for:

### 1. Grain

No duplicate:

```text
order_id + order_item_id
```

### 2. Dimension Keys

Checked for missing:

```text
date_key
customer_key
product_key
seller_key
```

### 3. Sales Values

Checked for invalid negative:

```text
price
freight_value
total_item_value
```

### 4. Computed Value

Validated:

```text
total_item_value = price + freight_value
```

---

# Power BI

The Data Warehouse is connected to **Microsoft Power BI Desktop**.

```text
SQL Server
    |
    v
olist_analytics
    |
    +-- dw.Dim_Customer
    +-- dw.Dim_Date
    +-- dw.Dim_Product
    +-- dw.Dim_Seller
    +-- dw.Fact_Sales
```

The project uses the **Import** connectivity mode.

---

# Power BI Report

A Power BI report file (`.pbix`) accompanies this project.

The Power BI file contains:

- Data model
- Relationships
- DAX Measures
- Dashboard visualizations
- Business analysis

Recommended repository structure:

```text
retail-business-intelligence-platform/
|
+-- data/
+-- sql/
+-- src/
+-- README.md
+-- Retail_Business_Intelligence.pbix
+-- docker-compose.yml
```

---

# Power BI Data Model

The Power BI model follows the Star Schema:

```text
                   Dim_Date
                     1
                     |
                     *
                     |
Dim_Customer  1 --- * Fact_Sales * --- 1 Dim_Product
                     *
                     |
                     1
                 Dim_Seller
```

### Relationships

```text
Fact_Sales[customer_key] * : 1 Dim_Customer[customer_key]

Fact_Sales[date_key]     * : 1 Dim_Date[date_key]

Fact_Sales[product_key]  * : 1 Dim_Product[product_key]

Fact_Sales[seller_key]   * : 1 Dim_Seller[seller_key]
```

All four relationships are:

- Active
- Many-to-One (`* : 1`)
- Single-direction filtering

The filtering direction is:

```text
Dimension
    |
    v
Fact
```

---

# DAX Measures — Next Phase

The Power BI data model is now ready for the **DAX Measures** layer.

Planned core measures include:

```text
Total Sales
Total Orders
Total Items
Total Customers
Average Order Value
Average Item Value
Freight Revenue
Product Revenue
MoM Sales Growth
```

The objective is to create reusable measures once and reuse them across multiple Power BI visuals and dashboard pages.

---

# Planned Dashboard Layer

The dashboard will focus on **business questions**, rather than simply displaying charts.

## Executive Sales Overview

Potential KPIs:

- Total Sales
- Total Orders
- Total Items
- Average Order Value
- Monthly Sales Trend
- MoM Growth
- Sales by Product Category

---

## Customer Analysis

Potential analysis:

- Customer Distribution
- Customer Sales Contribution
- Order Frequency
- Geographic Patterns

---

## Product Analysis

Potential analysis:

- Top Products
- Product Categories
- Revenue Contribution
- Product Performance

---

## Seller Analysis

Potential analysis:

- Seller Sales
- Order Volume
- Seller Contribution
- Seller Performance Comparison

---

## Order & Operations Analysis

Potential analysis:

- Order Status
- Delivery Performance
- Freight Contribution
- Order-Level Performance

The final number of dashboard pages will be based on analytical value and portfolio quality.

---

# Project Structure

```text
retail-business-intelligence-platform/
|
+-- data/
|   +-- raw/
|   +-- dw/
|
+-- sql/
|   +-- ddl/
|   +-- analytics/
|       +-- 01_sales_analysis.sql
|       +-- 02_customer_analysis.sql
|       +-- 03_product_analysis.sql
|       +-- 04_order_analysis.sql
|       +-- 05_marketing_analysis.sql
|
+-- src/
|   +-- export_dw.py
|
+-- docker-compose.yml
|
+-- README.md
|
+-- Retail_Business_Intelligence.pbix
```

# Portfolio Deliverables

The final portfolio package will contain:

- SQL source/database scripts
- Analytical SQL queries
- Data Warehouse schema
- Python bridge script
- Power BI `.pbix` report
- README documentation
- Data model / architecture documentation
- Power BI dashboard screenshots
- Business insights and recommendations

---


# Key Learning Outcomes

Through this project, the following practical skills are demonstrated:

### SQL

- Complex SQL queries
- CTEs
- Window Functions
- Aggregation
- Ranking
- Business-oriented analysis

### Data Warehousing

- OLTP vs OLAP
- Fact vs Dimension
- Grain
- Surrogate Keys
- Star Schema
- Source-to-DW mapping

### Power BI

- SQL Server connectivity
- Import mode
- Data modeling
- Relationships
- Star Schema implementation

### DAX

- KPI measures
- Time intelligence
- Growth metrics
- Reusable analytical calculations

### Business Analytics

- KPI design
- Trend analysis
- Customer analysis
- Product analysis
- Seller analysis
- Business insights

