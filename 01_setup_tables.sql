-- =============================================================
-- PROJECT: Oracle SQL Data Validation & Reporting
-- FILE   : 01_setup_tables.sql
-- PURPOSE: Create sample Oracle HCM / SCM style tables
-- AUTHOR : Ramshetti Siddeswara
-- TOOL   : Oracle LiveSQL (livesql.oracle.com)
-- =============================================================

-- Drop tables if they already exist (clean run)
BEGIN EXECUTE IMMEDIATE 'DROP TABLE ORDERS';       EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE EMPLOYEES';    EXCEPTION WHEN OTHERS THEN NULL; END;
/
BEGIN EXECUTE IMMEDIATE 'DROP TABLE DEPARTMENTS';  EXCEPTION WHEN OTHERS THEN NULL; END;
/

-- -------------------------------------------------------------
-- TABLE 1: DEPARTMENTS
-- Simulates Oracle HCM Department setup
-- -------------------------------------------------------------
CREATE TABLE DEPARTMENTS (
    DEPARTMENT_ID   NUMBER PRIMARY KEY,
    DEPARTMENT_NAME VARCHAR2(100) NOT NULL,
    LOCATION        VARCHAR2(100),
    MANAGER_ID      NUMBER,
    STATUS          VARCHAR2(20) DEFAULT 'ACTIVE'
);

-- -------------------------------------------------------------
-- TABLE 2: EMPLOYEES
-- Simulates Oracle HCM Employee master data
-- -------------------------------------------------------------
CREATE TABLE EMPLOYEES (
    EMPLOYEE_ID     NUMBER PRIMARY KEY,
    FIRST_NAME      VARCHAR2(50),
    LAST_NAME       VARCHAR2(50),
    EMAIL           VARCHAR2(100),
    HIRE_DATE       DATE,
    JOB_TITLE       VARCHAR2(100),
    DEPARTMENT_ID   NUMBER,   -- FK to DEPARTMENTS (intentionally some NULL/invalid for validation)
    SALARY          NUMBER,
    STATUS          VARCHAR2(20) DEFAULT 'ACTIVE'
);

-- -------------------------------------------------------------
-- TABLE 3: ORDERS
-- Simulates Oracle SCM Order Management data
-- -------------------------------------------------------------
CREATE TABLE ORDERS (
    ORDER_ID        NUMBER PRIMARY KEY,
    ORDER_DATE      DATE,
    CUSTOMER_NAME   VARCHAR2(100),
    CUSTOMER_ID     NUMBER,   -- intentionally some NULL for validation
    PRODUCT_NAME    VARCHAR2(100),
    QUANTITY        NUMBER,
    UNIT_PRICE      NUMBER,
    TOTAL_AMOUNT    NUMBER,
    STATUS          VARCHAR2(30)
);

COMMIT;
