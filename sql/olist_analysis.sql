-- =============================================================
-- E-commerce SQL Analytics (Olist) — SQLite, DBeaver
-- Author: Monica Venzor
-- Source dataset: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce
-- 
-- Only use six CSV tables:
-- olist_orders_dataset.csv - orders
-- olist_customers_dataset.csv - customers
-- olist_order_items_dataset.csv - order_items
-- olist_order_payments_dataset.csv - order_payments
-- olist_products_dataset.csv - products
-- product_category_name_translation.csv - product_category_name_translation
--
-- Scope:
--   * Pure SQL (no external tools)
--   * KPIs based on DELIVERED orders only
--		 New vs returning customers
--		 Average order value
--		 Most used payment method
--		 Top-selling products
--		 Revenue by month
--   * 6 tables required:
--       orders, customers, order_items, order_payments, products,
--       product_category_name_translation
--
-- How to run:
--   1) Run the SETUP block (indexes + small helper tables) once.
--   2) Run each KPI block independently to get results.
-- =============================================================

/* -------------------------------------------------------------
   0) Quick sanity check
   Ensure we actually have delivered orders to analyze.
--------------------------------------------------------------*/
-- Count delivered orders
SELECT COUNT(*) AS delivered_orders
FROM orders
WHERE order_status = 'delivered';

-- Time range of delivered orders
SELECT MIN(date(order_purchase_timestamp)) AS min_date,
       MAX(date(order_purchase_timestamp)) AS max_date
FROM orders
WHERE order_status = 'delivered';

-- Count unique customers (delivered only)
SELECT COUNT(DISTINCT c.customer_unique_id) AS unique_customers
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
WHERE o.order_status = 'delivered';


/* -------------------------------------------------------------
   1) SETUP — INDEXES + HELPER TABLES
   SQLite speeds up dramatically with the right indexes, and
        prefiltering "delivered" orders into a tiny table avoids
        expensive scans on the big orders table.
--------------------------------------------------------------*/
-- Indexes on base tables
CREATE INDEX IF NOT EXISTS idx_orders_status_ts
  ON orders(order_status, order_purchase_timestamp);
CREATE INDEX IF NOT EXISTS idx_orders_status_id
  ON orders(order_status, order_id);
CREATE INDEX IF NOT EXISTS idx_customers_id
  ON customers(customer_id);
CREATE INDEX IF NOT EXISTS idx_customers_cuid
  ON customers(customer_unique_id);
CREATE INDEX IF NOT EXISTS idx_items_order
  ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_payments_order
  ON order_payments(order_id);

-- Helper table: only delivered orders (small and fast to join)
DROP TABLE IF EXISTS delivered_orders;
CREATE TABLE delivered_orders AS
SELECT
  order_id,
  order_purchase_timestamp
FROM orders
WHERE order_status = 'delivered';

CREATE INDEX IF NOT EXISTS idx_delivered_orders_id
  ON delivered_orders(order_id);

-- Helper table: revenue per order (materialized once)
--     Logic: sum(price + freight) across items for each order.
DROP TABLE IF EXISTS order_revenue;
CREATE TABLE order_revenue AS
SELECT
  i.order_id,
  SUM(CAST(i.price AS REAL) + CAST(i.freight_value AS REAL)) AS order_revenue
FROM order_items i
GROUP BY i.order_id;

CREATE INDEX IF NOT EXISTS idx_order_revenue_id
  ON order_revenue(order_id);

/* ====================================================================
   2) KPI — NEW vs RETURNING CUSTOMERS (monthly)
   Objective: Understand retention by labeling each delivered order as
              the customer's 1st purchase (NEW) or a repeat (RETURNING).
   Why it matters: Shows acquisition vs loyalty dynamics over time.
===================================================================== */

