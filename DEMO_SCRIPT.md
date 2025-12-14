# 🎬 PatientPoint Predictive Maintenance Demo Script

**Duration:** 20 minutes  
**Audience:** PatientPoint IT Leadership, Operations, Field Services  
**Platform:** Snowflake Intelligence + Cortex Agents

---

## 🎯 FOCUS Framework Alignment

| CHALLENGE | ACTION | RESULT |
|-----------|--------|--------|
| 💸 Lost Advertising Revenue | 🤖 AI Agent Implementation | 💵 Revenue Protection |
| 💰 High Operational Costs | 🔧 Automated Remote Resolution | 📉 40-60% Cost Reduction |
| ⏰ Unexpected Downtime | 🧠 AI/ML Predictive Models | 🎯 >85% Predictive Accuracy |

---

## 📋 Demo Overview

This demo tells a **cohesive story** through 4 personas, with each question flowing naturally to the next:

| Persona | Focus | Time |
|---------|-------|------|
| 🎯 **Executive (C-Suite)** | KPIs, ROI, strategic metrics | 4 min |
| 🖥️ **Operations Center** | Fleet monitoring, predictions, dispatch | 6 min |
| 🔧 **Field Technician** | Work orders, troubleshooting, repair guidance | 4 min |
| 🤖 **AI Agent Demo** | Natural language, conversational AI | 4 min |

---

## 🎬 Opening (0:00 - 2:00)

### Setting the Stage

**SAY THIS:**
> "PatientPoint operates 500,000 IoT devices—HealthScreen displays—across hospitals and clinics nationwide. These screens generate **advertising revenue from pharmaceutical partners**. When a screen fails, three things happen:
> 
> 1. **Lost Revenue**: Every hour offline means lost ad impressions and revenue
> 2. **High Costs**: Field dispatch costs $150-300 per visit
> 3. **Unpredictable Downtime**: Reactive maintenance means you don't know what's failing until it's down
> 
> Today I'll show you how Snowflake Intelligence and Cortex Agents solve all three with **predictive AI**."

**Actions:**
1. Open **Snowflake Intelligence** (AI & ML → Snowflake Intelligence)
2. Select the **Device Maintenance Assistant** agent
3. Briefly show the chat interface

---

## 🎯 Act 1: Executive Dashboard (2:00 - 6:00)

*Persona: C-Suite / VP of Operations*

### Scene Setup
> "Let's start with what executives care about: the big picture. Imagine you're the VP of Operations walking into a Monday morning meeting. You need instant answers—no waiting for reports, no switching between dashboards."

---

### 📌 Prompt 1: The Big Picture

```
Give me a summary of our device fleet health and business impact
```

#### 🎯 Why This Matters to the Customer
- **Executive time is expensive** — They need a single view, not 10 dashboards
- **Board-ready metrics** — Health score, uptime, revenue impact in one answer
- **Early warning** — Identify systemic issues before they become crises

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **Single Pane of Glass** | Natural language replaces multiple BI tools |
| **Real-time Awareness** | Data as of current hour, not last week's report |
| **Risk Visibility** | At-risk devices surfaced proactively |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `V_DEVICE_HEALTH_SUMMARY` | Current health scores, risk levels | 100 devices |
| `V_EXECUTIVE_DASHBOARD` | Aggregated KPIs | 1 row |
| `V_REVENUE_IMPACT` | Uptime and revenue metrics | 100 devices |
| `V_CUSTOMER_SATISFACTION` | NPS and satisfaction scores | 14 facilities |

#### ✅ Auditability — How to Verify
> *"Everything you see here is queryable. If you want to drill into any number, I can show you the underlying SQL or run it directly in Snowsight."*

```sql
-- Verify fleet health summary
SELECT STATUS, COUNT(*) as DEVICE_COUNT, ROUND(AVG(HEALTH_SCORE),1) as AVG_HEALTH
FROM V_DEVICE_HEALTH_SUMMARY
GROUP BY STATUS;

-- Verify at-risk count
SELECT RISK_LEVEL, COUNT(*) FROM V_DEVICE_HEALTH_SUMMARY GROUP BY RISK_LEVEL;
```

#### 🔧 Customization for PatientPoint

| What We Used | What PatientPoint Would Use | Integration Effort |
|--------------|----------------------------|-------------------|
| **Demo: 100 devices** | **Production: 500,000 devices** from your device management system | Data pipeline from IoT platform |
| **Health Score formula** (CPU, memory, temp, errors) | Your actual **device health metrics** + custom weights | Configure in `V_DEVICE_HEALTH_SUMMARY` |
| **Risk thresholds** (CRITICAL >75°C, etc.) | Your **operational thresholds** based on historical failure data | Update risk classification logic |
| **Hourly telemetry** | Your **actual telemetry frequency** (could be 5-min, 15-min) | Adjust data ingestion pipeline |

**SAY THIS:**
> *"This demo uses 100 representative devices. In production, this same query scales to your 500,000 devices—Snowflake handles the compute. The health score formula and risk thresholds are fully configurable based on your historical failure patterns."*

#### 📝 Expected Response Highlights
- **Fleet Health Score**: ~71/100 (Good performance)
- **Device Status**: 92 online, 5 degraded, 3 offline
- **Risk Distribution**: 3 CRITICAL, 4 HIGH, 67 MEDIUM, 26 LOW
- **Uptime**: ~94.5%
- **Revenue Loss**: $0 historical (resolved incidents)
- **NPS Score**: +8.6

#### ⚠️ Objection Handling

**IF ASKED: "Why is 67% of the fleet at MEDIUM risk?"**
> *"MEDIUM risk doesn't mean failure is imminent—it means these devices have one or more metrics slightly elevated that we're monitoring. This is exactly what predictive maintenance does: it identifies potential issues EARLY, before they become CRITICAL. The fact that only 7 devices (7%) are at HIGH or CRITICAL shows the system is working."*

**IF ASKED: "Why is uptime only 94.5%?"**
> *"The 94.5% includes our 3 offline and 5 degraded devices right now. This is a point-in-time snapshot showing current status. The important metric is that we're seeing these issues BEFORE they cause revenue impact. Let me show you the revenue picture..."*

**IF ASKED: "The health score of 71 seems low"**
> *"A health score of 71 means the fleet is in 'Good' condition. Perfect would be 100, but that's unrealistic for a 500K device fleet. What matters is identifying the devices that need attention—and the AI just surfaced exactly which 7 devices require action."*

#### 🔄 Transition
> *"Good overview—we see a fleet health score of 71, with 7 devices needing attention. But the key metric here is zero historical revenue loss. Let me show you what's at risk RIGHT NOW from our current device status..."*

---

### 📌 Prompt 2: Revenue Protection

```
How much advertising revenue are we losing from device downtime?
```

