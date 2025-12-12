/*============================================================================
  Act 5 (Simulation): Automated Remote Resolution Workflows + Escalation

  Purpose:
  - Demonstrate "automated remote fixes" without touching real devices.
  - Create runbooks and simulated executions tied to work orders.

  Notes:
  - Execution outcomes are simulated using historical remote success rates by
    failure type (from ANALYTICS.V_REMOTE_RESOLUTION_RATES) with deterministic
    overrides for scenario devices (stable demo).
============================================================================*/

USE ROLE SF_INTELLIGENCE_DEMO;

USE DATABASE PREDICTIVE_MAINTENANCE;
USE SCHEMA OPERATIONS;

CREATE OR REPLACE TABLE OPERATIONS.REMOTE_RUNBOOKS (
  RUNBOOK_ID STRING,
  FAILURE_TYPE STRING,
  RUNBOOK_NAME STRING,
  DESCRIPTION STRING,
  DEFAULT_CHANNEL STRING, -- REMOTE | FIELD
  CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE OPERATIONS.REMOTE_RUNBOOK_STEPS (
  RUNBOOK_ID STRING,
  STEP_NUM INT,
  STEP_TITLE STRING,
  STEP_DETAILS STRING
);

CREATE OR REPLACE TABLE OPERATIONS.REMOTE_EXECUTIONS (
  EXECUTION_ID STRING,
  WORK_ORDER_ID STRING,
  DEVICE_ID STRING,
  FAILURE_TYPE STRING,
  RUNBOOK_ID STRING,
  STARTED_AT TIMESTAMP_NTZ,
  ENDED_AT TIMESTAMP_NTZ,
  STATUS STRING, -- STARTED | SUCCESS | FAILED | ESCALATED
  OUTCOME_NOTES STRING,
  SIGNALS VARIANT
);

-- Seed runbooks (idempotent)
DELETE FROM OPERATIONS.REMOTE_RUNBOOKS;
DELETE FROM OPERATIONS.REMOTE_RUNBOOK_STEPS;

INSERT INTO OPERATIONS.REMOTE_RUNBOOKS (RUNBOOK_ID, FAILURE_TYPE, RUNBOOK_NAME, DESCRIPTION, DEFAULT_CHANNEL)
SELECT * FROM VALUES
  ('RB-NET-001', 'Network Connectivity', 'Network Recovery', 'Reset network interface, verify packet loss/latency, refresh config.', 'REMOTE'),
  ('RB-SW-001', 'Software Crash', 'App Restart + Patch', 'Restart services, clear cache, validate CPU/memory, apply patch if available.', 'REMOTE'),
  ('RB-FW-001', 'Firmware Bug', 'Firmware Patch', 'Apply firmware update / hotfix and confirm stability.', 'REMOTE'),
  ('RB-THERM-001', 'Overheating', 'Thermal Mitigation', 'Reduce load, validate fan/vents, advise relocation if needed.', 'FIELD'),
  ('RB-PSU-001', 'Power Supply', 'Power Stabilization', 'Remote diagnostics, power cycle, validate power draw; likely requires replacement.', 'FIELD'),
  ('RB-DISP-001', 'Display Panel', 'Display Diagnostics', 'Brightness test, pixel check; typically requires panel replacement.', 'FIELD');

INSERT INTO OPERATIONS.REMOTE_RUNBOOK_STEPS (RUNBOOK_ID, STEP_NUM, STEP_TITLE, STEP_DETAILS)
SELECT * FROM VALUES
  ('RB-NET-001', 1, 'Collect network stats', 'Capture latency/packet loss; snapshot last 24h trend.'),
  ('RB-NET-001', 2, 'Reset network interface', 'Cycle interface and refresh configuration.'),
  ('RB-NET-001', 3, 'Verify recovery', 'Re-check latency/packet loss and confirm stable connectivity.'),

  ('RB-SW-001', 1, 'Collect logs', 'Pull last 4h error logs; capture CPU/memory.'),
  ('RB-SW-001', 2, 'Restart services', 'Restart player services; clear temp cache.'),
  ('RB-SW-001', 3, 'Validate stability', 'Confirm errors drop and CPU/memory normalize.'),

  ('RB-FW-001', 1, 'Check firmware version', 'Compare to latest recommended version.'),
  ('RB-FW-001', 2, 'Apply patch', 'Apply hotfix/firmware update in maintenance window.'),
  ('RB-FW-001', 3, 'Post-check', 'Confirm stability and no new errors.'),

  ('RB-THERM-001', 1, 'Remote thermal check', 'Confirm sustained high temperature and fan behavior.'),
  ('RB-THERM-001', 2, 'Recommend field action', 'If sustained, schedule field visit to inspect airflow/placement.'),

  ('RB-PSU-001', 1, 'Remote power diagnostics', 'Check power draw trend and spikes.'),
  ('RB-PSU-001', 2, 'Attempt stabilization', 'Power cycle and reduce load; confirm power draw.'),
  ('RB-PSU-001', 3, 'Escalate', 'If spikes persist, schedule PSU replacement.'),

  ('RB-DISP-001', 1, 'Remote display test', 'Run brightness test and artifact check.'),
  ('RB-DISP-001', 2, 'Escalate', 'If artifacts persist, dispatch for panel replacement.');

CREATE OR REPLACE VIEW ANALYTICS.V_REMOTE_EXECUTIONS AS
SELECT
  e.EXECUTION_ID,
  e.WORK_ORDER_ID,
  e.DEVICE_ID,
  e.FAILURE_TYPE,
  e.RUNBOOK_ID,
  r.RUNBOOK_NAME,
  e.STARTED_AT,
  e.ENDED_AT,
  e.STATUS,
  e.OUTCOME_NOTES,
  e.SIGNALS
FROM PREDICTIVE_MAINTENANCE.OPERATIONS.REMOTE_EXECUTIONS e
LEFT JOIN PREDICTIVE_MAINTENANCE.OPERATIONS.REMOTE_RUNBOOKS r
  ON e.RUNBOOK_ID = r.RUNBOOK_ID;

CREATE OR REPLACE PROCEDURE OPERATIONS.EXECUTE_REMOTE_WORK_ORDER(
  WORK_ORDER_ID STRING
)
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
  exec_id STRING DEFAULT UUID_STRING();
BEGIN
  -- Load work order
  CREATE OR REPLACE TEMP TABLE _wo AS
  SELECT *
  FROM PREDICTIVE_MAINTENANCE.OPERATIONS.WORK_ORDERS
  WHERE WORK_ORDER_ID = :WORK_ORDER_ID;

  LET device_id STRING := (SELECT DEVICE_ID FROM _wo);
  LET issue_type STRING := (SELECT ISSUE_TYPE FROM _wo);

  -- Pick runbook by issue type
  LET runbook_id STRING := (
    SELECT RUNBOOK_ID
    FROM PREDICTIVE_MAINTENANCE.OPERATIONS.REMOTE_RUNBOOKS
    WHERE FAILURE_TYPE = :issue_type
    QUALIFY ROW_NUMBER() OVER (ORDER BY RUNBOOK_ID) = 1
  );

  -- Historical success rate by failure type
  LET hist_rate FLOAT := (
    SELECT REMOTE_SUCCESS_RATE
    FROM PREDICTIVE_MAINTENANCE.ANALYTICS.V_REMOTE_RESOLUTION_RATES
    WHERE FAILURE_TYPE = :issue_type
  );

  -- Deterministic overrides for scenario devices (stable demo)
  LET forced_status STRING :=
    CASE
      WHEN device_id = '4512' THEN 'SUCCESS'   -- network: typically remote
      WHEN device_id IN ('4523','4556') THEN 'SUCCESS' -- software/firmware: remote
      WHEN device_id IN ('4532','7821','4545') THEN 'ESCALATED' -- hardware/env: field
      ELSE NULL
    END;

  LET started_at TIMESTAMP_NTZ := CURRENT_TIMESTAMP();
  LET ended_at TIMESTAMP_NTZ := DATEADD('minute', 10, started_at);

  LET outcome STRING :=
    COALESCE(
      forced_status,
      IFF(UNIFORM(0, 100, RANDOM()) < COALESCE(hist_rate, 0.70) * 100, 'SUCCESS', 'ESCALATED')
    );

  INSERT INTO OPERATIONS.REMOTE_EXECUTIONS (
    EXECUTION_ID, WORK_ORDER_ID, DEVICE_ID, FAILURE_TYPE, RUNBOOK_ID,
    STARTED_AT, ENDED_AT, STATUS, OUTCOME_NOTES, SIGNALS
  )
  SELECT
    :exec_id,
    :WORK_ORDER_ID,
    device_id,
    issue_type,
    runbook_id,
    started_at,
    ended_at,
    outcome,
    IFF(outcome = 'SUCCESS', 'Remote runbook completed successfully.', 'Escalated to field service based on outcome/likelihood.'),
    CONTEXT
  FROM _wo;

  -- Update work order state
  UPDATE OPERATIONS.WORK_ORDERS
  SET
    UPDATED_AT = CURRENT_TIMESTAMP(),
    STATUS = IFF(outcome = 'SUCCESS', 'COMPLETED', 'IN_PROGRESS'),
    NOTES = CONCAT(COALESCE(NOTES, ''), ' | Remote execution: ', outcome)
  WHERE WORK_ORDER_ID = :WORK_ORDER_ID;

  RETURN 'Remote execution complete ✅ execution_id=' || exec_id || ', outcome=' || outcome;
END;
$$;

-- Convenience: execute remote work for currently remote-recommended work orders
-- (scenario lock for deterministic outcomes)
SELECT 'Remote remediation objects created ✅' AS STATUS;


