/*

************************************************************
Create Secure Stage to Integrate Data from AWS S3 Bucket
************************************************************

The purpose of this script.
    - This SQL script creates a secure stage to integrate data from an S3 bucket in AWS
    - This allows data to be loaded from S3 into the bronze layer of the data warehouse in Snowflake
    - The stage is created using a storage integration with AWS credentials.
    - An AWS IAM role is created with access to the S3 bucket.
    - A Snowflake role is created and granted access to the storage integration and the stage.
    - The stage is created in the bronze layer of the data warehouse.

Data Source:
    - Three csv files in an S3 bucket in AWS.
    - The files are:
        - superannuation_members.csv
        - member_employers.csv
        - employment_history.csv
    - The files are stored in the following S3 bucket:
        - s3://superannuation-bucket2/

 */


-- Use the ACCOUNTADMIN role to begin with
USE ROLE ACCOUNTADMIN;

-- Check existing integrations first
SHOW INTEGRATIONS;

-- Drop existing integration if it exists with issues
-- DROP INTEGRATION IF EXISTS S3_INTEGRATION;

-- Create storage integration with AWS credentials
CREATE OR REPLACE STORAGE INTEGRATION S3_INTEGRATION
  TYPE = EXTERNAL_STAGE
  ENABLED = TRUE
  STORAGE_PROVIDER = S3
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::493249671090:role/superannuation_role'
  STORAGE_ALLOWED_LOCATIONS = ('s3://superannuation-bucket2/');

-- Verify integration was created successfully
SHOW INTEGRATIONS LIKE 'S3_INTEGRATION';
DESCRIBE INTEGRATION S3_INTEGRATION;

-- Create the Snowflake role
CREATE OR REPLACE ROLE superannuation_snowflake_role;
GRANT ROLE superannuation_snowflake_role TO USER STEWROBO;

-- Grant usage on the integration to roles that need it
GRANT USAGE ON INTEGRATION S3_INTEGRATION TO ROLE ACCOUNTADMIN;
GRANT USAGE ON INTEGRATION S3_INTEGRATION TO ROLE superannuation_snowflake_role;

-- Grant database and schema access
GRANT USAGE ON DATABASE SUPERANNUATION TO ROLE superannuation_snowflake_role;
GRANT USAGE ON SCHEMA SUPERANNUATION.BRONZE TO ROLE superannuation_snowflake_role;

GRANT ALL PRIVILEGES ON SCHEMA SUPERANNUATION.BRONZE TO ROLE superannuation_snowflake_role;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA SUPERANNUATION.BRONZE TO ROLE superannuation_snowflake_role;

-- Now switch to database context for stage creation
USE DATABASE SUPERANNUATION;
USE SCHEMA BRONZE;

-- Create stage 
CREATE OR REPLACE STAGE BRONZE_STAGE
  STORAGE_INTEGRATION = S3_INTEGRATION
  URL = 's3://superannuation-bucket2/'
  FILE_FORMAT = (
    TYPE = CSV
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"' -- Handles fields with commas
  );

-- Verify stage creation
DESC STAGE BRONZE_STAGE;
SHOW STAGES LIKE 'BRONZE_STAGE';

GRANT USAGE ON STAGE BRONZE_STAGE TO ROLE superannuation_snowflake_role;

-- Not necessary for this project, but good practice to grant future table privileges for new tables created in the schema
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA SUPERANNUATION.BRONZE TO ROLE superannuation_snowflake_role;

-- Verify permissions
SHOW GRANTS TO ROLE superannuation_snowflake_role;

-- Describe the storage integration to get Snowflake credentials to use in AWS IAM trust policy
DESCRIBE INTEGRATION S3_INTEGRATION;