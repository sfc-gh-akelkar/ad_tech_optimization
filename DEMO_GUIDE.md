## PatientPoint Predictive Maintenance Demo Guide (FOCUS Framework)

### What you’re selling (one sentence)
Snowflake turns PatientPoint’s screen telemetry + maintenance history into **early warning + predicted failures + automated remote fixes**, so PatientPoint can **protect ad revenue**, **cut field-service costs**, and **reduce operational risk**—with **governed, explainable AI**.

---

## The Focus Framework (keep repeating this)

### Challenge (WHY this matters for PatientPoint)
- **Make money (revenue protection)**: Screen downtime = missed ad impressions for pharma partners → direct revenue leakage + partner dissatisfaction.
- **Save money (operational efficiency)**: Reactive break/fix drives expensive field dispatches, rush parts, overtime, and wasted “hunt-and-peck” troubleshooting.
- **Reduce risk (brand + SLA + compliance posture)**: Unpredictable outages create reputational risk with clinics and partners, plus operational risk from manual processes and inconsistent remediation.

### Action (WHAT the solution does)
- **Act 2 – Early warning**: Anomaly watchlist (baseline 14d vs scoring 1d) flags devices drifting before they cross thresholds.
- **Act 3 – 24–48h prediction**: Failure predictions + confidence + (demo) accuracy tracking vs deterministic scenario incidents.
- **Ops Center – Operationalization**: Auto-generated work orders with recommended channel (remote vs field), priority, and due-by.
- **Act 5 – Automated remote resolution (simulated)**: Runbooks + executions + escalation when remote is unlikely to succeed.
- **Snowflake Intelligence (Agent)**: One chat interface that uses **Cortex Analyst** (semantic views) + **Cortex Search** (KB) to answer exec + ops + technician questions.

### Result (WHAT outcomes you show, credibly)
- **Observed outcomes** (from the data): downtime hours, revenue impact, remote success rates by failure type.
- **Transparent estimates** (assumption-driven): revenue protected and field cost avoided based on editable assumptions (`OPERATIONS.DEMO_ASSUMPTIONS`).
- **Demo accuracy**: reported as “demo evaluation vs deterministic scenario incidents,” not production ML accuracy.

---

## What makes Snowflake special (say this early)
- **One platform**: data + governance + AI + orchestration + semantic layer + retrieval—no brittle multi-system glue.
- **Governed AI**: semantic views + role-based access + auditable SQL = controlled, explainable answers.
- **Business-facing AI**: Cortex Analyst translates natural language → SQL on curated semantic views (not raw tables).
- **Real operational workflow**: alerts → work orders → remediation steps → outcomes → KPIs, all as first-class data products.
- **Time-to-value**: you can start with “credible simulation” (Acts 2/3/5) and swap in production ML later without redesigning the system.

---

## Demo setup (1–2 minutes)

### Run order (already in repo)
Use the ordered script list you already have (Act 1 → semantic layer → search → semantic views → watchlist → predictions → work orders → remediation → exec KPIs → agent).

### Demo posture (credibility statements)
- “This is realistic synthetic telemetry + labeled scenario incidents for demo repeatability.”
- “Where we estimate savings, we show the assumptions table and keep it editable.”
- “The AI Agent doesn’t guess—everything is grounded in semantic views or the KB search tool.”

---

## The live demo (10–15 minutes, structured to WOW)

### Segment 1 — Exec hook (2 minutes): “Stop revenue leakage”
**Goal**: anchor on PatientPoint’s business.

In Snowsight (or via Agent), show:
- `ANALYTICS.V_EXEC_KPIS` (or semantic view `SV_EXEC_KPIS`)

Talk track:
- “Here’s the fleet health snapshot and the operational load.”
- “Here’s **observed downtime and observed revenue impact** from historical incidents.”
- “Here are **explicit, editable assumptions** used for any ‘avoided cost’ estimates—no black box ROI.”

Ask the Agent (copy/paste):
- “Show executive KPIs: fleet size, critical/warning now, predicted failures in 48h, downtime hours and revenue impact in the last 30 days.”
- “Which KPIs are observed vs estimated? Show the assumptions driving the estimates.”

