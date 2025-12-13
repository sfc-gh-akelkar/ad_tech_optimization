/*******************************************************************************
 * PATIENTPOINT PREDICTIVE MAINTENANCE DEMO
 * Part 3: Cortex Search Services
 * 
 * Creates Cortex Search services over:
 * - Troubleshooting knowledge base (diagnostic procedures)
 * - Maintenance history (past incidents and resolutions)
 * 
 * These enable RAG-based retrieval for the AI agent
 * 
 * Prerequisites: Run 01 and 02 scripts first
 ******************************************************************************/

-- ============================================================================
-- USE DEMO ROLE
-- ============================================================================
USE ROLE SF_INTELLIGENCE_DEMO;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE PATIENTPOINT_MAINTENANCE;
USE SCHEMA DEVICE_OPS;

-- ============================================================================
-- PREPARE KNOWLEDGE BASE FOR CORTEX SEARCH
-- Combine all relevant text fields into a searchable document
-- ============================================================================
CREATE OR REPLACE TABLE TROUBLESHOOTING_KB_SEARCH AS
SELECT 
    KB_ID,
    ISSUE_CATEGORY,
    ISSUE_SYMPTOMS,
    DIAGNOSTIC_STEPS,
    REMOTE_FIX_PROCEDURE,
    REQUIRES_DISPATCH,
    ESTIMATED_REMOTE_FIX_TIME_MINS,
    SUCCESS_RATE_PCT,
    -- Combined searchable content
    CONCAT(
        'Issue Category: ', ISSUE_CATEGORY, '\n\n',
        'Symptoms: ', ISSUE_SYMPTOMS, '\n\n',
        'Diagnostic Steps: ', DIAGNOSTIC_STEPS, '\n\n',
        'Remote Fix Procedure: ', REMOTE_FIX_PROCEDURE, '\n\n',
        'Requires Field Dispatch: ', IFF(REQUIRES_DISPATCH, 'Yes - this issue typically requires a technician on-site', 'No - this can usually be fixed remotely'), '\n',
        'Estimated Fix Time: ', COALESCE(ESTIMATED_REMOTE_FIX_TIME_MINS::VARCHAR, 'N/A - Requires Dispatch'), ' minutes\n',
        'Historical Success Rate: ', SUCCESS_RATE_PCT::VARCHAR, '%'
    ) AS SEARCH_CONTENT
FROM TROUBLESHOOTING_KB;

-- ============================================================================
-- CREATE MAINTENANCE HISTORY SEARCH TABLE
-- Enable searching past incidents and resolutions
-- ============================================================================
CREATE OR REPLACE TABLE MAINTENANCE_HISTORY_SEARCH AS
SELECT 
    m.TICKET_ID,
    m.DEVICE_ID,
    d.DEVICE_MODEL,
    d.FACILITY_NAME,
    d.FACILITY_TYPE,
    d.LOCATION_CITY,
    d.LOCATION_STATE,
    m.ISSUE_TYPE,
    m.ISSUE_DESCRIPTION,
    m.RESOLUTION_TYPE,
    m.RESOLUTION_NOTES,
    m.COST_USD,
    m.CREATED_AT,
    m.RESOLVED_AT,
    DATEDIFF('minute', m.CREATED_AT, m.RESOLVED_AT) as RESOLUTION_TIME_MINS,
    -- Combined searchable content
    CONCAT(
        'Maintenance Ticket: ', m.TICKET_ID, '\n',
        'Device: ', m.DEVICE_ID, ' (', d.DEVICE_MODEL, ')\n',
        'Facility: ', d.FACILITY_NAME, ' - ', d.FACILITY_TYPE, '\n',
        'Location: ', d.LOCATION_CITY, ', ', d.LOCATION_STATE, '\n\n',
        'Issue Type: ', m.ISSUE_TYPE, '\n',
        'Problem Description: ', m.ISSUE_DESCRIPTION, '\n\n',
        'How it was resolved: ', m.RESOLUTION_TYPE, '\n',
        'Resolution Details: ', m.RESOLUTION_NOTES, '\n',
        'Cost: $', COALESCE(m.COST_USD::VARCHAR, '0'), '\n',
        'Time to Resolve: ', DATEDIFF('minute', m.CREATED_AT, m.RESOLVED_AT)::VARCHAR, ' minutes'
    ) AS SEARCH_CONTENT
