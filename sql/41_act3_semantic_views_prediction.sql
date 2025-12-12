/*============================================================================
  Act 3 (Snowflake Intelligence): Semantic Views for Failure Predictions + Accuracy
============================================================================*/

USE ROLE SF_INTELLIGENCE_DEMO;

USE DATABASE PREDICTIVE_MAINTENANCE;
USE SCHEMA ANALYTICS;

CREATE OR REPLACE SEMANTIC VIEW SV_FAILURE_PREDICTIONS
  TABLES (
    preds AS PREDICTIVE_MAINTENANCE.ANALYTICS.V_FAILURE_PREDICTIONS_CURRENT
      PRIMARY KEY (DEVICE_ID, HORIZON_HOURS)
      WITH SYNONYMS = ('predictions', 'failure predictions', '24-48 hour predictions')
      COMMENT = 'Latest failure predictions per device (simulated).'
  )
  DIMENSIONS (
    preds.device_id AS preds.DEVICE_ID WITH SYNONYMS = ('device', 'screen', 'screen id'),
    preds.horizon_hours AS preds.HORIZON_HOURS WITH SYNONYMS = ('horizon', 'hours'),
    preds.predicted_failure_type AS preds.PREDICTED_FAILURE_TYPE WITH SYNONYMS = ('failure type', 'predicted failure'),
    preds.confidence_band AS preds.CONFIDENCE_BAND WITH SYNONYMS = ('confidence', 'risk band'),
    preds.mode AS preds.MODE
  )
  METRICS (
    preds.prediction_probability AS MAX(preds.PREDICTION_PROBABILITY) COMMENT = 'Prediction probability (0–1).'
  )
  COMMENT = 'Act 3 semantic view: simulated 24–48h failure predictions.'
  COPY GRANTS;

CREATE OR REPLACE SEMANTIC VIEW SV_PREDICTION_ACCURACY
  TABLES (
    eval AS PREDICTIVE_MAINTENANCE.OPERATIONS.PREDICTION_EVAL_RUNS
      PRIMARY KEY (RUN_ID)
      WITH SYNONYMS = ('prediction accuracy', 'model accuracy', 'eval')
      COMMENT = 'Prediction evaluation runs (demo accuracy vs scenario incidents).'
  )
  DIMENSIONS (
    eval.run_id AS eval.RUN_ID,
    eval.mode AS eval.MODE,
    eval.horizon_hours AS eval.HORIZON_HOURS
  )
  METRICS (
    eval.precision AS MAX(eval.PRECISION),
    eval.recall AS MAX(eval.RECALL),
    eval.f1 AS MAX(eval.F1),
    eval.predictions AS MAX(eval.PREDICTIONS),
    eval.actual_incidents AS MAX(eval.ACTUAL_INCIDENTS),
    eval.true_positives AS MAX(eval.TRUE_POSITIVES),
    eval.false_positives AS MAX(eval.FALSE_POSITIVES),
    eval.false_negatives AS MAX(eval.FALSE_NEGATIVES)
  )
  COMMENT = 'Act 3 semantic view: demo prediction accuracy metrics (not production accuracy).'
  COPY GRANTS;


