/*******************************************************************************
 * PATIENTPOINT PREDICTIVE MAINTENANCE DEMO
 * Part 1: Database, Schema, and Sample Data Setup
 * 
 * This script creates the foundation for the AI Agent demo:
 * - Role setup (SF_INTELLIGENCE_DEMO)
 * - Database and schema
 * - Device inventory table
 * - Device telemetry (time-series health data)
 * - Maintenance history
 * - Troubleshooting knowledge base
 ******************************************************************************/

-- ============================================================================
-- ROLE SETUP
-- Run these commands as ACCOUNTADMIN or a role with CREATE ROLE privilege
-- ============================================================================

-- Create the demo role
USE ROLE ACCOUNTADMIN;

CREATE ROLE IF NOT EXISTS SF_INTELLIGENCE_DEMO
    COMMENT = 'Role for PatientPoint Predictive Maintenance Demo with Snowflake Intelligence';

-- Grant necessary account-level privileges
GRANT CREATE DATABASE ON ACCOUNT TO ROLE SF_INTELLIGENCE_DEMO;
GRANT CREATE WAREHOUSE ON ACCOUNT TO ROLE SF_INTELLIGENCE_DEMO;

-- Grant Cortex privileges (required for Cortex Search, Agents, etc.)
GRANT DATABASE ROLE SNOWFLAKE.CORTEX_USER TO ROLE SF_INTELLIGENCE_DEMO;

-- Grant the role to current user (adjust as needed)
GRANT ROLE SF_INTELLIGENCE_DEMO TO ROLE SYSADMIN;
-- GRANT ROLE SF_INTELLIGENCE_DEMO TO USER <your_username>;

-- ============================================================================
-- SWITCH TO DEMO ROLE FOR ALL SUBSEQUENT OPERATIONS
-- ============================================================================
USE ROLE SF_INTELLIGENCE_DEMO;

-- ============================================================================
-- WAREHOUSE SETUP (if needed)
-- ============================================================================
CREATE WAREHOUSE IF NOT EXISTS COMPUTE_WH
    WAREHOUSE_SIZE = 'MEDIUM'
    AUTO_SUSPEND = 300
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Warehouse for PatientPoint demo';

USE WAREHOUSE COMPUTE_WH;

-- ============================================================================
-- DATABASE AND SCHEMA SETUP
-- ============================================================================
CREATE DATABASE IF NOT EXISTS PATIENTPOINT_MAINTENANCE;

-- Grant ownership to the demo role
GRANT OWNERSHIP ON DATABASE PATIENTPOINT_MAINTENANCE TO ROLE SF_INTELLIGENCE_DEMO COPY CURRENT GRANTS;

USE DATABASE PATIENTPOINT_MAINTENANCE;

CREATE SCHEMA IF NOT EXISTS DEVICE_OPS;

-- Grant ownership to the demo role
GRANT OWNERSHIP ON SCHEMA PATIENTPOINT_MAINTENANCE.DEVICE_OPS TO ROLE SF_INTELLIGENCE_DEMO COPY CURRENT GRANTS;

USE SCHEMA DEVICE_OPS;

-- ============================================================================
-- DEVICE INVENTORY TABLE
-- All in-office screens deployed across healthcare facilities
-- ============================================================================
CREATE OR REPLACE TABLE DEVICE_INVENTORY (
    DEVICE_ID VARCHAR(20) PRIMARY KEY,
    DEVICE_MODEL VARCHAR(50),
    FACILITY_NAME VARCHAR(100),
    FACILITY_TYPE VARCHAR(50),
    LOCATION_CITY VARCHAR(50),
    LOCATION_STATE VARCHAR(2),
    INSTALL_DATE DATE,
    WARRANTY_EXPIRY DATE,
    LAST_MAINTENANCE_DATE DATE,
    FIRMWARE_VERSION VARCHAR(20),
    STATUS VARCHAR(20) DEFAULT 'ONLINE',  -- ONLINE, OFFLINE, DEGRADED, MAINTENANCE
    -- Revenue tracking fields
    HOURLY_AD_REVENUE_USD FLOAT DEFAULT 12.50,  -- Advertising revenue per hour when online
    MONTHLY_IMPRESSIONS INT DEFAULT 15000        -- Average monthly ad impressions
);

-- Insert sample device inventory (100 devices across various facilities)
INSERT INTO DEVICE_INVENTORY VALUES
    ('DEV-001', 'HealthScreen Pro 55', 'Downtown Medical Center', 'Hospital', 'Chicago', 'IL', '2023-01-15', '2026-01-15', '2024-06-01', 'v3.2.1', 'ONLINE'),
    ('DEV-002', 'HealthScreen Pro 55', 'Lakeside Family Practice', 'Primary Care', 'Chicago', 'IL', '2023-02-20', '2026-02-20', '2024-05-15', 'v3.2.1', 'ONLINE'),
    ('DEV-003', 'HealthScreen Lite 32', 'North Shore Pediatrics', 'Pediatrics', 'Evanston', 'IL', '2022-11-10', '2025-11-10', '2024-04-20', 'v3.1.8', 'DEGRADED'),
    ('DEV-004', 'HealthScreen Pro 55', 'Midwest Cardiology Associates', 'Specialty', 'Oak Park', 'IL', '2023-03-05', '2026-03-05', '2024-07-10', 'v3.2.1', 'ONLINE'),
    ('DEV-005', 'HealthScreen Lite 32', 'Springfield Urgent Care', 'Urgent Care', 'Springfield', 'IL', '2022-08-22', '2025-08-22', '2024-03-01', 'v3.0.5', 'OFFLINE'),
    ('DEV-006', 'HealthScreen Pro 55', 'Memorial Hospital West', 'Hospital', 'Columbus', 'OH', '2023-04-18', '2026-04-18', '2024-08-05', 'v3.2.1', 'ONLINE'),
    ('DEV-007', 'HealthScreen Max 65', 'Cleveland Clinic Annex', 'Hospital', 'Cleveland', 'OH', '2023-06-01', '2026-06-01', '2024-09-01', 'v3.2.2', 'ONLINE'),
    ('DEV-008', 'HealthScreen Lite 32', 'Buckeye Family Medicine', 'Primary Care', 'Columbus', 'OH', '2022-09-14', '2025-09-14', '2024-02-28', 'v3.1.2', 'DEGRADED'),
    ('DEV-009', 'HealthScreen Pro 55', 'Cincinnati Womens Health', 'OB/GYN', 'Cincinnati', 'OH', '2023-05-22', '2026-05-22', '2024-07-20', 'v3.2.1', 'ONLINE'),
    ('DEV-010', 'HealthScreen Pro 55', 'Dayton Orthopedic Center', 'Specialty', 'Dayton', 'OH', '2023-07-10', '2026-07-10', '2024-09-15', 'v3.2.1', 'ONLINE'),
    ('DEV-011', 'HealthScreen Max 65', 'Henry Ford Health Detroit', 'Hospital', 'Detroit', 'MI', '2023-01-08', '2026-01-08', '2024-05-01', 'v3.2.0', 'ONLINE'),
    ('DEV-012', 'HealthScreen Pro 55', 'Ann Arbor Family Care', 'Primary Care', 'Ann Arbor', 'MI', '2023-02-14', '2026-02-14', '2024-06-10', 'v3.2.1', 'ONLINE'),
    ('DEV-013', 'HealthScreen Lite 32', 'Grand Rapids Pediatrics', 'Pediatrics', 'Grand Rapids', 'MI', '2022-10-05', '2025-10-05', '2024-04-15', 'v3.1.5', 'ONLINE'),
    ('DEV-014', 'HealthScreen Pro 55', 'Lansing Cardiology Group', 'Specialty', 'Lansing', 'MI', '2023-04-01', '2026-04-01', '2024-08-01', 'v3.2.1', 'DEGRADED'),
    ('DEV-015', 'HealthScreen Lite 32', 'Kalamazoo Walk-In Clinic', 'Urgent Care', 'Kalamazoo', 'MI', '2022-07-20', '2025-07-20', '2024-01-15', 'v3.0.3', 'ONLINE'),
    ('DEV-016', 'HealthScreen Pro 55', 'IU Health Indianapolis', 'Hospital', 'Indianapolis', 'IN', '2023-03-12', '2026-03-12', '2024-07-05', 'v3.2.1', 'ONLINE'),
    ('DEV-017', 'HealthScreen Max 65', 'Fort Wayne Medical Center', 'Hospital', 'Fort Wayne', 'IN', '2023-05-08', '2026-05-08', '2024-09-10', 'v3.2.2', 'ONLINE'),
    ('DEV-018', 'HealthScreen Lite 32', 'Evansville Family Practice', 'Primary Care', 'Evansville', 'IN', '2022-12-01', '2025-12-01', '2024-05-20', 'v3.1.8', 'OFFLINE'),
    ('DEV-019', 'HealthScreen Pro 55', 'South Bend Womens Clinic', 'OB/GYN', 'South Bend', 'IN', '2023-06-15', '2026-06-15', '2024-08-25', 'v3.2.1', 'ONLINE'),
    ('DEV-020', 'HealthScreen Lite 32', 'Bloomington Urgent Care', 'Urgent Care', 'Bloomington', 'IN', '2022-08-10', '2025-08-10', '2024-02-10', 'v3.0.8', 'DEGRADED'),
    ('DEV-021', 'HealthScreen Pro 55', 'Aurora Health Milwaukee', 'Hospital', 'Milwaukee', 'WI', '2023-02-28', '2026-02-28', '2024-06-20', 'v3.2.1', 'ONLINE'),
    ('DEV-022', 'HealthScreen Max 65', 'UW Health Madison', 'Hospital', 'Madison', 'WI', '2023-04-10', '2026-04-10', '2024-08-15', 'v3.2.2', 'ONLINE'),
    ('DEV-023', 'HealthScreen Lite 32', 'Green Bay Pediatrics', 'Pediatrics', 'Green Bay', 'WI', '2022-09-25', '2025-09-25', '2024-03-25', 'v3.1.3', 'ONLINE'),
    ('DEV-024', 'HealthScreen Pro 55', 'Kenosha Heart Center', 'Specialty', 'Kenosha', 'WI', '2023-05-05', '2026-05-05', '2024-09-01', 'v3.2.1', 'ONLINE'),
    ('DEV-025', 'HealthScreen Lite 32', 'Appleton Walk-In Care', 'Urgent Care', 'Appleton', 'WI', '2022-06-18', '2025-06-18', '2024-01-05', 'v3.0.2', 'DEGRADED'),
    ('DEV-026', 'HealthScreen Pro 55', 'Mayo Clinic Rochester', 'Hospital', 'Rochester', 'MN', '2023-01-20', '2026-01-20', '2024-05-25', 'v3.2.1', 'ONLINE'),
    ('DEV-027', 'HealthScreen Max 65', 'Hennepin Healthcare', 'Hospital', 'Minneapolis', 'MN', '2023-03-15', '2026-03-15', '2024-07-15', 'v3.2.2', 'ONLINE'),
    ('DEV-028', 'HealthScreen Lite 32', 'St Paul Family Medicine', 'Primary Care', 'St Paul', 'MN', '2022-10-20', '2025-10-20', '2024-04-10', 'v3.1.6', 'ONLINE'),
    ('DEV-029', 'HealthScreen Pro 55', 'Duluth Womens Health', 'OB/GYN', 'Duluth', 'MN', '2023-06-01', '2026-06-01', '2024-08-20', 'v3.2.1', 'ONLINE'),
    ('DEV-030', 'HealthScreen Lite 32', 'Bloomington MN Urgent Care', 'Urgent Care', 'Bloomington', 'MN', '2022-07-08', '2025-07-08', '2024-01-20', 'v3.0.4', 'ONLINE');

