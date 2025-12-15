/*
=============================================================================
PatientPoint Ad Tech Optimization Demo - Gold Layer Views
=============================================================================
Creates aggregated views for analytics, reporting, and Cortex services.
These views serve as the foundation for Semantic Views and Search Services.
All objects use SF_INTELLIGENCE_DEMO role.
=============================================================================
*/

USE ROLE SF_INTELLIGENCE_DEMO;
USE DATABASE AD_TECH;
USE SCHEMA ANALYTICS;
USE WAREHOUSE AD_TECH_WH;

-- ============================================================================
-- V_CAMPAIGN_PERFORMANCE - Campaign-Level KPIs
-- NOTE: All aggregations cast to NUMBER for Cortex Search compatibility
-- ============================================================================
CREATE OR REPLACE VIEW V_CAMPAIGN_PERFORMANCE AS
SELECT
    c.campaign_id,
    c.campaign_name,
    c.drug_name,
    c.therapeutic_area,
    c.campaign_type,
    c.target_specialty,
    c.status,
    c.start_date,
    c.end_date,
    CAST(c.budget AS NUMBER(18,2)) AS budget,
    p.partner_id,
    p.partner_name,
    p.partner_tier,
    
    -- Bid metrics (cast to NUMBER for change tracking)
    COUNT(DISTINCT b.bid_id) AS total_bids,
    SUM(CASE WHEN b.win_flag THEN 1 ELSE 0 END) AS winning_bids,
    CAST(ROUND(SUM(CASE WHEN b.win_flag THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(b.bid_id), 0), 2) AS NUMBER(8,2)) AS win_rate_pct,
    CAST(ROUND(AVG(b.bid_amount), 2) AS NUMBER(12,2)) AS avg_bid_cpm,
    
    -- Impression metrics (cast to NUMBER for change tracking)
    COUNT(DISTINCT i.impression_id) AS total_impressions,
    CAST(ROUND(AVG(i.completion_rate) * 100, 2) AS NUMBER(8,2)) AS avg_completion_rate_pct,
    CAST(ROUND(AVG(i.viewability_score) * 100, 2) AS NUMBER(8,2)) AS avg_viewability_pct,
    
    -- Engagement metrics (cast to NUMBER for change tracking)
    COUNT(DISTINCT e.engagement_id) AS total_engagements,
    CAST(ROUND(COUNT(DISTINCT e.engagement_id) * 100.0 / NULLIF(COUNT(DISTINCT i.impression_id), 0), 4) AS NUMBER(8,4)) AS ctr_pct,
    SUM(CASE WHEN e.conversion_flag THEN 1 ELSE 0 END) AS total_conversions,
    CAST(ROUND(SUM(CASE WHEN e.conversion_flag THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(DISTINCT e.engagement_id), 0), 2) AS NUMBER(8,2)) AS conversion_rate_pct,
    
    -- Financial metrics (cast to NUMBER for change tracking)
    CAST(SUM(i.revenue) AS NUMBER(18,2)) AS total_revenue,
    CAST(ROUND(SUM(i.revenue) / NULLIF(MAX(c.budget), 0), 2) AS NUMBER(10,4)) AS roas,
    CAST(ROUND(SUM(i.revenue) / NULLIF(COUNT(DISTINCT i.impression_id), 0) * 1000, 2) AS NUMBER(12,2)) AS effective_cpm,
    
    -- Time metrics
    MIN(i.impression_timestamp) AS first_impression,
    MAX(i.impression_timestamp) AS last_impression,
    DATEDIFF(day, MIN(i.impression_timestamp), MAX(i.impression_timestamp)) AS campaign_duration_days

FROM DIM_CAMPAIGNS c
JOIN DIM_PHARMA_PARTNERS p ON c.partner_id = p.partner_id
LEFT JOIN FACT_BIDS b ON c.campaign_id = b.campaign_id
LEFT JOIN FACT_IMPRESSIONS i ON c.campaign_id = i.campaign_id
LEFT JOIN FACT_ENGAGEMENTS e ON c.campaign_id = e.campaign_id
GROUP BY all;