#### 🎯 Why This Matters to the Customer
- **Revenue is the language of the C-suite** — This connects IT metrics to business outcomes
- **Pharma partners expect uptime** — Contractual SLAs may be at risk
- **Quantifies the cost of inaction** — Makes the case for predictive maintenance investment

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **Revenue Attribution** | Device health → ad impressions → dollars |
| **Zero Loss Target** | Predictive maintenance prevents revenue leakage |
| **Partner Confidence** | Reliable screens = reliable ad delivery |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `V_REVENUE_IMPACT` | Revenue loss per device, uptime % | 100 devices |
| `DEVICE_DOWNTIME` | Historical downtime incidents | 10 incidents |
| `DEVICE_INVENTORY` | Hourly ad revenue per device ($8-$25/hr) | 100 devices |

#### ✅ Auditability — How to Verify
```sql
-- See revenue loss by device
SELECT DEVICE_ID, FACILITY_NAME, TOTAL_REVENUE_LOSS_USD, UPTIME_PERCENTAGE
FROM V_REVENUE_IMPACT
WHERE TOTAL_REVENUE_LOSS_USD > 0
ORDER BY TOTAL_REVENUE_LOSS_USD DESC;

-- Verify downtime records
SELECT * FROM DEVICE_DOWNTIME ORDER BY DOWNTIME_START DESC;
```

#### 🔧 Customization for PatientPoint

| What We Used | What PatientPoint Would Use | Integration Effort |
|--------------|----------------------------|-------------------|
| **$8-$25/hr ad revenue** | Your **actual CPM rates** by device type, location, pharma partner | Import from ad platform (e.g., GAM, direct contracts) |
| **Monthly impressions** (9K-27K) | Your **actual impression data** from ad server | Real-time or daily sync from ad platform |
| **Downtime tracking** | Your **actual outage data** from monitoring system | Connect to alerting/monitoring tool |

**Key PatientPoint Data Sources:**
- **Ad Revenue**: Google Ad Manager, direct pharma contracts, CPM by placement
- **Impressions**: Real-time ad server logs, viewability metrics
- **Downtime**: Device management platform alerts, heartbeat failures

**SAY THIS:**
> *"The revenue numbers here come from your ad platform data. We can connect directly to your ad server to pull actual CPM rates and impression counts per device. This means the AI calculates real revenue impact, not estimates."*

#### 📝 Expected Response Highlights
- **Revenue at Risk**: ~$51,660 (5% of potential)
- **Top 3 Offline Devices**: DEV-081 ($15K), DEV-031 ($9K), DEV-025 ($6K)
- **Devices Affected**: 8 out of 100 (92% healthy)
- **Geographic Pattern**: Cleveland facilities disproportionately affected
- **Production Scale**: ~$25.8M annual impact

#### ⚠️ Objection Handling

**IF ASKED: "Q1 said $0 revenue loss, now you're saying $51K?"**
> *"Great catch—these are different metrics. The $0 in Q1 was HISTORICAL downtime—incidents that have been recorded and resolved. The $51K here is CURRENT revenue at risk from devices that are offline or degraded RIGHT NOW. This is exactly why predictive maintenance matters—we can see the potential revenue impact BEFORE it becomes actual loss."*

**IF ASKED: "How do you calculate revenue per device?"**
> *"Each device has an hourly ad revenue rate based on its model and location—ranging from $8/hour for Lite 32s to $25/hour for Max 65s in high-traffic facilities. We multiply by hours offline to get revenue impact. In production, this would pull actual CPM rates from your ad platform."*

**IF ASKED: "Why are Cleveland facilities having issues?"**
> *"The AI identified a geographic pattern—this could indicate a regional network issue, a batch of devices from the same shipment, or even a facility-level infrastructure problem. This is the kind of insight that helps operations prioritize investigations."*

#### 🔄 Transition
> *"So we have $51K at risk from 8 devices right now. The good news? 92% of the fleet is healthy. This shows exactly why we need predictive maintenance—to catch these issues before they cause actual revenue loss. Let me show you the cost side..."*

---

### 📌 Prompt 3: ROI & Cost Baseline

```
What's our annual field service cost and projected savings with predictive maintenance?
```

#### 🎯 Why This Matters to the Customer
- **CFO question #1** — "What does this cost and what do we save?"
- **Investment justification** — Hard numbers for budget approval
- **Benchmark against industry** — $185/dispatch is industry standard

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **Cost Baseline Established** | $185M/year at 500K devices |
| **Savings Projection** | $96M/year (52% reduction) |
| **Remote Fix Economics** | $185 dispatch vs $25 remote = $160 saved per fix |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `V_ROI_ANALYSIS` | Annual projections, per-unit costs | 1 row |
| `MAINTENANCE_HISTORY` | Actual resolution types | 24 tickets |
| `V_MAINTENANCE_ANALYTICS` | Cost savings achieved | 24 records |

#### ✅ Auditability — How to Verify
```sql
-- See the full ROI calculation
SELECT * FROM V_ROI_ANALYSIS;

-- Verify remote fix rate
SELECT RESOLUTION_TYPE, COUNT(*) as COUNT, SUM(COST_SAVINGS_USD) as TOTAL_SAVINGS
FROM V_MAINTENANCE_ANALYTICS
GROUP BY RESOLUTION_TYPE;
```

**SAY THIS:**
> *"This is the ROI story: we spend $185M annually on field dispatches at 500K devices. With 60%+ remote resolution, we're projecting $96M in annual savings—that's a 52% cost reduction. This aligns with what we've seen at customers like FIIX, who achieved 10x improvement in maintenance insights."*

#### 🔧 Customization for PatientPoint

| What We Used | What PatientPoint Would Use | Integration Effort |
|--------------|----------------------------|-------------------|
| **$185 avg dispatch cost** | Your **actual dispatch costs** (labor, travel, parts) | Import from ServiceNow/field service system |
| **$25 remote fix cost** | Your **actual remote support costs** (labor time) | Calculate from helpdesk data |
| **2 issues/device/year assumption** | Your **actual historical issue rate** | Analyze from maintenance history |

**PatientPoint-Specific ROI Inputs:**
- **Labor costs**: Technician hourly rate × avg time on-site
- **Travel costs**: Mileage reimbursement, fleet costs
- **Parts costs**: Average parts per dispatch
- **Remote costs**: NOC hourly rate × avg resolution time

**SAY THIS (if asked about the numbers):**
> *"These cost assumptions are configurable. In a POC, we'd plug in your actual dispatch costs from ServiceNow and your remote support costs from your helpdesk system. The ROI calculation updates automatically."*

#### 📝 Expected Response Highlights
- **Annual Field Service Cost**: $185M (at 500K devices)
- **Avg Dispatch Cost**: $185 per incident
- **Avg Remote Fix Cost**: $25 per incident
- **Projected Annual Savings**: $96M (52% reduction)
- **Dispatches Avoided**: 600,000 annually
- **Remote Fix Rate**: 60-75%
- **ROI**: ~4:1 return

#### ⚠️ Objection Handling

**IF ASKED: "Where does $185 per dispatch come from?"**
> *"That's an industry average for field service visits—includes technician labor (2-4 hours), travel costs, vehicle expenses, and parts markup. In a POC, we'd plug in your actual dispatch costs from ServiceNow or your field service system."*