-- Add more devices to reach ~100 for a realistic demo
INSERT INTO DEVICE_INVENTORY 
SELECT 
    'DEV-' || LPAD((SEQ4() + 31)::VARCHAR, 3, '0'),
    CASE MOD(SEQ4(), 3) 
        WHEN 0 THEN 'HealthScreen Pro 55'
        WHEN 1 THEN 'HealthScreen Lite 32'
        ELSE 'HealthScreen Max 65'
    END,
    'Healthcare Facility ' || (SEQ4() + 31),
    CASE MOD(SEQ4(), 5)
        WHEN 0 THEN 'Hospital'
        WHEN 1 THEN 'Primary Care'
        WHEN 2 THEN 'Specialty'
        WHEN 3 THEN 'Urgent Care'
        ELSE 'Pediatrics'
    END,
    CASE MOD(SEQ4(), 6)
        WHEN 0 THEN 'Chicago'
        WHEN 1 THEN 'Detroit'
        WHEN 2 THEN 'Cleveland'
        WHEN 3 THEN 'Indianapolis'
        WHEN 4 THEN 'Milwaukee'
        ELSE 'Minneapolis'
    END,
    CASE MOD(SEQ4(), 6)
        WHEN 0 THEN 'IL'
        WHEN 1 THEN 'MI'
        WHEN 2 THEN 'OH'
        WHEN 3 THEN 'IN'
        WHEN 4 THEN 'WI'
        ELSE 'MN'
    END,
    DATEADD('day', -1 * (SEQ4() * 7 + 100), CURRENT_DATE()),
    DATEADD('year', 3, DATEADD('day', -1 * (SEQ4() * 7 + 100), CURRENT_DATE())),
    DATEADD('day', -1 * MOD(SEQ4() * 17, 180), CURRENT_DATE()),
    'v3.' || MOD(SEQ4(), 3)::VARCHAR || '.' || MOD(SEQ4(), 10)::VARCHAR,
    CASE 
        WHEN MOD(SEQ4(), 15) = 0 THEN 'OFFLINE'
        WHEN MOD(SEQ4(), 8) = 0 THEN 'DEGRADED'
        ELSE 'ONLINE'
    END
FROM TABLE(GENERATOR(ROWCOUNT => 70));

-- ============================================================================
-- DEVICE TELEMETRY TABLE
-- Real-time health metrics from each device (IoT data)
-- ============================================================================
CREATE OR REPLACE TABLE DEVICE_TELEMETRY (
    TELEMETRY_ID VARCHAR(36) DEFAULT UUID_STRING(),
    DEVICE_ID VARCHAR(20),
    TIMESTAMP TIMESTAMP_NTZ,
    CPU_TEMP_CELSIUS FLOAT,
    CPU_USAGE_PCT FLOAT,
    MEMORY_USAGE_PCT FLOAT,
    DISK_USAGE_PCT FLOAT,
    NETWORK_LATENCY_MS FLOAT,
    DISPLAY_BRIGHTNESS_PCT FLOAT,
    UPTIME_HOURS FLOAT,
    ERROR_COUNT INT,
    LAST_HEARTBEAT TIMESTAMP_NTZ,
    CONSTRAINT fk_device FOREIGN KEY (DEVICE_ID) REFERENCES DEVICE_INVENTORY(DEVICE_ID)
);

-- Generate telemetry data for the past 30 days
-- This simulates real IoT sensor data with some devices showing degradation patterns
INSERT INTO DEVICE_TELEMETRY (DEVICE_ID, TIMESTAMP, CPU_TEMP_CELSIUS, CPU_USAGE_PCT, MEMORY_USAGE_PCT, 
                               DISK_USAGE_PCT, NETWORK_LATENCY_MS, DISPLAY_BRIGHTNESS_PCT, 
                               UPTIME_HOURS, ERROR_COUNT, LAST_HEARTBEAT)
SELECT 
    d.DEVICE_ID,
    DATEADD('hour', -1 * t.SEQ, CURRENT_TIMESTAMP()) as TIMESTAMP,
    -- CPU temp: normally 45-55, degraded devices run hotter
    CASE 
        WHEN d.STATUS = 'DEGRADED' THEN 55 + (RANDOM() / POW(10, 18)) * 20
        WHEN d.STATUS = 'OFFLINE' THEN 70 + (RANDOM() / POW(10, 18)) * 15
        ELSE 42 + (RANDOM() / POW(10, 18)) * 13
    END as CPU_TEMP_CELSIUS,
    -- CPU usage: normally 15-40%, degraded higher
    CASE 
        WHEN d.STATUS = 'DEGRADED' THEN 60 + (RANDOM() / POW(10, 18)) * 35
        WHEN d.STATUS = 'OFFLINE' THEN 85 + (RANDOM() / POW(10, 18)) * 15
        ELSE 15 + (RANDOM() / POW(10, 18)) * 25
    END as CPU_USAGE_PCT,
    -- Memory usage
    CASE 
        WHEN d.STATUS = 'DEGRADED' THEN 70 + (RANDOM() / POW(10, 18)) * 25
        ELSE 30 + (RANDOM() / POW(10, 18)) * 40
    END as MEMORY_USAGE_PCT,
    -- Disk usage
    40 + (RANDOM() / POW(10, 18)) * 45 as DISK_USAGE_PCT,
    -- Network latency: normally 10-50ms, issues cause spikes
    CASE 
        WHEN d.STATUS IN ('DEGRADED', 'OFFLINE') THEN 100 + (RANDOM() / POW(10, 18)) * 400
        ELSE 10 + (RANDOM() / POW(10, 18)) * 40
    END as NETWORK_LATENCY_MS,
    -- Display brightness
    70 + (RANDOM() / POW(10, 18)) * 30 as DISPLAY_BRIGHTNESS_PCT,
    -- Uptime hours since last reboot
    24 + (RANDOM() / POW(10, 18)) * 720 as UPTIME_HOURS,
    -- Error count
    CASE 
        WHEN d.STATUS = 'DEGRADED' THEN FLOOR((RANDOM() / POW(10, 18)) * 15)
        WHEN d.STATUS = 'OFFLINE' THEN FLOOR((RANDOM() / POW(10, 18)) * 50)
        ELSE FLOOR((RANDOM() / POW(10, 18)) * 3)
    END as ERROR_COUNT,
    DATEADD('minute', -1 * FLOOR((RANDOM() / POW(10, 18)) * 5), DATEADD('hour', -1 * t.SEQ, CURRENT_TIMESTAMP())) as LAST_HEARTBEAT
