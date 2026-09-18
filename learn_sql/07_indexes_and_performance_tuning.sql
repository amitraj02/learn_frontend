-- ============================================================================
-- 🎓 LESSON 07: INDEXES, PERFORMANCE TUNING & QUERY EXECUTION PLANS
-- Designed for Algorithmic Trading & High-Performance Data Engineering
-- Instructor: AI Tech Teacher
-- ============================================================================
--
-- 📌 WHAT YOU WILL LEARN TODAY:
--   1. Full Table Scan (O(N)) vs B-Tree Index Search (O(log N))
--   2. Single Column vs Composite (Multi-Column) Indexes
--   3. The Leftmost Prefix Rule (Why column order in an index matters!)
--   4. Covering Indexes: Answering queries 100% inside RAM without touching the table
--   5. How to read `EXPLAIN QUERY PLAN` like a Database Architect
--   6. SQLite Pragmas for High-Frequency Bots: WAL Mode, Synchronous Normal
-- ============================================================================

DROP TABLE IF EXISTS tick_stream;

CREATE TABLE tick_stream (
    tick_id       INTEGER PRIMARY KEY,
    symbol        TEXT NOT NULL,
    ltp           REAL NOT NULL,
    volume        INTEGER NOT NULL,
    received_at   DATETIME NOT NULL
);

-- Insert 10 sample ticks
INSERT INTO tick_stream (tick_id, symbol, ltp, volume, received_at) VALUES
(1,  'RELIANCE', 2940.10, 50,  '2026-03-01 09:15:00.100'),
(2,  'INFY',     1615.00, 100, '2026-03-01 09:15:00.120'),
(3,  'RELIANCE', 2940.25, 25,  '2026-03-01 09:15:00.150'),
(4,  'TCS',      4100.50, 10,  '2026-03-01 09:15:00.200'),
(5,  'RELIANCE', 2940.00, 200, '2026-03-01 09:15:00.250'),
(6,  'INFY',     1615.50, 40,  '2026-03-01 09:15:00.300'),
(7,  'RELIANCE', 2940.50, 150, '2026-03-01 09:15:00.350'),
(8,  'SBIN',      745.00, 300, '2026-03-01 09:15:00.400'),
(9,  'RELIANCE', 2941.00, 500, '2026-03-01 09:15:00.450'),
(10, 'INFY',     1616.00, 80,  '2026-03-01 09:15:00.500');

-- ============================================================================
-- 1. INSPECTING QUERY PLAN BEFORE INDEXING (FULL TABLE SCAN)
-- Notice "SCAN TABLE tick_stream" — The database engine must check EVERY row!
-- ============================================================================
EXPLAIN QUERY PLAN
SELECT symbol, ltp, received_at 
FROM tick_stream 
WHERE symbol = 'RELIANCE' 
  AND received_at >= '2026-03-01 09:15:00.200';

-- ============================================================================
-- 2. CREATING A COMPOSITE INDEX
-- In trading, we almost always filter by SYMBOL + TIMESTAMP simultaneously!
-- ============================================================================
CREATE INDEX idx_ticks_symbol_time ON tick_stream (symbol, received_at);

-- ============================================================================
-- 3. INSPECTING QUERY PLAN AFTER COMPOSITE INDEX
-- Notice "SEARCH TABLE tick_stream USING INDEX idx_ticks_symbol_time (symbol=? AND received_at>?)"
-- ============================================================================
EXPLAIN QUERY PLAN
SELECT symbol, ltp, received_at 
FROM tick_stream 
WHERE symbol = 'RELIANCE' 
  AND received_at >= '2026-03-01 09:15:00.200';

-- Run the optimized query
SELECT symbol, ltp, volume, received_at
FROM tick_stream 
WHERE symbol = 'RELIANCE' 
  AND received_at >= '2026-03-01 09:15:00.200';

-- ============================================================================
-- 4. COVERING INDEX (ZERO TABLE LOOKUP)
-- If all columns in SELECT & WHERE exist in the index, the DB never reads disk!
-- ============================================================================
CREATE INDEX idx_ticks_covering ON tick_stream (symbol, received_at, ltp);

EXPLAIN QUERY PLAN
SELECT symbol, received_at, ltp 
FROM tick_stream 
WHERE symbol = 'INFY';

-- ============================================================================
-- 5. TRADING BOT PRODUCTION TUNING: SQLITE PRAGMAS FOR SPEED
-- When ingesting 500 ticks/second from websocket, these settings prevent lag:
-- ============================================================================
-- Enable Write-Ahead Logging (Allows simultaneous readers and 1 writer without blocking!)
PRAGMA journal_mode = WAL;

-- Normal synchronous mode: 10x faster disk flush, safe from application crashes
PRAGMA synchronous = NORMAL;

-- Keep 64MB memory cache for active queries
PRAGMA cache_size = -64000;

-- Memory temp store for subqueries and sorts
PRAGMA temp_store = MEMORY;
