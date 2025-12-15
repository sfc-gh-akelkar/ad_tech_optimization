/*
=============================================================================
PatientPoint Ad Tech Demo - SIMPLIFIED Semantic Views
=============================================================================
Semantic views on pre-computed flat tables - NO JOINS at query time.
=============================================================================
*/

USE ROLE SF_INTELLIGENCE_DEMO;
USE DATABASE AD_TECH;
USE SCHEMA CORTEX;
USE WAREHOUSE AD_TECH_WH;

-- ============================================================================
-- CAMPAIGN ANALYTICS SEMANTIC VIEW
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW AD_TECH.CORTEX.SV_CAMPAIGN_ANALYTICS

    TABLES (
        campaigns AS AD_TECH.ANALYTICS.T_CAMPAIGN_PERFORMANCE 
            PRIMARY KEY (campaign_id)
            COMMENT = 'Pre-computed campaign performance metrics'
    )

    DIMENSIONS (
        campaigns.campaign_name AS campaigns.campaign_name
            WITH SYNONYMS = ('campaign', 'ad campaign')
            COMMENT = 'Campaign name',
        
        campaigns.drug_name AS campaigns.drug_name
            WITH SYNONYMS = ('drug', 'medication', 'medicine')
            COMMENT = 'Pharmaceutical drug name',
        
        campaigns.therapeutic_area AS campaigns.therapeutic_area
            WITH SYNONYMS = ('therapy area', 'treatment area', 'medical category')
            COMMENT = 'Therapeutic category',
        
        campaigns.campaign_type AS campaigns.campaign_type
            COMMENT = 'Campaign type (Awareness, Education, Direct Response)',
        
        campaigns.target_specialty AS campaigns.target_specialty
            COMMENT = 'Target medical specialty',
        
        campaigns.status AS campaigns.status
            WITH SYNONYMS = ('campaign status')
            COMMENT = 'Campaign status',
        
        campaigns.partner_name AS campaigns.partner_name
            WITH SYNONYMS = ('pharma partner', 'advertiser', 'client')
            COMMENT = 'Pharmaceutical partner name',
        
        campaigns.partner_tier AS campaigns.partner_tier
            WITH SYNONYMS = ('tier', 'partner level')
            COMMENT = 'Partner tier (Platinum, Gold, Silver, Bronze)',
        
        campaigns.start_date AS campaigns.start_date
            COMMENT = 'Campaign start date',
        
        campaigns.end_date AS campaigns.end_date
            COMMENT = 'Campaign end date'
    )

    METRICS (
        campaigns.budget AS SUM(campaigns.budget)
            WITH SYNONYMS = ('campaign budget', 'spend limit')
            COMMENT = 'Total budget',
        
        campaigns.total_bids AS SUM(campaigns.total_bids)
            WITH SYNONYMS = ('bid count', 'bids')
            COMMENT = 'Total bid requests',
        
        campaigns.winning_bids AS SUM(campaigns.winning_bids)
            WITH SYNONYMS = ('wins', 'bid wins')
            COMMENT = 'Winning bids',
        
        campaigns.win_rate_pct AS AVG(campaigns.win_rate_pct)
            WITH SYNONYMS = ('win rate')
            COMMENT = 'Win rate percentage',
        
        campaigns.avg_bid_cpm AS AVG(campaigns.avg_bid_cpm)
            WITH SYNONYMS = ('average cpm', 'cpm')
            COMMENT = 'Average bid CPM',
        
        campaigns.total_impressions AS SUM(campaigns.total_impressions)
            WITH SYNONYMS = ('impressions', 'views')
            COMMENT = 'Total impressions',
        
        campaigns.avg_completion_rate_pct AS AVG(campaigns.avg_completion_rate_pct)
            WITH SYNONYMS = ('completion rate')
            COMMENT = 'Average completion rate',
        
        campaigns.avg_viewability_pct AS AVG(campaigns.avg_viewability_pct)
            WITH SYNONYMS = ('viewability')
            COMMENT = 'Average viewability',
        
        campaigns.total_engagements AS SUM(campaigns.total_engagements)
            WITH SYNONYMS = ('engagements', 'clicks')
            COMMENT = 'Total engagements',
        
        campaigns.ctr_pct AS AVG(campaigns.ctr_pct)
            WITH SYNONYMS = ('ctr', 'click through rate')
            COMMENT = 'Click-through rate',
        
        campaigns.total_conversions AS SUM(campaigns.total_conversions)
            WITH SYNONYMS = ('conversions')
            COMMENT = 'Total conversions',
        
        campaigns.conversion_rate_pct AS AVG(campaigns.conversion_rate_pct)
            WITH SYNONYMS = ('conversion rate', 'cvr')
            COMMENT = 'Conversion rate',
        
        campaigns.total_revenue AS SUM(campaigns.total_revenue)
            WITH SYNONYMS = ('revenue', 'earnings')
            COMMENT = 'Total revenue',
        
        campaigns.roas AS AVG(campaigns.roas)
            WITH SYNONYMS = ('return on ad spend', 'roi')
            COMMENT = 'Return on ad spend',
        
        campaigns.effective_cpm AS AVG(campaigns.effective_cpm)
            WITH SYNONYMS = ('ecpm')
            COMMENT = 'Effective CPM'
    )

    COMMENT = 'Campaign performance analytics';