FROM DEVICE_INVENTORY d
CROSS JOIN (SELECT SEQ4() as SEQ FROM TABLE(GENERATOR(ROWCOUNT => 720))) t  -- 30 days * 24 hours
WHERE t.SEQ < 720;

-- ============================================================================
-- MAINTENANCE HISTORY TABLE
-- Past service tickets and resolutions
-- ============================================================================
CREATE OR REPLACE TABLE MAINTENANCE_HISTORY (
    TICKET_ID VARCHAR(20) PRIMARY KEY,
    DEVICE_ID VARCHAR(20),
    CREATED_AT TIMESTAMP_NTZ,
    RESOLVED_AT TIMESTAMP_NTZ,
    ISSUE_TYPE VARCHAR(50),
    ISSUE_DESCRIPTION TEXT,
    RESOLUTION_TYPE VARCHAR(30),  -- REMOTE_FIX, FIELD_DISPATCH, REPLACEMENT
    RESOLUTION_NOTES TEXT,
    TECHNICIAN_ID VARCHAR(20),
    COST_USD FLOAT,
    CONSTRAINT fk_device_maint FOREIGN KEY (DEVICE_ID) REFERENCES DEVICE_INVENTORY(DEVICE_ID)
);

-- Insert realistic maintenance history
INSERT INTO MAINTENANCE_HISTORY VALUES
    ('TKT-2024-001', 'DEV-003', '2024-09-15 08:30:00', '2024-09-15 09:15:00', 'DISPLAY_FREEZE', 'Screen frozen on splash screen, unresponsive to touch', 'REMOTE_FIX', 'Performed remote restart via agent. Display resumed normal operation.', 'REMOTE_AGENT', 0),
    ('TKT-2024-002', 'DEV-005', '2024-09-18 14:20:00', '2024-09-19 11:00:00', 'NO_NETWORK', 'Device offline, no heartbeat for 6 hours', 'FIELD_DISPATCH', 'Router failure at facility. Replaced ethernet cable and reset network config.', 'TECH-042', 185.00),
    ('TKT-2024-003', 'DEV-008', '2024-09-22 10:45:00', '2024-09-22 11:00:00', 'HIGH_CPU', 'CPU usage consistently above 90%, sluggish performance', 'REMOTE_FIX', 'Killed runaway process and cleared temp files. Scheduled firmware update.', 'REMOTE_AGENT', 0),
    ('TKT-2024-004', 'DEV-014', '2024-10-01 09:00:00', '2024-10-02 14:30:00', 'DISPLAY_FAILURE', 'Display showing vertical lines, hardware malfunction suspected', 'REPLACEMENT', 'Display panel replaced. Root cause: power surge damage.', 'TECH-018', 450.00),
    ('TKT-2024-005', 'DEV-018', '2024-10-05 16:30:00', '2024-10-06 10:00:00', 'BOOT_FAILURE', 'Device stuck in boot loop', 'FIELD_DISPATCH', 'Corrupted firmware. Reflashed via USB. Recommended UPS installation.', 'TECH-025', 210.00),
    ('TKT-2024-006', 'DEV-020', '2024-10-10 11:15:00', '2024-10-10 11:30:00', 'MEMORY_LEAK', 'Memory usage climbing to 95%, app crashes', 'REMOTE_FIX', 'Restarted application services and cleared cache. Issue resolved.', 'REMOTE_AGENT', 0),
    ('TKT-2024-007', 'DEV-025', '2024-10-15 08:00:00', '2024-10-15 08:20:00', 'CONNECTIVITY', 'Intermittent WiFi disconnections', 'REMOTE_FIX', 'Reset network adapter and updated WiFi driver remotely.', 'REMOTE_AGENT', 0),
    ('TKT-2024-008', 'DEV-003', '2024-10-20 13:45:00', '2024-10-21 09:30:00', 'DISPLAY_FREEZE', 'Recurring freeze issue, third occurrence this month', 'FIELD_DISPATCH', 'Replaced thermal paste and cleaned internal fans. Overheating was root cause.', 'TECH-042', 165.00),
    ('TKT-2024-009', 'DEV-012', '2024-10-25 10:00:00', '2024-10-25 10:10:00', 'SOFTWARE_UPDATE', 'Scheduled firmware update to v3.2.2', 'REMOTE_FIX', 'Successfully pushed firmware update remotely.', 'REMOTE_AGENT', 0),
    ('TKT-2024-010', 'DEV-007', '2024-11-01 14:00:00', '2024-11-01 14:15:00', 'DISPLAY_CALIBRATION', 'Touch calibration off, users reporting missed inputs', 'REMOTE_FIX', 'Ran remote touch calibration routine. Accuracy restored.', 'REMOTE_AGENT', 0),
    ('TKT-2024-011', 'DEV-005', '2024-11-05 09:30:00', '2024-11-05 16:45:00', 'NO_NETWORK', 'Device offline again, same facility as TKT-2024-002', 'FIELD_DISPATCH', 'Facility network infrastructure unstable. Recommended network audit to facility manager.', 'TECH-042', 185.00),
    ('TKT-2024-012', 'DEV-019', '2024-11-10 11:00:00', '2024-11-10 11:05:00', 'HIGH_MEMORY', 'Memory at 88%, preemptive maintenance flag', 'REMOTE_FIX', 'Cleared application cache and restarted services proactively.', 'REMOTE_AGENT', 0),
    ('TKT-2024-013', 'DEV-022', '2024-11-15 08:45:00', '2024-11-15 09:00:00', 'SLOW_RESPONSE', 'UI lag reported by staff', 'REMOTE_FIX', 'Optimized database queries and cleared log files.', 'REMOTE_AGENT', 0),
    ('TKT-2024-014', 'DEV-008', '2024-11-20 15:30:00', '2024-11-21 11:00:00', 'OVERHEATING', 'CPU temp above 80C, automatic shutdown triggered', 'FIELD_DISPATCH', 'Replaced cooling fan and cleaned dust filters.', 'TECH-018', 195.00),
    ('TKT-2024-015', 'DEV-014', '2024-11-25 10:15:00', '2024-11-25 10:30:00', 'DISPLAY_FLICKER', 'Occasional screen flicker', 'REMOTE_FIX', 'Adjusted display refresh rate settings remotely.', 'REMOTE_AGENT', 0);

-- ============================================================================
-- TROUBLESHOOTING KNOWLEDGE BASE
-- Documentation for the AI agent to reference
-- ============================================================================
CREATE OR REPLACE TABLE TROUBLESHOOTING_KB (
    KB_ID VARCHAR(20) PRIMARY KEY,
    ISSUE_CATEGORY VARCHAR(50),
    ISSUE_SYMPTOMS TEXT,
    DIAGNOSTIC_STEPS TEXT,
    REMOTE_FIX_PROCEDURE TEXT,
    REQUIRES_DISPATCH BOOLEAN,
    ESTIMATED_REMOTE_FIX_TIME_MINS INT,
    SUCCESS_RATE_PCT FLOAT,
    LAST_UPDATED DATE
);

