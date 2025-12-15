/*
=============================================================================
PatientPoint Ad Tech Optimization Demo - Synthetic Data Generation
=============================================================================
Generates realistic dummy data for all dimension and fact tables.
Data is HIPAA-safe with no real patient identifiers.
All operations use SF_INTELLIGENCE_DEMO role.
=============================================================================
*/

USE ROLE SF_INTELLIGENCE_DEMO;
USE DATABASE AD_TECH;
USE SCHEMA ANALYTICS;
USE WAREHOUSE AD_TECH_WH;

-- ============================================================================
-- POPULATE DIM_DATE (2 years: 2023-2024)
-- ============================================================================
INSERT INTO DIM_DATE
SELECT 
    TO_NUMBER(TO_CHAR(date_val, 'YYYYMMDD')) AS date_key,
    date_val AS full_date,
    YEAR(date_val) AS year,
    QUARTER(date_val) AS quarter,
    'Q' || QUARTER(date_val)::VARCHAR AS quarter_name,
    MONTH(date_val) AS month,
    MONTHNAME(date_val) AS month_name,
    WEEKOFYEAR(date_val) AS week_of_year,
    DAYOFWEEK(date_val) AS day_of_week,
    DAYNAME(date_val) AS day_name,
    DAYOFWEEK(date_val) IN (0, 6) AS is_weekend,
    FALSE AS is_holiday,
    YEAR(date_val) AS fiscal_year,
    QUARTER(date_val) AS fiscal_quarter
FROM (
    SELECT DATEADD(day, seq4(), '2023-01-01'::DATE) AS date_val
    FROM TABLE(GENERATOR(ROWCOUNT => 730))
)
WHERE date_val <= '2024-12-31';

-- ============================================================================
-- POPULATE DIM_MEDICAL_SPECIALTIES
-- ============================================================================
INSERT INTO DIM_MEDICAL_SPECIALTIES VALUES
(1, 'Cardiology', 'Cardiovascular', 45, 'HIGH', 1.8, 'Heart and cardiovascular system specialists'),
(2, 'Endocrinology', 'Metabolic', 40, 'HIGH', 1.7, 'Diabetes, thyroid, and hormone specialists'),
(3, 'Oncology', 'Cancer Care', 60, 'MEDIUM', 2.0, 'Cancer diagnosis and treatment'),
(4, 'Primary Care', 'General', 25, 'HIGH', 1.0, 'General practitioners and family medicine'),
(5, 'Dermatology', 'Skin', 20, 'MEDIUM', 1.3, 'Skin conditions and cosmetic procedures'),
(6, 'Orthopedics', 'Musculoskeletal', 35, 'MEDIUM', 1.4, 'Bone and joint specialists'),
(7, 'Neurology', 'Nervous System', 50, 'MEDIUM', 1.6, 'Brain and nervous system disorders'),
(8, 'Pulmonology', 'Respiratory', 40, 'MEDIUM', 1.5, 'Lung and respiratory conditions'),
(9, 'Gastroenterology', 'Digestive', 35, 'MEDIUM', 1.4, 'Digestive system specialists'),
(10, 'Rheumatology', 'Autoimmune', 45, 'LOW', 1.5, 'Arthritis and autoimmune conditions'),
(11, 'Ophthalmology', 'Eye Care', 25, 'MEDIUM', 1.3, 'Eye and vision specialists'),
(12, 'Urology', 'Urinary', 30, 'MEDIUM', 1.4, 'Urinary tract and male reproductive'),
(13, 'Nephrology', 'Kidney', 45, 'LOW', 1.6, 'Kidney disease specialists'),
(14, 'Psychiatry', 'Mental Health', 50, 'MEDIUM', 1.2, 'Mental health and behavioral disorders'),
(15, 'Allergy & Immunology', 'Immune System', 30, 'MEDIUM', 1.3, 'Allergies and immune disorders'),
(16, 'Infectious Disease', 'Infections', 40, 'LOW', 1.4, 'Complex infection management'),
(17, 'Hematology', 'Blood', 45, 'LOW', 1.7, 'Blood disorders and cancers'),
(18, 'Pain Management', 'Pain', 35, 'MEDIUM', 1.3, 'Chronic pain treatment'),
(19, 'Sports Medicine', 'Athletic', 30, 'LOW', 1.2, 'Athletic injuries and performance'),
(20, 'Geriatrics', 'Senior Care', 40, 'MEDIUM', 1.4, 'Elderly patient care'),
(21, 'Pediatrics', 'Child Care', 25, 'HIGH', 1.1, 'Children and adolescent medicine'),
(22, 'OB/GYN', 'Women Health', 35, 'HIGH', 1.3, 'Obstetrics and gynecology'),
(23, 'Podiatry', 'Foot Care', 25, 'LOW', 1.1, 'Foot and ankle specialists'),
(24, 'Physical Therapy', 'Rehabilitation', 45, 'MEDIUM', 1.0, 'Physical rehabilitation'),
(25, 'Urgent Care', 'Emergency', 20, 'HIGH', 1.2, 'Walk-in urgent medical care');

