/*
=============================================================================
PatientPoint Ad Tech Optimization Demo - Database Setup
=============================================================================
This script creates the database, schemas, and warehouses for the demo.
All objects use the SF_INTELLIGENCE_DEMO role.

Run this script first before any other scripts.
=============================================================================
*/

-- ============================================================================
-- STEP 1: Use the designated role
-- ============================================================================
USE ROLE SF_INTELLIGENCE_DEMO;

-- ============================================================================
-- STEP 2: Create Database
-- ============================================================================
CREATE DATABASE IF NOT EXISTS AD_TECH;

USE DATABASE AD_TECH;

-- ============================================================================
-- STEP 3: Create Schemas
-- ============================================================================

-- Raw/staging data
CREATE SCHEMA IF NOT EXISTS AD_TECH.RAW;

-- Conformed dimension and fact tables
CREATE SCHEMA IF NOT EXISTS AD_TECH.ANALYTICS;

-- Cortex services and agents
CREATE SCHEMA IF NOT EXISTS AD_TECH.CORTEX;

-- Streamlit applications
CREATE SCHEMA IF NOT EXISTS AD_TECH.APPS;

-- ============================================================================
-- STEP 4: Create Warehouses
-- ============================================================================

-- Main warehouse for queries and Cortex services
CREATE WAREHOUSE IF NOT EXISTS AD_TECH_WH
    WAREHOUSE_SIZE = 'MEDIUM'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Primary warehouse for PatientPoint Ad Tech demo';

-- Set default warehouse
USE WAREHOUSE AD_TECH_WH;

-- ============================================================================
-- STEP 5: Grant permissions (if needed for other roles)
-- ============================================================================

-- Grant usage on database to the role (already owner, but explicit)
GRANT USAGE ON DATABASE AD_TECH TO ROLE SF_INTELLIGENCE_DEMO;
GRANT USAGE ON ALL SCHEMAS IN DATABASE AD_TECH TO ROLE SF_INTELLIGENCE_DEMO;
GRANT ALL PRIVILEGES ON ALL SCHEMAS IN DATABASE AD_TECH TO ROLE SF_INTELLIGENCE_DEMO;

-- Future grants for any new objects
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA AD_TECH.RAW TO ROLE SF_INTELLIGENCE_DEMO;
GRANT ALL PRIVILEGES ON FUTURE TABLES IN SCHEMA AD_TECH.ANALYTICS TO ROLE SF_INTELLIGENCE_DEMO;
GRANT ALL PRIVILEGES ON FUTURE VIEWS IN SCHEMA AD_TECH.ANALYTICS TO ROLE SF_INTELLIGENCE_DEMO;

-- ============================================================================
-- STEP 6: Verify Setup
-- ============================================================================
SHOW DATABASES LIKE 'AD_TECH';
SHOW SCHEMAS IN DATABASE AD_TECH;
SHOW WAREHOUSES LIKE 'AD_TECH_WH';

SELECT 'Database setup complete!' AS status;

