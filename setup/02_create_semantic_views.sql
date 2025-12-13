/*******************************************************************************
 * PATIENTPOINT PREDICTIVE MAINTENANCE DEMO
 * Part 2: Snowflake Semantic Views for Cortex Analyst
 * 
 * Creates native Snowflake Semantic Views (not YAML semantic models)
 * for natural language queries in Snowflake Intelligence
 * 
 * Prerequisites: Run 01_create_database_and_data.sql first
 ******************************************************************************/

-- ============================================================================
-- USE DEMO ROLE
-- ============================================================================
USE ROLE SF_INTELLIGENCE_DEMO;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE PATIENTPOINT_MAINTENANCE;
USE SCHEMA DEVICE_OPS;

-- ============================================================================
-- CREATE ANALYTICS VIEWS
-- Clean, analytics-ready views that the semantic view will reference
-- ============================================================================

-- Device Health Summary View (combines inventory + latest telemetry)
CREATE OR REPLACE VIEW V_DEVICE_HEALTH_SUMMARY AS
WITH latest_telemetry AS (
    SELECT 
        DEVICE_ID,
        CPU_TEMP_CELSIUS,
        CPU_USAGE_PCT,
        MEMORY_USAGE_PCT,
        DISK_USAGE_PCT,
        NETWORK_LATENCY_MS,
        UPTIME_HOURS,
        ERROR_COUNT,
        LAST_HEARTBEAT,
        TIMESTAMP as TELEMETRY_TIMESTAMP,
        ROW_NUMBER() OVER (PARTITION BY DEVICE_ID ORDER BY TIMESTAMP DESC) as rn
    FROM DEVICE_TELEMETRY
)
SELECT 
    d.DEVICE_ID,
    d.DEVICE_MODEL,
    d.FACILITY_NAME,
    d.FACILITY_TYPE,
    d.LOCATION_CITY,
    d.LOCATION_STATE,
    CONCAT(d.LOCATION_CITY, ', ', d.LOCATION_STATE) as LOCATION,
    d.INSTALL_DATE,
    d.WARRANTY_EXPIRY,
    d.LAST_MAINTENANCE_DATE,
    DATEDIFF('day', d.LAST_MAINTENANCE_DATE, CURRENT_DATE()) as DAYS_SINCE_MAINTENANCE,
    d.FIRMWARE_VERSION,
    d.STATUS,
    d.HOURLY_AD_REVENUE_USD,
    d.MONTHLY_IMPRESSIONS,
    t.CPU_TEMP_CELSIUS,
    t.CPU_USAGE_PCT,
    t.MEMORY_USAGE_PCT,
    t.DISK_USAGE_PCT,
    t.NETWORK_LATENCY_MS,
    t.UPTIME_HOURS,
    t.ERROR_COUNT,
    t.LAST_HEARTBEAT,
    t.TELEMETRY_TIMESTAMP,
    -- Health score calculation
    GREATEST(0, 
        100 
        - CASE WHEN t.CPU_TEMP_CELSIUS > 70 THEN 30 WHEN t.CPU_TEMP_CELSIUS > 60 THEN 15 ELSE 0 END
        - CASE WHEN t.CPU_USAGE_PCT > 90 THEN 25 WHEN t.CPU_USAGE_PCT > 75 THEN 10 ELSE 0 END
        - CASE WHEN t.MEMORY_USAGE_PCT > 90 THEN 25 WHEN t.MEMORY_USAGE_PCT > 80 THEN 10 ELSE 0 END
        - CASE WHEN t.NETWORK_LATENCY_MS > 200 THEN 15 WHEN t.NETWORK_LATENCY_MS > 100 THEN 5 ELSE 0 END
        - CASE WHEN t.ERROR_COUNT > 10 THEN 20 WHEN t.ERROR_COUNT > 5 THEN 10 ELSE 0 END
    )::INT as HEALTH_SCORE,
    -- Risk classification
    CASE 
        WHEN d.STATUS = 'OFFLINE' THEN 'CRITICAL'
        WHEN t.CPU_TEMP_CELSIUS > 70 OR t.CPU_USAGE_PCT > 90 OR t.MEMORY_USAGE_PCT > 90 THEN 'HIGH'
        WHEN d.STATUS = 'DEGRADED' OR t.ERROR_COUNT > 5 THEN 'MEDIUM'
        ELSE 'LOW'
    END as RISK_LEVEL,
    -- Primary issue
    CASE 
        WHEN d.STATUS = 'OFFLINE' THEN 'Device Offline'
        WHEN t.CPU_TEMP_CELSIUS > 70 THEN 'Overheating'
        WHEN t.CPU_USAGE_PCT > 90 THEN 'High CPU Usage'
        WHEN t.MEMORY_USAGE_PCT > 90 THEN 'Memory Exhaustion'
        WHEN t.NETWORK_LATENCY_MS > 200 THEN 'Network Issues'
        WHEN t.ERROR_COUNT > 10 THEN 'High Error Rate'
        WHEN d.STATUS = 'DEGRADED' THEN 'Degraded Performance'
        ELSE 'Healthy'
    END as PRIMARY_ISSUE
