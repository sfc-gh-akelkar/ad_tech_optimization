# 🏥 PatientPoint Predictive Maintenance Demo

**AI Agents for Predictive Maintenance and Automated Fixes**

A Snowflake Cortex Agent demo for **Snowflake Intelligence** showcasing how AI can predict device failures, diagnose issues, and recommend fixes—reducing manual field dispatches.

---

## 🎯 Demo Overview

### The Challenge
PatientPoint operates **500,000 IoT devices**—HealthScreen displays—across hospitals and clinics nationwide. When devices fail:

| Pain Point | Impact |
|------------|--------|
| **High Costs** | Field technician dispatches cost $150-300+ per visit |
| **Patient Impact** | Screen downtime affects patient engagement |
| **Reactive Model** | Issues discovered only after failure, not before |

### The Solution
This demo showcases Snowflake's Cortex Agent capabilities via **Snowflake Intelligence**:

1. **Cortex Analyst** → Natural language queries over device health & maintenance data
2. **Cortex Search** → Semantic search over troubleshooting guides and past incidents
3. **Snowflake Intelligence** → Native chat interface for operations teams

### The Results
- **40-60% reduction** in field dispatches
- **80% faster** mean time to resolution  
- **$4,000+/month** in cost savings (demo scenario)

---

## 📁 Project Structure

```
ai_agent_device_maintenance/
├── setup/
│   ├── 01_create_database_and_data.sql    # Database, tables, sample data, work orders
│   ├── 02_create_semantic_views.sql       # Native Snowflake Semantic Views
│   ├── 03_create_cortex_search.sql        # Cortex Search services
│   ├── 04_create_agent.sql                # Agent setup & Snowflake Intelligence config
│   └── 05_predictive_simulation.sql       # Predictive failure detection & ML readiness
└── README.md                              # This file
```

---

## 🚀 Quick Start

### Prerequisites
- Snowflake account with **Cortex** access
- ACCOUNTADMIN role (for initial setup) or equivalent privileges
- The demo uses the `SF_INTELLIGENCE_DEMO` role (created automatically in script 01)

### Role Setup

The demo creates and uses a dedicated role `SF_INTELLIGENCE_DEMO` with the following privileges:

| Privilege | Purpose |
|-----------|---------|
| CREATE DATABASE | Create the PATIENTPOINT_MAINTENANCE database |
| CREATE WAREHOUSE | Create the COMPUTE_WH warehouse |
| SNOWFLAKE.CORTEX_USER | Access Cortex features (Search, Agents, Analyst) |
| Ownership of all demo objects | Full control over demo database, schema, tables, views |

> **Tip**: To grant the role to additional users:
> ```sql
> GRANT ROLE SF_INTELLIGENCE_DEMO TO USER <username>;
> ```

### Step 1: Run SQL Setup Scripts

Execute the SQL scripts **in order** in Snowsight:

```sql
-- 1. Create role, database, tables, and sample data
-- Run: setup/01_create_database_and_data.sql
-- NOTE: Start as ACCOUNTADMIN, script creates SF_INTELLIGENCE_DEMO role

-- 2. Create Snowflake Semantic Views for Cortex Analyst
-- Run: setup/02_create_semantic_views.sql

-- 3. Create Cortex Search services for knowledge base
-- Run: setup/03_create_cortex_search.sql

-- 4. Create the agent and configure for Snowflake Intelligence
-- Run: setup/04_create_agent.sql

-- 5. Create predictive failure detection views
-- Run: setup/05_predictive_simulation.sql
```

> **Note**: All scripts use the `SF_INTELLIGENCE_DEMO` role. The warehouse `COMPUTE_WH` is created automatically.

### Step 2: Create the Agent in Snowsight

1. Navigate to **AI & ML → Agents**
2. Click **Create agent**
3. Configure as follows:

| Field | Value |
|-------|-------|
| **Name** | `DEVICE_MAINTENANCE_AGENT` |
| **Display Name** | `Device Maintenance Assistant` |
| **Description** | I help you monitor and maintain PatientPoint HealthScreen devices. I can check device health, find troubleshooting procedures, and analyze maintenance trends. |

