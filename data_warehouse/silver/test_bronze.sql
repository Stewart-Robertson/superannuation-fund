/* 

************************************************************
Test Script for Bronze Layer Table Quality
************************************************************

The purpose of this script.
    - This SQL script will perform quality tests of the bronze layer of the data warehouse.

*/

-- Issues identified:
-- 1. For some companies, there are more member IDs than the total number of employees in the member_employees table.
-- 2. Some employment start_dates >= end_dates in the employment_history table. Checks show that these are all current roles.
-- 3. Current roles have null end_dates in the employment_history table.
-- 4. Members who are not currently employed do not appear in the member_employers table (does not require a fix).
-- 5. There are some members who do not have a super balance but have a contribution rate and are employed.

/*

============================================================
Test the quality and values of the superannuation_members table
============================================================

*/

-- Test 1: Check for duplicate member IDs
SELECT member_id, COUNT(*)
FROM SUPERANNUATION.BRONZE.SUPERANNUATION_MEMBERS
GROUP BY member_id
HAVING COUNT(*) > 1;

-- Test 2: Check for missing values in NOT NULL columns
SELECT *
FROM SUPERANNUATION.BRONZE.SUPERANNUATION_MEMBERS
WHERE first_name IS NULL
   OR last_name IS NULL
   OR date_of_birth IS NULL
   OR gender IS NULL
   OR employment_status IS NULL
   OR salary IS NULL
   OR employer_contribution_rate IS NULL
   OR employee_contribution_rate IS NULL
   OR super_balance IS NULL
   OR investment_option IS NULL
   OR insurance_coverage IS NULL;

-- Test 3: Check salary values
SELECT *
FROM SUPERANNUATION.BRONZE.SUPERANNUATION_MEMBERS
WHERE salary NOT BETWEEN 20000 AND 1000000;

-- Test 4: Check for valid date_of_birth (e.g., not in the future, etc.)
SELECT *
FROM SUPERANNUATION.BRONZE.SUPERANNUATION_MEMBERS
WHERE date_of_birth > CURRENT_DATE
   OR date_of_birth < '1900-01-01'
   OR date_of_birth > DATEADD('year', -18, CURRENT_DATE);

-- Test 5: Check for valid gender values
SELECT *
FROM SUPERANNUATION.BRONZE.SUPERANNUATION_MEMBERS
WHERE UPPER(gender) NOT IN ('MALE', 'FEMALE', 'OTHER');

-- Test 6: Check for valid contribution rates (e.g., between 0 and 1)
SELECT *
FROM SUPERANNUATION.BRONZE.SUPERANNUATION_MEMBERS
WHERE employer_contribution_rate NOT BETWEEN 0 AND 0.2
   OR employee_contribution_rate NOT BETWEEN 0 AND 0.2;

-- Test 7: Check for valid employment_status values
SELECT *
FROM SUPERANNUATION.BRONZE.SUPERANNUATION_MEMBERS
WHERE employment_status NOT IN ('full_time_employed', 'unemployed', 'retired', 'student', 'casual', 'part_time');

-- Test 8: Check for valid investment_option values
SELECT *
FROM SUPERANNUATION.BRONZE.SUPERANNUATION_MEMBERS
WHERE investment_option NOT IN (
    'cash',
    'capital_guaranteed',
    'conservative',
    'moderate',
    'balanced',
    'socially_responsible_balanced',
    'growth',
    'high_growth',
    'international_growth'
    );

-- Test 9: Check for valid insurance coverage values (e.g., between 0 and 1_000_000)
SELECT *
FROM SUPERANNUATION.BRONZE.SUPERANNUATION_MEMBERS
WHERE insurance_coverage NOT BETWEEN 0 AND 1000000; -- Assume that the fund has a maximum of $1M in insurance coverage

-- Test 10: Check for valid super balance (e.g., between 0 and 15_000_000)
SELECT *
FROM SUPERANNUATION.BRONZE.SUPERANNUATION_MEMBERS
WHERE super_balance NOT BETWEEN 0 AND 15000000; -- Assume that the fund has a maximum of $15M in super balance


-- Test 11: Check for leading or trailing whitespace in NOT NULL columns
SELECT *
FROM SUPERANNUATION.BRONZE.SUPERANNUATION_MEMBERS
WHERE 
    TRIM(first_name) <> first_name
    OR TRIM(last_name) <> last_name
    OR TRIM(member_id) <> member_id
    OR TRIM(gender) <> gender
    OR TRIM(employment_status) <> employment_status
    OR TRIM(investment_option) <> investment_option;

