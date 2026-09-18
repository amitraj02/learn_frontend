-- ============================================================================
-- 🎓 LESSON 08: TRANSACTIONS, ACID GUARANTEES & CONCURRENCY
-- Designed for Algorithmic Trading & High-Performance Data Engineering
-- Instructor: AI Tech Teacher
-- ============================================================================
--
-- 📌 WHAT YOU WILL LEARN TODAY:
--   1. The ACID Principles: Atomicity, Consistency, Isolation, Durability
--   2. The Atomic Trade Placement Scenario (Margin deduction + Order creation)
--   3. Transaction Control: BEGIN TRANSACTION, COMMIT, ROLLBACK
--   4. Nested Control with SAVEPOINT and ROLLBACK TO SAVEPOINT
--   5. Preventing Race Conditions & Double-Spending in Algorithmic Trading
-- ============================================================================

DROP TABLE IF EXISTS wallet_audit_log;
DROP TABLE IF EXISTS bot_orders;
DROP TABLE IF EXISTS trading_wallets;

CREATE TABLE trading_wallets (
    wallet_id    TEXT PRIMARY KEY,
    trader_name  TEXT NOT NULL,
    free_cash    REAL NOT NULL CHECK (free_cash >= 0.0), -- DB constraint prevents negative balance!
    locked_margin REAL NOT NULL DEFAULT 0.0
);

CREATE TABLE bot_orders (
    order_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    wallet_id    TEXT NOT NULL REFERENCES trading_wallets(wallet_id),
    symbol       TEXT NOT NULL,
    quantity     INTEGER NOT NULL,
    price        REAL NOT NULL,
    margin_req   REAL NOT NULL,
    status       TEXT NOT NULL
);

CREATE TABLE wallet_audit_log (
    log_id       INTEGER PRIMARY KEY AUTOINCREMENT,
    wallet_id    TEXT NOT NULL,
    action_type  TEXT NOT NULL,
    amount       REAL NOT NULL,
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Seed Account Balance: 100,000 INR
INSERT INTO trading_wallets (wallet_id, trader_name, free_cash, locked_margin)
VALUES ('W_ALPHA_01', 'Amit Algo Desk', 100000.00, 0.00);

-- ============================================================================
-- SCENARIO A: A SUCCESSFUL ATOMIC TRANSACTION
-- Place an order requiring 30,000 margin. Deduct cash, lock margin, insert order.
-- ============================================================================
BEGIN TRANSACTION;

-- Step 1: Move funds from free_cash to locked_margin
UPDATE trading_wallets
SET free_cash = free_cash - 30000.00,
    locked_margin = locked_margin + 30000.00
WHERE wallet_id = 'W_ALPHA_01';

-- Step 2: Insert order
INSERT INTO bot_orders (wallet_id, symbol, quantity, price, margin_req, status)
VALUES ('W_ALPHA_01', 'RELIANCE', 10, 3000.00, 30000.00, 'NEW');

-- Step 3: Insert audit log entry
INSERT INTO wallet_audit_log (wallet_id, action_type, amount)
VALUES ('W_ALPHA_01', 'LOCK_MARGIN_ORDER_NEW', 30000.00);

-- If all steps succeeded, commit permanently:
COMMIT;

-- Inspect state: Free cash is now 70,000 and locked margin is 30,000
SELECT * FROM trading_wallets;
SELECT * FROM bot_orders;

-- ============================================================================
-- SCENARIO B: SIMULATING A FAILURE & ROLLBACK
-- Bot attempts to order with 80,000 margin, but only 70,000 is available!
-- ============================================================================
BEGIN TRANSACTION;

-- Suppose application logic or DB constraint throws an error, or broker rejects:
UPDATE trading_wallets
SET free_cash = free_cash - 80000.00,
    locked_margin = locked_margin + 80000.00
WHERE wallet_id = 'W_ALPHA_01';

-- Simulated Broker Rejection:
-- In code: If broker returns REJECT, we execute ROLLBACK!
ROLLBACK;

-- Verify state remains intact at 70,000 free cash! (No corruption, no lost funds)
SELECT * FROM trading_wallets;

-- ============================================================================
-- SCENARIO C: SAVEPOINTS (PARTIAL ROLLBACKS)
-- Useful for complex multi-leg basket orders where 1 optional leg fails
-- ============================================================================
BEGIN TRANSACTION;

SAVEPOINT leg_1;
INSERT INTO bot_orders (wallet_id, symbol, quantity, price, margin_req, status)
VALUES ('W_ALPHA_01', 'NIFTY26MAR22000CE', 50, 150.00, 7500.00, 'FILLED');

SAVEPOINT leg_2;
INSERT INTO bot_orders (wallet_id, symbol, quantity, price, margin_req, status)
VALUES ('W_ALPHA_01', 'NIFTY26MAR21500PE', 50, 120.00, 6000.00, 'REJECTED');

-- Rollback ONLY leg 2, keeping leg 1 active!
ROLLBACK TO SAVEPOINT leg_2;

-- Release savepoint and commit leg 1
RELEASE SAVEPOINT leg_1;
COMMIT;

-- Final Order Book Verification
SELECT * FROM bot_orders;
