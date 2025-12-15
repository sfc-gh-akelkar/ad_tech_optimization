/*
=============================================================================
PatientPoint Ad Tech Demo - STREAMLINED PRE-COMPUTED DATA
=============================================================================
This script creates FLAT, PRE-COMPUTED tables optimized for Cortex Agent demos.
NO JOINS REQUIRED at query time - all metrics are pre-calculated.

Tables created:
1. T_CAMPAIGN_PERFORMANCE - 100 campaigns with all KPIs
2. T_INVENTORY_ANALYTICS - 200 inventory slots with metrics  
3. T_AUDIENCE_INSIGHTS - 100 audience cohorts with engagement data

All dates are relative to CURRENT_DATE for demo freshness.
Run time: ~30 seconds total
=============================================================================
*/

USE ROLE SF_INTELLIGENCE_DEMO;
USE DATABASE AD_TECH;
USE SCHEMA ANALYTICS;
USE WAREHOUSE AD_TECH_WH;

-- ============================================================================
-- T_CAMPAIGN_PERFORMANCE - Pre-computed campaign metrics (100 campaigns)
-- This is what the Semantic View will query directly - NO JOINS
-- ALL METRICS ARE MATHEMATICALLY CONSISTENT
-- ============================================================================
CREATE OR REPLACE TABLE T_CAMPAIGN_PERFORMANCE AS
WITH partners AS (
    -- Accurate pharma partner list with correct drug ownership
    SELECT * FROM VALUES
        (1, 'Pfizer Inc.', 'Platinum', 'Big Pharma'),
        (2, 'Johnson & Johnson', 'Platinum', 'Big Pharma'),
        (3, 'Merck & Co.', 'Platinum', 'Big Pharma'),
        (4, 'Eli Lilly', 'Platinum', 'Big Pharma'),
        (5, 'AbbVie Inc.', 'Gold', 'Big Pharma'),
        (6, 'Bristol-Myers Squibb', 'Gold', 'Big Pharma'),
        (7, 'Novo Nordisk', 'Platinum', 'Big Pharma'),  -- Ozempic, Wegovy owner
        (8, 'AstraZeneca', 'Gold', 'Big Pharma'),
        (9, 'Sanofi', 'Gold', 'Big Pharma'),
        (10, 'Amgen', 'Silver', 'Biotech'),
        (11, 'Novartis', 'Gold', 'Big Pharma'),
        (12, 'Regeneron', 'Silver', 'Biotech'),
        (13, 'Biogen', 'Bronze', 'Biotech'),
        (14, 'Boehringer Ingelheim', 'Gold', 'Big Pharma'),
        (15, 'Takeda', 'Silver', 'Big Pharma')
    AS t(partner_id, partner_name, partner_tier, industry_segment)
),
drugs AS (
    -- Accurate drug-to-partner mappings
    SELECT * FROM VALUES
        -- Diabetes
        ('Jardiance', 'Diabetes', 14),      -- Boehringer Ingelheim / Eli Lilly
        ('Ozempic', 'Diabetes', 7),          -- Novo Nordisk
        ('Trulicity', 'Diabetes', 4),        -- Eli Lilly
        ('Farxiga', 'Diabetes', 8),          -- AstraZeneca
        -- Cardiology  
        ('Eliquis', 'Cardiology', 6),        -- Bristol-Myers Squibb / Pfizer
        ('Entresto', 'Cardiology', 11),      -- Novartis
        ('Repatha', 'Cardiology', 10),       -- Amgen
        -- Oncology
        ('Keytruda', 'Oncology', 3),         -- Merck
        ('Opdivo', 'Oncology', 6),           -- Bristol-Myers Squibb
        ('Ibrance', 'Oncology', 1),          -- Pfizer
        ('Tagrisso', 'Oncology', 8),         -- AstraZeneca
        -- Immunology
        ('Humira', 'Immunology', 5),         -- AbbVie
        ('Dupixent', 'Immunology', 9),       -- Sanofi / Regeneron
        ('Skyrizi', 'Immunology', 5),        -- AbbVie
        ('Rinvoq', 'Immunology', 5),         -- AbbVie
        -- Weight Loss / GLP-1
        ('Wegovy', 'Weight Loss', 7),        -- Novo Nordisk
        ('Mounjaro', 'Weight Loss', 4),      -- Eli Lilly
        ('Zepbound', 'Weight Loss', 4),      -- Eli Lilly
        -- Neurology
        ('Vyvanse', 'Neurology', 15),        -- Takeda
        ('Spinraza', 'Neurology', 13)        -- Biogen
    AS t(drug_name, therapeutic_area, partner_id)
),
specialties AS (
    SELECT * FROM VALUES
        ('Cardiology'), ('Endocrinology'), ('Oncology'), ('Primary Care'), 
        ('Neurology'), ('Dermatology'), ('Immunology'), ('Internal Medicine')
    AS t(specialty)
),
campaign_types AS (
    SELECT * FROM VALUES ('Awareness'), ('Education'), ('Direct Response') AS t(campaign_type)
),
-- Step 1: Generate base campaign data with random seeds
base_campaigns AS (
    SELECT
        d.drug_name,
        d.therapeutic_area,
        d.partner_id,
        p.partner_name,
        p.partner_tier,
        ct.campaign_type,
        sp.specialty AS target_specialty,
        UNIFORM(30, 400, RANDOM()) AS days_ago,
        -- Base metrics that drive everything else
        ROUND(UNIFORM(100000, 2000000, RANDOM()), -4) AS budget,
        UNIFORM(0.60, 0.95, RANDOM()) AS budget_utilization_rate,  -- 60-95% of budget spent
        UNIFORM(0.80, 5.50, RANDOM()) AS target_roas,              -- Target ROAS
        UNIFORM(50000, 500000, RANDOM()) AS total_impressions,
        UNIFORM(0.005, 0.045, RANDOM()) AS ctr_rate,               -- 0.5-4.5% CTR
        UNIFORM(0.02, 0.15, RANDOM()) AS conversion_rate,          -- 2-15% conversion rate
        UNIFORM(5000, 50000, RANDOM()) AS total_bids,
        UNIFORM(0.35, 0.85, RANDOM()) AS win_rate,                 -- 35-85% win rate
        UNIFORM(0.65, 0.95, RANDOM()) AS completion_rate,
        UNIFORM(0.70, 0.98, RANDOM()) AS viewability_rate
    FROM drugs d
    JOIN partners p ON d.partner_id = p.partner_id
    CROSS JOIN specialties sp
    CROSS JOIN campaign_types ct
    CROSS JOIN TABLE(GENERATOR(ROWCOUNT => 2))
),
-- Step 2: Derive all metrics mathematically
derived_campaigns AS (
    SELECT
        *,
        -- Derived financial metrics
        ROUND(budget * budget_utilization_rate, 2) AS spend,
        ROUND(budget * budget_utilization_rate * target_roas, 2) AS total_revenue,
        
        -- Derived engagement metrics (from impressions)
        ROUND(total_impressions * ctr_rate) AS total_clicks,
        ROUND(total_impressions * ctr_rate * conversion_rate) AS total_conversions,
        ROUND(total_impressions * ctr_rate * 0.5) AS total_engagements,  -- Engagements ~ 50% of clicks
        
        -- Derived bid metrics
        ROUND(total_bids * win_rate) AS winning_bids
    FROM base_campaigns
)
-- Step 3: Final SELECT with calculated percentages and IDs
SELECT
    'CAMP-' || LPAD(ROW_NUMBER() OVER (ORDER BY RANDOM())::VARCHAR, 5, '0') AS campaign_id,
    drug_name || ' ' || campaign_type || ' Q' || QUARTER(DATEADD(day, -days_ago, CURRENT_DATE())) || ' ' || YEAR(DATEADD(day, -days_ago, CURRENT_DATE())) AS campaign_name,
    drug_name,
    therapeutic_area,
    campaign_type,
    target_specialty,
    CASE 
        WHEN days_ago < 60 THEN 'Active'
        WHEN days_ago < 180 THEN CASE WHEN RANDOM() < 0.7 THEN 'Completed' ELSE 'Active' END
        ELSE 'Completed'
    END AS status,
    DATEADD(day, -days_ago::INT, CURRENT_DATE()) AS start_date,
    DATEADD(day, -days_ago::INT + UNIFORM(30, 90, RANDOM()), CURRENT_DATE()) AS end_date,
    budget::NUMBER(18,2) AS budget,
    partner_id,
    partner_name,
    partner_tier,
    
    -- Bid metrics
    total_bids,
    winning_bids,
    ROUND(win_rate * 100, 2)::NUMBER(8,2) AS win_rate_pct,
    ROUND(spend / NULLIF(winning_bids, 0) * 1000 / NULLIF(total_impressions / winning_bids, 0), 2)::NUMBER(12,2) AS avg_bid_cpm,
    
    -- Impression metrics
    total_impressions::INT AS total_impressions,
    ROUND(completion_rate * 100, 2)::NUMBER(8,2) AS avg_completion_rate_pct,
    ROUND(viewability_rate * 100, 2)::NUMBER(8,2) AS avg_viewability_pct,
    
    -- Engagement metrics (DERIVED from impressions × rates)
    total_engagements::INT AS total_engagements,
    ROUND(ctr_rate * 100, 4)::NUMBER(8,4) AS ctr_pct,               -- CTR = clicks / impressions
    total_conversions::INT AS total_conversions,
    ROUND(conversion_rate * 100, 2)::NUMBER(8,2) AS conversion_rate_pct,  -- Conv rate = conversions / clicks
    
    -- Revenue metrics (DERIVED: revenue = spend × ROAS)
    total_revenue::NUMBER(18,2) AS total_revenue,
    spend::NUMBER(18,2) AS total_spend,                             -- NEW: Actual spend
    ROUND(target_roas, 2)::NUMBER(10,4) AS roas,                    -- ROAS = revenue / spend
    ROUND(spend / NULLIF(total_impressions, 0) * 1000, 2)::NUMBER(12,2) AS effective_cpm  -- CPM = spend per 1000 impressions