INSERT INTO TROUBLESHOOTING_KB VALUES
    ('KB-001', 'DISPLAY_FREEZE', 
     'Screen frozen, unresponsive to touch, display shows static image, no UI updates',
     '1. Check last heartbeat timestamp\n2. Verify CPU and memory usage\n3. Check for high error count\n4. Review recent telemetry for anomalies',
     '1. Attempt soft restart via remote command\n2. If unresponsive, force restart device\n3. Clear application cache\n4. Verify display resumes normal operation\n5. Monitor for 15 minutes post-fix',
     FALSE, 15, 87.5, '2024-10-01'),
    
    ('KB-002', 'NO_NETWORK',
     'Device offline, no heartbeat received, network connectivity lost, cannot reach device remotely',
     '1. Check last known network latency\n2. Verify facility network status if available\n3. Review historical network issues at location\n4. Check for patterns with other devices at same facility',
     '1. If device comes back online, reset network adapter\n2. Update network configuration\n3. Clear DNS cache\n4. Test connectivity to cloud services',
     TRUE, NULL, 25.0, '2024-10-15'),
    
    ('KB-003', 'HIGH_CPU',
     'CPU usage above 80%, sluggish performance, slow UI response, potential runaway process',
     '1. Check current CPU usage percentage\n2. Identify process consuming resources\n3. Check memory usage correlation\n4. Review uptime - long uptime may indicate need for restart',
     '1. Identify and terminate runaway processes\n2. Clear temporary files and cache\n3. Restart high-consumption services\n4. If persistent, schedule firmware update\n5. Consider restart if uptime exceeds 30 days',
     FALSE, 10, 92.0, '2024-09-20'),
    
    ('KB-004', 'HIGH_MEMORY',
     'Memory usage above 85%, application crashes, out of memory errors, slow performance',
     '1. Check current memory usage percentage\n2. Identify memory-consuming applications\n3. Check for memory leak patterns over time\n4. Review application logs for OOM errors',
     '1. Restart application services to free memory\n2. Clear application cache\n3. Remove old log files\n4. If recurring, escalate for code review',
     FALSE, 8, 94.0, '2024-09-25'),
    
    ('KB-005', 'OVERHEATING',
     'CPU temperature above 75C, thermal throttling, automatic shutdowns, fan noise',
     '1. Check current CPU temperature\n2. Compare to historical baseline\n3. Check ambient temperature if available\n4. Review CPU usage - high usage causes heat',
     '1. Reduce CPU load by stopping non-essential processes\n2. If persistent high temp, schedule field visit\n3. Remote restart may temporarily help\n4. Document for preventive maintenance',
     TRUE, NULL, 15.0, '2024-10-05'),
    
    ('KB-006', 'DISPLAY_FLICKER',
     'Screen flickering, intermittent display issues, refresh rate problems, visual artifacts',
     '1. Check display brightness settings\n2. Review recent configuration changes\n3. Check for electromagnetic interference patterns\n4. Verify display driver version',
     '1. Reset display settings to default\n2. Update display driver if outdated\n3. Adjust refresh rate settings\n4. Recalibrate display output',
     FALSE, 12, 78.0, '2024-10-10'),
    
    ('KB-007', 'CONNECTIVITY_INTERMITTENT',
     'Sporadic disconnections, high network latency spikes, packet loss, unstable connection',
     '1. Review network latency history\n2. Check for patterns (time of day, concurrent devices)\n3. Verify WiFi signal strength if wireless\n4. Check for IP conflicts',
     '1. Reset network adapter\n2. Renew DHCP lease\n3. Update network drivers\n4. Switch to backup network if available\n5. Clear network cache',
     FALSE, 10, 70.0, '2024-10-20'),
    
    ('KB-008', 'BOOT_FAILURE',
     'Device stuck in boot loop, fails to start, shows error on boot, cannot reach OS',
     '1. Review last successful boot timestamp\n2. Check for recent updates that may have failed\n3. Verify power stability at location\n4. Check for corrupted system files',
     '1. Attempt remote recovery mode if accessible\n2. Push recovery firmware if device responds\n3. Most boot failures require physical access',
     TRUE, NULL, 10.0, '2024-10-25'),
    
    ('KB-009', 'SOFTWARE_UPDATE',
     'Firmware update required, outdated version detected, security patch needed',
     '1. Verify current firmware version\n2. Check compatibility with latest release\n3. Confirm device is stable before update\n4. Verify network connectivity for download',
     '1. Schedule update during off-hours if possible\n2. Push firmware update package\n3. Monitor update progress\n4. Verify successful installation\n5. Confirm device restarts properly',
     FALSE, 20, 98.0, '2024-11-01'),
    
    ('KB-010', 'DISK_FULL',
     'Disk usage above 90%, cannot save data, application errors, log rotation failure',
     '1. Check current disk usage percentage\n2. Identify large files or directories\n3. Review log file sizes\n4. Check for failed cleanup jobs',
     '1. Clear old log files\n2. Remove temporary files\n3. Clear application cache\n4. Archive old data if needed\n5. Verify disk space recovered',
     FALSE, 10, 96.0, '2024-11-05');

-- ============================================================================
-- DEVICE DOWNTIME TRACKING TABLE
-- Tracks periods when devices are offline for revenue impact calculation
-- ============================================================================
CREATE OR REPLACE TABLE DEVICE_DOWNTIME (
    DOWNTIME_ID VARCHAR(36) DEFAULT UUID_STRING() PRIMARY KEY,
    DEVICE_ID VARCHAR(20),
    DOWNTIME_START TIMESTAMP_NTZ,
    DOWNTIME_END TIMESTAMP_NTZ,
    DOWNTIME_HOURS FLOAT,
    CAUSE VARCHAR(50),  -- HARDWARE_FAILURE, NETWORK_OUTAGE, SOFTWARE_ISSUE, MAINTENANCE
    TICKET_ID VARCHAR(20),
    REVENUE_LOSS_USD FLOAT,
    IMPRESSIONS_LOST INT,
    CONSTRAINT fk_device_downtime FOREIGN KEY (DEVICE_ID) REFERENCES DEVICE_INVENTORY(DEVICE_ID)
);

-- Insert sample downtime records (correlate with maintenance history)
INSERT INTO DEVICE_DOWNTIME (DEVICE_ID, DOWNTIME_START, DOWNTIME_END, DOWNTIME_HOURS, CAUSE, TICKET_ID, REVENUE_LOSS_USD, IMPRESSIONS_LOST) VALUES
    ('DEV-005', '2024-09-18 14:20:00', '2024-09-19 11:00:00', 20.67, 'NETWORK_OUTAGE', 'TKT-2024-002', 258.38, 430),
    ('DEV-014', '2024-10-01 09:00:00', '2024-10-02 14:30:00', 29.5, 'HARDWARE_FAILURE', 'TKT-2024-004', 368.75, 615),
    ('DEV-018', '2024-10-05 16:30:00', '2024-10-06 10:00:00', 17.5, 'SOFTWARE_ISSUE', 'TKT-2024-005', 218.75, 365),
    ('DEV-003', '2024-10-20 13:45:00', '2024-10-21 09:30:00', 19.75, 'HARDWARE_FAILURE', 'TKT-2024-008', 246.88, 410),
    ('DEV-005', '2024-11-05 09:30:00', '2024-11-05 16:45:00', 7.25, 'NETWORK_OUTAGE', 'TKT-2024-011', 90.63, 150),
    ('DEV-008', '2024-11-20 15:30:00', '2024-11-21 11:00:00', 19.5, 'HARDWARE_FAILURE', 'TKT-2024-014', 243.75, 405),
    -- Some unplanned downtime without tickets (discovered by monitoring)
    ('DEV-020', '2024-10-08 02:00:00', '2024-10-08 06:30:00', 4.5, 'SOFTWARE_ISSUE', NULL, 56.25, 95),
    ('DEV-025', '2024-10-22 22:00:00', '2024-10-23 01:30:00', 3.5, 'NETWORK_OUTAGE', NULL, 43.75, 75),
    ('DEV-014', '2024-11-02 08:00:00', '2024-11-02 09:15:00', 1.25, 'SOFTWARE_ISSUE', NULL, 15.63, 25),
    ('DEV-003', '2024-11-18 14:00:00', '2024-11-18 15:30:00', 1.5, 'SOFTWARE_ISSUE', NULL, 18.75, 30);

-- ============================================================================
-- PROVIDER FEEDBACK TABLE
-- Customer satisfaction tracking from healthcare providers
-- ============================================================================
CREATE OR REPLACE TABLE PROVIDER_FEEDBACK (
    FEEDBACK_ID VARCHAR(36) DEFAULT UUID_STRING() PRIMARY KEY,
    FACILITY_NAME VARCHAR(100),
    DEVICE_ID VARCHAR(20),
    FEEDBACK_DATE DATE,
    NPS_SCORE INT,  -- Net Promoter Score: -100 to 100 (calculated from 0-10 rating)
    SATISFACTION_RATING INT,  -- 1-5 stars
    RESPONSE_TIME_RATING INT,  -- 1-5 stars (how quickly issues were resolved)
    DEVICE_RELIABILITY_RATING INT,  -- 1-5 stars
    FEEDBACK_CATEGORY VARCHAR(50),  -- POSITIVE, NEUTRAL, NEGATIVE
    FEEDBACK_TEXT TEXT,
    FOLLOW_UP_REQUIRED BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_device_feedback FOREIGN KEY (DEVICE_ID) REFERENCES DEVICE_INVENTORY(DEVICE_ID)
);

