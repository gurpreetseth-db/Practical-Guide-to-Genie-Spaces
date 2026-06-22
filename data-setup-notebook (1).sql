-- Databricks notebook source
-- MAGIC %md
-- MAGIC # Pinnacle Retail - Genie Workshop Data Setup
-- MAGIC **Run all cells in order. Takes ~2 minutes.**
-- MAGIC
-- MAGIC Creates: 100 customers, 20 products, 10,000+ orders, 25,000+ order line items

-- COMMAND ----------

-- Create the catalog and schema
CREATE CATALOG IF NOT EXISTS genie_workshop;
USE CATALOG genie_workshop;
CREATE SCHEMA IF NOT EXISTS pinnacle_retail;
USE SCHEMA pinnacle_retail;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Table 1: Customers (100 rows)

-- COMMAND ----------

CREATE OR REPLACE TABLE customers (
  customer_id INT NOT NULL COMMENT 'Unique identifier for each customer account. Primary key. Range: 1001–1100.',
  full_name STRING COMMENT 'Legal company name or individual buyer name. This is the primary display name used in all reports.',
  email STRING COMMENT 'Primary contact email for the customer account. Format: name@company.com.',
  segment STRING COMMENT 'Customer tier based on annual spend. Values: Enterprise (>$80K/yr), Mid-Market ($20K–$80K), SMB ($5K–$20K), Consumer (<$5K). Enterprise customers are our highest-value accounts with dedicated account managers.',
  region STRING COMMENT 'US geographic sales region. Values: North (IL, MI, MN, WI, OH), South (TX, FL, GA, TN, NC, LA), East (NY, MA, PA, DC, MD, CT, VA, NJ, RI), West (CA, WA, OR, CO, AZ, NV, UT). Used for territory-based reporting.',
  city STRING COMMENT 'Customer''s primary office city. 35 unique cities across the US.',
  state STRING COMMENT 'Two-letter US state abbreviation. Example: CA, NY, TX.',
  signup_date DATE COMMENT 'Date the customer first created their account. Range: mid-2022 to mid-2024. Used for cohort analysis and customer tenure calculations.',
  lifetime_value DECIMAL(12,2) COMMENT 'Total cumulative revenue from this customer across all historical orders, in USD. Enterprise customers typically have LTV > $80K. This is a pre-calculated summary field, not a real-time aggregate.',
  is_active BOOLEAN COMMENT 'True if the customer has placed at least one order in the last 12 months. False means the customer is considered churned. Approximately 10% of customers are inactive.'
)
COMMENT 'Master customer table for Pinnacle Retail. Each row represents one customer account.

Customers are classified into four segments based on annual spend:
- Enterprise: annual spend > $80K (our largest accounts, ~20% of customer base)
- Mid-Market: annual spend $20K–$80K (growth segment, ~30%)
- SMB: annual spend $5K–$20K (long-tail, ~30%)
- Consumer: annual spend < $5K (individual buyers, ~20%)

Customers span four US geographic regions (North, South, East, West) across 35 cities.

The is_active flag indicates whether a customer has placed an order in the last 12 months. Inactive customers (is_active = false) are considered churned. Approximately 10% of customers are inactive.

Use this table for any customer-level analysis: segmentation, regional breakdown, lifetime value ranking, active/churned analysis.';

