/*
=============================================================================
PatientPoint Ad Tech Demo - CURATED PRE-COMPUTED DATA
=============================================================================
This script creates FLAT tables with EXPLICIT, CURATED values.
NO GENERATORS - all values are hardcoded and mathematically consistent.

Tables created:
1. T_CAMPAIGN_PERFORMANCE - 25 campaigns with realistic KPIs
2. T_INVENTORY_ANALYTICS - 30 inventory slots with metrics  
3. T_AUDIENCE_INSIGHTS - 20 audience cohorts with engagement data

All metrics are pre-calculated and verified:
- ROAS = Revenue / Spend
- CTR = Clicks / Impressions × 100
- Conversion Rate = Conversions / Engagements × 100
- Revenue = Impressions × CPM / 1000 (for inventory)

Run time: ~10 seconds
=============================================================================
*/

USE ROLE SF_INTELLIGENCE_DEMO;
USE DATABASE AD_TECH;
USE SCHEMA ANALYTICS;
USE WAREHOUSE AD_TECH_WH;

-- ============================================================================
-- T_CAMPAIGN_PERFORMANCE - 25 curated campaigns
-- Each row tells a story with consistent metrics
-- ============================================================================
CREATE OR REPLACE TABLE T_CAMPAIGN_PERFORMANCE (
    campaign_id VARCHAR(20),
    campaign_name VARCHAR(100),
    drug_name VARCHAR(50),
    therapeutic_area VARCHAR(50),
    campaign_type VARCHAR(30),
    target_specialty VARCHAR(50),
    status VARCHAR(20),
    start_date DATE,
    end_date DATE,
    budget NUMBER(18,2),
    partner_id INT,
    partner_name VARCHAR(100),
    partner_tier VARCHAR(20),
    total_bids INT,
    winning_bids INT,
    win_rate_pct NUMBER(8,2),
    avg_bid_cpm NUMBER(12,2),
    total_impressions INT,
    avg_completion_rate_pct NUMBER(8,2),
    avg_viewability_pct NUMBER(8,2),
    total_engagements INT,
    ctr_pct NUMBER(8,4),
    total_conversions INT,
    conversion_rate_pct NUMBER(8,2),
    total_revenue NUMBER(18,2),
    total_spend NUMBER(18,2),
    roas NUMBER(10,4),
    effective_cpm NUMBER(12,2)
);

INSERT INTO T_CAMPAIGN_PERFORMANCE VALUES
-- ═══════════════════════════════════════════════════════════════════════════
-- TOP PERFORMERS (ROAS 4.5-5.5) - These are the success stories
-- ═══════════════════════════════════════════════════════════════════════════
-- Ozempic: Blockbuster GLP-1, huge budget, excellent ROAS
('CAMP-00001', 'Ozempic Direct Response Q3 2025', 'Ozempic', 'Diabetes', 'Direct Response', 'Endocrinology', 'Completed', DATEADD(day, -120, CURRENT_DATE), DATEADD(day, -30, CURRENT_DATE), 1500000.00, 7, 'Novo Nordisk', 'Platinum', 45000, 38250, 85.00, 32.50, 425000, 92.00, 95.00, 14875, 3.50, 1785, 12.00, 5737500.00, 1125000.00, 5.10, 26.47),

-- Wegovy: Weight loss darling, premium targeting
('CAMP-00002', 'Wegovy Awareness Q3 2025', 'Wegovy', 'Weight Loss', 'Awareness', 'Primary Care', 'Completed', DATEADD(day, -150, CURRENT_DATE), DATEADD(day, -60, CURRENT_DATE), 1200000.00, 7, 'Novo Nordisk', 'Platinum', 38000, 30400, 80.00, 28.00, 380000, 88.00, 92.00, 11400, 3.00, 1254, 11.00, 4560000.00, 912000.00, 5.00, 24.00),

-- Mounjaro: Eli Lilly's competitor, strong performance
('CAMP-00003', 'Mounjaro Education Q2 2025', 'Mounjaro', 'Weight Loss', 'Education', 'Endocrinology', 'Completed', DATEADD(day, -200, CURRENT_DATE), DATEADD(day, -110, CURRENT_DATE), 1100000.00, 4, 'Eli Lilly', 'Platinum', 35000, 28000, 80.00, 30.00, 350000, 90.00, 94.00, 12250, 3.50, 1348, 11.00, 4235000.00, 847000.00, 5.00, 24.20),

-- Keytruda: Oncology leader, high-value conversions
('CAMP-00004', 'Keytruda Direct Response Q3 2025', 'Keytruda', 'Oncology', 'Direct Response', 'Oncology', 'Active', DATEADD(day, -60, CURRENT_DATE), DATEADD(day, 30, CURRENT_DATE), 2000000.00, 3, 'Merck & Co.', 'Platinum', 52000, 41600, 80.00, 38.00, 480000, 85.00, 90.00, 14400, 3.00, 1584, 11.00, 7200000.00, 1500000.00, 4.80, 31.25),

-- Eliquis: Cardiology staple, steady performer
('CAMP-00005', 'Eliquis Education Q3 2025', 'Eliquis', 'Cardiology', 'Education', 'Cardiology', 'Completed', DATEADD(day, -100, CURRENT_DATE), DATEADD(day, -20, CURRENT_DATE), 800000.00, 6, 'Bristol-Myers Squibb', 'Gold', 28000, 22400, 80.00, 25.00, 280000, 91.00, 93.00, 8400, 3.00, 924, 11.00, 2800000.00, 600000.00, 4.67, 21.43),

