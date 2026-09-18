#!/usr/bin/env python3
"""
Interactive SQL Practice Runner
TradeBOT SQL Teaching Suite
Instructor: AI Tech Teacher

Usage:
  python3 practice_runner.py --lesson 01
  python3 practice_runner.py --lesson 06
  python3 practice_runner.py --interactive
  python3 practice_runner.py --list
"""

import os
import sys
import sqlite3
import argparse
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent

def print_table(cursor, headers=True):
    """Utility to print SQLite query output cleanly in tabular format."""
    rows = cursor.fetchall()
    if not rows:
        print("  (Query executed successfully. 0 rows returned)")
        return

    col_names = [description[0] for description in cursor.description]
    # Determine column widths
    widths = [len(c) for c in col_names]
    for row in rows:
        for i, val in enumerate(row):
            widths[i] = max(widths[i], len(str(val) if val is not None else "NULL"))

    sep_line = "+" + "+".join(["-" * (w + 2) for w in widths]) + "+"
    header_line = "|" + "|".join([f" {col_names[i]:<{widths[i]}} " for i in range(len(col_names))]) + "|"

    print(sep_line)
    print(header_line)
    print(sep_line)
    for row in rows:
        row_line = "|" + "|".join([f" {str(row[i]) if row[i] is not None else 'NULL':<{widths[i]}} " for i in range(len(row))]) + "|"
        print(row_line)
    print(sep_line)
    print(f"Total Rows: {len(rows)}\n")

def list_lessons():
    print("\n=======================================================")
    print("      📚 AVAILABLE SQL MASTERCLASS LESSONS")
    print("=======================================================")
    sql_files = sorted(list(BASE_DIR.glob("*.sql")))
    if not sql_files:
        print("No .sql lesson files found in directory.")
        return

    for idx, f in enumerate(sql_files, 1):
        print(f"  [{idx:02d}] {f.name}")
    print("=======================================================\n")

def run_lesson(lesson_id_or_name):
    # Find matching file
    sql_files = sorted(list(BASE_DIR.glob("*.sql")))
    target_file = None
    for f in sql_files:
        if lesson_id_or_name.lower() in f.name.lower():
            target_file = f
            break

    if not target_file:
        print(f"❌ Error: Could not find lesson matching '{lesson_id_or_name}'.")
        list_lessons()
        return

    print(f"\n🚀 Running Lesson: {target_file.name}")
    print("=" * 60)

    # Use in-memory SQLite database
    conn = sqlite3.connect(":memory:")
    conn.isolation_level = None # Autocommit mode
    cursor = conn.cursor()

    with open(target_file, "r", encoding="utf-8") as file:
        content = file.read()

    # Split into statements while respecting comments
    statements = [stmt.strip() for stmt in content.split(";") if stmt.strip()]

    stmt_count = 0
    query_count = 0
    for stmt in statements:
        # Strip comments to check if it's executable
        clean_lines = [line for line in stmt.splitlines() if not line.strip().startswith("--")]
        clean_stmt = "\n".join(clean_lines).strip()
        if not clean_stmt:
            continue

        stmt_count += 1
        is_select = clean_stmt.upper().startswith("SELECT") or clean_stmt.upper().startswith("WITH") or clean_stmt.upper().startswith("EXPLAIN")

        try:
            cursor.execute(stmt)
            if is_select:
                query_count += 1
                # Show first comment or line of query
                first_lines = [l.strip() for l in stmt.splitlines() if l.strip()]
                title = first_lines[0] if first_lines else "Query"
                print(f"\n▶ Query #{query_count}: {title}")
                print_table(cursor)
        except Exception as e:
            print(f"⚠️ SQL Notice/Error on statement: {e}")

    print("=" * 60)
    print(f"✅ Finished running {target_file.name} successfully ({stmt_count} statements, {query_count} queries).")
    conn.close()

def interactive_shell():
    print("\n=======================================================")
    print("   💻 INTERACTIVE SQL PLAYGROUND (SQLite In-Memory)")
    print("   Type your SQL statement ending with ';' and hit Enter.")
    print("   Type 'exit' or 'quit' to exit.")
    print("=======================================================\n")
    conn = sqlite3.connect(":memory:")
    cursor = conn.cursor()

    # Preload sample trading dataset
    cursor.executescript("""
        CREATE TABLE instruments (
            id INTEGER PRIMARY KEY,
            symbol TEXT UNIQUE,
            asset_class TEXT,
            tick_size REAL,
            lot_size INTEGER
        );
        INSERT INTO instruments VALUES 
            (1, 'RELIANCE', 'EQUITY', 0.05, 1),
            (2, 'INFY', 'EQUITY', 0.05, 1),
            (3, 'TCS', 'EQUITY', 0.05, 1),
            (4, 'NIFTY26MAR22000CE', 'OPTION', 0.05, 50),
            (5, 'BANKNIFTY26MAR48000PE', 'OPTION', 0.05, 15);

        CREATE TABLE orders (
            order_id INTEGER PRIMARY KEY AUTOINCREMENT,
            symbol TEXT,
            side TEXT,
            quantity INTEGER,
            price REAL,
            status TEXT,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        );
        INSERT INTO orders (symbol, side, quantity, price, status) VALUES
            ('RELIANCE', 'BUY', 10, 2945.50, 'FILLED'),
            ('RELIANCE', 'SELL', 10, 2975.00, 'FILLED'),
            ('INFY', 'BUY', 25, 1620.00, 'FILLED'),
            ('TCS', 'BUY', 5, 3950.00, 'PENDING'),
            ('NIFTY26MAR22000CE', 'BUY', 100, 142.50, 'FILLED');
    """)
    print("💡 Pre-loaded sample tables: 'instruments' and 'orders'")
    print("   Try: SELECT * FROM instruments; or SELECT * FROM orders;\n")

    buffer = ""
    while True:
        try:
            line = input("sql> " if not buffer else " ...> ")
            if line.strip().lower() in ("exit", "quit"):
                print("Goodbye! Happy querying.")
                break
            if not line.strip():
                continue
            buffer += " " + line
            if ";" in buffer:
                stmts = [s.strip() for s in buffer.split(";") if s.strip()]
                buffer = ""
                for stmt in stmts:
                    clean_upper = stmt.strip().upper()
                    cursor.execute(stmt)
                    if clean_upper.startswith("SELECT") or clean_upper.startswith("WITH") or clean_upper.startswith("EXPLAIN") or clean_upper.startswith("PRAGMA"):
                        print_table(cursor)
                    else:
                        conn.commit()
                        print(f"  ✔ Executed successfully ({cursor.rowcount} rows affected)")
        except (KeyboardInterrupt, EOFError):
            print("\nExiting playground.")
            break
        except Exception as err:
            print(f"❌ Error: {err}")
            buffer = ""

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="SQL Masterclass Practice Runner")
    parser.add_argument("--lesson", type=str, help="Run a specific lesson file, e.g. '01' or '06'")
    parser.add_argument("--interactive", action="store_true", help="Launch interactive SQL shell")
    parser.add_argument("--list", action="store_true", help="List all available lessons")
    args = parser.parse_args()

    if args.list:
        list_lessons()
    elif args.lesson:
        run_lesson(args.lesson)
    elif args.interactive:
        interactive_shell()
    else:
        list_lessons()
        print("Tip: Run with --lesson 01 or --interactive")