-- ============================================================================
-- POPULATE DIM_LOCATIONS (500 facilities across US)
-- ============================================================================
INSERT INTO DIM_LOCATIONS
WITH regions AS (
    SELECT * FROM VALUES
        ('Northeast', ARRAY_CONSTRUCT('New York', 'Boston', 'Philadelphia', 'Pittsburgh', 'Newark', 'Hartford', 'Providence', 'Buffalo')),
        ('Southeast', ARRAY_CONSTRUCT('Miami', 'Atlanta', 'Charlotte', 'Orlando', 'Tampa', 'Jacksonville', 'Raleigh', 'Nashville')),
        ('Midwest', ARRAY_CONSTRUCT('Chicago', 'Detroit', 'Minneapolis', 'Cleveland', 'Columbus', 'Indianapolis', 'Milwaukee', 'Kansas City')),
        ('Southwest', ARRAY_CONSTRUCT('Houston', 'Dallas', 'Phoenix', 'San Antonio', 'Austin', 'Denver', 'Las Vegas', 'Albuquerque')),
        ('West', ARRAY_CONSTRUCT('Los Angeles', 'San Francisco', 'Seattle', 'San Diego', 'Portland', 'Sacramento', 'San Jose', 'Honolulu'))
    AS t(region, cities)
),
states AS (
    SELECT * FROM VALUES
        ('New York', 'NY', 'Northeast'), ('Boston', 'MA', 'Northeast'), ('Philadelphia', 'PA', 'Northeast'),
        ('Pittsburgh', 'PA', 'Northeast'), ('Newark', 'NJ', 'Northeast'), ('Hartford', 'CT', 'Northeast'),
        ('Providence', 'RI', 'Northeast'), ('Buffalo', 'NY', 'Northeast'),
        ('Miami', 'FL', 'Southeast'), ('Atlanta', 'GA', 'Southeast'), ('Charlotte', 'NC', 'Southeast'),
        ('Orlando', 'FL', 'Southeast'), ('Tampa', 'FL', 'Southeast'), ('Jacksonville', 'FL', 'Southeast'),
        ('Raleigh', 'NC', 'Southeast'), ('Nashville', 'TN', 'Southeast'),
        ('Chicago', 'IL', 'Midwest'), ('Detroit', 'MI', 'Midwest'), ('Minneapolis', 'MN', 'Midwest'),
        ('Cleveland', 'OH', 'Midwest'), ('Columbus', 'OH', 'Midwest'), ('Indianapolis', 'IN', 'Midwest'),
        ('Milwaukee', 'WI', 'Midwest'), ('Kansas City', 'MO', 'Midwest'),
        ('Houston', 'TX', 'Southwest'), ('Dallas', 'TX', 'Southwest'), ('Phoenix', 'AZ', 'Southwest'),
        ('San Antonio', 'TX', 'Southwest'), ('Austin', 'TX', 'Southwest'), ('Denver', 'CO', 'Southwest'),
        ('Las Vegas', 'NV', 'Southwest'), ('Albuquerque', 'NM', 'Southwest'),
        ('Los Angeles', 'CA', 'West'), ('San Francisco', 'CA', 'West'), ('Seattle', 'WA', 'West'),
        ('San Diego', 'CA', 'West'), ('Portland', 'OR', 'West'), ('Sacramento', 'CA', 'West'),
        ('San Jose', 'CA', 'West'), ('Honolulu', 'HI', 'West')
    AS t(city, state_code, region)
),
facility_types AS (
    SELECT * FROM VALUES
        ('Hospital', 15000),
        ('Medical Center', 8000),
        ('Specialty Clinic', 3000),
        ('Outpatient Center', 4000),
        ('Urgent Care', 2500)
    AS t(facility_type, base_volume)
),
generated AS (
    SELECT 
        ROW_NUMBER() OVER (ORDER BY RANDOM()) AS location_id,
        s.city,
        s.state_code,
        s.region,
        f.facility_type,
        f.base_volume,
        UNIFORM(1, 999, RANDOM()) AS facility_num,
        UNIFORM(5.0, 10.0, RANDOM())::FLOAT AS affluence
    FROM states s
    CROSS JOIN facility_types f
    CROSS JOIN TABLE(GENERATOR(ROWCOUNT => 3))
    ORDER BY RANDOM()
    LIMIT 500
)
SELECT
    location_id,
    CASE facility_type
        WHEN 'Hospital' THEN city || ' ' || ARRAY_CONSTRUCT('General', 'Regional', 'Community', 'Memorial', 'University')[UNIFORM(0, 4, RANDOM())] || ' Hospital'
        WHEN 'Medical Center' THEN city || ' ' || ARRAY_CONSTRUCT('Health', 'Medical', 'Care', 'Wellness')[UNIFORM(0, 3, RANDOM())] || ' Center'
        WHEN 'Specialty Clinic' THEN ARRAY_CONSTRUCT('Premier', 'Advanced', 'Elite', 'Complete')[UNIFORM(0, 3, RANDOM())] || ' ' || city || ' Clinic'
        WHEN 'Outpatient Center' THEN city || ' Outpatient ' || ARRAY_CONSTRUCT('Services', 'Care', 'Center')[UNIFORM(0, 2, RANDOM())]
        ELSE city || ' Urgent Care #' || facility_num::VARCHAR
    END AS facility_name,
    facility_type,
    facility_num || ' ' || ARRAY_CONSTRUCT('Main', 'Oak', 'Maple', 'Medical', 'Health')[UNIFORM(0, 4, RANDOM())] || ' Street' AS address,
    city,
    state_code AS state,
    LPAD(UNIFORM(10000, 99999, RANDOM())::VARCHAR, 5, '0') AS zip_code,
    region,
    LPAD(UNIFORM(500, 850, RANDOM())::VARCHAR, 3, '0') AS dma_code,
    city || ' DMA' AS dma_name,
    UNIFORM(25.0, 48.0, RANDOM())::FLOAT AS latitude,
    UNIFORM(-125.0, -70.0, RANDOM())::FLOAT AS longitude,
    (base_volume * UNIFORM(0.7, 1.3, RANDOM()))::INTEGER AS patient_volume,
    ROUND(affluence, 1) AS affluence_index