-- Insert sample provider feedback
INSERT INTO PROVIDER_FEEDBACK (FACILITY_NAME, DEVICE_ID, FEEDBACK_DATE, NPS_SCORE, SATISFACTION_RATING, 
                                RESPONSE_TIME_RATING, DEVICE_RELIABILITY_RATING, FEEDBACK_CATEGORY, 
                                FEEDBACK_TEXT, FOLLOW_UP_REQUIRED) VALUES
    -- Positive feedback
    ('Downtown Medical Center', 'DEV-001', '2024-11-15', 9, 5, 5, 5, 'POSITIVE', 
     'The screen has been running flawlessly. Patients love the health tips displayed.', FALSE),
    ('Lakeside Family Practice', 'DEV-002', '2024-11-10', 8, 4, 5, 4, 'POSITIVE', 
     'Quick response when we had a minor issue. Very satisfied with the service.', FALSE),
    ('Memorial Hospital West', 'DEV-006', '2024-11-20', 10, 5, 5, 5, 'POSITIVE', 
     'Excellent product and support. The remote fix capability saved us a lot of hassle.', FALSE),
    ('Cleveland Clinic Annex', 'DEV-007', '2024-11-18', 9, 5, 4, 5, 'POSITIVE', 
     'Large screen is perfect for our waiting area. Great visibility for all patients.', FALSE),
    ('Ann Arbor Family Care', 'DEV-012', '2024-11-12', 8, 4, 4, 4, 'POSITIVE', 
     'Reliable device. The educational content is very helpful for patient engagement.', FALSE),
    ('Mayo Clinic Rochester', 'DEV-026', '2024-11-22', 10, 5, 5, 5, 'POSITIVE', 
     'Top-notch equipment and support. Exactly what we expect from a premium partner.', FALSE),
    
    -- Neutral feedback
    ('North Shore Pediatrics', 'DEV-003', '2024-10-25', 6, 3, 4, 3, 'NEUTRAL', 
     'Device works okay but has had some performance issues. Hoping it improves after recent maintenance.', FALSE),
    ('Buckeye Family Medicine', 'DEV-008', '2024-11-01', 5, 3, 3, 2, 'NEUTRAL', 
     'Had multiple issues this quarter. Support was helpful but reliability needs improvement.', TRUE),
    ('Lansing Cardiology Group', 'DEV-014', '2024-10-15', 6, 3, 4, 3, 'NEUTRAL', 
     'Recent hardware replacement fixed the display issue. Monitoring performance now.', FALSE),
    ('Appleton Walk-In Care', 'DEV-025', '2024-11-08', 5, 3, 3, 3, 'NEUTRAL', 
     'Occasional connectivity issues but nothing major. Would appreciate more proactive monitoring.', FALSE),
    
    -- Negative feedback (for devices with issues)
    ('Springfield Urgent Care', 'DEV-005', '2024-11-10', 2, 2, 2, 1, 'NEGATIVE', 
     'Device has been offline multiple times. Very frustrating for staff and patients.', TRUE),
    ('Evansville Family Practice', 'DEV-018', '2024-10-20', 3, 2, 3, 2, 'NEGATIVE', 
     'Boot loop issue caused significant downtime. Need better preventive maintenance.', TRUE),
    ('Bloomington Urgent Care', 'DEV-020', '2024-11-05', 4, 2, 3, 2, 'NEGATIVE', 
     'Memory issues causing app crashes. Affects our ability to show content to patients.', TRUE);

-- ============================================================================
-- REVENUE IMPACT VIEW
-- Calculates revenue loss from device downtime
-- ============================================================================
CREATE OR REPLACE VIEW V_REVENUE_IMPACT AS
SELECT 
    d.DEVICE_ID,
    d.FACILITY_NAME,
    d.FACILITY_TYPE,
    CONCAT(d.LOCATION_CITY, ', ', d.LOCATION_STATE) as LOCATION,
    d.HOURLY_AD_REVENUE_USD,
    d.MONTHLY_IMPRESSIONS,
    -- Downtime statistics
    COUNT(dt.DOWNTIME_ID) as DOWNTIME_INCIDENTS,
    COALESCE(SUM(dt.DOWNTIME_HOURS), 0) as TOTAL_DOWNTIME_HOURS,
    COALESCE(SUM(dt.REVENUE_LOSS_USD), 0) as TOTAL_REVENUE_LOSS_USD,
    COALESCE(SUM(dt.IMPRESSIONS_LOST), 0) as TOTAL_IMPRESSIONS_LOST,
    -- Uptime calculation (assuming 720 hours per month)
    ROUND((720 - COALESCE(SUM(dt.DOWNTIME_HOURS), 0)) / 720 * 100, 2) as UPTIME_PERCENTAGE,
    -- Revenue protection (what we saved by quick fixes)
    ROUND(d.HOURLY_AD_REVENUE_USD * 720, 2) as POTENTIAL_MONTHLY_REVENUE,
    ROUND(d.HOURLY_AD_REVENUE_USD * (720 - COALESCE(SUM(dt.DOWNTIME_HOURS), 0)), 2) as ACTUAL_MONTHLY_REVENUE
FROM DEVICE_INVENTORY d
LEFT JOIN DEVICE_DOWNTIME dt ON d.DEVICE_ID = dt.DEVICE_ID
    AND dt.DOWNTIME_START >= DATE_TRUNC('month', CURRENT_DATE())
GROUP BY d.DEVICE_ID, d.FACILITY_NAME, d.FACILITY_TYPE, d.LOCATION_CITY, d.LOCATION_STATE,
         d.HOURLY_AD_REVENUE_USD, d.MONTHLY_IMPRESSIONS;

-- ============================================================================
-- CUSTOMER SATISFACTION VIEW
-- Aggregates provider feedback for analysis
-- ============================================================================
CREATE OR REPLACE VIEW V_CUSTOMER_SATISFACTION AS
SELECT 
    f.FACILITY_NAME,
    d.FACILITY_TYPE,
    CONCAT(d.LOCATION_CITY, ', ', d.LOCATION_STATE) as LOCATION,
    f.DEVICE_ID,
    d.STATUS as DEVICE_STATUS,
    -- Satisfaction metrics
    ROUND(AVG(f.NPS_SCORE), 1) as AVG_NPS_SCORE,
    ROUND(AVG(f.SATISFACTION_RATING), 1) as AVG_SATISFACTION,
    ROUND(AVG(f.RESPONSE_TIME_RATING), 1) as AVG_RESPONSE_TIME_RATING,
    ROUND(AVG(f.DEVICE_RELIABILITY_RATING), 1) as AVG_RELIABILITY_RATING,
    -- Feedback counts
    COUNT(*) as TOTAL_FEEDBACK_COUNT,
    SUM(CASE WHEN f.FEEDBACK_CATEGORY = 'POSITIVE' THEN 1 ELSE 0 END) as POSITIVE_COUNT,
    SUM(CASE WHEN f.FEEDBACK_CATEGORY = 'NEUTRAL' THEN 1 ELSE 0 END) as NEUTRAL_COUNT,
    SUM(CASE WHEN f.FEEDBACK_CATEGORY = 'NEGATIVE' THEN 1 ELSE 0 END) as NEGATIVE_COUNT,
    SUM(CASE WHEN f.FOLLOW_UP_REQUIRED THEN 1 ELSE 0 END) as FOLLOW_UPS_REQUIRED,
    -- Latest feedback
    MAX(f.FEEDBACK_DATE) as LAST_FEEDBACK_DATE,
    -- NPS category
    CASE 
        WHEN AVG(f.NPS_SCORE) >= 9 THEN 'PROMOTER'
        WHEN AVG(f.NPS_SCORE) >= 7 THEN 'PASSIVE'
        ELSE 'DETRACTOR'
    END as NPS_CATEGORY
FROM PROVIDER_FEEDBACK f
JOIN DEVICE_INVENTORY d ON f.DEVICE_ID = d.DEVICE_ID
GROUP BY f.FACILITY_NAME, d.FACILITY_TYPE, d.LOCATION_CITY, d.LOCATION_STATE, 
         f.DEVICE_ID, d.STATUS;

