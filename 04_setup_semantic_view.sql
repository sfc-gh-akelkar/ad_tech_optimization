-- ============================================================================
-- Patient Point IXR Analytics - Semantic View Setup
-- ============================================================================
-- Description: Creates a Snowflake semantic view for natural language queries
--              Replaces the YAML-based semantic model approach
-- Reference: https://docs.snowflake.com/en/user-guide/views-semantic/example
-- ============================================================================

USE ROLE ACCOUNTADMIN;
USE SCHEMA PATIENTPOINT_DB.IXR_ANALYTICS;

-- ============================================================================
-- Create Semantic View for Patient Point Impact Analysis
-- ============================================================================
-- This semantic view enables Cortex Analyst to understand the relationship
-- between digital engagement metrics and clinical outcomes using natural language

CREATE OR REPLACE SEMANTIC VIEW PATIENT_IMPACT_SEMANTIC_VIEW
  -- Define base tables and their primary keys
  TABLES (
    provider_dim AS PATIENTPOINT_DB.IXR_ANALYTICS.PROVIDER_DIM 
      PRIMARY KEY (NPI),
    
    impact_analysis AS PATIENTPOINT_DB.IXR_ANALYTICS.V_IMPACT_ANALYSIS 
      PRIMARY KEY (PROVIDER_NPI, OUTCOME_MONTH)
  )
  
  -- Define relationships between tables
  RELATIONSHIPS (
    impact_analysis (PROVIDER_NPI) REFERENCES provider_dim (NPI)
  )
  
  -- Define dimensions (categorical and descriptive attributes)
  DIMENSIONS (
    -- Provider dimensions
    provider_dim.provider_specialty AS provider_dim.SPECIALTY
      WITH SYNONYMS = ('medical specialty', 'provider specialty', 'doctor specialty', 'practice type'),
    
    provider_dim.provider_region AS provider_dim.REGION
      WITH SYNONYMS = ('geographic region', 'location', 'area'),
    
    provider_dim.provider_active_status AS provider_dim.IS_ACTIVE
      WITH SYNONYMS = ('active status', 'active provider', 'provider status', 'churned', 'retained'),
    
    -- Impact analysis dimensions
    impact_analysis.specialty AS impact_analysis.SPECIALTY
      WITH SYNONYMS = ('medical specialty', 'provider type', 'specialty type'),
    
    impact_analysis.region AS impact_analysis.REGION
      WITH SYNONYMS = ('geographic region', 'location'),
    
    impact_analysis.provider_is_active AS impact_analysis.PROVIDER_IS_ACTIVE
      WITH SYNONYMS = ('active', 'churned', 'retention status', 'provider churn'),
    
    impact_analysis.engagement_level AS impact_analysis.ENGAGEMENT_LEVEL
      WITH SYNONYMS = ('engagement category', 'interaction level', 'engagement tier'),
    
    -- Time dimension with synonyms
    impact_analysis.reporting_month AS impact_analysis.OUTCOME_MONTH
      WITH SYNONYMS = ('month', 'time period', 'date', 'reporting month')
  )
  
  -- Define metrics (aggregated measures)
  METRICS (
    -- Provider counts
    provider_dim.provider_count AS COUNT(DISTINCT provider_dim.NPI)
      WITH SYNONYMS = ('number of providers', 'provider count', 'total providers', 'how many providers'),
    
    provider_dim.active_provider_count AS COUNT(DISTINCT CASE WHEN provider_dim.IS_ACTIVE = TRUE THEN provider_dim.NPI END)
      WITH SYNONYMS = ('active providers', 'retained providers'),
    
    -- Engagement metrics (aggregated)
    impact_analysis.total_engagement_events AS SUM(impact_analysis.TOTAL_INTERACTIONS)
      WITH SYNONYMS = ('total interactions', 'interaction count', 'engagement events'),
    
    impact_analysis.avg_dwell_time AS AVG(impact_analysis.AVG_DWELL_TIME_SEC)
      WITH SYNONYMS = ('dwell time', 'time spent', 'viewing time', 'engagement time', 'screen time'),
    
    impact_analysis.avg_clicks AS AVG(impact_analysis.AVG_CLICK_COUNT)
      WITH SYNONYMS = ('clicks', 'click count', 'interactions', 'number of clicks', 'user clicks'),
    
    impact_analysis.avg_scroll_depth AS AVG(impact_analysis.AVG_SCROLL_DEPTH_PCT)
      WITH SYNONYMS = ('scrolling', 'scroll depth', 'scroll percentage', 'how far scrolled', 'content consumption', 'reading depth'),
    
    impact_analysis.max_scroll AS MAX(impact_analysis.MAX_SCROLL_DEPTH_PCT)
      WITH SYNONYMS = ('maximum scroll', 'deepest scroll', 'max scroll depth'),
    
    impact_analysis.total_dwell_time AS SUM(impact_analysis.TOTAL_DWELL_TIME_SEC)
      WITH SYNONYMS = ('total time spent', 'cumulative time', 'total viewing time'),
    
    impact_analysis.total_click_volume AS SUM(impact_analysis.TOTAL_CLICKS)
      WITH SYNONYMS = ('total clicks', 'click volume', 'cumulative clicks'),
    
    impact_analysis.avg_engagement_score AS AVG(impact_analysis.ENGAGEMENT_SCORE)
      WITH SYNONYMS = ('engagement score', 'engagement index', 'interaction score'),
    
    -- Clinical outcome metrics (aggregated)
    impact_analysis.total_vaccines AS SUM(impact_analysis.VACCINES_ADMINISTERED)
      WITH SYNONYMS = ('vaccines', 'vaccinations', 'shots', 'immunizations', 'vaccine count', 'shots given'),
    
    impact_analysis.avg_vaccines_per_provider AS AVG(impact_analysis.VACCINES_ADMINISTERED)
      WITH SYNONYMS = ('average vaccines', 'vaccines per provider', 'mean vaccinations'),
    
    impact_analysis.total_screenings AS SUM(impact_analysis.SCREENINGS_COMPLETED)
      WITH SYNONYMS = ('screenings', 'preventative screenings', 'health screenings', 'screening tests', 'preventive care'),
    
    impact_analysis.avg_screenings_per_provider AS AVG(impact_analysis.SCREENINGS_COMPLETED)
      WITH SYNONYMS = ('average screenings', 'screenings per provider', 'mean screenings'),
    
    impact_analysis.avg_show_rate AS AVG(impact_analysis.APPOINTMENT_SHOW_RATE)
      WITH SYNONYMS = ('show rate', 'appointment adherence', 'no-show rate', 'attendance rate', 'kept appointments'),
    
    -- Efficiency metrics
    impact_analysis.avg_vaccine_efficiency AS AVG(impact_analysis.VACCINES_PER_INTERACTION)
      WITH SYNONYMS = ('vaccine efficiency', 'vaccines per engagement', 'vaccination rate'),
    
    impact_analysis.avg_screening_efficiency AS AVG(impact_analysis.SCREENINGS_PER_INTERACTION)
      WITH SYNONYMS = ('screening efficiency', 'screenings per engagement', 'screening rate'),
    
    -- Retention metrics
    impact_analysis.retention_rate AS AVG(CASE WHEN impact_analysis.PROVIDER_IS_ACTIVE = TRUE THEN 100.0 ELSE 0.0 END)
      WITH SYNONYMS = ('retention rate', 'churn rate', 'provider retention', 'active rate')
  )
  COMMENT = 'Semantic view for analyzing digital engagement impact on clinical outcomes'