FROM generated;

-- ============================================================================
-- POPULATE DIM_INVENTORY (5000 ad slots)
-- ============================================================================
INSERT INTO DIM_INVENTORY
WITH slot_configs AS (
    SELECT * FROM VALUES
        ('Digital Display', '55"', 'Waiting Room', 15, 150, 12.50, TRUE),
        ('Digital Display', '65"', 'Waiting Room', 30, 200, 18.00, TRUE),
        ('Digital Display', '32"', 'Hallway', 15, 80, 8.00, FALSE),
        ('Tablet', '10"', 'Check-in', 10, 50, 6.00, FALSE),
        ('Check-in Kiosk', '21"', 'Check-in', 20, 120, 10.00, FALSE),
        ('Waiting Room TV', '55"', 'Waiting Room', 30, 180, 15.00, TRUE),
        ('Exam Room Display', '32"', 'Exam Room', 15, 40, 22.00, TRUE),
        ('Interactive Panel', '43"', 'Waiting Room', 30, 100, 20.00, TRUE)
    AS t(screen_type, screen_size, placement_area, duration_seconds, daily_impressions, base_cpm, is_premium)
),
dayparts AS (
    SELECT * FROM VALUES ('Morning'), ('Afternoon'), ('Evening'), ('All Day') AS t(daypart)
)
SELECT
    'SLOT-' || LPAD(ROW_NUMBER() OVER (ORDER BY RANDOM())::VARCHAR, 6, '0') AS slot_id,
    l.facility_name || ' - ' || sc.placement_area || ' ' || sc.screen_type AS slot_name,
    l.location_id,
    UNIFORM(1, 25, RANDOM()) AS specialty_id,
    sc.screen_type,
    sc.screen_size,
    sc.placement_area,
    d.daypart,
    sc.duration_seconds,
    (sc.daily_impressions * UNIFORM(0.8, 1.2, RANDOM()))::INTEGER AS daily_impressions,
    ROUND(sc.base_cpm * s.base_cpm_multiplier * UNIFORM(0.9, 1.1, RANDOM()), 2) AS base_cpm,
    sc.is_premium,
    TRUE AS is_active,
    DATEADD(day, -UNIFORM(30, 365, RANDOM()), CURRENT_DATE()) AS created_date
FROM DIM_LOCATIONS l
CROSS JOIN slot_configs sc
CROSS JOIN dayparts d
JOIN DIM_MEDICAL_SPECIALTIES s ON s.specialty_id = UNIFORM(1, 25, RANDOM())
ORDER BY RANDOM()
LIMIT 5000;

