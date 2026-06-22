# oracle-sql-data-validation
# Oracle SQL Data Validation & Reporting
**Tools:** Oracle LiveSQL | Oracle SQL | HCM & SCM Data

## Overview
Simulated Oracle HCM and SCM data validation project using Oracle SQL.
Designed to identify and report data quality issues across employee and order datasets.

## Files
- `01_setup_tables.sql` — Creates EMPLOYEES, DEPARTMENTS, ORDERS tables
- `02_insert_data.sql` — Inserts clean + intentionally erroneous records
- `03_validation_queries.sql` — Validation checks + reporting queries

## Validations Covered
**HCM (Employee Data)**
- NULL Department ID (orphan employees)
- Invalid Department (not in master)
- NULL Email, Hire Date, Salary
- Duplicate Email detection

**SCM (Order Data)**
- NULL Customer ID / Name
- Zero quantity orders
- Total amount mismatch (Qty × Price)
- NULL Order Date

## How to Run
1. Go to livesql.oracle.com (free account)
2. Run files in order: 01 → 02 → 03
3. View validation results and error summary