-- Generate 100 customers using a CTE approach
INSERT INTO customers
WITH customer_names AS (
  SELECT * FROM VALUES
    (1, 'Acme Corp'), (2, 'Beta Industries'), (3, 'Cascade Solutions'), (4, 'Delta LLC'),
    (5, 'Echo Ventures'), (6, 'Foxtrot Inc'), (7, 'Gamma Tech'), (8, 'Horizon Group'),
    (9, 'Ionic Systems'), (10, 'Jade Retail'), (11, 'Kappa Foods'), (12, 'Luna Brands'),
    (13, 'Metro Direct'), (14, 'Nova Partners'), (15, 'Omega Supply'), (16, 'Pinnacle Labs'),
    (17, 'Quantum Data'), (18, 'Ridgeline Corp'), (19, 'Summit Analytics'), (20, 'Titan Logistics'),
    (21, 'Unity Health'), (22, 'Vertex Capital'), (23, 'Wavelength Media'), (24, 'Xenon Energy'),
    (25, 'Yellowstone Mfg'), (26, 'Zenith Software'), (27, 'Alpine Networks'), (28, 'Beacon Digital'),
    (29, 'Compass Group'), (30, 'Dynamo Services'), (31, 'Evergreen Retail'), (32, 'Falcon Security'),
    (33, 'Granite Systems'), (34, 'Harbinger AI'), (35, 'Impulse Media'), (36, 'Jetstream Cloud'),
    (37, 'Keystone Finance'), (38, 'Lighthouse Data'), (39, 'Magnet CRM'), (40, 'Nebula Insights'),
    (41, 'Orion Healthcare'), (42, 'Prism Analytics'), (43, 'Quartz Semiconductor'), (44, 'Redwood IoT'),
    (45, 'Stellar Payments'), (46, 'Tundra Supply'), (47, 'Uplift Education'), (48, 'Vanguard Tech'),
    (49, 'Wildfire Games'), (50, 'Xcelerate AI'), (51, 'Yarrow Biotech'), (52, 'Zephyr Telecom'),
    (53, 'Atlas Freight'), (54, 'Blueshift Labs'), (55, 'Citadel Defense'), (56, 'Driftwood Media'),
    (57, 'Ember Analytics'), (58, 'Frostbyte Security'), (59, 'Glow Cosmetics'), (60, 'Halcyon Health'),
    (61, 'Inferno Games'), (62, 'Jupiter Pharma'), (63, 'Kinetic Robotics'), (64, 'Luminary Design'),
    (65, 'Mosaic Insurance'), (66, 'Northstar Consulting'), (67, 'Oasis Hospitality'), (68, 'Paragon Legal'),
    (69, 'Quicksilver Trading'), (70, 'Riverstone Mining'), (71, 'Sapphire Banking'), (72, 'Thunderbolt Mfg'),
    (73, 'Ultraviolet Media'), (74, 'Venture Prime'), (75, 'Whitewater Logistics'), (76, 'Xylem Agriculture'),
    (77, 'Yellowjacket Sports'), (78, 'Zodiac Aerospace'), (79, 'Anchor Marine'), (80, 'Brimstone Energy'),
    (81, 'Crescent Foods'), (82, 'Daybreak Solar'), (83, 'Echelon Defense'), (84, 'Firefly Drones'),
    (85, 'Glacier Storage'), (86, 'Helix Genomics'), (87, 'Ironclad Cyber'), (88, 'Juniper Networks Co'),
    (89, 'Kestrel Aviation'), (90, 'Lantern Pharma'), (91, 'Meridian Finance'), (92, 'Nexus Retail'),
    (93, 'Obsidian Security'), (94, 'Phoenix Renewables'), (95, 'Quorum Health'), (96, 'Rampart Defense'),
    (97, 'Sequoia Ventures'), (98, 'Torrent Streaming'), (99, 'Umbra Intelligence'), (100, 'Valor Aerospace')
  AS t(id, name)
),
segments AS (
  SELECT * FROM VALUES
    ('Enterprise', 0.20), ('Mid-Market', 0.30), ('SMB', 0.30), ('Consumer', 0.20)
  AS t(segment, weight)
),
regions AS (
  SELECT * FROM VALUES
    ('North', 'Chicago', 'IL'), ('North', 'Detroit', 'MI'), ('North', 'Minneapolis', 'MN'), ('North', 'Milwaukee', 'WI'), ('North', 'Columbus', 'OH'),
    ('South', 'Austin', 'TX'), ('South', 'Miami', 'FL'), ('South', 'Atlanta', 'GA'), ('South', 'Nashville', 'TN'), ('South', 'Dallas', 'TX'),
    ('South', 'Charlotte', 'NC'), ('South', 'Houston', 'TX'), ('South', 'Tampa', 'FL'), ('South', 'New Orleans', 'LA'), ('South', 'Raleigh', 'NC'),
    ('East', 'New York', 'NY'), ('East', 'Boston', 'MA'), ('East', 'Philadelphia', 'PA'), ('East', 'Washington', 'DC'), ('East', 'Baltimore', 'MD'),
    ('East', 'Pittsburgh', 'PA'), ('East', 'Hartford', 'CT'), ('East', 'Richmond', 'VA'), ('East', 'Newark', 'NJ'), ('East', 'Providence', 'RI'),
    ('West', 'San Francisco', 'CA'), ('West', 'Seattle', 'WA'), ('West', 'Portland', 'OR'), ('West', 'Denver', 'CO'), ('West', 'Phoenix', 'AZ'),
    ('West', 'Los Angeles', 'CA'), ('West', 'San Diego', 'CA'), ('West', 'Las Vegas', 'NV'), ('West', 'Salt Lake City', 'UT'), ('West', 'Sacramento', 'CA')
  AS t(region, city, state)
)
SELECT
  1000 + cn.id AS customer_id,
  cn.name AS full_name,
  CONCAT(LOWER(REPLACE(cn.name, ' ', '.')), '@company.com') AS email,
  CASE
    WHEN cn.id <= 20 THEN 'Enterprise'
    WHEN cn.id <= 50 THEN 'Mid-Market'
    WHEN cn.id <= 80 THEN 'SMB'
    ELSE 'Consumer'
  END AS segment,
  r.region,
  r.city,
  r.state,
  DATE_ADD('2022-06-01', CAST(cn.id * 3.65 + HASH(cn.name) % 180 AS INT) % 730) AS signup_date,
  ROUND(
    CASE
      WHEN cn.id <= 20 THEN 80000 + (HASH(cn.name) % 200000)
      WHEN cn.id <= 50 THEN 20000 + (HASH(cn.name) % 60000)
      WHEN cn.id <= 80 THEN 5000 + (HASH(cn.name) % 18000)
      ELSE 1000 + (HASH(cn.name) % 5000)
    END, 2) AS lifetime_value,
  CASE WHEN cn.id % 10 != 0 THEN true ELSE false END AS is_active
