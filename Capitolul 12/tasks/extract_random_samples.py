import kagglehub
import pandas as pd

def extract_random_samples(**context) -> None:
    path = kagglehub.dataset_download("prokshitha/home-value-insights")
    houses = pd.read_csv(path + '/house_price_regression_dataset.csv')

    sample = houses.sample(n=10).reset_index(drop=True)

    print(f"Downloaded {len(houses)} rows, sampled {len(sample)} random rows")
    print(sample)

    records = sample.to_dict(orient="records")
    context["ti"].xcom_push(key="house_samples", value=records)