-- ============================================================================
-- TECHNICIANS TABLE
-- Field technicians available for dispatch
-- ============================================================================
CREATE OR REPLACE TABLE TECHNICIANS (
    TECHNICIAN_ID VARCHAR(20) PRIMARY KEY,
    TECHNICIAN_NAME VARCHAR(100),
    EMAIL VARCHAR(100),
    PHONE VARCHAR(20),
    REGION VARCHAR(50),  -- Midwest, Northeast, etc.
    COVERAGE_STATES ARRAY,  -- States they cover
    SPECIALIZATION VARCHAR(50),  -- Hardware, Software, Network
    CERTIFICATION_LEVEL VARCHAR(20),  -- Junior, Senior, Lead
    CURRENT_STATUS VARCHAR(20) DEFAULT 'AVAILABLE',  -- AVAILABLE, ON_CALL, DISPATCHED, OFF_DUTY
    CURRENT_LOCATION VARCHAR(100),
    AVG_RATING FLOAT DEFAULT 4.5,
    TOTAL_JOBS_COMPLETED INT DEFAULT 0
);

-- Insert sample technicians
INSERT INTO TECHNICIANS VALUES
    ('TECH-001', 'Marcus Johnson', 'marcus.johnson@patientpoint.com', '312-555-0101', 'Midwest', ARRAY_CONSTRUCT('IL', 'WI'), 'Hardware', 'Lead', 'AVAILABLE', 'Chicago, IL', 4.8, 156),
    ('TECH-002', 'Sarah Chen', 'sarah.chen@patientpoint.com', '312-555-0102', 'Midwest', ARRAY_CONSTRUCT('IL', 'IN'), 'Software', 'Senior', 'DISPATCHED', 'Indianapolis, IN', 4.9, 142),
    ('TECH-003', 'David Martinez', 'david.martinez@patientpoint.com', '614-555-0103', 'Midwest', ARRAY_CONSTRUCT('OH', 'MI'), 'Hardware', 'Senior', 'AVAILABLE', 'Columbus, OH', 4.7, 128),
    ('TECH-004', 'Emily Williams', 'emily.williams@patientpoint.com', '313-555-0104', 'Midwest', ARRAY_CONSTRUCT('MI', 'OH'), 'Network', 'Senior', 'ON_CALL', 'Detroit, MI', 4.6, 98),
    ('TECH-005', 'James Thompson', 'james.thompson@patientpoint.com', '414-555-0105', 'Midwest', ARRAY_CONSTRUCT('WI', 'MN'), 'Hardware', 'Junior', 'AVAILABLE', 'Milwaukee, WI', 4.4, 45),
    ('TECH-006', 'Lisa Anderson', 'lisa.anderson@patientpoint.com', '612-555-0106', 'Midwest', ARRAY_CONSTRUCT('MN', 'WI'), 'Software', 'Lead', 'AVAILABLE', 'Minneapolis, MN', 4.9, 189);

-- ============================================================================
-- WORK ORDERS TABLE
-- Maintenance work orders for operations and technicians
-- ============================================================================
CREATE OR REPLACE TABLE WORK_ORDERS (
    WORK_ORDER_ID VARCHAR(20) PRIMARY KEY,
    DEVICE_ID VARCHAR(20),
    CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    UPDATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    SCHEDULED_DATE DATE,
    SCHEDULED_TIME_WINDOW VARCHAR(20),  -- MORNING, AFTERNOON, EVENING
    PRIORITY VARCHAR(20),  -- CRITICAL, HIGH, MEDIUM, LOW
    STATUS VARCHAR(30),  -- OPEN, ASSIGNED, IN_PROGRESS, PENDING_PARTS, COMPLETED, CANCELLED
    WORK_ORDER_TYPE VARCHAR(30),  -- PREDICTIVE, REACTIVE, PREVENTIVE, INSTALLATION
    SOURCE VARCHAR(30),  -- AI_PREDICTION, MANUAL, PROVIDER_REQUEST, SCHEDULED
    ISSUE_SUMMARY TEXT,
    AI_DIAGNOSIS TEXT,
    RECOMMENDED_ACTIONS TEXT,
    ASSIGNED_TECHNICIAN_ID VARCHAR(20),
    ESTIMATED_DURATION_MINS INT,
    ACTUAL_DURATION_MINS INT,
    PARTS_REQUIRED ARRAY,
    RESOLUTION_NOTES TEXT,
    CUSTOMER_NOTIFIED BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_device_wo FOREIGN KEY (DEVICE_ID) REFERENCES DEVICE_INVENTORY(DEVICE_ID),
    CONSTRAINT fk_tech_wo FOREIGN KEY (ASSIGNED_TECHNICIAN_ID) REFERENCES TECHNICIANS(TECHNICIAN_ID)
);

-- Insert sample work orders (mix of statuses and types)
INSERT INTO WORK_ORDERS (WORK_ORDER_ID, DEVICE_ID, CREATED_AT, SCHEDULED_DATE, SCHEDULED_TIME_WINDOW, 
                          PRIORITY, STATUS, WORK_ORDER_TYPE, SOURCE, ISSUE_SUMMARY, AI_DIAGNOSIS, 
                          RECOMMENDED_ACTIONS, ASSIGNED_TECHNICIAN_ID, ESTIMATED_DURATION_MINS, 
                          ACTUAL_DURATION_MINS, PARTS_REQUIRED, RESOLUTION_NOTES, CUSTOMER_NOTIFIED) VALUES
    -- Critical/Open work orders (from AI predictions)
    ('WO-2024-001', 'DEV-003', CURRENT_TIMESTAMP(), CURRENT_DATE(), 'MORNING', 'CRITICAL', 'ASSIGNED', 'PREDICTIVE', 'AI_PREDICTION',
     'Device showing rising CPU temperature trend - failure predicted within 12 hours',
     'Telemetry analysis indicates thermal throttling. CPU temp increased 15°C over 24 hours. Fan may be failing or dust accumulation.',
     '1. Check/clean cooling fan\n2. Replace thermal paste\n3. Clear dust from vents\n4. Verify airflow around device',
     'TECH-001', 45, NULL, ARRAY_CONSTRUCT('Thermal Paste', 'Compressed Air'), NULL, TRUE),
    
    ('WO-2024-002', 'DEV-008', CURRENT_TIMESTAMP(), CURRENT_DATE(), 'AFTERNOON', 'HIGH', 'OPEN', 'PREDICTIVE', 'AI_PREDICTION',
     'Memory usage trending toward exhaustion - application instability expected',
     'Memory leak pattern detected. Usage increased from 65% to 92% over 48 hours. Likely application-level issue.',
     '1. Attempt remote service restart\n2. If fails, schedule on-site memory diagnostics\n3. May require application update',
     NULL, 30, NULL, NULL, NULL, FALSE),
    
    ('WO-2024-003', 'DEV-005', DATEADD('day', -1, CURRENT_TIMESTAMP()), CURRENT_DATE(), 'MORNING', 'CRITICAL', 'IN_PROGRESS', 'REACTIVE', 'PROVIDER_REQUEST',
     'Device offline - facility reports no display for 2 hours',
     'Network connectivity lost. Last heartbeat 2 hours ago. Historical pattern: this facility has had 3 network issues in past 60 days.',
     '1. Check network cable and router\n2. Verify facility network is operational\n3. Test with alternate network connection\n4. Recommend facility network audit',
     'TECH-002', 60, NULL, ARRAY_CONSTRUCT('Ethernet Cable', 'USB Network Adapter'), NULL, TRUE),
    
    -- Medium priority work orders
    ('WO-2024-004', 'DEV-014', DATEADD('day', -2, CURRENT_TIMESTAMP()), DATEADD('day', 1, CURRENT_DATE()), 'AFTERNOON', 'MEDIUM', 'ASSIGNED', 'PREVENTIVE', 'SCHEDULED',
     'Preventive maintenance - device approaching 180 days since last service',
     'Routine maintenance due. Device has been stable but firmware is 2 versions behind.',
     '1. Update firmware to v3.2.2\n2. Clean screen and housing\n3. Check all connections\n4. Run full diagnostic',
     'TECH-003', 40, NULL, NULL, NULL, TRUE),
    
    ('WO-2024-005', 'DEV-020', DATEADD('day', -1, CURRENT_TIMESTAMP()), DATEADD('day', 1, CURRENT_DATE()), 'MORNING', 'MEDIUM', 'ASSIGNED', 'PREDICTIVE', 'AI_PREDICTION',
     'Error rate increasing - 18 errors in past 24 hours',
     'Application errors correlating with memory pressure. Similar pattern preceded failure on DEV-008 last month.',
     '1. Clear application cache\n2. Restart all services\n3. Monitor for 24 hours\n4. Schedule follow-up if errors persist',
     'TECH-005', 25, NULL, NULL, NULL, FALSE),
    
    -- Completed work orders (for history)
    ('WO-2024-006', 'DEV-007', DATEADD('day', -5, CURRENT_TIMESTAMP()), DATEADD('day', -4, CURRENT_DATE()), 'AFTERNOON', 'LOW', 'COMPLETED', 'PREVENTIVE', 'SCHEDULED',
     'Scheduled firmware update and maintenance check',
     'Routine update. Device healthy, no issues detected.',
     'Standard firmware update procedure',
     'TECH-001', 30, 25, NULL, 'Firmware updated successfully to v3.2.2. All diagnostics passed. Device performing optimally.', TRUE),
    
    ('WO-2024-007', 'DEV-012', DATEADD('day', -3, CURRENT_TIMESTAMP()), DATEADD('day', -2, CURRENT_DATE()), 'MORNING', 'HIGH', 'COMPLETED', 'REACTIVE', 'PROVIDER_REQUEST',
     'Display flickering reported by facility staff',
     'Display refresh rate misconfigured after power outage.',
     '1. Check display settings\n2. Recalibrate if needed\n3. Check power supply stability',
     'TECH-003', 45, 35, NULL, 'Reset display settings to factory defaults. Recalibrated touch screen. Issue resolved. Recommended UPS installation to facility.', TRUE),
    
    ('WO-2024-008', 'DEV-019', DATEADD('day', -7, CURRENT_TIMESTAMP()), DATEADD('day', -6, CURRENT_DATE()), 'AFTERNOON', 'MEDIUM', 'COMPLETED', 'PREDICTIVE', 'AI_PREDICTION',
     'Disk usage at 88% - proactive cleanup recommended',
     'Log files consuming excessive space. Automated cleanup not running.',
     '1. Clear old logs\n2. Fix log rotation\n3. Verify automated cleanup scheduled',
     'TECH-006', 20, 15, NULL, 'Cleared 2.3GB of old logs. Fixed cron job for automated cleanup. Disk usage now at 52%.', TRUE);