FROM customer_names cn
CROSS JOIN (SELECT region, city, state, ROW_NUMBER() OVER (ORDER BY region, city) AS rn FROM regions) r
WHERE r.rn = (cn.id % 35) + 1;

-- COMMAND ----------

SELECT segment, COUNT(*) AS cnt, ROUND(AVG(lifetime_value), 2) AS avg_ltv
FROM customers GROUP BY segment ORDER BY segment;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Table 2: Products (20 rows)

-- COMMAND ----------

CREATE OR REPLACE TABLE products (
  product_id INT NOT NULL COMMENT 'Unique identifier for each product. Primary key. Range: 2001–2020.',
  product_name STRING COMMENT 'Display name of the product. Examples: CloudSync Pro, AI Analytics Suite, SecureShield Firewall. Use exact product names when filtering.',
  category STRING COMMENT 'Top-level product grouping. Values: Software, Hardware, Services, Accessories, Electronics. Software and Services tend to have the highest margins.',
  subcategory STRING COMMENT 'Detailed product classification within a category. Examples: SaaS Platform, Database, Analytics, Networking, Security, Support, Consulting, Training. Useful for drill-down analysis within a category.',
  unit_price DECIMAL(10,2) COMMENT 'List price / MSRP in USD. This is the published catalog price BEFORE any negotiation. Range: $89.99 (Wireless Keyboard) to $4,999.99 (Implementation Package). Do NOT use this for revenue calculations — use order_items.unit_price instead which reflects the actual negotiated sale price.',
  cost_price DECIMAL(10,2) COMMENT 'Cost of goods sold (COGS) per unit in USD. What Pinnacle Retail pays the supplier. Used for gross margin calculations: margin = sale_price - cost_price.',
  is_active BOOLEAN COMMENT 'True if the product is currently sold. False for discontinued products (e.g., CloudSync Lite, product_id 2004). Discontinued products appear in historical orders. Filter to is_active = true for "current catalog" queries.',
  launch_date DATE COMMENT 'Date the product was first made available for sale. Range: 2023-01-01 to 2024-09-01. Products launched in 2024 will have fewer historical orders.'
)
COMMENT 'Product catalog for Pinnacle Retail. Contains all products ever sold, including discontinued items.

Products span 5 categories with varying price points and margins:
- Software (5 products): SaaS platforms, databases, analytics, security — highest margins (~60-70%)
- Hardware (5 products): networking, security appliances, servers, edge computing, IoT — moderate margins (~40-50%)
- Services (4 products): support plans, consulting, training, managed services — variable margins
- Accessories (4 products): docks, keyboards, webcams, headsets — lower price points, good margins
- Electronics (2 products): monitors, portable power — mid-range pricing

