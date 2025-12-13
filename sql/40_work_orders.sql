/*============================================================================
  Ops Center: Work Orders + Scheduling (Simulation)

  Purpose:
  - Turn watchlist + predictions into operational actions:
    prioritized work orders with recommended next steps and dispatch guidance.
============================================================================*/

USE ROLE SF_INTELLIGENCE_DEMO;

USE DATABASE PREDICTIVE_MAINTENANCE;
USE SCHEMA OPERATIONS;

CREATE OR REPLACE TABLE OPERATIONS.WORK_ORDERS (
  WORK_ORDER_ID STRING,
  CREATED_AT TIMESTAMP_NTZ,
  UPDATED_AT TIMESTAMP_NTZ,

  STATUS STRING, -- OPEN | IN_PROGRESS | COMPLETED | CANCELLED
  PRIORITY STRING, -- P1 | P2 | P3
  DUE_BY TIMESTAMP_NTZ,

  DEVICE_ID STRING,
  ISSUE_TYPE STRING,
  RECOMMENDED_ACTION STRING,
  RECOMMENDED_CHANNEL STRING, -- REMOTE | FIELD

  SOURCE STRING, -- WATCHLIST | PREDICTION | MANUAL
  LINKED_RUN_ID STRING,

  NOTES STRING,
  CONTEXT VARIANT
);

CREATE OR REPLACE VIEW ANALYTICS.V_WORK_ORDERS_CURRENT AS
SELECT
  WORK_ORDER_ID,
  CREATED_AT,
  UPDATED_AT,
  STATUS,
  PRIORITY,
  DUE_BY,
  DEVICE_ID,
  ISSUE_TYPE,
  RECOMMENDED_ACTION,
  RECOMMENDED_CHANNEL,
  SOURCE,
  LINKED_RUN_ID,
  NOTES,
  CONTEXT
FROM PREDICTIVE_MAINTENANCE.OPERATIONS.WORK_ORDERS
WHERE STATUS IN ('OPEN','IN_PROGRESS');

CREATE OR REPLACE PROCEDURE OPERATIONS.GENERATE_WORK_ORDERS(
  MODE STRING DEFAULT 'LIVE_SCORING',
  AS_OF_TS TIMESTAMP_NTZ DEFAULT NULL,
  TOP_N INT DEFAULT 25
)
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
  run_id STRING DEFAULT UUID_STRING();