-- ============================================================================
-- WORK ORDER VIEWS FOR OPERATIONS
-- ============================================================================

-- Active work orders view for operations dashboard
CREATE OR REPLACE VIEW V_ACTIVE_WORK_ORDERS AS
SELECT 
    wo.WORK_ORDER_ID,
    wo.DEVICE_ID,
    d.DEVICE_MODEL,
    d.FACILITY_NAME,
    d.FACILITY_TYPE,
    CONCAT(d.LOCATION_CITY, ', ', d.LOCATION_STATE) as LOCATION,
    wo.PRIORITY,
    wo.STATUS,
    wo.WORK_ORDER_TYPE,
    wo.SOURCE,
    wo.ISSUE_SUMMARY,
    wo.AI_DIAGNOSIS,
    wo.RECOMMENDED_ACTIONS,
    wo.SCHEDULED_DATE,
    wo.SCHEDULED_TIME_WINDOW,
    wo.ASSIGNED_TECHNICIAN_ID,
    t.TECHNICIAN_NAME,
    t.PHONE as TECHNICIAN_PHONE,
    t.CURRENT_STATUS as TECHNICIAN_STATUS,
    wo.ESTIMATED_DURATION_MINS,
    wo.CUSTOMER_NOTIFIED,
    wo.CREATED_AT,
    DATEDIFF('hour', wo.CREATED_AT, CURRENT_TIMESTAMP()) as HOURS_SINCE_CREATED,
    -- Urgency score for prioritization
    CASE 
        WHEN wo.PRIORITY = 'CRITICAL' AND wo.STATUS = 'OPEN' THEN 100
        WHEN wo.PRIORITY = 'CRITICAL' THEN 90
        WHEN wo.PRIORITY = 'HIGH' AND wo.STATUS = 'OPEN' THEN 80
        WHEN wo.PRIORITY = 'HIGH' THEN 70
        WHEN wo.PRIORITY = 'MEDIUM' THEN 50
        ELSE 30
    END as URGENCY_SCORE
FROM WORK_ORDERS wo
JOIN DEVICE_INVENTORY d ON wo.DEVICE_ID = d.DEVICE_ID
LEFT JOIN TECHNICIANS t ON wo.ASSIGNED_TECHNICIAN_ID = t.TECHNICIAN_ID
WHERE wo.STATUS NOT IN ('COMPLETED', 'CANCELLED')
ORDER BY URGENCY_SCORE DESC, wo.CREATED_AT ASC;

-- Technician workload view
CREATE OR REPLACE VIEW V_TECHNICIAN_WORKLOAD AS
SELECT 
    t.TECHNICIAN_ID,
    t.TECHNICIAN_NAME,
    t.CURRENT_STATUS,
    t.REGION,
    t.SPECIALIZATION,
    t.CERTIFICATION_LEVEL,
    t.AVG_RATING,
    t.CURRENT_LOCATION,
    COUNT(wo.WORK_ORDER_ID) as ASSIGNED_WORK_ORDERS,
    SUM(CASE WHEN wo.STATUS = 'IN_PROGRESS' THEN 1 ELSE 0 END) as IN_PROGRESS_COUNT,
    SUM(CASE WHEN wo.PRIORITY = 'CRITICAL' THEN 1 ELSE 0 END) as CRITICAL_COUNT,
    SUM(COALESCE(wo.ESTIMATED_DURATION_MINS, 0)) as TOTAL_ESTIMATED_MINS
FROM TECHNICIANS t
LEFT JOIN WORK_ORDERS wo ON t.TECHNICIAN_ID = wo.ASSIGNED_TECHNICIAN_ID 
    AND wo.STATUS NOT IN ('COMPLETED', 'CANCELLED')
GROUP BY t.TECHNICIAN_ID, t.TECHNICIAN_NAME, t.CURRENT_STATUS, t.REGION, 
         t.SPECIALIZATION, t.CERTIFICATION_LEVEL, t.AVG_RATING, t.CURRENT_LOCATION;