-- ═══════════════════════════════════════════════════════════════════════════
-- STRONG PERFORMERS (ROAS 3.0-4.5) - Solid campaigns
-- ═══════════════════════════════════════════════════════════════════════════
-- Humira: Immunology blockbuster
('CAMP-00006', 'Humira Awareness Q2 2025', 'Humira', 'Immunology', 'Awareness', 'Dermatology', 'Completed', DATEADD(day, -180, CURRENT_DATE), DATEADD(day, -90, CURRENT_DATE), 900000.00, 5, 'AbbVie Inc.', 'Gold', 30000, 22500, 75.00, 26.00, 300000, 87.00, 91.00, 7500, 2.50, 750, 10.00, 2520000.00, 630000.00, 4.00, 21.00),

-- Skyrizi: AbbVie's newer immunology drug
('CAMP-00007', 'Skyrizi Direct Response Q3 2025', 'Skyrizi', 'Immunology', 'Direct Response', 'Dermatology', 'Active', DATEADD(day, -45, CURRENT_DATE), DATEADD(day, 45, CURRENT_DATE), 750000.00, 5, 'AbbVie Inc.', 'Gold', 25000, 18750, 75.00, 28.00, 250000, 89.00, 92.00, 7000, 2.80, 700, 10.00, 2100000.00, 525000.00, 4.00, 21.00),

-- Dupixent: Sanofi/Regeneron partnership
('CAMP-00008', 'Dupixent Education Q3 2025', 'Dupixent', 'Immunology', 'Education', 'Dermatology', 'Completed', DATEADD(day, -90, CURRENT_DATE), DATEADD(day, -10, CURRENT_DATE), 650000.00, 9, 'Sanofi', 'Gold', 22000, 16500, 75.00, 24.00, 220000, 88.00, 90.00, 5500, 2.50, 495, 9.00, 1755000.00, 455000.00, 3.86, 20.68),

-- Entresto: Heart failure treatment
('CAMP-00009', 'Entresto Direct Response Q2 2025', 'Entresto', 'Cardiology', 'Direct Response', 'Cardiology', 'Completed', DATEADD(day, -160, CURRENT_DATE), DATEADD(day, -70, CURRENT_DATE), 700000.00, 11, 'Novartis', 'Gold', 24000, 18000, 75.00, 27.00, 240000, 86.00, 89.00, 6000, 2.50, 540, 9.00, 1890000.00, 490000.00, 3.86, 20.42),

-- Jardiance: Diabetes/cardio crossover
('CAMP-00010', 'Jardiance Awareness Q3 2025', 'Jardiance', 'Diabetes', 'Awareness', 'Cardiology', 'Active', DATEADD(day, -50, CURRENT_DATE), DATEADD(day, 40, CURRENT_DATE), 600000.00, 14, 'Boehringer Ingelheim', 'Gold', 20000, 15000, 75.00, 25.00, 200000, 90.00, 93.00, 5000, 2.50, 450, 9.00, 1620000.00, 420000.00, 3.86, 21.00),

-- ═══════════════════════════════════════════════════════════════════════════
-- MODERATE PERFORMERS (ROAS 2.0-3.0) - Need optimization
-- ═══════════════════════════════════════════════════════════════════════════
-- Trulicity: Mature diabetes drug
('CAMP-00011', 'Trulicity Education Q2 2025', 'Trulicity', 'Diabetes', 'Education', 'Endocrinology', 'Completed', DATEADD(day, -170, CURRENT_DATE), DATEADD(day, -80, CURRENT_DATE), 500000.00, 4, 'Eli Lilly', 'Platinum', 18000, 12600, 70.00, 23.00, 180000, 84.00, 88.00, 3600, 2.00, 288, 8.00, 900000.00, 350000.00, 2.57, 19.44),

-- Ibrance: Oncology, lower engagement
('CAMP-00012', 'Ibrance Awareness Q3 2025', 'Ibrance', 'Oncology', 'Awareness', 'Oncology', 'Completed', DATEADD(day, -110, CURRENT_DATE), DATEADD(day, -30, CURRENT_DATE), 850000.00, 1, 'Pfizer Inc.', 'Platinum', 28000, 19600, 70.00, 32.00, 280000, 82.00, 86.00, 5600, 2.00, 448, 8.00, 1400000.00, 595000.00, 2.35, 21.25),

-- Opdivo: BMS oncology drug
('CAMP-00013', 'Opdivo Direct Response Q2 2025', 'Opdivo', 'Oncology', 'Direct Response', 'Oncology', 'Completed', DATEADD(day, -140, CURRENT_DATE), DATEADD(day, -50, CURRENT_DATE), 950000.00, 6, 'Bristol-Myers Squibb', 'Gold', 30000, 21000, 70.00, 34.00, 300000, 83.00, 87.00, 6000, 2.00, 480, 8.00, 1575000.00, 665000.00, 2.37, 22.17),

-- Repatha: Cholesterol, niche audience
('CAMP-00014', 'Repatha Education Q3 2025', 'Repatha', 'Cardiology', 'Education', 'Cardiology', 'Active', DATEADD(day, -40, CURRENT_DATE), DATEADD(day, 50, CURRENT_DATE), 400000.00, 10, 'Amgen', 'Silver', 14000, 9800, 70.00, 22.00, 140000, 85.00, 89.00, 2800, 2.00, 224, 8.00, 560000.00, 280000.00, 2.00, 20.00),