-- ============================================================================
-- POPULATE DIM_PHARMA_PARTNERS (20 partners)
-- ============================================================================
INSERT INTO DIM_PHARMA_PARTNERS VALUES
(1, 'Pfizer Inc.', 'Platinum', 'Big Pharma', 'John Smith', '2023-01-01', '2025-12-31', 50000000, TRUE),
(2, 'Johnson & Johnson', 'Platinum', 'Big Pharma', 'Sarah Johnson', '2023-01-01', '2025-12-31', 45000000, TRUE),
(3, 'Merck & Co.', 'Platinum', 'Big Pharma', 'Michael Brown', '2023-01-01', '2025-12-31', 42000000, TRUE),
(4, 'AbbVie Inc.', 'Gold', 'Big Pharma', 'Emily Davis', '2023-03-01', '2025-12-31', 35000000, TRUE),
(5, 'Bristol-Myers Squibb', 'Gold', 'Big Pharma', 'David Wilson', '2023-02-01', '2025-12-31', 32000000, TRUE),
(6, 'Eli Lilly', 'Platinum', 'Big Pharma', 'Jennifer Martinez', '2023-01-01', '2025-12-31', 48000000, TRUE),
(7, 'Novartis', 'Gold', 'Big Pharma', 'Robert Taylor', '2023-04-01', '2025-12-31', 30000000, TRUE),
(8, 'AstraZeneca', 'Gold', 'Big Pharma', 'Lisa Anderson', '2023-03-01', '2025-12-31', 28000000, TRUE),
(9, 'Sanofi', 'Gold', 'Big Pharma', 'James Thomas', '2023-02-01', '2025-12-31', 26000000, TRUE),
(10, 'GlaxoSmithKline', 'Silver', 'Big Pharma', 'Michelle Jackson', '2023-05-01', '2025-12-31', 20000000, TRUE),
(11, 'Amgen', 'Silver', 'Biotech', 'Christopher White', '2023-06-01', '2025-12-31', 18000000, TRUE),
(12, 'Gilead Sciences', 'Silver', 'Biotech', 'Amanda Harris', '2023-04-01', '2025-12-31', 16000000, TRUE),
(13, 'Biogen', 'Silver', 'Biotech', 'Daniel Martin', '2023-05-01', '2025-12-31', 15000000, TRUE),
(14, 'Regeneron', 'Bronze', 'Biotech', 'Jessica Garcia', '2023-07-01', '2025-12-31', 12000000, TRUE),
(15, 'Vertex Pharmaceuticals', 'Bronze', 'Biotech', 'Matthew Robinson', '2023-06-01', '2025-12-31', 10000000, TRUE),
(16, 'Moderna', 'Silver', 'Biotech', 'Ashley Clark', '2023-03-01', '2025-12-31', 22000000, TRUE),
(17, 'BioMarin', 'Bronze', 'Biotech', 'Joshua Lewis', '2023-08-01', '2025-12-31', 8000000, TRUE),
(18, 'Medtronic', 'Gold', 'Medical Device', 'Stephanie Lee', '2023-02-01', '2025-12-31', 25000000, TRUE),
(19, 'Abbott Laboratories', 'Silver', 'Medical Device', 'Andrew Walker', '2023-04-01', '2025-12-31', 18000000, TRUE),
(20, 'Boston Scientific', 'Bronze', 'Medical Device', 'Nicole Hall', '2023-07-01', '2025-12-31', 9000000, TRUE);

-- ============================================================================
-- POPULATE DIM_CAMPAIGNS (100 campaigns)
-- ============================================================================
INSERT INTO DIM_CAMPAIGNS
WITH drug_campaigns AS (
    SELECT * FROM VALUES
        -- Diabetes drugs
        ('Jardiance', 'Diabetes', 6, 2),
        ('Ozempic', 'Diabetes', 6, 6),
        ('Trulicity', 'Diabetes', 6, 6),
        ('Mounjaro', 'Diabetes', 6, 6),
        ('Farxiga', 'Diabetes', 5, 2),
        -- Cardiology drugs
        ('Entresto', 'Cardiology', 5, 1),
        ('Eliquis', 'Cardiology', 5, 1),
        ('Xarelto', 'Cardiology', 1, 2),
        ('Jardiance CV', 'Cardiology', 6, 2),
        ('Repatha', 'Cardiology', 11, 2),
        -- Oncology drugs
        ('Keytruda', 'Oncology', 3, 3),
        ('Opdivo', 'Oncology', 5, 3),
        ('Ibrance', 'Oncology', 1, 3),
        ('Tagrisso', 'Oncology', 8, 3),
        -- Immunology drugs
        ('Humira', 'Immunology', 4, 10),
        ('Skyrizi', 'Immunology', 4, 4),
        ('Rinvoq', 'Immunology', 4, 4),
        ('Dupixent', 'Immunology', 9, 14),
        -- Neurology drugs
        ('Vyvanse', 'Neurology', 7, 14),
        ('Aimovig', 'Neurology', 11, 7),
        ('Nurtec', 'Neurology', 1, 7),
        -- Respiratory drugs
        ('Trelegy', 'Respiratory', 10, 8),
        ('Fasenra', 'Respiratory', 8, 15),
        ('Nucala', 'Respiratory', 10, 8)
    AS t(drug_name, therapeutic_area, partner_id, specialty_id)
)
SELECT
    'CAMP-' || LPAD(ROW_NUMBER() OVER (ORDER BY RANDOM())::VARCHAR, 5, '0') AS campaign_id,
    dc.drug_name || ' ' || ARRAY_CONSTRUCT('Awareness', 'Education', 'HCP Engagement', 'Patient Support', 'Launch')[UNIFORM(0, 4, RANDOM())] || ' ' || year_val::VARCHAR AS campaign_name,
    dc.partner_id,
    dc.drug_name,
    dc.therapeutic_area,
    ARRAY_CONSTRUCT('Awareness', 'Education', 'Direct Response')[UNIFORM(0, 2, RANDOM())] AS campaign_type,
    s.specialty_name AS target_specialty,
    DATEADD(day, UNIFORM(0, 300, RANDOM()), (year_val || '-01-01')::DATE) AS start_date,
    DATEADD(day, UNIFORM(30, 120, RANDOM()), DATEADD(day, UNIFORM(0, 300, RANDOM()), (year_val || '-01-01')::DATE)) AS end_date,
    ROUND(UNIFORM(100000, 5000000, RANDOM()), -3) AS budget,
    ROUND(UNIFORM(1000, 50000, RANDOM()), -2) AS daily_budget_cap,
    UNIFORM(100000, 10000000, RANDOM()) AS target_impressions,
    ROUND(UNIFORM(0.005, 0.025, RANDOM()), 4) AS target_ctr,
    CASE 
        WHEN RANDOM() < 0.6 THEN 'Active'
        WHEN RANDOM() < 0.8 THEN 'Completed'
        WHEN RANDOM() < 0.95 THEN 'Paused'
        ELSE 'Scheduled'
    END AS status,
    CURRENT_TIMESTAMP() AS created_date
