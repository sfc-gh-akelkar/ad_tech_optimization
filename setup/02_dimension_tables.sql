/*
=============================================================================
PatientPoint Ad Tech Optimization Demo - Dimension Tables
=============================================================================
Creates dimension tables for the healthcare advertising data model.
All tables are created with SF_INTELLIGENCE_DEMO role.
=============================================================================
*/

USE ROLE SF_INTELLIGENCE_DEMO;
USE DATABASE AD_TECH;
USE SCHEMA ANALYTICS;
USE WAREHOUSE AD_TECH_WH;

-- ============================================================================
-- DIM_DATE - Date Dimension (2 years)
-- ============================================================================
CREATE OR REPLACE TABLE DIM_DATE (
    date_key            INTEGER PRIMARY KEY,
    full_date           DATE NOT NULL,
    year                INTEGER,
    quarter             INTEGER,
    quarter_name        VARCHAR(10),
    month               INTEGER,
    month_name          VARCHAR(20),
    week_of_year        INTEGER,
    day_of_week         INTEGER,
    day_name            VARCHAR(20),
    is_weekend          BOOLEAN,
    is_holiday          BOOLEAN,
    fiscal_year         INTEGER,
    fiscal_quarter      INTEGER
);

-- ============================================================================
-- DIM_MEDICAL_SPECIALTIES - Medical Practice Types
-- ============================================================================
CREATE OR REPLACE TABLE DIM_MEDICAL_SPECIALTIES (
    specialty_id        INTEGER PRIMARY KEY,
    specialty_name      VARCHAR(100) NOT NULL,
    specialty_category  VARCHAR(50),
    avg_visit_duration  INTEGER,       -- minutes
    patient_volume_tier VARCHAR(20),   -- HIGH, MEDIUM, LOW
    base_cpm_multiplier FLOAT,         -- premium multiplier for this specialty
    description         VARCHAR(500)
);

-- ============================================================================
-- DIM_LOCATIONS - Healthcare Facility Locations
-- ============================================================================
CREATE OR REPLACE TABLE DIM_LOCATIONS (
    location_id         INTEGER PRIMARY KEY,
    facility_name       VARCHAR(200) NOT NULL,
    facility_type       VARCHAR(50),   -- Hospital, Clinic, Medical Center, etc.
    address             VARCHAR(300),
    city                VARCHAR(100),
    state               VARCHAR(50),
    zip_code            VARCHAR(10),
    region              VARCHAR(50),   -- Northeast, Southeast, Midwest, Southwest, West
    dma_code            VARCHAR(10),   -- Designated Market Area
    dma_name            VARCHAR(100),
    latitude            FLOAT,
    longitude           FLOAT,
    patient_volume      INTEGER,       -- avg monthly patients
    affluence_index     FLOAT          -- 1-10 scale
);

-- ============================================================================
-- DIM_INVENTORY - Ad Placement Slots
-- ============================================================================
CREATE OR REPLACE TABLE DIM_INVENTORY (
    slot_id             VARCHAR(50) PRIMARY KEY,
    slot_name           VARCHAR(200) NOT NULL,
    location_id         INTEGER REFERENCES DIM_LOCATIONS(location_id),
    specialty_id        INTEGER REFERENCES DIM_MEDICAL_SPECIALTIES(specialty_id),
    screen_type         VARCHAR(50),   -- Digital Display, Tablet, Check-in Kiosk, Waiting Room TV
    screen_size         VARCHAR(20),   -- 10", 32", 55", 65"
    placement_area      VARCHAR(50),   -- Waiting Room, Exam Room, Check-in, Hallway
    daypart             VARCHAR(20),   -- Morning, Afternoon, Evening, All Day
    duration_seconds    INTEGER,       -- ad duration in seconds
    daily_impressions   INTEGER,       -- estimated daily impressions
    base_cpm            FLOAT,         -- base cost per thousand impressions
    is_premium          BOOLEAN,
    is_active           BOOLEAN DEFAULT TRUE,
    created_date        DATE
);

