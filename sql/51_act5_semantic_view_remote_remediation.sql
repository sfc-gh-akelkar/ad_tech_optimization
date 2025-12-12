/*============================================================================
  Act 5 (Snowflake Intelligence): Semantic View for Remote Remediation Executions
============================================================================*/

USE ROLE SF_INTELLIGENCE_DEMO;

USE DATABASE PREDICTIVE_MAINTENANCE;
USE SCHEMA ANALYTICS;

CREATE OR REPLACE SEMANTIC VIEW SV_REMOTE_REMEDIATION
  TABLES (
    execs AS PREDICTIVE_MAINTENANCE.ANALYTICS.V_REMOTE_EXECUTIONS
      PRIMARY KEY (EXECUTION_ID)
      WITH SYNONYMS = ('remote remediation', 'remote fixes', 'runbook executions')
      COMMENT = 'Simulated remote remediation executions and outcomes.'
  )
  DIMENSIONS (
    execs.execution_id AS execs.EXECUTION_ID,
    execs.work_order_id AS execs.WORK_ORDER_ID,
    execs.device_id AS execs.DEVICE_ID WITH SYNONYMS = ('device', 'screen', 'screen id'),
    execs.failure_type AS execs.FAILURE_TYPE,
    execs.runbook_name AS execs.RUNBOOK_NAME,
    execs.status AS execs.STATUS
  )
  METRICS (
    execs.total_executions AS COUNT(execs.EXECUTION_ID),
    execs.successes AS SUM(IFF(execs.STATUS = 'SUCCESS', 1, 0)),
    execs.escalations AS SUM(IFF(execs.STATUS = 'ESCALATED', 1, 0))
  )
  COMMENT = 'Act 5 semantic view: remote remediation outcomes (simulated).'
  COPY GRANTS;


