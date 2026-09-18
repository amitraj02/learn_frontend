-- ============================================================================
-- 🎓 LESSON 06: WINDOW FUNCTIONS & FINANCIAL TIME-SERIES ANALYTICS
-- Designed for Algorithmic Trading & High-Performance Data Engineering
-- Instructor: AI Tech Teacher
-- ============================================================================
--
-- 📌 WHAT YOU WILL LEARN TODAY:
--   1. Window Functions vs GROUP BY: Why Window Functions keep individual rows
--   2. The OVER Clause: PARTITION BY, ORDER BY, and Window Framing
--   3. Ranking: ROW_NUMBER(), RANK(), DENSE_RANK() (Top Gainers per Sector)
--   4. Price Action Shifts: LAG() & LEAD() for Bar Returns & Momentum
--   5. Rolling Indicators: 3-Period Simple Moving Average (SMA) via ROWS BETWEEN
--   6. Portfolio Equity Curve & Running Peak Drawdown Calculation
-- ============================================================================

DROP TABLE IF EXISTS daily_candles;
DROP TABLE IF EXISTS daily_pnl;

-- 1. Candle Data
CREATE TABLE daily_candles (
    bar_id     INTEGER PRIMARY KEY,
    symbol     TEXT NOT NULL,
    trade_date DATE NOT NULL,
    close_price REAL NOT NULL,
    volume     INTEGER NOT NULL
);

INSERT INTO daily_candles VALUES
(1,  'RELIANCE', '2026-03-01', 2900.00, 1200000),
(2,  'RELIANCE', '2026-03-02', 2930.00, 1450000),
(3,  'RELIANCE', '2026-03-03', 2915.00,  980000),
(4,  'RELIANCE', '2026-03-04', 2980.00, 2100000),
(5,  'RELIANCE', '2026-03-05', 3010.00, 1800000),
(6,  'INFY',     '2026-03-01', 1600.00,  800000),
(7,  'INFY',     '2026-03-02', 1620.00,  950000),
(8,  'INFY',     '2026-03-03', 1595.00,  720000),
(9,  'INFY',     '2026-03-04', 1640.00, 1300000),
(10, 'INFY',     '2026-03-05', 1660.00, 1100000);

-- 2. Daily Portfolio Performance
CREATE TABLE daily_pnl (
    day_id     INTEGER PRIMARY KEY,
    trade_date DATE NOT NULL,
    day_pnl    REAL NOT NULL
);

INSERT INTO daily_pnl VALUES
(1, '2026-03-01',  15000.00),
(2, '2026-03-02',  22000.00),
(3, '2026-03-03',  -8000.00),
(4, '2026-03-04', -12000.00),
(5, '2026-03-05',  31000.00),
(6, '2026-03-06',   5000.00);

-- ============================================================================
-- 1. RANKING FUNCTIONS: ROW_NUMBER(), RANK(), DENSE_RANK()
-- Identify the highest volume trading days for each stock
-- ============================================================================
SELECT 
    symbol,
    trade_date,
    volume,
    ROW_NUMBER() OVER (PARTITION BY symbol ORDER BY volume DESC) AS volume_row_num,
    RANK()       OVER (PARTITION BY symbol ORDER BY volume DESC) AS volume_rank
FROM daily_candles;

-- ============================================================================
-- 2. MOMENTUM & RETURNS USING LAG() AND LEAD()
-- Calculate Daily Return % = ((Close - Previous Close) / Previous Close) * 100
-- ============================================================================
SELECT 
    symbol,
    trade_date,
    close_price,
    -- Look back 1 candle row within the same symbol partition
    LAG(close_price, 1) OVER (PARTITION BY symbol ORDER BY trade_date ASC) AS prev_close,
    
    -- Absolute change in points
    ROUND(close_price - LAG(close_price, 1) OVER (PARTITION BY symbol ORDER BY trade_date ASC), 2) AS point_change,
    
    -- Percentage Return %
    ROUND(
        (close_price - LAG(close_price, 1) OVER (PARTITION BY symbol ORDER BY trade_date ASC)) / 
        LAG(close_price, 1) OVER (PARTITION BY symbol ORDER BY trade_date ASC) * 100.0,
        2
    ) AS return_pct
FROM daily_candles;

-- ============================================================================
-- 3. TECHNICAL INDICATOR: 3-PERIOD SIMPLE MOVING AVERAGE (SMA 3)
-- Using Window Frame: ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
-- ============================================================================
SELECT 
    symbol,
    trade_date,
    close_price,
    ROUND(
        AVG(close_price) OVER (
            PARTITION BY symbol 
            ORDER BY trade_date ASC 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS sma_3_period
FROM daily_candles;

-- ============================================================================
-- 4. PORTFOLIO EQUITY CURVE & MAXIMUM DRAWDOWN (MDD) CALCULATION
-- Cumulative Running Total & Running High Watermark (Peak Equity)
-- ============================================================================
WITH equity_progression AS (
    SELECT 
        trade_date,
        day_pnl,
        -- Running Total PnL (Starting capital 500,000)
        500000.0 + SUM(day_pnl) OVER (ORDER BY trade_date ASC) AS current_equity
    FROM daily_pnl
),
drawdown_analysis AS (
    SELECT 
        trade_date,
        day_pnl,
        current_equity,
        -- Running Peak (Highest equity seen so far)
        MAX(current_equity) OVER (ORDER BY trade_date ASC) AS peak_equity
    FROM equity_progression
)
SELECT 
    trade_date,
    day_pnl,
    current_equity,
    peak_equity,
    ROUND(current_equity - peak_equity, 2) AS drawdown_amount,
    ROUND(((current_equity - peak_equity) / peak_equity) * 100.0, 2) AS drawdown_pct
FROM drawdown_analysis;
