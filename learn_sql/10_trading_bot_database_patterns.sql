-- ============================================================================
-- 🎓 LESSON 10: PRODUCTION TRADING BOT DATABASE PATTERNS & OHLC RESAMPLING
-- Designed for Algorithmic Trading & High-Performance Data Engineering
-- Instructor: AI Tech Teacher
-- ============================================================================
--
-- 📌 WHAT YOU WILL LEARN TODAY:
--   1. Complete Database Architecture for an Algorithmic Trading Bot
--   2. Raw Ticks Table (High throughput websocket feed ingestion)
--   3. Resampling Raw Ticks into 1-Minute OHLCV Candles in Pure SQL!
--   4. Order State Machine: Transitions from CREATED -> SUBMITTED -> FILLED
--   5. Position Book: Tracking Net Open Positions and Unrealized PnL
--   6. Trade Journal & Performance Statistics
-- ============================================================================

DROP TABLE IF EXISTS positions;
DROP TABLE IF EXISTS execution_log;
DROP TABLE IF EXISTS raw_ticks;

-- 1. RAW TICKS FEED TABLE (Optimized for append-only streaming)
CREATE TABLE raw_ticks (
    tick_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    symbol      TEXT NOT NULL,
    ltp         REAL NOT NULL,
    volume      INTEGER NOT NULL,
    timestamp   DATETIME NOT NULL
);

-- 2. POSITIONS TABLE (Current state of active open inventory)
CREATE TABLE positions (
    position_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    symbol        TEXT NOT NULL UNIQUE,
    net_quantity  INTEGER NOT NULL DEFAULT 0,
    avg_price     REAL NOT NULL DEFAULT 0.0,
    current_ltp   REAL NOT NULL DEFAULT 0.0,
    realized_pnl  REAL NOT NULL DEFAULT 0.0,
    updated_at    DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Seed 1-minute worth of raw ticks for RELIANCE (between 09:15:00 and 09:15:59)
INSERT INTO raw_ticks (symbol, ltp, volume, timestamp) VALUES
('RELIANCE', 2940.00, 100, '2026-03-01 09:15:01'), -- Open
('RELIANCE', 2942.50, 250, '2026-03-01 09:15:12'),
('RELIANCE', 2945.00, 500, '2026-03-01 09:15:25'), -- High
('RELIANCE', 2938.00, 300, '2026-03-01 09:15:40'), -- Low
('RELIANCE', 2943.50, 150, '2026-03-01 09:15:58'), -- Close

-- Next minute ticks (09:16:00 to 09:16:59)
('RELIANCE', 2944.00,  80, '2026-03-01 09:16:05'), -- Open
('RELIANCE', 2948.00, 400, '2026-03-01 09:16:20'), -- High
('RELIANCE', 2941.00, 120, '2026-03-01 09:16:35'), -- Low
('RELIANCE', 2946.00, 200, '2026-03-01 09:16:55'); -- Close

-- ============================================================================
-- 1. PURE SQL OHLC RESAMPLING (RAW TICKS -> 1-MINUTE CANDLES)
-- Resamples thousands of raw ticks into Open, High, Low, Close, Volume bars!
-- ============================================================================
WITH tick_ranked AS (
    SELECT 
        symbol,
        ltp,
        volume,
        -- Group into 1-minute buckets by trimming seconds
        STRFTIME('%Y-%m-%d %H:%M:00', timestamp) AS candle_minute,
        ROW_NUMBER() OVER (PARTITION BY symbol, STRFTIME('%Y-%m-%d %H:%M:00', timestamp) ORDER BY timestamp ASC)  AS asc_rank,
        ROW_NUMBER() OVER (PARTITION BY symbol, STRFTIME('%Y-%m-%d %H:%M:00', timestamp) ORDER BY timestamp DESC) AS desc_rank
    FROM raw_ticks
)
SELECT 
    candle_minute,
    symbol,
    -- First tick of the minute is the OPEN
    MAX(CASE WHEN asc_rank = 1 THEN ltp END) AS [open],
    -- Highest tick of the minute is the HIGH
    MAX(ltp) AS [high],
    -- Lowest tick of the minute is the LOW
    MIN(ltp) AS [low],
    -- Last tick of the minute is the CLOSE
    MAX(CASE WHEN desc_rank = 1 THEN ltp END) AS [close],
    -- Total volume transacted during the minute
    SUM(volume) AS total_volume
FROM tick_ranked
GROUP BY candle_minute, symbol
ORDER BY candle_minute ASC;

-- ============================================================================
-- 2. LIVE MARK-TO-MARKET (MTM) UNREALIZED PnL QUERY
-- Calculate live unrealized profit or loss dynamically against current market price
-- ============================================================================
INSERT INTO positions (symbol, net_quantity, avg_price, current_ltp, realized_pnl) VALUES
('RELIANCE', 100, 2920.00, 2946.00, 1500.00),
('INFY',    -50, 1630.00, 1615.00,  800.00); -- Short position!

SELECT 
    symbol,
    net_quantity,
    avg_price,
    current_ltp,
    -- Unrealized PnL: For Longs (LTP - Avg)*Qty; For Shorts (Avg - LTP)*ABS(Qty)
    ROUND(net_quantity * (current_ltp - avg_price), 2) AS unrealized_pnl,
    realized_pnl,
    ROUND((net_quantity * (current_ltp - avg_price)) + realized_pnl, 2) AS total_mtm_pnl,
    CASE 
        WHEN net_quantity > 0 THEN 'LONG'
        WHEN net_quantity < 0 THEN 'SHORT'
        ELSE 'FLAT'
    END AS position_side
FROM positions;
