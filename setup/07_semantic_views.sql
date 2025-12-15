/*
=============================================================================
PatientPoint Ad Tech Demo - Semantic Views
=============================================================================
Creates all three semantic views for Cortex Analyst:
1. SV_CAMPAIGN_ANALYTICS - Campaign performance analytics
2. SV_INVENTORY_ANALYTICS - Inventory performance and availability
3. SV_AUDIENCE_INSIGHTS - Privacy-safe audience engagement

Uses SF_INTELLIGENCE_DEMO role.
Reference: https://docs.snowflake.com/en/sql-reference/sql/create-semantic-view
=============================================================================
*/

USE ROLE SF_INTELLIGENCE_DEMO;
USE DATABASE AD_TECH;
USE SCHEMA CORTEX;
USE WAREHOUSE AD_TECH_WH;

-- ============================================================================
-- PART 1: CAMPAIGN ANALYTICS SEMANTIC VIEW
-- Uses pre-aggregated gold layer view for simpler querying
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW AD_TECH.CORTEX.SV_CAMPAIGN_ANALYTICS

    TABLES (
        -- Pre-aggregated campaign performance (from gold layer)
        campaigns AS AD_TECH.ANALYTICS.V_CAMPAIGN_PERFORMANCE 
            PRIMARY KEY (campaign_id)
            COMMENT = 'Campaign performance metrics (pre-aggregated)'
    )

    DIMENSIONS (
        -- Campaign dimensions
        campaigns.campaign_name AS campaigns.campaign_name
            WITH SYNONYMS = ('campaign', 'ad campaign')
            COMMENT = 'Name of the advertising campaign',
        
        campaigns.drug_name AS campaigns.drug_name
            WITH SYNONYMS = ('drug', 'medication', 'medicine')
            COMMENT = 'Name of the pharmaceutical drug being advertised',
        
        campaigns.therapeutic_area AS campaigns.therapeutic_area
            WITH SYNONYMS = ('therapy area', 'treatment area', 'medical category')
            COMMENT = 'Therapeutic category (Diabetes, Cardiology, Oncology, etc.)',
        
        campaigns.campaign_type AS campaigns.campaign_type
            COMMENT = 'Type of campaign (Awareness, Education, Direct Response)',
        
        campaigns.target_specialty AS campaigns.target_specialty
            COMMENT = 'Target medical specialty for the campaign',
        
        campaigns.status AS campaigns.status
            WITH SYNONYMS = ('campaign status')
            COMMENT = 'Campaign status (Active, Paused, Completed)',
        
        campaigns.partner_name AS campaigns.partner_name
            WITH SYNONYMS = ('pharma partner', 'advertiser', 'client')
            COMMENT = 'Name of the pharmaceutical partner',
        
        campaigns.partner_tier AS campaigns.partner_tier
            WITH SYNONYMS = ('tier', 'partner level')
            COMMENT = 'Partner tier (Platinum, Gold, Silver, Bronze)',
        
        campaigns.start_date AS campaigns.start_date
            WITH SYNONYMS = ('campaign start', 'launch date')
            COMMENT = 'Campaign start date',
        
        campaigns.end_date AS campaigns.end_date
            WITH SYNONYMS = ('campaign end')
            COMMENT = 'Campaign end date'
    )

    METRICS (
        -- Budget
        campaigns.budget AS SUM(campaigns.budget)
            WITH SYNONYMS = ('campaign budget', 'spend limit')
            COMMENT = 'Total campaign budget',
        
        -- Bid metrics
        campaigns.total_bids AS SUM(campaigns.total_bids)
            WITH SYNONYMS = ('bid count', 'number of bids')
            COMMENT = 'Total number of bid requests',
        
        campaigns.winning_bids AS SUM(campaigns.winning_bids)
            WITH SYNONYMS = ('wins', 'bid wins')
            COMMENT = 'Number of winning bids',
        
        campaigns.win_rate_pct AS AVG(campaigns.win_rate_pct)
            WITH SYNONYMS = ('win rate', 'win rate percentage', 'win pct')
            COMMENT = 'Bid win rate percentage',
        
        campaigns.avg_bid_cpm AS AVG(campaigns.avg_bid_cpm)
            WITH SYNONYMS = ('average cpm', 'avg cpm', 'average bid')
            COMMENT = 'Average bid CPM amount',
        
        -- Impression metrics
        campaigns.total_impressions AS SUM(campaigns.total_impressions)
            WITH SYNONYMS = ('impressions', 'impression count', 'views')
            COMMENT = 'Total delivered impressions',
        
        campaigns.avg_completion_rate_pct AS AVG(campaigns.avg_completion_rate_pct)
            WITH SYNONYMS = ('completion rate', 'video completion')
            COMMENT = 'Average ad completion rate percentage',
        
        campaigns.avg_viewability_pct AS AVG(campaigns.avg_viewability_pct)
            WITH SYNONYMS = ('viewability', 'viewability rate')
            COMMENT = 'Average viewability score percentage',
        
        -- Engagement metrics
        campaigns.total_engagements AS SUM(campaigns.total_engagements)
            WITH SYNONYMS = ('engagements', 'interactions', 'clicks')
            COMMENT = 'Total user engagements',
        
        campaigns.ctr_pct AS AVG(campaigns.ctr_pct)
            WITH SYNONYMS = ('ctr', 'click through rate', 'click rate', 'engagement rate')
            COMMENT = 'Click-through rate percentage',
        
        campaigns.total_conversions AS SUM(campaigns.total_conversions)
            WITH SYNONYMS = ('conversions', 'conversion count')
            COMMENT = 'Total conversions',
        
        campaigns.conversion_rate_pct AS AVG(campaigns.conversion_rate_pct)
            WITH SYNONYMS = ('cvr', 'conversion rate', 'conv rate')
            COMMENT = 'Conversion rate percentage',
        
        -- Revenue metrics
        campaigns.total_revenue AS SUM(campaigns.total_revenue)
            WITH SYNONYMS = ('revenue', 'earnings', 'income')
            COMMENT = 'Total revenue from impressions',
        
        campaigns.roas AS AVG(campaigns.roas)
            WITH SYNONYMS = ('return on ad spend', 'roi')
            COMMENT = 'Return on ad spend ratio',
        
        campaigns.effective_cpm AS AVG(campaigns.effective_cpm)
            WITH SYNONYMS = ('ecpm', 'effective cpm')
            COMMENT = 'Effective CPM (revenue per 1000 impressions)'
    )

    COMMENT = 'Semantic view for pharmaceutical advertising campaign performance analytics';

