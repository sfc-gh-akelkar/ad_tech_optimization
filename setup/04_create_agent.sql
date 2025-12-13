/*******************************************************************************
 * PATIENTPOINT PREDICTIVE MAINTENANCE DEMO
 * Part 4: Cortex Agent Setup for Snowflake Intelligence
 * 
 * Creates the Cortex Agent that will be used in Snowflake Intelligence
 * Following best practices from:
 * https://github.com/Snowflake-Labs/sfquickstarts/blob/master/site/sfguides/src/best-practices-to-building-cortex-agents/best-practices-to-building-cortex-agents.md
 * 
 * The agent uses:
 * - Cortex Analyst (via semantic model) for structured device/maintenance data
 * - Cortex Search for troubleshooting knowledge base
 * 
 * Prerequisites: Run 01, 02, and 03 scripts first
 ******************************************************************************/

-- ============================================================================
-- USE DEMO ROLE
-- ============================================================================
USE ROLE SF_INTELLIGENCE_DEMO;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE PATIENTPOINT_MAINTENANCE;
USE SCHEMA DEVICE_OPS;

-- ============================================================================
-- STEP 1: CREATE THE AGENT OBJECT
-- This creates a basic agent that we'll configure with tools
-- ============================================================================

-- Create the agent via SQL (can also be done via Snowsight UI)
CREATE OR REPLACE CORTEX AGENT DEVICE_MAINTENANCE_AGENT
    COMMENT = 'AI Agent for PatientPoint device predictive maintenance. Monitors device health, diagnoses issues, searches troubleshooting guides, and provides maintenance recommendations.'
;

-- ============================================================================
-- STEP 2: CONFIGURE AGENT VIA ALTER STATEMENTS
-- Add tools, instructions, and sample questions
-- ============================================================================

-- Note: The full agent configuration is typically done via:
-- 1. Snowsight UI (AI & ML > Agents) - RECOMMENDED for demos
-- 2. REST API
-- 3. SQL ALTER statements (limited functionality)

-- For Snowflake Intelligence, the recommended approach is to:
-- 1. Create the agent via Snowsight UI
-- 2. Add a Semantic View for Cortex Analyst (structured data queries)
-- 3. Add Cortex Search services (unstructured knowledge search)
-- 4. Configure instructions and sample questions

-- ============================================================================
-- AGENT CONFIGURATION REFERENCE (for Snowsight UI setup)
-- ============================================================================