Key pricing columns:
- unit_price: the list price / MSRP for the product
- cost_price: what Pinnacle Retail pays for the product (COGS)
- Gross margin = unit_price - cost_price (at list price, before any negotiation)

Products with is_active = false have been discontinued (e.g., CloudSync Lite was replaced by CloudSync Pro). Discontinued products still appear in historical orders but should not be included in "current product catalog" queries.';

INSERT INTO products VALUES
-- Software (5 products)
(2001, 'CloudSync Pro',          'Software',     'SaaS Platform',    499.99,   150.00, true,  '2023-01-01'),
(2002, 'DataVault Enterprise',   'Software',     'Database',        1299.99,   400.00, true,  '2023-03-15'),
(2003, 'AI Analytics Suite',     'Software',     'Analytics',       2499.99,   800.00, true,  '2023-06-01'),
(2004, 'CloudSync Lite',         'Software',     'SaaS Platform',     99.99,    30.00, false, '2023-01-01'),
(2005, 'CyberGuard Endpoint',   'Software',     'Security',         799.99,   250.00, true,  '2024-03-01'),
-- Hardware (5 products)
(2006, 'SmartHub Router',        'Hardware',     'Networking',       249.99,   120.00, true,  '2023-02-01'),
(2007, 'SecureShield Firewall',  'Hardware',     'Security',         899.99,   450.00, true,  '2023-04-01'),
(2008, 'EdgeCompute Module',     'Hardware',     'Edge Computing',   599.99,   280.00, true,  '2024-01-15'),
(2009, 'ProServer Rack',        'Hardware',     'Server',          3499.99,  1800.00, true,  '2024-06-01'),
(2010, 'IoT Gateway Hub',       'Hardware',     'IoT',              349.99,   160.00, true,  '2024-09-01'),
-- Services (4 products)
(2011, 'Premium Support Plan',   'Services',     'Support',          199.99,    80.00, true,  '2023-01-01'),
(2012, 'Implementation Package', 'Services',     'Consulting',      4999.99,  2500.00, true,  '2023-01-01'),
(2013, 'Training Bootcamp',     'Services',     'Training',        2999.99,  1200.00, true,  '2024-02-01'),
(2014, 'Managed SOC Service',   'Services',     'Security Ops',    1499.99,   700.00, true,  '2024-07-01'),
-- Accessories (4 products)
(2015, 'USB-C Dock Pro',        'Accessories',  'Docking Station',  149.99,    60.00, true,  '2023-05-01'),
(2016, 'Wireless Keyboard Elite','Accessories', 'Input Devices',     89.99,    35.00, true,  '2023-07-01'),
(2017, '4K Webcam Ultra',       'Accessories',  'Video',            179.99,    75.00, true,  '2024-01-01'),
(2018, 'Noise-Cancel Headset',  'Accessories',  'Audio',            249.99,   100.00, true,  '2024-04-01'),
-- Electronics (2 products)
(2019, 'SmartDisplay 27"',      'Electronics',  'Monitors',         549.99,   250.00, true,  '2024-05-01'),
(2020, 'Portable Power Station', 'Electronics', 'Power',            399.99,   180.00, true,  '2024-08-01');

-- COMMAND ----------

SELECT category, COUNT(*) AS products, ROUND(AVG(unit_price), 2) AS avg_price
FROM products GROUP BY category ORDER BY category;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Table 3: Orders (10,000+ rows)
-- MAGIC Uses recursive generation with realistic distributions:
-- MAGIC - Enterprise customers order more frequently
-- MAGIC - Seasonal patterns (Q4 spike, Q1 dip)
-- MAGIC - 75% Completed, 10% Pending, 10% Cancelled, 5% Refunded

-- COMMAND ----------

