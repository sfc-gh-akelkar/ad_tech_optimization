/*
=============================================================================
PatientPoint Ad Tech Demo - Cortex Search Services
=============================================================================
Creates all three Cortex Search services for natural language discovery:
1. INVENTORY_SEARCH_SVC - Find available ad placements
2. CAMPAIGN_SEARCH_SVC - Search campaign performance
3. AUDIENCE_SEARCH_SVC - Discover target audience cohorts

Uses SF_INTELLIGENCE_DEMO role.
=============================================================================
*/

USE ROLE SF_INTELLIGENCE_DEMO;
USE DATABASE AD_TECH;
USE SCHEMA CORTEX;
USE WAREHOUSE AD_TECH_WH;

-- ============================================================================
-- PART 1: INVENTORY SEARCH SERVICE
-- ============================================================================

-- Create source TABLE (not view) to break lineage and materialize fixed-point types
CREATE OR REPLACE TABLE AD_TECH.CORTEX.T_INVENTORY_SEARCH_SOURCE AS
SELECT
    inv.slot_id,
    inv.slot_name,
    
    -- Searchable text field combining all relevant information
    CONCAT(
        'Ad placement slot: ', inv.slot_name, '. ',
        'Located at ', l.facility_name, ' in ', l.city, ', ', l.state, '. ',
        'Region: ', l.region, '. ',
        'Facility type: ', l.facility_type, '. ',
        'Medical specialty: ', s.specialty_name, ' (', s.specialty_category, '). ',
        'Screen: ', inv.screen_type, ' ', inv.screen_size, ' in ', inv.placement_area, '. ',
        'Available during ', inv.daypart, ' hours. ',
        'Ad duration: ', inv.duration_seconds::VARCHAR, ' seconds. ',
        'Estimated daily impressions: ', inv.daily_impressions::VARCHAR, '. ',
        'Base CPM: $', ROUND(inv.base_cpm, 2)::VARCHAR, '. ',
        CASE WHEN inv.is_premium THEN 'This is a PREMIUM placement with high visibility. ' ELSE '' END,
        'Patient volume at this location: ', l.patient_volume::VARCHAR, ' monthly. ',
        'Affluence index: ', ROUND(l.affluence_index, 1)::VARCHAR, '/10.'
    ) AS search_text,
    
    -- Filterable attributes
    s.specialty_name AS specialty,
    s.specialty_category,
    l.region,
    l.state,
    l.city,
    l.facility_type,
    inv.screen_type,
    inv.placement_area,
    inv.daypart,
    inv.is_premium,
    
    -- Additional metadata (materialized as fixed-point)
    l.facility_name,
    inv.screen_size,
    inv.duration_seconds,
    inv.daily_impressions,
    CAST(inv.base_cpm AS NUMBER(12,2)) AS base_cpm,
    l.patient_volume,
    CAST(l.affluence_index AS NUMBER(5,2)) AS affluence_index,
    CAST(s.base_cpm_multiplier AS NUMBER(5,2)) AS specialty_premium

FROM AD_TECH.ANALYTICS.DIM_INVENTORY inv
JOIN AD_TECH.ANALYTICS.DIM_LOCATIONS l ON inv.location_id = l.location_id
JOIN AD_TECH.ANALYTICS.DIM_MEDICAL_SPECIALTIES s ON inv.specialty_id = s.specialty_id
WHERE inv.is_active = TRUE;

-- Create the Inventory Search Service (using materialized table)
CREATE OR REPLACE CORTEX SEARCH SERVICE AD_TECH.CORTEX.INVENTORY_SEARCH_SVC
    ON search_text
    ATTRIBUTES specialty, specialty_category, region, state, city, facility_type, 
               screen_type, placement_area, daypart, is_premium
    WAREHOUSE = AD_TECH_WH
    TARGET_LAG = '1 hour'
    COMMENT = 'Search service for discovering available ad inventory by specialty, location, and screen type'
    AS (
        SELECT
            slot_id,
            slot_name,
            search_text,
            specialty,
            specialty_category,
            region,
            state,
            city,
            facility_type,
            screen_type,
            placement_area,
            daypart,
            is_premium,
            facility_name,
            screen_size,
            duration_seconds,
            daily_impressions,
            base_cpm,
            patient_volume,
            affluence_index,
            specialty_premium
        FROM AD_TECH.CORTEX.T_INVENTORY_SEARCH_SOURCE
    );

