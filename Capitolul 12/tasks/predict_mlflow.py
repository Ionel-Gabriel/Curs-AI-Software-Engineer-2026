MLFLOW_TRACKING_URI = "http://mlflow:5000/"
MODEL_NAME = "HousePriceRegressor"
MODEL_VERSION = 'champion'

import mlflow
import pandas as pd

def predict_mlflow(**context) -> None:
    ti = context['ti']

    records = ti.xcom_pull(key="house_samples", task_ids="extract_random_samples")
    if not records:
        raise ValueError("No data received from upstream task via XCom.")

    df = pd.DataFrame.from_records(records)
    print("Data received from previous task via XCom:")
    print(df)

    mlflow.set_tracking_uri(MLFLOW_TRACKING_URI)
    model_uri = f"models:/{MODEL_NAME}@{MODEL_VERSION}"

    model_info = mlflow.models.get_model_info(model_uri)
    input_schema = model_info.signature.inputs
    expected_columns = input_schema.input_names()

    print(f"Schema inferred from MLFlow model signature: {expected_columns}")

    features_df = df[expected_columns]

    model = mlflow.sklearn.load_model(model_uri)
    predictions = model.predict(features_df)

    print("\n=== Prediction Results ===")
    for i, pred in enumerate(predictions):
        actual = df.loc[i, "House_Price"] if "House_Price" in df.columns else None
        line = f"Sample {i}: predicted House_Price = {pred:.2f}"
        line += f" | actual House_Price = {actual:.2f}"
        print(line)
        print(f"Features: {features_df.iloc[i].to_dict()}")

        

