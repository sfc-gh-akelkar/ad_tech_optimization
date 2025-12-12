/*============================================================================
  Act 2 (Simulated ML): Anomaly Scoring + Ops Watchlist

  Approach:
  - NO model training / ML pipeline.
  - Compute explainable anomaly scores by comparing a device's recent behavior
    (scoring window) to its own historical baseline (baseline window).
  - Output domain scores + combined score + "why flagged".

  Windows (recommended):
  - Baseline: 14 days
  - Scoring:  1 day

  Data source:
  - PREDICTIVE_MAINTENANCE.ANALYTICS.V_DEVICE_TELEMETRY_DAILY (daily rollups)

  Run after:
  - sql/20_intelligence_semantic_layer.sql  (creates V_DEVICE_TELEMETRY_DAILY)

  What this creates:
  - OPERATIONS.ANOMALY_SCORES (history)
  - OPERATIONS.WATCHLIST_CURRENT (latest ranked)
  - OPERATIONS.REFRESH_WATCHLIST(mode, as_of_ts) procedure
============================================================================*/

USE ROLE SF_INTELLIGENCE_DEMO;

USE DATABASE PREDICTIVE_MAINTENANCE;
USE SCHEMA OPERATIONS;

CREATE OR REPLACE TABLE OPERATIONS.ANOMALY_SCORES (
  RUN_ID STRING,
  MODE STRING, -- LIVE_SCORING | SCENARIO_LOCK
  AS_OF_TS TIMESTAMP_NTZ,
  BASELINE_DAYS INT,
  SCORING_DAYS INT,

  DEVICE_ID STRING,

  SCORE_OVERALL FLOAT,
  SCORE_THERMAL FLOAT,
  SCORE_POWER FLOAT,
  SCORE_NETWORK FLOAT,
  SCORE_DISPLAY FLOAT,
  SCORE_STABILITY FLOAT,

  CONFIDENCE_BAND STRING, -- LOW | MEDIUM | HIGH
  WHY_FLAGGED STRING,
  TOP_SIGNALS VARIANT,

  BASELINE_START DATE,
  BASELINE_END DATE,
  SCORING_START DATE,
  SCORING_END DATE,

  CREATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE OPERATIONS.WATCHLIST_CURRENT (
  AS_OF_TS TIMESTAMP_NTZ,
  MODE STRING,
  RANK INT,
  DEVICE_ID STRING,
  SCORE_OVERALL FLOAT,
  SCORE_THERMAL FLOAT,
  SCORE_POWER FLOAT,
  SCORE_NETWORK FLOAT,
  SCORE_DISPLAY FLOAT,
  SCORE_STABILITY FLOAT,
  CONFIDENCE_BAND STRING,
  WHY_FLAGGED STRING,
  TOP_SIGNALS VARIANT,
  LAST_REFRESHED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE PROCEDURE OPERATIONS.REFRESH_WATCHLIST(
  MODE STRING DEFAULT 'LIVE_SCORING',
  AS_OF_TS TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
  BASELINE_DAYS INT DEFAULT 14,
  SCORING_DAYS INT DEFAULT 1,
  TOP_N INT DEFAULT 25
)
RETURNS STRING
LANGUAGE SQL
AS
$$
DECLARE
  run_id STRING DEFAULT UUID_STRING();
BEGIN
  -- Define date windows
  LET scoring_end DATE := TO_DATE(AS_OF_TS);
  LET scoring_start DATE := DATEADD('day', -SCORING_DAYS, scoring_end);
  LET baseline_end DATE := scoring_start;
  LET baseline_start DATE := DATEADD('day', -BASELINE_DAYS, baseline_end);

  -- If scenario lock, prioritize scenario devices (deterministic demo)
  LET scenario_list ARRAY := ARRAY_CONSTRUCT('4532','4512','4523','7821','4545','4556');

  -- Build per-device baseline stats and scoring window stats from daily rollups.
  -- Baseline excludes scoring window to avoid leakage.
  CREATE OR REPLACE TEMP TABLE _baseline AS
  SELECT
    DEVICE_ID,
    AVG(AVG_TEMPERATURE_F) AS BL_TEMP_MEAN,
    NULLIF(STDDEV_SAMP(AVG_TEMPERATURE_F), 0) AS BL_TEMP_STD,
    AVG(AVG_POWER_W) AS BL_POWER_MEAN,
    NULLIF(STDDEV_SAMP(AVG_POWER_W), 0) AS BL_POWER_STD,
    AVG(AVG_LATENCY_MS) AS BL_LAT_MEAN,
    NULLIF(STDDEV_SAMP(AVG_LATENCY_MS), 0) AS BL_LAT_STD,
    AVG(AVG_PACKET_LOSS_PCT) AS BL_LOSS_MEAN,
    NULLIF(STDDEV_SAMP(AVG_PACKET_LOSS_PCT), 0) AS BL_LOSS_STD,
    AVG(AVG_BRIGHTNESS) AS BL_BRIGHT_MEAN,
    NULLIF(STDDEV_SAMP(AVG_BRIGHTNESS), 0) AS BL_BRIGHT_STD,
    AVG(TOTAL_ERRORS) AS BL_ERR_MEAN,
    NULLIF(STDDEV_SAMP(TOTAL_ERRORS), 0) AS BL_ERR_STD
  FROM PREDICTIVE_MAINTENANCE.ANALYTICS.V_DEVICE_TELEMETRY_DAILY
  WHERE DAY >= :baseline_start AND DAY < :baseline_end
  GROUP BY DEVICE_ID;

  CREATE OR REPLACE TEMP TABLE _scorewin AS
  SELECT
    DEVICE_ID,
    AVG(AVG_TEMPERATURE_F) AS SC_TEMP,
    MAX(MAX_TEMPERATURE_F) AS SC_TEMP_MAX,
    AVG(AVG_POWER_W) AS SC_POWER,
    MAX(MAX_POWER_W) AS SC_POWER_MAX,
    AVG(AVG_LATENCY_MS) AS SC_LAT,
    MAX(MAX_LATENCY_MS) AS SC_LAT_MAX,
    AVG(AVG_PACKET_LOSS_PCT) AS SC_LOSS,
    MAX(MAX_PACKET_LOSS_PCT) AS SC_LOSS_MAX,
    AVG(AVG_BRIGHTNESS) AS SC_BRIGHT,
    SUM(TOTAL_ERRORS) AS SC_ERRORS,
    AVG(AVG_CPU_PCT) AS SC_CPU,
    AVG(AVG_MEM_PCT) AS SC_MEM
  FROM PREDICTIVE_MAINTENANCE.ANALYTICS.V_DEVICE_TELEMETRY_DAILY
  WHERE DAY >= :scoring_start AND DAY < :scoring_end
  GROUP BY DEVICE_ID;

  -- Join baseline and scoring window. Compute z-scores and domain scores.
  CREATE OR REPLACE TEMP TABLE _scored AS
  WITH joined AS (
    SELECT
      s.DEVICE_ID,
      b.*,
      s.SC_TEMP,
      s.SC_TEMP_MAX,
      s.SC_POWER,
      s.SC_POWER_MAX,
      s.SC_LAT,
      s.SC_LAT_MAX,
      s.SC_LOSS,
      s.SC_LOSS_MAX,
      s.SC_BRIGHT,
      s.SC_ERRORS,
      s.SC_CPU,
      s.SC_MEM
    FROM _scorewin s
    LEFT JOIN _baseline b ON s.DEVICE_ID = b.DEVICE_ID
  ),
  z AS (
    SELECT
      DEVICE_ID,
      -- z-scores (NULL when baseline std missing)
      (SC_TEMP - BL_TEMP_MEAN) / BL_TEMP_STD AS Z_TEMP,
      (SC_POWER - BL_POWER_MEAN) / BL_POWER_STD AS Z_POWER,
      (SC_LAT - BL_LAT_MEAN) / BL_LAT_STD AS Z_LAT,
      (SC_LOSS - BL_LOSS_MEAN) / BL_LOSS_STD AS Z_LOSS,
      (BL_BRIGHT_MEAN - SC_BRIGHT) / BL_BRIGHT_STD AS Z_BRIGHT_DROP,
      (SC_ERRORS - (BL_ERR_MEAN * :SCORING_DAYS)) / BL_ERR_STD AS Z_ERR,

      -- raw deltas for explainability
      SC_TEMP, BL_TEMP_MEAN,
      SC_POWER, BL_POWER_MEAN,
      SC_LAT, BL_LAT_MEAN,
      SC_LOSS, BL_LOSS_MEAN,
      SC_BRIGHT, BL_BRIGHT_MEAN,
      SC_ERRORS,
      SC_TEMP_MAX,
      SC_POWER_MAX,
      SC_LAT_MAX,
      SC_LOSS_MAX,
      SC_CPU,
      SC_MEM
    FROM joined
  ),
  scores AS (
    SELECT
      DEVICE_ID,
      -- Domain scores: clamp(|z|/4) into [0,1]. (z~4 => 1.0)
      LEAST(1.0, GREATEST(0.0, ABS(Z_TEMP) / 4.0)) AS SCORE_THERMAL,
      LEAST(1.0, GREATEST(0.0, ABS(Z_POWER) / 4.0)) AS SCORE_POWER,
      LEAST(1.0, GREATEST(0.0, GREATEST(ABS(Z_LAT), ABS(Z_LOSS)) / 4.0)) AS SCORE_NETWORK,
      LEAST(1.0, GREATEST(0.0, ABS(Z_BRIGHT_DROP) / 4.0)) AS SCORE_DISPLAY,
      LEAST(1.0, GREATEST(0.0, ABS(Z_ERR) / 4.0)) AS SCORE_STABILITY,

      -- keep raw fields for top_signals
      Z_TEMP, Z_POWER, Z_LAT, Z_LOSS, Z_BRIGHT_DROP, Z_ERR,
      SC_TEMP, BL_TEMP_MEAN,
      SC_POWER, BL_POWER_MEAN,
      SC_LAT, BL_LAT_MEAN,
      SC_LOSS, BL_LOSS_MEAN,
      SC_BRIGHT, BL_BRIGHT_MEAN,
      SC_ERRORS,
      SC_TEMP_MAX,
      SC_POWER_MAX,
      SC_LAT_MAX,
      SC_LOSS_MAX,
      SC_CPU,
      SC_MEM
    FROM z
  ),
  combined AS (
    SELECT
      *,
      -- Weighted overall score (ops-friendly: network/display weighted as high as thermal/power)
      LEAST(1.0, GREATEST(0.0,
        0.22*SCORE_THERMAL +
        0.22*SCORE_POWER +
        0.22*SCORE_NETWORK +
        0.18*SCORE_DISPLAY +
        0.16*SCORE_STABILITY
      )) AS SCORE_OVERALL
    FROM scores
  )
  SELECT
    DEVICE_ID,
    SCORE_OVERALL,
    SCORE_THERMAL,
    SCORE_POWER,
    SCORE_NETWORK,
    SCORE_DISPLAY,
    SCORE_STABILITY,
    CASE
      WHEN SCORE_OVERALL >= 0.85 THEN 'HIGH'
      WHEN SCORE_OVERALL >= 0.65 THEN 'MEDIUM'
      WHEN SCORE_OVERALL >= 0.45 THEN 'LOW'
      ELSE 'NONE'
    END AS CONFIDENCE_BAND,
    -- Simple "why" string based on top 2 domain contributors
    CONCAT(
      'Top domains: ',
      IFF(SCORE_NETWORK >= GREATEST(SCORE_THERMAL, SCORE_POWER, SCORE_DISPLAY, SCORE_STABILITY), 'NETWORK', ''),
      IFF(SCORE_THERMAL >= GREATEST(SCORE_NETWORK, SCORE_POWER, SCORE_DISPLAY, SCORE_STABILITY), 'THERMAL', ''),
      IFF(SCORE_POWER >= GREATEST(SCORE_NETWORK, SCORE_THERMAL, SCORE_DISPLAY, SCORE_STABILITY), 'POWER', ''),
      IFF(SCORE_DISPLAY >= GREATEST(SCORE_NETWORK, SCORE_THERMAL, SCORE_POWER, SCORE_STABILITY), 'DISPLAY', ''),
      IFF(SCORE_STABILITY >= GREATEST(SCORE_NETWORK, SCORE_THERMAL, SCORE_POWER, SCORE_DISPLAY), 'STABILITY', '')
    ) AS WHY_FLAGGED,
    OBJECT_CONSTRUCT(
      'z_temp', Z_TEMP,
      'z_power', Z_POWER,
      'z_latency', Z_LAT,
      'z_packet_loss', Z_LOSS,
      'z_brightness_drop', Z_BRIGHT_DROP,
      'z_errors', Z_ERR,
      'sc_temp', SC_TEMP,
      'bl_temp_mean', BL_TEMP_MEAN,
      'sc_power', SC_POWER,
      'bl_power_mean', BL_POWER_MEAN,
      'sc_latency', SC_LAT,
      'bl_latency_mean', BL_LAT_MEAN,
      'sc_packet_loss', SC_LOSS,
      'bl_packet_loss_mean', BL_LOSS_MEAN,
      'sc_brightness', SC_BRIGHT,
      'bl_brightness_mean', BL_BRIGHT_MEAN,
      'sc_errors', SC_ERRORS,
      'sc_temp_max', SC_TEMP_MAX,
      'sc_power_max', SC_POWER_MAX,
      'sc_latency_max', SC_LAT_MAX,
      'sc_packet_loss_max', SC_LOSS_MAX,
      'sc_cpu', SC_CPU,
      'sc_mem', SC_MEM
    ) AS TOP_SIGNALS
  FROM combined;

  -- In scenario lock mode, ensure scenario devices are included even if scoring is low.
  CREATE OR REPLACE TEMP TABLE _final AS
  SELECT *
  FROM _scored
  WHERE CONFIDENCE_BAND <> 'NONE'
  QUALIFY ROW_NUMBER() OVER (ORDER BY SCORE_OVERALL DESC) <= :TOP_N
  UNION ALL
  SELECT *
  FROM _scored
  WHERE :MODE = 'SCENARIO_LOCK'
    AND DEVICE_ID IN (SELECT VALUE::STRING FROM TABLE(FLATTEN(input => scenario_list)));

  -- Insert into history table
  INSERT INTO OPERATIONS.ANOMALY_SCORES (
    RUN_ID, MODE, AS_OF_TS, BASELINE_DAYS, SCORING_DAYS,
    DEVICE_ID,
    SCORE_OVERALL, SCORE_THERMAL, SCORE_POWER, SCORE_NETWORK, SCORE_DISPLAY, SCORE_STABILITY,
    CONFIDENCE_BAND, WHY_FLAGGED, TOP_SIGNALS,
    BASELINE_START, BASELINE_END, SCORING_START, SCORING_END
  )
  SELECT
    :run_id, :MODE, :AS_OF_TS, :BASELINE_DAYS, :SCORING_DAYS,
    DEVICE_ID,
    SCORE_OVERALL, SCORE_THERMAL, SCORE_POWER, SCORE_NETWORK, SCORE_DISPLAY, SCORE_STABILITY,
    CONFIDENCE_BAND, WHY_FLAGGED, TOP_SIGNALS,
    :baseline_start, :baseline_end, :scoring_start, :scoring_end
  FROM _final;

  -- Refresh current watchlist (replace)
  DELETE FROM OPERATIONS.WATCHLIST_CURRENT;

  INSERT INTO OPERATIONS.WATCHLIST_CURRENT (
    AS_OF_TS, MODE, RANK, DEVICE_ID,
    SCORE_OVERALL, SCORE_THERMAL, SCORE_POWER, SCORE_NETWORK, SCORE_DISPLAY, SCORE_STABILITY,
    CONFIDENCE_BAND, WHY_FLAGGED, TOP_SIGNALS
  )
  SELECT
    :AS_OF_TS,
    :MODE,
    ROW_NUMBER() OVER (ORDER BY SCORE_OVERALL DESC) AS RANK,
    DEVICE_ID,
    SCORE_OVERALL, SCORE_THERMAL, SCORE_POWER, SCORE_NETWORK, SCORE_DISPLAY, SCORE_STABILITY,
    CONFIDENCE_BAND, WHY_FLAGGED, TOP_SIGNALS
  FROM _final
  QUALIFY ROW_NUMBER() OVER (ORDER BY SCORE_OVERALL DESC) <= :TOP_N;

  RETURN 'Watchlist refreshed ✅ run_id=' || run_id || ', mode=' || MODE || ', as_of=' || AS_OF_TS;
END;
$$;

-- Convenience: run once (live scoring) and preview current watchlist
CALL OPERATIONS.REFRESH_WATCHLIST('LIVE_SCORING', CURRENT_TIMESTAMP(), 14, 1, 25);

SELECT * FROM OPERATIONS.WATCHLIST_CURRENT ORDER BY RANK;


