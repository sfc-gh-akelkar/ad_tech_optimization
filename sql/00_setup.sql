/*============================================================================
  Database setup
  
  Purpose: Create the foundational database schema for predictive maintenance
  
  What this creates:
  - Database and schemas
  - Device inventory table
  - Telemetry time-series data
  - Maintenance history
  - Initial reference data
  
  Run this first in Snowsight
============================================================================*/

USE ROLE SF_INTELLIGENCE_DEMO;

-- Create database and schemas
CREATE DATABASE IF NOT EXISTS PREDICTIVE_MAINTENANCE;

USE DATABASE PREDICTIVE_MAINTENANCE;

CREATE SCHEMA IF NOT EXISTS RAW_DATA;      -- Ingested telemetry
CREATE SCHEMA IF NOT EXISTS ANALYTICS;     -- Feature engineering, predictions
CREATE SCHEMA IF NOT EXISTS OPERATIONS;    -- Operational tables (alerts, workflows)

/*----------------------------------------------------------------------------
  Demo clock (reproducible outputs regardless of run date)
----------------------------------------------------------------------------*/

USE SCHEMA OPERATIONS;

CREATE TABLE IF NOT EXISTS OPERATIONS.DEMO_CONFIG (
  DEMO_NAME STRING,
  DEMO_AS_OF_TS TIMESTAMP_NTZ,
  HISTORY_DAYS INT,
  UPDATED_AT TIMESTAMP_NTZ
);

MERGE INTO OPERATIONS.DEMO_CONFIG t
USING (
  SELECT
    'DEFAULT' AS DEMO_NAME,
    TO_TIMESTAMP_NTZ('2025-12-12 12:00:00') AS DEMO_AS_OF_TS,
    30 AS HISTORY_DAYS,
    CURRENT_TIMESTAMP() AS UPDATED_AT
) s
ON t.DEMO_NAME = s.DEMO_NAME
WHEN MATCHED THEN
  UPDATE SET
    DEMO_AS_OF_TS = t.DEMO_AS_OF_TS,
    HISTORY_DAYS = t.HISTORY_DAYS,
    UPDATED_AT = CURRENT_TIMESTAMP()
WHEN NOT MATCHED THEN
  INSERT (DEMO_NAME, DEMO_AS_OF_TS, HISTORY_DAYS, UPDATED_AT)
  VALUES (s.DEMO_NAME, s.DEMO_AS_OF_TS, s.HISTORY_DAYS, s.UPDATED_AT);

CREATE OR REPLACE VIEW OPERATIONS.V_DEMO_TIME AS
SELECT
  DEMO_AS_OF_TS,
  TO_DATE(DEMO_AS_OF_TS) AS DEMO_AS_OF_DATE,
  HISTORY_DAYS
FROM OPERATIONS.DEMO_CONFIG
WHERE DEMO_NAME = 'DEFAULT';

USE SCHEMA RAW_DATA;