-- Farxiga: AZ diabetes drug
('CAMP-00015', 'Farxiga Awareness Q2 2025', 'Farxiga', 'Diabetes', 'Awareness', 'Primary Care', 'Completed', DATEADD(day, -190, CURRENT_DATE), DATEADD(day, -100, CURRENT_DATE), 450000.00, 8, 'AstraZeneca', 'Gold', 16000, 11200, 70.00, 21.00, 160000, 86.00, 90.00, 3200, 2.00, 256, 8.00, 720000.00, 315000.00, 2.29, 19.69),

-- ═══════════════════════════════════════════════════════════════════════════
-- UNDERPERFORMERS (ROAS 1.0-2.0) - Candidates for optimization/pause
-- ═══════════════════════════════════════════════════════════════════════════
-- Tagrisso: Niche oncology, limited reach
('CAMP-00016', 'Tagrisso Direct Response Q3 2025', 'Tagrisso', 'Oncology', 'Direct Response', 'Oncology', 'Active', DATEADD(day, -35, CURRENT_DATE), DATEADD(day, 55, CURRENT_DATE), 600000.00, 8, 'AstraZeneca', 'Gold', 18000, 10800, 60.00, 35.00, 150000, 78.00, 82.00, 2250, 1.50, 135, 6.00, 540000.00, 360000.00, 1.50, 24.00),

-- Rinvoq: Newer, building awareness
('CAMP-00017', 'Rinvoq Awareness Q2 2025', 'Rinvoq', 'Immunology', 'Awareness', 'Immunology', 'Completed', DATEADD(day, -175, CURRENT_DATE), DATEADD(day, -85, CURRENT_DATE), 550000.00, 5, 'AbbVie Inc.', 'Gold', 17000, 10200, 60.00, 28.00, 170000, 80.00, 84.00, 2550, 1.50, 153, 6.00, 476000.00, 330000.00, 1.44, 19.41),
    
-- Vyvanse: Neurology, competitive market  
('CAMP-00018', 'Vyvanse Education Q3 2025', 'Vyvanse', 'Neurology', 'Education', 'Neurology', 'Completed', DATEADD(day, -85, CURRENT_DATE), DATEADD(day, -15, CURRENT_DATE), 350000.00, 15, 'Takeda', 'Silver', 12000, 7200, 60.00, 20.00, 120000, 79.00, 83.00, 1800, 1.50, 108, 6.00, 280000.00, 210000.00, 1.33, 17.50),

-- Spinraza: Very niche, expensive
('CAMP-00019', 'Spinraza Direct Response Q2 2025', 'Spinraza', 'Neurology', 'Direct Response', 'Neurology', 'Completed', DATEADD(day, -165, CURRENT_DATE), DATEADD(day, -75, CURRENT_DATE), 300000.00, 13, 'Biogen', 'Bronze', 10000, 6000, 60.00, 25.00, 100000, 77.00, 81.00, 1500, 1.50, 90, 6.00, 225000.00, 180000.00, 1.25, 18.00),
    
-- Zepbound: New to market, ramping up
('CAMP-00020', 'Zepbound Awareness Q4 2025', 'Zepbound', 'Weight Loss', 'Awareness', 'Primary Care', 'Scheduled', DATEADD(day, 10, CURRENT_DATE), DATEADD(day, 100, CURRENT_DATE), 800000.00, 4, 'Eli Lilly', 'Platinum', 5000, 2500, 50.00, 30.00, 50000, 75.00, 80.00, 500, 1.00, 25, 5.00, 80000.00, 75000.00, 1.07, 15.00),

-- ═══════════════════════════════════════════════════════════════════════════
-- ADDITIONAL CAMPAIGNS FOR VARIETY
-- ═══════════════════════════════════════════════════════════════════════════
-- High-budget oncology active campaign
('CAMP-00021', 'Keytruda Awareness Q4 2025', 'Keytruda', 'Oncology', 'Awareness', 'Primary Care', 'Active', DATEADD(day, -30, CURRENT_DATE), DATEADD(day, 60, CURRENT_DATE), 1800000.00, 3, 'Merck & Co.', 'Platinum', 40000, 32000, 80.00, 35.00, 400000, 88.00, 91.00, 12000, 3.00, 1080, 9.00, 5400000.00, 1260000.00, 4.29, 31.50),

-- Education focus for mature drug
('CAMP-00022', 'Humira Direct Response Q3 2025', 'Humira', 'Immunology', 'Direct Response', 'Immunology', 'Completed', DATEADD(day, -95, CURRENT_DATE), DATEADD(day, -25, CURRENT_DATE), 700000.00, 5, 'AbbVie Inc.', 'Gold', 23000, 17250, 75.00, 27.00, 230000, 89.00, 92.00, 5750, 2.50, 518, 9.00, 1725000.00, 490000.00, 3.52, 21.30),

-- Multi-specialty diabetes campaign
('CAMP-00023', 'Ozempic Education Q2 2025', 'Ozempic', 'Diabetes', 'Education', 'Primary Care', 'Completed', DATEADD(day, -210, CURRENT_DATE), DATEADD(day, -120, CURRENT_DATE), 1000000.00, 7, 'Novo Nordisk', 'Platinum', 32000, 25600, 80.00, 30.00, 320000, 91.00, 94.00, 9600, 3.00, 960, 10.00, 3520000.00, 700000.00, 5.03, 21.88),

-- Regional cardiology test
('CAMP-00024', 'Eliquis Direct Response Q2 2025', 'Eliquis', 'Cardiology', 'Direct Response', 'Internal Medicine', 'Completed', DATEADD(day, -185, CURRENT_DATE), DATEADD(day, -95, CURRENT_DATE), 550000.00, 6, 'Bristol-Myers Squibb', 'Gold', 19000, 14250, 75.00, 24.00, 190000, 87.00, 90.00, 4750, 2.50, 428, 9.00, 1425000.00, 385000.00, 3.70, 20.26),

