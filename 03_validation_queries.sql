-- =============================================================
-- PROJECT: Oracle SQL Data Validation & Reporting
-- FILE   : 03_validation_queries.sql
-- PURPOSE: Identify data quality issues across HCM & SCM data
-- AUTHOR : Ramshetti Siddeswara
-- =============================================================

-- =============================================================
-- SECTION A: EMPLOYEE DATA VALIDATION (HCM)
-- =============================================================

-- A1: Employees with NULL Department (orphan records)
-- Issue  : Employee has no department assigned — invalid for HCM
-- Action : Assign correct department or investigate with HR team
SELECT
    EMPLOYEE_ID,
    FIRST_NAME || ' ' || LAST_NAME  AS EMPLOYEE_NAME,
    JOB_TITLE,
    STATUS,
    'NULL DEPARTMENT' AS ERROR_TYPE
FROM EMPLOYEES
WHERE DEPARTMENT_ID IS NULL;

-- A2: Employees with Invalid Department (dept does not exist)
-- Issue  : Department ID exists in Employee table but not in Departments master
-- Action : Correct the Department ID or add missing department to master
SELECT
    E.EMPLOYEE_ID,
    E.FIRST_NAME || ' ' || E.LAST_NAME AS EMPLOYEE_NAME,
    E.DEPARTMENT_ID AS INVALID_DEPT_ID,
    'INVALID DEPARTMENT ID' AS ERROR_TYPE
FROM EMPLOYEES E
WHERE E.DEPARTMENT_ID IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM DEPARTMENTS D WHERE D.DEPARTMENT_ID = E.DEPARTMENT_ID
  );

-- A3: Employees with NULL Email
-- Issue  : Email is mandatory in Oracle HCM for user account creation
-- Action : Collect email from employee records and update
SELECT
    EMPLOYEE_ID,
    FIRST_NAME || ' ' || LAST_NAME AS EMPLOYEE_NAME,
    JOB_TITLE,
    'NULL EMAIL' AS ERROR_TYPE
FROM EMPLOYEES
WHERE EMAIL IS NULL;

-- A4: Employees with NULL Hire Date
-- Issue  : Hire date is a required field in Oracle HCM FBDI template
-- Action : Verify joining date from offer letter and update
SELECT
    EMPLOYEE_ID,
    FIRST_NAME || ' ' || LAST_NAME AS EMPLOYEE_NAME,
    JOB_TITLE,
    'NULL HIRE DATE' AS ERROR_TYPE
FROM EMPLOYEES
WHERE HIRE_DATE IS NULL;

-- A5: Duplicate Email Addresses
-- Issue  : Same email assigned to multiple employees — causes login conflict
-- Action : Identify which record is correct, update the duplicate
SELECT
    EMAIL,
    COUNT(*)        AS DUPLICATE_COUNT,
    LISTAGG(EMPLOYEE_ID, ', ') WITHIN GROUP (ORDER BY EMPLOYEE_ID) AS EMPLOYEE_IDS,
    'DUPLICATE EMAIL' AS ERROR_TYPE
FROM EMPLOYEES
WHERE EMAIL IS NOT NULL
GROUP BY EMAIL
HAVING COUNT(*) > 1;

-- A6: Employees with NULL Salary
-- Issue  : Salary is required for payroll processing
-- Action : Get confirmed salary from offer letter and update
SELECT
    EMPLOYEE_ID,
    FIRST_NAME || ' ' || LAST_NAME AS EMPLOYEE_NAME,
    JOB_TITLE,
    'NULL SALARY' AS ERROR_TYPE
FROM EMPLOYEES
WHERE SALARY IS NULL;

-- A7: SUMMARY - Total Employee Error Count by Type
SELECT ERROR_TYPE, COUNT(*) AS TOTAL_ERRORS FROM (
    SELECT 'NULL DEPARTMENT'    AS ERROR_TYPE FROM EMPLOYEES WHERE DEPARTMENT_ID IS NULL
    UNION ALL
    SELECT 'INVALID DEPARTMENT' FROM EMPLOYEES E WHERE DEPARTMENT_ID IS NOT NULL
        AND NOT EXISTS (SELECT 1 FROM DEPARTMENTS D WHERE D.DEPARTMENT_ID = E.DEPARTMENT_ID)
    UNION ALL
    SELECT 'NULL EMAIL'         FROM EMPLOYEES WHERE EMAIL IS NULL
    UNION ALL
    SELECT 'NULL HIRE DATE'     FROM EMPLOYEES WHERE HIRE_DATE IS NULL
    UNION ALL
    SELECT 'NULL SALARY'        FROM EMPLOYEES WHERE SALARY IS NULL
) GROUP BY ERROR_TYPE ORDER BY TOTAL_ERRORS DESC;


-- =============================================================
-- SECTION B: ORDER DATA VALIDATION (SCM)
-- =============================================================

-- B1: Orders with NULL Customer ID
-- Issue  : Cannot process order without customer identifier
-- Action : Map order to correct customer master record
SELECT
    ORDER_ID,
    ORDER_DATE,
    CUSTOMER_NAME,
    PRODUCT_NAME,
    STATUS,
    'NULL CUSTOMER ID' AS ERROR_TYPE
FROM ORDERS
WHERE CUSTOMER_ID IS NULL;

-- B2: Orders with NULL Customer Name
-- Issue  : Missing customer name causes reporting gaps
-- Action : Fetch customer name from customer master using Customer ID
SELECT
    ORDER_ID,
    ORDER_DATE,
    CUSTOMER_ID,
    PRODUCT_NAME,
    'NULL CUSTOMER NAME' AS ERROR_TYPE
