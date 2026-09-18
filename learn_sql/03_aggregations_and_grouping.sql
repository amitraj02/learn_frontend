-- ============================================================================
-- 🎓 LESSON 03: AGGREGATIONS, GROUPING & THE SQL EXECUTION PIPELINE
-- Designed for Algorithmic Trading & High-Performance Data Engineering
-- Instructor: AI Tech Teacher
-- ============================================================================
--
-- 📌 WHAT YOU WILL LEARN TODAY:
--   1. Aggregate Functions: COUNT(*), COUNT(col), COUNT(DISTINCT), SUM, AVG, MIN, MAX
--   2. The GROUP BY Clause: Slicing rows into analytical buckets
--   3. The HAVING Clause: Post-aggregation filtering (vs WHERE pre-aggregation)
--   4. Filtered Aggregations using CASE WHEN (e.g., Win Rate, Profit Factor)
--   5. The exact 8-step SQL Execution Pipeline
-- ============================================================================

DROP TABLE IF EXISTS bot_trades;

CREATE TABLE bot_trades (
    trade_id      INTEGER PRIMARY KEY,
    strategy_name TEXT NOT NULL,
    symbol        TEXT NOT NULL,
    trade_date    DATE NOT NULL,
    entry_price   REAL NOT NULL,
    exit_price    REAL NOT NULL,
    quantity      INTEGER NOT NULL,
    net_pnl       REAL NOT NULL,
    brokerage     REAL NOT NULL
);

INSERT INTO bot_trades (trade_id, strategy_name, symbol, trade_date, entry_price, exit_price, quantity, net_pnl, brokerage) VALUES
(1,  'EMA_CROSSOVER', 'RELIANCE', '2026-03-01', 2900.0, 2940.0, 100,  4000.00, 40.0),
(2,  'EMA_CROSSOVER', 'INFY',     '2026-03-01', 1600.0, 1590.0, 200, -2000.00, 40.0),
(3,  'EMA_CROSSOVER', 'TCS',      '2026-03-02', 4000.0, 4080.0,  50,  4000.00, 40.0),
(4,  'EMA_CROSSOVER', 'HDFCBANK', '2026-03-02', 1420.0, 1410.0, 150, -1500.00, 40.0),
(5,  'RSI_SCALPER',   'RELIANCE', '2026-03-01', 2920.0, 2935.0, 200,  3000.00, 40.0),
(6,  'RSI_SCALPER',   'INFY',     '2026-03-01', 1610.0, 1618.0, 300,  2400.00, 40.0),
(7,  'RSI_SCALPER',   'RELIANCE', '2026-03-02', 2950.0, 2940.0, 150, -1500.00, 40.0),
(8,  'RSI_SCALPER',   'SBIN',     '2026-03-02',  740.0,  748.0, 400,  3200.00, 40.0),
(9,  'GAP_FADE',      'TATAMOTORS','2026-03-01', 960.0,  985.0, 250,  6250.00, 40.0),
(10, 'GAP_FADE',      'BAJFINANCE','2026-03-02', 6700.0, 6620.0,  30, -2400.00, 40.0);

-- ============================================================================
-- 1. OVERALL PORTFOLIO SUMMARY AGGREGATION
-- Calculate Total Trades, Unique Symbols, Total PnL, Win Count, Total Brokerage
-- ============================================================================
SELECT 
    COUNT(*) AS total_trades,
    COUNT(DISTINCT symbol) AS unique_symbols_traded,
    ROUND(SUM(net_pnl), 2) AS gross_portfolio_pnl,
    ROUND(SUM(brokerage), 2) AS total_brokerage_paid,
    ROUND(SUM(net_pnl) - SUM(brokerage), 2) AS net_take_home_profit,
    ROUND(AVG(net_pnl), 2) AS average_pnl_per_trade,
    MAX(net_pnl) AS biggest_winner,
    MIN(net_pnl) AS biggest_loser
FROM bot_trades;

-- ============================================================================
-- 2. GROUP BY: PERFORMANCE METRICS BY STRATEGY
-- Which strategy is making money, and which strategy is losing?
-- ============================================================================
SELECT 
    strategy_name,
    COUNT(*) AS total_trades,
    ROUND(SUM(net_pnl), 2) AS total_pnl,
    ROUND(AVG(net_pnl), 2) AS avg_trade_pnl,
    ROUND(SUM(brokerage), 2) AS total_brokerage
FROM bot_trades
GROUP BY strategy_name
ORDER BY total_pnl DESC;

-- ============================================================================
-- 3. THE CRITICAL DIFFERENCE: WHERE vs HAVING
-- 
-- 🧠 TEACHER'S RULE:
--   WHERE filters individual rows BEFORE they are grouped.
--   HAVING filters aggregated summary groups AFTER they are computed.
-- ============================================================================

-- Find strategies that have a net PnL greater than 4,000 on trades where entry_price >= 1000
SELECT 
    strategy_name,
    COUNT(*) AS trade_count,
    ROUND(SUM(net_pnl), 2) AS strategy_pnl
FROM bot_trades
WHERE entry_price >= 1000.00      -- Step 1: WHERE filters row-level entries
GROUP BY strategy_name            -- Step 2: Bucket by strategy
HAVING SUM(net_pnl) > 4000.00     -- Step 3: HAVING filters only profitable groups!
ORDER BY strategy_pnl DESC;

-- ============================================================================
-- 4. ADVANCED: CONDITIONAL AGGREGATION (CALCULATING WIN RATE & PROFIT FACTOR)
-- We embed CASE WHEN inside SUM() to calculate trading metrics in 1 single pass!
-- ============================================================================
SELECT 
    strategy_name,
    COUNT(*) AS total_trades,
    
    -- Count of winning trades
    SUM(CASE WHEN net_pnl > 0 THEN 1 ELSE 0 END) AS wins,
    
    -- Count of losing trades
    SUM(CASE WHEN net_pnl <= 0 THEN 1 ELSE 0 END) AS losses,
    
    -- Win Rate %
    ROUND(100.0 * SUM(CASE WHEN net_pnl > 0 THEN 1 ELSE 0 END) / COUNT(*), 1) AS win_rate_pct,
    
    -- Gross Profits & Gross Losses
    ROUND(SUM(CASE WHEN net_pnl > 0 THEN net_pnl ELSE 0 END), 2) AS gross_profit,
    ROUND(ABS(SUM(CASE WHEN net_pnl < 0 THEN net_pnl ELSE 0 END)), 2) AS gross_loss,
    
    -- Profit Factor = Gross Profit / Gross Loss
    ROUND(
        SUM(CASE WHEN net_pnl > 0 THEN net_pnl ELSE 0 END) / 
        NULLIF(ABS(SUM(CASE WHEN net_pnl < 0 THEN net_pnl ELSE 0 END)), 0),
        2
    ) AS profit_factor

FROM bot_trades
GROUP BY strategy_name
ORDER BY profit_factor DESC;

-- ============================================================================
-- 5. MULTI-LEVEL GROUPING (STRATEGY & DATE)
-- Breakdown performance day by day per strategy
-- ============================================================================
SELECT 
    trade_date,
    strategy_name,
    COUNT(*) AS trades_today,
    ROUND(SUM(net_pnl), 2) AS daily_pnl
FROM bot_trades
GROUP BY trade_date, strategy_name
ORDER BY trade_date ASC, daily_pnl DESC;
