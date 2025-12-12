/*============================================================================
  Cleanup script (objects created by earlier runs as ACCOUNTADMIN)

  Why:
  - If the demo was originally provisioned using ACCOUNTADMIN, objects will be
    owned by ACCOUNTADMIN. Dropping them is simplest while using that role.
  - After cleanup, you can re-run provisioning scripts using SF_INTELLIGENCE_DEMO.

  IMPORTANT:
  - This script is intentionally destructive.
  - It drops the entire PREDICTIVE_MAINTENANCE database (which contains all demo
    objects created by this repo).

  How to use:
  1) Run as ACCOUNTADMIN (or another role that OWNS these objects):
     USE ROLE ACCOUNTADMIN;
  2) Execute this script.
============================================================================*/

USE ROLE ACCOUNTADMIN;

-- Drop Snowflake Intelligence objects first (optional; database drop also removes them)
DROP AGENT IF EXISTS PREDICTIVE_MAINTENANCE.OPERATIONS.MAINTENANCE_OPS_AGENT;
DROP CORTEX SEARCH SERVICE IF EXISTS PREDICTIVE_MAINTENANCE.OPERATIONS.MAINTENANCE_KB_SEARCH;

-- Drop the entire demo database (drops schemas, tables, views, semantic views, procedures, etc.)
DROP DATABASE IF EXISTS PREDICTIVE_MAINTENANCE;


