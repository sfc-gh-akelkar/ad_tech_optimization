# PatientPoint Ad Tech Optimization Architecture

## High-Level Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              SOURCE SYSTEMS (Simulated)                              │
├─────────────────┬─────────────────┬─────────────────┬─────────────────┬─────────────┤
│   SALESFORCE    │    AD SERVER    │   RTB/SSP       │   ANALYTICS     │  FACILITY   │
│   (CRM)         │   (Delivery)    │   (Bids)        │   (Outcomes)    │  (MDM)      │
├─────────────────┼─────────────────┼─────────────────┼─────────────────┼─────────────┤
│ • Partner data  │ • Impressions   │ • Bid logs      │ • Engagements   │ • Locations │
│ • Contracts     │ • Completions   │ • Win rates     │ • Conversions   │ • Specialty │
│ • Tier levels   │ • Viewability   │ • CPM prices    │ • Dwell time    │ • Capacity  │
│ • Drug catalog  │ • Screen IDs    │ • Fill rates    │ • Attribution   │ • Equipment │
└────────┬────────┴────────┬────────┴────────┬────────┴────────┬────────┴──────┬──────┘
         │                 │                 │                 │               │
         ▼                 ▼                 ▼                 ▼               ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              DATA INGESTION (Production)                             │
├─────────────────────────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐ │
│  │  SNOWPIPE    │  │   FIVETRAN   │  │  KAFKA +     │  │     PARTNER API          │ │
│  │  (Streaming) │  │   (Batch)    │  │  SNOWPIPE    │  │     (REST/SFTP)          │ │
│  │              │  │              │  │  (Real-time) │  │                          │ │
│  │ Bid logs     │  │ CRM sync     │  │ Impression   │  │ Campaign specs           │ │
│  │ 10M+ events  │  │ Daily        │  │ events       │  │ Drug metadata            │ │
│  │ per day      │  │ refresh      │  │ Sub-second   │  │ Creative assets          │ │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                          │
                                          ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                         SNOWFLAKE DATA PLATFORM                                      │
│                         Database: AD_TECH                                            │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                      │
│  ┌─────────────────────────────────────────────────────────────────────────────┐    │
│  │ BRONZE LAYER (Raw)              Schema: RAW                                  │    │
│  │ ─────────────────────────────────────────────────────────────────────────── │    │
│  │  • RAW_BID_EVENTS          • RAW_IMPRESSIONS       • RAW_FACILITY_DATA      │    │
│  │  • RAW_PARTNER_DATA        • RAW_CONVERSIONS       • RAW_SCREEN_HEARTBEATS  │    │
│  │                                                                              │    │
│  │  [Append-only, immutable, full history retained]                            │    │
│  └─────────────────────────────────────────────────────────────────────────────┘    │
│                                          │                                           │
│                                          ▼                                           │
│  ┌─────────────────────────────────────────────────────────────────────────────┐    │
│  │ SILVER LAYER (Cleansed)         Schema: STAGING                              │    │
│  │ ─────────────────────────────────────────────────────────────────────────── │    │
│  │  DIMENSION TABLES                    FACT TABLES                             │    │
│  │  ┌────────────────────┐              ┌────────────────────┐                  │    │
│  │  │ DIM_PARTNERS       │              │ FACT_IMPRESSIONS   │                  │    │
│  │  │ DIM_CAMPAIGNS      │              │ FACT_BIDS          │                  │    │
│  │  │ DIM_FACILITIES     │              │ FACT_ENGAGEMENTS   │                  │    │
│  │  │ DIM_INVENTORY      │              │ FACT_CONVERSIONS   │                  │    │
│  │  │ DIM_THERAPEUTIC    │              │ FACT_REVENUE       │                  │    │
│  │  └────────────────────┘              └────────────────────┘                  │    │
│  │                                                                              │    │
│  │  [Validated, deduped, business keys applied, SCD Type 2]                    │    │
│  └─────────────────────────────────────────────────────────────────────────────┘    │
│                                          │                                           │
│                                          ▼                                           │
│  ┌─────────────────────────────────────────────────────────────────────────────┐    │
│  │ GOLD LAYER (Business Ready)     Schema: ANALYTICS                            │    │
│  │ ─────────────────────────────────────────────────────────────────────────── │    │
│  │                                                                              │    │
│  │  ┌─────────────────────────┐  ┌─────────────────────────┐                   │    │
│  │  │ T_CAMPAIGN_PERFORMANCE  │  │  T_INVENTORY_ANALYTICS  │                   │    │
│  │  ├─────────────────────────┤  ├─────────────────────────┤                   │    │
│  │  │ • Campaign metrics      │  │ • Slot performance      │                   │    │
│  │  │ • ROAS, CTR, Conv Rate  │  │ • Fill rates, CPMs      │                   │    │
│  │  │ • Partner, Therapeutic  │  │ • Facility, Specialty   │                   │    │
│  │  │ • Revenue, Spend        │  │ • Viewability, Engage   │                   │    │
│  │  └─────────────────────────┘  └─────────────────────────┘                   │    │
│  │                                                                              │    │
│  │  ┌─────────────────────────┐                                                │    │
│  │  │ T_AUDIENCE_INSIGHTS     │   [Pre-aggregated for query performance]       │    │
│  │  ├─────────────────────────┤   [Materialized for Cortex Search]             │    │
│  │  │ • Cohort engagement     │   [HIPAA-compliant: k-anonymity min 50]        │    │
│  │  │ • Conversion rates      │                                                │    │
│  │  │ • Demographics          │                                                │    │
│  │  └─────────────────────────┘                                                │    │
│  └─────────────────────────────────────────────────────────────────────────────┘    │
│                                          │                                           │
└──────────────────────────────────────────┼───────────────────────────────────────────┘
                                           │
                                           ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                         SNOWFLAKE INTELLIGENCE LAYER                                 │