/*
AGENT CONFIGURATION STEPS IN SNOWSIGHT:

1. Navigate to: AI & ML > Agents
2. Click "Create agent"
3. Configure the following:

BASIC INFO:
-----------
Agent Name: DEVICE_MAINTENANCE_AGENT
Display Name: Device Maintenance Assistant
Description: 
  I help you monitor and maintain PatientPoint HealthScreen devices. 
  I can check device health, find troubleshooting procedures, 
  analyze maintenance trends, and recommend actions.

TOOLS TO ADD:
-------------

A) CORTEX ANALYST (for structured data queries)
   - Name: DeviceAnalytics
   - Type: Cortex Analyst
   - Semantic View: PATIENTPOINT_MAINTENANCE.DEVICE_OPS.SV_DEVICE_MAINTENANCE
     (or use semantic model file from stage)
   - Warehouse: COMPUTE_WH
   - Query Timeout: 30 seconds
   - Description: Query device health metrics, maintenance history, 
     fleet statistics, and cost analytics

B) CORTEX SEARCH - Troubleshooting KB
   - Name: TroubleshootingGuide
   - Type: Cortex Search
   - Service: PATIENTPOINT_MAINTENANCE.DEVICE_OPS.TROUBLESHOOTING_SEARCH_SVC
   - Max Results: 5
   - Description: Search troubleshooting procedures, diagnostic steps, 
     and fix instructions for device issues

C) CORTEX SEARCH - Maintenance History
   - Name: PastIncidents  
   - Type: Cortex Search
   - Service: PATIENTPOINT_MAINTENANCE.DEVICE_OPS.MAINTENANCE_HISTORY_SEARCH_SVC
   - Max Results: 5
   - Description: Search past maintenance tickets and resolutions 
     to find similar issues and proven solutions

INSTRUCTIONS:
-------------
Response Instructions:
  You are the PatientPoint Device Maintenance Assistant. Your role is to help 
  operations teams monitor, diagnose, and maintain HealthScreen devices 
  deployed across healthcare facilities.

  When responding:
  - Be concise but thorough
  - Include specific device IDs and metrics when available
  - Recommend actions based on the data
  - Prioritize remote fixes over field dispatches when possible
  - Always explain your reasoning

  For device health questions, use DeviceAnalytics to query current metrics.
  For troubleshooting guidance, search TroubleshootingGuide for procedures.
  For similar past issues, search PastIncidents for resolutions that worked.

SAMPLE QUESTIONS:
-----------------
- What is the current health status of our device fleet?
- Which devices need immediate attention?
- How do I fix a frozen display screen?
- Show me devices in Ohio with low health scores
- What issues have we resolved remotely this month?
- How much money have we saved from remote fixes?
- Find past incidents similar to high CPU usage
- What's the average resolution time for network issues?
- Which devices are predicted to fail in the next 48 hours?
- What is our prediction accuracy based on historical data?
- Show me devices with rising CPU temperature trends
- How much revenue have we lost due to device downtime?
- Which facilities have the lowest satisfaction scores?
- What is our average NPS score?
- Which providers need follow-up due to negative feedback?

*/

-- ============================================================================
-- STEP 3: CREATE SEMANTIC VIEW FOR CORTEX ANALYST
-- This is the modern approach for structured data access
-- ============================================================================

