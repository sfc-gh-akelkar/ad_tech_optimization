/*
=============================================================================
PatientPoint Ad Tech Optimization Demo - Master Setup Script
=============================================================================
This script documents the execution order for all setup scripts.
Run each script in the order listed below.

Role: SF_INTELLIGENCE_DEMO
Estimated total run time: 10-15 minutes
=============================================================================
*/

-- ============================================================================
-- EXECUTION ORDER
-- ============================================================================
/*
  All scripts are in the setup/ folder. Run in order 01-08.

  STEP 1: Database & Infrastructure Setup
  ----------------------------------------
  File: 01_database_setup.sql
  Creates: Database, schemas, warehouses, roles (SF_INTELLIGENCE_DEMO)
  
  STEP 2: Dimension Tables DDL
  ----------------------------------------
  File: 02_dimension_tables.sql
  Creates: DIM_DATE, DIM_MEDICAL_SPECIALTIES, DIM_LOCATIONS, 
           DIM_INVENTORY, DIM_PHARMA_PARTNERS, DIM_CAMPAIGNS,
           DIM_AUDIENCE_COHORTS, DIM_CREATIVE_ASSETS
  
  STEP 3: Fact Tables DDL
  ----------------------------------------
  File: 03_fact_tables.sql
  Creates: FACT_BIDS, FACT_IMPRESSIONS, FACT_ENGAGEMENTS, FACT_APPOINTMENTS
  
  STEP 4: Generate Synthetic Data
  ----------------------------------------
  File: 04_generate_synthetic_data.sql
  Populates: All dimension and fact tables with ~1.8M rows of demo data
  Note: This is the longest running script (~5-10 minutes)
  
  STEP 5: Gold Layer Views
  ----------------------------------------
  File: 05_gold_layer_views.sql
  Creates: V_CAMPAIGN_PERFORMANCE, V_INVENTORY_ANALYTICS,
           V_AUDIENCE_INSIGHTS, V_CROSS_CHANNEL_ATTRIBUTION, etc.
  
  STEP 6: Cortex Search Services
  ----------------------------------------
  File: 06_cortex_search_services.sql
  Creates: INVENTORY_SEARCH_SVC, CAMPAIGN_SEARCH_SVC, AUDIENCE_SEARCH_SVC
  
  STEP 7: Semantic Views
  ----------------------------------------
  File: 07_semantic_views.sql
  Creates: SV_CAMPAIGN_ANALYTICS, SV_INVENTORY_ANALYTICS, SV_AUDIENCE_INSIGHTS
  
  STEP 8: Cortex Agent
  ----------------------------------------
  File: 08_cortex_agent.sql
  Creates: CAMPAIGN_OPTIMIZER_AGENT with 7 integrated tools

*/

-- ============================================================================
-- QUICK VERIFICATION AFTER SETUP
-- ============================================================================
/*
  Run these queries to verify successful setup:

  -- Check tables
  SELECT COUNT(*) FROM AD_TECH.ANALYTICS.DIM_CAMPAIGNS;          -- Should be ~100
  SELECT COUNT(*) FROM AD_TECH.ANALYTICS.FACT_IMPRESSIONS;       -- Should be ~1M
  
  -- Check Cortex services
  SHOW CORTEX SEARCH SERVICES IN SCHEMA AD_TECH.CORTEX;          -- Should show 3
  
  -- Check Semantic views
  SHOW SEMANTIC VIEWS IN SCHEMA AD_TECH.CORTEX;                  -- Should show 3
  
  -- Check Agent
  SHOW AGENTS IN SCHEMA AD_TECH.CORTEX;                          -- Should show 1
  
  -- Test Cortex Search
  SELECT SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
    'AD_TECH.CORTEX.INVENTORY_SEARCH_SVC',
    '{"query": "cardiology waiting room", "columns": ["slot_name"], "limit": 3}'
  );

*/

SELECT 'Review this file for setup instructions. Run scripts 01-08 in order.' AS instructions;