│                         Schema: CORTEX                                               │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                      │
│  ┌───────────────────────────────────────────────────────────────────────────────┐  │
│  │                         CORTEX SEARCH SERVICES                                 │  │
│  │                         (Natural Language Discovery)                           │  │
│  ├───────────────────────────────────────────────────────────────────────────────┤  │
│  │                                                                                │  │
│  │  ┌────────────────────┐  ┌────────────────────┐  ┌────────────────────┐       │  │
│  │  │ INVENTORY_SEARCH   │  │ CAMPAIGN_SEARCH    │  │ AUDIENCE_SEARCH    │       │  │
│  │  │ _SVC               │  │ _SVC               │  │ _SVC               │       │  │
│  │  ├────────────────────┤  ├────────────────────┤  ├────────────────────┤       │  │
│  │  │ "Find cardiology   │  │ "Show Wegovy       │  │ "Discover diabetes │       │  │
│  │  │  waiting room      │  │  campaigns with    │  │  patient cohorts   │       │  │
│  │  │  inventory in TX"  │  │  5.0+ ROAS"        │  │  55+ years old"    │       │  │
│  │  │                    │  │                    │  │                    │       │  │
│  │  │ → Facility, Slot,  │  │ → Partner, Drug,   │  │ → Demographics,    │       │  │
│  │  │   CPM, Availability│  │   Metrics, Period  │  │   Engagement Rates │       │  │
│  │  └────────────────────┘  └────────────────────┘  └────────────────────┘       │  │
│  │                                                                                │  │
│  │  [Semantic embeddings, real-time indexing, hybrid search]                     │  │
│  └───────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                      │
│  ┌───────────────────────────────────────────────────────────────────────────────┐  │
│  │                         SEMANTIC VIEWS                                         │  │
│  │                         (Business Terms → SQL Translation)                     │  │
│  ├───────────────────────────────────────────────────────────────────────────────┤  │
│  │                                                                                │  │
│  │  ┌────────────────────┐  ┌────────────────────┐  ┌────────────────────┐       │  │
│  │  │ SV_CAMPAIGN_       │  │ SV_INVENTORY_      │  │ SV_AUDIENCE_       │       │  │
│  │  │ ANALYTICS          │  │ ANALYTICS          │  │ INSIGHTS           │       │  │
│  │  ├────────────────────┤  ├────────────────────┤  ├────────────────────┤       │  │
│  │  │ DIMENSIONS:        │  │ DIMENSIONS:        │  │ DIMENSIONS:        │       │  │
│  │  │ • Campaign Name    │  │ • Facility Name    │  │ • Age Group        │       │  │
│  │  │ • Partner          │  │ • Specialty        │  │ • Gender           │       │  │
│  │  │ • Therapeutic Area │  │ • Region           │  │ • Health Interest  │       │  │
│  │  │ • Campaign Type    │  │ • Placement Type   │  │ • Region           │       │  │
│  │  │                    │  │                    │  │                    │       │  │
│  │  │ METRICS:           │  │ METRICS:           │  │ METRICS:           │       │  │
│  │  │ • ROAS             │  │ • Daily Impress.   │  │ • Engagement Rate  │       │  │
│  │  │ • Total Revenue    │  │ • Fill Rate        │  │ • Conversion Rate  │       │  │
│  │  │ • Total Spend      │  │ • Avg CPM          │  │ • Audience Size    │       │  │
│  │  │ • CTR              │  │ • Viewability      │  │ • Revenue/Member   │       │  │
│  │  │ • Conversion Rate  │  │ • Engagement Rate  │  │                    │       │  │
│  │  └────────────────────┘  └────────────────────┘  └────────────────────┘       │  │
│  │                                                                                │  │
│  │  [Cortex Analyst uses these to generate SQL from natural language]           │  │
│  └───────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                      │
│  ┌───────────────────────────────────────────────────────────────────────────────┐  │
│  │                         CORTEX AGENT                                           │  │
│  │                         CAMPAIGN_OPTIMIZER_AGENT                               │  │
│  ├───────────────────────────────────────────────────────────────────────────────┤  │
│  │                                                                                │  │
│  │   ┌─────────────────────────────────────────────────────────────────────────┐ │  │
│  │   │                    TOOL ORCHESTRATION                                    │ │  │
│  │   │                                                                          │ │  │
│  │   │  User Query: "Top 5 campaigns by ROAS with patterns"                    │ │  │
│  │   │       │                                                                  │ │  │
│  │   │       ▼                                                                  │ │  │
│  │   │  ┌─────────────────────────────────────────────────────────────────┐    │ │  │
│  │   │  │  AGENT ORCHESTRATOR (Claude/Snowflake LLM)                      │    │ │  │
│  │   │  │  • Parses user intent                                           │    │ │  │
│  │   │  │  • Selects appropriate tools                                    │    │ │  │
│  │   │  │  • Combines results                                             │    │ │  │
│  │   │  │  • Generates insights                                           │    │ │  │
│  │   │  └─────────────────────────────────────────────────────────────────┘    │ │  │
│  │   │       │                                                                  │ │  │
│  │   │       ├──────────────────┬──────────────────┬───────────────────────┐   │ │  │
│  │   │       ▼                  ▼                  ▼                       ▼   │ │  │
│  │   │  ┌──────────┐       ┌──────────┐       ┌──────────┐       ┌──────────┐ │ │  │
│  │   │  │Campaign  │       │Inventory │       │Audience  │       │Data to   │ │ │  │
│  │   │  │Analyst   │       │Analyst   │       │Analyst   │       │Chart     │ │ │  │
│  │   │  │(Text→SQL)│       │(Text→SQL)│       │(Text→SQL)│       │(Viz Gen) │ │ │  │
│  │   │  └────┬─────┘       └────┬─────┘       └────┬─────┘       └────┬─────┘ │ │  │
│  │   │       │                  │                  │                  │       │ │  │
│  │   │       ▼                  ▼                  ▼                  ▼       │ │  │
│  │   │  ┌──────────┐       ┌──────────┐       ┌──────────┐       ┌──────────┐ │ │  │
│  │   │  │Campaign  │       │Inventory │       │Audience  │       │Plotly/   │ │ │  │
│  │   │  │Search    │       │Search    │       │Search    │       │Altair    │ │ │  │
│  │   │  │(Discover)│       │(Discover)│       │(Discover)│       │Charts    │ │ │  │
│  │   │  └──────────┘       └──────────┘       └──────────┘       └──────────┘ │ │  │
│  │   │                                                                          │ │  │
│  │   └─────────────────────────────────────────────────────────────────────────┘ │  │
│  │                                                                                │  │
│  │   AGENT CONFIGURATION:                                                         │  │
│  │   • Orchestration: auto (Snowflake-managed model selection)                   │  │
│  │   • Budget: 60 seconds, 32K tokens                                            │  │
│  │   • Instructions: PatientPoint-specific, HIPAA-compliant                      │  │
│  │                                                                                │  │
│  └───────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                           │
                                           ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              USER INTERFACES                                         │