FROM drug_campaigns dc
JOIN DIM_MEDICAL_SPECIALTIES s ON s.specialty_id = dc.specialty_id
CROSS JOIN (SELECT 2023 AS year_val UNION ALL SELECT 2024) years
ORDER BY RANDOM()
LIMIT 100;

-- ============================================================================
-- POPULATE DIM_AUDIENCE_COHORTS (200 privacy-safe cohorts)
-- ============================================================================
INSERT INTO DIM_AUDIENCE_COHORTS
WITH age_buckets AS (
    SELECT * FROM VALUES ('18-24'), ('25-34'), ('35-44'), ('45-54'), ('55-64'), ('65+') AS t(age_bucket)
),
genders AS (
    SELECT * FROM VALUES ('Male'), ('Female'), ('All') AS t(gender)
),
regions AS (
    SELECT * FROM VALUES ('Northeast'), ('Southeast'), ('Midwest'), ('Southwest'), ('West') AS t(region)
),
health_interests AS (
    SELECT * FROM VALUES 
        ('Diabetes Management'), ('Heart Health'), ('Cancer Care'), ('Mental Wellness'),
        ('Pain Management'), ('Weight Management'), ('Respiratory Health'), ('Bone Health')
    AS t(health_interest)
)
SELECT
    'COHORT-' || LPAD(ROW_NUMBER() OVER (ORDER BY RANDOM())::VARCHAR, 5, '0') AS cohort_id,
    a.age_bucket || ' ' || g.gender || ' - ' || r.region || ' - ' || h.health_interest AS cohort_name,
    a.age_bucket,
    g.gender,
    ARRAY_CONSTRUCT('Caucasian', 'African American', 'Hispanic', 'Asian', 'Other', 'All')[UNIFORM(0, 5, RANDOM())] AS ethnicity,
    r.region,
    ARRAY_CONSTRUCT('Low', 'Medium', 'High', 'Very High')[UNIFORM(0, 3, RANDOM())] AS income_bracket,
    ARRAY_CONSTRUCT('Commercial', 'Medicare', 'Medicaid', 'Mixed')[UNIFORM(0, 3, RANDOM())] AS insurance_type,
    h.health_interest,
    GREATEST(50, UNIFORM(50, 50000, RANDOM())) AS cohort_size,  -- Enforce k-anonymity minimum
    ROUND(UNIFORM(30.0, 95.0, RANDOM()), 2) AS avg_engagement_score,
    ROUND(UNIFORM(0.5, 4.0, RANDOM()), 2) AS avg_visit_frequency,
    CASE h.health_interest
        WHEN 'Diabetes Management' THEN 'Diabetes, Endocrinology, Nutrition'
        WHEN 'Heart Health' THEN 'Cardiology, Hypertension, Cholesterol'
        WHEN 'Cancer Care' THEN 'Oncology, Immunotherapy, Clinical Trials'
        WHEN 'Mental Wellness' THEN 'Psychiatry, Anxiety, Depression'
        WHEN 'Pain Management' THEN 'Chronic Pain, Arthritis, Opioid Alternatives'
        WHEN 'Weight Management' THEN 'Obesity, Nutrition, GLP-1'
        WHEN 'Respiratory Health' THEN 'Asthma, COPD, Pulmonology'
        ELSE 'Osteoporosis, Orthopedics, Calcium'
    END AS top_therapeutic_interests,
    CURRENT_DATE() AS created_date,
    CURRENT_TIMESTAMP() AS last_updated