-- ============================================================================
-- V_CAMPAIGN_DAILY_METRICS - Daily Campaign Performance
-- ============================================================================
CREATE OR REPLACE VIEW V_CAMPAIGN_DAILY_METRICS AS
SELECT
    d.full_date,
    d.year,
    d.quarter_name,
    d.month_name,
    d.day_name,
    d.is_weekend,
    c.campaign_id,
    c.campaign_name,
    c.drug_name,
    c.therapeutic_area,
    p.partner_name,
    
    COUNT(DISTINCT b.bid_id) AS bids,
    SUM(CASE WHEN b.win_flag THEN 1 ELSE 0 END) AS wins,
    COUNT(DISTINCT i.impression_id) AS impressions,
    COUNT(DISTINCT e.engagement_id) AS engagements,
    SUM(CASE WHEN e.conversion_flag THEN 1 ELSE 0 END) AS conversions,
    SUM(i.revenue) AS revenue,
    ROUND(AVG(b.bid_amount), 2) AS avg_cpm

FROM DIM_DATE d
LEFT JOIN FACT_BIDS b ON d.date_key = b.date_key
LEFT JOIN DIM_CAMPAIGNS c ON b.campaign_id = c.campaign_id
LEFT JOIN DIM_PHARMA_PARTNERS p ON c.partner_id = p.partner_id
LEFT JOIN FACT_IMPRESSIONS i ON b.bid_id = i.bid_id
LEFT JOIN FACT_ENGAGEMENTS e ON i.impression_id = e.impression_id
WHERE c.campaign_id IS NOT NULL
GROUP BY all;

-- ============================================================================
-- V_INVENTORY_ANALYTICS - Slot-Level Performance Metrics
-- NOTE: All aggregations cast to NUMBER for Cortex Search compatibility
-- ============================================================================
CREATE OR REPLACE VIEW V_INVENTORY_ANALYTICS AS
SELECT
    inv.slot_id,
    inv.slot_name,
    inv.screen_type,
    inv.screen_size,
    inv.placement_area,
    inv.daypart,
    CAST(inv.base_cpm AS NUMBER(12,2)) AS base_cpm,
    inv.is_premium,
    inv.daily_impressions AS estimated_daily_impressions,
    
    -- Location info (cast floats to NUMBER)
    l.location_id,
    l.facility_name,
    l.facility_type,
    l.city,
    l.state,
    l.region,
    l.dma_name,
    l.patient_volume,
    CAST(l.affluence_index AS NUMBER(5,2)) AS affluence_index,
    
    -- Specialty info (cast floats to NUMBER)
    s.specialty_id,
    s.specialty_name,
    s.specialty_category,
    CAST(s.base_cpm_multiplier AS NUMBER(5,2)) AS specialty_premium,
    
    -- Performance metrics (cast to NUMBER for change tracking)
    COUNT(DISTINCT b.bid_id) AS total_bids,
    CAST(ROUND(SUM(CASE WHEN b.win_flag THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(b.bid_id), 0), 2) AS NUMBER(8,2)) AS fill_rate_pct,
    COUNT(DISTINCT i.impression_id) AS delivered_impressions,
    CAST(ROUND(AVG(b.bid_amount), 2) AS NUMBER(12,2)) AS avg_winning_cpm,
    CAST(ROUND(AVG(i.completion_rate) * 100, 2) AS NUMBER(8,2)) AS avg_completion_pct,
    CAST(ROUND(AVG(i.viewability_score) * 100, 2) AS NUMBER(8,2)) AS avg_viewability_pct,
    
    -- Engagement (cast to NUMBER for change tracking)
    COUNT(DISTINCT e.engagement_id) AS total_engagements,
    CAST(ROUND(COUNT(DISTINCT e.engagement_id) * 100.0 / NULLIF(COUNT(DISTINCT i.impression_id), 0), 3) AS NUMBER(8,4)) AS engagement_rate_pct,
    
    -- Revenue (cast to NUMBER for change tracking)
    CAST(SUM(i.revenue) AS NUMBER(18,2)) AS total_revenue,
    CAST(ROUND(SUM(i.revenue) / NULLIF(COUNT(DISTINCT i.impression_id), 0) * 1000, 2) AS NUMBER(12,2)) AS revenue_per_thousand