### Step 3: Add Tools to the Agent

#### Tool 1: Cortex Analyst (Structured Data)
| Setting | Value |
|---------|-------|
| **Name** | `DeviceAnalytics` |
| **Type** | Cortex Analyst |
| **Semantic View** | `PATIENTPOINT_MAINTENANCE.DEVICE_OPS.SV_DEVICE_MAINTENANCE` |
| **Warehouse** | Your warehouse |
| **Query Timeout** | 30 seconds |
| **Description** | Query device health metrics, maintenance history, fleet statistics, and cost analytics |

#### Tool 2: Cortex Search - Troubleshooting
| Setting | Value |
|---------|-------|
| **Name** | `TroubleshootingGuide` |
| **Type** | Cortex Search |
| **Service** | `PATIENTPOINT_MAINTENANCE.DEVICE_OPS.TROUBLESHOOTING_SEARCH_SVC` |
| **Max Results** | 5 |
| **Description** | Search troubleshooting procedures, diagnostic steps, and fix instructions |

#### Tool 3: Cortex Search - Past Incidents
| Setting | Value |
|---------|-------|
| **Name** | `PastIncidents` |
| **Type** | Cortex Search |
| **Service** | `PATIENTPOINT_MAINTENANCE.DEVICE_OPS.MAINTENANCE_HISTORY_SEARCH_SVC` |
| **Max Results** | 5 |
| **Description** | Search past maintenance tickets to find similar issues and proven solutions |

### Step 4: Configure Instructions

Add these **Response Instructions**:
```
You are the PatientPoint Device Maintenance Assistant. Your role is to help 
operations teams monitor, diagnose, and maintain HealthScreen devices 
deployed across healthcare facilities.

When responding:
- Be concise but thorough
- Include specific device IDs and metrics when available
- Recommend actions based on the data
- Prioritize remote fixes over field dispatches when possible
- Always explain your reasoning

For device health questions, use DeviceAnalytics to query current metrics.
For troubleshooting guidance, search TroubleshootingGuide for procedures.
For similar past issues, search PastIncidents for resolutions that worked.
```

### Step 5: Add Sample Questions

Add these starter questions:
- What is the current health status of our device fleet?
- Which devices need immediate attention?
- How do I fix a frozen display screen?
- How much money have we saved from remote fixes?

### Step 6: Access via Snowflake Intelligence

1. Navigate to **AI & ML → Snowflake Intelligence**
2. Select **Device Maintenance Assistant** from the agent dropdown
3. Start asking questions!

---

## 🎬 Demo Script

For the complete **20-minute demo script** with talking points, prompts, and persona-specific content, see:

📄 **[DEMO_SCRIPT.md](DEMO_SCRIPT.md)**

The demo covers 4 personas:
- 🎯 **Executive (C-Suite)** - KPIs, ROI, strategic metrics
- 🖥️ **Operations Center** - Fleet monitoring, predictions, dispatch
- 🔧 **Field Technician** - Work orders, troubleshooting, repair guidance
- 🤖 **AI Agent Demo** - Natural language, conversational AI

---

## 🔮 Predictive Failure Detection

The demo includes a **predictive simulation** that demonstrates how historical data enables failure prediction:

### What We Prove

| Capability | How It's Demonstrated |
|------------|----------------------|
| **Historical Data for ML** | `V_ML_TRAINING_DATA_SUMMARY` shows 30+ days of telemetry, maintenance history |
| **Feature Engineering** | `V_ML_FEATURE_EXAMPLES` shows trend detection, spike flags, derived features |
| **Labeled Training Data** | `V_LABELED_FAILURE_DATA` links telemetry patterns to actual failures |
| **Prediction Accuracy** | `V_PREDICTION_ACCURACY_ANALYSIS` shows >85% detection rate on historical data |
| **24-48 Hour Lead Time** | Predictions include `PREDICTED_HOURS_TO_FAILURE` with advance warning |

### Key Views

