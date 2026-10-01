# SQL Data Cleaning — Layoffs Dataset

A MySQL 8.0+ data-cleaning project that transforms a raw layoffs dataset into an analysis-ready table using a reproducible SQL workflow.

## Project Goals

This project demonstrates practical SQL data-cleaning techniques commonly used in analytics and data-engineering workflows:

- preserve the raw dataset by working from a staging copy
- detect and remove duplicate records
- standardize inconsistent text values
- convert text dates to a proper `DATE` datatype
- handle blank and missing values
- fill missing industry values using matching company/location records
- remove unusable rows
- produce a final cleaned table for downstream analysis

## Cleaning Pipeline

1. Create a staging copy of the source table.
2. Use `ROW_NUMBER()` with `PARTITION BY` to identify duplicates.
3. Remove duplicate records while retaining one valid row.
4. Standardize company, industry and country values.
5. Convert dates using `STR_TO_DATE()` and update the column datatype.
6. Convert blank industry values to `NULL`.
7. Populate missing industry values through a self-join on company and location.
8. Remove rows where both layoff measures are missing.
9. Create `layoffs_staging_cleaned` as the final analysis-ready table.

## SQL Concepts Demonstrated

- staging tables
- `ROW_NUMBER()` window functions
- `PARTITION BY`
- duplicate detection and removal
- `TRIM()` and string standardization
- `STR_TO_DATE()`
- `ALTER TABLE`
- `NULL` handling
- self joins
- conditional `UPDATE`
- data-quality validation

## Repository Contents

```text
Data_cleaning_Layoffs/
├── Main.sql
├── layoffs.csv
├── layoffs_cleaned.csv
└── README.md
```

## How to Run

1. Import `layoffs.csv` into MySQL as a table named `layoffs`.
2. Open `Main.sql` in MySQL Workbench or another MySQL 8.0+ client.
3. Execute the script in sequence.
4. Query the final table:

```sql
SELECT *
FROM layoffs_staging_cleaned;
```

## Output

The workflow creates a cleaned dataset suitable for exploratory analysis, dashboards or downstream transformation pipelines.

## Why This Project Matters

The project reflects a common data-engineering pattern:

```text
Raw Data → Staging → Cleaning → Validation → Analysis-Ready Data
```

It demonstrates that raw source data is preserved while transformations are performed in a controlled staging layer.
