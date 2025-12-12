/*============================================================================
  ACT 1: SYNTHETIC DATA GENERATION
  
  Purpose: Generate realistic device fleet data with telemetry patterns
  
  What this creates:
  - 100 devices across various locations
  - 30 days of telemetry data (every 5 minutes)
  - Realistic patterns including:
    * 90 healthy devices with normal variation
    * 8 devices with minor anomalies
    * 2 devices with clear degradation patterns (including #4532)
  
  Run this after 01_setup_database.sql
============================================================================*/

USE DATABASE PREDICTIVE_MAINTENANCE;
USE SCHEMA RAW_DATA;

/*----------------------------------------------------------------------------
  STEP 1: Generate Device Inventory (100 devices)
----------------------------------------------------------------------------*/

-- Note: Snowflake's RANDOM() is pseudo-random and does not support seeding
-- Each run will generate slightly different values, but patterns remain consistent

-- Generate 100 devices across US locations
INSERT INTO DEVICE_INVENTORY 
(DEVICE_ID, DEVICE_MODEL, MANUFACTURER, INSTALLATION_DATE, LOCATION_ID, 
 FACILITY_NAME, FACILITY_CITY, FACILITY_STATE, LATITUDE, LONGITUDE,
 ENVIRONMENT_TYPE, HARDWARE_VERSION, FIRMWARE_VERSION, WARRANTY_STATUS,
 LAST_MAINTENANCE_DATE, OPERATIONAL_STATUS)