-- Newer weight loss entry
('CAMP-00025', 'Wegovy Direct Response Q4 2025', 'Wegovy', 'Weight Loss', 'Direct Response', 'Endocrinology', 'Active', DATEADD(day, -25, CURRENT_DATE), DATEADD(day, 65, CURRENT_DATE), 1400000.00, 7, 'Novo Nordisk', 'Platinum', 42000, 35700, 85.00, 31.00, 420000, 90.00, 93.00, 14700, 3.50, 1617, 11.00, 5880000.00, 980000.00, 6.00, 23.33);

SELECT 'T_CAMPAIGN_PERFORMANCE created: ' || COUNT(*) || ' campaigns' AS status FROM T_CAMPAIGN_PERFORMANCE;


-- ============================================================================
-- T_INVENTORY_ANALYTICS - 30 curated inventory slots
-- Revenue = Impressions × CPM / 1000
-- ============================================================================
CREATE OR REPLACE TABLE T_INVENTORY_ANALYTICS (
    slot_id VARCHAR(20),
    slot_name VARCHAR(150),
    screen_type VARCHAR(30),
    screen_size VARCHAR(20),
    placement_area VARCHAR(30),
    daypart VARCHAR(20),
    base_cpm NUMBER(12,2),
    is_premium BOOLEAN,
    estimated_daily_impressions INT,
    facility_name VARCHAR(100),
    facility_type VARCHAR(30),
    city VARCHAR(50),
    state VARCHAR(10),
    region VARCHAR(20),
    patient_volume INT,
    affluence_index NUMBER(5,2),
    specialty_name VARCHAR(50),
    specialty_category VARCHAR(20),
    total_bids INT,
    fill_rate_pct NUMBER(8,2),
    delivered_impressions INT,
    avg_winning_cpm NUMBER(12,2),
    avg_completion_pct NUMBER(8,2),
    avg_viewability_pct NUMBER(8,2),
    total_engagements INT,
    engagement_rate_pct NUMBER(8,4),
    total_revenue NUMBER(18,2)
);

INSERT INTO T_INVENTORY_ANALYTICS VALUES
-- ═══════════════════════════════════════════════════════════════════════════
-- PREMIUM HOSPITAL INVENTORY - High CPM, High Value
-- ═══════════════════════════════════════════════════════════════════════════
('SLOT-00001', 'Mayo Clinic - Waiting Room Digital Display', 'Digital Display', 'Large', 'Waiting Room', 'All Day', 45.00, TRUE, 600, 'Mayo Clinic', 'Hospital', 'Rochester', 'MN', 'Midwest', 85000, 8.50, 'Cardiology', 'Specialty', 15000, 88.00, 52800, 52.00, 94.00, 96.00, 1584, 3.00, 2745.60),
('SLOT-00002', 'Mayo Clinic - Exam Room Tablet', 'Tablet', 'Small', 'Exam Room', 'Morning', 55.00, TRUE, 250, 'Mayo Clinic', 'Hospital', 'Rochester', 'MN', 'Midwest', 85000, 8.50, 'Oncology', 'Specialty', 8000, 92.00, 23000, 62.00, 96.00, 98.00, 805, 3.50, 1426.00),
('SLOT-00003', 'Cleveland Clinic - Waiting Room TV Screen', 'TV Screen', 'Large', 'Waiting Room', 'All Day', 42.00, TRUE, 550, 'Cleveland Clinic', 'Hospital', 'Cleveland', 'OH', 'Midwest', 78000, 8.20, 'Cardiology', 'Specialty', 14000, 85.00, 46750, 48.00, 92.00, 94.00, 1169, 2.50, 2244.00),
('SLOT-00004', 'Johns Hopkins - Exam Room Digital Display', 'Digital Display', 'Large', 'Exam Room', 'Afternoon', 58.00, TRUE, 400, 'Johns Hopkins', 'Hospital', 'Baltimore', 'MD', 'Northeast', 72000, 8.80, 'Oncology', 'Specialty', 12000, 90.00, 36000, 65.00, 95.00, 97.00, 1260, 3.50, 2340.00),
('SLOT-00005', 'NY Presbyterian - Waiting Room Kiosk', 'Kiosk', 'Medium', 'Waiting Room', 'All Day', 48.00, TRUE, 450, 'NY Presbyterian', 'Hospital', 'New York', 'NY', 'Northeast', 90000, 9.40, 'Neurology', 'Specialty', 13500, 86.00, 38700, 55.00, 93.00, 95.00, 1161, 3.00, 2128.50),