FROM DIM_INVENTORY inv
JOIN DIM_LOCATIONS l ON inv.location_id = l.location_id
JOIN DIM_MEDICAL_SPECIALTIES s ON inv.specialty_id = s.specialty_id
LEFT JOIN FACT_BIDS b ON inv.slot_id = b.slot_id
LEFT JOIN FACT_IMPRESSIONS i ON inv.slot_id = i.slot_id
LEFT JOIN FACT_ENGAGEMENTS e ON inv.slot_id = e.slot_id
WHERE inv.is_active = TRUE
GROUP BY all;

-- ============================================================================
-- V_AUDIENCE_INSIGHTS - Cohort Engagement Analysis
-- ============================================================================
CREATE OR REPLACE VIEW V_AUDIENCE_INSIGHTS AS
SELECT
    a.cohort_id,
    a.cohort_name,
    a.age_bucket,
    a.gender,
    a.ethnicity,
    a.region,
    a.income_bracket,
    a.insurance_type,
    a.health_interest,
    a.cohort_size,
    a.avg_engagement_score AS baseline_engagement_score,
    a.avg_visit_frequency,
    a.top_therapeutic_interests,
    
    -- Campaign exposure metrics
    COUNT(DISTINCT i.campaign_id) AS campaigns_exposed,
    COUNT(DISTINCT i.impression_id) AS total_impressions,
    ROUND(AVG(i.exposure_count), 1) AS avg_exposure_frequency,
    
    -- Engagement metrics
    COUNT(DISTINCT e.engagement_id) AS total_engagements,
    ROUND(COUNT(DISTINCT e.engagement_id) * 100.0 / NULLIF(COUNT(DISTINCT i.impression_id), 0), 3) AS engagement_rate_pct,
    SUM(CASE WHEN e.conversion_flag THEN 1 ELSE 0 END) AS total_conversions,
    ROUND(SUM(CASE WHEN e.conversion_flag THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(DISTINCT e.engagement_id), 0), 2) AS conversion_rate_pct,
    
    -- Behavioral metrics
    ROUND(AVG(e.dwell_time_seconds), 1) AS avg_dwell_time_seconds,
    ROUND(AVG(i.completion_rate) * 100, 2) AS avg_ad_completion_pct,
    
    -- Value metrics
    SUM(i.revenue) AS cohort_revenue,
    ROUND(SUM(i.revenue) / NULLIF(a.cohort_size, 0), 4) AS revenue_per_member

FROM DIM_AUDIENCE_COHORTS a
LEFT JOIN FACT_IMPRESSIONS i ON a.cohort_id = i.cohort_id
LEFT JOIN FACT_ENGAGEMENTS e ON a.cohort_id = e.cohort_id
GROUP BY all;

-- ============================================================================
-- V_CROSS_CHANNEL_ATTRIBUTION - Multi-Touch Attribution Analysis
-- ============================================================================
CREATE OR REPLACE VIEW V_CROSS_CHANNEL_ATTRIBUTION AS
SELECT
    c.campaign_id,
    c.campaign_name,
    c.drug_name,
    c.therapeutic_area,
    p.partner_name,
    
    -- Channel breakdown
    inv.screen_type AS channel,
    inv.placement_area,
    s.specialty_name,
    
    -- Attribution metrics
    COUNT(DISTINCT e.engagement_id) AS touchpoints,
    SUM(e.attribution_weight) AS attributed_weight,
    SUM(CASE WHEN e.is_last_touch THEN 1 ELSE 0 END) AS last_touch_conversions,
    SUM(CASE WHEN e.conversion_flag THEN 1 ELSE 0 END) AS total_conversions,
    
    -- Revenue attribution
    SUM(i.revenue * e.attribution_weight) AS attributed_revenue,
    
    -- Engagement quality
    ROUND(AVG(e.dwell_time_seconds), 1) AS avg_dwell_time,
    ROUND(AVG(i.completion_rate) * 100, 2) AS avg_completion_rate

