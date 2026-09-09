from pathlib import Path
import pandas as pd

PROJECT_ROOT = Path(__file__).resolve().parent.parent

DATA_DIR = PROJECT_ROOT / "data" / "raw"

REPORT_DIR = PROJECT_ROOT / "reports"

REPORT_DIR.mkdir(exist_ok=True)

def profile_dataframe(df: pd.DataFrame) -> pd.DataFrame:
    """
    Generate a profiling report for a dataframe.
    """

    profile = pd.DataFrame(index=df.columns)
    profile["dtype"] = df.dtypes.astype(str)
    profile["non_null"] = df.notnull().sum()
    profile["null_count"] = df.isnull().sum()
    profile["null_percent"] = (df.isnull().mean() * 100).round(2)
    profile["unique"] = df.nunique(dropna=True)

    # sample value
    profile["sample"] = [
        df[column].dropna().iloc[0]
        if not df[column].dropna().empty
        else None
        for column in df.columns]

    # default values
    profile["min"] = None
    profile["max"] = None

    # Numeric statistics
    for column in df.columns:
        if pd.api.types.is_numeric_dtype(df[column]):   
            profile.loc[column, "min"] = df[column].min()
            profile.loc[column, "max"] = df[column].max()

    profile.reset_index(inplace=True)
    profile.rename(
        columns={"index": "column"},
        inplace=True)

    return profile

def main():

    csv_files = sorted(DATA_DIR.glob("*.csv"))

    print(f"\nFound {len(csv_files)} CSV files.\n")

    for file in csv_files:

        print("=" * 80)
        print(f"Processing: {file.name}")

        df = pd.read_csv(file)

        profile = profile_dataframe(df)

        report_path = REPORT_DIR / f"{file.stem}_profile.csv"

        profile.to_csv(
            report_path,
            index=False
        )

        print(f"Saved -> {report_path.name}")

    print("\nAll profiling reports generated successfully.")


if __name__ == "__main__":
    main()


    