```sql
-- See devices predicted to fail within 48 hours
SELECT * FROM V_FAILURE_PREDICTIONS 
WHERE PREDICTED_HOURS_TO_FAILURE <= 48
ORDER BY FAILURE_PROBABILITY_PCT DESC;

-- Show prediction accuracy on historical failures
SELECT * FROM V_PREDICTION_ACCURACY_ANALYSIS;

-- Executive summary of predictive capabilities
SELECT * FROM V_PREDICTIVE_MAINTENANCE_SUMMARY;
```

### Sample Output: Predicted Failures

| Device | Facility | Failure Risk | Time to Failure | Risk Factor | Action |
|--------|----------|--------------|-----------------|-------------|--------|
| DEV-003 | North Shore Pediatrics | 78% | 12 hours | RISING_TEMPERATURE | URGENT: Clear cache, schedule maintenance |
| DEV-008 | Buckeye Family Medicine | 65% | 24 hours | MEMORY_LEAK_DETECTED | URGENT: Restart services |
| DEV-020 | Bloomington Urgent Care | 52% | 36 hours | ERROR_RATE_INCREASING | SOON: Schedule remote maintenance |

### Demo Prompts for Predictions

```
Which devices are predicted to fail in the next 48 hours?

What is our prediction accuracy based on historical data?

Show me the training data we have available for building ML models

What patterns appear before device failures?
```

---

## 📊 Data Model

### Tables Created

| Table | Description | Records |
|-------|-------------|---------|
| `DEVICE_INVENTORY` | Device master data | 100 devices |
| `DEVICE_TELEMETRY` | Hourly health metrics | ~72,000 records |
| `MAINTENANCE_HISTORY` | Service tickets | 15 records |
| `TROUBLESHOOTING_KB` | Fix procedures | 10 articles |

### Views for Analytics

| View | Purpose |
|------|---------|
| `V_DEVICE_HEALTH_SUMMARY` | Current health status with risk scores |
| `V_MAINTENANCE_ANALYTICS` | Ticket analytics with cost savings |
| `V_FLEET_SUMMARY` | Aggregate fleet statistics |

### Cortex Search Services

| Service | Indexed Content |
|---------|-----------------|
| `TROUBLESHOOTING_SEARCH_SVC` | Diagnostic procedures & fix steps |
| `MAINTENANCE_HISTORY_SEARCH_SVC` | Past incidents & resolutions |

---

## 🔧 Customization

### Add New Devices
```sql
INSERT INTO DEVICE_INVENTORY VALUES (
    'DEV-101', 
    'HealthScreen Pro 55', 
    'Your Facility Name',
    'Primary Care',
    'City', 'ST',
    '2024-01-01',
    '2027-01-01',
    '2024-06-01',
    'v3.2.1',
    'ONLINE'
);
```

### Add Knowledge Base Articles
```sql
INSERT INTO TROUBLESHOOTING_KB VALUES (
    'KB-011',
    'YOUR_ISSUE_TYPE',
    'Symptoms description...',
    'Diagnostic steps...',
    'Remote fix procedure...',
    FALSE,  -- requires_dispatch
    15,     -- estimated_fix_time_mins
    85.0,   -- success_rate_pct
    CURRENT_DATE()
);

-- Refresh the search index
-- (Automatic within TARGET_LAG window)
```

### Modify Agent Instructions
Update the agent configuration in **AI & ML → Agents** to customize:
- Response tone and style
- Priority of remote vs field fixes
- Additional business rules

---

## 📚 References

- [Cortex Agents Documentation](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents)
- [Snowflake Intelligence](https://docs.snowflake.com/en/user-guide/snowflake-cortex/snowflake-intelligence)
- [Best Practices for Building Cortex Agents](https://github.com/Snowflake-Labs/sfquickstarts/blob/master/site/sfguides/src/best-practices-to-building-cortex-agents/best-practices-to-building-cortex-agents.md)
- [Cortex Search Documentation](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-search)
- [Semantic Views](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-analyst/semantic-model)

---

**Built with ❄️ Snowflake Cortex**