-- oc = delivered orders with real customer id
-- fp = first purchase per customer
WITH oc AS (
  SELECT d.order_id,
         o.order_purchase_timestamp AS ts,
         c.customer_unique_id
  FROM delivered_orders d
  JOIN orders    o ON o.order_id = d.order_id
  JOIN customers c ON c.customer_id = o.customer_id
),
fp AS (
  SELECT customer_unique_id,
         MIN(date(ts)) AS first_date
  FROM oc
  GROUP BY customer_unique_id
)
SELECT
  strftime('%Y-%m', oc.ts) AS month,
  SUM(CASE WHEN date(oc.ts) = fp.first_date THEN 1 ELSE 0 END) AS orders_new,
  SUM(CASE WHEN date(oc.ts) > fp.first_date THEN 1 ELSE 0 END) AS orders_returning,
  printf('%d', SUM(CASE WHEN date(oc.ts) = fp.first_date THEN 1 ELSE 0 END)) AS orders_new_fmt,
  printf('%d', SUM(CASE WHEN date(oc.ts) > fp.first_date THEN 1 ELSE 0 END)) AS orders_ret_fmt
FROM oc
JOIN fp USING (customer_unique_id)
GROUP BY month
ORDER BY month;


/* ====================================================================
   3) KPI — AVERAGE ORDER VALUE (AOV)
   Objective: Measure how much, on average, a customer spends per order.
   Why it matters: Core revenue lever; high AOV often signals higher
                   cross-sell, pricing power, or shipping policies.
===================================================================== */

-- Overall AOV (delivered only)
SELECT ROUND(AVG(r.order_revenue), 2) AS avg_ticket
FROM delivered_orders d
JOIN order_revenue r USING (order_id);


-- AOV by month
SELECT
  strftime('%Y-%m', d.order_purchase_timestamp) AS month,
  ROUND(AVG(r.order_revenue), 2) AS avg_ticket,
  printf('R$ %, .2f', AVG(r.order_revenue)) AS avg_ticket_fmt
FROM delivered_orders d
JOIN order_revenue r USING (order_id)
GROUP BY month
ORDER BY month;

/* ====================================================================
   4) KPI — MOST USED PAYMENT METHOD
   Objective: Identify the dominant payment types, both by order count
              and by total value paid.
   Why it matters: Impacts checkout UX, fees, risk, and conversion.
===================================================================== */

-- By number of orders (use the first payment row per order)
SELECT
  p.payment_type,
  COUNT(*) AS orders_count,
  printf('%d', COUNT(*)) AS orders_count_fmt
FROM delivered_orders d
JOIN order_payments p ON p.order_id = d.order_id
WHERE p.payment_sequential = 1
GROUP BY p.payment_type
ORDER BY orders_count DESC;

-- By total paid value
SELECT
  p.payment_type,
  ROUND(SUM(CAST(p.payment_value AS REAL)), 2) AS total_paid,
  printf('%,.2f', SUM(CAST(p.payment_value AS REAL))) AS total_paid_fmt
FROM delivered_orders d
JOIN order_payments p ON p.order_id = d.order_id
GROUP BY p.payment_type
ORDER BY total_paid DESC;


/* ====================================================================
   5) KPI — TOP-SELLING CATEGORIES (by items sold)
   Objective: See which product categories dominate sales volume.
   Why it matters: Merchandising, inventory, and marketing prioritization.
===================================================================== */

SELECT
  COALESCE(t.product_category_name_english, p.product_category_name) AS category,
  COUNT(*) AS items_sold,
  printf('%d', COUNT(*)) AS items_sold_fmt
FROM delivered_orders d
JOIN order_items i ON i.order_id = d.order_id
JOIN products    p ON p.product_id = i.product_id
LEFT JOIN product_category_name_translation t
       ON t.product_category_name = p.product_category_name
GROUP BY category
ORDER BY items_sold DESC
LIMIT 10;


/* ====================================================================
   6) KPI — REVENUE BY MONTH (from items)
   Objective: Track revenue trend over time.
   Why it matters: Seasonality, growth, and business health.
===================================================================== */

SELECT
  strftime('%Y-%m', d.order_purchase_timestamp) AS month,
  ROUND(SUM(CAST(i.price AS REAL) + CAST(i.freight_value AS REAL)), 2) AS revenue,
  printf('R$ %, .2f', SUM(CAST(i.price AS REAL) + CAST(i.freight_value AS REAL))) AS revenue_fmt
FROM delivered_orders d
JOIN order_items i ON i.order_id = d.order_id
GROUP BY month
ORDER BY month;