FROM FACT_ENGAGEMENTS e
JOIN FACT_IMPRESSIONS i ON e.impression_id = i.impression_id
JOIN DIM_CAMPAIGNS c ON e.campaign_id = c.campaign_id
JOIN DIM_PHARMA_PARTNERS p ON c.partner_id = p.partner_id
JOIN DIM_INVENTORY inv ON e.slot_id = inv.slot_id
JOIN DIM_MEDICAL_SPECIALTIES s ON inv.specialty_id = s.specialty_id
GROUP BY all;

-- ============================================================================
-- V_SPECIALTY_PERFORMANCE - Performance by Medical Specialty
-- ============================================================================
CREATE OR REPLACE VIEW V_SPECIALTY_PERFORMANCE AS
SELECT
    s.specialty_id,
    s.specialty_name,
    s.specialty_category,
    s.patient_volume_tier,
    s.base_cpm_multiplier,
    
    -- Inventory metrics
    COUNT(DISTINCT inv.slot_id) AS total_slots,
    SUM(inv.daily_impressions) AS total_daily_capacity,
    ROUND(AVG(inv.base_cpm), 2) AS avg_base_cpm,
    
    -- Bid metrics
    COUNT(DISTINCT b.bid_id) AS total_bids,
    ROUND(AVG(b.bid_amount), 2) AS avg_bid_cpm,
    ROUND(SUM(CASE WHEN b.win_flag THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(b.bid_id), 0), 2) AS win_rate_pct,
    
    -- Impression metrics
    COUNT(DISTINCT i.impression_id) AS total_impressions,
    ROUND(AVG(i.viewability_score) * 100, 2) AS avg_viewability_pct,
    
    -- Engagement metrics
    COUNT(DISTINCT e.engagement_id) AS total_engagements,
    ROUND(COUNT(DISTINCT e.engagement_id) * 100.0 / NULLIF(COUNT(DISTINCT i.impression_id), 0), 3) AS ctr_pct,
    
    -- Revenue
    SUM(i.revenue) AS total_revenue,
    ROUND(SUM(i.revenue) / NULLIF(COUNT(DISTINCT i.impression_id), 0) * 1000, 2) AS rpm

FROM DIM_MEDICAL_SPECIALTIES s
LEFT JOIN DIM_INVENTORY inv ON s.specialty_id = inv.specialty_id
LEFT JOIN FACT_BIDS b ON inv.slot_id = b.slot_id
LEFT JOIN FACT_IMPRESSIONS i ON inv.slot_id = i.slot_id
LEFT JOIN FACT_ENGAGEMENTS e ON inv.slot_id = e.slot_id
GROUP BY 1,2,3,4,5;

-- ============================================================================
-- V_PARTNER_SUMMARY - Pharma Partner Performance Summary
-- ============================================================================
CREATE OR REPLACE VIEW V_PARTNER_SUMMARY AS
SELECT
    p.partner_id,
    p.partner_name,
    p.partner_tier,
    p.industry_segment,
    p.annual_budget,
    
    -- Campaign metrics
    COUNT(DISTINCT c.campaign_id) AS total_campaigns,
    SUM(c.budget) AS total_campaign_budget,
    
    -- Performance metrics
    COUNT(DISTINCT i.impression_id) AS total_impressions,
    COUNT(DISTINCT e.engagement_id) AS total_engagements,
    SUM(CASE WHEN e.conversion_flag THEN 1 ELSE 0 END) AS total_conversions,
    
    -- Financial metrics
    SUM(i.revenue) AS total_spend,
    ROUND(SUM(i.revenue) / NULLIF(SUM(c.budget), 0), 2) AS budget_utilization,
    ROUND(SUM(CASE WHEN e.conversion_flag THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(DISTINCT e.engagement_id), 0), 2) AS conversion_rate_pct,
    
    -- Efficiency metrics
    ROUND(COUNT(DISTINCT e.engagement_id) * 100.0 / NULLIF(COUNT(DISTINCT i.impression_id), 0), 3) AS avg_ctr_pct,
    ROUND(SUM(i.revenue) / NULLIF(SUM(CASE WHEN e.conversion_flag THEN 1 ELSE 0 END), 0), 2) AS cost_per_conversion

