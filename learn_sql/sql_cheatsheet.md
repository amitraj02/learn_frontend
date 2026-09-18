# ⚡ SQL Fast Reference Cheatsheet
### Essential Syntax, Order of Operations & Trading Analytics Idioms
*AI Tech Teacher Quick Desk Reference*

---

## 1. SQL Order of Execution (Crucial Mental Model)
```
1. FROM & JOINs        -> Locate data sources and combine tables
2. WHERE               -> Filter individual raw rows
3. GROUP BY            -> Aggregate rows into buckets
4. HAVING              -> Filter aggregated buckets
5. SELECT              -> Compute expressions and select columns
6. DISTINCT            -> Remove duplicate records
7. ORDER BY            -> Sort output rows
8. LIMIT / OFFSET      -> Paginate output slice
```

---

## 2. Table Joins Cheat Sheet

| Join Type | Description | Venn Diagram Meaning |
| :--- | :--- | :--- |
| `INNER JOIN` | Keep only rows matching both tables | Intersection of A and B |
| `LEFT JOIN` | Keep ALL rows from left table; fill right with `NULL` if no match | All of A, plus matched B |
| `RIGHT JOIN` | Keep ALL rows from right table; fill left with `NULL` if no match | All of B, plus matched A |
| `FULL OUTER JOIN` | Keep all rows from both tables | Union of A and B |
| `CROSS JOIN` | Cartesian product of both tables | Every row of A paired with every row of B |

---

## 3. Window Functions Cheat Table

| Window Function | What it does | Trading / FinTech Use Case |
| :--- | :--- | :--- |
| `ROW_NUMBER()` | Unique sequential integer (1, 2, 3...) | Pagination, deduplication |
| `RANK()` | Rank with gaps on ties (1, 2, 2, 4...) | Volume rank, top gainers |
| `DENSE_RANK()` | Rank without gaps on ties (1, 2, 2, 3...) | Sector quartile ranking |
| `LAG(col, n)` | Fetches value from `n` rows earlier | Prior bar close, return calculation |
| `LEAD(col, n)` | Fetches value from `n` rows later | Forward return, next tick price |
| `FIRST_VALUE(col)` | First value in the window frame | Candle OPEN price from ticks |
| `LAST_VALUE(col)` | Last value in the window frame | Candle CLOSE price from ticks |
| `AVG() OVER(...)` | Moving / Rolling average | 5-period SMA, 20-period SMA |
| `SUM() OVER(...)` | Cumulative running sum | Running portfolio equity curve |
| `MAX() OVER(...)` | Running peak / high-water mark | Maximum drawdown calculation |

---

## 4. High-Yield Idioms & Snippets

### A. Anti-Join (Find Unmatched Orders)
```sql
SELECT o.order_id
FROM orders o
LEFT JOIN executions e ON o.order_id = e.order_id
WHERE e.exec_id IS NULL;
```

### B. Conditional Aggregation (Win Rate in 1 Pass)
```sql
SELECT 
    COUNT(*) AS total_trades,
    SUM(CASE WHEN pnl > 0 THEN 1 ELSE 0 END) AS wins,
    ROUND(100.0 * SUM(CASE WHEN pnl > 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS win_rate_pct
FROM trades;
```

### C. 5-Period Rolling Simple Moving Average (SMA)
```sql
SELECT 
    symbol, trade_date, close_price,
    AVG(close_price) OVER (
        PARTITION BY symbol 
        ORDER BY trade_date 
        ROWS BETWEEN 4 PRECEDING AND CURRENT ROW
    ) AS sma_5
FROM daily_candles;
```

### D. SQLite Speed Tuning for Live Ticks
```sql
PRAGMA journal_mode = WAL;
PRAGMA synchronous = NORMAL;
PRAGMA cache_size = -64000;
```