CREATE OR REPLACE TABLE orders (
  order_id INT NOT NULL COMMENT 'Unique identifier for each order. Primary key. Auto-generated sequential number starting at 3001.',
  customer_id INT COMMENT 'Foreign key to customers.customer_id. Identifies which customer placed this order. One customer can have many orders.',
  order_date DATE COMMENT 'Date the order was placed. Range: 2024-01-01 to 2025-09-30. Shows seasonal patterns with Q4 spikes and Q1 dips. Used for time-series analysis, trending, and fiscal period grouping.',
  status STRING COMMENT 'Current order status. Values: Completed (fulfilled + paid, ~75%), Pending (awaiting processing, ~10%), Cancelled (cancelled before fulfillment, ~10%), Refunded (returned after fulfillment, ~5%). ONLY use Completed orders for revenue and financial metrics.',
  shipping_method STRING COMMENT 'How the order was shipped. Values: Standard (ground, 5-7 days), Express (2-3 days), Digital (instant delivery for software/services), Overnight (next day, premium). Software products often ship Digital.',
  discount_pct DECIMAL(5,2) COMMENT 'Order-level discount as a percentage (0 to ~25). Applied to ALL line items equally. A value of 10.00 means 10% off. Enterprise customers average 10-15% discounts. Consumer customers rarely get discounts. Formula: net_price = unit_price * (1 - discount_pct/100). ',
  notes STRING COMMENT 'Free-text notes from the sales rep. Values include: ''Renewal order'', ''Expansion deal'', ''Volume discount applied'', ''Urgent deployment'', or NULL (~65% of orders have no notes). Useful for categorizing order intent.'
) 
COMMENT 'Order header table. One row per customer order. Links to customers via customer_id.

CRITICAL BUSINESS RULES:
- Revenue calculations must ONLY include orders with status = 'Completed'
- Cancelled and Refunded orders should be EXCLUDED from revenue, margin, and volume metrics
- Pending orders are in-progress and should be excluded from financial metrics but can be counted for operational reporting

Status definitions:
- Completed: order fulfilled and payment received
- Pending: order placed but awaiting PO approval, payment, or fulfillment
- Cancelled: order cancelled before fulfillment (no revenue impact)
- Refunded: order was fulfilled but customer received a full refund (negative revenue impact in some reports, but typically excluded)

The discount_pct is the percentage discount applied to ALL line items in this order (0 to 100 scale). A value of 15 means 15% off. Enterprise customers typically receive larger discounts (5-25%) than SMB or Consumer customers (0-8%).

Line item revenue formula: order_items.quantity * order_items.unit_price * (1 - orders.discount_pct / 100)

Orders span January 2024 through September 2025. Enterprise customers order more frequently than Consumer customers. There are seasonal patterns: Q4 (Nov-Dec) has higher volumes, Q1 (Jan-Feb) has lower volumes';

-- Generate 10,000+ orders across Jan 2024 - Sep 2025
-- Uses ABS(HASH()) % N instead of RAND(seed) to avoid SEED_EXPRESSION_IS_UNFOLDABLE error
INSERT INTO orders
WITH date_range AS (
  SELECT EXPLODE(SEQUENCE(DATE('2024-01-01'), DATE('2025-09-30'), INTERVAL 1 DAY)) AS order_date
),
customer_ids AS (
  SELECT customer_id, segment FROM customers WHERE is_active = true
),
-- Generate multiple orders per day with realistic volume
daily_orders AS (
  SELECT
    d.order_date,
    c.customer_id,
    c.segment,
    -- Deterministic pseudo-random value 0-999 per (date, customer) pair
    ABS(HASH(CONCAT(CAST(d.order_date AS STRING), '-', CAST(c.customer_id AS STRING)))) % 1000 AS h_val,
    -- Separate hash for discount decisions
    ABS(HASH(CONCAT(CAST(d.order_date AS STRING), '-', CAST(c.customer_id AS STRING), '-disc'))) % 1000 AS h_disc,
    -- Separate hash for discount amount
    ABS(HASH(CONCAT(CAST(d.order_date AS STRING), '-', CAST(c.customer_id AS STRING), '-amt'))) % 1000 AS h_disc_amt,
    -- Separate hash for notes
    ABS(HASH(CONCAT(CAST(d.order_date AS STRING), '-', CAST(c.customer_id AS STRING), '-note'))) % 1000 AS h_note,
    -- More orders on weekdays, seasonal spikes
    CASE
      WHEN DAYOFWEEK(d.order_date) IN (1, 7) THEN 0.5  -- weekends
      WHEN MONTH(d.order_date) IN (11, 12) THEN 1.8     -- Q4 spike
      WHEN MONTH(d.order_date) IN (1, 2) THEN 0.7       -- Q1 dip
      ELSE 1.0
    END AS seasonal_weight,
    -- Enterprise orders more frequently
    CASE
      WHEN c.segment = 'Enterprise' THEN 3.0
      WHEN c.segment = 'Mid-Market' THEN 1.5
      WHEN c.segment = 'SMB' THEN 0.8
      ELSE 0.4
    END AS segment_weight
  FROM date_range d
  CROSS JOIN customer_ids c
)
SELECT
  ROW_NUMBER() OVER (ORDER BY order_date, customer_id) + 3000 AS order_id,
  customer_id,
  order_date,
  -- Status distribution: ~91% Completed, ~5% Pending, ~1% Cancelled, ~2% Refunded
  CASE
    WHEN h_val %100 < 75 THEN 'Completed'
    WHEN h_val %100 < 85 THEN 'Pending'
    WHEN h_val %100 < 95 THEN 'Cancelled'
    ELSE 'Refunded'
  END AS status,
  -- Shipping method distribution
  CASE
    WHEN h_val % 100 < 35 THEN 'Standard'
    WHEN h_val % 100 < 60 THEN 'Express'
    WHEN h_val % 100 < 75 THEN 'Digital'
    ELSE 'Overnight'
  END AS shipping_method,
  -- Discount: Enterprise gets more discounts, higher values
  ROUND(
    CASE
      WHEN segment = 'Enterprise' AND h_disc < 600
        THEN 5.0 + (h_disc_amt / 1000.0) * 20.0
      WHEN segment = 'Mid-Market' AND h_disc < 400
        THEN 3.0 + (h_disc_amt / 1000.0) * 12.0
      WHEN h_disc < 200
        THEN 2.0 + (h_disc_amt / 1000.0) * 8.0
      ELSE 0
    END, 2) AS discount_pct,
  -- Notes for some orders
  CASE
    WHEN h_note < 150 THEN 'Renewal order'
    WHEN h_note < 250 THEN 'Expansion deal'
    WHEN h_note < 300 THEN 'Volume discount applied'
    WHEN h_note < 350 THEN 'Urgent deployment'
    ELSE NULL
  END AS notes