-- Test 12: Check for zero super balance with non-zero contribution rates
SELECT *
FROM SUPERANNUATION.BRONZE.SUPERANNUATION_MEMBERS
WHERE super_balance = 0
AND (employer_contribution_rate > 0 OR employee_contribution_rate > 0);

-- Test 13: Check for zero contribution rates but non-zero super balance for people who are in their first job
SELECT *
FROM SUPERANNUATION.BRONZE.SUPERANNUATION_MEMBERS sm
WHERE sm.super_balance > 0
AND sm.employer_contribution_rate = 0
AND sm.employee_contribution_rate = 0
AND sm.employment_status <> 'student'
AND NOT EXISTS (
    SELECT 1
    FROM SUPERANNUATION.BRONZE.EMPLOYMENT_HISTORY eh
    WHERE eh.member_id = sm.member_id
    AND eh.start_date < CURRENT_DATE
);

/*

============================================================
Test the quality and values of the member_employers table
============================================================

*/

-- Test 1: Check for duplicate relationship IDs
SELECT relationship_id, COUNT(*)
FROM SUPERANNUATION.BRONZE.MEMBER_EMPLOYERS
GROUP BY relationship_id
HAVING COUNT(*) > 1;

-- Test 2: Check for missing values in NOT NULL columns
SELECT *
FROM SUPERANNUATION.BRONZE.MEMBER_EMPLOYERS
WHERE employer_id IS NULL
   OR member_id IS NULL
   OR company_name IS NULL
   OR industry IS NULL
   OR head_office_state IS NULL
   OR total_employees IS NULL
   OR avg_salary IS NULL
   OR default_super_fund_option IS NULL
   OR default_fund_risk_profile IS NULL;

-- Test 3: Check for realistic total_employees and avg_salary values
SELECT *
FROM SUPERANNUATION.BRONZE.MEMBER_EMPLOYERS
WHERE total_employees NOT BETWEEN 1 AND 3000000 OR avg_salary NOT BETWEEN 20000 AND 1000000;

-- Test 4: Check that the total employees per company is greater than the number of members in that company
SELECT *
FROM SUPERANNUATION.BRONZE.MEMBER_EMPLOYERS me
WHERE total_employees < (
    SELECT COUNT(DISTINCT member_id) 
    FROM SUPERANNUATION.BRONZE.EMPLOYMENT_HISTORY eh
    WHERE eh.employer_id = me.employer_id
);

-- Test 5: Check for leading or trailing whitespace in NOT NULL columns
SELECT *
FROM SUPERANNUATION.BRONZE.MEMBER_EMPLOYERS
WHERE TRIM(company_name) <> company_name
   OR TRIM(industry) <> industry
   OR TRIM(head_office_state) <> head_office_state
   OR TRIM(default_super_fund_option) <> default_super_fund_option
   OR TRIM(default_fund_risk_profile) <> default_fund_risk_profile;

-- Test 6: Check for valid industry values
SELECT *
FROM SUPERANNUATION.BRONZE.MEMBER_EMPLOYERS
WHERE industry NOT IN (
    'Mining', 'Finance', 'Technology', 'Healthcare', 'Education', 'Government',
    'Manufacturing', 'Retail', 'Hospitality', 'Construction', 'Professional Services', 'Transport'
    );

-- Test 7: Check for valid head_office_state values
SELECT *
FROM SUPERANNUATION.BRONZE.MEMBER_EMPLOYERS
WHERE head_office_state NOT IN ('NSW', 'VIC', 'QLD', 'WA', 'SA', 'TAS', 'NT', 'ACT');

-- Test 8: Check for valid default_super_fund_option values
SELECT *
FROM SUPERANNUATION.BRONZE.MEMBER_EMPLOYERS
WHERE default_super_fund_option NOT IN (
    'cash',
    'capital_guaranteed',
    'conservative',
    'moderate',
    'balanced',
    'socially_responsible_balanced',
    'growth',
    'high_growth',
    'international_growth'
    );

-- Test 9: Check for valid default_fund_risk_profile values
SELECT *
FROM SUPERANNUATION.BRONZE.MEMBER_EMPLOYERS
WHERE default_fund_risk_profile NOT IN (
    'conservative', 'moderate', 'aggressive'
    );

