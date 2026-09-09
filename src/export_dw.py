# for data from postgres

import csv
import psycopg2
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
OUTPUT_DIR = PROJECT_ROOT / "data" / "dw"

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

conn = psycopg2.connect(
    host="localhost",
    port=5433,
    database="olist_crm",
    user="admin",
    password="admin123"
)


def export_table(table_name, column_name, output_file):

    with conn.cursor() as cur:

        cur.execute(
            f"""
            SELECT {column_name}
            FROM {table_name}
            """
        )

        rows = cur.fetchall()

    output_path = OUTPUT_DIR / output_file

    with open(output_path, "w", newline="", encoding="utf-8") as f:

        writer = csv.writer(f)

        writer.writerow([column_name])
        writer.writerows(rows)

    print(f"Exported {len(rows)} rows from {table_name}")
    print(f"File: {output_path}")


# Customer
export_table(
    "crm.customers",
    "customer_id",
    "dw_customers.csv"
)


# Seller
export_table(
    "crm.sellers",
    "seller_id",
    "dw_sellers.csv"
)


conn.close()

print("DW export completed.")