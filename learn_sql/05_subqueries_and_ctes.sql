-- ============================================================================
-- 🎓 LESSON 05: SUBQUERIES & COMMON TABLE EXPRESSIONS (CTEs)
-- Designed for Algorithmic Trading & High-Performance Data Engineering
-- Instructor: AI Tech Teacher
-- ============================================================================
--
-- 📌 WHAT YOU WILL LEARN TODAY:
--   1. Scalar Subqueries: Returning a single dynamic benchmark value
--   2. Multi-Row Subqueries: Using IN, NOT IN with dynamic lists
--   3. Correlated Subqueries: Row-by-row contextual evaluation
--   4. EXISTS vs IN: Why EXISTS excels in performance
--   5. Common Table Expressions (CTEs): The WITH clause for clean, modular SQL
--   6. Chaining Multiple CTEs: Constructing professional data pipelines
--   7. Recursive CTEs: Generating time-series sequences & calendar bars
-- ============================================================================

DROP TABLE IF EXISTS stock_quotes;

CREATE TABLE stock_quotes (
    quote_id      INTEGER PRIMARY KEY,
    symbol        TEXT NOT NULL,
    sector        TEXT NOT NULL,
    current_price REAL NOT NULL,
    pe_ratio      REAL NOT NULL,
    daily_volume  INTEGER NOT NULL,
    quote_time    DATETIME NOT NULL
);

INSERT INTO stock_quotes VALUES
(1,  'RELIANCE',   'ENERGY',  2980.00, 26.4, 4500000, '2026-03-01 15:30:00'),
(2,  'ONGC',       'ENERGY',   275.50,  7.2, 8200000, '2026-03-01 15:30:00'),
(3,  'BPCL',       'ENERGY',   610.20,  6.8, 3100000, '2026-03-01 15:30:00'),
(4,  'TCS',        'IT',      4150.00, 31.0, 1800000, '2026-03-01 15:30:00'),
(5,  'INFY',       'IT',      1630.00, 27.5, 5900000, '2026-03-01 15:30:00'),
(6,  'WIPRO',      'IT',       490.00, 21.0, 4200000, '2026-03-01 15:30:00'),
(7,  'HDFCBANK',   'BANKING', 1445.00, 18.2, 9500000, '2026-03-01 15:30:00'),
(8,  'ICICIBANK',  'BANKING', 1090.00, 17.5, 7800000, '2026-03-01 15:30:00'),
(9,  'SBIN',       'BANKING',  755.00, 10.4, 11200000,'2026-03-01 15:30:00'),
(10, 'SUNPHARMA',  'PHARMA',  1560.00, 38.0, 1400000, '2026-03-01 15:30:00');

-- ============================================================================
-- 1. SCALAR SUBQUERY IN SELECT & WHERE
-- Compare each stock's price against the MARKET AVERAGE price
-- ============================================================================
SELECT 
    symbol,
    sector,
    current_price,
    -- Scalar subquery in SELECT
    ROUND((SELECT AVG(current_price) FROM stock_quotes), 2) AS market_avg_price,
    ROUND(current_price - (SELECT AVG(current_price) FROM stock_quotes), 2) AS diff_from_market_avg
FROM stock_quotes
-- Scalar subquery in WHERE: filter for stocks with above-average trading volume
WHERE daily_volume > (SELECT AVG(daily_volume) FROM stock_quotes)
ORDER BY current_price DESC;

-- ============================================================================
-- 2. CORRELATED SUBQUERY: BENCHMARKING WITHIN EACH SECTOR
-- Find stocks whose P/E ratio is LOWER than their own sector average (Valuation Bargains!)
-- ============================================================================
SELECT 
    outer_q.symbol,
    outer_q.sector,
    outer_q.pe_ratio,
    (
        SELECT ROUND(AVG(inner_q.pe_ratio), 1)
        FROM stock_quotes inner_q
        WHERE inner_q.sector = outer_q.sector
    ) AS sector_avg_pe
FROM stock_quotes outer_q
WHERE outer_q.pe_ratio < (
    SELECT AVG(inner_q.pe_ratio)
    FROM stock_quotes inner_q
    WHERE inner_q.sector = outer_q.sector
)
ORDER BY outer_q.sector, outer_q.pe_ratio ASC;

-- ============================================================================
-- 3. COMMON TABLE EXPRESSIONS (CTEs) — CLEAN CODE ARCHITECTURE
-- The same problem as above, written with CTEs: 10x more readable and maintainable!
-- ============================================================================
WITH sector_benchmarks AS (
    -- Step 1: Calculate aggregate statistics per sector
    SELECT 
        sector,
        ROUND(AVG(pe_ratio), 2) AS avg_sector_pe,
        ROUND(AVG(daily_volume), 0) AS avg_sector_volume
    FROM stock_quotes
    GROUP BY sector
),
undervalued_stocks AS (
    -- Step 2: Join base table with calculated benchmarks
    SELECT 
        sq.symbol,
        sq.sector,
        sq.current_price,
        sq.pe_ratio,
        sb.avg_sector_pe,
        ROUND(((sq.pe_ratio - sb.avg_sector_pe) / sb.avg_sector_pe) * 100.0, 1) AS pe_discount_pct
    FROM stock_quotes sq
    JOIN sector_benchmarks sb ON sq.sector = sb.sector
    WHERE sq.pe_ratio < sb.avg_sector_pe
)
-- Step 3: Final presentation
SELECT * FROM undervalued_stocks
ORDER BY pe_discount_pct ASC;

-- ============================================================================
-- 4. RECURSIVE CTE: GENERATING A 5-MINUTE CANDLE TIME-GRID
-- In algorithmic trading, you often need to detect missing price bars.
-- A recursive CTE can generate continuous minute timestamps automatically!
-- ============================================================================
WITH RECURSIVE trading_minutes(candle_time) AS (
    -- Anchor member: Market open 09:15
    SELECT DATETIME('2026-03-01 09:15:00')
    UNION ALL
    -- Recursive step: Add 5 minutes until 10:00
    SELECT DATETIME(candle_time, '+5 minutes')
    FROM trading_minutes
    WHERE candle_time < '2026-03-01 10:00:00'
)
SELECT 
    candle_time,
    STRFTIME('%H:%M', candle_time) AS time_hh_mm,
    'WAITING_FOR_TICK' AS feed_status
FROM trading_minutes;
