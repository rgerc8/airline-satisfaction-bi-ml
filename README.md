# Airline Satisfaction Analytics

An end-to-end analytics project for understanding airline passenger satisfaction and supporting business decisions with both **Business Intelligence (BI)** and **Machine Learning (ML)**.

The project combines a PostgreSQL data warehouse, dbt transformations, exploratory analysis, and a planned predictive workflow to answer two complementary questions:

1. **BI:** What factors, customer segments, and operational conditions are associated with passenger satisfaction?
2. **ML:** Can we predict whether a new passenger will be satisfied using the information available after the flight?

This project also has an **educational and training purpose**. It is a practical environment for learning how to design an analytics solution from raw data through transformation, reporting, predictive analysis, and eventual orchestration. The project intentionally brings together technologies commonly used in modern data and analytics teams.

## Technology Stack

- **PostgreSQL:** Relational database and analytical storage layer.
- **dbt:** SQL-based transformations, data modeling, documentation, and data-quality testing.
- **Python and Jupyter:** Exploratory data analysis, statistical analysis, and machine-learning preparation.
- **Power BI:** Planned business-facing dashboards and KPI reporting.
- **Apache Superset:** Planned open-source dashboarding and exploratory BI interface.
- **Apache Airflow:** Planned workflow orchestration for scheduled data refreshes, dbt runs, dashboard datasets, and model pipelines.

## Project Goals

### Business Intelligence

The BI layer is designed to help airline teams:

- Monitor overall satisfaction and dissatisfaction rates.
- Compare business, economy, and economy-plus passengers.
- Understand differences between business and personal travel.
- Identify the service attributes most associated with satisfaction.
- Evaluate the relationship between delays and passenger experience.
- Prioritize improvements to digital boarding, entertainment, seating, onboard service, and other service areas.
- Create reliable, documented datasets for dashboards and recurring reporting.

### Machine Learning

The ML layer will support post-flight satisfaction prediction. The target variable is `satisfaction`, and candidate predictors include:

- Passenger profile: age, gender, customer type.
- Trip context: travel type, travel class, and flight distance.
- Service ratings: online boarding, inflight entertainment, seat comfort, onboard service, and related attributes.
- Operational experience: departure and arrival delays.

Because this is a **post-flight** prediction use case, post-flight ratings and delay information can be considered available features. The prediction-time definition should remain explicit when the model is built.

## Current Dataset

The source is an airline passenger satisfaction dataset imported into PostgreSQL.

Current EDA findings:

- 129,880 passenger records.
- 22 original columns.
- 43.45% satisfied and 56.55% dissatisfied passengers.
- No duplicate rows detected.
- 393 missing values in `arrival_delay_in_minutes` (0.30%).
- Service ratings use a 0-5 scale, with some ratings containing a meaningful score of 0.
- `online_boarding` has the strongest numeric association with satisfaction.
- `travel_class` and `type_of_travel` have the strongest categorical associations.
- Departure and arrival delay are highly correlated, so redundant features should be considered during modeling.

Missing arrival delays are not automatically zero: only 147 of the 393 missing-arrival records have zero departure delay. The EDA therefore preserves the original values and evaluates missingness explicitly.

## Architecture

```text
Raw airline data
       |
       v
PostgreSQL: raw.airline_satisfaction
       |
       v
 dbt staging models
       |
       v
 dbt intermediate and mart models
       |
       +----------------------+
       |                      |
       v                      v
BI reporting datasets     ML-ready dataset
       |                      |
       v                      v
Dashboards and KPIs       Satisfaction prediction
```

## Repository Structure

```text
data/
    data.csv                         Local source data (ignored by Git)

dbt/
    dbt_project.yml                  dbt project configuration
    models/
        staging/                     Source-aligned cleaned views
        intermediate/                Reusable transformation layer
        marts/                       BI-facing reporting tables
        ml/                          ML-ready feature tables
    macros/                          Reusable dbt macros
    tests/                           dbt data-quality tests

notebooks/
    01_exploratory_data_analysis.ipynb
                                     Feature profiling, data quality,
                                     associations, missingness, and
                                     modeling-readiness analysis
```

## Exploratory Analysis

The EDA notebook covers:

