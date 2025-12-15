/*
=============================================================================
PatientPoint Ad Tech Optimization Demo - Fact Tables
=============================================================================
Creates fact tables for bid events, impressions, and engagements.
All tables are created with SF_INTELLIGENCE_DEMO role.
=============================================================================
*/

USE ROLE SF_INTELLIGENCE_DEMO;
USE DATABASE AD_TECH;
USE SCHEMA ANALYTICS;
USE WAREHOUSE AD_TECH_WH;

-- ============================================================================
-- FACT_BIDS - Bid Request/Response Events
-- ============================================================================
CREATE OR REPLACE TABLE FACT_BIDS (
    bid_id              VARCHAR(50) PRIMARY KEY,
    bid_timestamp       TIMESTAMP_NTZ NOT NULL,
    date_key            INTEGER,
    slot_id             VARCHAR(50),
    campaign_id         VARCHAR(50),
    partner_id          INTEGER,
    cohort_id           VARCHAR(50),
    
    -- Bid details
    bid_amount          FLOAT,         -- Our bid price (CPM)
    floor_price         FLOAT,         -- Minimum acceptable price
    competitor_bid      FLOAT,         -- Estimated competitor bid
    win_flag            BOOLEAN,       -- Did we win the auction?
    
    -- Performance metrics
    latency_ms          INTEGER,       -- Response time in milliseconds
    bid_source          VARCHAR(50),   -- Algorithm version or source
    
    -- Context
    daypart             VARCHAR(20),
    device_type         VARCHAR(50),
    
    -- Timestamps
    created_at          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- FACT_IMPRESSIONS - Delivered Ad Impressions
-- ============================================================================
CREATE OR REPLACE TABLE FACT_IMPRESSIONS (
    impression_id       VARCHAR(50) PRIMARY KEY,
    impression_timestamp TIMESTAMP_NTZ NOT NULL,
    date_key            INTEGER,
    
    -- Foreign keys
    slot_id             VARCHAR(50),
    campaign_id         VARCHAR(50),
    partner_id          INTEGER,
    creative_id         VARCHAR(50),
    cohort_id           VARCHAR(50),
    bid_id              VARCHAR(50),   -- Link to winning bid
    
    -- Impression metrics
    duration_viewed     INTEGER,       -- Seconds actually viewed
    completion_rate     FLOAT,         -- % of ad completed (0-1)
    viewability_score   FLOAT,         -- Viewability metric (0-1)
    
    -- Context
    daypart             VARCHAR(20),
    is_first_exposure   BOOLEAN,       -- First time this cohort saw this campaign
    exposure_count      INTEGER,       -- Total exposures for this cohort/campaign
    
    -- Cost
    actual_cpm          FLOAT,         -- Actual CPM paid
    revenue             FLOAT,         -- Revenue from this impression
    
    -- Timestamps
    created_at          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- FACT_ENGAGEMENTS - User Interactions with Ads
-- ============================================================================
CREATE OR REPLACE TABLE FACT_ENGAGEMENTS (
    engagement_id       VARCHAR(50) PRIMARY KEY,
    engagement_timestamp TIMESTAMP_NTZ NOT NULL,
    date_key            INTEGER,
    
    -- Foreign keys
    impression_id       VARCHAR(50),
    slot_id             VARCHAR(50),
    campaign_id         VARCHAR(50),
    partner_id          INTEGER,
    cohort_id           VARCHAR(50),
    
    -- Engagement details
    engagement_type     VARCHAR(50),   -- QR Scan, Touch, Dwell, Click
    dwell_time_seconds  INTEGER,       -- Time spent engaging
    action_taken        VARCHAR(100),  -- Specific action (e.g., "Scanned QR", "Requested Info")
    conversion_flag     BOOLEAN,       -- Did this lead to a conversion?
    conversion_type     VARCHAR(50),   -- Type of conversion if applicable
    
    -- Attribution
    attribution_weight  FLOAT,         -- Multi-touch attribution weight
    is_last_touch       BOOLEAN,       -- Last touch before conversion
    
    -- Timestamps
    created_at          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- FACT_APPOINTMENTS - Patient Visit Context (Anonymized)
-- ============================================================================
CREATE OR REPLACE TABLE FACT_APPOINTMENTS (
    appointment_id      VARCHAR(50) PRIMARY KEY,
    appointment_date    DATE NOT NULL,
    date_key            INTEGER,
    
    -- Location context (no patient identifiers)
    location_id         INTEGER,
    specialty_id        INTEGER,
    cohort_id           VARCHAR(50),   -- Aggregated cohort, not individual
    
    -- Timing (for daypart analysis)
    hour_of_day         INTEGER,
    daypart             VARCHAR(20),
    day_of_week         INTEGER,
    
    -- Duration metrics
    scheduled_duration  INTEGER,       -- minutes
    actual_wait_time    INTEGER,       -- minutes in waiting room
    
    -- Volume (aggregated, not individual)
    appointment_count   INTEGER,       -- Count for this cohort/time
    
    -- Timestamps
    created_at          TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

-- ============================================================================
-- Create indexes for performance
-- ============================================================================

-- Clustering keys for large fact tables
ALTER TABLE FACT_BIDS CLUSTER BY (date_key, campaign_id);
ALTER TABLE FACT_IMPRESSIONS CLUSTER BY (date_key, campaign_id);
ALTER TABLE FACT_ENGAGEMENTS CLUSTER BY (date_key, campaign_id);

SELECT 'Fact tables created successfully!' AS status;

