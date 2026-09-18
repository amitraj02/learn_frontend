-- ============================================================================
-- 🎓 LESSON 02: BASIC QUERIES, FILTERING, SORTING & CONDITIONAL PROJECTIONS
-- Designed for Algorithmic Trading & High-Performance Data Engineering
-- Instructor: AI Tech Teacher
-- ============================================================================
--
-- 📌 WHAT YOU WILL LEARN TODAY:
--   1. Projection: Selecting columns, calculating calculated fields (Notional Value)
--   2. Filtering rows with WHERE: Logical operators (AND, OR, NOT)
--   3. Advanced predicates: IN, BETWEEN, LIKE, IS NULL / IS NOT NULL
--   4. Sorting: ORDER BY multiple columns with ASC / DESC
--   5. Pagination: LIMIT and OFFSET for efficient UI feeds
--   6. Conditional Branching: CASE WHEN ... THEN ... ELSE ... END
-- ============================================================================

DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    order_id      INTEGER PRIMARY KEY,
    symbol        TEXT NOT NULL,
    sector        TEXT,
    side          TEXT NOT NULL,
    quantity      INTEGER NOT NULL,
    price         REAL NOT NULL,
    stop_loss     REAL,
    target_price  REAL,
    status        TEXT NOT NULL,
    filled_qty    INTEGER DEFAULT 0,
    placed_at     DATETIME
);

INSERT INTO orders (order_id, symbol, sector, side, quantity, price, stop_loss, target_price, status, filled_qty, placed_at) VALUES
(101, 'RELIANCE',   'ENERGY',  'BUY',  100, 2950.00, 2900.00, 3050.00, 'FILLED',    100, '2026-03-01 09:15:22'),
(102, 'TCS',        'IT',      'BUY',   50, 4120.00, 4050.00, 4250.00, 'FILLED',     50, '2026-03-01 09:18:10'),
(103, 'INFY',       'IT',      'BUY',  150, 1625.50, 1600.00, 1680.00, 'PARTIAL',    75, '2026-03-01 09:20:45'),
(104, 'HDFCBANK',   'BANKING', 'SELL', 200, 1450.00, 1475.00, 1400.00, 'FILLED',    200, '2026-03-01 09:25:00'),
(105, 'ICICIBANK',  'BANKING', 'BUY',  120, 1080.00, 1060.00, 1120.00, 'PENDING',     0, '2026-03-01 09:30:15'),
(106, 'TATAMOTORS', 'AUTO',    'BUY',  300,  980.00,  950.00, 1040.00, 'CANCELLED',   0, '2026-03-01 09:35:40'),
(107, 'SBIN',       'BANKING', 'BUY',  250,  750.00,    NULL,   790.00, 'FILLED',    250, '2026-03-01 09:40:02'),
(108, 'WIPRO',      'IT',      'SELL', 100,  480.00,  495.00,     NULL, 'REJECTED',    0, '2026-03-01 09:42:18'),
(109, 'SUNPHARMA',  'PHARMA',  'BUY',   80, 1540.00, 1500.00, 1620.00, 'FILLED',     80, '2026-03-01 09:45:00'),
(110, 'BAJFINANCE', 'FINANCE', 'BUY',   20, 6800.00, 6650.00, 7100.00, 'FILLED',     20, '2026-03-01 09:50:30');

-- ============================================================================
-- 1. PROJECTION & ARITHMETIC EXPRESSIONS
-- Compute trade turnover (notional value) and potential risk in points
-- ============================================================================
-- Notice how we can create alias names using 'AS' for clean reporting.
SELECT 
    order_id,
    symbol,
    side,
    quantity,
    price,
    stop_loss,
    (quantity * price) AS turnover_value,
    ROUND(price - stop_loss, 2) AS risk_per_share
FROM orders;

-- ============================================================================
-- 2. FILTERING WITH LOGICAL OPERATORS (AND, OR, NOT)
-- Find large IT sector buy orders with turnover exceeding 100,000
-- ============================================================================
SELECT order_id, symbol, sector, side, quantity, price, (quantity * price) AS turnover
FROM orders
WHERE sector = 'IT' 
  AND side = 'BUY' 
  AND (quantity * price) >= 100000;

-- ============================================================================
-- 3. SET MEMBERSHIP WITH 'IN' & 'NOT IN'
-- Filter for banking or energy sectors without typing messy chained ORs
-- ============================================================================
SELECT order_id, symbol, sector, status, price
FROM orders
WHERE sector IN ('BANKING', 'ENERGY')
  AND status NOT IN ('CANCELLED', 'REJECTED');

-- ============================================================================
-- 4. RANGE FILTERING WITH 'BETWEEN ... AND ...'
-- Find stocks priced between 1,000 and 3,000
-- ============================================================================
SELECT order_id, symbol, price, sector
FROM orders
WHERE price BETWEEN 1000.00 AND 3000.00
ORDER BY price ASC;

-- ============================================================================
-- 5. PATTERN MATCHING WITH 'LIKE'
-- Wildcards:
--   '%' matches any sequence of 0 or more characters
--   '_' matches exactly one single character
-- ============================================================================
-- Find all BANK tickers (e.g. HDFCBANK, ICICIBANK)
SELECT order_id, symbol, sector, price
FROM orders
WHERE symbol LIKE '%BANK';

-- ============================================================================
-- 6. THREE-VALUED LOGIC & HANDLING NULL VALUES
-- In SQL, NULL represents unknown data.
-- ⚠️ WRONG:  WHERE stop_loss = NULL   (Will ALWAYS return 0 rows!)
-- ✔️ RIGHT:  WHERE stop_loss IS NULL  or  IS NOT NULL
-- ============================================================================
SELECT 
    order_id, 
    symbol, 
    price, 
    stop_loss,
    COALESCE(stop_loss, price * 0.98) AS fallback_stop_loss  -- 2% default if NULL!
FROM orders
WHERE stop_loss IS NULL;

-- ============================================================================
-- 7. SORTING & PAGINATION (ORDER BY, LIMIT, OFFSET)
-- Get the top 3 highest turnover filled orders
-- ============================================================================
SELECT 
    order_id,
    symbol,
    quantity,
    price,
    (quantity * price) AS total_turnover
FROM orders
WHERE status = 'FILLED'
ORDER BY total_turnover DESC
LIMIT 3 OFFSET 0;

-- ============================================================================
-- 8. CONDITIONAL PROJECTIONS WITH 'CASE WHEN'
-- Classify order sizes into Small, Medium, Institutional blocks
-- ============================================================================
SELECT 
    order_id,
    symbol,
    quantity,
    price,
    (quantity * price) AS turnover,
    CASE 
        WHEN (quantity * price) >= 200000 THEN 'INSTITUTIONAL / LARGE'
        WHEN (quantity * price) >= 80000  THEN 'MEDIUM'
        ELSE 'RETAIL / SMALL'
    END AS order_tier,
    CASE 
        WHEN status = 'FILLED' THEN '🟢 Executed'
        WHEN status = 'PARTIAL' THEN '🟡 In-Flight'
        WHEN status = 'PENDING' THEN '🔵 In-Queue'
        ELSE '🔴 Inactive'
    END AS status_badge
FROM orders
ORDER BY turnover DESC;