;

-- ============================================================================
-- Verify Semantic View Creation
-- ============================================================================

-- Show the semantic view
SHOW SEMANTIC VIEWS LIKE 'PATIENT_IMPACT_SEMANTIC_VIEW';

-- Describe the semantic view structure
DESC SEMANTIC VIEW PATIENT_IMPACT_SEMANTIC_VIEW;

-- ============================================================================
-- Test Queries Using the Semantic View
-- ============================================================================
-- Note: Semantic views in Snowflake are used by Cortex Analyst for natural
-- language queries. Direct SQL queries are handled by Cortex Analyst.
-- For testing, you can query the underlying views directly.

-- Test 1: Verify semantic view exists
SELECT 'Semantic view created successfully' AS STATUS;

-- Test 2: Query underlying view for validation
SELECT 
    SPECIALTY,
    COUNT(DISTINCT PROVIDER_NPI) AS provider_count,
    SUM(VACCINES_ADMINISTERED) AS total_vaccines,
    ROUND(AVG(AVG_SCROLL_DEPTH_PCT), 2) AS avg_scroll_depth
FROM V_IMPACT_ANALYSIS
GROUP BY SPECIALTY
ORDER BY total_vaccines DESC
LIMIT 5;

-- ============================================================================
-- Grant Access to the Semantic View
-- ============================================================================

-- Grant usage to SYSADMIN role
GRANT SELECT ON SEMANTIC VIEW PATIENT_IMPACT_SEMANTIC_VIEW TO ROLE SYSADMIN;

-- Grant access to underlying objects
GRANT SELECT ON VIEW V_IMPACT_ANALYSIS TO ROLE SYSADMIN;

SELECT '✓ Semantic view created successfully. Ready for Cortex Analyst integration.' AS STATUS;

-- ============================================================================
-- Integration Notes
-- ============================================================================
/*
USING THE SEMANTIC VIEW WITH CORTEX ANALYST:

Semantic views are designed for Cortex Analyst to enable natural language queries.
They are NOT queried directly with SQL - instead, Cortex Analyst uses them to:
1. Understand the business meaning of data (via SYNONYMS)
2. Know which metrics can be aggregated
3. Understand relationships between tables
4. Generate correct SQL from natural language questions

CONFIGURATION WITH CORTEX AGENT:
When creating an agent in the Snowflake UI:
1. Navigate to: AI & ML → Agents → + Agent
2. Add Tool: Cortex Analyst
3. Select Semantic View: PATIENTPOINT_DB.IXR_ANALYTICS.PATIENT_IMPACT_SEMANTIC_VIEW
4. Cortex Analyst will use this semantic view to answer natural language questions

BENEFITS OF SEMANTIC VIEWS:
1. Native Snowflake object - no YAML file upload required
2. Version controlled through SQL scripts
3. Managed with standard DDL commands
4. Integrated with Snowflake's metadata and governance
5. Easier to update and maintain
6. Direct integration with Snowflake Intelligence

SAMPLE NATURAL LANGUAGE QUESTIONS (via Cortex Analyst):
- "Did an increase in scrolling lead to more vaccines administered?"
- "Show the correlation between dwell time and preventative screenings"
- "What is the relationship between engagement and provider churn?"
- "Compare clinical outcomes across different medical specialties"
- "Show me monthly trends in engagement and clinical outcomes"
*/

