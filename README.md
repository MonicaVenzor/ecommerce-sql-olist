# 🛒 E-commerce SQL Analytics — Olist Dataset (SQLite + DBeaver)

**Author:** Monica Venzor  
**Role:** Data Analyst (Portfolio Project)  
**Tools:** SQLite, DBeaver  
**Goal:** Analyze e-commerce performance using only SQL

---

## 🎯 Project Overview

This project explores real e-commerce data from **Olist (Brazilian marketplace on Kaggle)**, focusing on sales, customers, and payments.  
The challenge: extract **business insights** using only SQL queries and present them clearly.

### Key business questions
1. Who are our **new vs returning customers** over time?  
2. What’s the **average order value (AOV)** per month?  
3. Which **payment methods** are most popular?  
4. Which **product categories** sell the most?  
5. How does **monthly revenue** evolve over time?

---

## ⚙️ Dataset & Preparation

- Source: [Olist Brazilian E-commerce Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

- Tables used:
- olist_orders_dataset.csv - `orders`
- olist_customers_dataset.csv - `customers`
- olist_order_items_dataset.csv - `order_items`
- olist_order_payments_dataset.csv - `order_payments`
- olist_products_dataset.csv - `products`
- product_category_name_translation.csv - `product_category_name_translation`

**Steps performed:**
1. Imported CSVs into **SQLite** via **DBeaver**.  
2. Created indexes and helper tables for performance.  
3. Focused on `order_status = 'delivered'` to ensure data accuracy.  
4. Built reusable SQL queries for each KPI.

---

## 🧠 Business KPIs & Insights

### 🧩 1️⃣ New vs Returning Customers
This analysis compares first-time buyers vs repeat customers by month.  
It reveals that **Olist steadily grew its customer base** — both new and returning users increased significantly through 2017–2018.

📸 *Result:*

![New vs Returning Customers](results/KPI%201%20New%20vs%20returning%20customers.png)

💡 **Insight:** Repeat customers become increasingly relevant in late 2017–2018, showing growing brand trust and retention.

---

### 💰 2️⃣ Average Order Value (AOV)
Measures how much a customer spends per order — a key profitability metric.

📸 *Result (Overall & Monthly):*

![AOV overall](results/KPI%202%20%20Average%20order%20value.png)

![AOV by month](results/KPI%202%20Average%20order%20value%20by%20month.png)

- **Overall AOV:** R$ **159.83**
- Monthly values stay between **R$ 150–170**, suggesting consistent pricing and customer spend.

💡 **Insight:** The AOV stability implies healthy, predictable margins and effective upselling consistency.

---

### 💳 3️⃣ Payment Methods
Understanding preferred payment types helps optimize checkout and conversion.

📸 *Results:*

![Most used payment method](results/KPI%203%20Most%20used%20payment%20method.png)

![Total paid per method](results/KPI%203%20Total%20paid%20for%20payment%20method.png)

- **Credit card:** 74,275 orders → R$ 12.1M  
- **Boleto (bank slip):** 19,190 orders → R$ 2.7M  
- **Voucher & debit:** smaller share

💡 **Insight:** Credit cards clearly dominate, indicating high digital adoption and secure transaction confidence in Olist’s platform.

---

### 🏷️ 4️⃣ Top-Selling Categories
Highlights product categories with the most units sold.

📸 *Result:*

![Top categories](results/KPI%204%20Top%20selling%20products.png)

Top categories:
1. bed_bath_table  
2. health_beauty  
3. sports_leisure  
4. furniture_decor  
5. computers_accessories

💡 **Insight:** Home and lifestyle products lead — typical of a marketplace focused on comfort and self-care.

---

### 📈 5️⃣ Revenue by Month
Shows total sales trend combining product prices and freight costs.

📸 *Result:*

![Revenue by month](results/KPI%205%20Revenue%20by%20month.png)

💡 **Insight:** Revenue grew consistently during 2017–2018, peaking mid-2018 — possibly linked to seasonality and marketing campaigns.

---

## 🔍 Technical Highlights

- 100% SQL analysis (no external tools)
- Optimized with **indexes and helper tables**
- Used **CTEs** (`WITH`) for cleaner logic and better readability
- Added formatted outputs (`printf('R$ %, .2f')`) for presentation
- All queries are included in [`sql/olist_analysis.sql`](sql/olist_analysis.sql)

---

## 💡 Key Takeaways

- **Customer growth**: steady increase in both new and returning users.  
- **AOV stability**: consistent spend per order (≈ R$160).  
- **Payment preference**: credit cards dominate by far.  
- **Category mix**: home, beauty, and tech drive sales.  
- **Revenue trend**: strong upward trajectory through 2018.

---

## 🚀 About the Analyst

👩‍💻 **Monica Venzor**  
Biotechnology professional transitioning into **Data Analytics**.  
I combine my scientific background with data-driven thinking to uncover insights and support strategic decisions.  
Currently building a portfolio in **SQL, Excel, and Python**, focused on practical, business-oriented projects.  

📬 [LinkedIn](https://www.linkedin.com/in/monicavenzor/) | [GitHub](https://github.com/MonicaVenzor)  

---

## 🧩 Repository Structure

ecommerce-sql-olist/
├── README.md
├── sql/
│ └── olist_analysis.sql
└── results/
├── KPI 1 New vs returning customers.png
├── KPI 2 Average order value.png
├── KPI 2 Average order value by month.png
├── KPI 3 Most used payment method.png
├── KPI 3 Total paid for payment method.png
├── KPI 4 Top selling products.png
└── KPI 5 Revenue by month.png

### 🗨️ Final Note
This project demonstrates how **structured SQL logic + clear storytelling** can generate meaningful insights — even without dashboards or advanced visualization tools.

> “Data tells a story. SQL gives it a voice.” 💬
