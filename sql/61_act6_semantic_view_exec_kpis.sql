/*============================================================================
  Act 6 (Snowflake Intelligence): Executive KPI Semantic View
============================================================================*/

USE ROLE SF_INTELLIGENCE_DEMO;

USE DATABASE PREDICTIVE_MAINTENANCE;
USE SCHEMA ANALYTICS;

CREATE OR REPLACE SEMANTIC VIEW SV_EXEC_KPIS
  TABLES (
    kpi AS PREDICTIVE_MAINTENANCE.ANALYTICS.V_EXEC_KPIS
      PRIMARY KEY (AS_OF_TS)
      WITH SYNONYMS = ('executive dashboard', 'kpis', 'roi', 'business impact')
      COMMENT = 'Executive KPIs (observed + transparent assumption-driven estimates).'
  )
  DIMENSIONS (
    kpi.as_of_ts AS kpi.AS_OF_TS WITH SYNONYMS = ('as of', 'timestamp')
  )
  METRICS (
    kpi.fleet_size AS MAX(kpi.FLEET_SIZE),
    kpi.critical_now AS MAX(kpi.CRITICAL_NOW),
    kpi.warning_now AS MAX(kpi.WARNING_NOW),
    kpi.watchlist_count AS MAX(kpi.WATCHLIST_COUNT),
    kpi.predicted_failures_48h AS MAX(kpi.PREDICTED_FAILURES_48H),
    kpi.open_work_orders AS MAX(kpi.OPEN_WORK_ORDERS),

    kpi.incidents_30d AS MAX(kpi.INCIDENTS_30D),
    kpi.field_events_30d AS MAX(kpi.FIELD_EVENTS_30D),
    kpi.remote_events_30d AS MAX(kpi.REMOTE_EVENTS_30D),
    kpi.downtime_hours_30d AS MAX(kpi.DOWNTIME_HOURS_30D),
    kpi.revenue_impact_usd_30d AS MAX(kpi.REVENUE_IMPACT_USD_30D),

    kpi.remote_exec_success_rate_30d AS MAX(kpi.REMOTE_EXEC_SUCCESS_RATE_30D),
    kpi.est_revenue_protected_usd_30d AS MAX(kpi.EST_REVENUE_PROTECTED_USD_30D),
    kpi.est_field_cost_avoided_usd_30d AS MAX(kpi.EST_FIELD_COST_AVOIDED_USD_30D)
  )
  COMMENT = 'Act 6 semantic view: executive KPIs. Estimates are explicitly assumption-driven.'
  COPY GRANTS;