FROM age_buckets a
CROSS JOIN genders g
CROSS JOIN regions r
CROSS JOIN health_interests h
ORDER BY RANDOM()
LIMIT 200;

-- ============================================================================
-- POPULATE DIM_CREATIVE_ASSETS
-- ============================================================================
INSERT INTO DIM_CREATIVE_ASSETS
SELECT
    'CRTV-' || LPAD(ROW_NUMBER() OVER (ORDER BY c.campaign_id)::VARCHAR, 5, '0') AS creative_id,
    c.campaign_id,
    c.drug_name || ' - ' || ARRAY_CONSTRUCT('Main', 'Variant A', 'Variant B', 'Spanish', 'Elderly Focus')[v.variant_num] AS creative_name,
    ARRAY_CONSTRUCT('Video', 'Static Image', 'Interactive', 'Animation')[UNIFORM(0, 3, RANDOM())] AS creative_type,
    ARRAY_CONSTRUCT(15, 30, 45, 60)[UNIFORM(0, 3, RANDOM())] AS duration_seconds,
    ARRAY_CONSTRUCT('MP4', 'PNG', 'HTML5', 'GIF')[UNIFORM(0, 3, RANDOM())] AS file_format,
    ARRAY_CONSTRUCT('1920x1080', '1080x1920', '1280x720', '3840x2160')[UNIFORM(0, 3, RANDOM())] AS resolution,
    RANDOM() > 0.3 AS has_audio,
    ARRAY_CONSTRUCT('QR Code', 'URL', 'Phone', 'None')[UNIFORM(0, 3, RANDOM())] AS cta_type,
    'Approved' AS approval_status,
    c.start_date AS created_date
FROM DIM_CAMPAIGNS c
CROSS JOIN (SELECT 0 AS variant_num UNION ALL SELECT 1 UNION ALL SELECT 2) v
ORDER BY RANDOM()
LIMIT 300;

SELECT 'Dimension table data generated successfully!' AS status;

-- ============================================================================
-- POPULATE FACT_BIDS (500,000 bid events)
-- Uses pre-computed arrays for efficient random assignment
-- ============================================================================

-- Create temp tables with indexed row numbers for efficient joins
CREATE OR REPLACE TEMPORARY TABLE TMP_INVENTORY_INDEXED AS
SELECT slot_id, base_cpm, daypart, ROW_NUMBER() OVER (ORDER BY slot_id) - 1 AS idx
FROM DIM_INVENTORY;

CREATE OR REPLACE TEMPORARY TABLE TMP_CAMPAIGNS_INDEXED AS
SELECT campaign_id, partner_id, ROW_NUMBER() OVER (ORDER BY campaign_id) - 1 AS idx
FROM DIM_CAMPAIGNS;

CREATE OR REPLACE TEMPORARY TABLE TMP_COHORTS_INDEXED AS
SELECT cohort_id, ROW_NUMBER() OVER (ORDER BY cohort_id) - 1 AS idx
FROM DIM_AUDIENCE_COHORTS;

-- Now insert with efficient modulo joins on pre-computed indexes
INSERT INTO FACT_BIDS
SELECT
    'BID-' || LPAD(g.seq::VARCHAR, 8, '0') AS bid_id,
    DATEADD(
        minute, 
        -UNIFORM(0, 525600, RANDOM()),  -- Random minute in last year
        CURRENT_TIMESTAMP()
    ) AS bid_timestamp,
    TO_NUMBER(TO_CHAR(DATEADD(day, -UNIFORM(0, 365, RANDOM()), CURRENT_DATE()), 'YYYYMMDD')) AS date_key,
    i.slot_id,
    c.campaign_id,
    c.partner_id,
    a.cohort_id,
    -- Bid amount based on base CPM with variance
    ROUND(i.base_cpm * UNIFORM(0.8, 1.5, RANDOM()), 2) AS bid_amount,
    ROUND(i.base_cpm * 0.7, 2) AS floor_price,
    ROUND(i.base_cpm * UNIFORM(0.6, 1.3, RANDOM()), 2) AS competitor_bid,
    RANDOM() > 0.35 AS win_flag,  -- ~65% win rate
    UNIFORM(20, 200, RANDOM()) AS latency_ms,
    ARRAY_CONSTRUCT('Algorithm_v3', 'Algorithm_v4', 'ML_Model_v2', 'Rule_Based')[UNIFORM(0, 3, RANDOM())] AS bid_source,
    i.daypart,
    ARRAY_CONSTRUCT('Desktop Display', 'Tablet', 'Digital Signage', 'Kiosk')[UNIFORM(0, 3, RANDOM())] AS device_type,
    CURRENT_TIMESTAMP() AS created_at