FROM daily_orders
WHERE h_val < (seasonal_weight * segment_weight * 140)  -- Controls total volume ~10K+
ORDER BY order_date, customer_id;

-- COMMAND ----------

-- Verify order counts
SELECT
  COUNT(*) AS total_orders,
  COUNT(DISTINCT customer_id) AS unique_customers,
  MIN(order_date) AS earliest,
  MAX(order_date) AS latest,
  COUNT(CASE WHEN status = 'Completed' THEN 1 END) AS completed,
  COUNT(CASE WHEN status = 'Pending' THEN 1 END) AS pending,
  COUNT(CASE WHEN status = 'Cancelled' THEN 1 END) AS cancelled,
  COUNT(CASE WHEN status = 'Refunded' THEN 1 END) AS refunded
FROM orders;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Table 4: Order Items (25,000+ rows)
-- MAGIC Each order gets 1-5 line items with realistic product and quantity distributions

-- COMMAND ----------

CREATE OR REPLACE TABLE order_items (
  order_item_id INT NOT NULL,
  order_id INT COMMENT 'Foreign key to orders.order_id',
  product_id INT COMMENT 'Foreign key to products.product_id',
  quantity INT,
  unit_price DECIMAL(10,2) COMMENT 'Price at time of sale (may differ from product list price due to negotiation)'
);

