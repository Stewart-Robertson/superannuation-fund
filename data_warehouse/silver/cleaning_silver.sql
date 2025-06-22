/*

************************************************************
Cleaning & Enrichment Script: Refine Bronze Tables Before Loading Into Silver Tables
************************************************************

The purpose of this script.
    - This SQL script will clean the bronze layer tables before loading the silver layer tables.
    - Issues identified in the test_bronze.sql file will be addressed in this script.
    - Further table modifications will be made, such as creating new columns
    - Subject matter expertise has been consulted and recommended the changes

*/

/*
============================================================
Fixing identified issues in the bronze layer tables
============================================================
*/

-- Issue 1: For some companies, there are more member IDs than the total number of employees in the member_employees table.
-- Set total_employees to match the actual number of unique members for each employer if member count exceeds total_employees.
-- Assume subject matter expert has been consulted and recommended this fix.
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

-- Issue 2: Some employment start_dates >= end_dates in the employment_history table. Checks show that these are all current roles.
-- For current roles (end_date IS NULL or start_date >= end_date), set end_date to a placeholder far in the future for consistency (e.g., '9999-12-31')
UPDATE SUPERANNUATION.BRONZE.EMPLOYMENT_HISTORY
SET end_date = '9999-12-31'
WHERE end_date IS NULL OR start_date >= end_date;

-- Issue 3: Members who are not currently employed do not appear in the member_employers table (does not require a fix).

-- Issue 4: There are some members who do not have a super balance but have a contribution rate and are employed.
-- Set contribution rates to zero for employed members with zero balance. Assume subject matter expert has been consulted and recommended this fix.
UPDATE SUPERANNUATION.BRONZE.SUPERANNUATION_MEMBERS
SET employer_contribution_rate = 0,
    employee_contribution_rate = 0
WHERE super_balance = 0
  AND (employer_contribution_rate > 0 OR employee_contribution_rate > 0)
  AND employment_status IN ('full_time_employed', 'casual', 'part_time');

-- Issue 5: Members who are employed, with contribution rates, but no super balance 
-- Leaving this issue as it is, as further information/data from the subject matter expert is required

/*
============================================================
Adding new columns to the silver layer tables
============================================================
*/


/*
*******************************
superannuation_members table
*******************************
*/

-- Adding an age column to the superannuation_members table
ALTER TABLE SUPERANNUATION.SILVER.SUPERANNUATION_MEMBERS
ADD age INT;
-- Update the age column with the age of the member
UPDATE SUPERANNUATION.SILVER.SUPERANNUATION_MEMBERS
SET age = FLOOR(DATEDIFF(YEAR, date_of_birth, CURRENT_DATE) / 365.25);

-- Add combined contribution rate column to the superannuation_members table
ALTER TABLE SUPERANNUATION.SILVER.SUPERANNUATION_MEMBERS
ADD combined_contribution_rate DECIMAL(5,4);
-- Update the combined contribution rate column, handling NULL values
UPDATE SUPERANNUATION.SILVER.SUPERANNUATION_MEMBERS
SET combined_contribution_rate = COALESCE(employer_contribution_rate, 0) + COALESCE(employee_contribution_rate, 0);

-- Add insurance coverage as a percentage of salary
ALTER TABLE SUPERANNUATION.SILVER.SUPERANNUATION_MEMBERS
ADD insurance_coverage_by_salary DECIMAL(5,4);
-- Update the insurance coverage percentage, handling NULL and zero salary cases
UPDATE SUPERANNUATION.SILVER.SUPERANNUATION_MEMBERS
SET insurance_coverage_by_salary = 
    CASE 
        WHEN salary = 0 THEN 0
        WHEN salary IS NULL THEN NULL
        ELSE insurance_coverage / salary
    END;

-- Add a superannuation balance as a percentage of salary
ALTER TABLE SUPERANNUATION.SILVER.SUPERANNUATION_MEMBERS
ADD super_balance_by_salary DECIMAL(5,4);
UPDATE SUPERANNUATION.SILVER.SUPERANNUATION_MEMBERS
SET super_balance_by_salary = 
    CASE 
        WHEN salary = 0 THEN 0
        WHEN salary IS NULL THEN NULL
        ELSE super_balance / salary
    END;


/*
*******************************
employment_history table
*******************************
*/

-- Add a column for the number of days in the employment period
ALTER TABLE SUPERANNUATION.SILVER.EMPLOYMENT_HISTORY
ADD employment_days INT;

UPDATE SUPERANNUATION.SILVER.EMPLOYMENT_HISTORY
SET employment_days = DATEDIFF(DAY, start_date, end_date);