DESCRIBE SEMANTIC VIEW AD_TECH.CORTEX.SV_CAMPAIGN_ANALYTICS;
SELECT 'Campaign Semantic View created!' AS status;


-- ============================================================================
-- PART 2: INVENTORY ANALYTICS SEMANTIC VIEW
-- Uses pre-aggregated gold layer view for simpler querying
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW AD_TECH.CORTEX.SV_INVENTORY_ANALYTICS

    TABLES (
        -- Pre-aggregated inventory performance (from gold layer)
        inventory AS AD_TECH.ANALYTICS.V_INVENTORY_ANALYTICS 
            PRIMARY KEY (slot_id)
            COMMENT = 'Inventory performance metrics (pre-aggregated)'
    )

    DIMENSIONS (
        -- Inventory dimensions
        inventory.slot_name AS inventory.slot_name
            WITH SYNONYMS = ('slot', 'ad slot', 'placement')
            COMMENT = 'Name of the ad placement slot',
        
        inventory.screen_type AS inventory.screen_type
            WITH SYNONYMS = ('screen', 'display type')
            COMMENT = 'Type of screen (Digital Display, Tablet, Kiosk, TV)',
        
        inventory.screen_size AS inventory.screen_size
            COMMENT = 'Screen size',
        
        inventory.placement_area AS inventory.placement_area
            WITH SYNONYMS = ('area', 'location area')
            COMMENT = 'Placement area (Waiting Room, Exam Room, Check-in)',
        
        inventory.daypart AS inventory.daypart
            WITH SYNONYMS = ('time of day', 'day part')
            COMMENT = 'Daypart (Morning, Afternoon, Evening, All Day)',
        
        inventory.is_premium AS inventory.is_premium
            WITH SYNONYMS = ('premium', 'premium slot')
            COMMENT = 'Whether this is a premium placement',
        
        inventory.facility_name AS inventory.facility_name
            WITH SYNONYMS = ('facility', 'hospital', 'clinic')
            COMMENT = 'Name of the healthcare facility',
        
        inventory.facility_type AS inventory.facility_type
            COMMENT = 'Type of facility (Hospital, Clinic, Medical Center)',
        
        inventory.city AS inventory.city
            COMMENT = 'City name',
        
        inventory.state AS inventory.state
            COMMENT = 'State code',
        
        inventory.region AS inventory.region
            WITH SYNONYMS = ('geographic region')
            COMMENT = 'Geographic region (Northeast, Southeast, Midwest, Southwest, West)',
        
        inventory.specialty_name AS inventory.specialty_name
            WITH SYNONYMS = ('specialty', 'medical specialty')
            COMMENT = 'Medical specialty name',
        
        inventory.specialty_category AS inventory.specialty_category
            COMMENT = 'Specialty category'
    )

    METRICS (
        -- Inventory base metrics
        inventory.base_cpm AS AVG(inventory.base_cpm)
            WITH SYNONYMS = ('cpm', 'cost per thousand', 'price')
            COMMENT = 'Base CPM price for the slot',
        
        inventory.estimated_daily_impressions AS SUM(inventory.estimated_daily_impressions)
            WITH SYNONYMS = ('daily impressions', 'capacity')
            COMMENT = 'Estimated daily impressions',
        
        inventory.patient_volume AS SUM(inventory.patient_volume)
            WITH SYNONYMS = ('patients', 'volume')
            COMMENT = 'Monthly patient volume at location',
        
        inventory.affluence_index AS AVG(inventory.affluence_index)
            COMMENT = 'Affluence index (1-10 scale)',
        
        -- Performance metrics
        inventory.total_bids AS SUM(inventory.total_bids)
            WITH SYNONYMS = ('bids', 'bid count')
            COMMENT = 'Total bid requests',
        
        inventory.fill_rate_pct AS AVG(inventory.fill_rate_pct)
            WITH SYNONYMS = ('fill rate', 'utilization')
            COMMENT = 'Fill rate percentage',
        
        inventory.avg_winning_cpm AS AVG(inventory.avg_winning_cpm)
            WITH SYNONYMS = ('average winning cpm', 'avg price')
            COMMENT = 'Average winning CPM',
        
        inventory.delivered_impressions AS SUM(inventory.delivered_impressions)
            WITH SYNONYMS = ('impressions', 'views')
            COMMENT = 'Total delivered impressions',
        
        inventory.avg_completion_pct AS AVG(inventory.avg_completion_pct)
            WITH SYNONYMS = ('completion rate', 'video completion')
            COMMENT = 'Average completion rate',
        
        inventory.avg_viewability_pct AS AVG(inventory.avg_viewability_pct)
            WITH SYNONYMS = ('viewability')
            COMMENT = 'Average viewability score',
        
        inventory.total_revenue AS SUM(inventory.total_revenue)
            WITH SYNONYMS = ('revenue', 'earnings')
            COMMENT = 'Total revenue from slot',
        
        inventory.total_engagements AS SUM(inventory.total_engagements)
            WITH SYNONYMS = ('engagements', 'interactions')
            COMMENT = 'Total engagements',
        
        inventory.engagement_rate_pct AS AVG(inventory.engagement_rate_pct)
            WITH SYNONYMS = ('ctr', 'click rate', 'engagement rate')
            COMMENT = 'Engagement rate percentage'
    )

    COMMENT = 'Semantic view for ad inventory performance and availability analytics';