-- ═══════════════════════════════════════════════════════════════════════════
-- HIGH-VALUE SPECIALTY INVENTORY
-- ═══════════════════════════════════════════════════════════════════════════
('SLOT-00006', 'UCLA Medical Center - Exam Room Tablet', 'Tablet', 'Small', 'Exam Room', 'Morning', 52.00, TRUE, 280, 'UCLA Medical Center', 'Hospital', 'Los Angeles', 'CA', 'West', 82000, 8.70, 'Endocrinology', 'Specialty', 9000, 89.00, 24920, 58.00, 94.00, 96.00, 747, 3.00, 1445.36),
('SLOT-00007', 'Stanford Health - Waiting Room Digital Display', 'Digital Display', 'Large', 'Waiting Room', 'All Day', 50.00, TRUE, 350, 'Stanford Health', 'Hospital', 'Palo Alto', 'CA', 'West', 55000, 9.20, 'Oncology', 'Specialty', 10500, 87.00, 30450, 56.00, 93.00, 95.00, 914, 3.00, 1705.20),
('SLOT-00008', 'Mass General - Exam Room TV Screen', 'TV Screen', 'Large', 'Exam Room', 'Afternoon', 54.00, TRUE, 380, 'Massachusetts General', 'Hospital', 'Boston', 'MA', 'Northeast', 68000, 9.10, 'Cardiology', 'Specialty', 11400, 91.00, 34580, 60.00, 95.00, 97.00, 1037, 3.00, 2074.80),
('SLOT-00009', 'Cedars-Sinai - Check-in Digital Display', 'Digital Display', 'Large', 'Check-in', 'Morning', 38.00, FALSE, 500, 'Cedars-Sinai', 'Hospital', 'Los Angeles', 'CA', 'West', 58000, 9.00, 'Dermatology', 'Specialty', 12500, 82.00, 41000, 44.00, 90.00, 92.00, 1025, 2.50, 1804.00),
('SLOT-00010', 'Duke Health - Waiting Room Kiosk', 'Kiosk', 'Medium', 'Waiting Room', 'All Day', 40.00, FALSE, 400, 'Duke Health', 'Hospital', 'Durham', 'NC', 'Southeast', 62000, 8.00, 'Immunology', 'Specialty', 10000, 84.00, 33600, 46.00, 91.00, 93.00, 840, 2.50, 1545.60),

-- ═══════════════════════════════════════════════════════════════════════════
-- MEDICAL CENTER INVENTORY - Mid-tier value
-- ═══════════════════════════════════════════════════════════════════════════
('SLOT-00011', 'Northwell Health - Waiting Room TV Screen', 'TV Screen', 'Large', 'Waiting Room', 'Afternoon', 35.00, FALSE, 420, 'Northwell Health', 'Medical Center', 'New York', 'NY', 'Northeast', 45000, 8.30, 'Primary Care', 'General', 10500, 80.00, 33600, 40.00, 88.00, 90.00, 672, 2.00, 1344.00),
('SLOT-00012', 'Emory Healthcare - Exam Room Tablet', 'Tablet', 'Small', 'Exam Room', 'Morning', 42.00, FALSE, 220, 'Emory Healthcare', 'Medical Center', 'Atlanta', 'GA', 'Southeast', 42000, 7.80, 'Endocrinology', 'Specialty', 7000, 83.00, 18260, 48.00, 90.00, 92.00, 548, 3.00, 876.48),
('SLOT-00013', 'UPMC - Waiting Room Digital Display', 'Digital Display', 'Large', 'Waiting Room', 'All Day', 38.00, FALSE, 380, 'UPMC', 'Medical Center', 'Pittsburgh', 'PA', 'Northeast', 48000, 7.60, 'Cardiology', 'Specialty', 9500, 81.00, 30780, 44.00, 89.00, 91.00, 770, 2.50, 1354.32),
('SLOT-00014', 'Scripps Health - Check-in Kiosk', 'Kiosk', 'Medium', 'Check-in', 'Afternoon', 32.00, FALSE, 300, 'Scripps Health', 'Medical Center', 'San Diego', 'CA', 'West', 38000, 8.40, 'Primary Care', 'General', 7500, 78.00, 23400, 38.00, 86.00, 88.00, 468, 2.00, 889.20),
('SLOT-00015', 'Baylor Scott White - Waiting Room TV Screen', 'TV Screen', 'Large', 'Waiting Room', 'Morning', 36.00, FALSE, 400, 'Baylor Scott White', 'Medical Center', 'Dallas', 'TX', 'Southwest', 52000, 7.50, 'Neurology', 'Specialty', 10000, 79.00, 31600, 42.00, 87.00, 89.00, 632, 2.00, 1327.20),

-- ═══════════════════════════════════════════════════════════════════════════
-- CLINIC INVENTORY - Volume plays
-- ═══════════════════════════════════════════════════════════════════════════
('SLOT-00016', 'Cardiology Associates - Waiting Room Digital Display', 'Digital Display', 'Large', 'Waiting Room', 'All Day', 28.00, FALSE, 150, 'Cardiology Associates', 'Clinic', 'Miami', 'FL', 'Southeast', 8000, 7.20, 'Cardiology', 'Specialty', 4500, 75.00, 11250, 32.00, 84.00, 86.00, 281, 2.50, 360.00),
('SLOT-00017', 'Diabetes Care Center - Exam Room Tablet', 'Tablet', 'Small', 'Exam Room', 'Morning', 35.00, FALSE, 100, 'Diabetes Care Center', 'Clinic', 'Phoenix', 'AZ', 'Southwest', 6500, 6.80, 'Endocrinology', 'Specialty', 3500, 82.00, 8200, 40.00, 88.00, 90.00, 287, 3.50, 328.00),
('SLOT-00018', 'Oncology Partners - Waiting Room TV Screen', 'TV Screen', 'Large', 'Waiting Room', 'Afternoon', 40.00, FALSE, 120, 'Oncology Partners', 'Clinic', 'Chicago', 'IL', 'Midwest', 7200, 7.40, 'Oncology', 'Specialty', 4000, 80.00, 9600, 46.00, 90.00, 92.00, 288, 3.00, 441.60),
('SLOT-00019', 'Primary Care Plus - Check-in Digital Display', 'Digital Display', 'Large', 'Check-in', 'All Day', 22.00, FALSE, 200, 'Primary Care Plus', 'Clinic', 'Denver', 'CO', 'West', 12000, 6.50, 'Primary Care', 'General', 5000, 72.00, 14400, 26.00, 82.00, 84.00, 288, 2.00, 374.40),
('SLOT-00020', 'Family Medicine Group - Waiting Room Kiosk', 'Kiosk', 'Medium', 'Waiting Room', 'Morning', 25.00, FALSE, 160, 'Family Medicine Group', 'Clinic', 'Seattle', 'WA', 'West', 9500, 7.00, 'Primary Care', 'General', 4000, 74.00, 11840, 30.00, 85.00, 87.00, 296, 2.50, 355.20),

