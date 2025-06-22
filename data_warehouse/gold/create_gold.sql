/*

*****************************************************************************************
Create the Gold Layer: Use silver layer tables to create an analytical model for business intelligence
*****************************************************************************************

The purpose of this script:
    - Create the Gold Layer Star Schema for Superannuation Analytics
    - Use silver layer tables to create an analytical model for business intelligence
    - There will be four tables: one fact table and three dimension tables:
        - FACT_MEMBER_CONTRIBUTION_PERFORMANCE
        - DIM_MEMBER
        - DIM_EMPLOYER
        - DIM_EMPLOYMENT
    - 

=============
    Note
=============
This script treats the gold layer as a one-off, static model as the project will be completed in a single sprint.
It does not include any CI/CD or historization.
  
*/

-- Gold Layer Star Schema for Superannuation Analytics

USE DATABASE SUPERANNUATION;
USE SCHEMA GOLD;

/*

===============================
        Dimension Tables
===============================

************
 DIM_MEMBER
************

*/
CREATE OR REPLACE TABLE DIM_MEMBER AS
SELECT
    m.member_id,
    m.first_name,
    m.last_name,
    m.first_name || ' ' || m.last_name AS full_name,
    m.date_of_birth,
    FLOOR(DATEDIFF('year', m.date_of_birth, CURRENT_DATE())) AS age, -- Calculate age once
    m.gender,
    m.investment_option,
    m.super_balance,
    m.insurance_coverage,
    m.salary,
    m.employment_status,
    m.employee_contribution_rate,
    m.employer_contribution_rate,

    -- Segmentation: Age Group (using direct age calculation)
    CASE
        WHEN FLOOR(DATEDIFF('year', m.date_of_birth, CURRENT_DATE())) BETWEEN 18 AND 24 THEN '18-24'
        WHEN FLOOR(DATEDIFF('year', m.date_of_birth, CURRENT_DATE())) BETWEEN 25 AND 34 THEN '25-34'
        WHEN FLOOR(DATEDIFF('year', m.date_of_birth, CURRENT_DATE())) BETWEEN 35 AND 44 THEN '35-44'
        WHEN FLOOR(DATEDIFF('year', m.date_of_birth, CURRENT_DATE())) BETWEEN 45 AND 54 THEN '45-54'
        WHEN FLOOR(DATEDIFF('year', m.date_of_birth, CURRENT_DATE())) BETWEEN 55 AND 64 THEN '55-64'
        ELSE '65+'
    END AS age_group,

    -- Life Stage (using direct age calculation)
    CASE
        WHEN FLOOR(DATEDIFF('year', m.date_of_birth, CURRENT_DATE())) < 30 THEN 'Early Career/Student'
        WHEN FLOOR(DATEDIFF('year', m.date_of_birth, CURRENT_DATE())) BETWEEN 30 AND 49 THEN 'Peak Earning'
        WHEN FLOOR(DATEDIFF('year', m.date_of_birth, CURRENT_DATE())) >= 50 THEN 'Pre-Retirement/Retirement'
        ELSE 'Unknown'
    END AS life_stage,

    -- Balance Tier
    CASE
        WHEN m.super_balance < 50000 THEN 'Low'
        WHEN m.super_balance BETWEEN 50000 AND 200000 THEN 'Medium'
        WHEN m.super_balance BETWEEN 200001 AND 500000 THEN 'High'
        ELSE 'Premium' -- Covers > 500000
    END AS balance_tier,

    -- Insurance Adequacy
    CASE
        WHEN m.insurance_coverage < 100000 THEN 'low-insured'
        WHEN m.insurance_coverage BETWEEN 100000 AND 500000 THEN 'mid-insured'
        ELSE 'high-insured' -- Covers > 500000
    END AS insurance_level,

    -- Insurance Premium Revenue (using direct age calculation for age groups)
    CASE
        WHEN FLOOR(DATEDIFF('year', m.date_of_birth, CURRENT_DATE())) BETWEEN 18 AND 44 THEN m.insurance_coverage * 0.05 -- Covers '18-24', '25-34', '35-44'
        WHEN FLOOR(DATEDIFF('year', m.date_of_birth, CURRENT_DATE())) BETWEEN 45 AND 64 THEN m.insurance_coverage * 0.01 -- Covers '45-54', '55-64'
        ELSE m.insurance_coverage * 0.015 -- For '65+' and any other edge cases
    END AS insurance_premium_revenue,

    -- Simplified Super Growth Potential Segment (using m.salary, m.super_balance, age, and m.employment_status)
    CASE
        -- Students have high future potential
        WHEN UPPER(m.employment_status) = 'STUDENT' THEN 'High'

        -- High earners in prime earning years with room to grow balance
        WHEN m.salary >= 150000 AND FLOOR(DATEDIFF('year', m.date_of_birth, CURRENT_DATE())) < 50 AND m.super_balance < 300000 THEN 'Premium'
        WHEN m.salary >= 100000 AND FLOOR(DATEDIFF('year', m.date_of_birth, CURRENT_DATE())) < 50 AND m.super_balance < 200000 THEN 'High'

        -- Mid-tier earners with growth runway or already good balance for their age
        WHEN m.salary >= 70000 AND FLOOR(DATEDIFF('year', m.date_of_birth, CURRENT_DATE())) < 50 AND m.super_balance < 150000 THEN 'Medium'
        WHEN m.salary >= 50000 AND FLOOR(DATEDIFF('year', m.date_of_birth, CURRENT_DATE())) < 40 AND m.super_balance < 100000 THEN 'Medium'

        -- Members with already substantial balances might be considered 'Established' or 'Low' for *new* growth focus
        WHEN m.super_balance >= 500000 THEN 'Established/Low Growth Focus'
        WHEN m.super_balance >= 300000 AND FLOOR(DATEDIFF('year', m.date_of_birth, CURRENT_DATE())) >= 50 THEN 'Established/Low Growth Focus'

        -- Retired or Unemployed (current salary not indicative of active growth
        WHEN UPPER(m.employment_status) IN ('RETIRED', 'UNEMPLOYED') THEN 'Low'

        -- Default to Low for others (e.g., lower salary, older age with lower balance)
        ELSE 'Low'
    END AS super_growth_potential_segment,

    -- Campaign Priority (using direct age calculation)
    CASE
        WHEN m.salary > 100000 AND (m.employer_contribution_rate + m.employee_contribution_rate) < 0.15 THEN 'Priority Campaign Target'
        WHEN m.insurance_coverage < 100000 AND m.salary > 80000 THEN 'Insurance Upsell Target'
        WHEN FLOOR(DATEDIFF('year', m.date_of_birth, CURRENT_DATE())) < 35 AND m.super_balance < 50000 AND m.salary > 70000 THEN 'Early Career Intervention'
        ELSE 'Standard'
    END AS campaign_priority,
    -- Risk Appetite
    CASE
        WHEN LOWER(m.investment_option) LIKE '%high_growth%' OR LOWER(m.investment_option) LIKE '%international_growth%' THEN 'Aggressive'
        WHEN LOWER(m.investment_option) LIKE '%growth%' THEN 'High'
        WHEN LOWER(m.investment_option) LIKE '%balanced%' OR LOWER(m.investment_option) LIKE '%moderate%' OR LOWER(m.investment_option) LIKE '%socially_responsible_balanced%' THEN 'Medium'
        WHEN LOWER(m.investment_option) LIKE '%conservative%' OR LOWER(m.investment_option) LIKE '%capital_guaranteed%' OR LOWER(m.investment_option) LIKE '%cash%' THEN 'Low'
        ELSE 'Unknown'
    END AS risk_appetite
FROM SUPERANNUATION.SILVER.SUPERANNUATION_MEMBERS m;


/*
************
 DIM_EMPLOYER
************
*/
CREATE OR REPLACE TABLE DIM_EMPLOYER AS
SELECT
    e.relationship_id,
    e.employer_id,
    e.company_name,
    e.industry,
    e.head_office_state,
    e.total_employees,
    e.avg_salary,
    e.default_super_fund_option,
    e.default_fund_risk_profile,
    -- Salary Tier
    CASE
        WHEN e.avg_salary < 60000 THEN 'Below Average'
        WHEN e.avg_salary BETWEEN 60000 AND 90000 THEN 'Average'
        WHEN e.avg_salary BETWEEN 90001 AND 150000 THEN 'Above Average'
        ELSE 'Premium'
    END AS salary_tier,
    -- Industry Growth Potential
    CASE
        WHEN LOWER(e.industry) IN ('technology', 'biotechnology', 'renewable energy', 'artificial intelligence') THEN 'High-Growth'
        WHEN LOWER(e.industry) IN ('healthcare', 'finance', 'professional services', 'education technology') THEN 'Growing'
        WHEN LOWER(e.industry) IN ('manufacturing', 'retail', 'construction', 'education', 'government', 'mining') THEN 'Stable'
        WHEN LOWER(e.industry) IN ('traditional media', 'tobacco') THEN 'Declining'
        ELSE 'Unknown'
    END AS industry_growth_potential,
    -- Partnership Value Tier
    CASE
        WHEN e.total_employees * e.avg_salary > 700000000 THEN 'Platinum'
        WHEN e.total_employees * e.avg_salary BETWEEN 500000000 AND 700000000 THEN 'Gold'
        WHEN e.total_employees * e.avg_salary BETWEEN 300000000 AND 500000000 THEN 'Silver'
        ELSE 'Bronze'
    END AS partnership_value_tier,
FROM SUPERANNUATION.SILVER.MEMBER_EMPLOYERS e;

/*
*************
DIM_EMPLOYMENT
*************
*/
CREATE OR REPLACE TABLE DIM_EMPLOYMENT AS
SELECT
    eh.employment_id,
    eh.member_id,
    eh.employer_id,
    eh.position_title,
    eh.start_date,
    eh.end_date,
    eh.employment_type,
    eh.final_salary,
    CASE
        WHEN eh.end_date < CURRENT_DATE() 
            THEN DATEDIFF('day', eh.start_date, eh.end_date)
        ELSE DATEDIFF('day', eh.start_date, CURRENT_DATE())
    END AS employment_duration_days,
    ROUND(
        CASE
            WHEN eh.end_date < CURRENT_DATE() 
                THEN DATEDIFF('day', eh.start_date, eh.end_date)
            ELSE DATEDIFF('day', eh.start_date, CURRENT_DATE())
        END / 365.25, 2
    ) AS employment_duration_years,
    -- Is Current Employm ent
    CASE WHEN eh.end_date > CURRENT_DATE() THEN TRUE ELSE FALSE END AS is_current_employment,
    -- Length of time unemployed in months
    CASE
        WHEN eh.end_date IS NOT NULL
             AND eh.end_date = (
                 SELECT MAX(eh2.end_date)
                 FROM SUPERANNUATION.SILVER.EMPLOYMENT_HISTORY eh2
                 WHERE eh2.member_id = eh.member_id
             )
             AND eh.end_date < CURRENT_DATE()
        THEN FLOOR(DATEDIFF('month', eh.end_date, CURRENT_DATE()))
        ELSE 0
    END AS months_unemployed   
FROM SUPERANNUATION.SILVER.EMPLOYMENT_HISTORY eh;

/*

===============================
         Fact Table
===============================

*/
CREATE OR REPLACE TABLE FACT_MEMBER_CONTRIBUTION_PERFORMANCE AS
WITH most_recent_employment AS (
    SELECT *
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (
                   PARTITION BY member_id 
                   ORDER BY 
                       COALESCE(end_date, DATE '9999-12-31') DESC, 
                       start_date DESC
               ) AS rn
        FROM SUPERANNUATION.SILVER.EMPLOYMENT_HISTORY
    )
    WHERE rn = 1
)
SELECT
    m.member_id,
    CASE
        WHEN me.relationship_id IS NOT NULL THEN me.relationship_id
        ELSE NULL
    END AS relationship_id,
    e.employment_id,
    -- Core Revenue Metrics
    m.salary as current_salary,
    m.super_balance,
    m.insurance_coverage,
    m.employer_contribution_rate,
    m.employee_contribution_rate,
    (m.employer_contribution_rate + m.employee_contribution_rate) AS combined_contribution_rate,
    -- Business Impact Calculations
    (m.salary * m.employer_contribution_rate) AS annual_employer_contribution,
    (m.salary * m.employee_contribution_rate) AS annual_employee_contribution,
    (m.salary * (m.employer_contribution_rate + m.employee_contribution_rate)) AS total_annual_contribution,
    (m.salary * (0.3 - (m.employer_contribution_rate + m.employee_contribution_rate))) AS potential_additional_contribution, -- max combined contribution rate is 27.5%
    -- Opportunity Metrics
    CASE 
        WHEN m.date_of_birth < DATEADD(YEAR, -55, CURRENT_DATE()) 
            THEN 0
        ELSE (0.3 - (m.employer_contribution_rate + m.employee_contribution_rate)) 
    END AS contribution_rate_gap,
    GREATEST(0, 1000000 - m.insurance_coverage) AS insurance_coverage_gap, -- set maximum insurance coverage to $1M
    -- Performance Ratios
    (NULLIF(m.insurance_coverage,0) / NULLIF(m.salary,0)) AS insurance_coverage_by_salary,
    (NULLIF(m.super_balance,0) / NULLIF(m.salary,0)) AS super_balance_by_salary,
    ((m.salary * (m.employer_contribution_rate + m.employee_contribution_rate)) / NULLIF(m.salary * 0.3,0)) AS contribution_efficiency_ratio,
FROM SUPERANNUATION.SILVER.SUPERANNUATION_MEMBERS m
LEFT JOIN most_recent_employment e ON m.member_id = e.member_id
LEFT JOIN SUPERANNUATION.SILVER.MEMBER_EMPLOYERS me ON e.member_id = me.member_id AND e.employer_id = me.employer_id