WITH SEQUENCE_GEN AS (
    SELECT ROW_NUMBER() OVER (ORDER BY NULL) AS SEQ
    FROM TABLE(GENERATOR(ROWCOUNT => 100))
)
SELECT
    -- Device IDs: 4001-4100 (with 4532 as our problem device)
    CASE 
        WHEN SEQ <= 32 THEN 4500 + SEQ
        WHEN SEQ = 33 THEN 4532  -- Our "sick" device
        WHEN SEQ <= 66 THEN 4500 + SEQ
        WHEN SEQ = 67 THEN 7821  -- Second problem device
        ELSE 4500 + SEQ
    END AS DEVICE_ID,
    
    -- Device models (varied distribution)
    CASE (SEQ % 4)
        WHEN 0 THEN 'Samsung DM55E'
        WHEN 1 THEN 'LG 55XS4F'
        WHEN 2 THEN 'NEC P554'
        ELSE 'Philips 55BDL4050D'
    END AS DEVICE_MODEL,
    
    CASE (SEQ % 4)
        WHEN 0 THEN 'Samsung'
        WHEN 1 THEN 'LG'
        WHEN 2 THEN 'NEC'
        ELSE 'Philips'
    END AS MANUFACTURER,
    
    -- Installation dates (1-4 years ago, older devices more likely to fail)
    CASE 
        WHEN SEQ = 33 THEN DATEADD('day', -1065, CURRENT_DATE())  -- 4532: ~2.9 years old
        WHEN SEQ = 67 THEN DATEADD('day', -950, CURRENT_DATE())   -- 7821: ~2.6 years old
        ELSE DATEADD('day', -(UNIFORM(365, 1460, RANDOM())), CURRENT_DATE())
    END AS INSTALLATION_DATE,
    
    'LOC-' || LPAD(SEQ, 4, '0') AS LOCATION_ID,
    
    -- Facility names
    CASE (SEQ % 20)
        WHEN 0 THEN 'Oak Park Medical Center'
        WHEN 1 THEN 'Westside Family Clinic'
        WHEN 2 THEN 'Downtown Healthcare'
        WHEN 3 THEN 'Riverside Medical Group'
        WHEN 4 THEN 'Hillside Physicians'
        WHEN 5 THEN 'Lakefront Urgent Care'
        WHEN 6 THEN 'Parkview Family Practice'
        WHEN 7 THEN 'Metro Health Associates'
        WHEN 8 THEN 'Sunshine Pediatrics'
        WHEN 9 THEN 'Valley Medical Plaza'
        WHEN 10 THEN 'Crossroads Healthcare'
        WHEN 11 THEN 'Summit Medical Center'
        WHEN 12 THEN 'Bayshore Clinic'
        WHEN 13 THEN 'Greenfield Family Medicine'
        WHEN 14 THEN 'Highland Medical Group'
        WHEN 15 THEN 'Oceanview Health Center'
        WHEN 16 THEN 'Prairie Family Clinic'
        WHEN 17 THEN 'Mountain View Medical'
        WHEN 18 THEN 'Riverside Urgent Care'
        ELSE 'Central Healthcare Associates'
    END AS FACILITY_NAME,
    
    -- Cities (distributed across US)
    CASE (SEQ % 15)
        WHEN 0 THEN 'Chicago'
        WHEN 1 THEN 'Miami'
        WHEN 2 THEN 'Seattle'
        WHEN 3 THEN 'Austin'
        WHEN 4 THEN 'Boston'
        WHEN 5 THEN 'Denver'
        WHEN 6 THEN 'Phoenix'
        WHEN 7 THEN 'Portland'
        WHEN 8 THEN 'Atlanta'
        WHEN 9 THEN 'San Diego'
        WHEN 10 THEN 'Dallas'
        WHEN 11 THEN 'Nashville'
        WHEN 12 THEN 'Charlotte'
        WHEN 13 THEN 'Minneapolis'
        ELSE 'Philadelphia'
    END AS FACILITY_CITY,
    
    CASE (SEQ % 15)
        WHEN 0 THEN 'IL'
        WHEN 1 THEN 'FL'
        WHEN 2 THEN 'WA'
        WHEN 3 THEN 'TX'
        WHEN 4 THEN 'MA'
        WHEN 5 THEN 'CO'
        WHEN 6 THEN 'AZ'
        WHEN 7 THEN 'OR'
        WHEN 8 THEN 'GA'
        WHEN 9 THEN 'CA'
        WHEN 10 THEN 'TX'
        WHEN 11 THEN 'TN'
        WHEN 12 THEN 'NC'
        WHEN 13 THEN 'MN'
        ELSE 'PA'
    END AS FACILITY_STATE,
    
    -- Approximate coordinates
    UNIFORM(25.0, 48.0, RANDOM()) AS LATITUDE,
    UNIFORM(-125.0, -70.0, RANDOM()) AS LONGITUDE,
    
    -- Environment types
    CASE 
        WHEN SEQ = 33 THEN 'Lobby'  -- 4532: High traffic area
        WHEN SEQ = 67 THEN 'Waiting Room'
        WHEN (SEQ % 4) = 0 THEN 'Lobby'
        WHEN (SEQ % 4) = 1 THEN 'Waiting Room'
        WHEN (SEQ % 4) = 2 THEN 'Exam Room'
        ELSE 'Hallway'
    END AS ENVIRONMENT_TYPE,
    
    'HW-v' || (2 + (SEQ % 3)) || '.0' AS HARDWARE_VERSION,
    
    -- Firmware versions (older versions more problematic)
    CASE 
        WHEN SEQ = 33 THEN 'v2.3.8'  -- 4532: Older firmware with known power issues
        WHEN SEQ < 20 THEN 'v2.4.1'  -- Newer firmware
        WHEN SEQ < 60 THEN 'v2.3.8'  -- Older firmware
        ELSE 'v2.4.0'
    END AS FIRMWARE_VERSION,
    
    CASE 
        WHEN SEQ = 33 THEN 'Expired'  -- 4532: Out of warranty
        WHEN SEQ = 67 THEN 'Expired'
        WHEN DATEDIFF('day', DATEADD('day', -(UNIFORM(365, 1460, RANDOM())), CURRENT_DATE()), CURRENT_DATE()) > 1095 
            THEN 'Expired'
        ELSE 'Active'
    END AS WARRANTY_STATUS,
    
    -- Last maintenance (60-180 days ago)
    CASE
        WHEN SEQ = 33 THEN DATEADD('day', -118, CURRENT_DATE())  -- 4532: Recent maintenance but still degrading
        ELSE DATEADD('day', -(UNIFORM(60, 180, RANDOM())), CURRENT_DATE())
    END AS LAST_MAINTENANCE_DATE,
    
    'Active' AS OPERATIONAL_STATUS
FROM SEQUENCE_GEN;

