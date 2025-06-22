/* 

************************************************************
Test Script for Silver Layer Table Quality
************************************************************

The purpose of this script.
    - This SQL script will perform quality tests to validate the silver layer of the data warehouse.
    - The quality checks that failed in the bronze layer will be repeated here to ensure they have been resolved.

*/

/*

============================================================
Test the quality and values of the superannuation_members table
============================================================

*/
-- Check that the total employees per company is greater than the number of members in that company
-- Expected result: No rows returned
SELECT *
FROM SUPERANNUATION.SILVER.MEMBER_EMPLOYERS me
WHERE total_employees < (
    SELECT COUNT(DISTINCT member_id) 
    FROM SUPERANNUATION.SILVER.EMPLOYMENT_HISTORY eh
    WHERE eh.employer_id = me.employer_id
);

-- Check for records where start_date >= end_date
-- Expected result: No rows returned
SELECT *
FROM SUPERANNUATION.SILVER.EMPLOYMENT_HISTORY
WHERE start_date >= end_date
   OR start_date > CURRENT_DATE;

-- As shown in the above test, as there are no records where start_date >= end_date, this test should return no rows:
-- Expected result: No rows returned
SELECT *
FROM SUPERANNUATION.SILVER.EMPLOYMENT_HISTORY eh
WHERE (eh.start_date >= eh.end_date)
  AND eh.start_date = (
      SELECT GREATEST(
          MAX(COALESCE(eh2.start_date, '1900-01-01')),
          MAX(COALESCE(eh2.end_date, '1900-01-01'))
      )
      FROM SUPERANNUATION.SILVER.EMPLOYMENT_HISTORY eh2
      WHERE eh2.member_id = eh.member_id
  )
  AND EXISTS (
      SELECT 1
      FROM SUPERANNUATION.SILVER.SUPERANNUATION_MEMBERS sm
      WHERE sm.member_id = eh.member_id
        AND sm.employment_status IN ('full_time_employed', 'casual', 'part_time')
  );

-- Check for records where end_date is NULL but start_date is not
-- Expected result: No rows returned
SELECT *
FROM SUPERANNUATION.SILVER.EMPLOYMENT_HISTORY
WHERE end_date IS NULL;