DESCRIBE CORTEX SEARCH SERVICE AD_TECH.CORTEX.INVENTORY_SEARCH_SVC;
SELECT 'Inventory Search Service created!' AS status;


-- ============================================================================
-- PART 2: CAMPAIGN SEARCH SERVICE
-- ============================================================================

-- Create source TABLE from DIMENSION tables only (fast - no fact table joins)
-- Performance metrics can be looked up separately via Cortex Analyst
CREATE OR REPLACE TABLE AD_TECH.CORTEX.T_CAMPAIGN_SEARCH_SOURCE AS
SELECT
    c.campaign_id,
    c.campaign_name,
    
    -- Rich searchable text with campaign details
    CONCAT(
        'Campaign: ', c.campaign_name, '. ',
        'Pharmaceutical partner: ', p.partner_name, ' (', p.partner_tier, ' tier). ',
        'Drug: ', c.drug_name, '. ',
        'Therapeutic area: ', c.therapeutic_area, '. ',
        'Campaign type: ', c.campaign_type, '. ',
        'Target specialty: ', c.target_specialty, '. ',
        'Status: ', c.status, '. ',
        'Budget: $', ROUND(c.budget, 0)::VARCHAR, '. ',
        'Date range: ', c.start_date::VARCHAR, ' to ', c.end_date::VARCHAR, '. ',
        'Industry segment: ', p.industry_segment, '. ',
        CASE c.status
            WHEN 'Active' THEN 'This campaign is currently ACTIVE and running. '
            WHEN 'Completed' THEN 'This campaign has been COMPLETED. '
            WHEN 'Paused' THEN 'This campaign is currently PAUSED. '
            ELSE ''
        END
    ) AS campaign_summary,
    
    -- Filterable attributes
    c.therapeutic_area,
    p.partner_name,
    p.partner_tier,
    c.campaign_type,
    c.target_specialty,
    c.status,
    c.drug_name,
    
    -- Date attributes for filtering
    YEAR(c.start_date) AS campaign_year,
    QUARTER(c.start_date) AS campaign_quarter,
    'Q' || QUARTER(c.start_date)::VARCHAR || ' ' || YEAR(c.start_date)::VARCHAR AS quarter_label,
    
    -- Basic metrics from dimension (no aggregations)
    CAST(c.budget AS NUMBER(18,2)) AS budget,
    c.target_impressions,
    CAST(c.target_ctr AS NUMBER(8,4)) AS target_ctr

FROM AD_TECH.ANALYTICS.DIM_CAMPAIGNS c
JOIN AD_TECH.ANALYTICS.DIM_PHARMA_PARTNERS p ON c.partner_id = p.partner_id;

-- Create the Campaign Search Service (using dimension-based table - fast)
CREATE OR REPLACE CORTEX SEARCH SERVICE AD_TECH.CORTEX.CAMPAIGN_SEARCH_SVC
    ON campaign_summary
    ATTRIBUTES therapeutic_area, partner_name, partner_tier, campaign_type, 
               target_specialty, status, drug_name, campaign_year, quarter_label
    WAREHOUSE = AD_TECH_WH
    TARGET_LAG = '1 hour'
    COMMENT = 'Search service for querying campaigns by therapeutic area, partner, drug, and status'
    AS (
        SELECT
            campaign_id,
            campaign_name,
            campaign_summary,
            therapeutic_area,
            partner_name,
            partner_tier,
            campaign_type,
            target_specialty,
            status,
            drug_name,
            campaign_year,
            campaign_quarter,
            quarter_label,
            budget,
            target_impressions,
            target_ctr
        FROM AD_TECH.CORTEX.T_CAMPAIGN_SEARCH_SOURCE
    );