├─────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                      │
│  ┌─────────────────────┐  ┌─────────────────────┐  ┌─────────────────────┐          │
│  │  STREAMLIT IN       │  │  SNOWSIGHT          │  │  API / EMBEDDED     │          │
│  │  SNOWFLAKE          │  │  (Native UI)        │  │  (Future)           │          │
│  ├─────────────────────┤  ├─────────────────────┤  ├─────────────────────┤          │
│  │ • Campaign Optimizer│  │ • Direct Agent      │  │ • Partner Portal    │          │
│  │ • Inventory Explorer│  │   interaction       │  │ • Slack/Teams Bot   │          │
│  │ • AI Agent Chat     │  │ • SQL-based access  │  │ • REST API          │          │
│  │ • Executive Reports │  │                     │  │                     │          │
│  └─────────────────────┘  └─────────────────────┘  └─────────────────────┘          │
│                                                                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Demo Question → Data Flow Mapping

| Demo Question | Primary Tool | Data Tables | Cortex Feature |
|---------------|--------------|-------------|----------------|
| **Q1:** Top 5 campaigns by ROAS | CampaignAnalyst | T_CAMPAIGN_PERFORMANCE | Semantic View → Text-to-SQL |
| **Q2:** Underperforming campaigns | CampaignAnalyst | T_CAMPAIGN_PERFORMANCE | Semantic View → Text-to-SQL |
| **Q3:** Premium inventory for diabetes | InventorySearch + InventoryAnalyst | T_INVENTORY_ANALYTICS | Cortex Search + Semantic View |
| **Q4:** GLP-1 competitive position | CampaignAnalyst + CampaignSearch | T_CAMPAIGN_PERFORMANCE | Semantic View + Cortex Search |
| **Q5:** 20% budget allocation | All Tools | All 3 Gold Tables | Multi-tool orchestration |