/*----------------------------------------------------------------------------
  STEP 2: Create stored procedure to generate telemetry data
  
  This generates 30 days of 5-minute interval data for all devices
  Total records: 100 devices × 8,640 records = 864,000 rows
----------------------------------------------------------------------------*/

CREATE OR REPLACE PROCEDURE GENERATE_TELEMETRY_DATA()
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
    days_of_history INT DEFAULT 30;
    interval_minutes INT DEFAULT 5;
    total_intervals INT;
BEGIN
    -- Calculate total intervals
    total_intervals := (days_of_history * 24 * 60) / interval_minutes;
    
    -- Generate telemetry for all devices
    INSERT INTO SCREEN_TELEMETRY 
    (DEVICE_ID, TIMESTAMP, TEMPERATURE_F, AMBIENT_TEMP_F, POWER_CONSUMPTION_W, 
     VOLTAGE, CPU_USAGE_PCT, MEMORY_USAGE_PCT, DISK_USAGE_PCT,
     BRIGHTNESS_LEVEL, SCREEN_ON_HOURS, NETWORK_LATENCY_MS, PACKET_LOSS_PCT,
     BANDWIDTH_MBPS, ERROR_COUNT, WARNING_COUNT, UPTIME_HOURS, DATA_QUALITY_SCORE)
    SELECT
        d.DEVICE_ID,
        
        -- Timestamp (every 5 minutes for 30 days)
        DATEADD('minute', -(SEQ * :interval_minutes), CURRENT_TIMESTAMP()) AS TIMESTAMP,
        
        -- Temperature: Varies by device health status
        CASE 
            -- Device 4532: Power supply degradation (temperature climbing over last 7 days)
            WHEN d.DEVICE_ID = '4532' THEN
                CASE 
                    WHEN SEQ < (7 * 24 * 12) THEN  -- Last 7 days
                        m.TYPICAL_TEMP_F + 
                        UNIFORM(-3, 3, RANDOM()) +  -- Normal noise
                        ((7 * 24 * 12) - SEQ) * 0.003  -- Linear climb (0.003°F per 5-min interval = ~25° over 7 days)
                    ELSE  -- Before degradation started
                        m.TYPICAL_TEMP_F + UNIFORM(-3, 3, RANDOM())
                END
            
            -- Device 7821: Display panel issue (temperature normal, other symptoms)
            WHEN d.DEVICE_ID = '7821' THEN
                m.TYPICAL_TEMP_F + UNIFORM(-2, 2, RANDOM())
            
            -- Minor anomaly devices (slightly elevated but not critical)
            WHEN d.DEVICE_ID IN ('4505', '4512', '4523', '4534', '4545', '4556', '4567', '4578') THEN
                m.TYPICAL_TEMP_F + UNIFORM(-2, 5, RANDOM())  -- Occasionally warmer
                
            -- Normal devices
            ELSE m.TYPICAL_TEMP_F + UNIFORM(-3, 3, RANDOM())
        END AS TEMPERATURE_F,
        
        -- Ambient temperature (seasonal variation)
        70 + 
        (SIN((SEQ / (:total_intervals * 1.0)) * 2 * PI()) * 5) +  -- Seasonal wave
        UNIFORM(-2, 2, RANDOM()) AS AMBIENT_TEMP_F,
        
        -- Power consumption: Correlates with temperature for power supply issues
        CASE 
            -- Device 4532: Power spikes correlating with temperature
            WHEN d.DEVICE_ID = '4532' THEN
                CASE 
                    WHEN SEQ < (7 * 24 * 12) THEN
                        m.TYPICAL_POWER_W + 
                        UNIFORM(-5, 10, RANDOM()) +
                        ((7 * 24 * 12) - SEQ) * 0.014 +  -- Climbing power (120W increase over 7 days)
                        (CASE WHEN UNIFORM(0, 100, RANDOM()) < 20 THEN UNIFORM(20, 50, RANDOM()) ELSE 0 END)  -- Random spikes
                    ELSE
                        m.TYPICAL_POWER_W + UNIFORM(-5, 10, RANDOM())
                END
            
            -- Normal devices
            ELSE m.TYPICAL_POWER_W + UNIFORM(-10, 15, RANDOM())
        END AS POWER_CONSUMPTION_W,
        
        -- Voltage (normally stable)
        120 + UNIFORM(-2, 2, RANDOM()) AS VOLTAGE,
        
        -- CPU usage (normal variation)
        CASE 
            WHEN d.DEVICE_ID = '4532' AND SEQ < (7 * 24 * 12) THEN
                UNIFORM(30, 70, RANDOM())  -- Higher CPU due to system stress
            ELSE UNIFORM(15, 45, RANDOM())
        END AS CPU_USAGE_PCT,
        
        -- Memory usage
        UNIFORM(40, 70, RANDOM()) AS MEMORY_USAGE_PCT,
        
        -- Disk usage (slowly growing)
        50 + ((:total_intervals - SEQ) / (:total_intervals * 1.0)) * 15 AS DISK_USAGE_PCT,
        
        -- Brightness (business hours vs. night)
        CASE 
            WHEN HOUR(DATEADD('minute', -(SEQ * :interval_minutes), CURRENT_TIMESTAMP())) BETWEEN 7 AND 19 
                THEN 85 
            ELSE 30  -- Dimmed at night
        END AS BRIGHTNESS_LEVEL,
        
        -- Screen on hours (cumulative)
        (:total_intervals - SEQ) * (:interval_minutes / 60.0) AS SCREEN_ON_HOURS,
        
        -- Network latency
        15 + UNIFORM(-5, 15, RANDOM()) + 
        (CASE WHEN UNIFORM(0, 100, RANDOM()) < 5 THEN UNIFORM(50, 200, RANDOM()) ELSE 0 END) AS NETWORK_LATENCY_MS,
        
        -- Packet loss (normally near zero)
        CASE 
            WHEN UNIFORM(0, 100, RANDOM()) < 95 THEN UNIFORM(0.0, 0.5, RANDOM())
            ELSE UNIFORM(1.0, 10.0, RANDOM())
        END AS PACKET_LOSS_PCT,
        
        -- Bandwidth
        UNIFORM(2, 15, RANDOM()) AS BANDWIDTH_MBPS,
        
        -- Error count: Increases with device stress
        CASE 
            WHEN d.DEVICE_ID = '4532' AND SEQ < (7 * 24 * 12) THEN
                FLOOR(UNIFORM(5, 15, RANDOM()) + ((7 * 24 * 12) - SEQ) * 0.001)
            WHEN d.DEVICE_ID IN ('4505', '4512', '4523') THEN
                FLOOR(UNIFORM(1, 4, RANDOM()))
            ELSE 
                FLOOR(UNIFORM(0, 2, RANDOM()))
        END AS ERROR_COUNT,
        
        -- Warning count
        CASE 
            WHEN d.DEVICE_ID = '4532' AND SEQ < (7 * 24 * 12) THEN
                FLOOR(UNIFORM(2, 8, RANDOM()))
            ELSE FLOOR(UNIFORM(0, 3, RANDOM()))
        END AS WARNING_COUNT,
        
        -- Uptime hours (resets occasionally)
        (SEQ * :interval_minutes / 60.0) % 720 AS UPTIME_HOURS,  -- Resets every 30 days
        
        -- Data quality (normally high)
        0.95 + UNIFORM(0, 0.05, RANDOM()) AS DATA_QUALITY_SCORE
        
    FROM DEVICE_INVENTORY d
    CROSS JOIN (
        SELECT ROW_NUMBER() OVER (ORDER BY NULL) AS SEQ
        FROM TABLE(GENERATOR(ROWCOUNT => :total_intervals))
    ) AS g
    LEFT JOIN DEVICE_MODELS_REFERENCE m ON d.DEVICE_MODEL = m.MODEL_NAME
    WHERE d.OPERATIONAL_STATUS = 'Active';
    
    RETURN 'Telemetry data generated: ' || total_intervals || ' intervals × ' || 
           (SELECT COUNT(*) FROM DEVICE_INVENTORY WHERE OPERATIONAL_STATUS = 'Active') || 
           ' devices = ' || (total_intervals * (SELECT COUNT(*) FROM DEVICE_INVENTORY WHERE OPERATIONAL_STATUS = 'Active')) || ' records';
