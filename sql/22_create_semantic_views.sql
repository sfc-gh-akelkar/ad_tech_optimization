/*============================================================================
  Create Semantic View(s) for Snowflake Intelligence / Cortex Analyst

  This script creates a single semantic view that unifies the curated ANALYTICS
  views into a governed semantic object, per Snowflake semantic view DDL.

  Why one semantic view?
  - Keeps the Analyst surface area simple (one object to point Intelligence at)
  - Enables cross-table questions via relationships (device -> telemetry -> incidents)

  Prereqs:
  - Run sql/01_setup_database.sql
  - Run sql/02_generate_sample_data.sql
  - Run sql/20_intelligence_semantic_layer.sql

  Docs:
  - CREATE SEMANTIC VIEW syntax: https://docs.snowflake.com/en/sql-reference/sql/create-semantic-view
============================================================================*/

USE DATABASE PREDICTIVE_MAINTENANCE;
USE SCHEMA ANALYTICS;

CREATE OR REPLACE SEMANTIC VIEW SV_PATIENTPOINT_MAINTENANCE_OPS

  TABLES (
    fleet AS PREDICTIVE_MAINTENANCE.ANALYTICS.V_FLEET_DEVICE_STATUS
      PRIMARY KEY (DEVICE_ID)
      WITH SYNONYMS = ('fleet status', 'device status', 'screen status')
      COMMENT = 'Current fleet health status and device metadata (threshold-based).',

    telemetry_daily AS PREDICTIVE_MAINTENANCE.ANALYTICS.V_DEVICE_TELEMETRY_DAILY
      PRIMARY KEY (DEVICE_ID, DAY)
      COMMENT = 'Daily aggregated telemetry for last 30 days.',

    incidents AS PREDICTIVE_MAINTENANCE.ANALYTICS.V_MAINTENANCE_INCIDENTS
      PRIMARY KEY (MAINTENANCE_ID)
      COMMENT = 'Maintenance incident history with enriched context.',

    baseline AS PREDICTIVE_MAINTENANCE.ANALYTICS.V_BASELINE_PRE_ML
      PRIMARY KEY (AS_OF)
      COMMENT = 'Pre-ML baseline monitoring metrics (threshold-based).'
  )

  RELATIONSHIPS (
    telemetry_daily (DEVICE_ID) REFERENCES fleet,
    incidents (DEVICE_ID) REFERENCES fleet
  )

  DIMENSIONS (
    fleet.device_id AS DEVICE_ID
      WITH SYNONYMS = ('device', 'screen', 'screen id', 'display id')
      COMMENT = 'Unique identifier for an in-office screen.',

    fleet.device_model AS DEVICE_MODEL
      WITH SYNONYMS = ('model', 'hardware model'),

    fleet.facility_name AS FACILITY_NAME
      WITH SYNONYMS = ('clinic', 'facility', 'location'),

    fleet.facility_city AS FACILITY_CITY,
    fleet.facility_state AS FACILITY_STATE
      WITH SYNONYMS = ('state', 'region'),

    fleet.environment_type AS ENVIRONMENT_TYPE
      WITH SYNONYMS = ('placement', 'room type'),

    fleet.overall_status AS OVERALL_STATUS
      WITH SYNONYMS = ('health status', 'status'),

    fleet.temp_status AS TEMP_STATUS,
    fleet.power_status AS POWER_STATUS,

    telemetry_daily.day AS DAY
      COMMENT = 'Calendar day for telemetry rollups.',

    incidents.failure_type AS FAILURE_TYPE
      WITH SYNONYMS = ('issue type', 'failure mode'),

    incidents.resolution_type AS RESOLUTION_TYPE
      WITH SYNONYMS = ('fix type', 'remediation type'),

    incidents.remote_fix_successful AS REMOTE_FIX_SUCCESSFUL
      WITH SYNONYMS = ('resolved remotely', 'remote fix worked')
  )

  METRICS (
    fleet.fleet_size AS COUNT(fleet.device_id)
      COMMENT = 'Total number of devices in the fleet.',

    fleet.critical_devices AS COUNT_IF(fleet.overall_status = 'CRITICAL')
      COMMENT = 'Count of devices in CRITICAL status.',

    fleet.warning_devices AS COUNT_IF(fleet.overall_status = 'WARNING')
      COMMENT = 'Count of devices in WARNING status.',

    fleet.avg_temperature_f AS AVG(fleet.temperature_f)
      COMMENT = 'Average current temperature (F) across fleet.',

    fleet.avg_power_w AS AVG(fleet.power_w)
      COMMENT = 'Average current power consumption (W) across fleet.',

    fleet.total_active_errors AS SUM(fleet.error_count)
      COMMENT = 'Sum of current error counts across fleet.',

    incidents.incident_count AS COUNT(incidents.maintenance_id)
      COMMENT = 'Total number of maintenance incidents.',

    incidents.avg_downtime_hours AS AVG(incidents.downtime_hours)
      COMMENT = 'Average downtime hours for incidents.',

    incidents.avg_total_cost_usd AS AVG(incidents.total_cost_usd)
      COMMENT = 'Average total incident cost (USD).',

    incidents.remote_success_rate AS
      SUM(IFF(incidents.remote_fix_successful, 1, 0)) /
      NULLIF(SUM(IFF(incidents.remote_fix_successful IS NOT NULL, 1, 0)), 0)
      COMMENT = 'Remote resolution success rate where outcome is known.',

    baseline.devices_requiring_review_today AS MAX(baseline.devices_requiring_review_today)
      COMMENT = 'Baseline threshold-based devices requiring review (snapshot).',

    baseline.manual_charts_to_review_proxy AS MAX(baseline.charts_to_review_if_manual)
      COMMENT = 'Baseline proxy for manual monitoring workload (#devices x ~10 charts).'
  )

  COMMENT = 'PatientPoint predictive maintenance semantic view for Snowflake Intelligence (fleet status, telemetry trends, incident history, and baseline metrics).'
  COPY GRANTS;

-- Sanity check
DESC SEMANTIC VIEW SV_PATIENTPOINT_MAINTENANCE_OPS;