-- Test 10: Check every member in the member_employers table has a corresponding entry in the superannuation_members table
SELECT *
FROM SUPERANNUATION.BRONZE.MEMBER_EMPLOYERS me
WHERE NOT EXISTS (
    SELECT 1
    FROM SUPERANNUATION.BRONZE.SUPERANNUATION_MEMBERS sm
    WHERE sm.member_id = me.member_id
    );

-- Test 11: Check every employer in the member_employers table has a corresponding entry in the employment_history table
SELECT *
FROM SUPERANNUATION.BRONZE.MEMBER_EMPLOYERS me
WHERE NOT EXISTS (
    SELECT 1
    FROM SUPERANNUATION.BRONZE.EMPLOYMENT_HISTORY eh
    WHERE eh.employer_id = me.employer_id
    );

/*

============================================================
Test the quality and values of the employment_history table
============================================================

*/

-- Test 1: Check for duplicate employment IDs
SELECT employment_id, COUNT(*)
FROM SUPERANNUATION.BRONZE.EMPLOYMENT_HISTORY
GROUP BY employment_id
HAVING COUNT(*) > 1;

-- Test 2: Check for missing values in NOT NULL columns
SELECT *
FROM SUPERANNUATION.BRONZE.EMPLOYMENT_HISTORY
WHERE member_id IS NULL
   OR employer_id IS NULL
   OR position_title IS NULL
   OR start_date IS NULL
   OR employment_type IS NULL
   OR final_salary IS NULL;

-- Test 3: Check for realistic final_salary values
SELECT *
FROM SUPERANNUATION.BRONZE.EMPLOYMENT_HISTORY
WHERE final_salary NOT BETWEEN 20000 AND 1000000;

-- Test 4: Check for valid date range (start_date should be before end_date and not in the future)
SELECT *
FROM SUPERANNUATION.BRONZE.EMPLOYMENT_HISTORY
WHERE start_date >= end_date
   OR start_date > CURRENT_DATE
   OR end_date > CURRENT_DATE;

-- Test 5: For records where start_date >= end_date , check if start_date is the max date for that member and the member is currently employed
SELECT *
FROM SUPERANNUATION.BRONZE.EMPLOYMENT_HISTORY eh
WHERE (eh.start_date >= eh.end_date)
  AND eh.start_date = (
      SELECT GREATEST(
          MAX(COALESCE(eh2.start_date, '1900-01-01')),
          MAX(COALESCE(eh2.end_date, '1900-01-01'))
      )
      FROM SUPERANNUATION.BRONZE.EMPLOYMENT_HISTORY eh2
      WHERE eh2.member_id = eh.member_id
  )
  AND EXISTS (
      SELECT 1
      FROM SUPERANNUATION.BRONZE.SUPERANNUATION_MEMBERS sm
      WHERE sm.member_id = eh.member_id
        AND sm.employment_status IN ('full_time_employed', 'casual', 'part_time')
  );

-- Test 6: Check for records where end_date is NULL but start_date is not
SELECT *
FROM SUPERANNUATION.BRONZE.EMPLOYMENT_HISTORY
WHERE end_date IS NULL;

-- Test 7: Check for valid employment_type values
SELECT *
FROM SUPERANNUATION.BRONZE.EMPLOYMENT_HISTORY
WHERE employment_type NOT IN ('full-time', 'contract', 'part-time');

-- Test 8: Check for leading or trailing whitespace in NOT NULL columns
SELECT *
FROM SUPERANNUATION.BRONZE.EMPLOYMENT_HISTORY
WHERE TRIM(position_title) <> position_title
   OR TRIM(employment_type) <> employment_type
   OR TRIM(member_id) <> member_id;

-- Test 9: Check for valid employer_id values
SELECT *
FROM SUPERANNUATION.BRONZE.EMPLOYMENT_HISTORY
WHERE employer_id NOT IN (
    SELECT employer_id
    FROM SUPERANNUATION.BRONZE.MEMBER_EMPLOYERS
    );

-- Test 10: Check for valid member_id values
SELECT *
FROM SUPERANNUATION.BRONZE.EMPLOYMENT_HISTORY
WHERE member_id NOT IN (
    SELECT member_id
    FROM SUPERANNUATION.BRONZE.SUPERANNUATION_MEMBERS
    );