-- ═══════════════════════════════════════════════════════════════════════════
-- ADDITIONAL VARIETY - Different dayparts and placements
-- ═══════════════════════════════════════════════════════════════════════════
('SLOT-00021', 'Houston Methodist - Hallway Digital Display', 'Digital Display', 'Large', 'Hallway', 'All Day', 20.00, FALSE, 700, 'Houston Methodist', 'Hospital', 'Houston', 'TX', 'Southwest', 75000, 7.90, 'Internal Medicine', 'General', 14000, 70.00, 49000, 24.00, 80.00, 82.00, 980, 2.00, 1176.00),
('SLOT-00022', 'UCLA Medical Center - Hallway TV Screen', 'TV Screen', 'Large', 'Hallway', 'Afternoon', 22.00, FALSE, 600, 'UCLA Medical Center', 'Hospital', 'Los Angeles', 'CA', 'West', 82000, 8.70, 'Orthopedics', 'Specialty', 12000, 68.00, 40800, 26.00, 78.00, 80.00, 816, 2.00, 1060.80),
('SLOT-00023', 'Cleveland Clinic - Check-in Tablet', 'Tablet', 'Small', 'Check-in', 'Morning', 30.00, FALSE, 350, 'Cleveland Clinic', 'Hospital', 'Cleveland', 'OH', 'Midwest', 78000, 8.20, 'Internal Medicine', 'General', 8750, 76.00, 26600, 36.00, 86.00, 88.00, 532, 2.00, 957.60),
('SLOT-00024', 'Johns Hopkins - Hallway Kiosk', 'Kiosk', 'Medium', 'Hallway', 'Evening', 18.00, FALSE, 300, 'Johns Hopkins', 'Hospital', 'Baltimore', 'MD', 'Northeast', 72000, 8.80, 'Dermatology', 'Specialty', 6000, 65.00, 19500, 22.00, 76.00, 78.00, 390, 2.00, 429.00),
('SLOT-00025', 'NY Presbyterian - Exam Room Digital Display', 'Digital Display', 'Large', 'Exam Room', 'Evening', 48.00, TRUE, 280, 'NY Presbyterian', 'Hospital', 'New York', 'NY', 'Northeast', 90000, 9.40, 'Cardiology', 'Specialty', 7000, 85.00, 23800, 54.00, 92.00, 94.00, 714, 3.00, 1285.20),

-- Additional high-volume slots
('SLOT-00026', 'Mass General - Waiting Room Digital Display', 'Digital Display', 'Large', 'Waiting Room', 'All Day', 46.00, TRUE, 520, 'Massachusetts General', 'Hospital', 'Boston', 'MA', 'Northeast', 68000, 9.10, 'Neurology', 'Specialty', 13000, 88.00, 45760, 52.00, 93.00, 95.00, 1373, 3.00, 2379.52),
('SLOT-00027', 'Stanford Health - Exam Room Tablet', 'Tablet', 'Small', 'Exam Room', 'Afternoon', 56.00, TRUE, 200, 'Stanford Health', 'Hospital', 'Palo Alto', 'CA', 'West', 55000, 9.20, 'Endocrinology', 'Specialty', 6000, 90.00, 18000, 62.00, 95.00, 97.00, 630, 3.50, 1116.00),
('SLOT-00028', 'Emory Healthcare - Hallway TV Screen', 'TV Screen', 'Large', 'Hallway', 'All Day', 24.00, FALSE, 450, 'Emory Healthcare', 'Medical Center', 'Atlanta', 'GA', 'Southeast', 42000, 7.80, 'Orthopedics', 'Specialty', 9000, 72.00, 32400, 28.00, 80.00, 82.00, 648, 2.00, 907.20),
('SLOT-00029', 'UPMC - Check-in Digital Display', 'Digital Display', 'Large', 'Check-in', 'Morning', 32.00, FALSE, 380, 'UPMC', 'Medical Center', 'Pittsburgh', 'PA', 'Northeast', 48000, 7.60, 'Primary Care', 'General', 9500, 77.00, 29260, 38.00, 87.00, 89.00, 731, 2.50, 1111.88),
('SLOT-00030', 'Baylor Scott White - Exam Room Tablet', 'Tablet', 'Small', 'Exam Room', 'Afternoon', 38.00, FALSE, 180, 'Baylor Scott White', 'Medical Center', 'Dallas', 'TX', 'Southwest', 52000, 7.50, 'Immunology', 'Specialty', 5400, 81.00, 14580, 44.00, 89.00, 91.00, 437, 3.00, 641.52);

SELECT 'T_INVENTORY_ANALYTICS created: ' || COUNT(*) || ' slots' AS status FROM T_INVENTORY_ANALYTICS;


