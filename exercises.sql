-- 1. Moyennes
SELECT avg(n) AS avg_orders_per_user
FROM (SELECT user_uuid, count(*) AS n FROM orders GROUP BY user_uuid);
SELECT round(avg(quantity), 2) AS avg_quantity FROM orders;

-- 2. Première/dernière commande par user
SELECT user_uuid, min(date) AS first_order, max(date) AS last_order,
       date_diff('day', min(date), max(date)) AS days_between
FROM orders GROUP BY user_uuid ORDER BY days_between DESC LIMIT 5;

-- 3. Heure la plus vendeuse
SELECT hour(date) AS h, sum(quantity) AS quantity
FROM orders GROUP BY h ORDER BY quantity DESC LIMIT 1;

-- 4. Variation mensuelle par produit
WITH m AS (
  SELECT product, date_trunc('month', date) AS month, sum(quantity) AS q
  FROM orders GROUP BY ALL
)
SELECT product, month, q,
       round(100 * (q - lag(q) OVER w) / lag(q) OVER w, 1) AS pct_change
FROM m WINDOW w AS (PARTITION BY product ORDER BY month)
ORDER BY product, month;

-- 5. Users ayant commandé les 6 produits
SELECT u.username
FROM orders o JOIN users u ON o.user_uuid = u.uuid
GROUP BY u.uuid, u.username
HAVING count(DISTINCT o.product) = (SELECT count(DISTINCT product) FROM orders);