SELECT 'SV_CAMPAIGN_ANALYTICS created!' AS status;


-- ============================================================================
-- INVENTORY ANALYTICS SEMANTIC VIEW
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW AD_TECH.CORTEX.SV_INVENTORY_ANALYTICS

    TABLES (
        inventory AS AD_TECH.ANALYTICS.T_INVENTORY_ANALYTICS 
            PRIMARY KEY (slot_id)
            COMMENT = 'Pre-computed inventory metrics'
    )

    DIMENSIONS (
        inventory.slot_name AS inventory.slot_name
            WITH SYNONYMS = ('slot', 'placement')
            COMMENT = 'Ad slot name',
        
        inventory.screen_type AS inventory.screen_type
            WITH SYNONYMS = ('screen', 'display')
            COMMENT = 'Screen type',
        
        inventory.placement_area AS inventory.placement_area
            WITH SYNONYMS = ('area', 'location')
            COMMENT = 'Placement area',
        
        inventory.daypart AS inventory.daypart
            WITH SYNONYMS = ('time of day')
            COMMENT = 'Daypart',
        
        inventory.is_premium AS inventory.is_premium
            WITH SYNONYMS = ('premium')
            COMMENT = 'Premium slot flag',
        
        inventory.facility_name AS inventory.facility_name
            WITH SYNONYMS = ('facility', 'hospital', 'clinic')
            COMMENT = 'Facility name',
        
        inventory.facility_type AS inventory.facility_type
            COMMENT = 'Facility type',
        
        inventory.city AS inventory.city
            COMMENT = 'City',
        
        inventory.state AS inventory.state
            COMMENT = 'State',
        
        inventory.region AS inventory.region
            WITH SYNONYMS = ('geographic region')
            COMMENT = 'Region',
        
        inventory.specialty_name AS inventory.specialty_name
            WITH SYNONYMS = ('specialty', 'medical specialty')
            COMMENT = 'Medical specialty'
    )

    METRICS (
        inventory.base_cpm AS AVG(inventory.base_cpm)
            WITH SYNONYMS = ('cpm', 'price')
            COMMENT = 'Base CPM',
        
        inventory.estimated_daily_impressions AS SUM(inventory.estimated_daily_impressions)
            WITH SYNONYMS = ('daily impressions', 'capacity')
            COMMENT = 'Daily impressions',
        
        inventory.patient_volume AS SUM(inventory.patient_volume)
            WITH SYNONYMS = ('patients', 'volume')
            COMMENT = 'Patient volume',
        
        inventory.affluence_index AS AVG(inventory.affluence_index)
            COMMENT = 'Affluence index',
        
        inventory.total_bids AS SUM(inventory.total_bids)
            WITH SYNONYMS = ('bids')
            COMMENT = 'Total bids',
        
        inventory.fill_rate_pct AS AVG(inventory.fill_rate_pct)
            WITH SYNONYMS = ('fill rate', 'utilization')
            COMMENT = 'Fill rate',
        
        inventory.delivered_impressions AS SUM(inventory.delivered_impressions)
            WITH SYNONYMS = ('impressions')
            COMMENT = 'Delivered impressions',
        
        inventory.avg_winning_cpm AS AVG(inventory.avg_winning_cpm)
            WITH SYNONYMS = ('winning cpm')
            COMMENT = 'Average winning CPM',
        
        inventory.avg_completion_pct AS AVG(inventory.avg_completion_pct)
            WITH SYNONYMS = ('completion rate')
            COMMENT = 'Completion rate',
        
        inventory.avg_viewability_pct AS AVG(inventory.avg_viewability_pct)
            WITH SYNONYMS = ('viewability')
            COMMENT = 'Viewability',
        
        inventory.total_engagements AS SUM(inventory.total_engagements)
            WITH SYNONYMS = ('engagements')
            COMMENT = 'Total engagements',
        
        inventory.engagement_rate_pct AS AVG(inventory.engagement_rate_pct)
            WITH SYNONYMS = ('ctr', 'engagement rate')
            COMMENT = 'Engagement rate',
        
        inventory.total_revenue AS SUM(inventory.total_revenue)
            WITH SYNONYMS = ('revenue')
            COMMENT = 'Total revenue'
    )

    COMMENT = 'Inventory performance analytics';

