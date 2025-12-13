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

## 💰 Key Value Drivers (Use in Talking Points)

### Operational Cost Reduction
| Benefit | Impact |
|---------|--------|
| **Reduced Downtime** | Predict issues before they occur → dramatic reduction in unplanned failures |
| **Optimized Scheduling** | Eliminate unnecessary preventive maintenance while ensuring critical interventions |
| **Lower Field Costs** | Faster fault isolation + targeted repairs → reduced labor and travel expenses |

### Performance Improvements
| Metric | Value |
|--------|-------|
| **Faster Insights** | 10x faster real-time predictive analytics for immediate decision-making |
| **Query Accuracy** | 90% accuracy with advanced AI models vs traditional approaches |
| **Extended Asset Life** | Proactive maintenance defers capital expenditure by optimizing equipment cycles |

### Customer Success Examples (Use as Social Proof)
| Customer | Results |
|----------|---------|
| **FIIX** | 10x improvement in maintenance insights, reduced asset downtime, eliminated manual querying for 40,000+ customers |
| **Toyota** | Minimized production disruptions, extended equipment life, improved maintenance cost-effectiveness |
| **Telecom Operators** | Reduced field maintenance costs, improved SLA compliance, optimized battery replacement cycles |

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

**Talking Points (aligned to FOCUS Challenges):**
> "PatientPoint operates 500,000 IoT devices—HealthScreen displays—across hospitals and clinics nationwide. These screens generate **advertising revenue from pharmaceutical partners**. When a screen fails, three things happen:
> 
> 1. **Lost Revenue**: Every hour offline means lost ad impressions and revenue
> 2. **High Costs**: Field dispatch costs $150-300 per visit
> 3. **Unpredictable Downtime**: Reactive maintenance means you don't know what's failing until it's down
> 
> Today I'll show you how Snowflake Intelligence and Cortex Agents solve all three with **predictive AI**."

**The Snowflake Advantage (weave in as appropriate):**
> "What makes this different from traditional monitoring tools?
> - **10x faster insights**: Real-time predictive analytics vs. batch reporting
> - **90% query accuracy**: Cortex AI models outperform rule-based approaches  
> - **Extended asset life**: Proactive maintenance defers capital expenditure
> 
> Companies like FIIX, Toyota, and major telecom operators have already achieved these results with Snowflake."

**Actions:**
1. Open **Snowflake Intelligence** (AI & ML → Snowflake Intelligence)
2. Select the **Device Maintenance Assistant** agent
3. Briefly show the chat interface

---

## 🎯 Act 1: Executive Dashboard (2:00 - 6:00)

*Persona: C-Suite / VP of Operations*

### Scene Setup
> "Let's start with what executives care about: the big picture. Imagine you're the VP of Operations walking into a Monday morning meeting. You need instant answers."

---

### Prompt 1: The Big Picture
```
Give me a summary of our device fleet health and business impact
```

**Transition:** *"Good overview. I see we have strong uptime, but let me dig into the financials..."*

---

### Prompt 2: Revenue Protection (addresses Challenge #1)
```
How much advertising revenue are we losing from device downtime?
```

**Transition:** *"Zero revenue loss this month—that's our revenue protection working. But how are we achieving this? Let's look at cost savings..."*

---

### Prompt 3: ROI & Cost Baseline (addresses C-Suite #1 question) 🆕
```
What's our annual field service cost and projected savings with predictive maintenance?
```

**Talking Point:** *"This is the ROI story: we spend $185M annually on field dispatches at 500K devices. With 60%+ remote resolution, we're projecting $96M in annual savings—that's a 52% cost reduction."*

> 💡 **Value Driver Callout:** *"This aligns with what we've seen at other customers. FIIX achieved 10x improvement in maintenance insights. The ROI typically justifies the investment within the first year."*

**Transition:** *"Let me show you the actual savings we're achieving..."*

---

### Prompt 4: Cost Savings (addresses Challenge #2)
```
How much money have we saved this month from remote fixes vs field dispatches?
```

**Transition:** *"That's real savings happening now—on track for 40-60% reduction in field service costs. But I noticed the NPS score. Let's check customer satisfaction..."*

---

### Prompt 5: Customer Pulse (follows from NPS mention)
```
What is our customer satisfaction score and which facilities need follow-up?
```

