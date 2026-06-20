-- =====================================================
-- QUERY 1: Average price by brand
-- What it does: extracts brand from product name
-- and shows pricing stats per brand
-- =====================================================
SELECT
  SPLIT(Product_name, ' ')[OFFSET(0)] AS brand,
  COUNT(*)                             AS total_laptops,
  ROUND(AVG(price), 2)                 AS avg_price,
  ROUND(MIN(price), 2)                 AS cheapest,
  ROUND(MAX(price), 2)                 AS most_expensive
FROM `celtic-bivouac-453916-n6.ecommerce_prices.product_prices`
GROUP BY brand
ORDER BY avg_price ASC;

-- =====================================================
-- QUERY 2: Price range breakdown
-- What it does: categorizes laptops into budget tiers
-- Used by: product and marketing teams
-- =====================================================
SELECT
  CASE
    WHEN price < 500  THEN 'Budget (under $500)'
    WHEN price < 800  THEN 'Mid-range ($500-$800)'
    WHEN price < 1100 THEN 'Premium ($800-$1100)'
    ELSE                   'Luxury (above $1100)'
  END AS price_category,
  COUNT(*) AS total_laptops,
  ROUND(AVG(price), 2) AS avg_price
FROM `celtic-bivouac-453916-n6.ecommerce_prices.product_prices`
GROUP BY price_category
ORDER BY avg_price ASC;

-- =====================================================
-- QUERY 3: Top 10 cheapest laptops
-- =====================================================
SELECT
  Product_name,
  price,
  crawled_at
FROM `celtic-bivouac-453916-n6.ecommerce_prices.product_prices`
ORDER BY price ASC
LIMIT 10;

-- =====================================================
-- QUERY 4: Top 10 most expensive laptops
-- =====================================================
SELECT
  Product_name,
  price,
  crawled_at
FROM `celtic-bivouac-453916-n6.ecommerce_prices.product_prices`
ORDER BY price DESC
LIMIT 10;

-- =====================================================
-- QUERY 5: Total market summary
-- =====================================================
SELECT
  COUNT(*)             AS total_products,
  ROUND(AVG(price), 2) AS avg_price,
  ROUND(MIN(price), 2) AS lowest_price,
  ROUND(MAX(price), 2) AS highest_price,
  ROUND(SUM(price), 2) AS total_market_value
FROM `celtic-bivouac-453916-n6.ecommerce_prices.product_prices`;