-- ============================================================================
-- DIM_PHARMA_PARTNERS - Pharmaceutical Advertisers
-- ============================================================================
CREATE OR REPLACE TABLE DIM_PHARMA_PARTNERS (
    partner_id          INTEGER PRIMARY KEY,
    partner_name        VARCHAR(200) NOT NULL,
    partner_tier        VARCHAR(20),   -- Platinum, Gold, Silver, Bronze
    industry_segment    VARCHAR(100),  -- Big Pharma, Biotech, Medical Device, etc.
    primary_contact     VARCHAR(200),
    contract_start_date DATE,
    contract_end_date   DATE,
    annual_budget       FLOAT,
    is_active           BOOLEAN DEFAULT TRUE
);

-- ============================================================================
-- DIM_CAMPAIGNS - Advertising Campaigns
-- ============================================================================
CREATE OR REPLACE TABLE DIM_CAMPAIGNS (
    campaign_id         VARCHAR(50) PRIMARY KEY,
    campaign_name       VARCHAR(300) NOT NULL,
    partner_id          INTEGER REFERENCES DIM_PHARMA_PARTNERS(partner_id),
    drug_name           VARCHAR(200),
    therapeutic_area    VARCHAR(100),  -- Diabetes, Cardiology, Oncology, etc.
    campaign_type       VARCHAR(50),   -- Awareness, Education, Direct Response
    target_specialty    VARCHAR(100),  -- Target medical specialty
    start_date          DATE,
    end_date            DATE,
    budget              FLOAT,
    daily_budget_cap    FLOAT,
    target_impressions  INTEGER,
    target_ctr          FLOAT,
    status              VARCHAR(20),   -- Active, Paused, Completed, Scheduled
    created_date        TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- DIM_AUDIENCE_COHORTS - Privacy-Safe Patient Segments
-- ============================================================================
CREATE OR REPLACE TABLE DIM_AUDIENCE_COHORTS (
    cohort_id           VARCHAR(50) PRIMARY KEY,
    cohort_name         VARCHAR(200) NOT NULL,
    age_bucket          VARCHAR(20),   -- 18-24, 25-34, 35-44, 45-54, 55-64, 65+
    gender              VARCHAR(20),   -- Male, Female, All
    ethnicity           VARCHAR(50),   -- For demographic analysis
    region              VARCHAR(50),   -- Geographic region
    income_bracket      VARCHAR(30),   -- Low, Medium, High, Very High
    insurance_type      VARCHAR(50),   -- Commercial, Medicare, Medicaid, Uninsured
    health_interest     VARCHAR(100),  -- Primary health interest category
    cohort_size         INTEGER,       -- Must be >= 50 for k-anonymity
    avg_engagement_score FLOAT,        -- 0-100 scale
    avg_visit_frequency FLOAT,         -- visits per month
    top_therapeutic_interests VARCHAR(500), -- comma-separated list
    created_date        DATE,
    last_updated        TIMESTAMP_NTZ
);

-- ============================================================================
-- DIM_CREATIVE_ASSETS - Ad Creative Information
-- ============================================================================
CREATE OR REPLACE TABLE DIM_CREATIVE_ASSETS (
    creative_id         VARCHAR(50) PRIMARY KEY,
    campaign_id         VARCHAR(50) REFERENCES DIM_CAMPAIGNS(campaign_id),
    creative_name       VARCHAR(200),
    creative_type       VARCHAR(50),   -- Video, Static Image, Interactive, Animation
    duration_seconds    INTEGER,
    file_format         VARCHAR(20),
    resolution          VARCHAR(20),
    has_audio           BOOLEAN,
    cta_type            VARCHAR(50),   -- QR Code, URL, Phone, None
    approval_status     VARCHAR(20),   -- Approved, Pending, Rejected
    created_date        DATE
);

SELECT 'Dimension tables created successfully!' AS status;