FROM DEVICE_INVENTORY d
LEFT JOIN latest_telemetry t ON d.DEVICE_ID = t.DEVICE_ID AND t.rn = 1;

-- Maintenance Analytics View
CREATE OR REPLACE VIEW V_MAINTENANCE_ANALYTICS AS
SELECT 
    m.TICKET_ID,
    m.DEVICE_ID,
    d.DEVICE_MODEL,
    d.FACILITY_NAME,
    d.FACILITY_TYPE,
    d.LOCATION_CITY,
    d.LOCATION_STATE,
    CONCAT(d.LOCATION_CITY, ', ', d.LOCATION_STATE) as LOCATION,
    m.CREATED_AT,
    m.RESOLVED_AT,
    DATE_TRUNC('month', m.CREATED_AT) as TICKET_MONTH,
    DATE_TRUNC('week', m.CREATED_AT) as TICKET_WEEK,
    m.ISSUE_TYPE,
    m.ISSUE_DESCRIPTION,
    m.RESOLUTION_TYPE,
    m.RESOLUTION_NOTES,
    m.TECHNICIAN_ID,
    m.COST_USD,
    DATEDIFF('minute', m.CREATED_AT, m.RESOLVED_AT) as RESOLUTION_TIME_MINS,
    CASE 
        WHEN m.RESOLUTION_TYPE = 'REMOTE_FIX' THEN 185  -- Avg dispatch cost saved
        ELSE 0 
    END as COST_SAVINGS_USD,
    CASE 
        WHEN m.RESOLUTION_TYPE = 'REMOTE_FIX' THEN TRUE
        ELSE FALSE
    END as WAS_REMOTE_FIX
FROM MAINTENANCE_HISTORY m
JOIN DEVICE_INVENTORY d ON m.DEVICE_ID = d.DEVICE_ID;

