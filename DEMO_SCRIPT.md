# 🎬 PatientPoint Predictive Maintenance Demo Script

**Duration:** 20 minutes  
**Audience:** PatientPoint IT Leadership, Operations, Field Services  
**Platform:** Snowflake Intelligence + Cortex Agents

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

**Talking Points:**
> "PatientPoint operates 500,000 IoT devices—HealthScreen displays—across hospitals and clinics nationwide. When a screen fails, it costs $150-300 per field dispatch, and patients miss critical health information. At that scale, even a 1% failure rate means 5,000 potential dispatches. Today I'll show you how Snowflake Intelligence and Cortex Agents transform their maintenance operations."

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
Give me an executive summary of our device fleet health and business impact
```

**Transition:** *"Good overview. I see we have strong uptime, but let me dig into the financials..."*

---

### Prompt 2: Cost Impact (follows from summary)
```
How much money have we saved this month from remote fixes vs field dispatches?
```

**Transition:** *"That's impressive—$2,500+ saved this month just from remote fixes. But I noticed the NPS score. Let's look at customer satisfaction..."*

---

### Prompt 3: Customer Pulse (follows from NPS mention)
```
What is our customer satisfaction score and which facilities need follow-up?
```

**Transition:** *"I see Springfield Urgent Care flagged for follow-up. Let's hand this over to Operations to understand what's happening there..."*

---

### Key Takeaways for Executive
| Metric | Value | Scale Impact (500K devices) |
|--------|-------|----------------------------|
| 💰 Remote fix savings | $2,500+/month | **$15M+/year** |
| 🟢 Fleet uptime | 92%+ | 40K devices need monitoring |
| ⭐ NPS Score | 8.6 | Customer loyalty driver |
| 📊 Remote resolution | 70%+ | 350K dispatches avoided/year |

---

## 🖥️ Act 2: Operations Center (6:00 - 12:00)

*Persona: IT Manager / Facilities Operations*

### Scene Setup
> "Now let's switch to the Operations Center. The executive just flagged Springfield Urgent Care. But as an ops manager, you need to see the full picture of what's at risk today."

---

### Prompt 1: What's At Risk Right Now?
```
Which devices have critical or high risk levels right now?
```

**Transition:** *"I see 7 devices flagged—including DEV-005 at Springfield Urgent Care that the executive mentioned. Before I dispatch technicians, let me see if any of these can be fixed remotely..."*

---

### Prompt 2: Triage for Remote Fixes (follows naturally)
```
Can any of these critical or high risk devices be fixed remotely?
```

**Transition:** *"Great—the agent identified that HIGH_CPU and MEMORY_LEAK issues can be fixed remotely with 92% success rate. Let me try that first on DEV-005..."*

---

### Prompt 3: Deep Dive on Problem Device (follows from triage)
```
What's the status of device DEV-005 at Springfield Urgent Care and what's causing the issue?
```

**Transition:** *"I see it's a network connectivity issue—that explains the degraded status. This facility has had 3 network issues in 60 days. Let me check if we already have work orders for this..."*

---

### Prompt 4: Work Order Status (follows from device issue)
```
Show me all active work orders and their priority
```

**Transition:** *"I see there's already a CRITICAL work order for DEV-005. Good—let's make sure a technician is assigned and has what they need..."*

---

### Prompt 5: Predictive Intelligence (bonus if time)
```
Which devices are predicted to fail in the next 48 hours?
```

**Transition:** *"This is the power of predictive maintenance—we can see failures 24-48 hours before they happen. Let's switch to the technician's perspective..."*

---

### Key Takeaways for Operations
| Capability | Demo Evidence |
|------------|---------------|
| 🎯 Real-time risk detection | 7 devices flagged across fleet |
| 🔧 Remote fix triage | AI recommends most cost-effective action |
| 📍 Facility pattern recognition | Springfield flagged for network audit |
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

### Business Impact at Scale

> "With Snowflake Intelligence and Cortex Agents, PatientPoint can manage their 500,000 device fleet with:
> 
> ✅ **Predict failures** 24-48 hours before they happen with >85% accuracy
> 
> ✅ **Resolve 70%+ of issues remotely**—that's 350,000 avoided dispatches annually
> 
> ✅ **Save $50M+/year** in avoided dispatch costs at scale ($185 × 350K)
> 
> ✅ **Reduce MTTR** from hours to minutes for remote fixes
> 
> ✅ **Improve customer satisfaction** with proactive maintenance
> 
> All running natively in Snowflake—no external ML platforms, no separate agent frameworks, and full governance through your existing Snowflake security model."

### Call to Action
> "Would you like to see how this could work with your data? We can set up a proof-of-concept in days, not months."

---

## 💬 Alternative Prompts by Persona

Use these if the primary flow doesn't work or if you have extra time.

### Executive (C-Suite)
```
Give me an executive summary of fleet health
How much revenue are we losing from device downtime?
What's our uptime percentage this month?
How many critical issues do we have right now?
```

### Operations Center
```
Which devices are predicted to fail in the next 48 hours?
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