**Transition:** *"I see Springfield Urgent Care flagged for follow-up. Let's hand this over to Operations to understand what's happening there..."*

---

### Key Takeaways for Executive (Mapped to FOCUS Results)
| FOCUS Result | Metric | Demo Value | Scale Impact |
|--------------|--------|------------|--------------|
| 💵 **Revenue Protection** | Ad revenue loss | $0 | Millions protected |
| 💰 **40-60% Cost Reduction** | Annual baseline + savings | $2,500+/month | **$50M+/year** |
| 🎯 **>85% Prediction Accuracy** | Remote resolution | 70%+ | 350K dispatches avoided |
| ⭐ Customer Satisfaction | NPS Score | 8.6 | Loyalty driver |

---

## 🖥️ Act 2: Operations Center (6:00 - 12:00)

*Persona: IT Manager / Facilities Operations*

### Scene Setup
> "Now let's switch to the Operations Center. The executive just flagged Springfield Urgent Care. But as an ops manager, you need to see the full picture of what's at risk today."

---

### Prompt 1: Top Facilities Overview 🆕
```
Show me device health across our top 10 facilities by ad revenue
```

**Talking Point:** *"Operations teams need to prioritize by business impact. This shows our highest-revenue facilities and their device health."*

**Transition:** *"Good overview. Now let me drill into what's at risk right now across the entire fleet..."*

---

### Prompt 2: What's At Risk Right Now?
```
Which devices have critical or high risk levels right now?
```

**Transition:** *"I see 7 devices flagged—including DEV-005 at Springfield Urgent Care that the executive mentioned. Before I dispatch technicians, let me see if any of these can be fixed remotely..."*

---

### Prompt 3: Triage for Remote Fixes (follows naturally)
```
Can any of these critical or high risk devices be fixed remotely?
```

**Transition:** *"Great—the agent identified that HIGH_CPU and MEMORY_LEAK issues can be fixed remotely with 92% success rate. Let me try that first on DEV-005..."*

---

### Prompt 4: Deep Dive on Problem Device (follows from triage)
```
What's the status of device DEV-005 at Springfield Urgent Care and what's causing the issue?
```

**Transition:** *"I see it's a network connectivity issue—that explains the degraded status. This facility has had 3 network issues in 60 days. Let me check if we already have work orders for this..."*

---

### Prompt 5: Work Order Status (follows from device issue)
```
Show me all active work orders and their priority
```

**Transition:** *"I see there's already a CRITICAL work order for DEV-005. Good—let's look at our predictive capabilities..."*

---

### Prompt 6: Predictive Intelligence
```
Which devices are predicted to fail in the next 48 hours?
```

**Transition:** *"This is the power of predictive maintenance—we can see failures before they happen. But how accurate are these predictions? Let me show you..."*

---

### Prompt 7: Prediction Accuracy (proves AI credibility) 🆕
```
What's our prediction accuracy based on historical failure data?
```

**Talking Point:** *"This is the proof point—we're not just making predictions, we're validating them against actual outcomes. >85% accuracy means 8 out of 10 predictions are correct."*

> 💡 **Value Driver Callout:** *"Snowflake customers consistently see 90% query accuracy with Cortex AI models—significantly outperforming traditional rule-based approaches."*

**Transition:** *"Strong accuracy. Now let me show you how fast we're resolving issues..."*

---

### Prompt 8: MTTR Performance 🆕
```
What's our mean time to resolution and how does it compare by resolution type?
```

**Talking Point:** *"Remote fixes average 30 minutes. Field dispatches take 4+ hours. That's 8x faster resolution—which directly impacts uptime and revenue."*

> 💡 **Value Driver Callout:** *"This is 10x faster insights than traditional batch reporting. Real-time predictive analytics enable immediate operational decision-making."*

**Transition:** *"Now watch this—the agent can also trigger actions automatically..."*

---

### Prompt 9: Automated Action (Key Demo Moment! 🎯)
```
Can you attempt a remote restart on device DEV-003 to fix the high CPU issue?
```

**Talking Point:** *"Notice what just happened—the agent didn't just recommend an action, it triggered a simulated API call to the device management system. In production, this would actually restart the device."*

**Follow-up to show the log:**
```
Show me recent external actions that were triggered
```