-- ============================================================================
-- SEMANTIC VIEW 1: DEVICE FLEET ANALYTICS
-- For querying device health, status, and fleet metrics
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_DEVICE_FLEET
  COMMENT = 'Semantic view for device health monitoring and fleet analytics. Query device status, health scores, risk levels, and telemetry metrics.'

  TABLES (
    devices AS V_DEVICE_HEALTH_SUMMARY
      PRIMARY KEY (DEVICE_ID)
      WITH SYNONYMS = ('device', 'screen', 'unit', 'fleet', 'equipment')
      COMMENT = 'Current health status and telemetry for all HealthScreen devices'
  )

  DIMENSIONS (
    -- Device identifiers
    devices.device_id AS DEVICE_ID
      WITH SYNONYMS = ('device', 'screen id', 'unit id')
      COMMENT = 'Unique identifier for each HealthScreen device',
    
    devices.device_model AS DEVICE_MODEL
      WITH SYNONYMS = ('model', 'screen type', 'product type')
      COMMENT = 'Device model: Pro 55, Lite 32, or Max 65',
    
    -- Location dimensions
    devices.facility_name AS FACILITY_NAME
      WITH SYNONYMS = ('facility', 'location', 'clinic', 'hospital', 'office', 'site')
      COMMENT = 'Name of the healthcare facility where device is installed',
    
    devices.facility_type AS FACILITY_TYPE
      WITH SYNONYMS = ('facility category', 'type of facility', 'practice type')
      COMMENT = 'Type of healthcare facility: Hospital, Primary Care, Specialty, Urgent Care, Pediatrics',
    
    devices.location_city AS CITY
      WITH SYNONYMS = ('city')
      COMMENT = 'City where the facility is located',
    
    devices.location_state AS STATE
      WITH SYNONYMS = ('state', 'region')
      COMMENT = 'State where the facility is located (2-letter code)',
    
    devices.location AS FULL_LOCATION
      WITH SYNONYMS = ('full location', 'city and state', 'where')
      COMMENT = 'Combined city and state location',
    
    -- Status dimensions
    devices.status AS DEVICE_STATUS
      WITH SYNONYMS = ('status', 'state', 'condition', 'operational status')
      COMMENT = 'Current operational status: ONLINE, DEGRADED, OFFLINE, MAINTENANCE',
    
    devices.risk_level AS RISK_LEVEL
      WITH SYNONYMS = ('risk', 'priority', 'risk category', 'urgency')
      COMMENT = 'Risk classification: LOW, MEDIUM, HIGH, CRITICAL',
    
    devices.primary_issue AS PRIMARY_ISSUE
      WITH SYNONYMS = ('issue', 'problem', 'main issue', 'current problem')
      COMMENT = 'The primary issue affecting the device if any',
    
    devices.firmware_version AS FIRMWARE_VERSION
      WITH SYNONYMS = ('firmware', 'software version', 'version')
      COMMENT = 'Current firmware version installed on the device',
    
    -- Time dimensions
    devices.install_date AS INSTALL_DATE
      WITH SYNONYMS = ('installation date', 'deployed date', 'setup date')
      COMMENT = 'Date the device was installed at the facility',
    
    devices.last_maintenance_date AS LAST_MAINTENANCE_DATE
      WITH SYNONYMS = ('last service', 'last serviced', 'previous maintenance')
      COMMENT = 'Date of the most recent maintenance performed'
  )

  METRICS (
    -- Count metrics
    devices.total_devices AS COUNT(DISTINCT DEVICE_ID)
      WITH SYNONYMS = ('device count', 'number of devices', 'how many devices', 'fleet size')
      COMMENT = 'Total count of devices',
    
    devices.online_devices AS SUM(CASE WHEN STATUS = 'ONLINE' THEN 1 ELSE 0 END)
      WITH SYNONYMS = ('online count', 'devices online', 'working devices')
      COMMENT = 'Count of devices currently online',
    
    devices.offline_devices AS SUM(CASE WHEN STATUS = 'OFFLINE' THEN 1 ELSE 0 END)
      WITH SYNONYMS = ('offline count', 'devices offline', 'down devices')
      COMMENT = 'Count of devices currently offline',
    
    devices.degraded_devices AS SUM(CASE WHEN STATUS = 'DEGRADED' THEN 1 ELSE 0 END)
      WITH SYNONYMS = ('degraded count', 'devices degraded', 'struggling devices')
      COMMENT = 'Count of devices with degraded performance',
    
    devices.devices_at_risk AS SUM(CASE WHEN RISK_LEVEL IN ('HIGH', 'CRITICAL') THEN 1 ELSE 0 END)
      WITH SYNONYMS = ('at risk devices', 'risky devices', 'high risk count')
      COMMENT = 'Count of devices with HIGH or CRITICAL risk level',
    
    -- Health metrics
    devices.avg_health_score AS ROUND(AVG(HEALTH_SCORE), 1)
      WITH SYNONYMS = ('average health', 'health score', 'fleet health', 'mean health')
      COMMENT = 'Average health score across devices (0-100, higher is better)',
    
    -- Telemetry metrics
    devices.avg_cpu_temp AS ROUND(AVG(CPU_TEMP_CELSIUS), 1)
      WITH SYNONYMS = ('average temperature', 'cpu temperature', 'mean temp')
      COMMENT = 'Average CPU temperature in Celsius',
    
    devices.avg_cpu_usage AS ROUND(AVG(CPU_USAGE_PCT), 1)
      WITH SYNONYMS = ('cpu usage', 'processor usage', 'average cpu')
      COMMENT = 'Average CPU usage percentage',
    
    devices.avg_memory_usage AS ROUND(AVG(MEMORY_USAGE_PCT), 1)
      WITH SYNONYMS = ('memory usage', 'ram usage', 'average memory')
      COMMENT = 'Average memory usage percentage',
    
    devices.total_errors AS SUM(ERROR_COUNT)
      WITH SYNONYMS = ('error count', 'errors', 'total error count')
      COMMENT = 'Total error count across devices',
    
    devices.avg_days_since_maintenance AS ROUND(AVG(DAYS_SINCE_MAINTENANCE), 0)
      WITH SYNONYMS = ('days since service', 'maintenance age', 'service gap')
      COMMENT = 'Average days since last maintenance'
  )
