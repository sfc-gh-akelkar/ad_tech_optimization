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
- **Early warning**: Anomaly watchlist (baseline 14d vs scoring 1d) flags devices drifting before they cross thresholds.
- **24–48h prediction**: Failure predictions + confidence + demo evaluation metrics vs deterministic scenario incidents.
- **Ops Center – Operationalization**: Auto-generated work orders with recommended channel (remote vs field), priority, and due-by.
- **Automated remote resolution (simulated)**: Runbooks + executions + escalation when remote is unlikely to succeed.
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
- **Time-to-value**: you can start with credible simulation and swap in production models later without redesigning the system.

---

## Demo setup (1–2 minutes)

### Run order (already in repo)
Use the ordered script list in `START_HERE.md` (setup → data → curated views → semantic views → search → watchlist → predictions → work orders → remediation → executive KPIs → agent).

### Demo posture (credibility statements)
- “This is realistic synthetic telemetry + labeled scenario incidents for demo repeatability.”
- “Where we estimate savings, we show the assumptions table and keep it editable.”
- “The AI Agent doesn’t guess—everything is grounded in semantic views or the KB search tool.”

---

## Prescriptive 20‑minute demo script (verbatim, designed to WOW)

### Before you start (30 seconds)
Do this in **Snowflake Intelligence**:
1) Open **Snowflake Intelligence** → **Agents**
2) Open `MAINTENANCE_OPS_AGENT`
3) Make sure you can see answers + citations/tool outputs in the chat UI

### 0:00–1:00 — Opening (frame the business)
Say:
“PatientPoint’s screens are not just ‘IT devices’—they’re **revenue delivery endpoints**. When a screen is down, you lose impressions, partners notice, and clinic staff gets pulled into troubleshooting. Today I’m going to show how Snowflake helps you **make money, save money, and reduce risk** by moving from reactive break/fix to proactive operations.”

Then say (Snowflake differentiator):
“What’s special here is Snowflake isn’t just storing data—Snowflake is the **governed system of intelligence**: curated data + semantic layer + retrieval + orchestration—so answers are explainable and auditable.”

### 1:00–3:30 — Challenge → Result preview (exec-friendly)
Copy/paste to Agent:
- “Show executive KPIs: fleet size, critical/warning now, watchlist count, predicted failures in the next 48 hours, downtime hours and revenue impact in the last 30 days.”

If the response shows watchlist/predictions as 0, immediately follow with:
- “Why might watchlist count or predicted failures be zero? Check whether scoring/predictions were refreshed recently and summarize the current critical devices and their telemetry signals.”

Say:
“Two important credibility points:
1) **Observed** downtime and revenue impact come from incident history.
2) Any ‘avoided cost’ is **explicitly assumption-driven**—we can edit it live per PatientPoint.”

Copy/paste to Agent:
- “Which KPIs are observed vs estimated? Show the assumptions driving the estimates.”

### 3:30–7:30 — Action #1: Early warning watchlist (baseline vs now)
Say:
“The hardest part operationally isn’t collecting telemetry—it’s deciding **what matters right now**. We compute a per-device baseline, then score what changed in the last day. The output is a ranked watchlist with ‘why flagged’ explanations.”

Copy/paste to Agent:
- “What devices should the ops team look at first today and why? Include the top abnormal signals.”

If they ask “how is it explainable?” say:
“It’s not a black box. Each device is scored across thermal, power, network, display, and stability—and we can see the underlying deltas.”

Copy/paste to Agent:
- “For device 4532, summarize the abnormal signals and the last 7–30 days of telemetry trends.”

### 7:30–11:00 — Action #2: 24–48h predicted failures (and how to talk about accuracy)
Say:
“Early warning is great, but the real operational unlock is: **what’s likely to fail in the next 24–48 hours**, and what type of failure is it? That’s how you schedule work, parts, and staffing—before downtime hits.”

Copy/paste to Agent:
- “Which devices are likely to fail in the next 48 hours? Show probability, predicted failure type, and the reason.”

If they ask “is the accuracy real?” say:
“For the demo, we track **demo evaluation metrics** against a deterministic scenario set so the demo is repeatable. In production, accuracy comes from evaluation on your labeled incident outcomes.”

Copy/paste to Agent:
- “Show the latest prediction evaluation metrics and explain what they represent.”

### 11:00–14:00 — Action #3: Turn insight into an ops queue (work orders)
Say:
“This is where value becomes real: insights become **work orders** with priority, due-by time, and recommended channel—remote vs field—based on predicted failure type and historical success rates.”

Copy/paste to Agent:
- “What work orders are open right now? Which are P1 and due in the next 24 hours?”
- “Which work orders require field dispatch vs remote remediation? Summarize counts and top examples.”

Tie to PatientPoint dollars:
“Every avoided dispatch saves real money. Every hour of avoided downtime protects ad delivery. The key is prioritization and routing—not just alerts.”

### 14:00–17:00 — Action #4: Automated remote remediation (simulated) + escalation
Say:
“Now the ‘wow’: automated remote remediation.

Important note for the demo: we’re **not going to run real commands on your endpoints in a demo**. What we *will* show is the full operating model: **how predicted failures turn into automated remediation workflows with audit trails and escalation to field service**.

In production, the same workflow would call your endpoint tooling (MDM/RMM/device management APIs) and create/update tickets in your field service system (e.g., ServiceNow/Salesforce Field Service).”

Copy/paste to Agent:
- “Pick the highest priority remote work order and provide step-by-step runbook instructions.”
- “Show recent remote remediation outcomes: successes vs escalations.”

Say:
“Escalation is not failure—it’s risk management. If the data says display panel failures rarely resolve remotely, we don’t waste time; we dispatch with the right parts.”

### 17:00–19:00 — Evidence grounding (KB + historical outcomes)
Say:
“The agent is only valuable if it’s grounded. We combine structured telemetry and outcomes with a searchable maintenance knowledge base of similar incidents.”

Copy/paste to Agent:
- “For ‘Network Connectivity’ failures, what fixes have worked historically and what is the remote success rate?”
- “Find similar incidents to device 4512 and summarize the top troubleshooting steps.”

### 19:00–20:00 — Close (value + next steps)
Say:
“For PatientPoint, the value is straightforward:
- **Make money**: fewer missed impressions and stronger partner trust through higher uptime.
- **Save money**: fewer unnecessary dispatches and lower time-to-diagnose/resolve.
- **Reduce risk**: predictable operations, governed answers, and an auditable workflow from signal → action → result.

Next step after the demo is simple: connect to your real telemetry stream and incident history, calibrate assumptions with your finance team, and then swap the simulated scoring for production models—without changing the data product or the agent interface.”

---

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
- “The watchlist scoring and 24–48h predictions are simulated for demo speed and explainability; production would swap in Cortex ML / Snowpark ML models using the same governed data layer.”

### “Are the savings real?”
- “Observed metrics come directly from incident data. Any ‘avoided’ estimate is driven by the assumptions table—you can change it live.”

### “What’s required to productionize?”
- “Replace simulated scoring with production models, connect remote runbooks to endpoint tooling, and integrate with a ticketing/field-service system. The data + governance foundation remains the same.”