/*----------------------------------------------------------------------------
  TABLE: DEVICE_INVENTORY
  Dimension table containing device metadata
----------------------------------------------------------------------------*/
CREATE OR REPLACE TABLE DEVICE_INVENTORY (
    DEVICE_ID VARCHAR(50) PRIMARY KEY,
    DEVICE_MODEL VARCHAR(100),
    MANUFACTURER VARCHAR(100),
    INSTALLATION_DATE DATE,
    LOCATION_ID VARCHAR(50),
    FACILITY_NAME VARCHAR(200),
    FACILITY_CITY VARCHAR(100),
    FACILITY_STATE VARCHAR(2),
    LATITUDE FLOAT,
    LONGITUDE FLOAT,
    ENVIRONMENT_TYPE VARCHAR(50),     -- 'Lobby', 'Waiting Room', 'Exam Room', 'Hallway'
    HARDWARE_VERSION VARCHAR(50),
    FIRMWARE_VERSION VARCHAR(50),
    WARRANTY_STATUS VARCHAR(50),
    LAST_MAINTENANCE_DATE DATE,
    OPERATIONAL_STATUS VARCHAR(50),   -- 'Active', 'Maintenance', 'Offline', 'Decommissioned'
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

/*----------------------------------------------------------------------------
  TABLE: SCREEN_TELEMETRY
  Time-series fact table with device metrics
----------------------------------------------------------------------------*/
CREATE OR REPLACE TABLE SCREEN_TELEMETRY (
    TELEMETRY_ID NUMBER AUTOINCREMENT PRIMARY KEY,
    DEVICE_ID VARCHAR(50) NOT NULL,
    TIMESTAMP TIMESTAMP_NTZ NOT NULL,
    
    -- Temperature metrics
    TEMPERATURE_F FLOAT,              -- Device internal temperature (Fahrenheit)
    AMBIENT_TEMP_F FLOAT,             -- Ambient room temperature
    
    -- Power metrics
    POWER_CONSUMPTION_W FLOAT,        -- Current power draw (Watts)
    VOLTAGE FLOAT,                    -- Input voltage
    
    -- Performance metrics
    CPU_USAGE_PCT FLOAT,              -- CPU utilization percentage
    MEMORY_USAGE_PCT FLOAT,           -- Memory utilization percentage
    DISK_USAGE_PCT FLOAT,             -- Disk usage percentage
    
    -- Display metrics
    BRIGHTNESS_LEVEL INT,             -- 0-100 brightness setting
    SCREEN_ON_HOURS FLOAT,            -- Cumulative hours screen has been on
    
    -- Network metrics
    NETWORK_LATENCY_MS FLOAT,         -- Network round-trip time
    PACKET_LOSS_PCT FLOAT,            -- Network packet loss percentage
    BANDWIDTH_MBPS FLOAT,             -- Network bandwidth usage
    
    -- Health metrics
    ERROR_COUNT INT,                  -- Number of errors in last hour
    WARNING_COUNT INT,                -- Number of warnings in last hour
    UPTIME_HOURS FLOAT,               -- Hours since last restart
    
    -- Metadata
    DATA_QUALITY_SCORE FLOAT,         -- 0-1 score for data completeness
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    
    FOREIGN KEY (DEVICE_ID) REFERENCES DEVICE_INVENTORY(DEVICE_ID)
);

-- Add clustering for time-series queries
ALTER TABLE SCREEN_TELEMETRY CLUSTER BY (DEVICE_ID, TIMESTAMP);

/*----------------------------------------------------------------------------
  TABLE: MAINTENANCE_HISTORY
  Historical maintenance and failure records
----------------------------------------------------------------------------*/
CREATE OR REPLACE TABLE MAINTENANCE_HISTORY (
    MAINTENANCE_ID VARCHAR(50) PRIMARY KEY,
    DEVICE_ID VARCHAR(50) NOT NULL,
    INCIDENT_DATE TIMESTAMP_NTZ NOT NULL,
    INCIDENT_TYPE VARCHAR(100),           -- 'Preventive', 'Corrective', 'Predictive'
    FAILURE_TYPE VARCHAR(100),            -- 'Power Supply', 'Display Panel', 'Network', 'Software', etc.
    FAILURE_SYMPTOMS TEXT,                -- Description of symptoms
    
    -- Resolution details
    RESOLUTION_TYPE VARCHAR(100),         -- 'Remote Fix', 'Field Service', 'Part Replacement'
    RESOLUTION_DATE TIMESTAMP_NTZ,
    RESOLUTION_TIME_HOURS FLOAT,          -- Time from incident to resolution
    
    -- Actions taken
    ACTIONS_TAKEN TEXT,                   -- Description of repair actions
    REMOTE_FIX_ATTEMPTED BOOLEAN,
    REMOTE_FIX_SUCCESSFUL BOOLEAN,
    PARTS_REPLACED TEXT,                  -- List of replaced components
    TECHNICIAN_ID VARCHAR(50),
    
    -- Costs
    LABOR_COST_USD FLOAT,
    PARTS_COST_USD FLOAT,
    TRAVEL_COST_USD FLOAT,
    TOTAL_COST_USD FLOAT,
    
    -- Impact
    DOWNTIME_HOURS FLOAT,
    REVENUE_IMPACT_USD FLOAT,             -- Estimated lost revenue
    CUSTOMER_NOTIFIED BOOLEAN,
    
    -- Root cause
    ROOT_CAUSE TEXT,
    PREVENTABLE BOOLEAN,

    -- Enrichment: additional context to support downstream search/analytics
    PRE_FAILURE_TEMP_TREND VARCHAR(20),        -- 'STABLE', 'CLIMBING', 'ERRATIC'
    PRE_FAILURE_POWER_TREND VARCHAR(20),
    PRE_FAILURE_NETWORK_TREND VARCHAR(20),
    DAYS_OF_WARNING_SIGNS INT,
    FIRMWARE_VERSION_AT_INCIDENT VARCHAR(50),
    ENVIRONMENT_TYPE_AT_INCIDENT VARCHAR(50),
    DEVICE_MODEL_AT_INCIDENT VARCHAR(100),
    DEVICE_AGE_DAYS_AT_INCIDENT INT,
    OPERATOR_NOTES TEXT,
    SIMILAR_RECENT_FAILURES INT,
    
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    
    FOREIGN KEY (DEVICE_ID) REFERENCES DEVICE_INVENTORY(DEVICE_ID)
);

/*----------------------------------------------------------------------------
  TABLE: DEVICE_MODELS_REFERENCE
  Reference data for different device models and their characteristics
----------------------------------------------------------------------------*/
CREATE OR REPLACE TABLE DEVICE_MODELS_REFERENCE (
    MODEL_NAME VARCHAR(100) PRIMARY KEY,
    MANUFACTURER VARCHAR(100),
    TYPICAL_TEMP_F FLOAT,                 -- Normal operating temperature
    TEMP_WARNING_THRESHOLD_F FLOAT,       -- Warning threshold
    TEMP_CRITICAL_THRESHOLD_F FLOAT,      -- Critical threshold
    TYPICAL_POWER_W FLOAT,                -- Normal power consumption
    POWER_WARNING_THRESHOLD_W FLOAT,
    POWER_CRITICAL_THRESHOLD_W FLOAT,
    EXPECTED_LIFETIME_YEARS FLOAT,        -- Expected device lifetime
    COMMON_FAILURE_MODES TEXT,            -- JSON array of common failures
    MAINTENANCE_INTERVAL_DAYS INT,
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

/*----------------------------------------------------------------------------
  INSERT: Reference data for device models
----------------------------------------------------------------------------*/
INSERT INTO DEVICE_MODELS_REFERENCE 
(MODEL_NAME, MANUFACTURER, TYPICAL_TEMP_F, TEMP_WARNING_THRESHOLD_F, TEMP_CRITICAL_THRESHOLD_F,
 TYPICAL_POWER_W, POWER_WARNING_THRESHOLD_W, POWER_CRITICAL_THRESHOLD_W,
 EXPECTED_LIFETIME_YEARS, COMMON_FAILURE_MODES, MAINTENANCE_INTERVAL_DAYS)
VALUES
('Samsung DM55E', 'Samsung', 65, 75, 85, 100, 150, 200, 5.0, '["Power Supply", "Display Panel", "Software"]', 180),
('LG 55XS4F', 'LG', 63, 73, 83, 95, 140, 180, 5.5, '["Display Panel", "Network"]', 180),
('NEC P554', 'NEC', 67, 77, 87, 105, 155, 205, 6.0, '["Power Supply", "Software"]', 180),
('Philips 55BDL4050D', 'Philips', 64, 74, 84, 98, 145, 190, 5.2, '["Display Panel", "Power Supply"]', 180);

/*----------------------------------------------------------------------------
  VIEWS: Convenience views for common queries
----------------------------------------------------------------------------*/

-- Latest telemetry per device
CREATE OR REPLACE VIEW RAW_DATA.V_LATEST_TELEMETRY AS
SELECT 
    t.*,
    d.DEVICE_MODEL,
    d.FACILITY_NAME,
    d.FACILITY_STATE,
    d.ENVIRONMENT_TYPE
FROM SCREEN_TELEMETRY t
INNER JOIN (
    SELECT DEVICE_ID, MAX(TIMESTAMP) AS MAX_TIMESTAMP
    FROM SCREEN_TELEMETRY
    GROUP BY DEVICE_ID
) latest ON t.DEVICE_ID = latest.DEVICE_ID AND t.TIMESTAMP = latest.MAX_TIMESTAMP
LEFT JOIN DEVICE_INVENTORY d ON t.DEVICE_ID = d.DEVICE_ID;

-- Device health summary
CREATE OR REPLACE VIEW RAW_DATA.V_DEVICE_HEALTH_SUMMARY AS
SELECT 
    d.DEVICE_ID,
    d.DEVICE_MODEL,
    d.HARDWARE_VERSION,
    d.FIRMWARE_VERSION,
    d.WARRANTY_STATUS,
    d.FACILITY_NAME,
    d.FACILITY_CITY,
    d.FACILITY_STATE,
    d.ENVIRONMENT_TYPE,
    d.OPERATIONAL_STATUS,
    t.TEMPERATURE_F,
    t.POWER_CONSUMPTION_W,
    t.ERROR_COUNT,
    t.UPTIME_HOURS,
    t.TIMESTAMP AS LAST_REPORT_TIME,
    DATEDIFF('day', d.INSTALLATION_DATE, (SELECT DEMO_AS_OF_DATE FROM OPERATIONS.V_DEMO_TIME)) AS DEVICE_AGE_DAYS,
    DATEDIFF('day', d.LAST_MAINTENANCE_DATE, (SELECT DEMO_AS_OF_DATE FROM OPERATIONS.V_DEMO_TIME)) AS DAYS_SINCE_MAINTENANCE,
    -- Simple health flags based on model thresholds
    CASE 
        WHEN t.TEMPERATURE_F > m.TEMP_CRITICAL_THRESHOLD_F THEN 'CRITICAL'
        WHEN t.TEMPERATURE_F > m.TEMP_WARNING_THRESHOLD_F THEN 'WARNING'
        ELSE 'NORMAL'
    END AS TEMP_STATUS,
    CASE 
        WHEN t.POWER_CONSUMPTION_W > m.POWER_CRITICAL_THRESHOLD_W THEN 'CRITICAL'
        WHEN t.POWER_CONSUMPTION_W > m.POWER_WARNING_THRESHOLD_W THEN 'WARNING'
        ELSE 'NORMAL'
    END AS POWER_STATUS
FROM DEVICE_INVENTORY d
LEFT JOIN V_LATEST_TELEMETRY t ON d.DEVICE_ID = t.DEVICE_ID
LEFT JOIN DEVICE_MODELS_REFERENCE m ON d.DEVICE_MODEL = m.MODEL_NAME;

/*----------------------------------------------------------------------------
  ANALYTICS: Baseline (Pre-ML) Metrics

  These views establish the "before ML" baseline so the demo can show deltas
  (more lead time, fewer manual checks, etc.) without inventing cost numbers.
----------------------------------------------------------------------------*/

CREATE OR REPLACE VIEW ANALYTICS.V_THRESHOLD_DETECTION_WINDOWS AS
WITH THRESHOLDS AS (
  SELECT
    d.DEVICE_ID,
    d.DEVICE_MODEL,
    m.TEMP_WARNING_THRESHOLD_F,
    m.TEMP_CRITICAL_THRESHOLD_F,
    m.POWER_WARNING_THRESHOLD_W,
    m.POWER_CRITICAL_THRESHOLD_W
  FROM RAW_DATA.DEVICE_INVENTORY d
  JOIN RAW_DATA.DEVICE_MODELS_REFERENCE m
    ON d.DEVICE_MODEL = m.MODEL_NAME
  WHERE d.OPERATIONAL_STATUS = 'Active'
),
HISTORY AS (
  SELECT
    t.DEVICE_ID,
    MIN(IFF(t.TEMPERATURE_F > th.TEMP_WARNING_THRESHOLD_F OR t.POWER_CONSUMPTION_W > th.POWER_WARNING_THRESHOLD_W, t.TIMESTAMP, NULL)) AS FIRST_WARNING_TS,
    MIN(IFF(t.TEMPERATURE_F > th.TEMP_CRITICAL_THRESHOLD_F OR t.POWER_CONSUMPTION_W > th.POWER_CRITICAL_THRESHOLD_W, t.TIMESTAMP, NULL)) AS FIRST_CRITICAL_TS
  FROM RAW_DATA.SCREEN_TELEMETRY t
  JOIN THRESHOLDS th ON t.DEVICE_ID = th.DEVICE_ID
  WHERE t.TIMESTAMP >= DATEADD('day', - (SELECT HISTORY_DAYS FROM OPERATIONS.V_DEMO_TIME), (SELECT DEMO_AS_OF_TS FROM OPERATIONS.V_DEMO_TIME))
    AND t.TIMESTAMP < (SELECT DEMO_AS_OF_TS FROM OPERATIONS.V_DEMO_TIME)
  GROUP BY t.DEVICE_ID
)
SELECT
  th.DEVICE_ID,
  th.DEVICE_MODEL,
  h.FIRST_WARNING_TS,
  h.FIRST_CRITICAL_TS,
  DATEDIFF('hour', h.FIRST_WARNING_TS, h.FIRST_CRITICAL_TS) AS HOURS_WARNING_TO_CRITICAL,
  DATEDIFF('hour', h.FIRST_WARNING_TS, (SELECT DEMO_AS_OF_TS FROM OPERATIONS.V_DEMO_TIME)) AS HOURS_SINCE_FIRST_WARNING
FROM THRESHOLDS th
LEFT JOIN HISTORY h ON th.DEVICE_ID = h.DEVICE_ID;

CREATE OR REPLACE VIEW ANALYTICS.V_BASELINE_METRICS AS
SELECT
  (SELECT DEMO_AS_OF_TS FROM OPERATIONS.V_DEMO_TIME) AS AS_OF,
  COUNT(*) AS FLEET_SIZE,
  SUM(IFF(TEMP_STATUS = 'CRITICAL' OR POWER_STATUS = 'CRITICAL', 1, 0)) AS DEVICES_CRITICAL,
  SUM(IFF((TEMP_STATUS = 'WARNING' OR POWER_STATUS = 'WARNING') AND NOT (TEMP_STATUS = 'CRITICAL' OR POWER_STATUS = 'CRITICAL'), 1, 0)) AS DEVICES_WARNING,
  SUM(IFF(TEMP_STATUS = 'NORMAL' AND POWER_STATUS = 'NORMAL', 1, 0)) AS DEVICES_HEALTHY,
  -- Workload proxies (no cost assumptions):
  COUNT(*) * 10 AS CHARTS_TO_REVIEW_IF_MANUAL, -- ~10 key metrics per device
  SUM(IFF(TEMP_STATUS IN ('WARNING','CRITICAL') OR POWER_STATUS IN ('WARNING','CRITICAL'), 1, 0)) AS DEVICES_REQUIRING_REVIEW_TODAY
FROM RAW_DATA.V_DEVICE_HEALTH_SUMMARY;
/*----------------------------------------------------------------------------
  SUCCESS MESSAGE
----------------------------------------------------------------------------*/
SELECT 'Database setup complete ✅' AS STATUS,
       'Tables created: DEVICE_INVENTORY, SCREEN_TELEMETRY, MAINTENANCE_HISTORY' AS NEXT_STEP,
       'Run 01_generate_sample_data.sql next' AS ACTION;

