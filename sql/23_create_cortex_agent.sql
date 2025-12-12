/*============================================================================
  Create Cortex Agent (Snowflake Intelligence) via SQL

  This script creates an AGENT object with:
  - Cortex Analyst tool(s) backed by semantic views (structured data)
  - Cortex Search tool backed by Cortex Search service (knowledge retrieval)

  References:
  - Best practices (semantic views): https://www.snowflake.com/en/developers/guides/best-practices-to-building-cortex-agents/#semantic-views-data-level
  - Agent SQL example: https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents-manage

  Prereqs (run first):
  - sql/20_intelligence_semantic_layer.sql
  - sql/22_create_semantic_views.sql
  - sql/21_cortex_search_kb.sql
  - sql/30_act2_watchlist.sql
  - sql/31_act2_semantic_view_watchlist.sql

  IMPORTANT:
  - This script uses warehouse APP_WH for Analyst execution.
  - Orchestration model is set to "auto".
============================================================================*/

USE ROLE SF_INTELLIGENCE_DEMO;

USE DATABASE PREDICTIVE_MAINTENANCE;
USE SCHEMA OPERATIONS;

CREATE OR REPLACE AGENT MAINTENANCE_OPS_AGENT
  COMMENT = 'PatientPoint Maintenance Ops Agent: fleet health, telemetry trends, and evidence-based troubleshooting.'
  PROFILE = '{"display_name":"Maintenance Ops Agent","avatar":"business-icon.png","color":"blue"}'
  FROM SPECIFICATION
$$
models:
  orchestration: auto

orchestration:
  budget:
    seconds: 45
    tokens: 12000

instructions:
  system: |
    You are PatientPoint Maintenance Ops Agent. Your job is to help prevent screen downtime by identifying at-risk devices,
    explaining what signals are abnormal (temperature, power, network, errors), and recommending next best actions based on
    historical outcomes. You must be accurate, explainable, and governed: use tools to retrieve data and do not guess.

    Boundaries:
    - Do not fabricate cost savings or model accuracy. Use measured values from data. If not available, state limitations.
    - Do not infer or provide PHI/PII (not present in this dataset).
    - Do not execute real device actions; provide recommendations only.

  orchestration: |
    Tooling rules:
    - Use Analyst_Watchlist to identify which devices are most abnormal right now (baseline 14d vs scoring 1d) and why.
    - Use Analyst_Fleet for fleet status, current critical/warning devices, and locations.
    - Use Analyst_Telemetry for 7–30 day trends (temperature/power/network/errors/brightness).
    - Use Analyst_Incidents for incident history, downtime, cost and revenue impact.
    - Use Analyst_RemoteRates for remote resolution success rates by failure type.
    - Use Analyst_Baseline for pre-ML baseline monitoring workload.
    - Use Search_KB to retrieve similar incidents and troubleshooting knowledge; prefer filters by FAILURE_TYPE when applicable.

    Workflow for device deep dive:
    1) Use Analyst_Fleet to get current status for the device.
    2) Use Analyst_Telemetry to summarize the last 7–30 days of trends for the device.
    3) Use Search_KB to retrieve top similar incidents (filter by failure type if known).
    4) Use Analyst_RemoteRates to cite historical remote-fix success rates for that failure type (if available).
    5) Respond with: executive summary, key signals, evidence, recommended next action options with caveats.

  response: |
    Response format:
    - Start with 1–3 bullet executive summary.
    - Then include a short "Evidence" section with key numbers and date ranges.
    - Then include "Recommended next actions" with Option A (low cost) and Option B (escalation), each with rationale.
    - Keep it concise and business-oriented.

  sample_questions:
    - question: "What devices should the ops team look at first today, and why?"
      answer: "I will use the anomaly watchlist semantic view to rank devices and summarize the top abnormal signals."
    - question: "How many devices are critical today, and where are they located?"
      answer: "I will use the fleet status semantic view to summarize critical devices by city/state."
    - question: "Why is device 4532 flagged? Show the last 7 days of key metrics."
      answer: "I will pull current status and then summarize daily telemetry trends for the last 7 days."
    - question: "For network degradation, what fixes have worked historically?"
      answer: "I will retrieve similar incidents from the knowledge base and compare against historical remote success rates."
    - question: "What is our baseline monitoring workload today (pre-ML)?"
      answer: "I will use the baseline semantic view to report devices requiring review and charts-to-review proxy."

tools:
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "Analyst_Watchlist"
      description: "Ranked anomaly watchlist (baseline 14d vs scoring 1d) with explainable domain scores and why-flagged."
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "Analyst_Fleet"
      description: "Fleet health and current device status (critical/warning, location, model)."
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "Analyst_Telemetry"
      description: "Telemetry trends (daily rollups) for temperature, power, network, errors, brightness."
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "Analyst_Incidents"
      description: "Incident history including downtime, cost, revenue impact, root cause, operator notes."
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "Analyst_RemoteRates"
      description: "Remote resolution success rates by failure type."
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "Analyst_Baseline"
      description: "Baseline (pre-ML) monitoring workload and counts."
  - tool_spec:
      type: "cortex_search"
      name: "Search_KB"
      description: "Searches the maintenance knowledge base for similar incidents and troubleshooting steps."

tool_resources:
  Analyst_Watchlist:
    semantic_view: "PREDICTIVE_MAINTENANCE.ANALYTICS.SV_ANOMALY_WATCHLIST"
    warehouse: "APP_WH"
    timeout_seconds: 60
  Analyst_Fleet:
    semantic_view: "PREDICTIVE_MAINTENANCE.ANALYTICS.SV_FLEET_STATUS"
    warehouse: "APP_WH"
    timeout_seconds: 60
  Analyst_Telemetry:
    semantic_view: "PREDICTIVE_MAINTENANCE.ANALYTICS.SV_DEVICE_TELEMETRY_DAILY"
    warehouse: "APP_WH"
    timeout_seconds: 60
  Analyst_Incidents:
    semantic_view: "PREDICTIVE_MAINTENANCE.ANALYTICS.SV_MAINTENANCE_INCIDENTS"
    warehouse: "APP_WH"
    timeout_seconds: 60
  Analyst_RemoteRates:
    semantic_view: "PREDICTIVE_MAINTENANCE.ANALYTICS.SV_REMOTE_RESOLUTION_RATES"
    warehouse: "APP_WH"
    timeout_seconds: 60
  Analyst_Baseline:
    semantic_view: "PREDICTIVE_MAINTENANCE.ANALYTICS.SV_BASELINE_PRE_ML"
    warehouse: "APP_WH"
    timeout_seconds: 60
  Search_KB:
    name: "PREDICTIVE_MAINTENANCE.OPERATIONS.MAINTENANCE_KB_SEARCH"
    max_results: "5"
    title_column: "KB_TITLE"
    id_column: "KB_ID"
$$;

-- Grant usage to a role (edit as needed)
-- GRANT USAGE ON AGENT PREDICTIVE_MAINTENANCE.OPERATIONS.MAINTENANCE_OPS_AGENT TO ROLE <YOUR_ROLE>;

SHOW AGENTS LIKE 'MAINTENANCE_OPS_AGENT';


