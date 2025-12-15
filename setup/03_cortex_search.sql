/*
=============================================================================
PatientPoint Ad Tech Demo - SIMPLIFIED Cortex Search Services
=============================================================================
Creates search services directly on the pre-computed tables.
NO VIEWS, NO JOINS - just simple search on flat tables.
=============================================================================
*/

USE ROLE SF_INTELLIGENCE_DEMO;
USE DATABASE AD_TECH;
USE SCHEMA CORTEX;
USE WAREHOUSE AD_TECH_WH;

-- ============================================================================
-- INVENTORY SEARCH - Search ad slots by description
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE INVENTORY_SEARCH_SVC
    ON search_text
    ATTRIBUTES slot_id, slot_name, facility_name, region, specialty_name, screen_type, placement_area, daypart, base_cpm, is_premium
    WAREHOUSE = AD_TECH_WH
    TARGET_LAG = '1 hour'
AS (
    SELECT
        slot_id,
        slot_name,
        facility_name,
        facility_type,
        city,
        state,
        region,
        specialty_name,
        screen_type,
        placement_area,
        daypart,
        base_cpm,
        is_premium,
        -- Search text combines key searchable fields
        slot_name || ' ' || facility_name || ' ' || region || ' ' || specialty_name || ' ' || 
        screen_type || ' ' || placement_area || ' ' || daypart || 
        CASE WHEN is_premium THEN ' premium' ELSE '' END AS search_text
    FROM AD_TECH.ANALYTICS.T_INVENTORY_ANALYTICS
);

SELECT 'INVENTORY_SEARCH_SVC created!' AS status;


-- ============================================================================
-- CAMPAIGN SEARCH - Search campaigns by description
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE CAMPAIGN_SEARCH_SVC
    ON search_text
    ATTRIBUTES campaign_id, campaign_name, partner_name, therapeutic_area, drug_name, campaign_type, status, roas, total_revenue
    WAREHOUSE = AD_TECH_WH
    TARGET_LAG = '1 hour'
AS (
    SELECT
        campaign_id,
        campaign_name,
        drug_name,
        therapeutic_area,
        campaign_type,
        target_specialty,
        status,
        partner_name,
        partner_tier,
        total_revenue,
        roas,
        total_impressions,
        ctr_pct,
        -- Search text combines key searchable fields
        campaign_name || ' ' || drug_name || ' ' || therapeutic_area || ' ' || 
        campaign_type || ' ' || partner_name || ' ' || partner_tier || ' ' || 
        status || ' ' || target_specialty AS search_text
    FROM AD_TECH.ANALYTICS.T_CAMPAIGN_PERFORMANCE
);

SELECT 'CAMPAIGN_SEARCH_SVC created!' AS status;


-- ============================================================================
-- AUDIENCE SEARCH - Search audience cohorts by description
-- ============================================================================
CREATE OR REPLACE CORTEX SEARCH SERVICE AUDIENCE_SEARCH_SVC
    ON search_text
    ATTRIBUTES cohort_id, cohort_name, age_bucket, gender, region, health_interest, income_bracket, insurance_type, cohort_size, engagement_rate_pct
    WAREHOUSE = AD_TECH_WH
    TARGET_LAG = '1 hour'
AS (
    SELECT
        cohort_id,
        cohort_name,
        age_bucket,
        gender,
        region,
        income_bracket,
        insurance_type,
        health_interest,
        top_therapeutic_interests,
        cohort_size,
        baseline_engagement_score,
        engagement_rate_pct,
        conversion_rate_pct,
        -- Search text combines key searchable fields
        cohort_name || ' ' || age_bucket || ' ' || gender || ' ' || region || ' ' ||
        income_bracket || ' ' || insurance_type || ' ' || health_interest || ' ' ||
        top_therapeutic_interests AS search_text
    FROM AD_TECH.ANALYTICS.T_AUDIENCE_INSIGHTS
);

SELECT 'AUDIENCE_SEARCH_SVC created!' AS status;


-- ============================================================================
-- VERIFY ALL SEARCH SERVICES
-- ============================================================================
SHOW CORTEX SEARCH SERVICES IN SCHEMA AD_TECH.CORTEX;

SELECT 'All 3 Cortex Search Services created!' AS status;