**IF ASKED: "How did you calculate 4:1 ROI?"**
> *"$96M in annual savings versus an estimated $20-25M for implementation and operations. The exact ROI depends on your infrastructure, but field service companies typically see 3-5x return. Some customers like FIIX have seen 10x improvement in maintenance insights."*

**IF ASKED: "Is 75% remote fix rate realistic?"**
> *"Based on the demo data, we're seeing 60-70% remote resolution. 75% is achievable as the AI learns your failure patterns and the knowledge base matures. For software issues, some customers see 80%+. Hardware issues like display failures will always require dispatch."*

**IF ASKED: "What's not included in these savings?"**
> *"This is conservative—it only counts dispatch avoidance. It doesn't include: revenue protection from faster resolution, customer satisfaction gains, extended device lifespan from proactive maintenance, or reduced emergency overtime costs."*

#### 🎤 Executive Talking Point
**SAY THIS after the response:**
> *"This is the headline number for your CFO: $96 million in annual savings from a 52% reduction in field dispatches. And this is conservative—it doesn't include revenue protection from faster resolution or the customer satisfaction gains from proactive maintenance."*

#### 🔄 Transition
> *"That's the projection at scale. Let me show you the actual savings we're achieving right now in the demo data..."*

---

### 📌 Prompt 4: Cost Savings Achieved

```
How much money have we saved this month from remote fixes vs field dispatches?
```

#### 🎯 Why This Matters to the Customer
- **Proof over promise** — Not projections, actual realized savings
- **Trend visibility** — Is the program working month-over-month?
- **Operational validation** — Remote fix strategy is paying off

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **Realized Savings** | Actual dollars saved (not projected) |
| **Remote Fix Rate** | 60-70% of issues resolved without dispatch |
| **Dispatch Avoidance** | Each remote fix = $185 saved |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `V_MAINTENANCE_ANALYTICS` | Ticket-level cost data | 24 tickets |
| `MAINTENANCE_HISTORY` | Resolution type, technician, timestamp | 24 records |

#### ✅ Auditability — How to Verify
```sql
-- See savings by ticket
SELECT TICKET_ID, DEVICE_ID, FACILITY_NAME, RESOLUTION_TYPE, 
       COST_USD, COST_SAVINGS_USD, RESOLUTION_TIME_MINS
FROM V_MAINTENANCE_ANALYTICS
WHERE DATE_TRUNC('month', CREATED_AT) = DATE_TRUNC('month', CURRENT_DATE())
ORDER BY CREATED_AT DESC;
```

#### 🔄 Transition
> *"That's real savings happening now—on track for 40-60% reduction in field service costs. But I noticed we track NPS. Let's check customer satisfaction..."*

---

### 📌 Prompt 5: Customer Satisfaction

```
What is our customer satisfaction score and which facilities need follow-up?
```

#### 🎯 Why This Matters to the Customer
- **Retention driver** — Happy providers renew contracts
- **Early warning system** — Negative feedback = churn risk
- **Closed-loop service** — Issues flagged for follow-up

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **NPS Tracking** | Net Promoter Score by facility |
| **Proactive Follow-up** | Negative feedback triggers action |
| **Service Quality Correlation** | Device uptime → satisfaction |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `V_CUSTOMER_SATISFACTION` | NPS, ratings by facility | 14 facilities |
| `PROVIDER_FEEDBACK` | Individual feedback records | 14 records |

#### ✅ Auditability — How to Verify
```sql
-- See facilities needing follow-up
SELECT FACILITY_NAME, AVG_NPS_SCORE, FEEDBACK_CATEGORY, FOLLOW_UPS_REQUIRED
FROM V_CUSTOMER_SATISFACTION
WHERE FOLLOW_UPS_REQUIRED > 0;

-- See all feedback
SELECT * FROM PROVIDER_FEEDBACK ORDER BY FEEDBACK_DATE DESC;
```

#### 🔧 Customization for PatientPoint

| What We Used | What PatientPoint Would Use | Integration Effort |
|--------------|----------------------------|-------------------|
| **NPS Score (0-10)** | Your **actual provider NPS surveys** | Import from survey tool (Qualtrics, etc.) |
| **Satisfaction ratings** | Your **CRM feedback data** | Sync from Salesforce/HubSpot |
| **Follow-up flags** | Your **customer success workflow** | Connect to CS platform |

**PatientPoint Data Sources:**
- **Provider Surveys**: Qualtrics, SurveyMonkey, or in-app feedback
- **CRM Data**: Salesforce, HubSpot provider records
- **Support Tickets**: Zendesk, ServiceNow customer complaints
- **Contract Data**: Renewal risk indicators, account health

**SAY THIS:**
> *"We're correlating device health with provider satisfaction. The insight here is: facilities with more device issues have lower NPS. This helps your customer success team prioritize which accounts need attention—before they churn."*

#### 🔄 Transition
> *"I see Springfield Urgent Care flagged for follow-up—they had a negative experience. Let's hand this over to Operations to understand what's happening with their device..."*

---

### ✅ Executive Act Summary

| FOCUS Result | Metric Shown | Demo Value | Production Scale |
|--------------|--------------|------------|------------------|
| 💵 **Revenue Protection** | Ad revenue loss | $0 | Millions protected |
| 💰 **40-60% Cost Reduction** | Annual savings | $2,500+/month | **$50M+/year** |
| 🎯 **Prediction Accuracy** | Remote fix rate | 60-70% | 350K dispatches avoided |
| ⭐ **Customer Satisfaction** | NPS Score | 8.6 | Retention driver |

---

## 🖥️ Act 2: Operations Center (6:00 - 12:00)

*Persona: IT Manager / Facilities Operations*

### Scene Setup
> "Now let's switch to the Operations Center. The executive just flagged Springfield Urgent Care. But as an ops manager, you need to see the full picture of what's at risk today—and make dispatch decisions."

---

### 📌 Prompt 1: Top Facilities by Revenue

```
Show me device health across our top 10 facilities by ad revenue
```

#### 🎯 Why This Matters to the Customer
- **Prioritize by business impact** — Not all devices are equal
- **Revenue-weighted decisions** — Fix high-revenue devices first
- **Resource allocation** — Where should techs focus?

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **Revenue-Based Prioritization** | Operations decisions tied to business value |
| **Risk Concentration** | Are high-revenue facilities also high-risk? |
| **Portfolio View** | Facility-level health at a glance |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `V_DEVICE_HEALTH_SUMMARY` | Health scores, facility names | 100 devices |
| `DEVICE_INVENTORY` | Hourly ad revenue per device | 100 devices |

#### ✅ Auditability — How to Verify
```sql
-- Top 10 facilities by revenue
SELECT FACILITY_NAME, SUM(HOURLY_AD_REVENUE_USD * 720) as MONTHLY_REVENUE,
       AVG(HEALTH_SCORE) as AVG_HEALTH, COUNT(*) as DEVICE_COUNT
FROM V_DEVICE_HEALTH_SUMMARY
GROUP BY FACILITY_NAME
ORDER BY MONTHLY_REVENUE DESC
LIMIT 10;
```

