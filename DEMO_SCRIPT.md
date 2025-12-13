# 🎬 PatientPoint Predictive Maintenance Demo Script

**Duration:** 20 minutes  
**Audience:** PatientPoint IT Leadership, Operations, Field Services  
**Platform:** Snowflake Intelligence + Cortex Agents

---

## 📋 Demo Overview

This demo addresses **4 key personas** with distinct needs:

| Persona | Focus | Time |
|---------|-------|------|
| 🎯 **Executive (C-Suite)** | KPIs, ROI, strategic metrics | 4 min |
| 🖥️ **Operations Center** | Fleet monitoring, predictions, dispatch | 6 min |
| 🔧 **Field Technician** | Work orders, troubleshooting, repair guidance | 4 min |
| 🤖 **AI Agent Demo** | Natural language, conversational AI | 4 min |

---

## 🎬 Opening (0:00 - 2:00)

**Talking Points:**
> "PatientPoint operates 500,000 IoT devices—HealthScreen displays—across hospitals and clinics nationwide. When a screen fails, it costs $150-300 per field dispatch, and patients miss critical health information. At that scale, even a 1% failure rate means 5,000 potential dispatches. Today I'll show you how Snowflake Intelligence and Cortex Agents transform their maintenance operations."

**Actions:**
1. Open **Snowflake Intelligence** (AI & ML → Snowflake Intelligence)
2. Select the **Device Maintenance Assistant** agent
3. Briefly show the chat interface

---

## 🎯 Act 1: Executive Dashboard (2:00 - 6:00)

*Persona: C-Suite / VP of Operations*

### Talking Points
> "Let's start with what executives care about: the big picture. Our AI agent can instantly surface KPIs that used to require multiple dashboards and hours of report generation."

### Prompts to Demo

**Prompt 1: Executive Summary**
```
Give me an executive summary of our device fleet health and business impact
```
*Expected Response: Fleet size (100 devices), uptime %, cost savings, NPS score, revenue impact*

**Prompt 2: Cost Savings**
```
How much money have we saved this month from remote fixes vs field dispatches?
```
*Expected Response: Cost savings breakdown, remote fix rate (60%+), avoided dispatch costs ($185 each)*

**Prompt 3: Customer Satisfaction**
```
What is our customer satisfaction score and which facilities need follow-up?
```
*Expected Response: NPS score, satisfaction ratings, list of facilities with pending follow-ups*

### Key Metrics to Highlight
| Metric | Value | Talking Point |
|--------|-------|---------------|
| 🟢 Fleet uptime | ~85% | "At 500K devices, 85% uptime means 75K devices need attention" |
| 💰 Cost savings | $1,665+ (demo) | "Each remote fix saves $185—at scale that's millions annually" |
| ⭐ NPS Score | 6.5 | "Room for improvement through proactive maintenance" |
| 📊 Remote resolution rate | 60%+ | "At 500K devices, that's 300K+ issues avoided per year" |

> **Note:** Demo uses 100 sample devices representing patterns across the full 500K fleet.

---

## 🖥️ Act 2: Operations Center (6:00 - 12:00)

*Persona: IT Manager / Facilities Operations*

### Talking Points
> "Now let's look at what the operations team sees every day. They need real-time visibility and predictive alerts to prevent failures before they happen. This is where AI really shines."

### Prompts to Demo

**Prompt 1: Predictive Alerts**
```
Which devices are predicted to fail in the next 48 hours?
```
*Show: Predictive capability with probability scores (78%, 65%, etc.) and lead times*

**Prompt 2: Work Order Management**
```
Show me all active work orders and their priority
```
*Show: Work order queue with CRITICAL, HIGH, MEDIUM priorities and assignment status*

**Prompt 3: Risk Assessment**
```
Which devices have critical or high risk levels right now?
```
*Show: Real-time risk detection with specific device IDs and risk factors*

**Prompt 4: Remote Fix Triage** *(Natural follow-up)*
```
Can any of these critical or high risk devices be fixed remotely?
```
*Show: AI cross-references device issues with KB to identify remote fix opportunities*

*Expected Response: Agent identifies which issues (HIGH_CPU, MEMORY_LEAK, DISPLAY_FREEZE) can be fixed remotely with 87-94% success rates, vs. issues requiring dispatch (NO_NETWORK, OVERHEATING hardware)*

> **💡 Talking Point:** "This is the power of combining structured data with a knowledge base. The agent doesn't just alert—it recommends the most cost-effective action. At scale, this optimization is worth millions."

**Prompt 5: Device Deep-Dive**
```
What's the status of device DEV-005 and what's causing the issue?
```
*Show: Detailed device diagnostics - CPU temp trends, memory usage, error counts, recommended actions*

### Key Points to Highlight
| Capability | Demo Evidence |
|------------|---------------|
| 🔮 Predictive accuracy | >85% based on historical patterns |
| ⏰ Lead time | 24-48 hours advance warning |
| 🎯 AI-generated work orders | Work orders created from predictions |
| 📍 Trend analysis | Rising temperatures, memory leaks detected |

---

## 🔧 Act 3: Field Technician View (12:00 - 16:00)

*Persona: Field Service Technician*

### Talking Points
> "When a technician is dispatched, they need clear instructions—not a 50-page manual. The AI agent searches our knowledge base and learns from past incidents to provide step-by-step guidance."

### Prompts to Demo