FROM derived_campaigns
ORDER BY RANDOM()
LIMIT 100;

SELECT 'T_CAMPAIGN_PERFORMANCE created: ' || COUNT(*) || ' campaigns' AS status FROM T_CAMPAIGN_PERFORMANCE;


-- ============================================================================
-- T_INVENTORY_ANALYTICS - Pre-computed inventory metrics (200 slots)
-- ALL METRICS ARE MATHEMATICALLY CONSISTENT
-- Revenue = Impressions × CPM / 1000
-- ============================================================================
CREATE OR REPLACE TABLE T_INVENTORY_ANALYTICS AS
WITH facilities AS (
    SELECT * FROM VALUES
        ('Mayo Clinic', 'Hospital', 'Rochester', 'MN', 'Midwest', 85000, 8.5),
        ('Cleveland Clinic', 'Hospital', 'Cleveland', 'OH', 'Midwest', 78000, 8.2),
        ('Johns Hopkins', 'Hospital', 'Baltimore', 'MD', 'Northeast', 72000, 8.8),
        ('Massachusetts General', 'Hospital', 'Boston', 'MA', 'Northeast', 68000, 9.1),
        ('UCLA Medical Center', 'Hospital', 'Los Angeles', 'CA', 'West', 82000, 8.7),
        ('Houston Methodist', 'Hospital', 'Houston', 'TX', 'Southwest', 75000, 7.9),
        ('NY Presbyterian', 'Hospital', 'New York', 'NY', 'Northeast', 90000, 9.4),
        ('Stanford Health', 'Hospital', 'Palo Alto', 'CA', 'West', 55000, 9.2),
        ('Duke Health', 'Hospital', 'Durham', 'NC', 'Southeast', 62000, 8.0),
        ('Cedars-Sinai', 'Hospital', 'Los Angeles', 'CA', 'West', 58000, 9.0),
        ('Northwell Health', 'Medical Center', 'New York', 'NY', 'Northeast', 45000, 8.3),
        ('Emory Healthcare', 'Medical Center', 'Atlanta', 'GA', 'Southeast', 42000, 7.8),
        ('UPMC', 'Medical Center', 'Pittsburgh', 'PA', 'Northeast', 48000, 7.6),
        ('Scripps Health', 'Medical Center', 'San Diego', 'CA', 'West', 38000, 8.4),
        ('Baylor Scott White', 'Medical Center', 'Dallas', 'TX', 'Southwest', 52000, 7.5),
        ('Cardiology Associates', 'Clinic', 'Miami', 'FL', 'Southeast', 8000, 7.2),
        ('Diabetes Care Center', 'Clinic', 'Phoenix', 'AZ', 'Southwest', 6500, 6.8),
        ('Oncology Partners', 'Clinic', 'Chicago', 'IL', 'Midwest', 7200, 7.4),
        ('Primary Care Plus', 'Clinic', 'Denver', 'CO', 'West', 12000, 6.5),
        ('Family Medicine Group', 'Clinic', 'Seattle', 'WA', 'West', 9500, 7.0)
    AS t(facility_name, facility_type, city, state, region, patient_volume, affluence_index)
),
specialties AS (
    SELECT * FROM VALUES
        ('Cardiology', 'Specialty', 1.4), ('Endocrinology', 'Specialty', 1.3),
        ('Oncology', 'Specialty', 1.5), ('Primary Care', 'General', 1.0),
        ('Neurology', 'Specialty', 1.35), ('Dermatology', 'Specialty', 1.25),
        ('Internal Medicine', 'General', 1.1), ('Orthopedics', 'Specialty', 1.2)
    AS t(specialty_name, specialty_category, cpm_multiplier)
),
screen_types AS (
    SELECT * FROM VALUES 
        ('Digital Display', 'Large', 500), ('Tablet', 'Small', 200), 
        ('Kiosk', 'Medium', 350), ('TV Screen', 'Large', 450)
    AS t(screen_type, screen_size, base_impressions)
),
placements AS (
    SELECT * FROM VALUES ('Waiting Room', 25), ('Exam Room', 35), ('Check-in', 18), ('Hallway', 12) AS t(placement_area, base_cpm)
),
dayparts AS (
    SELECT * FROM VALUES ('Morning', 1.1), ('Afternoon', 1.0), ('Evening', 0.9), ('All Day', 1.05) AS t(daypart, multiplier)
),
-- Step 1: Base slot data with random seeds
base_slots AS (
    SELECT
        f.facility_name, f.facility_type, f.city, f.state, f.region, f.patient_volume, f.affluence_index,
        sp.specialty_name, sp.specialty_category, sp.cpm_multiplier,
        st.screen_type, st.screen_size, st.base_impressions,
        pl.placement_area, pl.base_cpm,
        dp.daypart, dp.multiplier AS daypart_multiplier,
        -- Base rates that drive everything
        UNIFORM(0.40, 0.90, RANDOM()) AS fill_rate,              -- 40-90% fill rate
        UNIFORM(0.003, 0.035, RANDOM()) AS engagement_rate,      -- 0.3-3.5% engagement
        UNIFORM(0.70, 0.98, RANDOM()) AS completion_rate,
        UNIFORM(0.75, 0.99, RANDOM()) AS viewability_rate,
        UNIFORM(60, 180, RANDOM()) AS days_of_data              -- 60-180 days of historical data
    FROM facilities f
    CROSS JOIN specialties sp
    CROSS JOIN screen_types st
    CROSS JOIN placements pl
    CROSS JOIN dayparts dp
),
-- Step 2: Derive all metrics mathematically
derived_slots AS (
    SELECT
        *,
        -- CPM calculation
        ROUND(base_cpm * cpm_multiplier * daypart_multiplier, 2) AS calc_base_cpm,
        ROUND(base_cpm * cpm_multiplier * daypart_multiplier * UNIFORM(1.0, 1.4, RANDOM()), 2) AS avg_winning_cpm,
        
        -- Daily impressions (use UNIFORM for 0-1 range, not RANDOM())
        ROUND(base_impressions * daypart_multiplier * UNIFORM(0.8, 1.2, RANDOM())) AS est_daily_impressions,
        
        -- Total impressions over time period
        ROUND(base_impressions * daypart_multiplier * UNIFORM(0.8, 1.2, RANDOM()) * days_of_data * fill_rate) AS delivered_impressions,
        
        -- Total bids (more bids than impressions since fill rate < 100%)
        ROUND(base_impressions * daypart_multiplier * days_of_data * 1.2) AS total_bids
    FROM base_slots
)
-- Step 3: Final SELECT with calculated revenue and engagement
SELECT
    'SLOT-' || LPAD(ROW_NUMBER() OVER (ORDER BY RANDOM())::VARCHAR, 5, '0') AS slot_id,
    facility_name || ' - ' || placement_area || ' ' || screen_type AS slot_name,
    screen_type,
    screen_size,
    placement_area,
    daypart,
    calc_base_cpm::NUMBER(12,2) AS base_cpm,
    CASE WHEN RANDOM() < 0.3 THEN TRUE ELSE FALSE END AS is_premium,
    est_daily_impressions::INT AS estimated_daily_impressions,
    
    -- Location info
    facility_name,
    facility_type,
    city,
    state,
    region,
    patient_volume,
    ROUND(affluence_index, 2)::NUMBER(5,2) AS affluence_index,
    
    -- Specialty info
    specialty_name,
    specialty_category,
    
    -- Performance metrics (MATHEMATICALLY CONSISTENT)
    total_bids::INT AS total_bids,
    ROUND(fill_rate * 100, 2)::NUMBER(8,2) AS fill_rate_pct,
    delivered_impressions::INT AS delivered_impressions,
    avg_winning_cpm::NUMBER(12,2) AS avg_winning_cpm,
    ROUND(completion_rate * 100, 2)::NUMBER(8,2) AS avg_completion_pct,
    ROUND(viewability_rate * 100, 2)::NUMBER(8,2) AS avg_viewability_pct,
    
    -- Engagements DERIVED from impressions × engagement rate
    ROUND(delivered_impressions * engagement_rate)::INT AS total_engagements,
    ROUND(engagement_rate * 100, 4)::NUMBER(8,4) AS engagement_rate_pct,
    
    -- Revenue DERIVED: impressions × CPM / 1000
    ROUND(delivered_impressions * avg_winning_cpm / 1000, 2)::NUMBER(18,2) AS total_revenue