;

-- ============================================================================
-- SEMANTIC VIEW 2: MAINTENANCE ANALYTICS
-- For querying maintenance history, costs, and resolution metrics
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_MAINTENANCE_ANALYTICS
  COMMENT = 'Semantic view for maintenance ticket analytics. Query issue types, resolution methods, costs, MTTR, and cost savings.'

  TABLES (
    tickets AS V_MAINTENANCE_ANALYTICS
      PRIMARY KEY (TICKET_ID)
      WITH SYNONYMS = ('maintenance', 'tickets', 'incidents', 'service calls', 'repairs')
      COMMENT = 'Historical maintenance records with issue types and resolutions'
  )

  DIMENSIONS (
    -- Ticket identifiers
    tickets.ticket_id AS TICKET_ID
      WITH SYNONYMS = ('ticket', 'case', 'incident', 'case number')
      COMMENT = 'Unique identifier for the maintenance ticket',
    
    tickets.device_id AS DEVICE_ID
      WITH SYNONYMS = ('device', 'screen')
      COMMENT = 'Device that required maintenance',
    
    -- Issue dimensions
    tickets.issue_type AS ISSUE_TYPE
      WITH SYNONYMS = ('problem type', 'issue category', 'failure type')
      COMMENT = 'Category of issue: DISPLAY_FREEZE, HIGH_CPU, NO_NETWORK, etc.',
    
    tickets.resolution_type AS RESOLUTION_TYPE
      WITH SYNONYMS = ('fix type', 'how fixed', 'resolution method', 'fix method')
      COMMENT = 'How the issue was resolved: REMOTE_FIX, FIELD_DISPATCH, REPLACEMENT',
    
    tickets.was_remote_fix AS WAS_REMOTE_FIX
      WITH SYNONYMS = ('fixed remotely', 'remote resolution', 'remote fix')
      COMMENT = 'Whether the issue was resolved remotely (TRUE/FALSE)',
    
    -- Location dimensions
    tickets.facility_name AS FACILITY_NAME
      WITH SYNONYMS = ('facility', 'location', 'site')
      COMMENT = 'Facility where the device is located',
    
    tickets.facility_type AS FACILITY_TYPE
      COMMENT = 'Type of healthcare facility',
    
    tickets.location AS FULL_LOCATION
      WITH SYNONYMS = ('city state', 'where')
      COMMENT = 'City and state of the facility',
    
    -- Time dimensions
    tickets.created_at AS CREATED_AT
      WITH SYNONYMS = ('ticket date', 'incident date', 'when it happened', 'opened')
      COMMENT = 'When the maintenance ticket was created',
    
    tickets.resolved_at AS RESOLVED_AT
      WITH SYNONYMS = ('resolution date', 'fixed date', 'closed')
      COMMENT = 'When the ticket was resolved',
    
    tickets.ticket_month AS TICKET_MONTH
      WITH SYNONYMS = ('month')
      COMMENT = 'Month the ticket was created'
  )

  METRICS (
    -- Count metrics
    tickets.total_tickets AS COUNT(DISTINCT TICKET_ID)
      WITH SYNONYMS = ('ticket count', 'number of incidents', 'how many tickets', 'incident count')
      COMMENT = 'Total count of maintenance tickets',
    
    tickets.remote_fix_count AS SUM(CASE WHEN RESOLUTION_TYPE = 'REMOTE_FIX' THEN 1 ELSE 0 END)
      WITH SYNONYMS = ('remote fixes', 'fixed remotely', 'remote resolutions')
      COMMENT = 'Number of issues resolved remotely',
    
    tickets.field_dispatch_count AS SUM(CASE WHEN RESOLUTION_TYPE = 'FIELD_DISPATCH' THEN 1 ELSE 0 END)
      WITH SYNONYMS = ('dispatches', 'field visits', 'technician visits', 'on-site fixes')
      COMMENT = 'Number of issues requiring field technician dispatch',
    
    -- Cost metrics
    tickets.total_cost AS SUM(COALESCE(COST_USD, 0))
      WITH SYNONYMS = ('maintenance cost', 'total spend', 'total expense')
      COMMENT = 'Total cost of maintenance in USD',
    
    tickets.avg_cost AS ROUND(AVG(COALESCE(COST_USD, 0)), 2)
      WITH SYNONYMS = ('average cost', 'cost per ticket')
      COMMENT = 'Average cost per maintenance ticket',
    
    tickets.total_cost_savings AS SUM(COST_SAVINGS_USD)
      WITH SYNONYMS = ('savings', 'money saved', 'cost savings', 'avoided costs')
      COMMENT = 'Total cost savings from remote fixes (avoided dispatch costs)',
    
    -- Time metrics
    tickets.avg_resolution_time AS ROUND(AVG(RESOLUTION_TIME_MINS), 0)
      WITH SYNONYMS = ('resolution time', 'time to fix', 'mttr', 'average fix time')
      COMMENT = 'Average time to resolve issues in minutes',
    
    -- Rate metrics
    tickets.remote_fix_rate AS ROUND(SUM(CASE WHEN RESOLUTION_TYPE = 'REMOTE_FIX' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0), 1)
      WITH SYNONYMS = ('remote resolution rate', 'automation rate', 'remote fix percentage')
      COMMENT = 'Percentage of issues resolved remotely'
  )
