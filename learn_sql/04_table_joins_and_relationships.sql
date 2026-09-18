-- ============================================================================
-- 🎓 LESSON 04: TABLE JOINS & RELATIONAL DATA MODELING
-- Designed for Algorithmic Trading & High-Performance Data Engineering
-- Instructor: AI Tech Teacher
-- ============================================================================
--
-- 📌 WHAT YOU WILL LEARN TODAY:
--   1. Relational Normalization: Why we split data into multiple tables
--   2. INNER JOIN: Intersection of records (Orders with Executions)
--   3. LEFT OUTER JOIN: Complete left table retention with unmatched right as NULL
--   4. Anti-Join Pattern: Finding missing/unfilled orders via IS NULL
--   5. CROSS JOIN: Generating full Cartesian matrices (e.g. Scrip x Strategy matrix)
--   6. SELF JOIN: Comparing a trade directly against a previous trade
--   7. Multi-Table Joins: Connecting 3+ tables seamlessly
-- ============================================================================

DROP TABLE IF EXISTS executions;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS instruments;

-- 1. Reference Table: Instruments
CREATE TABLE instruments (
    symbol        TEXT PRIMARY KEY,
    name          TEXT NOT NULL,
    sector        TEXT NOT NULL,
    lot_size      INTEGER NOT NULL
);

-- 2. Reference Table: Accounts
CREATE TABLE accounts (
    account_id    TEXT PRIMARY KEY,
    owner_name    TEXT NOT NULL,
    broker        TEXT NOT NULL
);

-- 3. Transactional Table: Orders
CREATE TABLE orders (
    order_id      INTEGER PRIMARY KEY,
    account_id    TEXT NOT NULL REFERENCES accounts(account_id),
    symbol        TEXT NOT NULL REFERENCES instruments(symbol),
    side          TEXT NOT NULL,
    target_qty    INTEGER NOT NULL,
    order_time    DATETIME NOT NULL
);

-- 4. Fill Table: Executions (1 Order can have 0, 1, or MULTIPLE fill executions)
CREATE TABLE executions (
    exec_id       INTEGER PRIMARY KEY,
    order_id      INTEGER NOT NULL REFERENCES orders(order_id),
    fill_qty      INTEGER NOT NULL,
    fill_price    REAL NOT NULL,
    fill_time     DATETIME NOT NULL
);

-- Populate Mock Trading Universe
INSERT INTO instruments VALUES 
('RELIANCE', 'Reliance Industries', 'ENERGY', 1),
('TCS',      'Tata Consultancy Services', 'IT', 1),
('INFY',     'Infosys Ltd', 'IT', 1),
('HDFCBANK', 'HDFC Bank Ltd', 'BANKING', 1),
('ZOMATO',   'Zomato Ltd', 'CONSUMER', 1);

INSERT INTO accounts VALUES
('ACC_01', 'Amit (Algo Main)', 'ZERODHA'),
('ACC_02', 'Prop Desk Alpha', 'INTERACTIVE_BROKERS'),
('ACC_03', 'Hedge Inactive', 'DHAN');

INSERT INTO orders VALUES
(1001, 'ACC_01', 'RELIANCE', 'BUY',  100, '2026-03-01 09:15:00'),
(1002, 'ACC_01', 'TCS',      'BUY',   50, '2026-03-01 09:16:00'),
(1003, 'ACC_02', 'INFY',     'SELL', 200, '2026-03-01 09:17:00'),
(1004, 'ACC_02', 'HDFCBANK', 'BUY',  150, '2026-03-01 09:18:00'),
(1005, 'ACC_01', 'ZOMATO',   'BUY',  500, '2026-03-01 09:19:00');  -- Not filled yet!

-- Multiple fills for order 1001 (Partial fill then completion)
INSERT INTO executions VALUES
(501, 1001, 60, 2950.00, '2026-03-01 09:15:02'),
(502, 1001, 40, 2950.50, '2026-03-01 09:15:05'),
(503, 1002, 50, 4100.00, '2026-03-01 09:16:01'),
(504, 1003, 200, 1620.00, '2026-03-01 09:17:03');
-- Notice: Order 1004 and 1005 have NO rows in executions!