-- Create the semantic view that Cortex Analyst will use
CREATE OR REPLACE SEMANTIC VIEW SV_DEVICE_MAINTENANCE
  COMMENT = 'Semantic view for device health and maintenance analytics'
  TABLES (
    -- Device Health table
    V_DEVICE_HEALTH_SUMMARY AS devices
      COLUMNS (
        DEVICE_ID AS device_id 
          COMMENT 'Unique device identifier'
          SYNONYMS ('device', 'screen', 'unit'),
        DEVICE_MODEL AS model
          COMMENT 'Device model (Pro 55, Lite 32, Max 65)'
          SYNONYMS ('device model', 'screen type', 'product'),
        FACILITY_NAME AS facility
          COMMENT 'Healthcare facility name'
          SYNONYMS ('location', 'clinic', 'hospital', 'office'),
        FACILITY_TYPE AS facility_type
          COMMENT 'Type of facility (Hospital, Primary Care, etc.)',
        LOCATION_STATE AS state
          COMMENT 'State location (2-letter code)',
        LOCATION_CITY AS city
          COMMENT 'City location',
        STATUS AS status
          COMMENT 'Current status (ONLINE, DEGRADED, OFFLINE)'
          SYNONYMS ('device status', 'state', 'condition'),
        HEALTH_SCORE AS health_score
          COMMENT 'Health score 0-100, higher is better'
          SYNONYMS ('health', 'score', 'device health'),
        RISK_LEVEL AS risk_level
          COMMENT 'Risk classification (LOW, MEDIUM, HIGH, CRITICAL)'
          SYNONYMS ('risk', 'priority'),
        PRIMARY_ISSUE AS issue
          COMMENT 'Primary issue affecting the device'
          SYNONYMS ('problem', 'main issue'),
        CPU_TEMP_CELSIUS AS cpu_temp
          COMMENT 'CPU temperature in Celsius',
        CPU_USAGE_PCT AS cpu_usage
          COMMENT 'CPU usage percentage',
        MEMORY_USAGE_PCT AS memory_usage
          COMMENT 'Memory usage percentage',
        ERROR_COUNT AS errors
          COMMENT 'Number of errors logged',
        DAYS_SINCE_MAINTENANCE AS days_since_service
          COMMENT 'Days since last maintenance'
      ),
    -- Maintenance Analytics table  
    V_MAINTENANCE_ANALYTICS AS maintenance
      COLUMNS (
        TICKET_ID AS ticket_id
          COMMENT 'Maintenance ticket ID'
          SYNONYMS ('ticket', 'case', 'incident'),
        DEVICE_ID AS device_id
          COMMENT 'Device that was serviced',
        ISSUE_TYPE AS issue_type
          COMMENT 'Category of issue (DISPLAY_FREEZE, HIGH_CPU, etc.)'
          SYNONYMS ('problem type', 'issue category'),
        RESOLUTION_TYPE AS resolution_type
          COMMENT 'How resolved (REMOTE_FIX, FIELD_DISPATCH, REPLACEMENT)'
          SYNONYMS ('fix type', 'how fixed'),
        COST_USD AS cost
          COMMENT 'Cost of maintenance in USD'
          SYNONYMS ('maintenance cost', 'expense'),
        RESOLUTION_TIME_MINS AS resolution_time
          COMMENT 'Time to resolve in minutes'
          SYNONYMS ('time to fix', 'mttr'),
        COST_SAVINGS_USD AS savings
          COMMENT 'Cost savings from remote fix'
          SYNONYMS ('money saved'),
        WAS_REMOTE_FIX AS fixed_remotely
          COMMENT 'Whether issue was fixed remotely',
        CREATED_AT AS ticket_date
          COMMENT 'When the ticket was created'
          SYNONYMS ('date', 'when')
      ),
    -- Failure Predictions table (requires script 05 to be run first)
    V_FAILURE_PREDICTIONS AS predictions
      COLUMNS (
        DEVICE_ID AS device_id
          COMMENT 'Device identifier',
        FACILITY_NAME AS facility
          COMMENT 'Healthcare facility name',
        LOCATION AS location
          COMMENT 'City and state',
        FAILURE_PROBABILITY_PCT AS failure_probability
          COMMENT 'Predicted probability of failure (0-100%)'
          SYNONYMS ('failure risk', 'risk percentage', 'probability'),
        PREDICTION_CATEGORY AS prediction_category
          COMMENT 'Risk category (CRITICAL, HIGH, MEDIUM, LOW, HEALTHY)'
          SYNONYMS ('risk level', 'prediction'),
        PREDICTED_HOURS_TO_FAILURE AS hours_to_failure
          COMMENT 'Predicted hours until device failure'
          SYNONYMS ('time to failure', 'when will it fail'),
        ESTIMATED_FAILURE_TIME AS failure_time
          COMMENT 'Estimated timestamp of failure',
        PRIMARY_RISK_FACTOR AS risk_factor
          COMMENT 'Main factor contributing to failure risk'
          SYNONYMS ('cause', 'reason', 'why'),
        RECOMMENDED_ACTION AS recommended_action
          COMMENT 'Suggested action to prevent failure'
          SYNONYMS ('what to do', 'action', 'recommendation'),
        TEMP_TREND_24H AS temperature_trend
          COMMENT 'CPU temperature change over 24 hours',
        CPU_TREND_24H AS cpu_trend
          COMMENT 'CPU usage change over 24 hours',
        MEMORY_TREND_24H AS memory_trend
          COMMENT 'Memory usage change over 24 hours'
      ),
    -- Revenue Impact table
    V_REVENUE_IMPACT AS revenue
      COLUMNS (
        DEVICE_ID AS device_id
          COMMENT 'Device identifier',
        FACILITY_NAME AS facility
          COMMENT 'Healthcare facility name',
        HOURLY_AD_REVENUE_USD AS hourly_revenue
          COMMENT 'Advertising revenue per hour'
          SYNONYMS ('revenue per hour', 'ad revenue'),
        DOWNTIME_INCIDENTS AS downtime_count
          COMMENT 'Number of downtime incidents'
          SYNONYMS ('outages', 'incidents'),
        TOTAL_DOWNTIME_HOURS AS downtime_hours
          COMMENT 'Total hours of downtime'
          SYNONYMS ('hours offline', 'outage hours'),
        TOTAL_REVENUE_LOSS_USD AS revenue_loss
          COMMENT 'Total revenue lost due to downtime'
          SYNONYMS ('lost revenue', 'money lost', 'revenue impact'),
        TOTAL_IMPRESSIONS_LOST AS impressions_lost
          COMMENT 'Ad impressions lost due to downtime',
        UPTIME_PERCENTAGE AS uptime
          COMMENT 'Percentage of time device was online'
          SYNONYMS ('availability', 'uptime rate'),
        POTENTIAL_MONTHLY_REVENUE AS potential_revenue
          COMMENT 'Maximum possible monthly revenue if 100% uptime',
        ACTUAL_MONTHLY_REVENUE AS actual_revenue
          COMMENT 'Actual monthly revenue after downtime'
      ),
    -- Customer Satisfaction table
    V_CUSTOMER_SATISFACTION AS satisfaction
      COLUMNS (
        FACILITY_NAME AS facility
          COMMENT 'Healthcare facility name',
        DEVICE_ID AS device_id
          COMMENT 'Device identifier',
        AVG_NPS_SCORE AS nps_score
          COMMENT 'Average Net Promoter Score (-100 to 100)'
          SYNONYMS ('nps', 'net promoter score', 'promoter score'),
        AVG_SATISFACTION AS satisfaction_rating
          COMMENT 'Average satisfaction rating (1-5)'
          SYNONYMS ('satisfaction', 'rating', 'stars'),
        AVG_RESPONSE_TIME_RATING AS response_rating
          COMMENT 'Average response time rating (1-5)',
        AVG_RELIABILITY_RATING AS reliability_rating
          COMMENT 'Average device reliability rating (1-5)',
        POSITIVE_COUNT AS positive_feedback
          COMMENT 'Number of positive feedback responses',
        NEGATIVE_COUNT AS negative_feedback
          COMMENT 'Number of negative feedback responses',
        FOLLOW_UPS_REQUIRED AS pending_follow_ups
          COMMENT 'Number of pending follow-up actions',
        NPS_CATEGORY AS nps_category
          COMMENT 'NPS classification (PROMOTER, PASSIVE, DETRACTOR)'
      )
  )