-- Generate 2-3 line items per order with varied products
-- Uses ABS(HASH()) % N instead of RAND(seed) to avoid SEED_EXPRESSION_IS_UNFOLDABLE error
INSERT INTO order_items
WITH order_products AS (
  SELECT
    o.order_id,
    o.customer_id,
    c.segment,
    p.product_id,
    p.unit_price AS list_price,
    p.category,
    -- Deterministic pseudo-random values using HASH modulo
    ABS(HASH(CONCAT(CAST(o.order_id AS STRING), '-', CAST(p.product_id AS STRING)))) % 1000 AS h_val,
    ABS(HASH(CONCAT(CAST(o.order_id AS STRING), '-', CAST(p.product_id AS STRING), '-qty'))) % 1000 AS h_qty,
    ABS(HASH(CONCAT(CAST(o.order_id AS STRING), '-', CAST(p.product_id AS STRING), '-px'))) % 1000 AS h_px,
    -- Enterprise buys more expensive products (affinity as 0-1000 scale)
    CASE
      WHEN c.segment = 'Enterprise' AND p.category IN ('Software', 'Services') THEN 700
      WHEN c.segment = 'Enterprise' AND p.category = 'Hardware' THEN 500
      WHEN c.segment = 'Mid-Market' AND p.category IN ('Software', 'Hardware') THEN 500
      WHEN c.segment = 'SMB' AND p.unit_price < 1000 THEN 500
      WHEN c.segment = 'Consumer' AND p.unit_price < 500 THEN 600
      ELSE 150
    END AS product_affinity
  FROM orders o
  JOIN customers c ON o.customer_id = c.customer_id
  CROSS JOIN products p
  WHERE p.is_active = true
)
SELECT
  ROW_NUMBER() OVER (ORDER BY order_id, product_id) + 4000 AS order_item_id,
  order_id,
  product_id,
  -- Quantity varies by segment and product type
  GREATEST(1, CAST(
    CASE
      WHEN segment = 'Enterprise' THEN 3 + (h_qty / 1000.0) * 25
      WHEN segment = 'Mid-Market' THEN 2 + (h_qty / 1000.0) * 12
      WHEN segment = 'SMB' THEN 1 + (h_qty / 1000.0) * 6
      ELSE 1 + (h_qty / 1000.0) * 3
    END AS INT)) AS quantity,
  -- Negotiated price: 0-15% off list for Enterprise, 0-8% for others
  ROUND(list_price * (1.0 -
    CASE
      WHEN segment = 'Enterprise' THEN (h_px / 1000.0) * 0.15
      WHEN segment = 'Mid-Market' THEN (h_px / 1000.0) * 0.08
      ELSE (h_px / 1000.0) * 0.03
    END), 2) AS unit_price
FROM order_products
WHERE h_val < product_affinity
  AND h_val < 250;  -- Limits to ~2-3 items per order

-- COMMAND ----------

-- Verify line item counts
SELECT
  COUNT(*) AS total_line_items,
  COUNT(DISTINCT order_id) AS orders_with_items,
  ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT order_id), 1) AS avg_items_per_order,
  ROUND(SUM(quantity * unit_price), 2) AS gross_merchandise_value
FROM order_items;

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Add Constraints (Primary Keys & Foreign Keys)
-- MAGIC These are automatically picked up by Genie as join relationships.

-- COMMAND ----------

ALTER TABLE customers ADD CONSTRAINT pk_customers PRIMARY KEY (customer_id);
ALTER TABLE products ADD CONSTRAINT pk_products PRIMARY KEY (product_id);
ALTER TABLE orders ADD CONSTRAINT pk_orders PRIMARY KEY (order_id);
ALTER TABLE order_items ADD CONSTRAINT pk_order_items PRIMARY KEY (order_item_id);

ALTER TABLE orders ADD CONSTRAINT fk_orders_customers
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id);
ALTER TABLE order_items ADD CONSTRAINT fk_items_orders
  FOREIGN KEY (order_id) REFERENCES orders(order_id);
ALTER TABLE order_items ADD CONSTRAINT fk_items_products
  FOREIGN KEY (product_id) REFERENCES products(product_id);

-- COMMAND ----------

-- MAGIC %md
-- MAGIC ## Final Verification - Data Summary

-- COMMAND ----------

SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items;

-- COMMAND ----------

-- Revenue by segment (sanity check)
SELECT
  c.segment,
  COUNT(DISTINCT c.customer_id) AS customers,
  COUNT(DISTINCT o.order_id) AS orders,
  ROUND(SUM(oi.quantity * oi.unit_price * (1 - o.discount_pct / 100.0)), 2) AS total_revenue,
  ROUND(AVG(oi.quantity * oi.unit_price * (1 - o.discount_pct / 100.0)), 2) AS avg_line_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'Completed'
GROUP BY c.segment
ORDER BY total_revenue DESC;

-- COMMAND ----------

-- Monthly order trend (sanity check)
SELECT
  DATE_FORMAT(order_date, 'yyyy-MM') AS month,
  COUNT(*) AS orders,
  COUNT(CASE WHEN status = 'Completed' THEN 1 END) AS completed,
  COUNT(CASE WHEN status = 'Pending' THEN 1 END) AS Pending,
  COUNT(CASE WHEN status = 'Cancelled' THEN 1 END) AS Cancelled,
  COUNT(CASE WHEN status = 'Refunded' THEN 1 END) AS Refunded  
FROM orders
GROUP BY DATE_FORMAT(order_date, 'yyyy-MM')
ORDER BY month;