BEGIN
  LET demo_as_of_ts TIMESTAMP_NTZ := COALESCE(AS_OF_TS, (SELECT DEMO_AS_OF_TS FROM OPERATIONS.V_DEMO_TIME));

  -- Create work orders from latest predictions (preferred) and watchlist (fallback).
  CREATE OR REPLACE TEMP TABLE _candidates AS
  SELECT
    p.DEVICE_ID,
    p.PREDICTED_FAILURE_TYPE AS ISSUE_TYPE,
    p.PREDICTION_PROBABILITY AS SCORE,
    p.CONFIDENCE_BAND,
    'PREDICTION' AS SOURCE,
    p.SIGNALS AS CONTEXT
  FROM PREDICTIVE_MAINTENANCE.ANALYTICS.V_FAILURE_PREDICTIONS_CURRENT p
  WHERE (:MODE = 'SCENARIO_LOCK' AND p.DEVICE_ID IN ('4532','4512','4523','7821','4545','4556'))
     OR (:MODE <> 'SCENARIO_LOCK')

  UNION ALL
  SELECT
    w.DEVICE_ID,
    -- Map dominant anomaly domain to an operational issue type (so work orders are actionable
    -- even when predictions are not generated for that device).
    CASE
      WHEN w.SCORE_DISPLAY = GREATEST(w.SCORE_THERMAL, w.SCORE_POWER, w.SCORE_NETWORK, w.SCORE_STABILITY, w.SCORE_DISPLAY) THEN 'Display Panel'
      WHEN w.SCORE_NETWORK = GREATEST(w.SCORE_THERMAL, w.SCORE_POWER, w.SCORE_NETWORK, w.SCORE_STABILITY, w.SCORE_DISPLAY) THEN 'Network Connectivity'
      WHEN w.SCORE_POWER = GREATEST(w.SCORE_THERMAL, w.SCORE_POWER, w.SCORE_NETWORK, w.SCORE_STABILITY, w.SCORE_DISPLAY) THEN 'Power Supply'
      WHEN w.SCORE_THERMAL = GREATEST(w.SCORE_THERMAL, w.SCORE_POWER, w.SCORE_NETWORK, w.SCORE_STABILITY, w.SCORE_DISPLAY) THEN 'Overheating'
      ELSE 'Software Crash'
    END AS ISSUE_TYPE,
    w.SCORE_OVERALL AS SCORE,
    w.CONFIDENCE_BAND,
    'WATCHLIST' AS SOURCE,
    w.TOP_SIGNALS AS CONTEXT
  FROM PREDICTIVE_MAINTENANCE.OPERATIONS.WATCHLIST_CURRENT w;

  -- De-dupe to one best row per device
  CREATE OR REPLACE TEMP TABLE _best AS
  SELECT *
  FROM _candidates
  QUALIFY ROW_NUMBER() OVER (PARTITION BY DEVICE_ID ORDER BY SCORE DESC, SOURCE) = 1;

  -- Insert OPEN work orders (idempotency: avoid duplicates for same device+status open)
  INSERT INTO OPERATIONS.WORK_ORDERS (
    WORK_ORDER_ID, CREATED_AT, UPDATED_AT,
    STATUS, PRIORITY, DUE_BY,
    DEVICE_ID, ISSUE_TYPE, RECOMMENDED_ACTION, RECOMMENDED_CHANNEL,
    SOURCE, LINKED_RUN_ID,
    NOTES, CONTEXT
  )
  WITH prioritized AS (
    SELECT
      b.*,
      -- Priority should align with operational risk:
      -- - Predictions: treat probability as risk score (more sensitive for near-term failures)
      -- - Watchlist: treat anomaly score as risk score
      CASE
        WHEN SOURCE = 'PREDICTION' AND SCORE >= 0.70 THEN 'P1'
        WHEN SOURCE = 'PREDICTION' AND SCORE >= 0.55 THEN 'P2'
        WHEN SOURCE = 'WATCHLIST' AND SCORE >= 0.85 THEN 'P1'
        WHEN SOURCE = 'WATCHLIST' AND SCORE >= 0.70 THEN 'P2'
        ELSE 'P3'
      END AS DERIVED_PRIORITY,
      CASE
        WHEN SOURCE = 'PREDICTION' AND SCORE >= 0.70 THEN 8
        WHEN SOURCE = 'PREDICTION' AND SCORE >= 0.55 THEN 24
        WHEN SOURCE = 'WATCHLIST' AND SCORE >= 0.85 THEN 8
        WHEN SOURCE = 'WATCHLIST' AND SCORE >= 0.70 THEN 24
        ELSE 72
      END AS DUE_HOURS
    FROM _best b
  )
  SELECT
    UUID_STRING(),
    :demo_as_of_ts,
    :demo_as_of_ts,
    'OPEN',
    DERIVED_PRIORITY AS PRIORITY,
    DATEADD('hour', DUE_HOURS, :demo_as_of_ts) AS DUE_BY,
    DEVICE_ID,
    ISSUE_TYPE,
    CASE
      WHEN ISSUE_TYPE = 'Network Connectivity' THEN 'Run remote network diagnostics; reset interface; verify packet loss/latency.'
      WHEN ISSUE_TYPE = 'Power Supply' THEN 'Schedule proactive PSU replacement; validate power draw and temperature trend.'
      WHEN ISSUE_TYPE = 'Display Panel' THEN 'Dispatch for panel inspection/replacement; remote checks unlikely to resolve.'
      WHEN ISSUE_TYPE = 'Overheating' THEN 'Check placement/ventilation; clean vents; consider relocation; verify ambient conditions.'
      WHEN ISSUE_TYPE = 'Software Crash' THEN 'Apply remote restart/patch; collect logs; monitor CPU/memory.'
      ELSE 'Review anomaly signals and determine next best action.'
    END AS RECOMMENDED_ACTION,
    CASE
      WHEN ISSUE_TYPE IN ('Display Panel','Power Supply','Overheating') THEN 'FIELD'
      ELSE 'REMOTE'
    END AS RECOMMENDED_CHANNEL,
    SOURCE,
    :run_id,
    'Auto-generated by demo workflow.',
    CONTEXT
  FROM prioritized
  WHERE DEVICE_ID NOT IN (
    SELECT DEVICE_ID
    FROM OPERATIONS.WORK_ORDERS
    WHERE STATUS IN ('OPEN','IN_PROGRESS')
  )
  QUALIFY ROW_NUMBER() OVER (ORDER BY SCORE DESC) <= :TOP_N;

  RETURN 'Work orders generated ✅ run_id=' || run_id || ', as_of=' || demo_as_of_ts;
END;
$$;

CALL OPERATIONS.GENERATE_WORK_ORDERS('SCENARIO_LOCK', (SELECT DEMO_AS_OF_TS FROM OPERATIONS.V_DEMO_TIME), 25);
SELECT * FROM ANALYTICS.V_WORK_ORDERS_CURRENT ORDER BY PRIORITY, DUE_BY;


