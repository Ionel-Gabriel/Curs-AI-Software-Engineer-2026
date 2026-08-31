import pendulum
from airflow.models.dag import DAG
from airflow.operators.python import PythonOperator

from tasks.extract_random_samples import extract_random_samples
from tasks.predict_mlflow import predict_mlflow

default_args = {
    "owner": "airflow",
    "retries": 1
}


with DAG(
    dag_id="kaggle_mlflow_house_price_prediction",
    description="Sample house-price data from Kaggle, predict with an MLFlow model",
    default_args=default_args,
    schedule=None,
    start_date=pendulum.datetime(2026, 1, 1, tz="UTC"),
    catchup=False,
    tags=["mlflow", "kaggle", "example"],
) as dag:
    extract_task = PythonOperator(
        task_id = "extract_random_samples",
        python_callable=extract_random_samples,
    )

    predict_task = PythonOperator(
        task_id="predict_mlflow",
        python_callable=predict_mlflow
    )

    extract_task >> predict_task