DESCRIBE SEMANTIC VIEW AD_TECH.CORTEX.SV_INVENTORY_ANALYTICS;
SELECT 'Inventory Semantic View created!' AS status;


-- ============================================================================
-- PART 3: AUDIENCE INSIGHTS SEMANTIC VIEW
-- Uses pre-aggregated gold layer view for simpler querying
-- ============================================================================
CREATE OR REPLACE SEMANTIC VIEW AD_TECH.CORTEX.SV_AUDIENCE_INSIGHTS

    TABLES (
        -- Pre-aggregated audience insights (from gold layer)
        cohorts AS AD_TECH.ANALYTICS.V_AUDIENCE_INSIGHTS 
            PRIMARY KEY (cohort_id)
            COMMENT = 'Audience cohort performance metrics (pre-aggregated, k-anonymity enforced)'
    )

    DIMENSIONS (
        -- Cohort dimensions
        cohorts.cohort_name AS cohorts.cohort_name
            WITH SYNONYMS = ('cohort', 'audience', 'segment')
            COMMENT = 'Name of the audience cohort',
        
        cohorts.age_bucket AS cohorts.age_bucket
            WITH SYNONYMS = ('age group', 'age range', 'age')
            COMMENT = 'Age bucket (18-24, 25-34, 35-44, 45-54, 55-64, 65+)',
        
        cohorts.gender AS cohorts.gender
            WITH SYNONYMS = ('sex')
            COMMENT = 'Gender (Male, Female, All)',
        
        cohorts.ethnicity AS cohorts.ethnicity
            COMMENT = 'Ethnicity demographic',
        
        cohorts.region AS cohorts.region
            WITH SYNONYMS = ('geographic region')
            COMMENT = 'Geographic region',
        
        cohorts.income_bracket AS cohorts.income_bracket
            WITH SYNONYMS = ('income', 'income level')
            COMMENT = 'Income bracket (Low, Medium, High, Very High)',
        
        cohorts.insurance_type AS cohorts.insurance_type
            WITH SYNONYMS = ('insurance', 'payer')
            COMMENT = 'Insurance type (Commercial, Medicare, Medicaid)',
        
        cohorts.health_interest AS cohorts.health_interest
            WITH SYNONYMS = ('health topic', 'interest area')
            COMMENT = 'Primary health interest category',
        
        cohorts.top_therapeutic_interests AS cohorts.top_therapeutic_interests
            WITH SYNONYMS = ('therapeutic interests', 'treatment interests')
            COMMENT = 'Top therapeutic interest areas'
    )

    METRICS (
        -- Cohort size (privacy-safe)
        cohorts.cohort_size AS SUM(cohorts.cohort_size)
            WITH SYNONYMS = ('size', 'audience size', 'members')
            COMMENT = 'Cohort size (minimum 50 for k-anonymity)',
        
        -- Baseline engagement
        cohorts.baseline_engagement_score AS AVG(cohorts.baseline_engagement_score)
            WITH SYNONYMS = ('engagement score', 'base engagement')
            COMMENT = 'Baseline engagement score (0-100)',
        
        cohorts.avg_visit_frequency AS AVG(cohorts.avg_visit_frequency)
            WITH SYNONYMS = ('visits per month', 'frequency')
            COMMENT = 'Average monthly visit frequency',
        
        -- Campaign exposure metrics
        cohorts.campaigns_exposed AS SUM(cohorts.campaigns_exposed)
            WITH SYNONYMS = ('campaigns', 'campaign exposure')
            COMMENT = 'Number of distinct campaigns this cohort was exposed to',
        
        cohorts.total_impressions AS SUM(cohorts.total_impressions)
            WITH SYNONYMS = ('impressions', 'ad views')
            COMMENT = 'Total impressions served to cohort',
        
        cohorts.avg_exposure_frequency AS AVG(cohorts.avg_exposure_frequency)
            WITH SYNONYMS = ('exposure frequency', 'ad frequency')
            COMMENT = 'Average exposure frequency',
        
        cohorts.avg_ad_completion_pct AS AVG(cohorts.avg_ad_completion_pct)
            WITH SYNONYMS = ('completion rate', 'video completion')
            COMMENT = 'Average ad completion rate percentage',
        
        -- Engagement metrics
        cohorts.total_engagements AS SUM(cohorts.total_engagements)
            WITH SYNONYMS = ('engagements', 'interactions')
            COMMENT = 'Total engagements from cohort',
        
        cohorts.engagement_rate_pct AS AVG(cohorts.engagement_rate_pct)
            WITH SYNONYMS = ('ctr', 'click rate', 'interaction rate', 'engagement rate')
            COMMENT = 'Engagement rate percentage',
        
        cohorts.avg_dwell_time_seconds AS AVG(cohorts.avg_dwell_time_seconds)
            WITH SYNONYMS = ('dwell time', 'attention time')
            COMMENT = 'Average dwell time in seconds',
        
        -- Conversion metrics
        cohorts.total_conversions AS SUM(cohorts.total_conversions)
            WITH SYNONYMS = ('conversions')
            COMMENT = 'Total conversions',
        
        cohorts.conversion_rate_pct AS AVG(cohorts.conversion_rate_pct)
            WITH SYNONYMS = ('cvr', 'conversion rate', 'conv rate')
            COMMENT = 'Conversion rate percentage',
        
        -- Revenue metrics
        cohorts.cohort_revenue AS SUM(cohorts.cohort_revenue)
            WITH SYNONYMS = ('revenue')
            COMMENT = 'Total revenue attributed to cohort',
        
        cohorts.revenue_per_member AS AVG(cohorts.revenue_per_member)
            WITH SYNONYMS = ('arpu', 'revenue per user')
            COMMENT = 'Revenue per cohort member'
    )

    COMMENT = 'Semantic view for privacy-safe audience cohort engagement analytics (k-anonymity enforced)';

DESCRIBE SEMANTIC VIEW AD_TECH.CORTEX.SV_AUDIENCE_INSIGHTS;
SELECT 'Audience Semantic View created!' AS status;


-- ============================================================================
-- VERIFY ALL SEMANTIC VIEWS
-- ============================================================================
SHOW SEMANTIC VIEWS IN SCHEMA AD_TECH.CORTEX;

SELECT 'All 3 Semantic Views created successfully!' AS status;

