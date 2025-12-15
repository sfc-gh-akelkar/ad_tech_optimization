# 🏥 PatientPoint Ad Tech Optimization Demo

AI-powered healthcare advertising optimization platform built on **Snowflake Intelligence** and **Cortex Agents**.

## 🎯 Overview

This demo showcases how PatientPoint can leverage Snowflake's AI/ML capabilities to optimize pharmaceutical advertising campaigns across medical facilities while maintaining strict HIPAA compliance.

### Key Capabilities Demonstrated

| Capability | Snowflake Feature | Use Case |
|------------|-------------------|----------|
| **Natural Language Analytics** | Cortex Agents | Ask questions about campaigns in plain English |
| **Semantic Search** | Cortex Search | Discover inventory and audiences using natural language |
| **Text-to-SQL** | Cortex Analyst + Semantic Views | Query structured data without writing SQL |
| **Automated Visualization** | Data to Chart | Generate charts from query results |

## 📁 Repository Structure

```
ad_tech_optimization/
├── README.md
│
├── setup/                           # 5 scripts, run in ~2 minutes
│   ├── 01_database_setup.sql        # Database, schemas, roles
│   ├── 02_demo_data.sql             # Pre-computed flat tables (NO JOINS!)
│   ├── 03_cortex_search.sql         # 3 Cortex Search services
│   ├── 04_semantic_views.sql        # 3 Semantic Views for Cortex Analyst
│   └── 05_cortex_agent.sql          # Campaign Optimizer Agent
│
├── demo/                            # Demo resources
│   └── executive_demo_script.md     # C-suite presentation script
│
└── streamlit/                       # Streamlit in Snowflake app
    ├── environment.yml
    ├── Home.py
    └── pages/
        ├── 1_Campaign_Optimizer.py
        ├── 2_Inventory_Explorer.py
        └── 3_Agent_Chat.py
```

## 🚀 Quick Start (~2 minutes)

### Prerequisites

- Snowflake account with Cortex features enabled
- ACCOUNTADMIN or appropriate role to create objects

### Installation Steps

Run these 5 scripts in order in Snowsight:

```sql
-- Step 1: Database & Infrastructure (~10 sec)
-- Execute: setup/01_database_setup.sql

-- Step 2: Pre-computed Demo Data (~30 sec)
-- Execute: setup/02_demo_data.sql

-- Step 3: Cortex Search Services (~30 sec)  
-- Execute: setup/03_cortex_search.sql

-- Step 4: Semantic Views (~10 sec)
-- Execute: setup/04_semantic_views.sql

-- Step 5: Cortex Agent (~10 sec)
-- Execute: setup/05_cortex_agent.sql
```

### Verify Setup

```sql
USE ROLE SF_INTELLIGENCE_DEMO;
USE DATABASE AD_TECH;

-- Check tables (should show 100, 200, 100 rows)
SELECT 'T_CAMPAIGN_PERFORMANCE' AS t, COUNT(*) FROM ANALYTICS.T_CAMPAIGN_PERFORMANCE
UNION ALL SELECT 'T_INVENTORY_ANALYTICS', COUNT(*) FROM ANALYTICS.T_INVENTORY_ANALYTICS  
UNION ALL SELECT 'T_AUDIENCE_INSIGHTS', COUNT(*) FROM ANALYTICS.T_AUDIENCE_INSIGHTS;

-- Check Cortex services (3 search services)
SHOW CORTEX SEARCH SERVICES IN SCHEMA CORTEX;

-- Check Semantic views (3 views)
SHOW SEMANTIC VIEWS IN SCHEMA CORTEX;

-- Check Agent (1 agent)
SHOW AGENTS IN SCHEMA CORTEX;
```

## 📊 Data Model

This demo uses **pre-computed flat tables** - no joins required at runtime!