#### 🔄 Transition
> *"Good overview of our highest-value facilities. Now let me see what's actually at risk across the entire fleet right now..."*

---

### 📌 Prompt 2: Current Risk Assessment

```
Which devices have critical or high risk levels right now?
```

#### 🎯 Why This Matters to the Customer
- **Actionable intelligence** — Not just data, but prioritized action items
- **Failure prevention** — Address issues before they cause downtime
- **Dispatch optimization** — Know which devices need attention TODAY

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **Real-time Risk Scoring** | Devices ranked by failure probability |
| **Root Cause Visibility** | Each risk level shows the primary issue |
| **Proactive Operations** | See problems before customers report them |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `V_DEVICE_HEALTH_SUMMARY` | Risk level, primary issue | 100 devices |
| `DEVICE_TELEMETRY` | Real-time CPU, memory, temp, errors | 72,000 readings |

**Risk Classification Logic:**
```
CRITICAL: Device offline
HIGH: Degraded + (CPU temp > 65°C OR CPU usage > 80%)
MEDIUM: Degraded OR (CPU temp > 75°C OR CPU usage > 95%)
LOW: All metrics within normal range
```

#### ✅ Auditability — How to Verify
```sql
-- See all at-risk devices with details
SELECT DEVICE_ID, FACILITY_NAME, LOCATION, HEALTH_SCORE, RISK_LEVEL,
       PRIMARY_ISSUE, CPU_TEMP_CELSIUS, CPU_USAGE_PCT, MEMORY_USAGE_PCT,
       DAYS_SINCE_MAINTENANCE
FROM V_DEVICE_HEALTH_SUMMARY
WHERE RISK_LEVEL IN ('CRITICAL', 'HIGH')
ORDER BY CASE RISK_LEVEL WHEN 'CRITICAL' THEN 1 WHEN 'HIGH' THEN 2 END;
```

#### 🔧 Customization for PatientPoint

| What We Used | What PatientPoint Would Use | Integration Effort |
|--------------|----------------------------|-------------------|
| **CPU temp thresholds** (65°C, 75°C) | Your **device specs** and historical failure temps | Analyze past failures to set thresholds |
| **Risk classification rules** | Your **operational SLAs** (e.g., hospital vs clinic) | Business logic in view definition |
| **Telemetry metrics** | Your **actual IoT data points** (could include ambient temp, display brightness) | Map to existing telemetry schema |

**PatientPoint-Specific Considerations:**
- **Device Models**: Different thresholds for Pro 55, Lite 32, Max 65?
- **Facility Types**: Hospitals might have stricter SLAs than clinics
- **Geographic Factors**: Higher acceptable temps in warm climates?
- **Age of Device**: Older devices may need different thresholds

**SAY THIS:**
> *"These risk thresholds are based on industry standards, but you'd tune them using your historical failure data. For example, if your devices typically fail at 80°C, we'd set the CRITICAL threshold there. The AI learns from your patterns."*

#### 🔄 Transition
> *"I see 7 devices flagged—including DEV-005 at Springfield Urgent Care that the executive mentioned. Before I dispatch technicians, let me see if any of these can be fixed remotely..."*

---

### 📌 Prompt 3: Remote Fix Triage

```
Can any of these critical or high risk devices be fixed remotely?
```

#### 🎯 Why This Matters to the Customer
- **Cost optimization** — Remote fix = $25 vs dispatch = $185
- **Faster resolution** — Remote in 30 min vs dispatch in 4+ hours
- **Intelligent triage** — AI recommends most cost-effective action

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **Automated Triage** | AI classifies remote vs on-site |
| **Success Rate Prediction** | Each issue type has known fix rate |
| **Decision Support** | Ops manager gets recommendation, not just data |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `TROUBLESHOOTING_KB` | Success rates by issue type | 10 categories |
| `V_DEVICE_HEALTH_SUMMARY` | Current issues per device | 100 devices |

**Remote Fix Success Rates:**
| Issue Type | Remote Success Rate |
|------------|---------------------|
| HIGH_CPU | 92% |
| MEMORY_LEAK | 94% |
| DISPLAY_FREEZE | 87.5% |
| CONNECTIVITY | 70% |
| OVERHEATING | 15% (usually requires dispatch) |

#### ✅ Auditability — How to Verify
```sql
-- See success rates from knowledge base
SELECT ISSUE_CATEGORY, SUCCESS_RATE_PCT, REQUIRES_DISPATCH,
       ESTIMATED_REMOTE_FIX_TIME_MINS
FROM TROUBLESHOOTING_KB
ORDER BY SUCCESS_RATE_PCT DESC;
```

#### 🔄 Transition
> *"Great—the agent identified that HIGH_CPU and MEMORY_LEAK issues can be fixed remotely with 92%+ success rate. Let me dig into Springfield specifically..."*

---

### 📌 Prompt 4: Device Deep Dive

```
What's the status of device DEV-005 at Springfield Urgent Care and what's causing the issue?
```

#### 🎯 Why This Matters to the Customer
- **Full context for dispatch** — Don't send techs blind
- **Pattern recognition** — Is this a recurring issue at this location?
- **Root cause analysis** — Understand why, not just what

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **Device-Level Detail** | Complete health profile on demand |
| **Historical Context** | Past issues at this facility |
| **Actionable Diagnosis** | Not just symptoms, but recommended actions |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `V_DEVICE_HEALTH_SUMMARY` | Current device status | 1 device |
| `MAINTENANCE_HISTORY` | Past tickets for this device | Variable |
| `TROUBLESHOOTING_KB` | Fix procedures | 10 categories |

#### ✅ Auditability — How to Verify
```sql
-- Full device profile
SELECT * FROM V_DEVICE_HEALTH_SUMMARY WHERE DEVICE_ID = 'DEV-005';

-- Historical issues at this location
SELECT * FROM MAINTENANCE_HISTORY 
WHERE DEVICE_ID = 'DEV-005' 
ORDER BY CREATED_AT DESC;
```

#### 🔄 Transition
> *"I see it's a network connectivity issue—and this facility has had 3 network issues in 60 days. Let me check if we already have work orders created..."*

---

### 📌 Prompt 5: Work Order Status

```
Show me all active work orders and their priority
```

#### 🎯 Why This Matters to the Customer
- **Dispatch coordination** — What's already being worked?
- **Priority management** — Critical vs routine work
- **AI-generated vs manual** — See predictive maintenance in action

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **Work Order Visibility** | All active jobs in one view |
| **AI-Initiated Work** | Predictive system creates proactive tickets |
| **Technician Utilization** | Who's assigned to what |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `V_ACTIVE_WORK_ORDERS` | Active work orders with details | 5 active |
| `WORK_ORDERS` | Full work order records | 8 total |
| `TECHNICIANS` | Technician assignments | 6 techs |