- Dataset shape, data types, uniqueness, missingness, and duplicates.
- Numeric distributions, skewness, IQR-based outliers, and rating ranges.
- Categorical value inventories and customer composition.
- Satisfaction rates by demographic, travel, class, delay, age, and distance segments.
- Differences in service ratings between satisfied and dissatisfied passengers.
- Pearson associations and pairwise feature correlations.
- Chi-square tests with Cramer's V for categorical variables.
- Mann-Whitney tests with rank-biserial effect sizes for numeric and ordinal variables.
- Missing-arrival-delay diagnostics.
- Delay outlier sensitivity using raw, capped, and `log1p` transformations.
- Feature-availability and potential leakage review.
- Schema and value-range assertions.

## Modeling Decisions

For the post-flight prediction use case:

- Keep `arrival_delay_in_minutes` as a candidate feature.
- Add an `arrival_delay_missing` indicator.
- Do not replace every missing arrival delay with zero.
- Use a training-set-only imputation strategy, preferably conditional on departure delay or a model-based imputation approach.
- Evaluate a baseline model before adding more complex transformations.
- Use stratified validation because the target is moderately imbalanced.
- Report more than accuracy: precision, recall, F1-score, ROC-AUC, PR-AUC, and a confusion matrix should be considered.
- Inspect feature importance and calibration before using predictions operationally.

The ML pipeline should prevent train/test leakage by fitting encoders, imputers, scalers, and feature-selection steps only on the training data.

## BI Questions

The project is intended to support questions such as:

- Which service attributes have the largest relationship with dissatisfaction?
- Is satisfaction materially different across travel classes?
- How does business travel compare with personal travel?
- How does customer loyalty relate to satisfaction?
- Does increasing departure or arrival delay correspond to lower satisfaction?
- Which passenger segments should receive targeted service improvements?
- Which KPIs should be monitored regularly by business stakeholders?

## Getting Started

### Prerequisites

- Python 3.10+
- PostgreSQL
- dbt Core with the PostgreSQL adapter
- Jupyter or VS Code with the Jupyter extension

### Python environment

Create and activate a virtual environment, then install the analysis dependencies:

```bash
python -m venv .venv
source .venv/bin/activate
pip install pandas matplotlib scipy sqlalchemy psycopg2-binary jupyter ipykernel
```

### Database

Create a PostgreSQL database and load the source data into:

```text
Database: airline_db
Schema: raw
Table: raw.airline_satisfaction
```

The dbt source declaration is located at `dbt/models/staging/sources.yml`.

Do not commit database passwords or connection strings. Use environment variables or a local dbt profile for credentials.

### Run dbt

From the `dbt/` directory, configure a profile named `airline_satisfaction`, then run:

```bash
dbt debug
dbt source freshness
dbt run
dbt test
dbt docs generate
dbt docs serve
```

Only run commands that are supported by the configured warehouse and available models. Generated dbt artifacts under `target/` and `logs/` are intentionally ignored by Git.

### Run the EDA notebook

Open:

```text
notebooks/01_exploratory_data_analysis.ipynb
```

Run the notebook from the first cell so the database connection, feature groups, diagnostics, and conclusions are created in order.

## Roadmap

- Complete and test staging, intermediate, BI mart, and ML dbt models.
- Add dbt tests for accepted values, not-null constraints, relationships, and delay/rating ranges.
- Build a reusable ML feature table in the dbt `ml` layer.
- Create a feature-engineering notebook separate from the EDA notebook.
- Train and compare baseline models such as logistic regression, random forest, and gradient boosting.
- Tune the decision threshold according to the business cost of missed dissatisfied passengers.
- Add model explainability and calibration analysis.
- Publish Power BI dashboards with documented KPI definitions.
- Publish equivalent exploratory dashboards in Apache Superset.
- Use Apache Airflow to orchestrate scheduled ingestion, dbt transformations, dashboard refreshes, and model-monitoring workflows.

## Data and Privacy

The dataset is used for analytical and educational purposes. Review licensing and usage terms for the original source before redistributing the data. Local data files are excluded from version control through `.gitignore`.

## License

No project license has been specified yet. Add a license before public redistribution if this repository will be shared or reused.