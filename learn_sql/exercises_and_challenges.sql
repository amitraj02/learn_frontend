-- ============================================================================
-- 🎓 SQL MASTERCLASS: EXERCISES, CHALLENGES & SOLUTIONS
-- Designed for Algorithmic Trading & High-Performance Data Engineering
-- Instructor: AI Tech Teacher
-- ============================================================================
--
-- Instructions:
--   Try writing the SQL query for each challenge on your own before reading the solution.
--   Run this entire script via:
--       python3 learn_sql/practice_runner.py --lesson exercises
-- ============================================================================

DROP TABLE IF EXISTS portfolio_trades;

CREATE TABLE portfolio_trades (
    trade_id     INTEGER PRIMARY KEY,
    symbol       TEXT NOT NULL,
    sector       TEXT NOT NULL,
    trade_type   TEXT NOT NULL,
    shares       INTEGER NOT NULL,
    entry_price  REAL NOT NULL,
    exit_price   REAL NOT NULL,
    trade_date   DATE NOT NULL
);

INSERT INTO portfolio_trades VALUES
(1,  'RELIANCE',   'ENERGY',  'LONG',  100, 2900.0, 2960.0, '2026-03-01'),
(2,  'INFY',       'IT',      'LONG',  200, 1600.0, 1580.0, '2026-03-01'),
(3,  'TCS',        'IT',      'SHORT',  50, 4100.0, 4020.0, '2026-03-01'),
(4,  'HDFCBANK',   'BANKING', 'LONG',  150, 1420.0, 1450.0, '2026-03-02'),
(5,  'ICICIBANK',  'BANKING', 'LONG',  120, 1080.0, 1070.0, '2026-03-02'),
(6,  'TATAMOTORS', 'AUTO',    'LONG',  300,  950.0,  990.0, '2026-03-02'),
(7,  'SBIN',       'BANKING', 'SHORT', 250,  760.0,  745.0, '2026-03-03'),
(8,  'SUNPHARMA',  'PHARMA',  'LONG',   80, 1520.0, 1560.0, '2026-03-03'),
(9,  'BAJFINANCE', 'FINANCE', 'LONG',   30, 6800.0, 6650.0, '2026-03-03'),
(10, 'WIPRO',      'IT',      'LONG',  250,  490.0,  505.0, '2026-03-03');

-- ============================================================================
-- 🟢 CHALLENGE 1 (EASY): PROFIT / LOSS CALCULATION
-- Question: Calculate P&L for each trade. 
-- For LONG trades: (exit_price - entry_price) * shares
-- For SHORT trades: (entry_price - exit_price) * shares
-- ============================================================================
-- SOLUTION:
SELECT 
    trade_id,
    symbol,
    trade_type,
    shares,
    entry_price,
    exit_price,
    CASE 
        WHEN trade_type = 'LONG'  THEN (exit_price - entry_price) * shares
        WHEN trade_type = 'SHORT' THEN (entry_price - exit_price) * shares
    END AS pnl
FROM portfolio_trades;

-- ============================================================================
-- 🟢 CHALLENGE 2 (EASY): TOP 3 WINNERS
-- Question: Find the top 3 trades with the highest absolute profit.
-- ============================================================================
-- SOLUTION:
WITH trade_pnl AS (
    SELECT 
        trade_id,
        symbol,
        trade_type,
        CASE 
            WHEN trade_type = 'LONG'  THEN (exit_price - entry_price) * shares
            WHEN trade_type = 'SHORT' THEN (entry_price - exit_price) * shares
        END AS pnl
    FROM portfolio_trades
)
SELECT * FROM trade_pnl
ORDER BY pnl DESC
LIMIT 3;

-- ============================================================================
-- 🟡 CHALLENGE 3 (MEDIUM): SECTOR AGGREGATION & WIN RATE
-- Question: Calculate total PnL and Win Rate % grouped by Sector.
-- ============================================================================
-- SOLUTION:
WITH calculated_pnl AS (
    SELECT 
        sector,
        CASE 
            WHEN trade_type = 'LONG'  THEN (exit_price - entry_price) * shares
            WHEN trade_type = 'SHORT' THEN (entry_price - exit_price) * shares
        END AS pnl
    FROM portfolio_trades
)
SELECT 
    sector,
    COUNT(*) AS total_trades,
    ROUND(SUM(pnl), 2) AS total_sector_pnl,
    ROUND(100.0 * SUM(CASE WHEN pnl > 0 THEN 1 ELSE 0 END) / COUNT(*), 1) AS win_rate_pct
FROM calculated_pnl
GROUP BY sector
ORDER BY total_sector_pnl DESC;

-- ============================================================================
-- 🔴 CHALLENGE 4 (HARD): RUNNING CUMULATIVE PnL OVER TIME
-- Question: Show a day-by-day running total of portfolio profit over time.
-- ============================================================================
-- SOLUTION:
WITH daily_agg AS (
    SELECT 
        trade_date,
        SUM(
            CASE 
                WHEN trade_type = 'LONG'  THEN (exit_price - entry_price) * shares
                WHEN trade_type = 'SHORT' THEN (entry_price - exit_price) * shares
            END
        ) AS day_total_pnl
    FROM portfolio_trades
    GROUP BY trade_date
)
SELECT 
    trade_date,
    day_total_pnl,
    SUM(day_total_pnl) OVER (ORDER BY trade_date ASC) AS running_portfolio_pnl
FROM daily_agg;

-- ============================================================================
-- 🟣 CHALLENGE 5 (EXPERT): DENSE RANK PER SECTOR
-- Question: Within each sector, rank trades from highest to lowest PnL.
-- ============================================================================
-- SOLUTION:
WITH scored_trades AS (
    SELECT 
        trade_id,
        symbol,
        sector,
        CASE 
            WHEN trade_type = 'LONG'  THEN (exit_price - entry_price) * shares
            WHEN trade_type = 'SHORT' THEN (entry_price - exit_price) * shares
        END AS pnl
    FROM portfolio_trades
)
SELECT 
    sector,
    symbol,
    pnl,
    DENSE_RANK() OVER (PARTITION BY sector ORDER BY pnl DESC) AS rank_in_sector
FROM scored_trades
ORDER BY sector, rank_in_sector ASC;
