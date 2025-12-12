/*============================================================================
  Snowflake Intelligence Enablement (Cortex Search)

  Purpose:
  - Create a maintenance knowledge base table (text + attributes)
  - Create a Cortex Search service over that KB

  Run after:
  - sql/01_setup_database.sql
  - sql/02_generate_sample_data.sql

  Notes:
  - Choose an existing warehouse for WAREHOUSE= (this script uses APP_WH).
  - TARGET_LAG controls refresh cadence for the search index.
  - The KB is intentionally derived from MAINTENANCE_HISTORY so we avoid
    inventing content; it stays grounded in the data.
============================================================================*/

USE ROLE SF_INTELLIGENCE_DEMO;

USE DATABASE PREDICTIVE_MAINTENANCE;
USE SCHEMA OPERATIONS;

/*----------------------------------------------------------------------------
  1) Knowledge base table (derived from maintenance incidents)
----------------------------------------------------------------------------*/

CREATE OR REPLACE TABLE OPERATIONS.MAINTENANCE_KB (
  KB_ID STRING,
  DEVICE_ID STRING,
  FAILURE_TYPE STRING,
  RESOLUTION_TYPE STRING,
  DEVICE_MODEL STRING,
  ENVIRONMENT_TYPE STRING,
  INCIDENT_DATE TIMESTAMP_NTZ,
  KB_TITLE STRING,
  KB_TEXT STRING,
  CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

INSERT INTO OPERATIONS.MAINTENANCE_KB (
  KB_ID,
  DEVICE_ID,
  FAILURE_TYPE,
  RESOLUTION_TYPE,
  DEVICE_MODEL,
  ENVIRONMENT_TYPE,
  INCIDENT_DATE,
  KB_TITLE,
  KB_TEXT
)
SELECT
  MAINTENANCE_ID AS KB_ID,
  DEVICE_ID,
  FAILURE_TYPE,
  RESOLUTION_TYPE,
  COALESCE(DEVICE_MODEL_AT_INCIDENT, '<unknown>') AS DEVICE_MODEL,
  COALESCE(ENVIRONMENT_TYPE_AT_INCIDENT, '<unknown>') AS ENVIRONMENT_TYPE,
  INCIDENT_DATE,
  CONCAT(FAILURE_TYPE, ' - ', RESOLUTION_TYPE, ' (', COALESCE(DEVICE_MODEL_AT_INCIDENT, 'Unknown Model'), ')') AS KB_TITLE,
  CONCAT(
    'Symptoms: ', COALESCE(FAILURE_SYMPTOMS, 'N/A'), '\n',
    'Actions: ', COALESCE(ACTIONS_TAKEN, 'N/A'), '\n',
    'Root cause: ', COALESCE(ROOT_CAUSE, 'N/A'), '\n',
    'Operator notes: ', COALESCE(OPERATOR_NOTES, 'N/A'), '\n',
    'Remote fix attempted: ', IFF(REMOTE_FIX_ATTEMPTED, 'Yes', 'No'), '\n',
    'Remote fix successful: ', IFF(REMOTE_FIX_SUCCESSFUL, 'Yes', 'No'), '\n',
    'Downtime hours: ', COALESCE(TO_VARCHAR(DOWNTIME_HOURS), 'N/A'), '\n',
    'Cost USD: ', COALESCE(TO_VARCHAR(TOTAL_COST_USD), 'N/A')
  ) AS KB_TEXT
FROM RAW_DATA.MAINTENANCE_HISTORY;

/*----------------------------------------------------------------------------
  2) Cortex Search service

  CREATE CORTEX SEARCH SERVICE syntax (per Snowflake docs):
  CREATE OR REPLACE CORTEX SEARCH SERVICE <name>
    ON <search_column>
    ATTRIBUTES <col_name> [ , ... ]
    WAREHOUSE = <warehouse_name>
    TARGET_LAG = '<num> { seconds | minutes | hours | days }'
    AS <query>;
----------------------------------------------------------------------------*/

CREATE OR REPLACE CORTEX SEARCH SERVICE OPERATIONS.MAINTENANCE_KB_SEARCH
  ON KB_TEXT
  ATTRIBUTES FAILURE_TYPE, RESOLUTION_TYPE, DEVICE_MODEL, ENVIRONMENT_TYPE
  WAREHOUSE = APP_WH
  TARGET_LAG = '1 hour'
  AS (
    SELECT
      KB_ID,
      KB_TITLE,
      KB_TEXT,
      FAILURE_TYPE,
      RESOLUTION_TYPE,
      DEVICE_MODEL,
      ENVIRONMENT_TYPE,
      INCIDENT_DATE
    FROM OPERATIONS.MAINTENANCE_KB
  );

/*----------------------------------------------------------------------------
  3) Preview query example (use modern SEARCH_PREVIEW JSON syntax)
----------------------------------------------------------------------------*/

-- Example: find similar incidents for power supply degradation
SELECT PARSE_JSON(
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'PREDICTIVE_MAINTENANCE.OPERATIONS.MAINTENANCE_KB_SEARCH',
    '{
      "query": "power consumption spiking and temperature climbing",
      "columns": ["KB_ID", "KB_TITLE", "FAILURE_TYPE", "RESOLUTION_TYPE", "DEVICE_MODEL", "ENVIRONMENT_TYPE", "INCIDENT_DATE"],
      "limit": 5,
      "filter": {"@eq": {"FAILURE_TYPE": "Power Supply"}}
    }'
  )
)['results'] AS results;

SELECT 'Cortex Search KB created ✅' AS STATUS;


