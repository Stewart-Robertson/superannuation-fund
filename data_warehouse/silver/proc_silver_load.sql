/* 

************************************************************
Stored procedure: load data from bronze layer tables into silver layer tables
************************************************************

The purpose of this script:
    - This SQL script truncates the tables in the silver layer
    - It applies cleaning transformations to the bronze layer tables
    - It loads cleaned, transformed data into the silver layer
    - It then updates the newly created columns from cleaning_silver.sql with calculated values
    
*/

CREATE OR REPLACE PROCEDURE SUPERANNUATION.SILVER.proc_load_silver()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN

-- Step 1: Clean bronze tables

-- Clean member_employers: Update total_employees to match actual member count if necessary
UPDATE SUPERANNUATION.BRONZE.MEMBER_EMPLOYERS me
SET total_employees = (
    SELECT COUNT(DISTINCT eh.member_id)
    FROM SUPERANNUATION.BRONZE.EMPLOYMENT_HISTORY eh
    WHERE eh.employer_id = me.employer_id
)
WHERE total_employees < (
    SELECT COUNT(DISTINCT eh2.member_id)
    FROM SUPERANNUATION.BRONZE.EMPLOYMENT_HISTORY eh2
    WHERE eh2.employer_id = me.employer_id
);

-- Clean employment_history: Set end_date to '9999-12-31' for current roles
UPDATE SUPERANNUATION.BRONZE.EMPLOYMENT_HISTORY
SET end_date = '9999-12-31'
WHERE end_date IS NULL OR start_date >= end_date;

-- Clean superannuation_members: Set contribution rates to zero for employed members with zero balance
UPDATE SUPERANNUATION.BRONZE.SUPERANNUATION_MEMBERS
SET employer_contribution_rate = 0,
    employee_contribution_rate = 0
WHERE super_balance = 0
  AND (employer_contribution_rate > 0 OR employee_contribution_rate > 0)
  AND employment_status IN ('full_time_employed', 'casual', 'part_time');

-- Step 2: Truncate silver tables
TRUNCATE TABLE SUPERANNUATION.SILVER.SUPERANNUATION_MEMBERS;
TRUNCATE TABLE SUPERANNUATION.SILVER.MEMBER_EMPLOYERS;
TRUNCATE TABLE SUPERANNUATION.SILVER.EMPLOYMENT_HISTORY;

-- Step 3: Load cleaned data from bronze tables
INSERT INTO SUPERANNUATION.SILVER.SUPERANNUATION_MEMBERS (
    member_id,
    first_name,
    last_name,
    date_of_birth,
    gender,
    employment_status,
    salary,
    employer_contribution_rate,
    employee_contribution_rate,
    super_balance,
    investment_option,
    insurance_coverage
)
SELECT 
    member_id,
    first_name,
    last_name,
    date_of_birth,
    gender,
    employment_status,
    salary,
    employer_contribution_rate,
    employee_contribution_rate,
    super_balance,
    investment_option,
    insurance_coverage
FROM SUPERANNUATION.BRONZE.SUPERANNUATION_MEMBERS;

INSERT INTO SUPERANNUATION.SILVER.MEMBER_EMPLOYERS (
    relationship_id,
    employer_id,
    member_id,
    company_name,
    industry,
    head_office_state,
    total_employees,
    avg_salary,
    default_super_fund_option,
    default_fund_risk_profile
)
SELECT 
    relationship_id,
    employer_id,
    member_id,
    company_name,
    industry,
    head_office_state,
    total_employees,
    avg_salary,
    default_super_fund_option,
    default_fund_risk_profile
FROM SUPERANNUATION.BRONZE.MEMBER_EMPLOYERS;

INSERT INTO SUPERANNUATION.SILVER.EMPLOYMENT_HISTORY (
    employment_id,
    member_id,
    employer_id,
    position_title,
    start_date,
    end_date,
    employment_type,
    final_salary
)
SELECT 
    employment_id,
    member_id,
    employer_id,
    position_title,
    start_date,
    end_date,
    employment_type,
    final_salary
FROM SUPERANNUATION.BRONZE.EMPLOYMENT_HISTORY;

-- Step 3: Update enriched columns
-- Update age column
UPDATE SUPERANNUATION.SILVER.SUPERANNUATION_MEMBERS
SET age = DATEDIFF(YEAR, date_of_birth, CURRENT_DATE);

-- Update combined contribution rate
UPDATE SUPERANNUATION.SILVER.SUPERANNUATION_MEMBERS
SET combined_contribution_rate = COALESCE(employer_contribution_rate, 0) + COALESCE(employee_contribution_rate, 0);

-- Update insurance coverage percentage
UPDATE SUPERANNUATION.SILVER.SUPERANNUATION_MEMBERS
SET insurance_coverage_by_salary = 
    CASE 
        WHEN salary = 0 THEN 0
        WHEN salary IS NULL THEN NULL
        ELSE insurance_coverage / salary
    END;

-- Update super balance percentage
UPDATE SUPERANNUATION.SILVER.SUPERANNUATION_MEMBERS
SET super_balance_by_salary = 
    CASE 
        WHEN salary = 0 THEN 0
        WHEN salary IS NULL THEN NULL
        ELSE ROUND(super_balance / salary, 2)
    END;

-- Update employment duration
UPDATE SUPERANNUATION.SILVER.EMPLOYMENT_HISTORY
SET employment_days = DATEDIFF(DAY, start_date, end_date);

RETURN 'Successfully loaded silver tables';

END;
$$;

CALL SUPERANNUATION.SILVER.proc_load_silver();