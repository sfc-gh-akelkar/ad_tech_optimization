/*============================================================================
  Snowflake Intelligence Enablement (Cortex Analyst)

  Purpose:
  - Create curated, governed ANALYTICS views that are stable for natural language
    querying (Cortex Analyst / Snowflake Intelligence).
  - Keep raw tables in RAW_DATA; expose business-friendly views in ANALYTICS.

  Run after:
  - sql/01_setup_database.sql
  - sql/02_generate_sample_data.sql
============================================================================*/

USE DATABASE PREDICTIVE_MAINTENANCE;

/*----------------------------------------------------------------------------
  1) Fleet status view (business-friendly)
----------------------------------------------------------------------------*/

CREATE OR REPLACE VIEW ANALYTICS.V_FLEET_DEVICE_STATUS AS
SELECT
  DEVICE_ID,
  DEVICE_MODEL,
  FACILITY_NAME,
  FACILITY_CITY,
  FACILITY_STATE,
  ENVIRONMENT_TYPE,
  OPERATIONAL_STATUS,
  TEMPERATURE_F,
  POWER_CONSUMPTION_W,
  ERROR_COUNT,
  UPTIME_HOURS,
  LAST_REPORT_TIME,
  DEVICE_AGE_DAYS,
  DAYS_SINCE_MAINTENANCE,
  TEMP_STATUS,
  POWER_STATUS,
  CASE
    WHEN TEMP_STATUS = 'CRITICAL' OR POWER_STATUS = 'CRITICAL' THEN 'CRITICAL'
    WHEN TEMP_STATUS = 'WARNING' OR POWER_STATUS = 'WARNING' THEN 'WARNING'
    ELSE 'HEALTHY'
  END AS OVERALL_STATUS
FROM RAW_DATA.V_DEVICE_HEALTH_SUMMARY;

/*----------------------------------------------------------------------------
  2) Daily telemetry rollup (reduces query volume and supports trends)
----------------------------------------------------------------------------*/

CREATE OR REPLACE VIEW ANALYTICS.V_DEVICE_TELEMETRY_DAILY AS
SELECT
  DEVICE_ID,
  DATE_TRUNC('day', TIMESTAMP) AS DAY,
  AVG(TEMPERATURE_F) AS AVG_TEMPERATURE_F,
  MAX(TEMPERATURE_F) AS MAX_TEMPERATURE_F,
  AVG(POWER_CONSUMPTION_W) AS AVG_POWER_W,
  MAX(POWER_CONSUMPTION_W) AS MAX_POWER_W,
  AVG(NETWORK_LATENCY_MS) AS AVG_LATENCY_MS,
  MAX(NETWORK_LATENCY_MS) AS MAX_LATENCY_MS,
  AVG(PACKET_LOSS_PCT) AS AVG_PACKET_LOSS_PCT,
  MAX(PACKET_LOSS_PCT) AS MAX_PACKET_LOSS_PCT,
  SUM(ERROR_COUNT) AS TOTAL_ERRORS,
  AVG(CPU_USAGE_PCT) AS AVG_CPU_PCT,
  AVG(MEMORY_USAGE_PCT) AS AVG_MEM_PCT,
  AVG(BRIGHTNESS_LEVEL) AS AVG_BRIGHTNESS
FROM RAW_DATA.SCREEN_TELEMETRY
WHERE TIMESTAMP >= DATEADD('day', -30, CURRENT_TIMESTAMP())
GROUP BY DEVICE_ID, DAY;

/*----------------------------------------------------------------------------
  3) Incident view (business-friendly maintenance history)
----------------------------------------------------------------------------*/

CREATE OR REPLACE VIEW ANALYTICS.V_MAINTENANCE_INCIDENTS AS
SELECT
  MAINTENANCE_ID,
  DEVICE_ID,
  INCIDENT_DATE,
  INCIDENT_TYPE,
  FAILURE_TYPE,
  FAILURE_SYMPTOMS,
  RESOLUTION_TYPE,
  RESOLUTION_DATE,
  RESOLUTION_TIME_HOURS,
  REMOTE_FIX_ATTEMPTED,
  REMOTE_FIX_SUCCESSFUL,
  TOTAL_COST_USD,
  DOWNTIME_HOURS,
  REVENUE_IMPACT_USD,
  ROOT_CAUSE,
  PREVENTABLE,
  -- enriched context (Phase 1)
  PRE_FAILURE_TEMP_TREND,
  PRE_FAILURE_POWER_TREND,
  PRE_FAILURE_NETWORK_TREND,
  DAYS_OF_WARNING_SIGNS,
  FIRMWARE_VERSION_AT_INCIDENT,
  ENVIRONMENT_TYPE_AT_INCIDENT,
  DEVICE_MODEL_AT_INCIDENT,
  DEVICE_AGE_DAYS_AT_INCIDENT,
  OPERATOR_NOTES,
  SIMILAR_RECENT_FAILURES
FROM RAW_DATA.MAINTENANCE_HISTORY;

/*----------------------------------------------------------------------------
  4) Remote resolution performance by failure type (for exec-friendly questions)
----------------------------------------------------------------------------*/

CREATE OR REPLACE VIEW ANALYTICS.V_REMOTE_RESOLUTION_RATES AS
SELECT
  FAILURE_TYPE,
  COUNT(*) AS INCIDENTS,
  SUM(IFF(REMOTE_FIX_ATTEMPTED, 1, 0)) AS REMOTE_ATTEMPTS,
  SUM(IFF(REMOTE_FIX_SUCCESSFUL, 1, 0)) AS REMOTE_SUCCESSES,
  IFF(REMOTE_ATTEMPTS = 0, NULL, REMOTE_SUCCESSES / REMOTE_ATTEMPTS) AS REMOTE_SUCCESS_RATE,
  AVG(TOTAL_COST_USD) AS AVG_TOTAL_COST_USD,
  AVG(DOWNTIME_HOURS) AS AVG_DOWNTIME_HOURS
FROM RAW_DATA.MAINTENANCE_HISTORY
GROUP BY FAILURE_TYPE;

/*----------------------------------------------------------------------------
  5) Baseline metrics (pre-ML) – already created in sql/01_setup_database.sql
     Surface via stable ANALYTICS views for Analyst.
----------------------------------------------------------------------------*/

CREATE OR REPLACE VIEW ANALYTICS.V_BASELINE_PRE_ML AS
SELECT * FROM ANALYTICS.V_BASELINE_METRICS;

/*----------------------------------------------------------------------------
  Quick sanity checks
----------------------------------------------------------------------------*/

SELECT 'Intelligence semantic layer created ✅' AS STATUS;