;

-- Grant usage on the semantic view to the demo role
-- (Already owned by SF_INTELLIGENCE_DEMO, but explicit grant for clarity)
GRANT USAGE ON SEMANTIC VIEW SV_DEVICE_MAINTENANCE TO ROLE SF_INTELLIGENCE_DEMO;

-- ============================================================================
-- STEP 4: REGISTER AGENT WITH SNOWFLAKE INTELLIGENCE
-- Makes the agent visible in the Snowflake Intelligence UI
-- ============================================================================

-- Check if Snowflake Intelligence object exists
SHOW SNOWFLAKE INTELLIGENCES;

-- Add the agent to Snowflake Intelligence (run after creating agent via UI)
-- ALTER SNOWFLAKE INTELLIGENCE SNOWFLAKE_INTELLIGENCE_OBJECT_DEFAULT 
--     ADD AGENT PATIENTPOINT_MAINTENANCE.DEVICE_OPS.DEVICE_MAINTENANCE_AGENT;

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Verify agent was created
SHOW CORTEX AGENTS IN SCHEMA DEVICE_OPS;

-- Verify semantic view
SHOW SEMANTIC VIEWS IN SCHEMA DEVICE_OPS;

-- Test the semantic view with sample queries
SELECT * FROM V_DEVICE_HEALTH_SUMMARY WHERE RISK_LEVEL = 'HIGH' LIMIT 5;
SELECT * FROM V_MAINTENANCE_ANALYTICS WHERE RESOLUTION_TYPE = 'REMOTE_FIX' LIMIT 5;

