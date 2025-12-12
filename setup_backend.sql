-- ============================================================================
-- PATIENTPOINT COMMAND CENTER - BACKEND SETUP
-- ============================================================================
-- This SQL script sets up the "hidden engine" that powers the dashboard.
-- The ML inference complexity is abstracted away - this simulates the output
-- of XGBoost models running in production.
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE WAREHOUSE COMPUTE_WH;

-- Create database and schema for the predictive maintenance system
CREATE DATABASE IF NOT EXISTS PATIENTPOINT_OPS;
CREATE SCHEMA IF NOT EXISTS PATIENTPOINT_OPS.DEVICE_ANALYTICS;

USE SCHEMA PATIENTPOINT_OPS.DEVICE_ANALYTICS;

-- ============================================================================
-- TABLE 1: FLEET_HEALTH_SCORED
-- ============================================================================
-- This table simulates the output of an XGBoost inference pipeline
-- In production, this would be populated by a Snowpark ML job running hourly
-- ============================================================================

CREATE OR REPLACE TABLE FLEET_HEALTH_SCORED (
    device_id VARCHAR(50) PRIMARY KEY,
    region VARCHAR(50),              -- US State
    hospital_name VARCHAR(200),
    last_ping TIMESTAMP_LTZ,
    cpu_load FLOAT,                  -- 0.0 to 100.0
    voltage FLOAT,                   -- Voltage reading
    memory_usage FLOAT,              -- 0.0 to 100.0
    temperature FLOAT,               -- Celsius
    uptime_hours INTEGER,
    failure_probability FLOAT,       -- 0.0 to 1.0 (ML Model Score)
    predicted_failure_type VARCHAR(100),
    latitude FLOAT,
    longitude FLOAT,
    created_at TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- GENERATE REALISTIC DEVICE FLEET DATA (500 devices across US hospitals)
-- ============================================================================
-- Distribution: 20 critical devices (>0.85 prob), rest distributed normally
-- ============================================================================

-- First, create a helper table with US hospital locations
CREATE OR REPLACE TEMPORARY TABLE us_hospital_locations AS
SELECT * FROM (VALUES
    ('New York', 'Mount Sinai Hospital', 40.7903, -73.9522),
    ('New York', 'NYU Langone Health', 40.7425, -73.9732),
    ('New York', 'Columbia Presbyterian', 40.8428, -73.9399),
    ('California', 'Cedars-Sinai Medical Center', 34.0754, -118.3774),
    ('California', 'UCLA Medical Center', 34.0669, -118.4460),
    ('California', 'Stanford Health Care', 37.4419, -122.1722),
    ('California', 'UCSF Medical Center', 37.7625, -122.4583),
    ('Texas', 'Houston Methodist Hospital', 29.7091, -95.4018),
    ('Texas', 'UT Southwestern Medical Center', 32.8153, -96.8361),
    ('Texas', 'Baylor Scott & White', 32.8241, -96.7879),
    ('Illinois', 'Northwestern Memorial Hospital', 41.8960, -87.6196),
    ('Illinois', 'Rush University Medical Center', 41.8742, -87.6710),
    ('Massachusetts', 'Massachusetts General Hospital', 42.3631, -71.0686),
    ('Massachusetts', 'Brigham and Women''s Hospital', 42.3361, -71.1073),
    ('Pennsylvania', 'Penn Medicine', 39.9496, -75.1961),
    ('Pennsylvania', 'UPMC Presbyterian', 40.4426, -79.9582),
    ('Florida', 'Mayo Clinic Jacksonville', 30.2979, -81.3930),
    ('Florida', 'Tampa General Hospital', 27.9443, -82.4610),
    ('Ohio', 'Cleveland Clinic', 41.5034, -81.6221),
    ('Ohio', 'Ohio State University Wexner', 40.0006, -83.0305),
    ('Michigan', 'Michigan Medicine', 42.2793, -83.7380),
    ('Washington', 'UW Medicine', 47.6505, -122.3088),
    ('Washington', 'Virginia Mason Medical Center', 47.6129, -122.3312),
    ('Georgia', 'Emory University Hospital', 33.7970, -84.3223),
    ('North Carolina', 'Duke University Hospital', 36.0103, -78.9398),
    ('Maryland', 'Johns Hopkins Hospital', 39.2970, -76.5930),
    ('Arizona', 'Mayo Clinic Phoenix', 33.4942, -111.9761),
    ('Colorado', 'UCHealth University Hospital', 39.7447, -104.9498),
    ('Minnesota', 'Mayo Clinic Rochester', 44.0225, -92.4662),
    ('Wisconsin', 'Froedtert Hospital', 43.0514, -88.0315)
) AS hospitals(region, hospital_name, latitude, longitude);

-- Generate 500 devices with realistic distribution
INSERT INTO FLEET_HEALTH_SCORED 
WITH device_base AS (
    SELECT 
        'PP-' || LPAD(seq4(), 5, '0') AS device_id,
        h.region,
        h.hospital_name,
        h.latitude + UNIFORM(-0.05, 0.05, RANDOM()) AS latitude,
        h.longitude + UNIFORM(-0.05, 0.05, RANDOM()) AS longitude,
        ROW_NUMBER() OVER (ORDER BY seq4()) AS rn
    FROM TABLE(GENERATOR(ROWCOUNT => 500)) g
    CROSS JOIN (
        SELECT region, hospital_name, latitude, longitude 
        FROM us_hospital_locations 
        ORDER BY RANDOM()
        LIMIT 1
    ) h
),
device_metrics AS (
    SELECT 
        d.*,
        -- Generate realistic metrics
        DATEADD(MINUTE, -UNIFORM(1, 180, RANDOM()), CURRENT_TIMESTAMP()) AS last_ping,
        ROUND(UNIFORM(10.0, 95.0, RANDOM()), 2) AS cpu_load,
        ROUND(UNIFORM(110.0, 130.0, RANDOM()), 2) AS voltage,
        ROUND(UNIFORM(20.0, 90.0, RANDOM()), 2) AS memory_usage,
        ROUND(UNIFORM(35.0, 85.0, RANDOM()), 2) AS temperature,
        UNIFORM(1, 8760, RANDOM()) AS uptime_hours,
        -- Critical devices (20 devices with failure_prob > 0.85)
        CASE 
            WHEN d.rn <= 20 THEN ROUND(UNIFORM(0.85, 0.98, RANDOM()), 3)
            WHEN d.rn <= 50 THEN ROUND(UNIFORM(0.70, 0.84, RANDOM()), 3)
            WHEN d.rn <= 120 THEN ROUND(UNIFORM(0.50, 0.69, RANDOM()), 3)
            ELSE ROUND(UNIFORM(0.05, 0.49, RANDOM()), 3)
        END AS failure_probability
    FROM device_base d
)
SELECT 
    device_id,
    region,
    hospital_name,
    last_ping,
    cpu_load,
    voltage,
    memory_usage,
    temperature,
    uptime_hours,
    failure_probability,
    -- Assign failure type based on metrics
    CASE 
        WHEN temperature > 75 THEN 'Overheating'
        WHEN memory_usage > 85 THEN 'Memory Leak'
        WHEN cpu_load > 85 THEN 'CPU Exhaustion'
        WHEN voltage < 115 OR voltage > 125 THEN 'Power Supply Failure'
        WHEN uptime_hours > 7000 THEN 'Component Degradation'
        ELSE 'System Instability'
    END AS predicted_failure_type,
    latitude,
    longitude,
    CURRENT_TIMESTAMP() AS created_at
FROM device_metrics;

-- Verify data distribution
SELECT 
    CASE 
        WHEN failure_probability > 0.85 THEN 'Critical (>0.85)'
        WHEN failure_probability > 0.70 THEN 'High (0.70-0.85)'
        WHEN failure_probability > 0.50 THEN 'Medium (0.50-0.70)'
        ELSE 'Low (<0.50)'
    END AS risk_category,
    COUNT(*) AS device_count
FROM FLEET_HEALTH_SCORED
GROUP BY risk_category
ORDER BY MIN(failure_probability) DESC;

-- ============================================================================
-- TABLE 2: MAINTENANCE_LOGS
-- ============================================================================
-- Historical maintenance costs for ROI calculations
-- ============================================================================

CREATE OR REPLACE TABLE MAINTENANCE_LOGS (
    log_id INTEGER AUTOINCREMENT PRIMARY KEY,
    device_id VARCHAR(50),
    maintenance_date TIMESTAMP_LTZ,
    failure_type VARCHAR(100),
    downtime_hours FLOAT,
    repair_cost FLOAT,
    parts_replaced VARCHAR(500),
    technician_notes VARCHAR(2000),
    preventive BOOLEAN,  -- Was this preventive or reactive?
    created_at TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Generate historical maintenance logs (simulate 2 years of data)
INSERT INTO MAINTENANCE_LOGS (device_id, maintenance_date, failure_type, downtime_hours, repair_cost, parts_replaced, technician_notes, preventive)
SELECT 
    device_id,
    DATEADD(DAY, -UNIFORM(1, 730, RANDOM()), CURRENT_TIMESTAMP()) AS maintenance_date,
    predicted_failure_type AS failure_type,
    ROUND(UNIFORM(1.0, 48.0, RANDOM()), 1) AS downtime_hours,
    ROUND(UNIFORM(500.0, 15000.0, RANDOM()), 2) AS repair_cost,
    CASE predicted_failure_type
        WHEN 'Overheating' THEN 'Cooling fan, thermal paste'
        WHEN 'Memory Leak' THEN 'RAM modules, firmware update'
        WHEN 'CPU Exhaustion' THEN 'Processor board, heat sink'
        WHEN 'Power Supply Failure' THEN 'PSU unit, voltage regulator'
        WHEN 'Component Degradation' THEN 'Capacitors, circuit boards'
        ELSE 'Diagnostic software, calibration'
    END AS parts_replaced,
    'Routine maintenance completed. Device restored to operational status.' AS technician_notes,
    UNIFORM(0, 1, RANDOM()) < 0.3 AS preventive  -- 30% are preventive
FROM FLEET_HEALTH_SCORED
WHERE UNIFORM(0, 1, RANDOM()) < 0.4  -- ~40% of devices have had maintenance
LIMIT 200;

-- Summary of maintenance costs by failure type
SELECT 
    failure_type,
    COUNT(*) AS incident_count,
    ROUND(AVG(downtime_hours), 1) AS avg_downtime_hrs,
    ROUND(AVG(repair_cost), 2) AS avg_repair_cost,
    ROUND(SUM(repair_cost), 2) AS total_cost,
    SUM(IFF(preventive, 1, 0)) AS preventive_count,
    SUM(IFF(NOT preventive, 1, 0)) AS reactive_count
FROM MAINTENANCE_LOGS
GROUP BY failure_type
ORDER BY total_cost DESC;

-- ============================================================================
-- TABLE 3: RUNBOOK_DOCS (For Cortex Search Service)
-- ============================================================================
-- Repair manuals and troubleshooting guides
-- ============================================================================

CREATE OR REPLACE TABLE RUNBOOK_DOCS (
    doc_id INTEGER AUTOINCREMENT PRIMARY KEY,
    title VARCHAR(500),
    failure_category VARCHAR(100),
    content TEXT,
    severity VARCHAR(20),
    estimated_repair_time VARCHAR(100),
    required_tools VARCHAR(1000),
    safety_notes VARCHAR(1000),
    created_at TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()
);

-- Insert comprehensive repair documentation
INSERT INTO RUNBOOK_DOCS (title, failure_category, content, severity, estimated_repair_time, required_tools, safety_notes)
VALUES
(
    'Overheating Component Diagnostic and Repair Procedure',
    'Overheating',
    'SYMPTOMS: Device temperature exceeds 75°C consistently. Display may show thermal warnings.

DIAGNOSTIC STEPS:
1. Check ambient room temperature (should be 18-24°C)
2. Inspect cooling vents for dust accumulation or blockage
3. Verify cooling fan operation using diagnostic mode (Menu > System > Diagnostics > Fan Test)
4. Check thermal sensor readings in system logs

REPAIR PROCEDURE:
1. Power down device and disconnect from mains power
2. Remove external housing (4 Phillips screws on rear panel)
3. Use compressed air to clean all vents and internal fans
4. Inspect heat sink thermal compound - if degraded, clean with isopropyl alcohol and reapply Arctic Silver thermal paste
5. Replace cooling fan if bearing noise detected or RPM below 2000
6. Reassemble and run burn-in test for 2 hours
7. Verify temperature stabilizes below 65°C under load

PARTS NEEDED:
- Cooling fan assembly (P/N: PP-FAN-120MM-4PIN)
- Thermal compound (Arctic Silver 5)
- Cleaning supplies

POST-REPAIR VERIFICATION:
Run extended diagnostics for 4 hours. Temperature should remain 55-65°C under normal load.',
    'High',
    '2-4 hours',
    'Phillips screwdriver, compressed air, thermal paste, isopropyl alcohol, diagnostic laptop',
    'CRITICAL: Allow device to cool for 30 minutes before servicing. Wear ESD wrist strap when handling internal components.'
),
(
    'Memory Leak Resolution and RAM Module Replacement',
    'Memory Leak',
    'SYMPTOMS: Memory usage gradually increases to 90%+ over time. System slowdown, application crashes, or automatic reboots.

DIAGNOSTIC STEPS:
1. Access system console via USB debug port
2. Run memory diagnostic: "diag --mem-test --verbose"
3. Check system logs for memory allocation errors
4. Review running processes for memory leaks (commonly in data buffer processes)

SOFTWARE RESOLUTION (Try First):
1. Reboot device to clear memory
2. Update to latest firmware version (v3.2.1 or higher addresses known leaks)
3. Clear application cache: Settings > Advanced > Clear Cache
4. Disable auto-restart and monitor for 24 hours

HARDWARE REPLACEMENT (If Software Fix Fails):
1. Power down and discharge capacitors (hold power button 30 seconds while unplugged)
2. Remove system access panel
3. Locate RAM modules (2x 8GB DDR4 SO-DIMM slots)
4. Remove existing modules (press side clips, pull at 30° angle)
5. Install new certified RAM modules (P/N: PP-RAM-8GB-DDR4-2666)
6. Ensure modules click firmly into place
7. Replace access panel

POST-REPAIR VERIFICATION:
1. Boot to BIOS and verify RAM detection (16GB total)
2. Run extended memory test (Menu > Diagnostics > Memory > Extended)
3. Load test device for 8 hours, monitor memory usage - should stabilize at 40-60%

FIRMWARE UPDATE PROCEDURE:
1. Download firmware from PatientPoint portal
2. Copy to USB drive (FAT32 formatted)
3. Insert USB into service port
4. Navigate to Settings > System > Update > Install from USB
5. Do NOT power off during update (15-20 minutes)',
    'Medium',
    '1-3 hours',
    'USB debug cable, replacement RAM modules, ESD mat, diagnostic software',
    'WARNING: Always use ESD protection. Never hot-swap RAM. Ensure firmware is from official source only.'
),
(
    'CPU Exhaustion and Process Management',
    'CPU Exhaustion',
    'SYMPTOMS: CPU load consistently above 85%. System lag, delayed response to inputs, frame drops in display output.

DIAGNOSTIC STEPS:
1. Access system monitor via admin console (admin/admin default credentials)
2. Identify processes consuming high CPU (sort by CPU %)
3. Check for runaway processes or infinite loops
4. Review scheduled tasks for conflicts

IMMEDIATE MITIGATION:
1. Kill non-essential processes via console
2. Disable background analytics if enabled: Settings > Data Collection > Disable
3. Reduce display refresh rate: Settings > Display > 30Hz
4. Clear temporary files: System > Maintenance > Clear Temp

ROOT CAUSE INVESTIGATION:
Common causes ranked by frequency:
1. Corrupted data cache (45% of cases) - Solution: Clear cache partition
2. Outdated firmware (30%) - Solution: Update to v3.2.1+
3. Failed background sync (15%) - Solution: Reset network sync settings
4. Malformed patient records (10%) - Solution: Database repair tool

ADVANCED REPAIR - PROCESSOR BOARD REPLACEMENT:
(Only if above steps fail and CPU hardware fault confirmed via diagnostics)
1. This requires factory-trained technician
2. Backup all patient data to encrypted USB
3. Document device serial number and configuration
4. Order replacement processor board (P/N: PP-CPU-I5-GEN11)
5. Schedule on-site visit - 4-6 hour service window
6. Full reconfiguration and data restore required

PERFORMANCE OPTIMIZATION:
After resolving CPU issue, implement these best practices:
- Enable automatic cache clearing (weekly)
- Limit concurrent patient records to 50
- Disable unused plugins/modules
- Schedule database optimization monthly',
    'High',
    '30 minutes - 2 hours (software), 4-6 hours (hardware)',
    'Admin credentials, diagnostic console, USB backup drive, CPU diagnostic software',
    'NOTICE: Backup all patient data before advanced troubleshooting. HIPAA compliance requires encrypted transfer only.'
),
(
    'Power Supply Failure and Voltage Stabilization',
    'Power Supply Failure',
    'SYMPTOMS: Voltage readings outside 115-125V range. Random shutdowns, display flickering, power cycling.

DIAGNOSTIC STEPS:
1. Use multimeter to measure input voltage at wall outlet (should be 110-120V AC)
2. Check device voltage readings: Diagnostics > Power > Voltage Monitor
3. Inspect power cable for damage, fraying, or bent pins
4. Test with known-good power cable and outlet
5. Review system logs for power fault events

ENVIRONMENTAL FACTORS:
- Check building power quality (old wiring, inadequate circuits)
- Verify device is not sharing circuit with high-draw equipment (imaging machines, laser systems)
- Install hospital-grade power conditioner if building power is unstable
- Ensure proper grounding (3-prong outlet with verified ground)

POWER SUPPLY UNIT REPLACEMENT:
1. Order replacement PSU (P/N: PP-PSU-400W-MEDICAL)
2. Power down device, disconnect all cables, wait 5 minutes
3. Remove rear panel (6 screws)
4. Disconnect internal power cables (note positions/colors)
5. Remove old PSU (4 mounting screws)
6. Install new PSU, secure mounting
7. Reconnect all internal power cables (24-pin main, 8-pin CPU, SATA)
8. Replace rear panel

SURGE PROTECTION:
All PatientPoint devices must use:
- Medical-grade surge protector (IEC 60601-1 compliant)
- Battery backup (UPS) rated for 15-minute runtime minimum
- Isolated ground circuit recommended

VOLTAGE REGULATOR CALIBRATION:
If voltage readings are inaccurate but PSU is functional:
1. Enter service mode: Hold F8 during boot
2. Navigate to Hardware > Power > Calibration
3. Connect calibrated multimeter to test points
4. Run auto-calibration routine
5. Verify readings match multimeter within ±2V

POST-REPAIR VERIFICATION:
1. Monitor voltage for 24 hours (should be stable 120V ±5V)
2. Run power stability test: Diagnostics > Power > Stress Test (4 hours)
3. Document baseline voltage readings for future reference',
    'Critical',
    '2-4 hours',
    'Multimeter, replacement PSU, Phillips screwdriver set, UPS system, power quality analyzer',
    'DANGER: Work on live electrical systems prohibited. Disconnect power before servicing. Verify ground with multimeter. Use medical-grade replacement parts only.'
),
(
    'Component Degradation and Preventive Maintenance Schedule',
    'Component Degradation',
    'OVERVIEW: Devices with 7000+ operational hours show accelerated component wear. Proactive replacement prevents failures.

COMPONENT LIFESPAN GUIDELINES:
- Cooling fans: 15,000 hours (replace at 12,000)
- Electrolytic capacitors: 20,000 hours (inspect at 15,000)
- Hard drive/SSD: 30,000 hours or 5 years
- LCD display backlight: 40,000 hours
- Power supply: 40,000 hours
- Lithium backup battery: 3 years (replace regardless of hours)

ANNUAL PREVENTIVE MAINTENANCE (APM) CHECKLIST:
□ Visual inspection of all external ports and cables
□ Clean all vents and filters with compressed air
□ Verify cooling fan operation and bearing noise
□ Update firmware to latest stable version
□ Check internal component temperatures
□ Inspect capacitors for bulging or leaking
□ Test battery backup system (should hold charge 5+ minutes)
□ Verify all indicator LEDs functional
□ Clean touchscreen and external surfaces
□ Run full diagnostic suite (2-hour test)
□ Review and clear system logs
□ Backup device configuration
□ Update maintenance log with findings

CAPACITOR FAILURE INDICATORS:
- Visual: Bulging top, leaking electrolyte
- Symptoms: Random reboots, power issues, instability
- Location: Main board near power input (C1-C8)
- Replacement: Send to depot repair or replace entire board

PREDICTIVE MAINTENANCE INTERVALS:
Based on device age and usage:
- 0-2 years (0-17,520 hrs): Annual inspection only
- 2-4 years: Semi-annual inspection, fan replacement
- 4-6 years: Quarterly inspection, capacitor replacement, consider lifecycle refresh
- 6+ years: Monthly monitoring, plan device replacement

DEPOT REPAIR PROGRAM:
For devices needing extensive refurbishment:
1. Request RMA number from support portal
2. Backup and wipe all patient data
3. Ship device in approved packaging
4. Typical turnaround: 5-7 business days
5. Receive refurbished device with 90-day warranty

SPARE PARTS INVENTORY (Recommended for 50+ device fleets):
- 2x cooling fan assemblies
- 1x power supply unit
- 4x RAM modules (8GB)
- 1x replacement hard drive
- Thermal paste, cleaning supplies
- Diagnostic USB drive',
    'Medium',
    'Ongoing preventive maintenance',
    'Complete maintenance toolkit, compressed air, replacement parts inventory, diagnostic equipment',
    'NOTE: Preventive maintenance reduces reactive service calls by 60%. Track device hours in fleet management system. Use certified parts only to maintain warranty.'
),
(
    'System Instability and Software Corruption Recovery',
    'System Instability',
    'SYMPTOMS: Random crashes, application errors, blue screen events, data corruption, boot failures.

DIAGNOSTIC APPROACH (Start with least invasive):

LEVEL 1 - SOFT RESET:
1. Reboot device (may resolve transient issues)
2. Check for recent changes (new software, configuration changes)
3. Review system logs for error patterns
4. Run built-in diagnostics: Menu > System > Diagnostics > Quick Test

LEVEL 2 - CONFIGURATION RESET:
1. Backup current settings: Settings > System > Export Configuration
2. Reset to factory defaults: Settings > System > Factory Reset
3. Reconfigure device per facility standards
4. Restore patient data from backup
5. Test for 48 hours

LEVEL 3 - SOFTWARE RELOAD:
1. Download latest OS image from PatientPoint portal (requires admin access)
2. Create bootable USB installer
3. Backup ALL data to encrypted external drive
4. Boot from USB (F12 during startup)
5. Select "Clean Install" option
6. Follow on-screen prompts (45-60 minutes)
7. Install device drivers (included on USB)
8. Restore configuration and data

LEVEL 4 - HARDWARE DIAGNOSTICS:
If instability persists after software reload:
1. Run extended memory test (8+ hours)
2. Run hard drive SMART diagnostics
3. Check for loose internal connections
4. Reseat RAM modules and expansion cards
5. Replace hard drive if SMART errors detected
6. Consider motherboard replacement if all else fails

COMMON CORRUPTION CAUSES:
- Sudden power loss (improper shutdown)
- Failed firmware update
- Hard drive failure/bad sectors
- Malware or unauthorized software
- Physical shock or drop

DATA RECOVERY (If device will not boot):
1. Remove hard drive/SSD
2. Connect to diagnostic workstation via SATA/USB adapter
3. Use PatientPoint Data Recovery Tool (requires license)
4. Extract patient records to secure location
5. Verify data integrity with checksum tool
6. Transfer to replacement device

PREVENTING FUTURE INSTABILITY:
- Always use UPS to prevent sudden power loss
- Apply firmware updates during scheduled maintenance windows
- Regularly backup configurations (weekly recommended)
- Implement automatic error reporting
- Monitor device health metrics daily
- Train staff on proper shutdown procedures',
    'Variable',
    '30 minutes - 8 hours depending on level',
    'Bootable USB drive, backup storage, diagnostic workstation, OS installation media, admin credentials',
    'CRITICAL: Ensure HIPAA-compliant data handling during recovery. Encrypt all backups. Never use unauthorized software. Document all troubleshooting steps in service log.'
);

-- Verify documentation coverage
SELECT 
    failure_category,
    COUNT(*) AS doc_count,
    LISTAGG(title, ' | ') WITHIN GROUP (ORDER BY title) AS available_guides
FROM RUNBOOK_DOCS
GROUP BY failure_category;

-- ============================================================================
-- CORTEX SEARCH SERVICE FOR RUNBOOK_DOCS
-- ============================================================================
-- This creates a search service for intelligent document retrieval
-- The Cortex Agent will use this for unstructured queries
-- ============================================================================

-- Create Cortex Search Service on the runbook documentation
CREATE OR REPLACE CORTEX SEARCH SERVICE RUNBOOK_SEARCH_SERVICE
ON content
ATTRIBUTES title, failure_category, severity, estimated_repair_time, required_tools, safety_notes
WAREHOUSE = COMPUTE_WH
TARGET_LAG = '1 hour'
AS (
    SELECT 
        doc_id,
        title,
        failure_category,
        content,
        severity,
        estimated_repair_time,
        required_tools,
        safety_notes
    FROM RUNBOOK_DOCS
);

-- Test the search service (optional - uncomment to test after setup)
/*
SELECT
  SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'PATIENTPOINT_OPS.DEVICE_ANALYTICS.RUNBOOK_SEARCH_SERVICE',
    '{
      "query": "How do I fix an overheating device?",
      "columns": ["title", "failure_category", "content", "severity"],
      "limit": 3
    }'
  );
*/

-- ============================================================================
-- HELPER VIEWS FOR DASHBOARD
-- ============================================================================

-- View for real-time fleet health metrics
CREATE OR REPLACE VIEW VW_FLEET_HEALTH_METRICS AS
SELECT 
    COUNT(*) AS total_devices,
    SUM(CASE WHEN failure_probability > 0.85 THEN 1 ELSE 0 END) AS critical_devices,
    SUM(CASE WHEN failure_probability > 0.70 THEN 1 ELSE 0 END) AS high_risk_devices,
    ROUND(AVG(failure_probability), 3) AS avg_failure_probability,
    SUM(CASE WHEN failure_probability > 0.80 THEN 50 * 24 ELSE 0 END) AS revenue_at_risk_usd,
    SUM(CASE WHEN DATEDIFF(MINUTE, last_ping, CURRENT_TIMESTAMP()) > 60 THEN 1 ELSE 0 END) AS offline_devices
FROM FLEET_HEALTH_SCORED;

-- View for regional breakdown
CREATE OR REPLACE VIEW VW_REGIONAL_HEALTH AS
SELECT 
    region,
    COUNT(*) AS total_devices,
    SUM(CASE WHEN failure_probability > 0.85 THEN 1 ELSE 0 END) AS critical_count,
    ROUND(AVG(failure_probability), 3) AS avg_failure_prob,
    SUM(CASE WHEN failure_probability > 0.80 THEN 50 * 24 ELSE 0 END) AS revenue_at_risk
FROM FLEET_HEALTH_SCORED
GROUP BY region
ORDER BY critical_count DESC;

-- View for failure type analysis
CREATE OR REPLACE VIEW VW_FAILURE_TYPE_ANALYSIS AS
SELECT 
    predicted_failure_type,
    COUNT(*) AS device_count,
    ROUND(AVG(failure_probability), 3) AS avg_probability,
    ROUND(AVG(cpu_load), 2) AS avg_cpu_load,
    ROUND(AVG(memory_usage), 2) AS avg_memory_usage,
    ROUND(AVG(temperature), 2) AS avg_temperature
FROM FLEET_HEALTH_SCORED
WHERE failure_probability > 0.70
GROUP BY predicted_failure_type
ORDER BY device_count DESC;

-- ============================================================================
-- GRANT PERMISSIONS (Adjust role as needed for your environment)
-- ============================================================================

GRANT USAGE ON DATABASE PATIENTPOINT_OPS TO ROLE PUBLIC;
GRANT USAGE ON SCHEMA PATIENTPOINT_OPS.DEVICE_ANALYTICS TO ROLE PUBLIC;
GRANT SELECT ON ALL TABLES IN SCHEMA PATIENTPOINT_OPS.DEVICE_ANALYTICS TO ROLE PUBLIC;
GRANT SELECT ON ALL VIEWS IN SCHEMA PATIENTPOINT_OPS.DEVICE_ANALYTICS TO ROLE PUBLIC;
GRANT USAGE ON CORTEX SEARCH SERVICE RUNBOOK_SEARCH_SERVICE TO ROLE PUBLIC;

-- ============================================================================
-- VERIFICATION QUERIES (Optional - uncomment to test after setup)
-- ============================================================================

-- Fleet summary metrics
-- SELECT * FROM VW_FLEET_HEALTH_METRICS;

-- Top critical devices
/*
SELECT 
    device_id,
    hospital_name,
    region,
    failure_probability,
    predicted_failure_type
FROM FLEET_HEALTH_SCORED 
WHERE failure_probability > 0.85 
ORDER BY failure_probability DESC 
LIMIT 5;
*/

-- ============================================================================
-- OPTIONAL: SCHEDULED TASK TO REFRESH INFERENCE DATA
-- ============================================================================
-- Uncomment to enable automatic refresh of inference scores
-- In production, this would run your actual ML pipeline
-- ============================================================================

/*
CREATE OR REPLACE TASK REFRESH_FLEET_HEALTH_SCORES
    WAREHOUSE = COMPUTE_WH
    SCHEDULE = 'USING CRON 0 * * * * America/New_York'  -- Every hour
AS
    -- Simulate ML inference refresh by adding noise to existing scores
    UPDATE FLEET_HEALTH_SCORED
    SET 
        failure_probability = LEAST(0.99, GREATEST(0.01, failure_probability + UNIFORM(-0.05, 0.05, RANDOM()))),
        last_ping = CURRENT_TIMESTAMP(),
        cpu_load = ROUND(UNIFORM(10.0, 95.0, RANDOM()), 2),
        voltage = ROUND(UNIFORM(110.0, 130.0, RANDOM()), 2),
        memory_usage = ROUND(UNIFORM(20.0, 90.0, RANDOM()), 2),
        temperature = ROUND(UNIFORM(35.0, 85.0, RANDOM()), 2);

-- Enable the task
ALTER TASK REFRESH_FLEET_HEALTH_SCORES RESUME;
*/

-- ============================================================================
-- SETUP COMPLETE
-- ============================================================================
SELECT 'Backend setup complete! Ready to launch the PatientPoint Command Center dashboard.' AS status;