END;
$$;

/*----------------------------------------------------------------------------
  STEP 3: Execute the data generation
----------------------------------------------------------------------------*/

-- This will take 30-60 seconds to generate ~864,000 records
CALL GENERATE_TELEMETRY_DATA();

/*----------------------------------------------------------------------------
  STEP 4: Generate historical maintenance records
----------------------------------------------------------------------------*/

INSERT INTO MAINTENANCE_HISTORY
(MAINTENANCE_ID, DEVICE_ID, INCIDENT_DATE, INCIDENT_TYPE, FAILURE_TYPE,
 FAILURE_SYMPTOMS, RESOLUTION_TYPE, RESOLUTION_DATE, RESOLUTION_TIME_HOURS,
 ACTIONS_TAKEN, REMOTE_FIX_ATTEMPTED, REMOTE_FIX_SUCCESSFUL,
 PARTS_REPLACED, LABOR_COST_USD, PARTS_COST_USD, TRAVEL_COST_USD, TOTAL_COST_USD,
 DOWNTIME_HOURS, REVENUE_IMPACT_USD, CUSTOMER_NOTIFIED, ROOT_CAUSE, PREVENTABLE)
WITH SEQUENCE_GEN AS (
    SELECT ROW_NUMBER() OVER (ORDER BY NULL) AS SEQ
    FROM TABLE(GENERATOR(ROWCOUNT => 150))
)
SELECT
    'M-2025-' || LPAD(SEQ, 5, '0') AS MAINTENANCE_ID,
    
    -- Random device from inventory
    (SELECT DEVICE_ID FROM DEVICE_INVENTORY ORDER BY RANDOM() LIMIT 1) AS DEVICE_ID,
    
    -- Incident dates over past 18 months
    DATEADD('day', -(UNIFORM(1, 540, RANDOM())), CURRENT_DATE()) AS INCIDENT_DATE,
    
    -- Incident types
    CASE (SEQ % 3)
        WHEN 0 THEN 'Preventive'
        WHEN 1 THEN 'Corrective'
        ELSE 'Predictive'
    END AS INCIDENT_TYPE,
    
    -- Failure types (distribution reflects reality)
    CASE (SEQ % 10)
        WHEN 0 THEN 'Power Supply'
        WHEN 1 THEN 'Power Supply'
        WHEN 2 THEN 'Display Panel'
        WHEN 3 THEN 'Software Crash'
        WHEN 4 THEN 'Software Crash'
        WHEN 5 THEN 'Network Connectivity'
        WHEN 6 THEN 'Configuration Issue'
        WHEN 7 THEN 'Firmware Bug'
        WHEN 8 THEN 'Overheating'
        ELSE 'Hardware - Other'
    END AS FAILURE_TYPE,
    
    -- Symptoms (for similarity search later)
    CASE (SEQ % 10)
        WHEN 0 THEN 'Temperature climbing, power consumption spiking, voltage regulation warnings'
        WHEN 1 THEN 'Intermittent power cycling, unusual power draw patterns'
        WHEN 2 THEN 'Screen flickering, brightness dropping, display artifacts'
        WHEN 3 THEN 'Application crashes, system reboots, frozen screen'
        WHEN 4 THEN 'Unresponsive interface, high CPU usage, memory errors'
        WHEN 5 THEN 'Connection drops, high latency, unable to reach content server'
        WHEN 6 THEN 'Content not displaying correctly, wrong resolution settings'
        WHEN 7 THEN 'Random reboots after firmware update, boot loops'
        WHEN 8 THEN 'High internal temperature, fan noise, thermal shutdowns'
        ELSE 'General hardware malfunction'
    END AS FAILURE_SYMPTOMS,
    
    -- Resolution type (68% remote success for power, lower for hardware)
    CASE 
        WHEN (SEQ % 10) IN (0, 1) THEN  -- Power supply issues
            CASE WHEN UNIFORM(0, 100, RANDOM()) < 68 THEN 'Remote Fix' ELSE 'Part Replacement' END
        WHEN (SEQ % 10) = 2 THEN 'Part Replacement'  -- Display always needs replacement
        WHEN (SEQ % 10) IN (3, 4) THEN  -- Software issues
            CASE WHEN UNIFORM(0, 100, RANDOM()) < 94 THEN 'Remote Fix' ELSE 'Field Service' END
        WHEN (SEQ % 10) = 5 THEN  -- Network
            CASE WHEN UNIFORM(0, 100, RANDOM()) < 81 THEN 'Remote Fix' ELSE 'Field Service' END
        ELSE 'Remote Fix'
    END AS RESOLUTION_TYPE,
    
    DATEADD('hour', UNIFORM(1, 48, RANDOM()), DATEADD('day', -(UNIFORM(1, 540, RANDOM())), CURRENT_DATE())) AS RESOLUTION_DATE,
    
    -- Resolution time based on type
    CASE 
        WHEN (SEQ % 10) IN (0, 1) AND UNIFORM(0, 100, RANDOM()) < 68 THEN UNIFORM(0.15, 0.5, RANDOM())  -- Remote: 9-30 min
        WHEN (SEQ % 10) = 2 THEN UNIFORM(24, 72, RANDOM())  -- Hardware replacement
        WHEN (SEQ % 10) IN (3, 4, 5) THEN UNIFORM(0.1, 1, RANDOM())  -- Software/network remote
        ELSE UNIFORM(12, 48, RANDOM())
    END AS RESOLUTION_TIME_HOURS,
    
    -- Actions taken
    CASE (SEQ % 10)
        WHEN 0 THEN 'Remote restart, firmware update v2.4.1, power management config reset'
        WHEN 1 THEN 'Replaced power supply unit (PSU-500W)'
        WHEN 2 THEN 'Replaced display panel'
        WHEN 3 THEN 'Remote restart, cleared cache, updated application'
        WHEN 4 THEN 'System reset, reinstalled OS, restored configuration'
        WHEN 5 THEN 'Network config reset, DNS update, bandwidth test'
        WHEN 6 THEN 'Remote configuration update, display settings adjusted'
        WHEN 7 THEN 'Rolled back firmware to stable version v2.3.9'
        WHEN 8 THEN 'Cleaned ventilation, applied thermal paste, fan replacement'
        ELSE 'General maintenance and inspection'
    END AS ACTIONS_TAKEN,
    
    -- Remote fix attempted
    TRUE AS REMOTE_FIX_ATTEMPTED,
    
    -- Success based on resolution type
    CASE 
        WHEN (SEQ % 10) IN (0, 1) AND UNIFORM(0, 100, RANDOM()) < 68 THEN TRUE
        WHEN (SEQ % 10) = 2 THEN FALSE
        WHEN (SEQ % 10) IN (3, 4) AND UNIFORM(0, 100, RANDOM()) < 94 THEN TRUE
        WHEN (SEQ % 10) = 5 AND UNIFORM(0, 100, RANDOM()) < 81 THEN TRUE
        ELSE UNIFORM(0, 100, RANDOM()) < 50
    END AS REMOTE_FIX_SUCCESSFUL,
    
    -- Parts replaced
    CASE 
        WHEN (SEQ % 10) = 1 THEN 'Power Supply Unit (PSU-500W)'
        WHEN (SEQ % 10) = 2 THEN 'Display Panel'
        WHEN (SEQ % 10) = 8 THEN 'Cooling Fan'
        ELSE NULL
    END AS PARTS_REPLACED,
    
    -- Costs
    CASE WHEN (SEQ % 10) IN (0, 3, 4, 5, 6, 7) THEN 0 ELSE UNIFORM(100, 150, RANDOM()) END AS LABOR_COST_USD,
    CASE 
        WHEN (SEQ % 10) = 1 THEN 280
        WHEN (SEQ % 10) = 2 THEN 450
        WHEN (SEQ % 10) = 8 THEN 60
        ELSE 0
    END AS PARTS_COST_USD,
    CASE WHEN (SEQ % 10) IN (0, 3, 4, 5, 6, 7) THEN 0 ELSE UNIFORM(50, 150, RANDOM()) END AS TRAVEL_COST_USD,
    
    CASE 
        WHEN (SEQ % 10) IN (0, 3, 4, 5, 6, 7) THEN 0  -- Remote fixes
        WHEN (SEQ % 10) = 1 THEN 280 + 120 + 100  -- PSU replacement
        WHEN (SEQ % 10) = 2 THEN 450 + 140 + 110  -- Display replacement
        WHEN (SEQ % 10) = 8 THEN 60 + 110 + 80
        ELSE UNIFORM(200, 500, RANDOM())
    END AS TOTAL_COST_USD,
    
    -- Downtime
    CASE 
        WHEN (SEQ % 10) IN (0, 3, 4, 5, 6, 7) THEN UNIFORM(0.15, 0.5, RANDOM())  -- Remote: minimal
        ELSE UNIFORM(2, 8, RANDOM())  -- Field service: hours
    END AS DOWNTIME_HOURS,
    
    -- Revenue impact ($97/hour average)
    CASE 
        WHEN (SEQ % 10) IN (0, 3, 4, 5, 6, 7) THEN UNIFORM(0.15, 0.5, RANDOM()) * 97
        ELSE UNIFORM(2, 8, RANDOM()) * 97
    END AS REVENUE_IMPACT_USD,
    
    TRUE AS CUSTOMER_NOTIFIED,
    
    -- Root cause
    CASE (SEQ % 10)
        WHEN 0 THEN 'Firmware v2.3.8 power management bug'
        WHEN 1 THEN 'End-of-life power supply component'
        WHEN 2 THEN 'Display backlight degradation'
        WHEN 3 THEN 'Memory leak in content player application'
        WHEN 4 THEN 'Corrupted system files'
        WHEN 5 THEN 'ISP routing issue'
        WHEN 6 THEN 'Incorrect configuration deployment'
        WHEN 7 THEN 'Known firmware regression'
        WHEN 8 THEN 'Inadequate ventilation in lobby environment'
        ELSE 'Unknown'
    END AS ROOT_CAUSE,
    
    -- Preventable
    CASE WHEN (SEQ % 10) IN (0, 6, 7, 8) THEN TRUE ELSE FALSE END AS PREVENTABLE
    