#### ✅ Auditability — How to Verify
```sql
-- See all active work orders
SELECT WORK_ORDER_ID, DEVICE_ID, FACILITY_NAME, PRIORITY, STATUS,
       SOURCE, ASSIGNED_TECHNICIAN_ID, AI_DIAGNOSIS
FROM V_ACTIVE_WORK_ORDERS
ORDER BY URGENCY_SCORE DESC;

-- See AI-generated vs manual
SELECT SOURCE, COUNT(*) FROM WORK_ORDERS GROUP BY SOURCE;
```

#### 🔄 Transition
> *"I see there's already a CRITICAL work order for DEV-005—created by AI prediction. Now let me show you the predictive intelligence..."*

---

### 📌 Prompt 6: Predictive Failure Detection

```
Which devices are predicted to fail in the next 48 hours?
```

#### 🎯 Why This Matters to the Customer
- **24-48 hour advance warning** — Time to prevent failures
- **Proactive dispatch** — Schedule before emergency
- **Confidence scoring** — Know how reliable the prediction is

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **Predictive Lead Time** | 24-48 hour advance warning |
| **Failure Probability** | Confidence % for each prediction |
| **Contributing Factors** | Which metrics drove the prediction |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `V_FAILURE_PREDICTIONS` | Predicted failures with probability | Variable |
| `V_DEVICE_HEALTH_SUMMARY` | Current risk levels | 100 devices |
| `DEVICE_TELEMETRY` | 30 days of trend data | 72,000 readings |

**Prediction Model Inputs:**
- CPU temperature trend (rising = higher risk)
- Memory usage trend (approaching limit)
- Error count acceleration
- Days since last maintenance
- Historical failure patterns at this location

#### ✅ Auditability — How to Verify
```sql
-- See predictions (requires script 05)
SELECT DEVICE_ID, FACILITY_NAME, RISK_LEVEL, 
       PREDICTED_HOURS_TO_FAILURE, FAILURE_PROBABILITY_PCT,
       RISK_FACTORS
FROM V_FAILURE_PREDICTIONS
WHERE PREDICTED_HOURS_TO_FAILURE <= 48
ORDER BY FAILURE_PROBABILITY_PCT DESC;
```

**SAY THIS:**
> *"This is the power of predictive maintenance—we can see failures before they happen. The model looks at 30 days of telemetry: temperature trends, memory patterns, error acceleration. This gives us time to schedule proactive maintenance instead of reacting to emergencies."*

#### 🔧 Customization for PatientPoint

| What We Used | What PatientPoint Would Use | Integration Effort |
|--------------|----------------------------|-------------------|
| **30-day telemetry window** | Your **optimal prediction window** (could be 7, 14, 60 days) | Tune based on failure patterns |
| **Rule-based prediction** | Your choice: **Cortex ML models** for higher accuracy | Train on historical failure data |
| **Failure probability %** | Your **confidence thresholds** for action | Business rule configuration |

**ML Model Options for Production:**
1. **Rule-Based (Current)**: Simple threshold logic, ~85% accuracy
2. **Cortex ML Classification**: Train on historical failures, ~90%+ accuracy
3. **Anomaly Detection**: Identify unusual patterns automatically
4. **Time-Series Forecasting**: Predict when metrics will cross thresholds

**PatientPoint ML Data Requirements:**
- **Positive Examples**: Historical failures with telemetry before failure
- **Negative Examples**: Devices that didn't fail (for contrast)
- **Minimum Data**: 6-12 months of telemetry + failure records

**SAY THIS:**
> *"In the demo, we're using rule-based predictions. In production, you could train a Cortex ML model on your historical failure data—devices that actually failed, correlated with their telemetry leading up to failure. This typically pushes accuracy above 90%."*

#### 🔄 Transition
> *"But how accurate are these predictions? Let me prove it..."*

---

### 📌 Prompt 7: Prediction Accuracy

```
What's our prediction accuracy based on historical failure data?
```

#### 🎯 Why This Matters to the Customer
- **Credibility** — Predictions are only useful if accurate
- **Continuous improvement** — Track accuracy over time
- **Trust building** — Data scientists can validate the model

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **Validated Accuracy** | >85% predictions match actual failures |
| **False Positive Rate** | Minimized unnecessary dispatches |
| **Model Performance** | Precision and recall metrics |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `V_PREDICTION_ACCURACY_ANALYSIS` | Accuracy metrics | 1 row |
| `MAINTENANCE_HISTORY` | Actual failures for validation | 24 tickets |
| `V_FAILURE_PREDICTIONS` | Historical predictions | Variable |

#### ✅ Auditability — How to Verify
```sql
-- See accuracy analysis (requires script 05)
SELECT * FROM V_PREDICTION_ACCURACY_ANALYSIS;

-- Manual validation: compare predictions to actual failures
SELECT COUNT(*) as PREDICTED_ISSUES,
       SUM(CASE WHEN EXISTS (
           SELECT 1 FROM MAINTENANCE_HISTORY m 
           WHERE m.DEVICE_ID = p.DEVICE_ID 
           AND m.CREATED_AT > p.PREDICTION_TIMESTAMP
       ) THEN 1 ELSE 0 END) as ACTUAL_FAILURES
FROM V_FAILURE_PREDICTIONS p;
```

**SAY THIS:**
> *"This is the proof point—we're not just making predictions, we're validating them against actual outcomes. >85% accuracy means 8 out of 10 predictions are correct. Snowflake customers consistently see 90% query accuracy with Cortex AI."*

#### 🔄 Transition
> *"Strong accuracy. Now let me show you how fast we're resolving issues when they do occur..."*

---

### 📌 Prompt 8: Resolution Performance

```
What's our mean time to resolution and how does it compare by resolution type?
```

#### 🎯 Why This Matters to the Customer
- **MTTR is a key SLA metric** — Contractual obligations
- **Remote vs dispatch comparison** — Proves the ROI of remote fixes
- **Continuous improvement** — Track performance over time

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **8x Faster Resolution** | Remote fixes in 30 min vs 4+ hours |
| **SLA Compliance** | Meeting contractual response times |
| **Efficiency Gains** | Doing more with the same team |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `V_MAINTENANCE_ANALYTICS` | Resolution times by ticket | 24 tickets |
| `V_EXECUTIVE_DASHBOARD` | Aggregated MTTR | 1 row |

#### ✅ Auditability — How to Verify
```sql
-- MTTR by resolution type
SELECT RESOLUTION_TYPE,
       COUNT(*) as TICKET_COUNT,
       ROUND(AVG(RESOLUTION_TIME_MINS), 1) as AVG_MTTR_MINS,
       ROUND(AVG(RESOLUTION_TIME_MINS)/60, 1) as AVG_MTTR_HOURS
FROM V_MAINTENANCE_ANALYTICS
GROUP BY RESOLUTION_TYPE;
```

**SAY THIS:**
> *"Remote fixes average 30 minutes. Field dispatches take 4+ hours. That's 8x faster resolution—which directly impacts uptime and revenue. This is 10x faster insights than traditional batch reporting."*

#### 🔄 Transition
> *"Now watch this—the agent can also trigger actions automatically. This is the 'act' in observe-orient-decide-ACT..."*