-- ============================================================================
-- EXECUTIVE DASHBOARD VIEW
-- Single-pane-of-glass for C-suite executives
-- ============================================================================
CREATE OR REPLACE VIEW V_EXECUTIVE_DASHBOARD AS
SELECT 
    -- Current timestamp for dashboard refresh
    CURRENT_TIMESTAMP() as DASHBOARD_REFRESH_TIME,
    
    -- ===== FLEET HEALTH METRICS =====
    (SELECT COUNT(*) FROM DEVICE_INVENTORY) as TOTAL_FLEET_SIZE,
    (SELECT COUNT(*) FROM DEVICE_INVENTORY WHERE STATUS = 'ONLINE') as DEVICES_ONLINE,
    (SELECT COUNT(*) FROM DEVICE_INVENTORY WHERE STATUS = 'DEGRADED') as DEVICES_DEGRADED,
    (SELECT COUNT(*) FROM DEVICE_INVENTORY WHERE STATUS = 'OFFLINE') as DEVICES_OFFLINE,
    (SELECT ROUND(COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM DEVICE_INVENTORY), 0), 1) 
     FROM DEVICE_INVENTORY WHERE STATUS = 'ONLINE') as FLEET_UPTIME_PCT,
    (SELECT ROUND(AVG(HEALTH_SCORE), 1) FROM V_DEVICE_HEALTH_SUMMARY) as AVG_FLEET_HEALTH_SCORE,
    
    -- ===== PREDICTIVE MAINTENANCE METRICS =====
    (SELECT COUNT(*) FROM V_FAILURE_PREDICTIONS WHERE FAILURE_PROBABILITY_PCT >= 60) as HIGH_RISK_DEVICES,
    (SELECT COUNT(*) FROM V_FAILURE_PREDICTIONS 
     WHERE PREDICTED_HOURS_TO_FAILURE IS NOT NULL AND PREDICTED_HOURS_TO_FAILURE <= 48) as PREDICTED_FAILURES_48H,
    (SELECT PREDICTION_ACCURACY_PCT FROM V_PREDICTION_ACCURACY_ANALYSIS) as PREDICTION_ACCURACY_PCT,
    
    -- ===== COST METRICS =====
    (SELECT COALESCE(SUM(COST_SAVINGS_USD), 0) FROM V_MAINTENANCE_ANALYTICS) as TOTAL_COST_SAVINGS_USD,
    (SELECT COALESCE(SUM(COST_USD), 0) FROM MAINTENANCE_HISTORY) as TOTAL_MAINTENANCE_SPEND_USD,
    (SELECT ROUND(SUM(COST_SAVINGS_USD) / NULLIF(SUM(COST_USD) + SUM(COST_SAVINGS_USD), 0) * 100, 1) 
     FROM V_MAINTENANCE_ANALYTICS) as COST_AVOIDANCE_RATE_PCT,
    
    -- ===== OPERATIONAL EFFICIENCY =====
    (SELECT COUNT(*) FROM MAINTENANCE_HISTORY WHERE RESOLUTION_TYPE = 'REMOTE_FIX') as TOTAL_REMOTE_FIXES,
    (SELECT COUNT(*) FROM MAINTENANCE_HISTORY WHERE RESOLUTION_TYPE = 'FIELD_DISPATCH') as TOTAL_FIELD_DISPATCHES,
    (SELECT ROUND(COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM MAINTENANCE_HISTORY), 0), 1) 
     FROM MAINTENANCE_HISTORY WHERE RESOLUTION_TYPE = 'REMOTE_FIX') as REMOTE_RESOLUTION_RATE_PCT,
    (SELECT ROUND(AVG(RESOLUTION_TIME_MINS), 0) FROM V_MAINTENANCE_ANALYTICS) as AVG_MTTR_MINS,
    (SELECT ROUND(AVG(CASE WHEN RESOLUTION_TYPE = 'REMOTE_FIX' THEN RESOLUTION_TIME_MINS END), 0) 
     FROM V_MAINTENANCE_ANALYTICS) as AVG_REMOTE_MTTR_MINS,
    
    -- ===== REVENUE IMPACT =====
    (SELECT COALESCE(SUM(REVENUE_LOSS_USD), 0) FROM DEVICE_DOWNTIME) as TOTAL_REVENUE_LOSS_USD,
    (SELECT COALESCE(SUM(DOWNTIME_HOURS), 0) FROM DEVICE_DOWNTIME) as TOTAL_DOWNTIME_HOURS,
    (SELECT ROUND(SUM(HOURLY_AD_REVENUE_USD * 720), 0) FROM DEVICE_INVENTORY) as MONTHLY_REVENUE_POTENTIAL_USD,
    (SELECT ROUND(AVG(UPTIME_PERCENTAGE), 2) FROM V_REVENUE_IMPACT) as AVG_UPTIME_PCT,
    
    -- ===== CUSTOMER SATISFACTION =====
    (SELECT ROUND(AVG(NPS_SCORE), 1) FROM PROVIDER_FEEDBACK) as NPS_SCORE,
    (SELECT ROUND(AVG(SATISFACTION_RATING), 2) FROM PROVIDER_FEEDBACK) as AVG_SATISFACTION_RATING,
    (SELECT SUM(CASE WHEN FEEDBACK_CATEGORY = 'POSITIVE' THEN 1 ELSE 0 END) FROM PROVIDER_FEEDBACK) as PROMOTERS,
    (SELECT SUM(CASE WHEN FEEDBACK_CATEGORY = 'NEGATIVE' THEN 1 ELSE 0 END) FROM PROVIDER_FEEDBACK) as DETRACTORS,
    (SELECT SUM(CASE WHEN FOLLOW_UP_REQUIRED THEN 1 ELSE 0 END) FROM PROVIDER_FEEDBACK) as PENDING_FOLLOW_UPS,
    
    -- ===== WORK ORDER STATUS =====
    (SELECT COUNT(*) FROM WORK_ORDERS WHERE STATUS NOT IN ('COMPLETED', 'CANCELLED')) as ACTIVE_WORK_ORDERS,
    (SELECT COUNT(*) FROM WORK_ORDERS WHERE STATUS = 'OPEN') as UNASSIGNED_WORK_ORDERS,
    (SELECT COUNT(*) FROM WORK_ORDERS WHERE PRIORITY = 'CRITICAL' AND STATUS NOT IN ('COMPLETED', 'CANCELLED')) as CRITICAL_WORK_ORDERS,
    (SELECT COUNT(*) FROM WORK_ORDERS WHERE SOURCE = 'AI_PREDICTION' AND STATUS NOT IN ('COMPLETED', 'CANCELLED')) as AI_GENERATED_WORK_ORDERS;

-- ============================================================================
-- BUSINESS IMPACT SUMMARY VIEW
-- Executive-level KPIs combining all metrics
-- ============================================================================
CREATE OR REPLACE VIEW V_BUSINESS_IMPACT_SUMMARY AS
SELECT 
    -- Fleet metrics
    (SELECT COUNT(*) FROM DEVICE_INVENTORY) as TOTAL_DEVICES,
    (SELECT COUNT(*) FROM DEVICE_INVENTORY WHERE STATUS = 'ONLINE') as ONLINE_DEVICES,
    
    -- Cost savings
    (SELECT COALESCE(SUM(COST_SAVINGS_USD), 0) FROM V_MAINTENANCE_ANALYTICS) as TOTAL_COST_SAVINGS_USD,
    (SELECT COUNT(*) FROM MAINTENANCE_HISTORY WHERE RESOLUTION_TYPE = 'REMOTE_FIX') as REMOTE_FIXES,
    (SELECT ROUND(COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM MAINTENANCE_HISTORY), 0), 1) 
     FROM MAINTENANCE_HISTORY WHERE RESOLUTION_TYPE = 'REMOTE_FIX') as REMOTE_FIX_RATE_PCT,
    
    -- Revenue protection
    (SELECT COALESCE(SUM(REVENUE_LOSS_USD), 0) FROM DEVICE_DOWNTIME) as TOTAL_REVENUE_LOSS_USD,
    (SELECT COALESCE(SUM(DOWNTIME_HOURS), 0) FROM DEVICE_DOWNTIME) as TOTAL_DOWNTIME_HOURS,
    (SELECT COUNT(*) FROM DEVICE_DOWNTIME) as DOWNTIME_INCIDENTS,
    (SELECT ROUND(SUM(HOURLY_AD_REVENUE_USD * 720), 2) FROM DEVICE_INVENTORY) as POTENTIAL_MONTHLY_REVENUE_USD,
    
    -- Customer satisfaction
    (SELECT ROUND(AVG(NPS_SCORE), 1) FROM PROVIDER_FEEDBACK) as AVG_NPS_SCORE,
    (SELECT ROUND(AVG(SATISFACTION_RATING), 1) FROM PROVIDER_FEEDBACK) as AVG_SATISFACTION_RATING,
    (SELECT SUM(CASE WHEN FEEDBACK_CATEGORY = 'POSITIVE' THEN 1 ELSE 0 END) FROM PROVIDER_FEEDBACK) as POSITIVE_FEEDBACK_COUNT,
    (SELECT SUM(CASE WHEN FEEDBACK_CATEGORY = 'NEGATIVE' THEN 1 ELSE 0 END) FROM PROVIDER_FEEDBACK) as NEGATIVE_FEEDBACK_COUNT,
    (SELECT SUM(CASE WHEN FOLLOW_UP_REQUIRED THEN 1 ELSE 0 END) FROM PROVIDER_FEEDBACK) as PENDING_FOLLOW_UPS,
    
    -- MTTR
    (SELECT ROUND(AVG(RESOLUTION_TIME_MINS), 1) FROM V_MAINTENANCE_ANALYTICS) as AVG_RESOLUTION_TIME_MINS,
    (SELECT ROUND(AVG(CASE WHEN RESOLUTION_TYPE = 'REMOTE_FIX' THEN RESOLUTION_TIME_MINS END), 1) 
     FROM V_MAINTENANCE_ANALYTICS) as AVG_REMOTE_FIX_TIME_MINS,
    (SELECT ROUND(AVG(CASE WHEN RESOLUTION_TYPE = 'FIELD_DISPATCH' THEN RESOLUTION_TIME_MINS END), 1) 
     FROM V_MAINTENANCE_ANALYTICS) as AVG_DISPATCH_TIME_MINS;

-- Verify data loaded correctly
SELECT 'DEVICE_INVENTORY' as TABLE_NAME, COUNT(*) as ROW_COUNT FROM DEVICE_INVENTORY
UNION ALL
SELECT 'DEVICE_TELEMETRY', COUNT(*) FROM DEVICE_TELEMETRY
UNION ALL
SELECT 'MAINTENANCE_HISTORY', COUNT(*) FROM MAINTENANCE_HISTORY
UNION ALL
SELECT 'TROUBLESHOOTING_KB', COUNT(*) FROM TROUBLESHOOTING_KB
UNION ALL
SELECT 'DEVICE_DOWNTIME', COUNT(*) FROM DEVICE_DOWNTIME
UNION ALL
SELECT 'PROVIDER_FEEDBACK', COUNT(*) FROM PROVIDER_FEEDBACK
UNION ALL
SELECT 'TECHNICIANS', COUNT(*) FROM TECHNICIANS
UNION ALL
SELECT 'WORK_ORDERS', COUNT(*) FROM WORK_ORDERS;