FROM derived_slots
ORDER BY RANDOM()
LIMIT 200;

SELECT 'T_INVENTORY_ANALYTICS created: ' || COUNT(*) || ' slots' AS status FROM T_INVENTORY_ANALYTICS;


-- ============================================================================
-- T_AUDIENCE_INSIGHTS - Pre-computed audience cohort metrics (100 cohorts)
-- ALL METRICS ARE MATHEMATICALLY CONSISTENT
-- Conversions derived from Engagements, Revenue derived from Cohort Size
-- ============================================================================
CREATE OR REPLACE TABLE T_AUDIENCE_INSIGHTS AS
WITH age_buckets AS (
    SELECT * FROM VALUES ('18-24', 0.08), ('25-34', 0.15), ('35-44', 0.18), ('45-54', 0.22), ('55-64', 0.20), ('65+', 0.17) AS t(age_bucket, weight)
),
genders AS (
    SELECT * FROM VALUES ('Male', 0.48), ('Female', 0.48), ('All', 0.04) AS t(gender, weight)
),
regions AS (
    SELECT * FROM VALUES ('Northeast', 0.22), ('Southeast', 0.24), ('Midwest', 0.21), ('Southwest', 0.15), ('West', 0.18) AS t(region, weight)
),
income_brackets AS (
    SELECT * FROM VALUES ('Low', 0.25), ('Medium', 0.40), ('High', 0.25), ('Very High', 0.10) AS t(income_bracket, weight)
),
insurance_types AS (
    SELECT * FROM VALUES ('Commercial', 0.55), ('Medicare', 0.28), ('Medicaid', 0.12), ('Uninsured', 0.05) AS t(insurance_type, weight)
),
health_interests AS (
    SELECT * FROM VALUES 
        ('Diabetes Management', 'Diabetes, Endocrinology, Nutrition'),
        ('Heart Health', 'Cardiology, Blood Pressure, Cholesterol'),
        ('Cancer Awareness', 'Oncology, Prevention, Treatment'),
        ('Weight Management', 'Obesity, Nutrition, Fitness'),
        ('Mental Wellness', 'Neurology, Psychology, Stress'),
        ('Skin Health', 'Dermatology, Cosmetic, Sun Protection'),
        ('Joint & Bone Health', 'Orthopedics, Arthritis, Osteoporosis'),
        ('Respiratory Health', 'Pulmonology, Allergies, Asthma'),
        ('General Wellness', 'Prevention, Checkups, Lifestyle'),
        ('Womens Health', 'Gynecology, Pregnancy, Menopause')
    AS t(health_interest, therapeutic_interests)
),
-- Step 1: Base cohort data with random seeds
base_cohorts AS (
    SELECT
        ag.age_bucket, ag.weight AS age_weight,
        g.gender,
        r.region,
        ib.income_bracket,
        it.insurance_type,
        hi.health_interest, hi.therapeutic_interests,
        -- Base metrics that drive everything else
        UNIFORM(50, 5000, RANDOM()) AS cohort_size,
        UNIFORM(10, 100, RANDOM()) AS impressions_per_member,    -- Avg impressions per cohort member
        UNIFORM(0.005, 0.040, RANDOM()) AS engagement_rate,      -- 0.5-4.0% engagement rate
        UNIFORM(0.05, 0.25, RANDOM()) AS conversion_rate,        -- 5-25% of engagements convert
        UNIFORM(0.50, 15.00, RANDOM()) AS revenue_per_member,    -- Revenue attribution per member
        UNIFORM(5, 25, RANDOM()) AS campaigns_exposed,
        UNIFORM(40, 95, RANDOM()) AS baseline_engagement_score,
        UNIFORM(1.5, 6.5, RANDOM()) AS avg_visit_frequency,
        UNIFORM(15, 120, RANDOM()) AS avg_dwell_time_seconds,
        UNIFORM(0.60, 0.95, RANDOM()) AS ad_completion_rate
    FROM age_buckets ag
    CROSS JOIN genders g
    CROSS JOIN regions r
    CROSS JOIN income_brackets ib
    CROSS JOIN insurance_types it
    CROSS JOIN health_interests hi
),
-- Step 2: Derive all metrics mathematically
derived_cohorts AS (
    SELECT
        *,
        -- Impressions = cohort_size × impressions_per_member
        ROUND(cohort_size * impressions_per_member) AS total_impressions,
        
        -- Engagements = impressions × engagement_rate
        ROUND(cohort_size * impressions_per_member * engagement_rate) AS total_engagements,
        
        -- Conversions = engagements × conversion_rate
        ROUND(cohort_size * impressions_per_member * engagement_rate * conversion_rate) AS total_conversions,
        
        -- Revenue = cohort_size × revenue_per_member
        ROUND(cohort_size * revenue_per_member, 2) AS cohort_revenue,
        
        -- Exposure frequency = impressions / cohort_size
        ROUND(impressions_per_member / NULLIF(campaigns_exposed, 0), 1) AS avg_exposure_frequency
    FROM base_cohorts
)
-- Step 3: Final SELECT with calculated percentages
SELECT
    'COH-' || LPAD(ROW_NUMBER() OVER (ORDER BY RANDOM())::VARCHAR, 5, '0') AS cohort_id,
    age_bucket || ' ' || gender || ' - ' || health_interest || ' (' || region || ')' AS cohort_name,
    age_bucket,
    gender,
    CASE WHEN RANDOM() < 0.6 THEN 'Not Specified' 
         WHEN RANDOM() < 0.75 THEN 'White' 
         WHEN RANDOM() < 0.85 THEN 'Hispanic' 
         WHEN RANDOM() < 0.92 THEN 'Black' 
         ELSE 'Asian' END AS ethnicity,
    region,
    income_bracket,
    insurance_type,
    health_interest,
    therapeutic_interests AS top_therapeutic_interests,
    
    -- Cohort size (min 50 for k-anonymity)
    cohort_size::INT AS cohort_size,
    ROUND(baseline_engagement_score, 1)::NUMBER(5,1) AS baseline_engagement_score,
    ROUND(avg_visit_frequency, 1)::NUMBER(4,1) AS avg_visit_frequency,
    
    -- Campaign exposure
    campaigns_exposed::INT AS campaigns_exposed,
    total_impressions::INT AS total_impressions,
    GREATEST(avg_exposure_frequency, 2.0)::NUMBER(4,1) AS avg_exposure_frequency,  -- Min 2x exposure
    
    -- Engagement metrics (MATHEMATICALLY CONSISTENT)
    total_engagements::INT AS total_engagements,
    ROUND(engagement_rate * 100, 3)::NUMBER(8,3) AS engagement_rate_pct,           -- Derived from calculation
    total_conversions::INT AS total_conversions,
    -- Conversion rate = conversions / engagements × 100
    ROUND(CASE WHEN total_engagements > 0 THEN total_conversions / total_engagements * 100 ELSE 0 END, 2)::NUMBER(8,2) AS conversion_rate_pct,
    
    -- Behavioral metrics
    ROUND(avg_dwell_time_seconds, 1)::NUMBER(6,1) AS avg_dwell_time_seconds,
    ROUND(ad_completion_rate * 100, 2)::NUMBER(5,2) AS avg_ad_completion_pct,
    
    -- Value metrics (MATHEMATICALLY CONSISTENT)
    cohort_revenue::NUMBER(18,2) AS cohort_revenue,
    ROUND(revenue_per_member, 4)::NUMBER(10,4) AS revenue_per_member               -- Revenue per member = cohort_revenue / cohort_size

FROM derived_cohorts
ORDER BY RANDOM()
LIMIT 100;

SELECT 'T_AUDIENCE_INSIGHTS created: ' || COUNT(*) || ' cohorts' AS status FROM T_AUDIENCE_INSIGHTS;


-- ============================================================================
-- VERIFICATION
-- ============================================================================
SELECT 'DEMO DATA READY!' AS status;
SELECT 'T_CAMPAIGN_PERFORMANCE' AS table_name, COUNT(*) AS rec FROM T_CAMPAIGN_PERFORMANCE
UNION ALL SELECT 'T_INVENTORY_ANALYTICS', COUNT(*) AS rec FROM T_INVENTORY_ANALYTICS
UNION ALL SELECT 'T_AUDIENCE_INSIGHTS', COUNT(*) AS rec FROM T_AUDIENCE_INSIGHTS;