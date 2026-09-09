import pandas as pd

input_file = "data/raw/olist_order_reviews_dataset.csv"
output_file = "data/processed/olist_order_reviews_clean.csv"

df = pd.read_csv(
    input_file,
    encoding="utf-8"
)

df = df.drop(columns=["review_comment_message", "review_comment_title"])


df.to_csv(
    output_file,
    index=False,
    encoding="utf-8"
)

print(df.shape)
print(df.columns.tolist())