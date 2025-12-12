/*============================================================================
  Act 2 (Snowflake Intelligence): Semantic View for Anomaly Watchlist

  This exposes the Act 2 watchlist in business-friendly terms for Cortex Analyst.

  Depends on:
  - sql/30_act2_watchlist.sql (creates OPERATIONS.WATCHLIST_CURRENT + procedure)
  - sql/20_intelligence_semantic_layer.sql (creates ANALYTICS.V_FLEET_DEVICE_STATUS)
============================================================================*/

USE ROLE SF_INTELLIGENCE_DEMO;

USE DATABASE PREDICTIVE_MAINTENANCE;

USE SCHEMA ANALYTICS;

-- Enriched view: join watchlist to fleet status for context (location, model, environment, status).
CREATE OR REPLACE VIEW ANALYTICS.V_ANOMALY_WATCHLIST AS
SELECT
  w.AS_OF_TS,
  w.MODE,
  w.RANK,
  w.DEVICE_ID,

  f.DEVICE_MODEL,
  f.FACILITY_NAME,
  f.FACILITY_CITY,
  f.FACILITY_STATE,
  f.ENVIRONMENT_TYPE,
  f.OPERATIONAL_STATUS,
  f.OVERALL_STATUS,

  w.SCORE_OVERALL,
  w.SCORE_THERMAL,
  w.SCORE_POWER,
  w.SCORE_NETWORK,
  w.SCORE_DISPLAY,
  w.SCORE_STABILITY,
  w.CONFIDENCE_BAND,
  w.WHY_FLAGGED,
  w.TOP_SIGNALS,

  w.LAST_REFRESHED_AT
FROM PREDICTIVE_MAINTENANCE.OPERATIONS.WATCHLIST_CURRENT w
LEFT JOIN PREDICTIVE_MAINTENANCE.ANALYTICS.V_FLEET_DEVICE_STATUS f
  ON w.DEVICE_ID = f.DEVICE_ID;

-- Native semantic view for Cortex Analyst
CREATE OR REPLACE SEMANTIC VIEW SV_ANOMALY_WATCHLIST
  TABLES (
    watchlist AS PREDICTIVE_MAINTENANCE.ANALYTICS.V_ANOMALY_WATCHLIST
      PRIMARY KEY (DEVICE_ID, AS_OF_TS)
      WITH SYNONYMS = ('watchlist', 'anomaly watchlist', 'early warning', 'risk list')
      COMMENT = 'Ranked anomaly watchlist with explainable domain scores (baseline 14d vs scoring 1d).'
  )
  DIMENSIONS (
    watchlist.device_id AS watchlist.DEVICE_ID WITH SYNONYMS = ('device', 'screen', 'screen id'),
    watchlist.device_model AS watchlist.DEVICE_MODEL WITH SYNONYMS = ('model', 'hardware model'),
    watchlist.facility_name AS watchlist.FACILITY_NAME WITH SYNONYMS = ('clinic', 'facility', 'location'),
    watchlist.facility_city AS watchlist.FACILITY_CITY,
    watchlist.facility_state AS watchlist.FACILITY_STATE WITH SYNONYMS = ('state', 'region'),
    watchlist.environment_type AS watchlist.ENVIRONMENT_TYPE,
    watchlist.operational_status AS watchlist.OPERATIONAL_STATUS,
    watchlist.overall_status AS watchlist.OVERALL_STATUS WITH SYNONYMS = ('health status', 'status'),
    watchlist.mode AS watchlist.MODE,
    watchlist.confidence_band AS watchlist.CONFIDENCE_BAND
  )
  METRICS (
    watchlist.watchlist_rank AS MIN(watchlist.RANK) COMMENT = 'Rank in the current watchlist (1 is highest priority).',
    watchlist.anomaly_score_overall AS MAX(watchlist.SCORE_OVERALL) COMMENT = 'Overall anomaly score (0–1).',
    watchlist.anomaly_score_thermal AS MAX(watchlist.SCORE_THERMAL) COMMENT = 'Thermal anomaly score (0–1).',
    watchlist.anomaly_score_power AS MAX(watchlist.SCORE_POWER) COMMENT = 'Power anomaly score (0–1).',
    watchlist.anomaly_score_network AS MAX(watchlist.SCORE_NETWORK) COMMENT = 'Network anomaly score (0–1).',
    watchlist.anomaly_score_display AS MAX(watchlist.SCORE_DISPLAY) COMMENT = 'Display anomaly score (0–1).',
    watchlist.anomaly_score_stability AS MAX(watchlist.SCORE_STABILITY) COMMENT = 'Stability anomaly score (0–1).'
  )
  COMMENT = 'Act 2 semantic view: anomaly watchlist for early warning (baseline 14d vs scoring 1d).'
  COPY GRANTS;