FROM MAINTENANCE_HISTORY m
JOIN DEVICE_INVENTORY d ON m.DEVICE_ID = d.DEVICE_ID;

-- ============================================================================
-- CREATE CORTEX SEARCH SERVICE FOR TROUBLESHOOTING KB
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE TROUBLESHOOTING_SEARCH_SVC
    ON SEARCH_CONTENT
    ATTRIBUTES ISSUE_CATEGORY, REQUIRES_DISPATCH
    WAREHOUSE = COMPUTE_WH  -- Adjust to your warehouse name
    TARGET_LAG = '1 hour'
AS (
    SELECT 
        KB_ID,
        ISSUE_CATEGORY,
        ISSUE_SYMPTOMS,
        DIAGNOSTIC_STEPS,
        REMOTE_FIX_PROCEDURE,
        REQUIRES_DISPATCH,
        ESTIMATED_REMOTE_FIX_TIME_MINS,
        SUCCESS_RATE_PCT,
        SEARCH_CONTENT
    FROM TROUBLESHOOTING_KB_SEARCH
);

-- ============================================================================
-- CREATE CORTEX SEARCH SERVICE FOR MAINTENANCE HISTORY
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE MAINTENANCE_HISTORY_SEARCH_SVC
    ON SEARCH_CONTENT
    ATTRIBUTES ISSUE_TYPE, RESOLUTION_TYPE, DEVICE_MODEL, LOCATION_STATE
    WAREHOUSE = COMPUTE_WH  -- Adjust to your warehouse name
    TARGET_LAG = '1 hour'
AS (
    SELECT 
        TICKET_ID,
        DEVICE_ID,
        DEVICE_MODEL,
        FACILITY_NAME,
        FACILITY_TYPE,
        LOCATION_CITY,
        LOCATION_STATE,
        ISSUE_TYPE,
        ISSUE_DESCRIPTION,
        RESOLUTION_TYPE,
        RESOLUTION_NOTES,
        COST_USD,
        CREATED_AT,
        RESOLVED_AT,
        RESOLUTION_TIME_MINS,
        SEARCH_CONTENT
    FROM MAINTENANCE_HISTORY_SEARCH
);

-- ============================================================================
-- VERIFY CORTEX SEARCH SERVICES
-- ============================================================================
SHOW CORTEX SEARCH SERVICES IN SCHEMA DEVICE_OPS;

-- ============================================================================
-- TEST QUERIES
-- ============================================================================

-- Test: Find troubleshooting steps for a frozen screen
SELECT SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'PATIENTPOINT_MAINTENANCE.DEVICE_OPS.TROUBLESHOOTING_SEARCH_SVC',
    '{
        "query": "screen is frozen and not responding to touch input",
        "columns": ["KB_ID", "ISSUE_CATEGORY", "ISSUE_SYMPTOMS", "REMOTE_FIX_PROCEDURE", "SUCCESS_RATE_PCT"],
        "limit": 3
    }'
);

-- Test: Find past incidents with high CPU issues
SELECT SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'PATIENTPOINT_MAINTENANCE.DEVICE_OPS.MAINTENANCE_HISTORY_SEARCH_SVC',
    '{
        "query": "device running slow with high CPU usage",
        "columns": ["TICKET_ID", "DEVICE_ID", "ISSUE_TYPE", "RESOLUTION_TYPE", "RESOLUTION_NOTES"],
        "limit": 3
    }'
);

-- Test: Find issues that required field dispatch
SELECT SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'PATIENTPOINT_MAINTENANCE.DEVICE_OPS.TROUBLESHOOTING_SEARCH_SVC',
    '{
        "query": "what issues require sending a technician on site",
        "columns": ["ISSUE_CATEGORY", "ISSUE_SYMPTOMS", "REQUIRES_DISPATCH"],
        "filter": {"@eq": {"REQUIRES_DISPATCH": true}},
        "limit": 5
    }'
);