SELECT 'SV_INVENTORY_ANALYTICS created!' AS status;


-- ============================================================================
-- AUDIENCE INSIGHTS SEMANTIC VIEW
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW AD_TECH.CORTEX.SV_AUDIENCE_INSIGHTS

    TABLES (
        cohorts AS AD_TECH.ANALYTICS.T_AUDIENCE_INSIGHTS 
            PRIMARY KEY (cohort_id)
            COMMENT = 'Pre-computed audience cohort metrics (k-anonymity enforced)'
    )

    DIMENSIONS (
        cohorts.cohort_name AS cohorts.cohort_name
            WITH SYNONYMS = ('cohort', 'audience', 'segment')
            COMMENT = 'Cohort name',
        
        cohorts.age_bucket AS cohorts.age_bucket
            WITH SYNONYMS = ('age group', 'age')
            COMMENT = 'Age bucket',
        
        cohorts.gender AS cohorts.gender
            COMMENT = 'Gender',
        
        cohorts.region AS cohorts.region
            WITH SYNONYMS = ('geographic region')
            COMMENT = 'Region',
        
        cohorts.income_bracket AS cohorts.income_bracket
            WITH SYNONYMS = ('income')
            COMMENT = 'Income bracket',
        
        cohorts.insurance_type AS cohorts.insurance_type
            WITH SYNONYMS = ('insurance', 'payer')
            COMMENT = 'Insurance type',
        
        cohorts.health_interest AS cohorts.health_interest
            WITH SYNONYMS = ('health topic', 'interest')
            COMMENT = 'Health interest',
        
        cohorts.top_therapeutic_interests AS cohorts.top_therapeutic_interests
            WITH SYNONYMS = ('therapeutic interests')
            COMMENT = 'Therapeutic interests'
    )

    METRICS (
        cohorts.cohort_size AS SUM(cohorts.cohort_size)
            WITH SYNONYMS = ('size', 'audience size')
            COMMENT = 'Cohort size',
        
        cohorts.baseline_engagement_score AS AVG(cohorts.baseline_engagement_score)
            WITH SYNONYMS = ('engagement score')
            COMMENT = 'Baseline engagement',
        
        cohorts.avg_visit_frequency AS AVG(cohorts.avg_visit_frequency)
            WITH SYNONYMS = ('visit frequency')
            COMMENT = 'Visit frequency',
        
        cohorts.campaigns_exposed AS SUM(cohorts.campaigns_exposed)
            WITH SYNONYMS = ('campaigns')
            COMMENT = 'Campaigns exposed',
        
        cohorts.total_impressions AS SUM(cohorts.total_impressions)
            WITH SYNONYMS = ('impressions')
            COMMENT = 'Total impressions',
        
        cohorts.total_engagements AS SUM(cohorts.total_engagements)
            WITH SYNONYMS = ('engagements')
            COMMENT = 'Total engagements',
        
        cohorts.engagement_rate_pct AS AVG(cohorts.engagement_rate_pct)
            WITH SYNONYMS = ('ctr', 'engagement rate')
            COMMENT = 'Engagement rate',
        
        cohorts.total_conversions AS SUM(cohorts.total_conversions)
            WITH SYNONYMS = ('conversions')
            COMMENT = 'Total conversions',
        
        cohorts.conversion_rate_pct AS AVG(cohorts.conversion_rate_pct)
            WITH SYNONYMS = ('conversion rate', 'cvr')
            COMMENT = 'Conversion rate',
        
        cohorts.avg_dwell_time_seconds AS AVG(cohorts.avg_dwell_time_seconds)
            WITH SYNONYMS = ('dwell time')
            COMMENT = 'Dwell time',
        
        cohorts.cohort_revenue AS SUM(cohorts.cohort_revenue)
            WITH SYNONYMS = ('revenue')
            COMMENT = 'Cohort revenue',
        
        cohorts.revenue_per_member AS AVG(cohorts.revenue_per_member)
            WITH SYNONYMS = ('arpu')
            COMMENT = 'Revenue per member'
    )

    COMMENT = 'Privacy-safe audience cohort analytics';

SELECT 'SV_AUDIENCE_INSIGHTS created!' AS status;


-- ============================================================================
-- VERIFY ALL SEMANTIC VIEWS
-- ============================================================================
SHOW SEMANTIC VIEWS IN SCHEMA AD_TECH.CORTEX;

SELECT 'All 3 Semantic Views created!' AS status;