FROM (SELECT SEQ4() AS seq FROM TABLE(GENERATOR(ROWCOUNT => 500000))) g
JOIN TMP_INVENTORY_INDEXED i ON MOD(g.seq + UNIFORM(0, 4999, RANDOM())::INT, 5000) = i.idx
JOIN TMP_CAMPAIGNS_INDEXED c ON MOD(g.seq + UNIFORM(0, 99, RANDOM())::INT, 100) = c.idx
JOIN TMP_COHORTS_INDEXED a ON MOD(g.seq + UNIFORM(0, 199, RANDOM())::INT, 200) = a.idx;

-- Clean up temp tables
DROP TABLE IF EXISTS TMP_INVENTORY_INDEXED;
DROP TABLE IF EXISTS TMP_CAMPAIGNS_INDEXED;
DROP TABLE IF EXISTS TMP_COHORTS_INDEXED;

SELECT 'Fact bids generated: ' || COUNT(*)::VARCHAR FROM FACT_BIDS;

-- ============================================================================
-- POPULATE FACT_IMPRESSIONS (1,000,000 impressions from winning bids)
-- ============================================================================

-- Pre-compute one creative per campaign for efficient join
CREATE OR REPLACE TEMPORARY TABLE TMP_CAMPAIGN_CREATIVE AS
SELECT DISTINCT campaign_id, FIRST_VALUE(creative_id) OVER (PARTITION BY campaign_id ORDER BY creative_id) AS creative_id
FROM DIM_CREATIVE_ASSETS;

INSERT INTO FACT_IMPRESSIONS
SELECT
    'IMP-' || LPAD(ROW_NUMBER() OVER (ORDER BY b.bid_timestamp)::VARCHAR, 8, '0') AS impression_id,
    DATEADD(second, UNIFORM(1, 60, RANDOM()), b.bid_timestamp) AS impression_timestamp,
    b.date_key,
    b.slot_id,
    b.campaign_id,
    b.partner_id,
    cr.creative_id,
    b.cohort_id,
    b.bid_id,
    UNIFORM(5, 30, RANDOM()) AS duration_viewed,
    ROUND(UNIFORM(0.4, 1.0, RANDOM()), 3) AS completion_rate,
    ROUND(UNIFORM(0.6, 1.0, RANDOM()), 3) AS viewability_score,
    b.daypart,
    RANDOM() > 0.7 AS is_first_exposure,
    UNIFORM(1, 10, RANDOM()) AS exposure_count,
    b.bid_amount AS actual_cpm,
    ROUND(b.bid_amount / 1000, 4) AS revenue,
    CURRENT_TIMESTAMP() AS created_at
FROM FACT_BIDS b
LEFT JOIN TMP_CAMPAIGN_CREATIVE cr ON b.campaign_id = cr.campaign_id
WHERE b.win_flag = TRUE
LIMIT 1000000;

DROP TABLE IF EXISTS TMP_CAMPAIGN_CREATIVE;

SELECT 'Fact impressions generated: ' || COUNT(*)::VARCHAR FROM FACT_IMPRESSIONS;

-- ============================================================================
-- POPULATE FACT_ENGAGEMENTS (100,000 engagement events)
-- ============================================================================
INSERT INTO FACT_ENGAGEMENTS
SELECT
    'ENG-' || LPAD(ROW_NUMBER() OVER (ORDER BY i.impression_timestamp)::VARCHAR, 7, '0') AS engagement_id,
    DATEADD(second, UNIFORM(5, 120, RANDOM()), i.impression_timestamp) AS engagement_timestamp,
    i.date_key,
    i.impression_id,
    i.slot_id,
    i.campaign_id,
    i.partner_id,
    i.cohort_id,
    ARRAY_CONSTRUCT('QR Scan', 'Touch Interaction', 'Extended Dwell', 'Information Request')[UNIFORM(0, 3, RANDOM())] AS engagement_type,
    UNIFORM(10, 180, RANDOM()) AS dwell_time_seconds,
    CASE UNIFORM(0, 4, RANDOM())
        WHEN 0 THEN 'Scanned QR Code'
        WHEN 1 THEN 'Touched Screen for More Info'
        WHEN 2 THEN 'Watched Full Video'
        WHEN 3 THEN 'Requested Doctor Discussion'
        ELSE 'Saved Information'
    END AS action_taken,
    RANDOM() > 0.85 AS conversion_flag,  -- ~15% conversion rate
    CASE WHEN RANDOM() > 0.85 THEN 
        ARRAY_CONSTRUCT('Website Visit', 'Coupon Download', 'Doctor Discussion', 'Prescription Fill')[UNIFORM(0, 3, RANDOM())]
    ELSE NULL END AS conversion_type,
    ROUND(UNIFORM(0.1, 1.0, RANDOM()), 3) AS attribution_weight,
    RANDOM() > 0.7 AS is_last_touch,
    CURRENT_TIMESTAMP() AS created_at