---

### 📌 Prompt 9: Automated Action ⭐ KEY MOMENT

```
Can you attempt a remote restart on device DEV-003 to fix the high CPU issue?
```

#### 🎯 Why This Matters to the Customer
- **Close the loop** — AI doesn't just recommend, it acts
- **Speed** — No human delay between diagnosis and fix
- **Scalability** — Automated fixes across 500K devices

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **Automated Remediation** | Agent triggers device commands |
| **Audit Trail** | Every action is logged |
| **Integration Capability** | Connects to external systems |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `SEND_DEVICE_COMMAND` procedure | Triggers remote command | N/A |
| `EXTERNAL_ACTION_LOG` | Audit trail of actions | Growing |
| `V_RECENT_EXTERNAL_ACTIONS` | Recent action history | 20 max |

#### ✅ Auditability — How to Verify

**Follow-up prompt:**
```
Show me recent external actions that were triggered
```

```sql
-- See the audit log
SELECT TIMESTAMP, ACTION_TYPE, TARGET_SYSTEM, DEVICE_ID, 
       COMMAND, STATUS, INITIATED_BY
FROM V_RECENT_EXTERNAL_ACTIONS
ORDER BY TIMESTAMP DESC;
```

**SAY THIS:**
> *"Notice what just happened—the agent didn't just recommend an action, it triggered a simulated API call to the device management system. In production, this would actually restart the device via External Functions. Every action is logged for compliance and audit. Cortex Agents aren't just chatbots—they can execute actions."*

#### 🔧 Customization for PatientPoint

| What We Used | What PatientPoint Would Use | Integration Effort |
|--------------|----------------------------|-------------------|
| **Simulated API calls** | **Real External Functions** to your systems | Snowflake External Functions setup |
| **Log table for audit** | Your **compliance/audit system** | Could write to Splunk, Datadog |
| **Device commands** | Your **device management API** commands | Map to your IoT platform SDK |

**PatientPoint Integration Points:**

| System | Integration Method | What It Does |
|--------|-------------------|--------------|
| **Device Management Platform** | External Function → REST API | Send reboot, restart, clear cache commands |
| **ServiceNow** | Native App or External Function | Create incidents, work orders |
| **Slack/Teams** | External Function → Webhook | Alert operations team |
| **PagerDuty** | External Function → API | Escalate critical issues |
| **Your IoT Platform** (AWS IoT, Azure IoT) | External Function | Device twin updates, commands |

**Production Architecture:**
```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Cortex Agent   │────▶│ External Function │────▶│ Device Mgmt API │
│  (Snowflake)    │     │  (Snowflake)      │     │ (Your Platform) │
└─────────────────┘     └──────────────────┘     └─────────────────┘
         │
         ▼
┌─────────────────┐
│  Audit Log      │
│  (Snowflake)    │
└─────────────────┘
```

**SAY THIS:**
> *"In production, the stored procedure would be replaced with an External Function that calls your device management API. Snowflake External Functions provide secure, governed API access—same RBAC, same audit trail. We can integrate with ServiceNow, Slack, PagerDuty, or any REST API."*

#### 🔄 Transition
> *"The agent just demonstrated the full loop: detect → diagnose → act. Now let's see this from the technician's perspective when a dispatch IS required..."*

---

### ✅ Operations Act Summary

| Capability | Demo Evidence | Business Value |
|------------|---------------|----------------|
| 🏢 Revenue prioritization | Top 10 by ad revenue | Focus on what matters |
| 🎯 Real-time risk | 7 devices flagged | Prevent failures |
| 🔧 Remote fix triage | 92% success rate | Avoid $185/dispatch |
| 📊 Prediction accuracy | >85% validated | Trust the AI |
| ⏱️ MTTR tracking | 8x faster remote | SLA compliance |
| 🤖 Automated action | Triggered restart | Closed-loop ops |

---

## 🔧 Act 3: Field Technician View (12:00 - 16:00)

*Persona: Field Service Technician*

### Scene Setup
> "Now let's see this from the technician's perspective. Marcus Johnson just got assigned the Springfield Urgent Care job. He's in his truck, opening the mobile app. He needs to know: What am I walking into?"

---

### 📌 Prompt 1: My Assignments

```
What work orders are assigned to Marcus Johnson today?
```

#### 🎯 Why This Matters to the Customer
- **Technician productivity** — No wasted trips to the office
- **Priority clarity** — Know which job is most urgent
- **Mobile-first** — Works from anywhere

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **Personalized View** | Each tech sees their assignments |
| **Priority Ranking** | Critical jobs surfaced first |
| **Full Context** | Issue summary visible before arrival |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `V_ACTIVE_WORK_ORDERS` | Work orders by technician | 5 active |
| `TECHNICIANS` | Technician profiles | 6 techs |

#### ✅ Auditability — How to Verify
```sql
-- Marcus's assignments
SELECT wo.WORK_ORDER_ID, wo.DEVICE_ID, d.FACILITY_NAME, 
       wo.PRIORITY, wo.ISSUE_SUMMARY
FROM V_ACTIVE_WORK_ORDERS wo
WHERE wo.TECHNICIAN_NAME = 'Marcus Johnson'
AND wo.SCHEDULED_DATE = CURRENT_DATE();
```

#### 🔄 Transition
> *"Marcus sees the Springfield job—it's marked CRITICAL. Before he drives out, he wants to know exactly what he's dealing with..."*

---

### 📌 Prompt 2: Diagnosis & Fix Instructions

```
What's wrong with device DEV-005 and how do I fix it?
```

#### 🎯 Why This Matters to the Customer
- **First-time fix rate** — Come prepared, fix it once
- **Reduced training burden** — Knowledge base on demand
- **Consistent quality** — Same procedures regardless of tech experience

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **Step-by-Step Guidance** | No guesswork in the field |
| **Knowledge Base Access** | Institutional knowledge preserved |
| **Skill Augmentation** | Junior techs perform like seniors |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `V_DEVICE_HEALTH_SUMMARY` | Current device status | 1 device |
| `TROUBLESHOOTING_KB` | Fix procedures | 10 categories |
| Cortex Search: `TROUBLESHOOTING_SEARCH_SVC` | Semantic search | 10 docs |

#### ✅ Auditability — How to Verify
```sql
-- Device current status
SELECT * FROM V_DEVICE_HEALTH_SUMMARY WHERE DEVICE_ID = 'DEV-005';

-- Relevant KB article
SELECT ISSUE_CATEGORY, DIAGNOSTIC_STEPS, REMOTE_FIX_PROCEDURE,
       REQUIRES_DISPATCH, ESTIMATED_REMOTE_FIX_TIME_MINS
FROM TROUBLESHOOTING_KB
WHERE ISSUE_CATEGORY = 'NO_NETWORK';
```

#### 🔄 Transition
> *"The agent pulled troubleshooting steps from the knowledge base. But this is a recurring issue at this facility. Let me check what worked last time..."*

---

### 📌 Prompt 3: Historical Learning

```
Find past incidents at Springfield Urgent Care and how they were resolved
```

