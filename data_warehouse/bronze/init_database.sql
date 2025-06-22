/* 

************************************************************
Create Data Warehouse and Schemas of Data Warehouse Layers
************************************************************

The purpose of this script.
    - This SQL script will create a database called SUPERANNUATION.
    - The SUPERANNUATION will contain three layers, following a medallion methodology: 
        "bronze", "silver", and "gold".
    - The script will first check to see if the SUPERANNUATION database exists. 
    If it exists, it will be removed and recreated. It will otherwise be created for the first time.
    - The schemas for the three database layers will then be created.

************************************************************
                        WARNING
************************************************************

    - This script will PERMANENTLY DELETE the SUPERANNUATION database if it exists.
    - Use with caution, and ensure that all relevant data is backed up before running the script.

*/

CREATE DATABASE IF NOT EXISTS "SUPERANNUATION";

USE DATABASE "SUPERANNUATION";

CREATE SCHEMA IF NOT EXISTS "BRONZE";
CREATE SCHEMA IF NOT EXISTS "SILVER";
CREATE SCHEMA IF NOT EXISTS "GOLD";