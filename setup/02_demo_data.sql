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
-- ============================================================================
CREATE OR REPLACE TABLE T_CAMPAIGN_PERFORMANCE AS
WITH partners AS (
    SELECT * FROM VALUES
        (1, 'Pfizer Inc.', 'Platinum', 'Big Pharma'),
        (2, 'Johnson & Johnson', 'Platinum', 'Big Pharma'),
        (3, 'Merck & Co.', 'Platinum', 'Big Pharma'),
        (4, 'Eli Lilly', 'Platinum', 'Big Pharma'),
        (5, 'AbbVie Inc.', 'Gold', 'Big Pharma'),
        (6, 'Bristol-Myers Squibb', 'Gold', 'Big Pharma'),
        (7, 'Novartis', 'Gold', 'Big Pharma'),
        (8, 'AstraZeneca', 'Gold', 'Big Pharma'),
        (9, 'Sanofi', 'Gold', 'Big Pharma'),
        (10, 'Amgen', 'Silver', 'Biotech'),
        (11, 'Gilead Sciences', 'Silver', 'Biotech'),
        (12, 'Moderna', 'Silver', 'Biotech'),
        (13, 'Regeneron', 'Bronze', 'Biotech'),
        (14, 'Biogen', 'Bronze', 'Biotech'),
        (15, 'Medtronic', 'Gold', 'Medical Device')
    AS t(partner_id, partner_name, partner_tier, industry_segment)
),
drugs AS (
    SELECT * FROM VALUES
        ('Jardiance', 'Diabetes', 1), ('Ozempic', 'Diabetes', 4), ('Trulicity', 'Diabetes', 4),
        ('Eliquis', 'Cardiology', 6), ('Entresto', 'Cardiology', 7), ('Repatha', 'Cardiology', 10),
        ('Keytruda', 'Oncology', 3), ('Opdivo', 'Oncology', 6), ('Ibrance', 'Oncology', 1),
        ('Humira', 'Immunology', 5), ('Dupixent', 'Immunology', 13), ('Skyrizi', 'Immunology', 5),
        ('Ozempic', 'Weight Loss', 7), ('Wegovy', 'Weight Loss', 7), ('Mounjaro', 'Weight Loss', 4),
        ('Vyvanse', 'Neurology', 2), ('Spinraza', 'Neurology', 14), ('Tecfidera', 'Neurology', 14),
        ('Stelara', 'Dermatology', 2), ('Cosentyx', 'Dermatology', 7)
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
statuses AS (
    SELECT * FROM VALUES ('Active', 0.5), ('Completed', 0.3), ('Paused', 0.15), ('Scheduled', 0.05) AS t(status, weight)
)
SELECT
    'CAMP-' || LPAD(ROW_NUMBER() OVER (ORDER BY RANDOM())::VARCHAR, 5, '0') AS campaign_id,
    d.drug_name || ' ' || ct.campaign_type || ' Q' || QUARTER(DATEADD(day, -days_ago, CURRENT_DATE())) || ' ' || YEAR(DATEADD(day, -days_ago, CURRENT_DATE())) AS campaign_name,
    d.drug_name,
    d.therapeutic_area,
    ct.campaign_type,
    sp.specialty AS target_specialty,
    CASE WHEN RANDOM() < 0.5 THEN 'Active' WHEN RANDOM() < 0.8 THEN 'Completed' WHEN RANDOM() < 0.95 THEN 'Paused' ELSE 'Scheduled' END AS status,
    DATEADD(day, -days_ago, CURRENT_DATE()) AS start_date,
    DATEADD(day, -days_ago + UNIFORM(30, 90, RANDOM()), CURRENT_DATE()) AS end_date,
    ROUND(UNIFORM(100000, 2000000, RANDOM()), -4)::NUMBER(18,2) AS budget,
    p.partner_id,
    p.partner_name,
    p.partner_tier,
    
    -- Pre-computed bid metrics
    UNIFORM(5000, 50000, RANDOM()) AS total_bids,
    ROUND(UNIFORM(2000, 40000, RANDOM())) AS winning_bids,
    ROUND(UNIFORM(35, 85, RANDOM()), 2)::NUMBER(8,2) AS win_rate_pct,
    ROUND(UNIFORM(8, 45, RANDOM()), 2)::NUMBER(12,2) AS avg_bid_cpm,
    
    -- Pre-computed impression metrics
    UNIFORM(50000, 500000, RANDOM()) AS total_impressions,
    ROUND(UNIFORM(65, 95, RANDOM()), 2)::NUMBER(8,2) AS avg_completion_rate_pct,
    ROUND(UNIFORM(70, 98, RANDOM()), 2)::NUMBER(8,2) AS avg_viewability_pct,
    
    -- Pre-computed engagement metrics
    UNIFORM(1000, 25000, RANDOM()) AS total_engagements,
    ROUND(UNIFORM(0.5, 4.5, RANDOM()), 4)::NUMBER(8,4) AS ctr_pct,
    UNIFORM(50, 2000, RANDOM()) AS total_conversions,
    ROUND(UNIFORM(2, 15, RANDOM()), 2)::NUMBER(8,2) AS conversion_rate_pct,
    
    -- Pre-computed revenue metrics
    ROUND(UNIFORM(10000, 500000, RANDOM()), 2)::NUMBER(18,2) AS total_revenue,
    ROUND(UNIFORM(0.8, 4.5, RANDOM()), 4)::NUMBER(10,4) AS roas,
    ROUND(UNIFORM(12, 65, RANDOM()), 2)::NUMBER(12,2) AS effective_cpm

FROM drugs d
JOIN partners p ON d.partner_id = p.partner_id
CROSS JOIN specialties sp
CROSS JOIN campaign_types ct
CROSS JOIN (SELECT UNIFORM(30, 365, RANDOM()) AS days_ago FROM TABLE(GENERATOR(ROWCOUNT => 2))) date_offsets
ORDER BY RANDOM()
LIMIT 100;

SELECT 'T_CAMPAIGN_PERFORMANCE created: ' || COUNT(*) || ' campaigns' AS status FROM T_CAMPAIGN_PERFORMANCE;


-- ============================================================================
-- T_INVENTORY_ANALYTICS - Pre-computed inventory metrics (200 slots)
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
)
SELECT
    'SLOT-' || LPAD(ROW_NUMBER() OVER (ORDER BY RANDOM())::VARCHAR, 5, '0') AS slot_id,
    f.facility_name || ' - ' || pl.placement_area || ' ' || st.screen_type AS slot_name,
    st.screen_type,
    st.screen_size,
    pl.placement_area,
    dp.daypart,
    ROUND(pl.base_cpm * sp.cpm_multiplier * dp.multiplier, 2)::NUMBER(12,2) AS base_cpm,
    CASE WHEN RANDOM() < 0.3 THEN TRUE ELSE FALSE END AS is_premium,
    ROUND(st.base_impressions * dp.multiplier * (0.8 + RANDOM() * 0.4)) AS estimated_daily_impressions,
    
    -- Location info
    f.facility_name,
    f.facility_type,
    f.city,
    f.state,
    f.region,
    f.patient_volume,
    ROUND(f.affluence_index, 2)::NUMBER(5,2) AS affluence_index,
    
    -- Specialty info
    sp.specialty_name,
    sp.specialty_category,
    
    -- Pre-computed performance metrics
    UNIFORM(1000, 15000, RANDOM()) AS total_bids,
    ROUND(UNIFORM(40, 90, RANDOM()), 2)::NUMBER(8,2) AS fill_rate_pct,
    UNIFORM(5000, 80000, RANDOM()) AS delivered_impressions,
    ROUND(UNIFORM(15, 55, RANDOM()), 2)::NUMBER(12,2) AS avg_winning_cpm,
    ROUND(UNIFORM(70, 98, RANDOM()), 2)::NUMBER(8,2) AS avg_completion_pct,
    ROUND(UNIFORM(75, 99, RANDOM()), 2)::NUMBER(8,2) AS avg_viewability_pct,
    UNIFORM(200, 5000, RANDOM()) AS total_engagements,
    ROUND(UNIFORM(0.3, 3.5, RANDOM()), 4)::NUMBER(8,4) AS engagement_rate_pct,
    ROUND(UNIFORM(1000, 50000, RANDOM()), 2)::NUMBER(18,2) AS total_revenue