---

## Data Elements by Business Domain

### Campaign Performance (T_CAMPAIGN_PERFORMANCE)
```
┌─────────────────────────────────────────────────────────────────┐
│ CAMPAIGN_ID        │ Primary key                                │
│ CAMPAIGN_NAME      │ e.g., "Wegovy Direct Response Q4 2025"    │
│ PARTNER_NAME       │ e.g., "Novo Nordisk", "Eli Lilly"         │
│ PARTNER_TIER       │ Platinum, Gold, Silver, Bronze             │
│ THERAPEUTIC_AREA   │ Weight Loss, Diabetes, Oncology, etc.      │
│ DRUG_NAME          │ e.g., "Wegovy", "Ozempic", "Keytruda"      │
│ CAMPAIGN_TYPE      │ Direct Response, Education, Awareness      │
│ START_DATE         │ Campaign start                             │
│ END_DATE           │ Campaign end                               │
│ BUDGET             │ Allocated budget ($)                       │
│ TOTAL_SPEND        │ Actual spend ($)                           │
│ TOTAL_REVENUE      │ Revenue generated ($)                      │
│ TOTAL_IMPRESSIONS  │ Impression count                           │
│ TOTAL_CONVERSIONS  │ Conversion count                           │
│ ROAS               │ Return on Ad Spend (Revenue/Spend)         │
│ CTR_PCT            │ Click-through rate (%)                     │
│ CONVERSION_RATE_PCT│ Conversion rate (%)                        │
│ VIEWABILITY_PCT    │ Viewability score (%)                      │
└─────────────────────────────────────────────────────────────────┘
```