FROM FACT_IMPRESSIONS i
WHERE RANDOM() > 0.9  -- ~10% of impressions generate engagement
LIMIT 100000;

SELECT 'Fact engagements generated: ' || COUNT(*)::VARCHAR FROM FACT_ENGAGEMENTS;

-- ============================================================================
-- POPULATE FACT_APPOINTMENTS (aggregated appointment context)
-- ============================================================================

-- Create temp tables for efficient joins
CREATE OR REPLACE TEMPORARY TABLE TMP_LOCATIONS_INDEXED AS
SELECT location_id, ROW_NUMBER() OVER (ORDER BY location_id) - 1 AS idx
FROM DIM_LOCATIONS;

CREATE OR REPLACE TEMPORARY TABLE TMP_COHORTS_INDEXED AS
SELECT cohort_id, ROW_NUMBER() OVER (ORDER BY cohort_id) - 1 AS idx
FROM DIM_AUDIENCE_COHORTS;

INSERT INTO FACT_APPOINTMENTS
SELECT
    'APPT-' || LPAD(g.seq::VARCHAR, 8, '0') AS appointment_id,
    DATEADD(day, -UNIFORM(0, 365, RANDOM()), CURRENT_DATE()) AS appointment_date,
    TO_NUMBER(TO_CHAR(DATEADD(day, -UNIFORM(0, 365, RANDOM()), CURRENT_DATE()), 'YYYYMMDD')) AS date_key,
    l.location_id,
    UNIFORM(1, 25, RANDOM()) AS specialty_id,
    a.cohort_id,
    UNIFORM(7, 19, RANDOM()) AS hour_of_day,
    CASE 
        WHEN UNIFORM(7, 19, RANDOM()) < 12 THEN 'Morning'
        WHEN UNIFORM(7, 19, RANDOM()) < 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS daypart,
    UNIFORM(0, 6, RANDOM()) AS day_of_week,
    UNIFORM(15, 60, RANDOM()) AS scheduled_duration,
    UNIFORM(5, 45, RANDOM()) AS actual_wait_time,
    UNIFORM(1, 50, RANDOM()) AS appointment_count,  -- Aggregated count
    CURRENT_TIMESTAMP() AS created_at
FROM (SELECT SEQ4() AS seq FROM TABLE(GENERATOR(ROWCOUNT => 200000))) g
JOIN TMP_LOCATIONS_INDEXED l ON MOD(g.seq + UNIFORM(0, 499, RANDOM())::INT, 500) = l.idx
JOIN TMP_COHORTS_INDEXED a ON MOD(g.seq + UNIFORM(0, 199, RANDOM())::INT, 200) = a.idx;

-- Clean up temp tables
DROP TABLE IF EXISTS TMP_LOCATIONS_INDEXED;
DROP TABLE IF EXISTS TMP_COHORTS_INDEXED;

SELECT 'Fact appointments generated: ' || COUNT(*)::VARCHAR FROM FACT_APPOINTMENTS;

-- ============================================================================
-- Final Summary
-- ============================================================================
SELECT 'SYNTHETIC DATA GENERATION COMPLETE' AS status;

SELECT 'DIM_DATE' AS table_name, COUNT(*) AS row_count FROM DIM_DATE
UNION ALL SELECT 'DIM_MEDICAL_SPECIALTIES', COUNT(*) FROM DIM_MEDICAL_SPECIALTIES
UNION ALL SELECT 'DIM_LOCATIONS', COUNT(*) FROM DIM_LOCATIONS
UNION ALL SELECT 'DIM_INVENTORY', COUNT(*) FROM DIM_INVENTORY
UNION ALL SELECT 'DIM_PHARMA_PARTNERS', COUNT(*) FROM DIM_PHARMA_PARTNERS
UNION ALL SELECT 'DIM_CAMPAIGNS', COUNT(*) FROM DIM_CAMPAIGNS
UNION ALL SELECT 'DIM_AUDIENCE_COHORTS', COUNT(*) FROM DIM_AUDIENCE_COHORTS
UNION ALL SELECT 'DIM_CREATIVE_ASSETS', COUNT(*) FROM DIM_CREATIVE_ASSETS
UNION ALL SELECT 'FACT_BIDS', COUNT(*) FROM FACT_BIDS
UNION ALL SELECT 'FACT_IMPRESSIONS', COUNT(*) FROM FACT_IMPRESSIONS
UNION ALL SELECT 'FACT_ENGAGEMENTS', COUNT(*) FROM FACT_ENGAGEMENTS
UNION ALL SELECT 'FACT_APPOINTMENTS', COUNT(*) FROM FACT_APPOINTMENTS
ORDER BY table_name;