-- ============================================================================
-- T_AUDIENCE_INSIGHTS - 20 curated audience cohorts
-- All metrics are mathematically consistent
-- ============================================================================
CREATE OR REPLACE TABLE T_AUDIENCE_INSIGHTS (
    cohort_id VARCHAR(20),
    cohort_name VARCHAR(150),
    age_bucket VARCHAR(10),
    gender VARCHAR(10),
    ethnicity VARCHAR(30),
    region VARCHAR(20),
    income_bracket VARCHAR(20),
    insurance_type VARCHAR(20),
    health_interest VARCHAR(50),
    top_therapeutic_interests VARCHAR(200),
    cohort_size INT,
    baseline_engagement_score NUMBER(5,1),
    avg_visit_frequency NUMBER(4,1),
    campaigns_exposed INT,
    total_impressions INT,
    avg_exposure_frequency NUMBER(4,1),
    total_engagements INT,
    engagement_rate_pct NUMBER(8,3),
    total_conversions INT,
    conversion_rate_pct NUMBER(8,2),
    avg_dwell_time_seconds NUMBER(6,1),
    avg_ad_completion_pct NUMBER(5,2),
    cohort_revenue NUMBER(18,2),
    revenue_per_member NUMBER(10,4)
);

INSERT INTO T_AUDIENCE_INSIGHTS VALUES
-- ═══════════════════════════════════════════════════════════════════════════
-- HIGH-VALUE COHORTS - Platinum tier engagement
-- ═══════════════════════════════════════════════════════════════════════════
('COH-00001', '55-64 Female - Diabetes Management (Northeast)', '55-64', 'Female', 'White', 'Northeast', 'High', 'Commercial', 'Diabetes Management', 'Diabetes, Endocrinology, Nutrition', 2500, 85.0, 4.2, 18, 125000, 5.0, 4375, 3.500, 700, 16.00, 95.0, 92.00, 35000.00, 14.0000),
('COH-00002', '45-54 Male - Heart Health (Midwest)', '45-54', 'Male', 'White', 'Midwest', 'High', 'Commercial', 'Heart Health', 'Cardiology, Blood Pressure, Cholesterol', 3200, 82.0, 3.8, 15, 128000, 4.0, 3840, 3.000, 576, 15.00, 88.0, 90.00, 38400.00, 12.0000),
('COH-00003', '65+ Female - Cancer Awareness (West)', '65+', 'Female', 'Not Specified', 'West', 'Very High', 'Medicare', 'Cancer Awareness', 'Oncology, Prevention, Treatment', 1800, 88.0, 5.5, 12, 90000, 5.0, 3150, 3.500, 504, 16.00, 105.0, 94.00, 27000.00, 15.0000),
('COH-00004', '35-44 Female - Weight Management (Southeast)', '35-44', 'Female', 'Hispanic', 'Southeast', 'Medium', 'Commercial', 'Weight Management', 'Obesity, Nutrition, Fitness', 4500, 78.0, 3.2, 20, 180000, 4.0, 5400, 3.000, 756, 14.00, 72.0, 88.00, 45000.00, 10.0000),

-- ═══════════════════════════════════════════════════════════════════════════
-- STRONG ENGAGEMENT COHORTS
-- ═══════════════════════════════════════════════════════════════════════════
('COH-00005', '25-34 Male - Mental Wellness (Northeast)', '25-34', 'Male', 'Black', 'Northeast', 'Medium', 'Commercial', 'Mental Wellness', 'Neurology, Psychology, Stress', 3800, 72.0, 2.8, 14, 114000, 3.0, 2850, 2.500, 342, 12.00, 65.0, 85.00, 30400.00, 8.0000),
('COH-00006', '45-54 Female - Skin Health (West)', '45-54', 'Female', 'Asian', 'West', 'High', 'Commercial', 'Skin Health', 'Dermatology, Cosmetic, Sun Protection', 2200, 80.0, 3.5, 16, 88000, 4.0, 2640, 3.000, 370, 14.00, 78.0, 89.00, 24200.00, 11.0000),
('COH-00007', '55-64 Male - Joint & Bone Health (Midwest)', '55-64', 'Male', 'White', 'Midwest', 'Medium', 'Medicare', 'Joint & Bone Health', 'Orthopedics, Arthritis, Osteoporosis', 2800, 75.0, 4.0, 13, 112000, 4.0, 2800, 2.500, 364, 13.00, 82.0, 87.00, 22400.00, 8.0000),
('COH-00008', '65+ Male - Respiratory Health (Southeast)', '65+', 'Male', 'White', 'Southeast', 'Medium', 'Medicare', 'Respiratory Health', 'Pulmonology, Allergies, Asthma', 2100, 77.0, 4.5, 11, 84000, 4.0, 2100, 2.500, 273, 13.00, 90.0, 86.00, 16800.00, 8.0000),

-- ═══════════════════════════════════════════════════════════════════════════
-- MODERATE ENGAGEMENT COHORTS
-- ═══════════════════════════════════════════════════════════════════════════
('COH-00009', '35-44 Male - Diabetes Management (Southwest)', '35-44', 'Male', 'Hispanic', 'Southwest', 'Low', 'Medicaid', 'Diabetes Management', 'Diabetes, Endocrinology, Nutrition', 3500, 65.0, 2.5, 10, 105000, 3.0, 2100, 2.000, 252, 12.00, 55.0, 82.00, 17500.00, 5.0000),
('COH-00010', '18-24 Female - General Wellness (West)', '18-24', 'Female', 'Asian', 'West', 'Low', 'Commercial', 'General Wellness', 'Prevention, Checkups, Lifestyle', 5000, 60.0, 1.8, 8, 100000, 2.0, 2000, 2.000, 200, 10.00, 45.0, 80.00, 25000.00, 5.0000),
('COH-00011', '25-34 Female - Womens Health (Northeast)', '25-34', 'Female', 'Black', 'Northeast', 'Medium', 'Commercial', 'Womens Health', 'Gynecology, Pregnancy, Menopause', 4200, 70.0, 2.2, 12, 126000, 3.0, 3150, 2.500, 378, 12.00, 60.0, 84.00, 29400.00, 7.0000),
('COH-00012', '45-54 All - Heart Health (Southeast)', '45-54', 'All', 'Not Specified', 'Southeast', 'High', 'Commercial', 'Heart Health', 'Cardiology, Blood Pressure, Cholesterol', 1500, 79.0, 3.6, 14, 60000, 4.0, 1500, 2.500, 195, 13.00, 80.0, 88.00, 15000.00, 10.0000),

