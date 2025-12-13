/*============================================================================
  Create Semantic Views for Snowflake Intelligence / Cortex Analyst (Split Views)

  This script creates multiple narrowly scoped semantic views (recommended) so
  Snowflake Intelligence / Cortex Analyst can be configured with focused tools.

  Prereqs:
  - Run sql/01_setup_database.sql
  - Run sql/02_generate_sample_data.sql
  - Run sql/20_intelligence_semantic_layer.sql

  Docs:
  - CREATE SEMANTIC VIEW syntax: https://docs.snowflake.com/en/sql-reference/sql/create-semantic-view
============================================================================*/

USE ROLE SF_INTELLIGENCE_DEMO;

USE DATABASE PREDICTIVE_MAINTENANCE;
USE SCHEMA ANALYTICS;

/*----------------------------------------------------------------------------
  1) Fleet status semantic view
----------------------------------------------------------------------------*/

CREATE OR REPLACE SEMANTIC VIEW SV_FLEET_STATUS
  TABLES (
    fleet AS PREDICTIVE_MAINTENANCE.ANALYTICS.V_FLEET_DEVICE_STATUS
      PRIMARY KEY (DEVICE_ID)
      WITH SYNONYMS = ('fleet status', 'device status', 'screen status')
      COMMENT = 'Current fleet health status and device metadata (threshold-based).'
  )
  DIMENSIONS (
    fleet.device_id AS fleet.DEVICE_ID
      WITH SYNONYMS = ('device', 'screen', 'screen id', 'display id')
      COMMENT = 'Unique identifier for an in-office screen.',
    fleet.device_model AS fleet.DEVICE_MODEL WITH SYNONYMS = ('model', 'hardware model'),
    fleet.firmware_version AS fleet.FIRMWARE_VERSION WITH SYNONYMS = ('firmware', 'firmware version', 'software version'),
    fleet.hardware_version AS fleet.HARDWARE_VERSION WITH SYNONYMS = ('hardware version', 'hw version'),
    fleet.warranty_status AS fleet.WARRANTY_STATUS WITH SYNONYMS = ('warranty', 'warranty status'),
    fleet.facility_name AS fleet.FACILITY_NAME WITH SYNONYMS = ('clinic', 'facility', 'location'),
    fleet.facility_city AS fleet.FACILITY_CITY,
    fleet.facility_state AS fleet.FACILITY_STATE WITH SYNONYMS = ('state', 'region'),
    fleet.environment_type AS fleet.ENVIRONMENT_TYPE WITH SYNONYMS = ('placement', 'room type'),
    fleet.overall_status AS fleet.OVERALL_STATUS WITH SYNONYMS = ('health status', 'status'),
    fleet.temp_status AS fleet.TEMP_STATUS,
    fleet.power_status AS fleet.POWER_STATUS
  )
  METRICS (
    fleet.fleet_size AS COUNT(fleet.DEVICE_ID) COMMENT = 'Total number of devices in the fleet.',
    fleet.critical_devices AS SUM(IFF(fleet.OVERALL_STATUS = 'CRITICAL', 1, 0)) COMMENT = 'Count of devices in CRITICAL status.',
    fleet.warning_devices AS SUM(IFF(fleet.OVERALL_STATUS = 'WARNING', 1, 0)) COMMENT = 'Count of devices in WARNING status.',
    fleet.avg_temperature_f AS AVG(fleet.TEMPERATURE_F) COMMENT = 'Average current temperature (F) across fleet.',
    fleet.avg_power_w AS AVG(fleet.POWER_CONSUMPTION_W) COMMENT = 'Average current power consumption (W) across fleet.',
    fleet.total_active_errors AS SUM(fleet.ERROR_COUNT) COMMENT = 'Sum of current error counts across fleet.'
  )
  COMMENT = 'PatientPoint semantic view: fleet health and device status.'
  COPY GRANTS;

/*----------------------------------------------------------------------------
  2) Telemetry trends semantic view (daily rollups)
----------------------------------------------------------------------------*/

CREATE OR REPLACE SEMANTIC VIEW SV_DEVICE_TELEMETRY_DAILY
  TABLES (
    telemetry AS PREDICTIVE_MAINTENANCE.ANALYTICS.V_DEVICE_TELEMETRY_DAILY
      PRIMARY KEY (DEVICE_ID, DAY)
      COMMENT = 'Daily aggregated telemetry for the last 30 days.'
  )
  DIMENSIONS (
    telemetry.device_id AS telemetry.DEVICE_ID WITH SYNONYMS = ('device', 'screen', 'screen id'),
    telemetry.day AS telemetry.DAY WITH SYNONYMS = ('date', 'day')
  )
  METRICS (
    telemetry.avg_temperature_f AS AVG(telemetry.AVG_TEMPERATURE_F) COMMENT = 'Avg temperature (F) per day (already rolled up).',
    telemetry.max_temperature_f AS MAX(telemetry.MAX_TEMPERATURE_F) COMMENT = 'Max temperature (F) per day.',
    telemetry.avg_power_w AS AVG(telemetry.AVG_POWER_W) COMMENT = 'Avg power (W) per day.',
    telemetry.max_power_w AS MAX(telemetry.MAX_POWER_W) COMMENT = 'Max power (W) per day.',
    telemetry.avg_latency_ms AS AVG(telemetry.AVG_LATENCY_MS) COMMENT = 'Avg latency (ms) per day.',
    telemetry.max_latency_ms AS MAX(telemetry.MAX_LATENCY_MS) COMMENT = 'Max latency (ms) per day.',
    telemetry.avg_packet_loss_pct AS AVG(telemetry.AVG_PACKET_LOSS_PCT) COMMENT = 'Avg packet loss (%) per day.',
    telemetry.total_errors AS SUM(telemetry.TOTAL_ERRORS) COMMENT = 'Total errors per day.'
  )
  COMMENT = 'PatientPoint semantic view: telemetry trends (daily rollups).'
  COPY GRANTS;