-- ============================================================================
-- 1. INNER JOIN: ONLY ORDERS THAT RECEIVED AT LEAST ONE EXECUTION
-- ============================================================================
SELECT 
    o.order_id,
    o.symbol,
    o.side,
    o.target_qty,
    e.exec_id,
    e.fill_qty,
    e.fill_price,
    e.fill_time
FROM orders o
INNER JOIN executions e ON o.order_id = e.order_id;

-- ============================================================================
-- 2. LEFT OUTER JOIN: ALL ORDERS, REGARDLESS OF WHETHER THEY WERE FILLED
-- Notice how orders 1004 and 1005 show up with NULL execution details!
-- ============================================================================
SELECT 
    o.order_id,
    o.symbol,
    o.target_qty,
    COALESCE(SUM(e.fill_qty), 0) AS total_filled_qty,
    ROUND(AVG(e.fill_price), 2) AS vwap_price,
    CASE 
        WHEN COALESCE(SUM(e.fill_qty), 0) = 0 THEN 'UNFILLED'
        WHEN COALESCE(SUM(e.fill_qty), 0) < o.target_qty THEN 'PARTIAL'
        ELSE 'COMPLETE'
    END AS fill_status
FROM orders o
LEFT JOIN executions e ON o.order_id = e.order_id
GROUP BY o.order_id, o.symbol, o.target_qty;

-- ============================================================================
-- 3. THE ANTI-JOIN: FINDING ALL UNFILLED ORDERS (GHOST ORDERS)
-- We use LEFT JOIN + WHERE right_table.key IS NULL
-- ============================================================================
SELECT 
    o.order_id,
    o.account_id,
    o.symbol,
    o.side,
    o.target_qty,
    o.order_time
FROM orders o
LEFT JOIN executions e ON o.order_id = e.order_id
WHERE e.exec_id IS NULL;

-- ============================================================================
-- 4. MULTI-TABLE JOIN (CONNECTING 4 TABLES IN 1 ANALYTICAL VIEW)
-- Join Accounts -> Orders -> Executions -> Instruments
-- ============================================================================
SELECT 
    a.broker,
    a.owner_name,
    i.sector,
    o.symbol,
    o.side,
    e.fill_qty,
    e.fill_price,
    ROUND(e.fill_qty * e.fill_price, 2) AS execution_value
FROM accounts a
JOIN orders o       ON a.account_id = o.account_id
JOIN instruments i  ON o.symbol = i.symbol
JOIN executions e   ON o.order_id = e.order_id
ORDER BY execution_value DESC;

-- ============================================================================
-- 5. CROSS JOIN: GENERATING A STRATEGY x INSTRUMENT TESTING MATRIX
-- ============================================================================
-- Suppose we have 3 strategies and want to test every strategy against every instrument:
WITH strategies AS (
    SELECT 'MOMENTUM_BREAKOUT' AS strat
    UNION ALL SELECT 'MEAN_REVERSION'
    UNION ALL SELECT 'VOLATILITY_ARBITRAGE'
)
SELECT 
    s.strat AS strategy_name,
    i.symbol,
    i.sector
FROM strategies s
CROSS JOIN instruments i
ORDER BY s.strat, i.symbol;

-- ============================================================================
-- 6. SELF JOIN: COMPARING CONSECUTIVE FILLS ON THE SAME ORDER
-- ============================================================================
-- Compare subsequent fill prices on the same order to detect slippage
SELECT 
    e1.order_id,
    e1.exec_id AS first_fill_id,
    e1.fill_price AS first_fill_price,
    e2.exec_id AS second_fill_id,
    e2.fill_price AS second_fill_price,
    ROUND(e2.fill_price - e1.fill_price, 2) AS price_delta
FROM executions e1
JOIN executions e2 
  ON e1.order_id = e2.order_id 
 AND e1.exec_id < e2.exec_id;
