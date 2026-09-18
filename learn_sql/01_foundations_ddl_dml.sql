-- ============================================================================
-- 🎓 LESSON 01: SQL FOUNDATIONS, DDL (DATA DEFINITION) & DML (DATA MANIPULATION)
-- Designed for Algorithmic Trading & High-Performance Data Engineering
-- Instructor: AI Tech Teacher
-- ============================================================================
--
-- 📌 WHAT YOU WILL LEARN TODAY:
--   1. What is a Relational Database (RDBMS) & why it matters for trading bots
--   2. DDL (Data Definition Language): CREATE, ALTER, DROP, TRUNCATE
--   3. Data Types & Storage Optimization (INTEGER, REAL, TEXT, BLOB, TIMESTAMP)
--   4. Integrity Constraints (PRIMARY KEY, FOREIGN KEY, NOT NULL, UNIQUE, CHECK, DEFAULT)
--   5. DML (Data Manipulation Language): INSERT, UPDATE, DELETE, UPSERT (ON CONFLICT)
-- ============================================================================

-- Clean up any prior test tables (Idempotent script execution)
DROP TABLE IF EXISTS trade_executions;
DROP TABLE IF EXISTS trading_accounts;
DROP TABLE IF EXISTS market_instruments;

-- ============================================================================
-- PART 1: DDL — DESIGNING A TRADING ENGINE SCHEMA WITH STRICT CONSTRAINTS
-- ============================================================================
-- Concept: In financial databases, bad data leads to bad trades.
-- We enforce business rules directly at the database engine level using constraints.