FROM ORDERS
WHERE CUSTOMER_NAME IS NULL;

-- B3: Orders with Zero or NULL Quantity
-- Issue  : Zero quantity orders are invalid and inflate order count
-- Action : Correct quantity or cancel order if it was raised in error
SELECT
    ORDER_ID,
    CUSTOMER_NAME,
    PRODUCT_NAME,
    QUANTITY,
    STATUS,
    'ZERO / NULL QUANTITY' AS ERROR_TYPE
FROM ORDERS
WHERE QUANTITY IS NULL OR QUANTITY = 0;

-- B4: Orders where Total Amount does not match (Qty * Unit Price)
-- Issue  : Total amount mismatch indicates data entry or system error
-- Action : Recalculate and update total amount field
SELECT
    ORDER_ID,
    CUSTOMER_NAME,
    QUANTITY,
    UNIT_PRICE,
    TOTAL_AMOUNT                     AS STORED_TOTAL,
    (QUANTITY * UNIT_PRICE)          AS CALCULATED_TOTAL,
    TOTAL_AMOUNT - (QUANTITY * UNIT_PRICE) AS DIFFERENCE,
    'AMOUNT MISMATCH' AS ERROR_TYPE
FROM ORDERS
WHERE TOTAL_AMOUNT <> (QUANTITY * UNIT_PRICE)
  AND QUANTITY IS NOT NULL
  AND UNIT_PRICE IS NOT NULL;

-- B5: Orders with NULL Order Date
-- Issue  : Missing date breaks order timeline and SLA reporting
-- Action : Recover date from source system or raise with business user
SELECT
    ORDER_ID,
    CUSTOMER_NAME,
    PRODUCT_NAME,
    STATUS,
    'NULL ORDER DATE' AS ERROR_TYPE
FROM ORDERS
WHERE ORDER_DATE IS NULL;

-- B6: SUMMARY - Total Order Error Count by Type
SELECT ERROR_TYPE, COUNT(*) AS TOTAL_ERRORS FROM (
    SELECT 'NULL CUSTOMER ID'    AS ERROR_TYPE FROM ORDERS WHERE CUSTOMER_ID IS NULL
    UNION ALL
    SELECT 'NULL CUSTOMER NAME'  FROM ORDERS WHERE CUSTOMER_NAME IS NULL
    UNION ALL
    SELECT 'ZERO/NULL QUANTITY'  FROM ORDERS WHERE QUANTITY IS NULL OR QUANTITY = 0
    UNION ALL
    SELECT 'AMOUNT MISMATCH'     FROM ORDERS WHERE TOTAL_AMOUNT <> (QUANTITY * UNIT_PRICE)
        AND QUANTITY IS NOT NULL AND UNIT_PRICE IS NOT NULL
    UNION ALL
    SELECT 'NULL ORDER DATE'     FROM ORDERS WHERE ORDER_DATE IS NULL
) GROUP BY ERROR_TYPE ORDER BY TOTAL_ERRORS DESC;


-- =============================================================
-- SECTION C: REPORTING QUERIES
-- =============================================================

-- C1: Employee count per Department
SELECT
    D.DEPARTMENT_NAME,
    D.LOCATION,
    COUNT(E.EMPLOYEE_ID) AS TOTAL_EMPLOYEES,
    SUM(E.SALARY)        AS TOTAL_SALARY_COST
FROM DEPARTMENTS D
LEFT JOIN EMPLOYEES E ON D.DEPARTMENT_ID = E.DEPARTMENT_ID
GROUP BY D.DEPARTMENT_NAME, D.LOCATION
ORDER BY TOTAL_EMPLOYEES DESC;

-- C2: Order Revenue Summary by Status
SELECT
    STATUS,
    COUNT(ORDER_ID)     AS TOTAL_ORDERS,
    SUM(TOTAL_AMOUNT)   AS TOTAL_REVENUE,
    AVG(TOTAL_AMOUNT)   AS AVG_ORDER_VALUE
FROM ORDERS
WHERE CUSTOMER_ID IS NOT NULL
  AND ORDER_DATE IS NOT NULL
GROUP BY STATUS
ORDER BY TOTAL_REVENUE DESC;

-- C3: Clean vs Error record count (overall data health)
SELECT 'EMPLOYEES' AS TABLE_NAME,
       COUNT(*)    AS TOTAL_RECORDS,
       SUM(CASE WHEN DEPARTMENT_ID IS NULL OR EMAIL IS NULL
                  OR HIRE_DATE IS NULL OR SALARY IS NULL THEN 1 ELSE 0 END) AS ERROR_RECORDS,
       COUNT(*) - SUM(CASE WHEN DEPARTMENT_ID IS NULL OR EMAIL IS NULL
                  OR HIRE_DATE IS NULL OR SALARY IS NULL THEN 1 ELSE 0 END) AS CLEAN_RECORDS
FROM EMPLOYEES
UNION ALL
SELECT 'ORDERS',
       COUNT(*),
       SUM(CASE WHEN CUSTOMER_ID IS NULL OR CUSTOMER_NAME IS NULL
                  OR ORDER_DATE IS NULL OR QUANTITY = 0 THEN 1 ELSE 0 END),
       COUNT(*) - SUM(CASE WHEN CUSTOMER_ID IS NULL OR CUSTOMER_NAME IS NULL
                  OR ORDER_DATE IS NULL OR QUANTITY = 0 THEN 1 ELSE 0 END)
FROM ORDERS;