*Show: V_RECENT_EXTERNAL_ACTIONS displays the API call that was logged*

> **💡 Key Message:** "Cortex Agents aren't just chatbots—they can execute actions. With External Functions, this same pattern connects to ServiceNow, Slack, PagerDuty, or your device management API."

**Transition:** *"The agent just demonstrated the full loop: detect → diagnose → act. Now let's see this from the technician's perspective..."*

---

### Key Takeaways for Operations
| Capability | Demo Evidence |
|------------|---------------|
| 🏢 Top facility prioritization | Filter by revenue impact |
| 🎯 Real-time risk detection | 7 devices flagged across fleet |
| 🔧 Remote fix triage | AI recommends most cost-effective action |
| 📊 Prediction accuracy | >85% validated against actuals |
| ⏱️ MTTR tracking | 8x faster with remote fixes |
| 🔮 48-hour predictions | Lead time to prevent failures |

---

## 🔧 Act 3: Field Technician View (12:00 - 16:00)

*Persona: Field Service Technician*

### Scene Setup
> "Now let's see this from the technician's perspective. Marcus Johnson just got assigned the Springfield Urgent Care job. He's in his truck, opening the app. He needs to know: What am I walking into?"

---

### Prompt 1: My Assignments Today
```
What work orders are assigned to Marcus Johnson today?
```

**Transition:** *"Marcus sees he has the Springfield job—it's marked CRITICAL. Before he drives out, he wants to know what he's dealing with..."*

---

### Prompt 2: Understanding the Problem (follows from assignment)
```
What's wrong with device DEV-005 and how do I fix it?
```

**Transition:** *"The agent pulled the troubleshooting steps from the knowledge base. But this is a recurring network issue at this facility. Let me check what worked last time..."*

---

### Prompt 3: Learning from History (follows from recurring issue)
```
Find past incidents at Springfield Urgent Care and how they were resolved
```

**Transition:** *"I can see two previous network issues—both required network cable replacement. That's valuable intel. Let me make sure I have the right parts..."*

---

### Prompt 4: Parts Preparation (follows from resolution history)
```
What parts might I need for a network connectivity issue?
```

**Transition:** *"Perfect—the agent recommends ethernet cable and USB network adapter based on past fixes. Marcus is now fully prepared for the job."*

---

### Key Takeaways for Field Tech
| Feature | Benefit |
|---------|---------|
| 📋 My work queue | Know what's assigned before leaving |
| 🔧 Fix instructions | Step-by-step from knowledge base |
| 📖 Historical learning | What worked at this facility before |
| 🧰 Parts list | Come prepared, fix first time |

---

## 🤖 Act 4: AI Agent Capabilities (16:00 - 20:00)

*Persona: All stakeholders*

### Scene Setup
> "We've seen the agent serve three different personas with three different needs. Let's show a few more examples of what's possible with natural language queries."

---

### Prompt 1: Analytical Comparison
```
Compare average resolution time for remote fixes vs field dispatches
```

**Why it matters:** *"This proves the ROI—remote fixes in minutes vs dispatches in hours."*

---

### Prompt 2: Geographic Drill-Down
```
Which facilities in Ohio have devices needing attention?
```

**Why it matters:** *"Operations can filter by region, state, or city—no SQL required."*

---

### Prompt 3: Pattern Recognition
```
What's the most common issue type this month and how are we resolving it?
```

**Why it matters:** *"The agent identifies trends—maybe we need a firmware update fleet-wide."*

---

### Prompt 4: ML Readiness (for technical audience)
```
What training data do we have available for building ML models?
```

**Why it matters:** *"72K telemetry records, 30 days of history—ready for custom ML."*

---

## 🎬 Closing (18:00 - 20:00)

### The Story We Just Told

> "In 20 minutes, we followed a single issue from the executive dashboard all the way to the technician's truck:
> 
> 1. **Executive** saw fleet health and flagged a customer satisfaction issue at Springfield
> 2. **Operations** identified the at-risk device, triaged it for remote vs. dispatch, and found a pattern
> 3. **Technician** got the assignment, learned from past incidents, and came prepared with the right parts
> 
> All from natural language questions. No SQL. No dashboard switching. No waiting for reports."

