import pandas as pd

df = pd.read_csv(
    "data/raw/olist_order_reviews_dataset.csv",
    encoding="utf-8"
)

print("TOTAL:", len(df))
print("UNIQUE review_id:", df["review_id"].nunique())
print("DUPLICATE review_id:", df["review_id"].duplicated().sum())