DESCRIBE CORTEX SEARCH SERVICE AD_TECH.CORTEX.CAMPAIGN_SEARCH_SVC;
SELECT 'Campaign Search Service created!' AS status;


-- ============================================================================
-- PART 3: AUDIENCE SEARCH SERVICE
-- ============================================================================

-- Create source TABLE from DIMENSION table only (fast - no fact table joins)
-- Engagement metrics can be looked up separately via Cortex Analyst
CREATE OR REPLACE TABLE AD_TECH.CORTEX.T_AUDIENCE_SEARCH_SOURCE AS
SELECT
    a.cohort_id,
    a.cohort_name,
    
    -- Rich searchable text describing the cohort
    CONCAT(
        'Audience cohort: ', a.cohort_name, '. ',
        'Demographics: ', a.age_bucket, ' age group, ', a.gender, '. ',
        'Ethnicity: ', a.ethnicity, '. ',
        'Geographic region: ', a.region, '. ',
        'Income bracket: ', a.income_bracket, '. ',
        'Insurance type: ', a.insurance_type, '. ',
        'Primary health interest: ', a.health_interest, '. ',
        'Related therapeutic interests: ', a.top_therapeutic_interests, '. ',
        'Cohort size: ', a.cohort_size::VARCHAR, ' members (privacy-safe aggregate). ',
        'Baseline engagement score: ', ROUND(a.avg_engagement_score, 1)::VARCHAR, '/100. ',
        'Average visit frequency: ', ROUND(a.avg_visit_frequency, 1)::VARCHAR, ' visits/month. ',
        CASE 
            WHEN a.avg_engagement_score >= 70 THEN 'HIGH ENGAGEMENT cohort - excellent for awareness campaigns. '
            WHEN a.avg_engagement_score >= 50 THEN 'MODERATE ENGAGEMENT cohort - good for education campaigns. '
            ELSE 'STANDARD cohort - suitable for broad reach. '
        END
    ) AS cohort_description,
    
    -- Filterable attributes
    a.age_bucket,
    a.gender,
    a.ethnicity,
    a.region,
    a.income_bracket,
    a.insurance_type,
    a.health_interest,
    
    -- Metrics from dimension (no aggregations needed)
    a.cohort_size,
    CAST(a.avg_engagement_score AS NUMBER(8,2)) AS baseline_engagement_score,
    CAST(a.avg_visit_frequency AS NUMBER(8,2)) AS avg_visit_frequency,
    a.top_therapeutic_interests

FROM AD_TECH.ANALYTICS.DIM_AUDIENCE_COHORTS a
WHERE a.cohort_size >= 50;  -- Enforce k-anonymity

-- Create the Audience Search Service (using dimension-based table - fast)
CREATE OR REPLACE CORTEX SEARCH SERVICE AD_TECH.CORTEX.AUDIENCE_SEARCH_SVC
    ON cohort_description
    ATTRIBUTES age_bucket, gender, ethnicity, region, income_bracket, 
               insurance_type, health_interest
    WAREHOUSE = AD_TECH_WH
    TARGET_LAG = '1 hour'
    COMMENT = 'Search service for discovering privacy-safe audience cohorts for campaign targeting'
    AS (
        SELECT
            cohort_id,
            cohort_name,
            cohort_description,
            age_bucket,
            gender,
            ethnicity,
            region,
            income_bracket,
            insurance_type,
            health_interest,
            cohort_size,
            baseline_engagement_score,
            avg_visit_frequency,
            top_therapeutic_interests
        FROM AD_TECH.CORTEX.T_AUDIENCE_SEARCH_SOURCE
    );

DESCRIBE CORTEX SEARCH SERVICE AD_TECH.CORTEX.AUDIENCE_SEARCH_SVC;
SELECT 'Audience Search Service created!' AS status;


-- ============================================================================
-- VERIFY ALL SEARCH SERVICES
-- ============================================================================
SHOW CORTEX SEARCH SERVICES IN SCHEMA AD_TECH.CORTEX;

SELECT 'All 3 Cortex Search Services created successfully!' AS status;