### Inventory Analytics (T_INVENTORY_ANALYTICS)
```
┌─────────────────────────────────────────────────────────────────┐
│ SLOT_ID            │ Primary key                                │
│ SLOT_NAME          │ e.g., "Mayo Clinic - Waiting Room TV"      │
│ FACILITY_NAME      │ e.g., "Mayo Clinic"                        │
│ SPECIALTY          │ Cardiology, Endocrinology, Oncology, etc.  │
│ CITY               │ Facility city                              │
│ STATE              │ Facility state                             │
│ REGION             │ Northeast, Southeast, Midwest, etc.        │
│ PLACEMENT_TYPE     │ Waiting Room, Exam Room, Check-in          │
│ SCREEN_TYPE        │ Digital Display, TV Screen, Tablet         │
│ DAYPART            │ Morning, Afternoon, Evening, All Day       │
│ DAILY_IMPRESSIONS  │ Average daily impressions                  │
│ FILL_RATE_PCT      │ Inventory fill rate (%)                    │
│ AVG_CPM            │ Average CPM ($)                            │
│ WINNING_CPM        │ Winning bid CPM ($)                        │
│ VIEWABILITY_PCT    │ Viewability score (%)                      │
│ ENGAGEMENT_RATE_PCT│ Engagement rate (%)                        │
│ PATIENT_VOLUME     │ Annual patient volume                      │
│ AFFLUENCE_INDEX    │ Affluence score (1-10)                     │
└─────────────────────────────────────────────────────────────────┘
```

### Audience Insights (T_AUDIENCE_INSIGHTS)
```
┌─────────────────────────────────────────────────────────────────┐
│ COHORT_ID          │ Primary key                                │
│ COHORT_NAME        │ e.g., "45-54 Female - Cancer Awareness"    │
│ AGE_GROUP          │ 18-24, 25-34, 35-44, 45-54, 55-64, 65+     │
│ GENDER             │ Male, Female                               │
│ REGION             │ Geographic region                          │
│ HEALTH_INTEREST    │ Diabetes, Cancer, Heart Health, etc.       │
│ AUDIENCE_SIZE      │ Cohort size (min 50 for k-anonymity)       │
│ ENGAGEMENT_RATE_PCT│ Engagement rate (%)                        │
│ CONVERSION_RATE_PCT│ Conversion rate (%)                        │
│ AVG_DWELL_TIME_SEC │ Average dwell time (seconds)               │
│ REVENUE_PER_MEMBER │ Revenue per cohort member ($)              │
└─────────────────────────────────────────────────────────────────┘
```

---

## Snowflake Features Summary

| Feature | Purpose in Demo | Demo Evidence |
|---------|-----------------|---------------|
| **Cortex Agent** | Multi-tool orchestration, natural language interface | All 5 questions answered in conversational UI |
| **Cortex Analyst** | Text-to-SQL via Semantic Views | Q1, Q2: Complex campaign queries without writing SQL |
| **Cortex Search** | Natural language discovery | Q3: "Find cardiology inventory" → structured results |
| **Semantic Views** | Business term definitions, metric calculations | ROAS, CTR, Conversion Rate understood without SQL |
| **Materialized Tables** | Pre-computed aggregations for query speed | Sub-second responses on pre-aggregated data |
| **Streamlit in Snowflake** | Custom UI for demo | Interactive chat interface |
| **Role-Based Access** | Data governance | SF_INTELLIGENCE_DEMO role controls access |

---

## Production vs. Demo Comparison

| Aspect | Demo (Today) | Production (PatientPoint) |
|--------|--------------|---------------------------|
| **Data Volume** | ~25 campaigns, ~30 slots, ~20 cohorts | 100K+ campaigns, 50K+ slots, 1M+ cohorts |
| **Data Refresh** | Static (pre-loaded) | Real-time (Snowpipe) + daily batch |
| **Source Systems** | Simulated tables | Salesforce, GAM, RTB logs, Analytics |
| **Data Lineage** | Flat tables | Bronze → Silver → Gold pipeline |
| **Governance** | Demo role | Row-level security, data masking |
| **Compute** | XS warehouse | Multi-cluster auto-scaling |