;

-- ============================================================================
-- SEMANTIC VIEW 3: REVENUE & SATISFACTION
-- For querying business impact metrics
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_BUSINESS_IMPACT
  COMMENT = 'Semantic view for business impact analytics. Query revenue loss, customer satisfaction, NPS scores, and downtime metrics.'

  TABLES (
    revenue AS V_REVENUE_IMPACT
      PRIMARY KEY (DEVICE_ID)
      WITH SYNONYMS = ('revenue', 'income', 'earnings', 'downtime')
      COMMENT = 'Revenue impact from device uptime and downtime',
    
    satisfaction AS V_CUSTOMER_SATISFACTION
      PRIMARY KEY (DEVICE_ID)
      WITH SYNONYMS = ('satisfaction', 'feedback', 'nps', 'customer feedback')
      COMMENT = 'Customer satisfaction and NPS scores from healthcare providers'
  )

  RELATIONSHIPS (
    satisfaction (DEVICE_ID) REFERENCES revenue
  )

  DIMENSIONS (
    -- Revenue dimensions
    revenue.device_id AS DEVICE_ID
      WITH SYNONYMS = ('device', 'screen')
      COMMENT = 'Device identifier',
    
    revenue.facility_name AS FACILITY_NAME
      WITH SYNONYMS = ('facility', 'location', 'site')
      COMMENT = 'Healthcare facility name',
    
    revenue.facility_type AS FACILITY_TYPE
      COMMENT = 'Type of healthcare facility',
    
    revenue.location AS FULL_LOCATION
      WITH SYNONYMS = ('city state', 'where')
      COMMENT = 'City and state location',
    
    -- Satisfaction dimensions
    satisfaction.nps_category AS NPS_CATEGORY
      WITH SYNONYMS = ('nps type', 'promoter status', 'satisfaction category')
      COMMENT = 'NPS classification: PROMOTER, PASSIVE, DETRACTOR'
  )

  METRICS (
    -- Revenue metrics
    revenue.total_revenue_loss AS SUM(TOTAL_REVENUE_LOSS_USD)
      WITH SYNONYMS = ('lost revenue', 'revenue loss', 'money lost', 'revenue impact')
      COMMENT = 'Total revenue lost due to device downtime in USD',
    
    revenue.total_downtime_hours AS SUM(TOTAL_DOWNTIME_HOURS)
      WITH SYNONYMS = ('downtime', 'hours offline', 'outage hours', 'downtime hours')
      COMMENT = 'Total hours of device downtime',
    
    revenue.downtime_incidents AS SUM(DOWNTIME_INCIDENTS)
      WITH SYNONYMS = ('outages', 'incidents', 'downtime count')
      COMMENT = 'Number of downtime incidents',
    
    revenue.avg_uptime AS ROUND(AVG(UPTIME_PERCENTAGE), 2)
      WITH SYNONYMS = ('uptime', 'availability', 'uptime rate', 'uptime percentage')
      COMMENT = 'Average uptime percentage across devices',
    
    revenue.total_impressions_lost AS SUM(TOTAL_IMPRESSIONS_LOST)
      WITH SYNONYMS = ('lost impressions', 'missed impressions', 'ad impressions lost')
      COMMENT = 'Total advertising impressions lost due to downtime',
    
    revenue.potential_revenue AS SUM(POTENTIAL_MONTHLY_REVENUE)
      WITH SYNONYMS = ('max revenue', 'potential earnings', 'maximum revenue')
      COMMENT = 'Maximum possible monthly revenue if 100% uptime',
    
    revenue.actual_revenue AS SUM(ACTUAL_MONTHLY_REVENUE)
      WITH SYNONYMS = ('actual earnings', 'realized revenue')
      COMMENT = 'Actual monthly revenue after accounting for downtime',
    
    -- Satisfaction metrics
    satisfaction.avg_nps_score AS ROUND(AVG(AVG_NPS_SCORE), 1)
      WITH SYNONYMS = ('nps', 'net promoter score', 'nps score', 'promoter score')
      COMMENT = 'Average Net Promoter Score (-100 to 100)',
    
    satisfaction.avg_satisfaction AS ROUND(AVG(AVG_SATISFACTION), 1)
      WITH SYNONYMS = ('satisfaction', 'rating', 'satisfaction score', 'happiness')
      COMMENT = 'Average satisfaction rating (1-5 stars)',
    
    satisfaction.avg_reliability_rating AS ROUND(AVG(AVG_RELIABILITY_RATING), 1)
      WITH SYNONYMS = ('reliability', 'reliability score', 'device reliability')
      COMMENT = 'Average device reliability rating (1-5)',
    
    satisfaction.positive_feedback AS SUM(POSITIVE_COUNT)
      WITH SYNONYMS = ('positive reviews', 'good feedback', 'happy customers')
      COMMENT = 'Number of positive feedback responses',
    
    satisfaction.negative_feedback AS SUM(NEGATIVE_COUNT)
      WITH SYNONYMS = ('negative reviews', 'bad feedback', 'complaints', 'unhappy customers')
      COMMENT = 'Number of negative feedback responses',
    
    satisfaction.pending_follow_ups AS SUM(FOLLOW_UPS_REQUIRED)
      WITH SYNONYMS = ('follow ups', 'pending actions', 'action items')
      COMMENT = 'Number of pending follow-up actions required'
  )
