/*

************************************************************
DDL Script: Define Silver Layer Tables
************************************************************

The purpose of this script.
    - This SQL script defines the tables in the silver layer of the data warehouse.
    - Running this script will re-define the tables' structure.

************************************************************
                        WARNING
************************************************************

    - This script will OVERWRITE the existing silver layer tables if they exist.
    - Use with caution, and ensure that all relevant data is backed up before running the script.

 */

USE DATABASE SUPERANNUATION;
USE SCHEMA SILVER;

CREATE OR REPLACE TABLE SUPERANNUATION.SILVER.SUPERANNUATION_MEMBERS (
    member_id VARCHAR(50) PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(10) NOT NULL,
    employment_status VARCHAR(50) NOT NULL,
    salary INT NOT NULL,
    employer_contribution_rate decimal(5,4) NOT NULL,
    employee_contribution_rate decimal(5,4) NOT NULL,
    super_balance INT NOT NULL,
    investment_option VARCHAR(50) NOT NULL,
    insurance_coverage INT NOT NULL,
    age INT,
    insurance_coverage_by_salary DECIMAL(8,4),
    super_balance_by_salary DECIMAL(8,4),
    combined_contribution_rate DECIMAL(8,4)
);

CREATE OR REPLACE TABLE SUPERANNUATION.SILVER.MEMBER_EMPLOYERS (
    relationship_id INT PRIMARY KEY,
    employer_id INT NOT NULL,
    member_id VARCHAR(50) NOT NULL,
    company_name VARCHAR(50) NOT NULL,
    industry VARCHAR(50) NOT NULL,
    head_office_state VARCHAR(50) NOT NULL,
    total_employees INT NOT NULL,
    avg_salary INT NOT NULL,
    default_super_fund_option VARCHAR(50) NOT NULL,
    default_fund_risk_profile VARCHAR(50) NOT NULL
);

CREATE OR REPLACE TABLE SUPERANNUATION.SILVER.EMPLOYMENT_HISTORY (
    employment_id INT PRIMARY KEY,
    member_id VARCHAR(50) NOT NULL,
    employer_id INT NOT NULL,
    position_title VARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE,
    employment_type VARCHAR(50) NOT NULL,
    final_salary INT NOT NULL,
    employment_days INT
);  