### Business Impact at Scale (FOCUS Results Delivered)

> "With Snowflake Intelligence and Cortex Agents, PatientPoint achieves all three FOCUS results:
> 
> **RESULT 1: 40-60% Cost Reduction** ✅
> - 70%+ issues resolved remotely → 350,000 avoided dispatches annually
> - $185 saved per remote fix → **$50M+/year in avoided costs**
> - *Like FIIX: 10x improvement in maintenance insights for 40,000+ customers*
> 
> **RESULT 2: Revenue Protection** ✅
> - Predictive maintenance prevents unplanned downtime
> - Zero ad revenue loss from device failures
> - Proactive fixes before screens go dark
> - *Like Toyota: Minimized production disruptions, extended equipment life*
> 
> **RESULT 3: >85% Predictive Accuracy** ✅
> - 24-48 hour advance warning of failures
> - Pattern recognition from 72K+ telemetry records
> - ML-ready data foundation in Snowflake
> - *Like Telecom operators: Improved SLA compliance, optimized replacement cycles*
> 
> All running natively in Snowflake—Cortex ML for predictions, Cortex Analyst for natural language, and full governance through your existing security model."

### Financial Impact Summary

| Impact Category | PatientPoint Value |
|-----------------|-------------------|
| 📈 **Revenue Growth** | Increased ad impressions through maximized uptime |
| 💵 **Direct Cost Savings** | $50M+/year from reduced dispatches |
| 🛡️ **Risk Mitigation** | Prevention of catastrophic failures affecting revenue |
| 🏭 **Capital Optimization** | Extended device lifespan → deferred replacement costs |

> **ROI Timeline:** The combination of improved uptime, reduced maintenance costs, and extended asset life typically delivers ROI that justifies IoT predictive maintenance investments **within the first year of implementation**.

### Call to Action
> "Would you like to see how this could work with your data? We can set up a proof-of-concept in days, not months. Other Snowflake customers like FIIX and Toyota have seen 10x improvements in maintenance operations."

---

## 💬 Alternative Prompts by Persona

Use these if the primary flow doesn't work or if you have extra time.

### Executive (C-Suite)
```
Give me an executive summary of fleet health
How much revenue are we losing from device downtime?
What's our annual field service cost and projected savings?
What's our uptime percentage this month?
How many critical issues do we have right now?
What's the ROI on predictive maintenance?
```

### Operations Center
```
Which devices are predicted to fail in the next 48 hours?
What's our prediction accuracy based on historical data?
What's our mean time to resolution by issue type?
Show me device health across our top 10 facilities
What's causing the most device failures this month?
Which technicians are available for dispatch right now?
Show me devices with the longest time since maintenance
```

### Field Technician
```
How do I fix a frozen display screen?
What are the troubleshooting steps for high CPU usage?
Which issues typically require a field visit vs remote fix?
What's the success rate for fixing memory leaks remotely?
```

### Analytical Queries
```
What's our prediction accuracy based on historical data?
Compare resolution times by issue type
What patterns appear before device failures?
Which facilities have the most recurring issues?
```

---

## 🛠️ Pre-Demo Checklist

- [ ] SQL scripts 01-05 executed successfully
- [ ] Agent created in Snowsight (AI & ML → Agents)
- [ ] Semantic views added to agent
- [ ] Cortex Search services added
- [ ] **Test the full flow once before demo**
- [ ] Snowflake Intelligence accessible

---

## 📊 Expected Demo Data

> **Note:** Demo uses 100 representative devices. Production scales to 500,000.

| Table | Demo Records | Production Scale | Purpose |
|-------|--------------|------------------|---------|
| DEVICE_INVENTORY | 100 | 500,000 | Device fleet |
| DEVICE_TELEMETRY | ~72,000 | ~360M/month | Health metrics |
| MAINTENANCE_HISTORY | 24 | ~50,000/month | Past tickets |
| TROUBLESHOOTING_KB | 10 | 100+ | Fix procedures |
| WORK_ORDERS | 8 | ~10,000/day | Active jobs |
| TECHNICIANS | 6 | 500+ | Field team |
| PROVIDER_FEEDBACK | 14 | ~100,000 | Customer satisfaction |
| DEVICE_DOWNTIME | 10 | ~25,000/month | Revenue impact |
