-- =============================================================
-- PROJECT: Oracle SQL Data Validation & Reporting
-- FILE   : 02_insert_data.sql
-- PURPOSE: Insert sample data (clean + intentional errors)
-- AUTHOR : Ramshetti Siddeswara
-- =============================================================

-- -------------------------------------------------------------
-- DEPARTMENTS DATA (all clean)
-- -------------------------------------------------------------
INSERT INTO DEPARTMENTS VALUES (10, 'Human Resources',      'Hyderabad', 101, 'ACTIVE');
INSERT INTO DEPARTMENTS VALUES (20, 'Supply Chain',         'Bangalore', 102, 'ACTIVE');
INSERT INTO DEPARTMENTS VALUES (30, 'Finance',              'Mumbai',    103, 'ACTIVE');
INSERT INTO DEPARTMENTS VALUES (40, 'Information Technology','Chennai',  104, 'ACTIVE');
INSERT INTO DEPARTMENTS VALUES (50, 'Operations',           'Pune',      105, 'ACTIVE');

-- -------------------------------------------------------------
-- EMPLOYEES DATA
-- Intentional errors introduced for validation:
--   E006 - NULL department_id (orphan employee)
--   E007 - Invalid department_id 99 (does not exist)
--   E008 - NULL email
--   E009 - NULL hire_date
--   E010 - Duplicate email as E001
--   E011 - NULL salary
--   E012 - Inactive status with no department
-- -------------------------------------------------------------
INSERT INTO EMPLOYEES VALUES (1001, 'Ravi',    'Kumar',   'ravi.kumar@company.com',    DATE '2023-01-15', 'HCM Consultant',       10, 55000, 'ACTIVE');
INSERT INTO EMPLOYEES VALUES (1002, 'Priya',   'Sharma',  'priya.sharma@company.com',  DATE '2023-03-20', 'SCM Analyst',          20, 52000, 'ACTIVE');
INSERT INTO EMPLOYEES VALUES (1003, 'Arjun',   'Reddy',   'arjun.reddy@company.com',   DATE '2022-07-10', 'Finance Executive',    30, 48000, 'ACTIVE');
INSERT INTO EMPLOYEES VALUES (1004, 'Sneha',   'Patel',   'sneha.patel@company.com',   DATE '2024-01-05', 'IT Developer',         40, 60000, 'ACTIVE');
INSERT INTO EMPLOYEES VALUES (1005, 'Kiran',   'Babu',    'kiran.babu@company.com',    DATE '2023-09-12', 'Operations Manager',   50, 65000, 'ACTIVE');
-- ERROR RECORDS BELOW
INSERT INTO EMPLOYEES VALUES (1006, 'Meena',   'Rao',     'meena.rao@company.com',     DATE '2024-02-01', 'HR Executive',         NULL, 45000, 'ACTIVE');   -- E001: NULL dept
INSERT INTO EMPLOYEES VALUES (1007, 'Suresh',  'Nair',    'suresh.nair@company.com',   DATE '2023-11-15', 'SCM Coordinator',      99,   47000, 'ACTIVE');   -- E002: Invalid dept 99
INSERT INTO EMPLOYEES VALUES (1008, 'Divya',   'Menon',   NULL,                        DATE '2023-06-20', 'Finance Analyst',      30,   43000, 'ACTIVE');   -- E003: NULL email
INSERT INTO EMPLOYEES VALUES (1009, 'Rahul',   'Singh',   'rahul.singh@company.com',   NULL,              'IT Consultant',        40,   58000, 'ACTIVE');   -- E004: NULL hire_date
INSERT INTO EMPLOYEES VALUES (1010, 'Vijay',   'Iyer',    'ravi.kumar@company.com',    DATE '2024-03-10', 'HCM Analyst',          10,   50000, 'ACTIVE');   -- E005: Duplicate email
INSERT INTO EMPLOYEES VALUES (1011, 'Lakshmi', 'Devi',    'lakshmi.devi@company.com',  DATE '2023-08-25', 'Operations Lead',      50,   NULL,  'ACTIVE');   -- E006: NULL salary
INSERT INTO EMPLOYEES VALUES (1012, 'Ajay',    'Verma',   'ajay.verma@company.com',    DATE '2022-12-01', 'HR Manager',           NULL, 70000, 'INACTIVE'); -- E007: Inactive + NULL dept

-- -------------------------------------------------------------
-- ORDERS DATA
-- Intentional errors:
--   O006 - NULL customer_id
--   O007 - NULL customer_name
--   O008 - Zero quantity
--   O009 - Total amount mismatch
--   O010 - NULL order date
-- -------------------------------------------------------------
INSERT INTO ORDERS VALUES (5001, DATE '2025-01-10', 'Infosys Ltd',       201, 'Oracle License',    5,  10000, 50000,  'COMPLETED');
INSERT INTO ORDERS VALUES (5002, DATE '2025-01-15', 'TCS India',         202, 'Cloud Subscription',3,  15000, 45000,  'COMPLETED');
INSERT INTO ORDERS VALUES (5003, DATE '2025-02-01', 'Wipro Technologies',203, 'Hardware Module',   10, 5000,  50000,  'PROCESSING');
INSERT INTO ORDERS VALUES (5004, DATE '2025-02-20', 'HCL Systems',       204, 'Support Services',  1,  20000, 20000,  'COMPLETED');
INSERT INTO ORDERS VALUES (5005, DATE '2025-03-05', 'Tech Mahindra',     205, 'ERP Add-on',        2,  12000, 24000,  'PENDING');
-- ERROR RECORDS
INSERT INTO ORDERS VALUES (5006, DATE '2025-03-10', 'Cognizant',         NULL,'Data Migration',    4,  8000,  32000,  'COMPLETED');  -- E001: NULL customer_id
INSERT INTO ORDERS VALUES (5007, DATE '2025-03-12', NULL,                207, 'Oracle HCM Module', 6,  9000,  54000,  'PENDING');    -- E002: NULL customer_name
INSERT INTO ORDERS VALUES (5008, DATE '2025-03-15', 'Mphasis Ltd',       208, 'Training Package',  0,  5000,  0,      'PENDING');    -- E003: Zero quantity
INSERT INTO ORDERS VALUES (5009, DATE '2025-03-18', 'Hexaware Tech',     209, 'SCM License',       3,  7000,  30000,  'COMPLETED');  -- E004: Total mismatch (3*7000=21000, not 30000)
INSERT INTO ORDERS VALUES (5010, NULL,              'Birlasoft',         210, 'ERP Upgrade',       2,  11000, 22000,  'PROCESSING'); -- E005: NULL order date

COMMIT;