#### 🎯 Why This Matters to the Customer
- **Pattern recognition** — Is there a systemic issue at this location?
- **Proven solutions** — What actually worked before?
- **Facility-specific knowledge** — Every location is different

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **Institutional Memory** | Learn from past successes |
| **Root Cause Patterns** | Identify recurring issues |
| **Facility Intelligence** | Location-specific insights |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `MAINTENANCE_HISTORY` | Past tickets with resolution notes | 24 records |
| Cortex Search: `MAINTENANCE_HISTORY_SEARCH_SVC` | Semantic search | 24 docs |

#### ✅ Auditability — How to Verify
```sql
-- Past incidents at this facility
SELECT TICKET_ID, DEVICE_ID, ISSUE_TYPE, RESOLUTION_TYPE,
       RESOLUTION_NOTES, TECHNICIAN_ID, CREATED_AT
FROM MAINTENANCE_HISTORY m
JOIN DEVICE_INVENTORY d ON m.DEVICE_ID = d.DEVICE_ID
WHERE d.FACILITY_NAME = 'Springfield Urgent Care'
ORDER BY CREATED_AT DESC;
```

**SAY THIS:**
> *"I can see two previous network issues—both required network cable replacement. That's valuable intel—there might be a wiring problem in that facility. Now Marcus knows exactly what to bring..."*

#### 🔄 Transition
> *"Let me make sure I have the right parts..."*

---

### 📌 Prompt 4: Parts Preparation

```
What parts might I need for a network connectivity issue?
```

#### 🎯 Why This Matters to the Customer
- **First-time fix rate** — Right parts = one trip
- **Inventory optimization** — Know what to stock in trucks
- **Customer experience** — No "I'll come back with the part"

#### 📊 Business Outcomes Demonstrated
| Outcome | What We're Proving |
|---------|-------------------|
| **Parts Prediction** | AI suggests based on past fixes |
| **Truck Stock Optimization** | Data-driven inventory |
| **Reduced Return Trips** | Fix it right the first time |

#### 🗄️ Data Being Used
| Source Table/View | What It Provides | Row Count |
|-------------------|------------------|-----------|
| `TROUBLESHOOTING_KB` | Standard parts by issue | 10 categories |
| `WORK_ORDERS.PARTS_REQUIRED` | Historical parts used | 8 records |

#### ✅ Auditability — How to Verify
```sql
-- Parts typically needed for network issues
SELECT ISSUE_CATEGORY, REMOTE_FIX_PROCEDURE
FROM TROUBLESHOOTING_KB
WHERE ISSUE_CATEGORY IN ('NO_NETWORK', 'CONNECTIVITY_INTERMITTENT');

-- Parts from past similar work orders
SELECT WORK_ORDER_ID, ISSUE_SUMMARY, PARTS_REQUIRED
FROM WORK_ORDERS
WHERE ISSUE_SUMMARY LIKE '%network%' OR ISSUE_SUMMARY LIKE '%connectivity%';
```

**SAY THIS:**
> *"Perfect—the agent recommends ethernet cable and USB network adapter based on past fixes. Marcus is now fully prepared for the job."*

---

### ✅ Field Tech Act Summary

| Feature | Benefit | Business Value |
|---------|---------|----------------|
| 📋 My work queue | Know assignments from anywhere | Productivity |
| 🔧 Fix instructions | Step-by-step from KB | First-time fix rate |
| 📖 Historical learning | What worked at this location | Pattern recognition |
| 🧰 Parts list | Come prepared | No return trips |

#### 🔧 Customization for PatientPoint (Field Tech Section)

| What We Used | What PatientPoint Would Use | Integration Effort |
|--------------|----------------------------|-------------------|
| **Work Orders table** | **ServiceNow / Field Service system** | Bi-directional sync |
| **Technician roster** | **HR/scheduling system** | Import technician data |
| **Troubleshooting KB** | **Your knowledge base** (Confluence, SharePoint) | Ingest into Cortex Search |
| **Parts inventory** | **Inventory management system** | Connect to parts database |

**PatientPoint Knowledge Base Sources:**
- **Existing Documentation**: Device manuals, troubleshooting guides
- **Tribal Knowledge**: Capture from senior technicians
- **Vendor Resources**: Manufacturer documentation
- **Past Tickets**: Resolution notes from ServiceNow

**SAY THIS:**
> *"The knowledge base is powered by Cortex Search—it does semantic search, not just keyword matching. You'd load your existing troubleshooting docs, and the AI finds the most relevant procedures. Technicians can ask questions in natural language."*

---

## 🤖 Act 4: AI Agent Capabilities (16:00 - 18:00)

*Persona: All stakeholders*

### Scene Setup
> "We've seen the agent serve three different personas with three different needs. Let me show a few more examples of what's possible—these are the kinds of ad-hoc questions that would normally require a data analyst."

---

### 📌 Prompt 1: Analytical Comparison

```
Compare average resolution time for remote fixes vs field dispatches
```

**Why it matters:** *"This proves the ROI—remote fixes in minutes vs dispatches in hours. No SQL required."*

---

### 📌 Prompt 2: Geographic Filtering

```
Which facilities in Ohio have devices needing attention?
```

**Why it matters:** *"Operations can filter by region, state, or city—natural language, no dashboard switching."*

---

### 📌 Prompt 3: Trend Analysis

```
What's the most common issue type this month and how are we resolving it?
```

**Why it matters:** *"The agent identifies trends—maybe we need a fleet-wide firmware update."*

---

### 📌 Prompt 4: ML Readiness (for technical audience)

```
What training data do we have available for building ML models?
```

**Why it matters:** *"72K telemetry records, 30 days of history—Snowflake is your ML platform, not just storage."*

---

## 🎬 Closing (18:00 - 20:00)

### The Story We Just Told

> "In 20 minutes, we followed a single issue from the executive dashboard all the way to the technician's truck:
> 
> 1. **Executive** saw fleet health, revenue protection, and flagged a satisfaction issue at Springfield
> 2. **Operations** identified at-risk devices, triaged for remote fix, triggered an automated restart, and validated prediction accuracy
> 3. **Technician** got the assignment, learned from past incidents, and came prepared with the right parts
> 
> All from natural language questions. No SQL. No dashboard switching. No waiting for reports. Every answer traceable to source data."

### Business Impact at Scale (FOCUS Results Delivered)

> "With Snowflake Intelligence and Cortex Agents, PatientPoint achieves all three FOCUS results:
> 
> **RESULT 1: 40-60% Cost Reduction** ✅
> - 70%+ issues resolved remotely → 350,000 avoided dispatches annually
> - $185 saved per remote fix → **$50M+/year in avoided costs**
> 
> **RESULT 2: Revenue Protection** ✅
> - Predictive maintenance prevents unplanned downtime
> - Zero ad revenue loss from device failures
> - Proactive fixes before screens go dark
> 
> **RESULT 3: >85% Predictive Accuracy** ✅
> - 24-48 hour advance warning of failures
> - Pattern recognition from 72K+ telemetry records
> - Validated against actual outcomes
> 
> All running natively in Snowflake—Cortex for AI, full governance through your existing security model, complete audit trail."