**WOW moment**: “We can show revenue-at-risk and operational burden with full lineage—then connect it to the actions being taken.”

---

### Segment 2 — Ops Center (4–5 minutes): “From signals to a ranked queue”
**Goal**: show early warning + prediction + prioritization.

Ask the Agent:
- “What devices should the ops team look at first today and why?”
  - Should pull from `SV_ANOMALY_WATCHLIST` with domain scores + why-flagged.
- “Which devices are likely to fail in the next 48 hours?”
  - Should pull from `SV_FAILURE_PREDICTIONS` with probability + predicted failure type.

Talk track:
- “This is the shift from reactive to proactive. Instead of 1,000 charts, the team gets a ranked watchlist and predicted failures.”
- “Each item is explainable: thermal/power/network/display/stability signals and their deltas vs baseline.”

If asked about accuracy:
- “Show the demo prediction accuracy and explain what it represents.”
  - Make it explicit: demo-only evaluation vs deterministic scenario incidents.

**WOW moment**: “We aren’t just flagging devices—we’re predicting the likely failure type and generating the next operational action.”

---

### Segment 3 — Work orders (3 minutes): “Turn alerts into execution”
**Goal**: prove the system closes the loop.

Ask the Agent:
- “What work orders are open right now? Which are P1 and due in the next 24 hours?”
- “Which work orders require field dispatch vs remote remediation?”

Talk track:
- “This is where the money is saved: fewer field dispatches and faster time-to-fix.”
- “The system recommends remote vs field based on predicted failure type and historical remote success rates.”

**WOW moment**: “Now it’s not just an insight—it’s an operational queue with deadlines and recommended channels.”

---

### Segment 4 — Remote remediation (3 minutes): “Automate what’s automatable”
**Goal**: show remote fix and escalation with governance.

Ask the Agent:
- “For the top remote work order, give step-by-step runbook instructions and expected success likelihood.”
- “Show recent remote remediation outcomes and escalations.”

Talk track:
- “Remote workflows are simulated here, but in production this is where you’d integrate MDM/RMM tooling.”
- “Escalation isn’t failure—it’s risk management: avoid wasting time when remote success is low (e.g., display panel).”

**WOW moment**: “We can demonstrate an ‘automated fix’ experience without touching real endpoints—perfect for a demo and for phased adoption.”

---

### Segment 5 — KB grounding (2 minutes): “Don’t guess—retrieve evidence”
**Goal**: show retrieval + consistency.

Ask the Agent:
- “For ‘Network Connectivity’ failures, what fixes have worked historically and what’s the remote success rate?”
- “Find similar incidents to device 4512 and summarize the top troubleshooting steps.”

Talk track:
- “This is why Snowflake Intelligence matters: structured data + unstructured knowledge + governance in one place.”

---

## PatientPoint-specific value mapping (use these lines)

### Save money
- “Reduce unnecessary dispatches by routing high-likelihood remote fixes first.”
- “Lower mean-time-to-diagnose by using the agent to synthesize telemetry + history + KB instantly.”

### Make money (protect revenue)
- “Reduce unplanned downtime and missed ad delivery.”
- “Proactively prioritize screens in high-traffic environments (lobbies/waiting rooms) that carry more revenue impact.”

### Reduce risk
- “Shift from reactive firefighting to predictable operations (SLAs, staffing, and partner trust).”
- “Governed AI reduces risk of hallucinated answers—everything is sourced from semantic views or KB search.”

---

## Questions you should expect (and how to answer)

### “Is this real ML?”
- “Acts 2/3 are simulated for demo speed and explainability; production would swap in Cortex ML / Snowpark ML models using the same governed data layer.”

### “Are the savings real?”
- “Observed metrics come directly from incident data. Any ‘avoided’ estimate is driven by the assumptions table—you can change it live.”

### “What’s required to productionize?”
- “Replace simulated scoring with production models, connect remote runbooks to endpoint tooling, and integrate with a ticketing/field-service system. The data + governance foundation remains the same.”