;

-- ============================================================================
-- SEMANTIC VIEW 4: OPERATIONS & WORK ORDERS
-- For operations center and field technician queries
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW SV_OPERATIONS
  COMMENT = 'Semantic view for operations center. Query work orders, technician assignments, dispatch status, and field operations.'

  TABLES (
    work_orders AS V_ACTIVE_WORK_ORDERS
      PRIMARY KEY (WORK_ORDER_ID)
      WITH SYNONYMS = ('work orders', 'tickets', 'jobs', 'dispatch', 'service calls')
      COMMENT = 'Active work orders and maintenance tasks',
    
    technicians AS V_TECHNICIAN_WORKLOAD
      PRIMARY KEY (TECHNICIAN_ID)
      WITH SYNONYMS = ('technicians', 'techs', 'field team', 'engineers', 'service team')
      COMMENT = 'Field technician roster and workload'
  )

  RELATIONSHIPS (
    work_orders (ASSIGNED_TECHNICIAN_ID) REFERENCES technicians (TECHNICIAN_ID)
  )

  DIMENSIONS (
    -- Work order dimensions
    work_orders.work_order_id AS WORK_ORDER_ID
      WITH SYNONYMS = ('work order', 'job number', 'ticket')
      COMMENT = 'Unique work order identifier',
    
    work_orders.device_id AS DEVICE_ID
      WITH SYNONYMS = ('device', 'screen')
      COMMENT = 'Device requiring service',
    
    work_orders.facility_name AS FACILITY_NAME
      WITH SYNONYMS = ('facility', 'location', 'site', 'customer')
      COMMENT = 'Facility name',
    
    work_orders.location AS FULL_LOCATION
      WITH SYNONYMS = ('city state', 'where')
      COMMENT = 'City and state',
    
    work_orders.priority AS PRIORITY
      WITH SYNONYMS = ('urgency', 'severity')
      COMMENT = 'Work order priority: CRITICAL, HIGH, MEDIUM, LOW',
    
    work_orders.status AS STATUS
      WITH SYNONYMS = ('work order status', 'state')
      COMMENT = 'Current status: OPEN, ASSIGNED, IN_PROGRESS, COMPLETED',
    
    work_orders.work_order_type AS WORK_ORDER_TYPE
      WITH SYNONYMS = ('type', 'category')
      COMMENT = 'Type: PREDICTIVE, REACTIVE, PREVENTIVE, INSTALLATION',
    
    work_orders.source AS SOURCE
      WITH SYNONYMS = ('origin', 'created by')
      COMMENT = 'How work order was created: AI_PREDICTION, MANUAL, PROVIDER_REQUEST',
    
    work_orders.scheduled_date AS SCHEDULED_DATE
      WITH SYNONYMS = ('date', 'when scheduled')
      COMMENT = 'Scheduled service date',
    
    work_orders.technician_name AS ASSIGNED_TECHNICIAN
      WITH SYNONYMS = ('tech', 'assigned to', 'engineer')
      COMMENT = 'Assigned technician name',
    
    -- Technician dimensions
    technicians.technician_name AS TECHNICIAN_NAME
      WITH SYNONYMS = ('tech name', 'engineer name')
      COMMENT = 'Technician full name',
    
    technicians.current_status AS TECHNICIAN_STATUS
      WITH SYNONYMS = ('availability', 'tech status')
      COMMENT = 'Technician status: AVAILABLE, ON_CALL, DISPATCHED, OFF_DUTY',
    
    technicians.region AS REGION
      COMMENT = 'Geographic region covered',
    
    technicians.specialization AS SPECIALIZATION
      WITH SYNONYMS = ('expertise', 'skill')
      COMMENT = 'Technician specialization: Hardware, Software, Network',
    
    technicians.certification_level AS CERTIFICATION_LEVEL
      WITH SYNONYMS = ('level', 'seniority')
      COMMENT = 'Certification level: Junior, Senior, Lead'
  )

  METRICS (
    -- Work order metrics
    work_orders.total_work_orders AS COUNT(DISTINCT WORK_ORDER_ID)
      WITH SYNONYMS = ('work order count', 'how many work orders', 'job count')
      COMMENT = 'Total count of active work orders',
    
    work_orders.critical_work_orders AS SUM(CASE WHEN PRIORITY = 'CRITICAL' THEN 1 ELSE 0 END)
      WITH SYNONYMS = ('critical jobs', 'urgent work orders')
      COMMENT = 'Count of critical priority work orders',
    
    work_orders.unassigned_work_orders AS SUM(CASE WHEN ASSIGNED_TECHNICIAN_ID IS NULL THEN 1 ELSE 0 END)
      WITH SYNONYMS = ('unassigned jobs', 'open jobs', 'needs assignment')
      COMMENT = 'Count of work orders not yet assigned',
    
    work_orders.ai_generated_work_orders AS SUM(CASE WHEN SOURCE = 'AI_PREDICTION' THEN 1 ELSE 0 END)
      WITH SYNONYMS = ('predictive work orders', 'ai work orders')
      COMMENT = 'Count of work orders generated by AI predictions',
    
    work_orders.avg_hours_open AS ROUND(AVG(HOURS_SINCE_CREATED), 1)
      WITH SYNONYMS = ('average age', 'hours waiting')
      COMMENT = 'Average hours since work order was created',
    
    -- Technician metrics
    technicians.total_technicians AS COUNT(DISTINCT TECHNICIAN_ID)
      WITH SYNONYMS = ('tech count', 'team size', 'how many technicians')
      COMMENT = 'Total number of technicians',
    
    technicians.available_technicians AS SUM(CASE WHEN CURRENT_STATUS = 'AVAILABLE' THEN 1 ELSE 0 END)
      WITH SYNONYMS = ('available techs', 'free technicians')
      COMMENT = 'Technicians currently available for dispatch',
    
    technicians.avg_technician_rating AS ROUND(AVG(AVG_RATING), 2)
      WITH SYNONYMS = ('average rating', 'team rating')
      COMMENT = 'Average technician performance rating',
    
    technicians.total_workload_mins AS SUM(TOTAL_ESTIMATED_MINS)
      WITH SYNONYMS = ('total work', 'workload')
      COMMENT = 'Total estimated work minutes across all technicians'
  )