FROM DIM_PHARMA_PARTNERS p
LEFT JOIN DIM_CAMPAIGNS c ON p.partner_id = c.partner_id
LEFT JOIN FACT_IMPRESSIONS i ON c.campaign_id = i.campaign_id
LEFT JOIN FACT_ENGAGEMENTS e ON c.campaign_id = e.campaign_id
WHERE p.is_active = TRUE
GROUP BY 1,2,3,4,5;

-- ============================================================================
-- V_DAYPART_ANALYSIS - Performance by Time of Day
-- ============================================================================
CREATE OR REPLACE VIEW V_DAYPART_ANALYSIS AS
SELECT
    b.daypart,
    d.day_name,
    d.is_weekend,
    
    -- Volume metrics
    COUNT(DISTINCT b.bid_id) AS total_bids,
    COUNT(DISTINCT i.impression_id) AS total_impressions,
    
    -- Performance metrics
    ROUND(SUM(CASE WHEN b.win_flag THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(b.bid_id), 0), 2) AS win_rate_pct,
    ROUND(AVG(b.bid_amount), 2) AS avg_cpm,
    
    -- Engagement
    COUNT(DISTINCT e.engagement_id) AS total_engagements,
    ROUND(COUNT(DISTINCT e.engagement_id) * 100.0 / NULLIF(COUNT(DISTINCT i.impression_id), 0), 3) AS ctr_pct,
    
    -- Revenue
    SUM(i.revenue) AS total_revenue

FROM FACT_BIDS b
JOIN DIM_DATE d ON b.date_key = d.date_key
LEFT JOIN FACT_IMPRESSIONS i ON b.bid_id = i.bid_id
LEFT JOIN FACT_ENGAGEMENTS e ON i.impression_id = e.impression_id
GROUP BY 1,2,3;

-- ============================================================================
-- V_REGIONAL_PERFORMANCE - Geographic Performance Analysis
-- ============================================================================
CREATE OR REPLACE VIEW V_REGIONAL_PERFORMANCE AS
SELECT
    l.region,
    l.state,
    l.dma_name,
    
    -- Location metrics
    COUNT(DISTINCT l.location_id) AS facilities,
    COUNT(DISTINCT inv.slot_id) AS total_slots,
    SUM(l.patient_volume) AS total_patient_volume,
    
    -- Performance metrics
    COUNT(DISTINCT i.impression_id) AS total_impressions,
    COUNT(DISTINCT e.engagement_id) AS total_engagements,
    ROUND(COUNT(DISTINCT e.engagement_id) * 100.0 / NULLIF(COUNT(DISTINCT i.impression_id), 0), 3) AS ctr_pct,
    
    -- Revenue
    SUM(i.revenue) AS total_revenue,
    ROUND(SUM(i.revenue) / NULLIF(COUNT(DISTINCT l.location_id), 0), 2) AS revenue_per_facility

FROM DIM_LOCATIONS l
LEFT JOIN DIM_INVENTORY inv ON l.location_id = inv.location_id
LEFT JOIN FACT_IMPRESSIONS i ON inv.slot_id = i.slot_id
LEFT JOIN FACT_ENGAGEMENTS e ON inv.slot_id = e.slot_id
GROUP BY 1,2,3;

-- ============================================================================
-- Verify all views
-- ============================================================================
SELECT 'Gold layer views created successfully!' AS status;

SHOW VIEWS IN SCHEMA AD_TECH.ANALYTICS;

