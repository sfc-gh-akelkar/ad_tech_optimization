# 🔧 PatientPoint Predictive Device Maintenance

**AI-Powered IoT Device Maintenance for PatientPoint HealthScreens**

A Snowflake Cortex Agent demo for **Snowflake Intelligence** showcasing how AI can predict device failures, diagnose issues, and recommend fixes—reducing manual field dispatches.

---

## 🎯 Overview

PatientPoint operates **500,000 HealthScreen devices** across healthcare facilities nationwide. This demo demonstrates how Snowflake Intelligence and Cortex Agents enable:

- **Predictive failure detection** - 24-48 hour advance warning
- **Automated remote remediation** - 60%+ issues fixed without dispatch  
- **Cost optimization** - $96M annual savings projected

### The Challenge

| Pain Point | Impact |
|------------|--------|
| **High Costs** | Field technician dispatches cost $150-300+ per visit |
| **Lost Revenue** | Device downtime = lost advertising impressions |
| **Reactive Model** | Issues discovered after failure, not before |

### The Solution

| Capability | Technology |
|------------|------------|
| Natural language queries | Cortex Analyst + Semantic Views |
| Knowledge base search | Cortex Search |
| Automated actions | Custom stored procedures |
| Predictive analytics | ML-ready data foundation |

### Business Impact

| Metric | Value |
|--------|-------|
| Annual Cost Baseline | $185M (field dispatches) |
| Projected Savings | $96M (52% reduction) |
| Remote Fix Rate | 60%+ |
| Prediction Accuracy | >85% |

---

## 📁 Project Structure

```
ai_agent_device_maintenance/
├── setup/
│   ├── 01_create_database_and_data.sql    # Database, tables, sample data
│   ├── 02_create_semantic_views.sql       # Semantic views for Cortex Analyst
│   ├── 03_create_cortex_search.sql        # Knowledge base search services
│   ├── 04_create_agent.sql                # Agent configuration
│   └── 05_predictive_simulation.sql       # Predictive analytics views
├── DEMO_SCRIPT.md                         # 20-minute demo walkthrough
└── README.md                              # This file
```

---

## 🚀 Quick Start

### Prerequisites
- Snowflake account with **Cortex** access
- ACCOUNTADMIN role (for initial setup)
- The demo uses the `SF_INTELLIGENCE_DEMO` role (created automatically)

### Step 1: Run SQL Scripts

Execute in order in Snowsight:

```sql
-- 1. Create role, database, tables, and sample data
-- Run: setup/01_create_database_and_data.sql

-- 2. Create Snowflake Semantic Views
-- Run: setup/02_create_semantic_views.sql

-- 3. Create Cortex Search services
-- Run: setup/03_create_cortex_search.sql

-- 4. Create the agent
-- Run: setup/04_create_agent.sql

-- 5. Create predictive failure detection views
-- Run: setup/05_predictive_simulation.sql
```

### Step 2: Access via Snowflake Intelligence

1. Navigate to **AI & ML → Snowflake Intelligence**
2. Select **Device Maintenance Assistant**
3. Start asking questions!

---

## 🎬 Demo Script

For the complete **20-minute demo script** with talking points and prompts, see:

📄 **[DEMO_SCRIPT.md](DEMO_SCRIPT.md)**

### Key Personas

| Persona | Focus |
|---------|-------|
| Executive (C-Suite) | ROI, fleet health, revenue protection |
| Operations Center | Risk triage, predictions, dispatch decisions |
| Field Technician | Work orders, troubleshooting, repair guidance |

### Sample Prompts

```
# Executive
Give me a summary of our device fleet health and business impact
What's our annual field service cost and projected savings?

# Operations
Which devices have critical or high risk levels right now?
Can any of these be fixed remotely?

# Technician
What work orders are assigned to Marcus Johnson today?
What's wrong with device DEV-003 and how do I fix it?
```

---

## 📊 Data Model

### Tables

| Table | Records | Description |
|-------|---------|-------------|
| DEVICE_INVENTORY | 100 | Device master data |
| DEVICE_TELEMETRY | ~72,000 | Hourly health metrics |
| MAINTENANCE_HISTORY | 24 | Service tickets |
| TROUBLESHOOTING_KB | 10 | Fix procedures |
| WORK_ORDERS | 8 | Active work orders |
| TECHNICIANS | 6 | Field team |

### Key Views

| View | Purpose |
|------|---------|
| V_DEVICE_HEALTH_SUMMARY | Current health with risk scores |
| V_MAINTENANCE_ANALYTICS | Ticket analytics with cost savings |
| V_FAILURE_PREDICTIONS | AI-predicted failures |
| V_ROI_ANALYSIS | Cost baseline and savings |

### Agent Tools

| Tool | Type | Purpose |
|------|------|---------|
| DeviceFleetAnalytics | Cortex Analyst | Device health & telemetry |
| MaintenanceAnalytics | Cortex Analyst | Ticket history & costs |
| ROIAnalytics | Cortex Analyst | Annual costs & ROI |
| TroubleshootingGuide | Cortex Search | Fix procedures |
| PastIncidents | Cortex Search | Historical resolutions |
| SendDeviceCommand | Custom Procedure | Remote device commands |
| SendAlert | Custom Procedure | Slack/PagerDuty alerts |
| CreateServiceNowIncident | Custom Procedure | Work order creation |

---

## 🔮 Predictive Capabilities

### What We Prove

| Capability | How It's Demonstrated |
|------------|----------------------|
| Historical Data for ML | 30+ days of telemetry, maintenance history |
| Feature Engineering | Trend detection, spike flags, derived features |
| Prediction Accuracy | >85% detection rate on historical data |
| 24-48 Hour Lead Time | Advance warning before failures |

### Sample Queries

```sql
-- Devices predicted to fail within 48 hours
SELECT * FROM V_FAILURE_PREDICTIONS 
WHERE PREDICTED_HOURS_TO_FAILURE <= 48
ORDER BY FAILURE_PROBABILITY_PCT DESC;

-- Prediction accuracy analysis
SELECT * FROM V_PREDICTION_ACCURACY_ANALYSIS;
```

---

## 💰 Value Drivers

### Operational Cost Reduction

| Benefit | Impact |
|---------|--------|
| Reduced Downtime | Predict issues before they occur |
| Optimized Scheduling | Eliminate unnecessary maintenance |
| Lower Field Costs | Remote fixes vs $185/dispatch |

### Performance Improvements

| Metric | Value |
|--------|-------|
| Faster Insights | 10x faster than batch reporting |
| Query Accuracy | 90% with Cortex AI |
| Extended Asset Life | Proactive maintenance |

### Customer Success Examples

| Customer | Results |
|----------|---------|
| FIIX | 10x improvement in maintenance insights |
| Toyota | Extended equipment life, reduced disruptions |
| Telecom | Reduced field costs, improved SLA compliance |

---

## 📚 References

- [Cortex Agents Documentation](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents)
- [Snowflake Intelligence](https://docs.snowflake.com/en/user-guide/snowflake-cortex/snowflake-intelligence)
- [Best Practices for Building Cortex Agents](https://github.com/Snowflake-Labs/sfquickstarts/blob/master/site/sfguides/src/best-practices-to-building-cortex-agents/best-practices-to-building-cortex-agents.md)

---

**Built with ❄️ Snowflake Cortex**