FROM facilities f
CROSS JOIN specialties sp
CROSS JOIN screen_types st
CROSS JOIN placements pl
CROSS JOIN dayparts dp
ORDER BY RANDOM()
LIMIT 200;

SELECT 'T_INVENTORY_ANALYTICS created: ' || COUNT(*) || ' slots' AS status FROM T_INVENTORY_ANALYTICS;


-- ============================================================================
-- T_AUDIENCE_INSIGHTS - Pre-computed audience cohort metrics (100 cohorts)
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
)
SELECT
    'COH-' || LPAD(ROW_NUMBER() OVER (ORDER BY RANDOM())::VARCHAR, 5, '0') AS cohort_id,
    ag.age_bucket || ' ' || g.gender || ' - ' || hi.health_interest || ' (' || r.region || ')' AS cohort_name,
    ag.age_bucket,
    g.gender,
    CASE WHEN RANDOM() < 0.6 THEN 'Not Specified' 
         WHEN RANDOM() < 0.75 THEN 'White' 
         WHEN RANDOM() < 0.85 THEN 'Hispanic' 
         WHEN RANDOM() < 0.92 THEN 'Black' 
         ELSE 'Asian' END AS ethnicity,
    r.region,
    ib.income_bracket,
    it.insurance_type,
    hi.health_interest,
    hi.therapeutic_interests AS top_therapeutic_interests,
    
    -- Cohort size (min 50 for k-anonymity)
    UNIFORM(50, 5000, RANDOM()) AS cohort_size,
    ROUND(UNIFORM(40, 95, RANDOM()), 1) AS baseline_engagement_score,
    ROUND(UNIFORM(1.5, 6.5, RANDOM()), 1) AS avg_visit_frequency,
    
    -- Pre-computed campaign exposure
    UNIFORM(5, 25, RANDOM()) AS campaigns_exposed,
    UNIFORM(1000, 50000, RANDOM()) AS total_impressions,
    ROUND(UNIFORM(2, 8, RANDOM()), 1) AS avg_exposure_frequency,
    
    -- Pre-computed engagement metrics
    UNIFORM(100, 5000, RANDOM()) AS total_engagements,
    ROUND(UNIFORM(0.5, 4.0, RANDOM()), 3) AS engagement_rate_pct,
    UNIFORM(10, 500, RANDOM()) AS total_conversions,
    ROUND(UNIFORM(2, 18, RANDOM()), 2) AS conversion_rate_pct,
    
    -- Pre-computed behavioral metrics
    ROUND(UNIFORM(15, 120, RANDOM()), 1) AS avg_dwell_time_seconds,
    ROUND(UNIFORM(60, 95, RANDOM()), 2) AS avg_ad_completion_pct,
    
    -- Pre-computed value metrics
    ROUND(UNIFORM(500, 25000, RANDOM()), 2) AS cohort_revenue,
    ROUND(UNIFORM(0.50, 15.00, RANDOM()), 4) AS revenue_per_member

FROM age_buckets ag
CROSS JOIN genders g
CROSS JOIN regions r
CROSS JOIN income_brackets ib
CROSS JOIN insurance_types it
CROSS JOIN health_interests hi
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