| Table | Description | Rows |
|-------|-------------|------|
| `T_CAMPAIGN_PERFORMANCE` | Campaign metrics with partner info | 100 |
| `T_INVENTORY_ANALYTICS` | Inventory slots with performance | 200 |
| `T_AUDIENCE_INSIGHTS` | Privacy-safe audience cohorts | 100 |

**All dates are relative to `CURRENT_DATE`** - the demo always has fresh, relevant data.

---

## 🏗️ Source Systems & Data Lineage

In production, these tables would be populated from multiple source systems across PatientPoint's infrastructure:

### T_CAMPAIGN_PERFORMANCE
*Campaign performance metrics aggregated from ad serving and analytics systems*

| Data Element | Source System | Description |
|--------------|---------------|-------------|
| Campaign metadata | **Salesforce CRM** | Partner info, contract terms, campaign setup |
| Bid data | **Real-time Bidding (RTB) Platform** | Bid requests, responses, win/loss tracking |
| Impressions | **Ad Server (GAM/DFP)** | Delivered impressions, viewability, completion |
| Engagements | **Analytics Platform** | Clicks, interactions, dwell time |
| Conversions | **Attribution System** | Appointment bookings, Rx lift studies |
| Revenue | **Billing/Finance System** | Invoiced amounts, CPM rates |

### T_INVENTORY_ANALYTICS
*Ad placement inventory across PatientPoint's network of medical facilities*

| Data Element | Source System | Description |
|--------------|---------------|-------------|
| Facility data | **Location Management System** | Hospitals, clinics, medical centers |
| Screen inventory | **Device Management (MDM)** | Digital displays, tablets, kiosks |
| Specialty mapping | **Provider Database** | Medical specialty classifications |
| Patient volume | **EHR Integration / Foot Traffic** | De-identified visit counts (aggregated) |
| Performance metrics | **Ad Server + Analytics** | Fill rates, CPMs, viewability |
| Geographic data | **GIS / DMA Mapping** | Region, market, demographic indices |

### T_AUDIENCE_INSIGHTS
*Privacy-safe audience cohorts for targeting (HIPAA compliant)*

| Data Element | Source System | Description |
|--------------|---------------|-------------|
| Demographic cohorts | **Data Clean Room** | Age, gender, region (aggregated, k=50+) |
| Health interests | **Anonymized Engagement Data** | Content interaction patterns |
| Insurance segments | **Claims Data Partner** | Payer mix (aggregated) |
| Engagement scores | **Analytics Platform** | Historical response rates by cohort |
| Therapeutic affinity | **Content Analytics** | Health topic engagement |

### Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         SOURCE SYSTEMS                                   │
├─────────────┬─────────────┬─────────────┬─────────────┬─────────────────┤
│  Salesforce │  RTB/SSP    │  Ad Server  │  Analytics  │  Data Clean     │
│  CRM        │  Platform   │  (GAM)      │  Platform   │  Room           │
└──────┬──────┴──────┬──────┴──────┬──────┴──────┬──────┴────────┬────────┘
       │             │             │             │               │
       ▼             ▼             ▼             ▼               ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         SNOWFLAKE DATA CLOUD                             │