-- ═══════════════════════════════════════════════════════════════════════════
-- LOWER ENGAGEMENT COHORTS - Optimization opportunities
-- ═══════════════════════════════════════════════════════════════════════════
('COH-00013', '18-24 Male - General Wellness (Midwest)', '18-24', 'Male', 'White', 'Midwest', 'Low', 'Uninsured', 'General Wellness', 'Prevention, Checkups, Lifestyle', 4000, 48.0, 1.2, 5, 60000, 1.5, 900, 1.500, 72, 8.00, 35.0, 72.00, 12000.00, 3.0000),
('COH-00014', '65+ Female - General Wellness (Southwest)', '65+', 'Female', 'Hispanic', 'Southwest', 'Low', 'Medicare', 'General Wellness', 'Prevention, Checkups, Lifestyle', 2400, 55.0, 2.0, 7, 48000, 2.0, 720, 1.500, 58, 8.00, 50.0, 78.00, 7200.00, 3.0000),
('COH-00015', '35-44 Male - Mental Wellness (Southeast)', '35-44', 'Male', 'Black', 'Southeast', 'Medium', 'Commercial', 'Mental Wellness', 'Neurology, Psychology, Stress', 3000, 52.0, 1.8, 6, 60000, 2.0, 900, 1.500, 90, 10.00, 42.0, 75.00, 12000.00, 4.0000),
('COH-00016', '55-64 Male - Skin Health (Northeast)', '55-64', 'Male', 'White', 'Northeast', 'Medium', 'Commercial', 'Skin Health', 'Dermatology, Cosmetic, Sun Protection', 1800, 58.0, 2.2, 8, 36000, 2.0, 540, 1.500, 54, 10.00, 48.0, 77.00, 7200.00, 4.0000),

-- ═══════════════════════════════════════════════════════════════════════════
-- NICHE HIGH-VALUE COHORTS
-- ═══════════════════════════════════════════════════════════════════════════
('COH-00017', '45-54 Female - Cancer Awareness (Northeast)', '45-54', 'Female', 'White', 'Northeast', 'Very High', 'Commercial', 'Cancer Awareness', 'Oncology, Prevention, Treatment', 1200, 90.0, 5.8, 10, 60000, 5.0, 2400, 4.000, 480, 20.00, 110.0, 95.00, 21600.00, 18.0000),
('COH-00018', '55-64 Female - Weight Management (West)', '55-64', 'Female', 'Not Specified', 'West', 'High', 'Commercial', 'Weight Management', 'Obesity, Nutrition, Fitness', 2000, 83.0, 3.8, 15, 80000, 4.0, 2800, 3.500, 420, 15.00, 85.0, 91.00, 26000.00, 13.0000),
('COH-00019', '65+ Male - Diabetes Management (Midwest)', '65+', 'Male', 'White', 'Midwest', 'Medium', 'Medicare', 'Diabetes Management', 'Diabetes, Endocrinology, Nutrition', 2600, 80.0, 4.8, 14, 104000, 4.0, 3120, 3.000, 468, 15.00, 92.0, 89.00, 23400.00, 9.0000),
('COH-00020', '35-44 Female - Heart Health (Southeast)', '35-44', 'Female', 'Hispanic', 'Southeast', 'Medium', 'Commercial', 'Heart Health', 'Cardiology, Blood Pressure, Cholesterol', 3600, 74.0, 2.8, 12, 108000, 3.0, 2700, 2.500, 324, 12.00, 68.0, 86.00, 25200.00, 7.0000);

SELECT 'T_AUDIENCE_INSIGHTS created: ' || COUNT(*) || ' cohorts' AS status FROM T_AUDIENCE_INSIGHTS;


-- ============================================================================
-- VERIFICATION
-- ============================================================================
SELECT '✅ DEMO DATA READY!' AS status;
SELECT 'T_CAMPAIGN_PERFORMANCE' AS table_name, COUNT(*) AS records FROM T_CAMPAIGN_PERFORMANCE
UNION ALL SELECT 'T_INVENTORY_ANALYTICS', COUNT(*) FROM T_INVENTORY_ANALYTICS
UNION ALL SELECT 'T_AUDIENCE_INSIGHTS', COUNT(*) FROM T_AUDIENCE_INSIGHTS;

-- Quick sanity check on a top campaign
SELECT 
    campaign_name,
    budget,
    total_spend,
    total_revenue,
    roas,
    ROUND(total_revenue / NULLIF(total_spend, 0), 2) AS calculated_roas,
    CASE WHEN ABS(roas - ROUND(total_revenue / NULLIF(total_spend, 0), 2)) < 0.1 THEN '✅ VALID' ELSE '❌ MISMATCH' END AS roas_check
FROM T_CAMPAIGN_PERFORMANCE
WHERE campaign_id = 'CAMP-00001';