;

-- ============================================================================
-- GRANT ACCESS TO SEMANTIC VIEWS
-- ============================================================================
GRANT USAGE ON SEMANTIC VIEW SV_DEVICE_FLEET TO ROLE SF_INTELLIGENCE_DEMO;
GRANT USAGE ON SEMANTIC VIEW SV_MAINTENANCE_ANALYTICS TO ROLE SF_INTELLIGENCE_DEMO;
GRANT USAGE ON SEMANTIC VIEW SV_BUSINESS_IMPACT TO ROLE SF_INTELLIGENCE_DEMO;
GRANT USAGE ON SEMANTIC VIEW SV_OPERATIONS TO ROLE SF_INTELLIGENCE_DEMO;

-- ============================================================================
-- VERIFICATION
-- ============================================================================
SHOW SEMANTIC VIEWS IN SCHEMA DEVICE_OPS;

-- Test queries using the semantic views
SELECT * FROM SEMANTIC_VIEW(
    SV_DEVICE_FLEET
    DIMENSIONS DEVICE_STATUS
    METRICS total_devices, avg_health_score
);

SELECT * FROM SEMANTIC_VIEW(
    SV_MAINTENANCE_ANALYTICS
    DIMENSIONS ISSUE_TYPE
    METRICS total_tickets, remote_fix_rate, avg_resolution_time
);

SELECT * FROM SEMANTIC_VIEW(
    SV_BUSINESS_IMPACT
    METRICS total_revenue_loss, avg_nps_score, avg_uptime
);

SELECT * FROM SEMANTIC_VIEW(
    SV_OPERATIONS
    DIMENSIONS PRIORITY, STATUS
    METRICS total_work_orders, unassigned_work_orders
);

