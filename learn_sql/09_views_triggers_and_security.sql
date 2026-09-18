-- ============================================================================
-- 🎓 LESSON 09: VIEWS, AUTOMATED TRIGGERS & SECURITY ARCHITECTURE
-- Designed for Algorithmic Trading & High-Performance Data Engineering
-- Instructor: AI Tech Teacher
-- ============================================================================
--
-- 📌 WHAT YOU WILL LEARN TODAY:
--   1. Views (CREATE VIEW): Encapsulating complex analytical queries for reuse
--   2. Triggers (CREATE TRIGGER): Automated event hooks (BEFORE / AFTER / INSTEAD OF)
--   3. Audit Trail Trigger: Tracking order status changes without code overhead
--   4. Security: SQL Injection vulnerabilities and Parameterized Query protection
-- ============================================================================

DROP TRIGGER IF EXISTS trg_audit_order_changes;
DROP VIEW IF EXISTS v_active_risk_dashboard;
DROP TABLE IF EXISTS audit_order_history;
DROP TABLE IF EXISTS active_orders;

CREATE TABLE active_orders (
    order_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    symbol       TEXT NOT NULL,
    side         TEXT NOT NULL,
    quantity     INTEGER NOT NULL,
    price        REAL NOT NULL,
    status       TEXT NOT NULL DEFAULT 'NEW',
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at   DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE audit_order_history (
    audit_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id     INTEGER NOT NULL,
    old_status   TEXT,
    new_status   TEXT,
    changed_at   DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO active_orders (symbol, side, quantity, price, status) VALUES
('RELIANCE', 'BUY', 50,  2950.00, 'NEW'),
('INFY',     'BUY', 100, 1620.00, 'FILLED'),
('TCS',      'BUY', 20,  4100.00, 'NEW');

-- ============================================================================
-- 1. VIEWS: REUSABLE REPORTING ABSTRACTIONS
-- Build a clean dashboard view that abstracts calculations away from frontend
-- ============================================================================
CREATE VIEW v_active_risk_dashboard AS
SELECT 
    symbol,
    side,
    quantity,
    price,
    ROUND(quantity * price, 2) AS exposure_value,
    status,
    CASE 
        WHEN (quantity * price) > 100000 THEN 'HIGH_EXPOSURE'
        ELSE 'NORMAL_EXPOSURE'
    END AS risk_category
FROM active_orders
WHERE status != 'CANCELLED';

-- Now queries on the view are dead simple:
SELECT * FROM v_active_risk_dashboard WHERE risk_category = 'HIGH_EXPOSURE';

-- ============================================================================
-- 2. TRIGGERS: AUTOMATED EVENT-DRIVEN AUDITING
-- When an order's status is updated, automatically record the transition!
-- ============================================================================
CREATE TRIGGER trg_audit_order_changes
AFTER UPDATE OF status ON active_orders
FOR EACH ROW
WHEN OLD.status != NEW.status
BEGIN
    INSERT INTO audit_order_history (order_id, old_status, new_status, changed_at)
    VALUES (NEW.order_id, OLD.status, NEW.status, CURRENT_TIMESTAMP);
    
    -- Also auto-update the updated_at timestamp on the parent table
    UPDATE active_orders SET updated_at = CURRENT_TIMESTAMP WHERE order_id = NEW.order_id;
END;

-- Test the trigger:
UPDATE active_orders SET status = 'CANCELLED' WHERE order_id = 1;
UPDATE active_orders SET status = 'FILLED'    WHERE order_id = 3;

-- Verify our audit table captured everything automatically!
SELECT * FROM audit_order_history;

-- ============================================================================
-- 3. SECURITY & SQL INJECTION PREVENTION (CRITICAL FOR PYTHON TRADING BOTS)
-- ============================================================================
-- ⚠️ INSECURE PYTHON CODE (NEVER DO THIS!):
--   user_input = "RELIANCE' OR '1'='1"
--   query = f"SELECT * FROM active_orders WHERE symbol = '{user_input}'"
--   cursor.execute(query)  <-- ATTACKER DUMPS THE ENTIRE DATABASE!
--
-- ✔️ SECURE PYTHON CODE (ALWAYS USE PARAMETERIZED QUERIES):
--   user_input = "RELIANCE"
--   cursor.execute("SELECT * FROM active_orders WHERE symbol = ?", (user_input,))
--
-- SQLite and DB engines treat '?' as literal data, making SQL injection impossible!
