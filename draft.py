import pandas as pd
import os

folder = "data"

for file in os.listdir(folder):
    if file.endswith(".csv"):
        df = pd.read_csv(os.path.join(folder, file), nrows=100)

        print("="*80)
        print(file)
        print(df.info())