FROM SEQUENCE_GEN;

/*----------------------------------------------------------------------------
  VERIFICATION QUERIES
----------------------------------------------------------------------------*/

-- Check device count
SELECT 'Devices Created' AS METRIC, COUNT(*) AS VALUE 
FROM DEVICE_INVENTORY;

-- Check telemetry records
SELECT 'Telemetry Records' AS METRIC, COUNT(*) AS VALUE 
FROM SCREEN_TELEMETRY;

-- Check maintenance history
SELECT 'Maintenance Records' AS METRIC, COUNT(*) AS VALUE 
FROM MAINTENANCE_HISTORY;

-- Check Device 4532 status
SELECT 
    'Device 4532 Status Check' AS CHECK_TYPE,
    DEVICE_ID,
    DEVICE_MODEL,
    FACILITY_NAME,
    FACILITY_CITY,
    TEMP_STATUS,
    POWER_STATUS,
    TEMPERATURE_F,
    POWER_CONSUMPTION_W,
    ERROR_COUNT
FROM V_DEVICE_HEALTH_SUMMARY
WHERE DEVICE_ID = '4532';

-- Show devices by health status
SELECT 
    CASE 
        WHEN TEMP_STATUS = 'CRITICAL' OR POWER_STATUS = 'CRITICAL' THEN 'CRITICAL'
        WHEN TEMP_STATUS = 'WARNING' OR POWER_STATUS = 'WARNING' THEN 'WARNING'
        ELSE 'HEALTHY'
    END AS OVERALL_STATUS,
    COUNT(*) AS DEVICE_COUNT
FROM V_DEVICE_HEALTH_SUMMARY
GROUP BY OVERALL_STATUS
ORDER BY OVERALL_STATUS;

/*----------------------------------------------------------------------------
  SUCCESS MESSAGE
----------------------------------------------------------------------------*/
SELECT 
    '✅ Act 1 Data Generation Complete!' AS STATUS,
    'You now have 100 devices with 30 days of telemetry' AS SUMMARY,
    'Device 4532 shows degradation pattern (power supply issue)' AS KEY_FINDING,
    'Next: Build Streamlit monitoring dashboard' AS NEXT_STEP;