**Prompt 1: Troubleshooting Steps**
```
How do I fix a frozen display screen?
```
*Show: Cortex Search retrieving troubleshooting steps from KB with success rates*

**Prompt 2: Technician Work Queue**
```
What work orders are assigned to Marcus Johnson today?
```
*Show: Technician-specific work queue with locations, priorities, estimated times*

**Prompt 3: Historical Learning**
```
Find past incidents similar to overheating issues and how they were resolved
```
*Show: Past incident search with resolution notes and outcomes*

**Prompt 4: Repair Guidance**
```
What parts might I need for a device with boot failure?
```
*Show: AI providing repair guidance based on KB and historical data*

### Key Points to Highlight
| Feature | Value |
|---------|-------|
| 📚 Knowledge base | 10 issue categories with detailed procedures |
| 🔍 Semantic search | Finds relevant procedures even with imprecise queries |
| 📖 Historical learning | Past incidents inform current repairs |
| ✅ Success rates | 87-98% for remote fixes by issue type |

---

## 🤖 Act 4: AI Agent Capabilities (16:00 - 20:00)

*Persona: All stakeholders*

### Talking Points
> "The power of this solution is that anyone can ask questions in natural language. No SQL required, no dashboard navigation, no waiting for IT to run a report. Just ask."

### Rapid-Fire Prompts (show versatility)

**Prompt 1: ML Readiness**
```
What training data do we have available for building ML models?
```
*Show: Data foundation summary - 72K telemetry records, 30 days history*

**Prompt 2: Analytical Query**
```
Compare average resolution time for remote fixes vs field dispatches
```
*Show: MTTR comparison - remote fixes in minutes vs dispatches in hours*

**Prompt 3: Geographic Filter**
```
Which facilities in Michigan have devices needing attention?
```
*Show: State-level filtering and drill-down*

**Prompt 4: Pattern Analysis**
```
What's the most common issue type this month and how are we resolving it?
```
*Show: Issue type breakdown with resolution patterns*

---

## 🎬 Closing (18:00 - 20:00)

### Summary Talking Points

> "With Snowflake Intelligence and Cortex Agents, PatientPoint can manage their 500,000 device fleet with:
> 
> ✅ **Predict failures** 24-48 hours before they happen with >85% accuracy
> 
> ✅ **Resolve 60%+ of issues remotely**—that's 300,000+ avoided dispatches annually
> 
> ✅ **Save $50M+/year** in avoided dispatch costs at scale ($185 × 300K)
> 
> ✅ **Reduce MTTR** from hours to minutes for remote fixes
> 
> ✅ **Improve customer satisfaction** across 500K touchpoints
> 
> All of this runs natively in Snowflake—no external ML platforms, no separate agent frameworks, and full governance through your existing Snowflake security model."

### Call to Action
> "Would you like to see how this could work with your data? We can set up a proof-of-concept in days, not months."

---

## 💬 Backup Prompts by Persona

### Executive (C-Suite)
```
Give me an executive summary of fleet health
How much money have we saved from remote fixes?
What is our NPS score?
What's our uptime percentage this month?
How many critical issues do we have right now?
```

### Operations Center
```
Which devices are predicted to fail in the next 48 hours?
Which devices have critical or high risk levels right now?
Can any of these devices be fixed remotely?
Show me all active work orders
Which technicians are available for dispatch?
What devices in Ohio need attention?
Show me the trend of device failures this month
```

### Field Technician
```
How do I fix a frozen display screen?
What are the troubleshooting steps for high CPU usage?
Find past incidents similar to network connectivity issues
What work orders are assigned to me?
Which issues typically require a field visit vs remote fix?
```

### Analytical Queries
```
What's our prediction accuracy based on historical data?
Compare resolution times by issue type
Show me devices with the longest time since maintenance
What patterns appear before device failures?
Which facilities have the most recurring issues?
```

---

## 🛠️ Pre-Demo Checklist

- [ ] SQL scripts 01-05 executed successfully
- [ ] Agent created in Snowsight (AI & ML → Agents)
- [ ] Semantic views added to agent (SV_DEVICE_FLEET, SV_MAINTENANCE_ANALYTICS, SV_BUSINESS_IMPACT, SV_OPERATIONS)
- [ ] Cortex Search services added (TROUBLESHOOTING_SEARCH_SVC, MAINTENANCE_HISTORY_SEARCH_SVC)
- [ ] Test prompts verified working
- [ ] Snowflake Intelligence accessible

---

## 📊 Expected Demo Data

> **Note:** Demo uses a representative sample of 100 devices. In production, this scales to PatientPoint's full 500,000 device fleet.

| Table | Demo Records | Production Scale | Purpose |
|-------|--------------|------------------|---------|
| DEVICE_INVENTORY | 100 | 500,000 | Device fleet |
| DEVICE_TELEMETRY | ~72,000 | ~360M/month | 30 days of health metrics |
| MAINTENANCE_HISTORY | 15 | ~50,000/month | Past service tickets |
| TROUBLESHOOTING_KB | 10 | 100+ | Fix procedures |
| WORK_ORDERS | 8 | ~10,000/day | Active/completed jobs |
| TECHNICIANS | 6 | 500+ | Field team roster |
| PROVIDER_FEEDBACK | 13 | ~100,000 | Customer satisfaction |
| DEVICE_DOWNTIME | 10 | ~25,000/month | Revenue impact data |

