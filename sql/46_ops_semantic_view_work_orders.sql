/*============================================================================
  Ops Center (Snowflake Intelligence): Semantic View for Work Orders
============================================================================*/

USE ROLE SF_INTELLIGENCE_DEMO;

USE DATABASE PREDICTIVE_MAINTENANCE;
USE SCHEMA ANALYTICS;

CREATE OR REPLACE SEMANTIC VIEW SV_WORK_ORDERS
  TABLES (
    wo AS PREDICTIVE_MAINTENANCE.ANALYTICS.V_WORK_ORDERS_CURRENT
      PRIMARY KEY (WORK_ORDER_ID)
      WITH SYNONYMS = ('work orders', 'tickets', 'dispatch queue')
      COMMENT = 'Current open/in-progress work orders generated from watchlist/predictions.'
  )
  DIMENSIONS (
    wo.work_order_id AS wo.WORK_ORDER_ID,
    wo.device_id AS wo.DEVICE_ID WITH SYNONYMS = ('device', 'screen', 'screen id'),
    wo.status AS wo.STATUS,
    wo.priority AS wo.PRIORITY,
    wo.issue_type AS wo.ISSUE_TYPE WITH SYNONYMS = ('issue', 'failure type'),
    wo.recommended_channel AS wo.RECOMMENDED_CHANNEL WITH SYNONYMS = ('channel', 'remote or field')
  )
  METRICS (
    wo.open_work_orders AS COUNT(wo.WORK_ORDER_ID) COMMENT = 'Count of open/in-progress work orders.'
  )
  COMMENT = 'Ops Center semantic view: work order queue and recommended actions.'
  COPY GRANTS;