/*----------------------------------------------------------------------------
  3) Maintenance incidents semantic view
----------------------------------------------------------------------------*/

CREATE OR REPLACE SEMANTIC VIEW SV_MAINTENANCE_INCIDENTS
  TABLES (
    inc AS PREDICTIVE_MAINTENANCE.ANALYTICS.V_MAINTENANCE_INCIDENTS
      PRIMARY KEY (MAINTENANCE_ID)
      COMMENT = 'Maintenance incident history with enriched context.'
  )
  DIMENSIONS (
    inc.maintenance_id AS inc.MAINTENANCE_ID,
    inc.device_id AS inc.DEVICE_ID WITH SYNONYMS = ('device', 'screen', 'screen id'),
    inc.incident_date AS inc.INCIDENT_DATE WITH SYNONYMS = ('incident time', 'failure time'),
    inc.failure_type AS inc.FAILURE_TYPE WITH SYNONYMS = ('issue type', 'failure mode'),
    inc.resolution_type AS inc.RESOLUTION_TYPE WITH SYNONYMS = ('fix type', 'remediation type'),
    inc.remote_fix_successful AS inc.REMOTE_FIX_SUCCESSFUL WITH SYNONYMS = ('resolved remotely', 'remote fix worked')
  )
  METRICS (
    inc.incident_count AS COUNT(inc.MAINTENANCE_ID) COMMENT = 'Total number of maintenance incidents.',
    inc.avg_downtime_hours AS AVG(inc.DOWNTIME_HOURS) COMMENT = 'Average downtime hours for incidents.',
    inc.avg_total_cost_usd AS AVG(inc.TOTAL_COST_USD) COMMENT = 'Average total incident cost (USD).',
    inc.avg_revenue_impact_usd AS AVG(inc.REVENUE_IMPACT_USD) COMMENT = 'Average revenue impact (USD).'
  )
  COMMENT = 'PatientPoint semantic view: maintenance incident history.'
  COPY GRANTS;

/*----------------------------------------------------------------------------
  4) Remote resolution performance semantic view
----------------------------------------------------------------------------*/

CREATE OR REPLACE SEMANTIC VIEW SV_REMOTE_RESOLUTION_RATES
  TABLES (
    rr AS PREDICTIVE_MAINTENANCE.ANALYTICS.V_REMOTE_RESOLUTION_RATES
      PRIMARY KEY (FAILURE_TYPE)
      COMMENT = 'Remote resolution rates by failure type.'
  )
  DIMENSIONS (
    rr.failure_type AS rr.FAILURE_TYPE WITH SYNONYMS = ('issue type', 'failure mode')
  )
  METRICS (
    rr.incidents AS SUM(rr.INCIDENTS) COMMENT = 'Number of incidents for failure type.',
    rr.remote_attempts AS SUM(rr.REMOTE_ATTEMPTS) COMMENT = 'Remote fix attempts.',
    rr.remote_successes AS SUM(rr.REMOTE_SUCCESSES) COMMENT = 'Remote fix successes.',
    rr.remote_success_rate AS AVG(rr.REMOTE_SUCCESS_RATE) COMMENT = 'Remote success rate.',
    rr.avg_total_cost_usd AS AVG(rr.AVG_TOTAL_COST_USD) COMMENT = 'Average total cost (USD).',
    rr.avg_downtime_hours AS AVG(rr.AVG_DOWNTIME_HOURS) COMMENT = 'Average downtime hours.'
  )
  COMMENT = 'PatientPoint semantic view: remote resolution performance.'
  COPY GRANTS;

/*----------------------------------------------------------------------------
  5) Baseline (pre-ML) semantic view
----------------------------------------------------------------------------*/

CREATE OR REPLACE SEMANTIC VIEW SV_BASELINE_PRE_ML
  TABLES (
    b AS PREDICTIVE_MAINTENANCE.ANALYTICS.V_BASELINE_PRE_ML
      PRIMARY KEY (AS_OF)
      COMMENT = 'Pre-ML baseline monitoring metrics (threshold-based).'
  )
  DIMENSIONS (
    b.as_of AS b.AS_OF WITH SYNONYMS = ('as of', 'timestamp')
  )
  METRICS (
    b.fleet_size AS MAX(b.FLEET_SIZE),
    b.devices_critical AS MAX(b.DEVICES_CRITICAL),
    b.devices_warning AS MAX(b.DEVICES_WARNING),
    b.devices_healthy AS MAX(b.DEVICES_HEALTHY),
    b.devices_requiring_review_today AS MAX(b.DEVICES_REQUIRING_REVIEW_TODAY),
    b.charts_to_review_if_manual AS MAX(b.CHARTS_TO_REVIEW_IF_MANUAL)
  )
  COMMENT = 'PatientPoint semantic view: baseline (pre-ML) monitoring workload and counts.'
  COPY GRANTS;

SHOW SEMANTIC VIEWS LIKE 'SV_%';


