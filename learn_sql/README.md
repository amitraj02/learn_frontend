# 🎓 SQL Masterclass & Teaching Suite
### Designed for Algorithmic Trading, Financial Data Engineering & Core SQL Mastery
*Instructor: AI Tech Teacher & Systems Mentor*

Welcome to the **SQL Teaching Suite** in `/Users/amitraj/tradeBOT/learn_sql`. Whether you are designing tables for high-throughput market feeds, querying historical candle data, managing trade orders, or calculating running portfolio P&L, SQL is the foundational backbone of data engineering.

---

## 🗺️ Learning Curriculum & File Directory

All lesson files in this folder are **100% self-contained and runnable**. You can run them directly in SQLite, PostgreSQL, MySQL, or using the included interactive tools.

| File | Topic | Core Concepts Taught | Trading / Real-World Focus |
| :--- | :--- | :--- | :--- |
| [`01_foundations_ddl_dml.sql`](file:///Users/amitraj/tradeBOT/learn_sql/01_foundations_ddl_dml.sql) | **DDL & DML Fundamentals** | `CREATE TABLE`, Constraints (`PK`, `FK`, `UNIQUE`, `CHECK`), `INSERT`, `UPDATE`, `DELETE`, `ALTER` | Watchlist, Accounts & Instruments schema |
| [`02_basic_queries_and_filtering.sql`](file:///Users/amitraj/tradeBOT/learn_sql/02_basic_queries_and_filtering.sql) | **Queries & Filtering** | `SELECT`, `WHERE`, `LIKE`, `IN`, `BETWEEN`, `ORDER BY`, `LIMIT`, `OFFSET`, `CASE WHEN` | Scanning high-beta stocks, filtering active orders |
| [`03_aggregations_and_grouping.sql`](file:///Users/amitraj/tradeBOT/learn_sql/03_aggregations_and_grouping.sql) | **Aggregations & Grouping** | `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`, `GROUP BY`, `HAVING`, SQL Execution Order | Trading volume, win rate, daily broker commissions |
| [`04_table_joins_and_relationships.sql`](file:///Users/amitraj/tradeBOT/learn_sql/04_table_joins_and_relationships.sql) | **Joins & Multi-Table Data** | `INNER JOIN`, `LEFT JOIN`, `RIGHT`, `FULL OUTER`, `CROSS JOIN`, `SELF JOIN` | Matching orders to executions & account balances |
| [`05_subqueries_and_ctes.sql`](file:///Users/amitraj/tradeBOT/learn_sql/05_subqueries_and_ctes.sql) | **Subqueries & CTEs** | Scalar & Correlated Subqueries, `EXISTS`, `WITH` (Common Table Expressions), Recursion | Multi-level order filtering, recursive date series |
| [`06_window_functions_and_analytics.sql`](file:///Users/amitraj/tradeBOT/learn_sql/06_window_functions_and_analytics.sql) | **Window Functions & Analytics** | `OVER(PARTITION BY ... ORDER BY ...)`, `ROW_NUMBER`, `RANK`, `LAG`, `LEAD`, Rolling Averages | Candle returns, 5-period moving average, running drawdown |
| [`07_indexes_and_performance_tuning.sql`](file:///Users/amitraj/tradeBOT/learn_sql/07_indexes_and_performance_tuning.sql) | **Indexing & Query Plans** | B-Tree Indexes, Composite Indexes, Covering Indexes, `EXPLAIN QUERY PLAN`, WAL Mode | Sub-millisecond tick lookup, order book query optimization |
| [`08_transactions_and_acid.sql`](file:///Users/amitraj/tradeBOT/learn_sql/08_transactions_and_acid.sql) | **Transactions & ACID Concurrency**| `BEGIN`, `COMMIT`, `ROLLBACK`, `SAVEPOINT`, Isolation levels, Concurrency locks | Atomic order placement with wallet deduction |
| [`09_views_triggers_and_security.sql`](file:///Users/amitraj/tradeBOT/learn_sql/09_views_triggers_and_security.sql) | **Views, Triggers & Security** | `CREATE VIEW`, Audit Triggers, SQL Injection Prevention, Parameterization | Auto-logging order cancellations, trader security |
| [`10_trading_bot_database_patterns.sql`](file:///Users/amitraj/tradeBOT/learn_sql/10_trading_bot_database_patterns.sql) | **Production Trading Bot Schemas** | Ticks storage, 1m/5m OHLC resampling via SQL, Trade audit log, PnL ledger | Complete database blueprint for `tradeBOT` |
| [`exercises_and_challenges.sql`](file:///Users/amitraj/tradeBOT/learn_sql/exercises_and_challenges.sql) | **Practice Challenges & Solutions** | 15 hands-on challenges (Beginner to Advanced) with schema and detailed answers | Interview questions, real bot edge cases |
| [`sql_cheatsheet.md`](file:///Users/amitraj/tradeBOT/learn_sql/sql_cheatsheet.md) | **Fast Reference Cheatsheet** | Clause order, data types, operators, date-time functions, quick syntax | Instant desk reference |
| [`practice_runner.py`](file:///Users/amitraj/tradeBOT/learn_sql/practice_runner.py) | **Interactive Python Practice CLI** | Run any lesson script or launch an interactive SQL shell against an in-memory DB | Command line experimentation |
| [`index.html`](file:///Users/amitraj/tradeBOT/learn_sql/index.html) | **Visual Web Masterclass** | Interactive browser app with built-in SQLite WebAssembly engine | Visual learning with instant live query execution |

---

## 🚀 3 Ways to Practice & Learn

### Option 1: The Interactive Web App (Recommended for Visual Learning)
Open [`index.html`](file:///Users/amitraj/tradeBOT/learn_sql/index.html) in your browser (or use the built-in preview). It includes a full in-browser SQLite WebAssembly engine, syntax guides, visual diagrams, and a live query sandbox with pre-loaded trading datasets!

### Option 2: The Included Python Practice Runner
From your terminal in `/Users/amitraj/tradeBOT`:
```bash
# Run a specific lesson and see all queries executed with tabular output:
python3 learn_sql/practice_runner.py --lesson 01

# Launch an interactive SQL playground session:
python3 learn_sql/practice_runner.py --interactive
```

### Option 3: Direct SQLite CLI
You can test queries directly on SQLite in terminal:
```bash
sqlite3 :memory: < learn_sql/01_foundations_ddl_dml.sql
sqlite3 :memory: < learn_sql/06_window_functions_and_analytics.sql
```

---

## 🧠 Mental Model: The SQL Order of Execution
Remember that SQL queries are **NOT** executed in the order they are written:
```
Written Order:             Execution Order:
1. SELECT                  1. FROM & JOINs (Find data source)
2. FROM                    2. WHERE (Filter individual rows)
3. WHERE                   3. GROUP BY (Aggregate rows into buckets)
4. GROUP BY                4. HAVING (Filter aggregated buckets)
5. HAVING                  5. SELECT (Calculate columns & expressions)
6. ORDER BY                6. DISTINCT (Deduplicate rows)
7. LIMIT / OFFSET          7. ORDER BY (Sort final rows)
                           8. LIMIT / OFFSET (Slice returned rows)
```
*Mastering this order is the secret to debugging 90% of all SQL issues!*