CREATE TABLE market_instruments (
    -- PRIMARY KEY uniquely identifies each scrip/instrument
    instrument_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    
    -- UNIQUE ensures no two rows have the same ticker symbol
    symbol          TEXT NOT NULL UNIQUE,
    
    -- Segment of market (NSE Cash, NFO Derivatives, MCX Commodities)
    exchange_segment TEXT NOT NULL,
    
    -- CHECK constraint ensures tick_size and lot_size are strictly positive numbers
    lot_size        INTEGER NOT NULL DEFAULT 1 CHECK (lot_size > 0),
    tick_size       REAL NOT NULL DEFAULT 0.05 CHECK (tick_size > 0.0),
    
    -- Status flag
    is_tradable     INTEGER NOT NULL DEFAULT 1 CHECK (is_tradable IN (0, 1)),
    
    -- Audit timestamp in ISO8601 UTC format
    created_at      DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE trading_accounts (
    account_id      TEXT PRIMARY KEY,
    broker_name     TEXT NOT NULL,
    account_type    TEXT NOT NULL CHECK (account_type IN ('PAPER', 'LIVE')),
    current_cash    REAL NOT NULL CHECK (current_cash >= 0.0),  -- Margin cannot be negative!
    allocated_margin REAL NOT NULL DEFAULT 0.0,
    updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE trade_executions (
    execution_id    INTEGER PRIMARY KEY AUTOINCREMENT,
    
    -- FOREIGN KEYS: Link execution directly to parent tables
    -- ON DELETE RESTRICT prevents accidentally deleting an account that has trade history!
    account_id      TEXT NOT NULL REFERENCES trading_accounts(account_id) ON DELETE RESTRICT,
    symbol          TEXT NOT NULL REFERENCES market_instruments(symbol) ON DELETE RESTRICT,
    
    side            TEXT NOT NULL CHECK (side IN ('BUY', 'SELL')),
    order_type      TEXT NOT NULL CHECK (order_type IN ('MARKET', 'LIMIT', 'SL_LIMIT', 'SL_MARKET')),
    quantity        INTEGER NOT NULL CHECK (quantity > 0),
    execution_price REAL NOT NULL CHECK (execution_price > 0.0),
    broker_order_id TEXT UNIQUE,
    status          TEXT NOT NULL DEFAULT 'NEW' CHECK (status IN ('NEW', 'PENDING', 'FILLED', 'REJECTED', 'CANCELLED')),
    executed_at     DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Teacher's Pro-Tip: Adding comments or altering schema after creation
-- Using ALTER TABLE to add a slippage tracking column
ALTER TABLE trade_executions ADD COLUMN slippage_pts REAL DEFAULT 0.0;

-- ============================================================================
-- PART 2: DML — INSERTING DATA WITH INTEGRITY
-- ============================================================================

-- 1. Standard Multi-Row INSERT
INSERT INTO market_instruments (symbol, exchange_segment, lot_size, tick_size, is_tradable) 
VALUES 
    ('RELIANCE', 'NSE_EQ', 1, 0.05, 1),
    ('INFY', 'NSE_EQ', 1, 0.05, 1),
    ('TCS', 'NSE_EQ', 1, 0.05, 1),
    ('HDFCBANK', 'NSE_EQ', 1, 0.05, 1),
    ('NIFTY26MAR22000CE', 'NSE_FNO', 50, 0.05, 1),
    ('BANKNIFTY26MAR48000PE', 'NSE_FNO', 15, 0.05, 1);

-- 2. Inserting Accounts
INSERT INTO trading_accounts (account_id, broker_name, account_type, current_cash, allocated_margin)
VALUES 
    ('ACC_ZERODHA_01', 'ZERODHA', 'LIVE', 250000.00, 50000.00),
    ('ACC_DHAN_PAPER', 'DHAN', 'PAPER', 1000000.00, 0.00);

-- 3. Inserting Executions
INSERT INTO trade_executions (account_id, symbol, side, order_type, quantity, execution_price, broker_order_id, status, slippage_pts)
VALUES
    ('ACC_ZERODHA_01', 'RELIANCE', 'BUY', 'LIMIT', 25, 2940.50, 'ORD_1001', 'FILLED', 0.10),
    ('ACC_ZERODHA_01', 'INFY', 'BUY', 'MARKET', 50, 1615.20, 'ORD_1002', 'FILLED', 0.45),
    ('ACC_DHAN_PAPER', 'NIFTY26MAR22000CE', 'BUY', 'LIMIT', 100, 145.00, 'ORD_1003', 'FILLED', -0.20),
    ('ACC_ZERODHA_01', 'TCS', 'BUY', 'LIMIT', 10, 3950.00, 'ORD_1004', 'PENDING', 0.00);

-- ============================================================================
-- PART 3: UPSERT (INSERT ... ON CONFLICT)
-- Essential for bots ingesting instrument master lists and live scrip tokens!
-- ============================================================================

-- If RELIANCE already exists, do NOT fail; instead update its lot_size or tradable flag
INSERT INTO market_instruments (symbol, exchange_segment, lot_size, tick_size, is_tradable)
VALUES ('RELIANCE', 'NSE_EQ', 1, 0.05, 1)
ON CONFLICT(symbol) DO UPDATE SET
    is_tradable = excluded.is_tradable,
    created_at = CURRENT_TIMESTAMP;

-- ============================================================================
-- PART 4: DML — UPDATING AND DELETING SAFELY
-- ============================================================================

-- 1. Targeted UPDATE using a strict WHERE filter
UPDATE trading_accounts 
SET current_cash = current_cash - (25 * 2940.50),
    updated_at = CURRENT_TIMESTAMP
WHERE account_id = 'ACC_ZERODHA_01';

-- 2. Conditional State Transition UPDATE
UPDATE trade_executions
SET status = 'CANCELLED'
WHERE broker_order_id = 'ORD_1004' AND status = 'PENDING';

-- 3. Controlled DELETE
-- In production systems, we usually SOFT-DELETE (set is_active = 0), but hard-delete is also used for transient caches
DELETE FROM trade_executions 
WHERE status = 'CANCELLED' AND execution_price > 5000;

-- ============================================================================
-- VERIFY OUR TABLES
-- ============================================================================
-- 1. View Instruments
SELECT instrument_id, symbol, exchange_segment, lot_size, tick_size, is_tradable FROM market_instruments;

-- 2. View Accounts
SELECT account_id, broker_name, account_type, current_cash, allocated_margin FROM trading_accounts;

-- 3. View Executed Trades
SELECT execution_id, account_id, symbol, side, order_type, quantity, execution_price, status, slippage_pts FROM trade_executions;
