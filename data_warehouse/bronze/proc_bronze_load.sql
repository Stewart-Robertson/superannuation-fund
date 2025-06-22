/*

************************************************************
Procedure: Load Bronze Layer Tables
************************************************************

The purpose of this script.
    - This SQL/Python script defines the procedure to load the bronze layer tables.
    - Running this script will re-define the procedure.
    - The procedure will truncate the bronze layer tables before loading the data into the bronze tables
    - The procedure is written in Python and uses the Snowpark Python API

Data Source:
    - The data is loaded from an S3 bucket in AWS
    - This uses a storage integration to access the S3 bucket
    - See create_secure_stage.sql for stage and storage integration setup

************************************************************
                        WARNING
************************************************************

    - This script will TRUNCATE the bronze layer tables and load the data from the bronze stage.
    - Use with caution, and ensure that all relevant data is backed up before running the script.

 */



USE ROLE ACCOUNTADMIN;

CREATE OR REPLACE PROCEDURE SUPERANNUATION.BRONZE.load_data()
RETURNS STRING -- Confirmation/error message
-- Set language to Python
LANGUAGE PYTHON
RUNTIME_VERSION = '3.12'
-- Snowpark Python API required to access Snowflake functionality
PACKAGES = ('snowflake-snowpark-python')
-- Handler function name
HANDLER = 'run'
EXECUTE AS OWNER
AS
$$
def run(session):
    try:
        # Truncate superannuation_members table
        session.sql("TRUNCATE TABLE SUPERANNUATION.BRONZE.superannuation_members").collect()
        # Copy data from storage integration with S3 into superannuation_members table
        session.sql("""
            COPY INTO SUPERANNUATION.BRONZE.superannuation_members
            FROM @SUPERANNUATION.BRONZE.BRONZE_STAGE/superannuation_members.csv
            ON_ERROR = 'ABORT_STATEMENT'
        """).collect()

        # Truncate member_employers table
        session.sql("TRUNCATE TABLE SUPERANNUATION.BRONZE.member_employers").collect()
        # Copy data from storage integration with S3 into member_employers table
        session.sql("""
            COPY INTO SUPERANNUATION.BRONZE.member_employers
            FROM @SUPERANNUATION.BRONZE.BRONZE_STAGE/member_employers.csv
            ON_ERROR = 'ABORT_STATEMENT'
            """).collect()

        # Truncate employment_history table
        session.sql("TRUNCATE TABLE SUPERANNUATION.BRONZE.employment_history").collect()
        # Copy data from storage integration with S3 into employment_history table
        session.sql("""
            COPY INTO SUPERANNUATION.BRONZE.employment_history
            FROM @SUPERANNUATION.BRONZE.BRONZE_STAGE/employment_history.csv
            ON_ERROR = 'ABORT_STATEMENT'
        """).collect()

        return "Successfully loaded data"
    except Exception as e:
        return f"Error occurred: {str(e)}"
$$;

-- Execute the procedure
CALL SUPERANNUATION.BRONZE.load_data();