│  ┌───────────────────────────────────────────────────────────────────┐  │
│  │  BRONZE LAYER (Raw)                                                │  │
│  │  - Raw events, logs, API responses                                 │  │
│  └───────────────────────────────────────────────────────────────────┘  │
│                              │                                           │
│                              ▼                                           │
│  ┌───────────────────────────────────────────────────────────────────┐  │
│  │  SILVER LAYER (Cleansed)                                          │  │
│  │  - Validated, deduplicated, conformed                             │  │
│  └───────────────────────────────────────────────────────────────────┘  │
│                              │                                           │
│                              ▼                                           │
│  ┌───────────────────────────────────────────────────────────────────┐  │
│  │  GOLD LAYER (Business-Ready) ← THIS DEMO                          │  │
│  │  - T_CAMPAIGN_PERFORMANCE                                         │  │
│  │  - T_INVENTORY_ANALYTICS                                          │  │
│  │  - T_AUDIENCE_INSIGHTS                                            │  │
│  └───────────────────────────────────────────────────────────────────┘  │
│                              │                                           │
│                              ▼                                           │
│  ┌───────────────────────────────────────────────────────────────────┐  │
│  │  AI/ML LAYER (Cortex)                                             │  │
│  │  - Semantic Views → Cortex Analyst                                │  │
│  │  - Search Services → Cortex Search                                │  │
│  │  - Campaign Optimizer Agent                                       │  │
│  └───────────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────────┘
```

### Key Integration Points

| Integration | Technology | Use Case |
|-------------|------------|----------|
| **CRM → Snowflake** | Fivetran / Airbyte | Partner & campaign sync |
| **RTB Platform → Snowflake** | Kafka / Snowpipe | Real-time bid streaming |
| **Ad Server → Snowflake** | API / S3 | Impression & event logs |
| **Data Clean Room** | Snowflake DCR | Privacy-safe audience sharing |
| **BI/Analytics** | Tableau / Streamlit | Dashboards & self-service |

## 🎬 Demo Questions (C-Suite)

### Question 1: Portfolio Performance
> "What are our top 5 performing campaigns by ROAS, and what do they have in common?"

### Question 2: Revenue Optimization
> "Which inventory slots are underperforming relative to their potential?"

### Question 3: Partner Analysis
> "Compare our Platinum tier partners' campaign performance"

### Question 4: Audience Targeting
> "For a new diabetes medication targeting adults 45-65, which audience cohorts should we prioritize?"

### Question 5: Operational Efficiency
> "What patterns do you see in our bidding performance across dayparts and regions?"

See `demo/executive_demo_script.md` for the full presentation script.

## 🤖 Cortex Agent Tools

The Campaign Optimizer Agent includes 7 integrated tools:

| Tool | Type | Purpose |
|------|------|---------|
| `CampaignAnalyst` | Cortex Analyst | Query campaign performance metrics |
| `InventoryAnalyst` | Cortex Analyst | Analyze ad slot performance |
| `AudienceAnalyst` | Cortex Analyst | Cohort engagement analytics |
| `InventorySearch` | Cortex Search | Natural language inventory discovery |
| `CampaignSearch` | Cortex Search | Search campaign history |
| `AudienceSearch` | Cortex Search | Find target audience segments |
| `DataToChart` | Data to Chart | Generate visualizations |

### Example Agent Prompts

```
"What's the optimal bid price for diabetes campaigns in cardiology?"
"Find premium morning slots in Texas endocrinology clinics"
"Compare Pfizer vs Eli Lilly campaign performance"
"Which audiences have highest engagement for heart medications?"
"Show me ROAS trends by therapeutic area"
```

## 🔒 Privacy & Compliance

This demo implements healthcare privacy best practices:

- ✅ **Synthetic Data**: All data is generated, not real
- ✅ **K-Anonymity**: Minimum cohort size of 50 enforced
- ✅ **No PII**: No individual patient identifiers
- ✅ **Aggregate Only**: All analytics at cohort level
- ✅ **HIPAA-Ready**: Architecture supports compliance requirements

## 🛠️ Technical Requirements

### Snowflake Features Required

- Cortex Agents
- Cortex Search
- Cortex Analyst + Semantic Views
- Streamlit in Snowflake (optional)

### Recommended Warehouse Size

- Demo: MEDIUM (cost-optimized)
- Production: LARGE or X-LARGE

## 📚 Resources

- [Cortex Agents Documentation](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents-manage)
- [Cortex Search Documentation](https://docs.snowflake.com/en/user-guide/cortex-search)
- [Semantic Views Documentation](https://docs.snowflake.com/en/user-guide/views-semantic/overview)

---

Built with ❄️ **Snowflake Intelligence**