### Call to Action
> "Would you like to see how this could work with your data? We can set up a proof-of-concept with your actual device telemetry in days, not months."

---

## 🛠️ Pre-Demo Checklist

- [ ] SQL scripts 01-05 executed successfully
- [ ] Agent created in Snowsight (AI & ML → Agents)
- [ ] Semantic views added to agent
- [ ] Cortex Search services added
- [ ] **Test the full flow once before demo**
- [ ] Snowflake Intelligence accessible

---

## 📊 Data Inventory (For Auditability Questions)

> **Note:** Demo uses 100 representative devices. Production scales to 500,000.

| Table | Demo Records | Production Scale | Purpose | Key Columns |
|-------|--------------|------------------|---------|-------------|
| `DEVICE_INVENTORY` | 100 | 500,000 | Device master data | DEVICE_ID, STATUS, HOURLY_AD_REVENUE_USD |
| `DEVICE_TELEMETRY` | ~72,000 | ~360M/month | Health metrics (hourly) | CPU_TEMP, CPU_USAGE, MEMORY_USAGE, ERROR_COUNT |
| `MAINTENANCE_HISTORY` | 24 | ~50,000/month | Past service tickets | ISSUE_TYPE, RESOLUTION_TYPE, COST_USD |
| `TROUBLESHOOTING_KB` | 10 | 100+ | Fix procedures | ISSUE_CATEGORY, SUCCESS_RATE_PCT |
| `WORK_ORDERS` | 8 | ~10,000/day | Active jobs | PRIORITY, STATUS, AI_DIAGNOSIS |
| `TECHNICIANS` | 6 | 500+ | Field team | COVERAGE_STATES, SPECIALIZATION |
| `PROVIDER_FEEDBACK` | 14 | ~100,000 | Customer satisfaction | NPS_SCORE, SATISFACTION_RATING |
| `DEVICE_DOWNTIME` | 10 | ~25,000/month | Revenue impact | DOWNTIME_HOURS, REVENUE_LOSS_USD |
| `EXTERNAL_ACTION_LOG` | Variable | Growing | Action audit trail | ACTION_TYPE, TIMESTAMP, PAYLOAD |

---

## 🔒 Governance & Compliance Talking Points

If asked about security, governance, or compliance:

> "Everything runs inside Snowflake's security perimeter:
> - **Role-based access control** — Same RBAC you use for all Snowflake data
> - **Data never leaves Snowflake** — Cortex processes data in-place
> - **Complete audit trail** — Every query, every action logged
> - **No data copying** — AI operates on live data, not exports
> - **SOC 2, HIPAA eligible** — Snowflake's certifications apply"

---

## 💬 Objection Handling

### "How is this different from our current monitoring tool?"
> "Traditional monitoring tools show you WHAT happened. Cortex Agents tell you WHAT, WHY, and WHAT TO DO—in natural language. Plus, they can take action, not just alert."

### "What if the AI gives a wrong answer?"
> "Every answer is grounded in your data—you can see the SQL it generated. The semantic model constrains the AI to your business logic. And for actions, everything is logged for audit."

### "How long does implementation take?"
> "We can have a proof-of-concept running on your data in 1-2 weeks. Production deployment depends on integration complexity—typically 4-8 weeks."

### "What about data we have outside Snowflake?"
> "Snowflake's data sharing and integration capabilities can bring in data from almost any source. The agent works on whatever data is in Snowflake."

---

## 🗺️ PatientPoint Implementation Roadmap

### Phase 1: Data Foundation (Week 1-2)

| Task | Data Source | Snowflake Target | Owner |
|------|-------------|------------------|-------|
| Device inventory | IoT Platform | `DEVICE_INVENTORY` | IoT Team |
| Telemetry stream | IoT Platform | `DEVICE_TELEMETRY` | Data Engineering |
| Maintenance history | ServiceNow | `MAINTENANCE_HISTORY` | IT Ops |
| Ad revenue data | Ad Platform (GAM) | `AD_REVENUE` | Ad Ops |
| Provider feedback | CRM/Surveys | `PROVIDER_FEEDBACK` | Customer Success |

### Phase 2: Analytics Layer (Week 2-3)

| Task | Deliverable | Customization Needed |
|------|-------------|---------------------|
| Health score formula | `V_DEVICE_HEALTH_SUMMARY` | Tune weights for your devices |
| Risk thresholds | Risk classification logic | Analyze historical failures |
| ROI calculations | `V_ROI_ANALYSIS` | Input actual cost data |
| Semantic views | Cortex Analyst models | Map to your business terms |

### Phase 3: AI Agent (Week 3-4)

| Task | Deliverable | Effort |
|------|-------------|--------|
| Knowledge base ingestion | Cortex Search service | Load troubleshooting docs |
| Agent configuration | `DEVICE_MAINTENANCE_AGENT` | Customize instructions |
| Tool setup | Semantic views + Search | Map to your data |
| Testing | End-to-end validation | Refine responses |

### Phase 4: Integrations (Week 4-6)

| Integration | Method | Priority |
|-------------|--------|----------|
| Device Management API | External Function | High |
| ServiceNow | Native App or External Function | High |
| Slack/Teams Alerts | External Function (Webhook) | Medium |
| PagerDuty Escalation | External Function | Medium |
| ML Model Training | Cortex ML | Phase 2 |

### Quick Win: Proof of Concept Scope

**For a 2-week POC, focus on:**
1. ✅ 1,000 devices (subset of fleet)
2. ✅ 30 days of telemetry
3. ✅ Basic health score formula
4. ✅ 5-10 executive/ops prompts
5. ✅ No external integrations (simulated actions)

**This proves:**
- Natural language querying works
- Data model scales
- AI provides accurate, actionable insights

---

## 📊 PatientPoint Data Mapping Quick Reference

| Demo Data | PatientPoint Equivalent | Notes |
|-----------|------------------------|-------|
| `DEVICE_ID` (DEV-001) | Your device serial numbers | Primary key for all joins |
| `FACILITY_NAME` | Provider account name | From CRM/master data |
| `HOURLY_AD_REVENUE_USD` | CPM × impressions/hour | From ad platform |
| `CPU_TEMP_CELSIUS` | Your telemetry field name | Map 1:1 or transform |
| `HEALTH_SCORE` | Calculated field | Formula is customizable |
| `TICKET_ID` | ServiceNow incident number | For correlation |
| `TECHNICIAN_ID` | Employee ID | From HR system |

---

## 🎯 Success Metrics for POC

| Metric | Demo Baseline | POC Target | Production Target |
|--------|---------------|------------|-------------------|
| Query accuracy | 90% | 85% | 90%+ |
| Response time | <5 sec | <10 sec | <5 sec |
| User adoption | N/A | 5 pilot users | 50+ users |
| Remote fix rate | 60% | Measure baseline | 60%+ |
| Prediction accuracy | 85% | Measure baseline | 85%+ |
