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
| **Interactive Dashboards** | Streamlit in Snowflake | Self-service analytics UI |

## 📁 Repository Structure

```
ad_tech_optimization/
├── README.md
│
├── setup/                              # All setup scripts in sequential order
│   ├── 00_run_all.sql                  # Master guide with execution order
│   ├── 01_database_setup.sql           # Database, schemas, warehouses, roles
│   ├── 02_dimension_tables.sql         # Dimension table DDL
│   ├── 03_fact_tables.sql              # Fact table DDL
│   ├── 04_generate_synthetic_data.sql  # Generate ~1.8M rows of demo data
│   ├── 05_gold_layer_views.sql         # Aggregated analytics views
│   ├── 06_cortex_search_services.sql   # 3 Cortex Search services
│   ├── 07_semantic_views.sql           # 3 Semantic Views for Cortex Analyst
│   └── 08_cortex_agent.sql             # Campaign Optimizer Agent with 7 tools
│
└── streamlit/                          # Streamlit in Snowflake app
    ├── environment.yml
    ├── Home.py                         # Main entry point
    └── pages/
        ├── 1_Campaign_Optimizer.py
        ├── 2_Inventory_Explorer.py
        └── 3_Agent_Chat.py
```

## 🚀 Quick Start

### Prerequisites

- Snowflake account with Cortex features enabled
- Role: `SF_INTELLIGENCE_DEMO` with appropriate permissions
- Warehouse: `AD_TECH_WH` (MEDIUM size recommended)

### Installation Steps

Run scripts in order (see `setup/00_run_all.sql` for detailed instructions):

```sql
-- Step 1: Database & Infrastructure
-- Execute: setup/01_database_setup.sql

-- Step 2: Dimension Tables
-- Execute: setup/02_dimension_tables.sql

-- Step 3: Fact Tables
-- Execute: setup/03_fact_tables.sql

-- Step 4: Generate Synthetic Data (~5-10 min)
-- Execute: setup/04_generate_synthetic_data.sql

-- Step 5: Gold Layer Views
-- Execute: setup/05_gold_layer_views.sql

-- Step 6: Cortex Search Services
-- Execute: setup/06_cortex_search_services.sql

-- Step 7: Semantic Views
-- Execute: setup/07_semantic_views.sql

-- Step 8: Cortex Agent
-- Execute: setup/08_cortex_agent.sql
```

### Verify Setup

```sql
-- Check tables
SELECT COUNT(*) FROM AD_TECH.ANALYTICS.DIM_CAMPAIGNS;     -- ~100
SELECT COUNT(*) FROM AD_TECH.ANALYTICS.FACT_IMPRESSIONS;  -- ~1M

-- Check Cortex services
SHOW CORTEX SEARCH SERVICES IN SCHEMA AD_TECH.CORTEX;     -- 3 services

-- Check Semantic views
SHOW SEMANTIC VIEWS IN SCHEMA AD_TECH.CORTEX;             -- 3 views

-- Check Agent
SHOW AGENTS IN SCHEMA AD_TECH.CORTEX;                     -- 1 agent
```

### Deploy Streamlit App

```sql
-- Create a stage for Streamlit files
CREATE STAGE IF NOT EXISTS AD_TECH.APPS.STREAMLIT_STAGE;

-- Upload Streamlit files to stage (use Snowsight or SnowCLI)
-- PUT file://streamlit/* @AD_TECH.APPS.STREAMLIT_STAGE/ad_tech_demo/;

-- Create Streamlit app
CREATE STREAMLIT AD_TECH.APPS.AD_TECH_DEMO
    ROOT_LOCATION = '@AD_TECH.APPS.STREAMLIT_STAGE/ad_tech_demo'
    MAIN_FILE = 'Home.py'
    QUERY_WAREHOUSE = 'AD_TECH_WH';
```

## 🎬 Demo Scenarios

### Scenario 1: Pricing Optimization

> "How do we optimize pricing for a diabetes medication campaign launching in cardiology waiting rooms?"

**Flow:**
1. Use Cortex Search to find available cardiology inventory
2. Analyze historical bid performance by specialty
3. Get AI-recommended pricing range from the Agent

### Scenario 2: Audience Targeting

> "Which patient demographics should we target for maximum engagement?"

**Flow:**
1. Search for high-engagement audience cohorts
2. Analyze conversion rates by demographic segment
3. Recommend privacy-safe targeting strategy

### Scenario 3: Campaign Attribution

> "How do we measure campaign attribution across our entire network?"

**Flow:**
1. Query cross-channel attribution view
2. Visualize touchpoint contribution
3. Calculate ROI by channel

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
"Compare Pfizer vs Eli Lilly Q4 2024 performance"
"Which audiences have highest engagement for heart medications?"
"Show me ROAS trends by therapeutic area"
```

## 📊 Data Model

### Dimension Tables

| Table | Description | Rows |
|-------|-------------|------|
| `DIM_DATE` | Date dimension (2 years) | ~730 |
| `DIM_MEDICAL_SPECIALTIES` | Medical practice types | 25 |
| `DIM_LOCATIONS` | Healthcare facilities | 500 |
| `DIM_INVENTORY` | Ad placement slots | 5,000 |
| `DIM_PHARMA_PARTNERS` | Pharmaceutical advertisers | 20 |
| `DIM_CAMPAIGNS` | Advertising campaigns | 100 |
| `DIM_AUDIENCE_COHORTS` | Privacy-safe patient segments | 200 |

### Fact Tables

| Table | Description | Rows |
|-------|-------------|------|
| `FACT_BIDS` | Bid request/response events | 500K |
| `FACT_IMPRESSIONS` | Delivered ad impressions | 1M |
| `FACT_ENGAGEMENTS` | User interactions | 100K |
| `FACT_APPOINTMENTS` | Aggregated visit context | 200K |

## 🔒 Privacy & Compliance

This demo implements healthcare privacy best practices:

- ✅ **Synthetic Data**: All patient data is generated, not real
- ✅ **K-Anonymity**: Minimum cohort size of 50 enforced
- ✅ **No PII**: No individual patient identifiers
- ✅ **Aggregate Only**: All analytics at cohort level
- ✅ **HIPAA-Ready**: Architecture supports compliance requirements

## 🛠️ Technical Requirements

### Snowflake Features Required

- Cortex Agents (Preview)
- Cortex Search
- Cortex Analyst + Semantic Views
- Streamlit in Snowflake
- Snowpark

### Recommended Warehouse Size

- Demo: MEDIUM (cost-optimized)
- Production: LARGE or X-LARGE

## 📚 Resources

- [Cortex Agents Documentation](https://docs.snowflake.com/en/user-guide/snowflake-cortex/cortex-agents-manage)
- [Cortex Search Documentation](https://docs.snowflake.com/en/user-guide/cortex-search)
- [Semantic Views Documentation](https://docs.snowflake.com/en/user-guide/views-semantic/overview)
- [Streamlit in Snowflake](https://docs.snowflake.com/en/developer-guide/streamlit/about-streamlit)

## 📝 License

This demo is for educational and demonstration purposes only.

---

Built with ❄️ **Snowflake Intelligence**
