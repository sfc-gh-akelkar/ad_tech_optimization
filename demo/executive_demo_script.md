# PatientPoint AI-Powered Campaign Optimization
## Executive Demo Script

**Customer:** PatientPoint  
**Duration:** 15-20 minutes  
**Goal:** Demonstrate how Snowflake Intelligence transforms ad-tech decision-making with AI-powered insights

---

## Attendees

| Name | Title | Key Interests |
|------|-------|---------------|
| **Mike Walsh** | COO | Operational efficiency, revenue optimization, scale |
| **Patrick Arnold** | CTO | Architecture, technology stack, platform capabilities |
| **Sharon Patent** | CADO | Data strategy, AI/ML, analytics maturity |
| **Jonathan Richman** | SVP Software & Engineering | Implementation, integration, developer experience |
| **Liberty Holt** | VP Data & Analytics | Data models, insight generation, self-service |
| **Jennifer Kelly** | Sr Director Data Engineering | Data pipelines, quality, architecture patterns |
| **JT Grant** | VP Ad Tech | Bidding optimization, inventory, campaign performance |
| **Drew Amwoza** | SVP Technology, Architecture & Strategy | Strategic technology decisions, future roadmap |
| **Chloé Varennes** | Director of Product Management, AdTech | Product features, user experience, use cases |

---

## Opening (2 minutes)

> "Today we're going to show you how Snowflake Intelligence can transform PatientPoint's campaign optimization from reactive reporting to proactive, AI-driven recommendations. Instead of dashboards that tell you what happened, you'll see an AI assistant that tells you what to do next—built entirely on your existing Snowflake data platform."

---

## Data Context (1 minute - optional, for technical audience)

> "Before we dive in, let me quickly explain what data the AI is working with. This represents the kind of integrated view you'd have in production."

### Three Core Datasets

| Dataset | What It Represents | Production Source Systems |
|---------|-------------------|---------------------------|
| **Campaign Performance** | 100 pharma campaigns with full KPIs | Salesforce CRM + RTB Platform + Ad Server + Billing |
| **Inventory Analytics** | 200 ad placements across medical facilities | Device MDM + Location System + GIS Data |
| **Audience Insights** | 100 privacy-safe patient cohorts | Data Clean Room + Analytics (k-anonymity enforced) |

### Source System Integration (Production)

```
Salesforce ──┐
RTB/SSP ─────┼──► Snowflake ──► Gold Layer ──► Cortex Agent
Ad Server ───┤      (Bronze → Silver → Gold)
Analytics ───┤
Clean Room ──┘
```

**💡 For Jennifer (Data Engineering):** *"In production, this would be Snowpipe for streaming bid data, Fivetran for CRM sync, and Dynamic Tables for the gold layer aggregations."*

**💡 For Sharon (CADO):** *"The Data Clean Room integration is key for the audience data—it enables pharma partners to bring their own data for matching without exposing PII."*

---

## Question 1: Portfolio Performance & Growth Drivers
### 👥 *Resonates with: Mike (COO), JT (VP Ad Tech), Sharon (CADO)*

**Ask the Agent:**
> "What are our top 5 performing campaigns by ROAS, and what do they have in common that we can replicate across our portfolio?"

**Why This Matters:**
- Shows AI can identify **patterns across campaigns** that humans might miss
- Demonstrates ability to move from "what happened" to "what should we do"
- Highlights cross-functional insights (creative, placement, audience, timing)

**Expected Insights:**
- Top campaigns by ROAS with specific metrics
- Common success factors (therapeutic area, daypart, audience segments)
- Actionable recommendations for underperforming campaigns

**Follow-up Chart Request:**
> "Show me a chart comparing ROAS by therapeutic area"

**💡 Talking Point for JT:** *"This is the kind of analysis that would typically take your ad ops team hours to compile—now it's a conversation."*

---

## Question 2: Revenue Optimization Opportunity
### 👥 *Resonates with: Mike (COO), JT (VP Ad Tech), Chloé (Director PM)*

**Ask the Agent:**
> "Which inventory slots are underperforming relative to their potential, and how much incremental revenue could we capture with optimized pricing?"

**Why This Matters:**
- Directly ties to **revenue and margin improvement**
- Shows AI can identify monetization gaps
- Quantifies the business case for optimization

**Expected Insights:**
- Inventory with low fill rates but high patient volume
- CPM optimization opportunities by region/specialty
- Estimated revenue uplift from pricing adjustments

**Follow-up:**
> "What's the optimal CPM range for cardiology waiting room slots based on historical win rates?"

**💡 Talking Point for Mike:** *"This connects operational data to revenue opportunity—the kind of insight that drives quarterly planning."*

---

## Question 3: Partner Growth Strategy
### 👥 *Resonates with: Mike (COO), Sharon (CADO), Liberty (VP Data & Analytics)*

**Ask the Agent:**
> "Compare our Platinum tier partners' campaign performance. Which partners are growing fastest and which need attention?"

**Why This Matters:**
- **Partner health visibility** at a glance
- Identifies upsell opportunities vs. churn risks
- Shows AI can prioritize sales/account team focus

**Expected Insights:**
- Partner performance comparison (impressions, ROAS, conversion rates)
- Trend analysis (growing vs. declining partners)
- Specific recommendations for partner engagement

**Follow-up Chart Request:**
> "Create a chart showing partner performance by total revenue and ROAS"

**💡 Talking Point for Sharon:** *"The AI is connecting campaign data, financial data, and partner data—exactly the kind of cross-domain analytics that typically requires custom development."*

---

## Question 4: Audience Intelligence & Targeting
### 👥 *Resonates with: Liberty (VP Data & Analytics), Chloé (Director PM), JT (VP Ad Tech)*

**Ask the Agent:**
> "For a new diabetes medication launch targeting adults 45-65, which audience cohorts should we prioritize and what inventory is best suited for reaching them?"

**Why This Matters:**
- Shows **end-to-end campaign planning** capability
- Demonstrates privacy-safe audience insights (HIPAA compliant)
- Illustrates how AI combines audience + inventory intelligence

**Expected Insights:**
- Top audience cohorts by engagement and conversion potential
- Recommended inventory placements (specialty, daypart, screen type)
- Budget allocation recommendations

**Compliance Callout:**
> "Notice that all audience data is aggregated at the cohort level with a minimum of 50 members. This ensures HIPAA compliance while still delivering actionable targeting insights."

**💡 Talking Point for Liberty:** *"This is self-service analytics at scale—your pharma partners could eventually ask these questions directly through a branded interface."*

---

## Question 5: Operational Efficiency & Scale
### 👥 *Resonates with: Patrick (CTO), Jonathan (SVP Eng), Jennifer (Sr Dir Data Eng), Drew (SVP Tech Strategy)*

**Ask the Agent:**
> "What patterns do you see in our bidding performance across dayparts and regions? Where should we focus our real-time optimization efforts?"

**Why This Matters:**
- Shows AI can optimize **operational efficiency**
- Identifies where automation should be focused
- Demonstrates real-time decision support capability

**Expected Insights:**
- Win rate patterns by daypart and region
- Bid price sensitivity analysis
- Recommendations for automated bidding rules

**Follow-up:**
> "Which regions have the most competitive bidding and what's our win rate there?"

**💡 Talking Point for Patrick & Drew:** *"This runs entirely within Snowflake—no external AI services, no data leaving your environment, and it scales with your existing compute infrastructure."*

**💡 Talking Point for Jennifer:** *"The semantic layer we built means the AI understands your business terminology. 'ROAS', 'fill rate', 'daypart'—these are defined once and work across all queries."*

---

## Closing (2 minutes)

### Key Takeaways by Role:

| Attendee | Key Takeaway |
|----------|--------------|
| **Mike Walsh** (COO) | Operational insights that directly connect to revenue optimization |
| **Patrick Arnold** (CTO) | Runs entirely in Snowflake—secure, scalable, no external dependencies |
| **Sharon Patent** (CADO) | AI that understands your data semantics and business context |
| **Jonathan Richman** (SVP Eng) | Declarative configuration—agents defined in SQL, version controlled |
| **Liberty Holt** (VP Data) | Self-service analytics that scales to partners and internal teams |
| **Jennifer Kelly** (Sr Dir DE) | Semantic layer governs how AI interprets your data model |
| **JT Grant** (VP Ad Tech) | Real-time campaign optimization insights without custom development |
| **Drew Amwoza** (SVP Tech) | Strategic platform capability that differentiates PatientPoint |
| **Chloé Varennes** (Dir PM) | New product capabilities for pharma partner self-service |

### Summary Points:

1. **From Dashboards to Decisions**  
   Instead of building reports, teams can ask questions and get actionable recommendations instantly.

2. **Privacy-First by Design**  
   All audience insights are aggregated and HIPAA compliant—no individual patient data is ever exposed.

3. **Cross-Functional Intelligence**  
   The AI connects campaign, inventory, audience, and partner data to surface insights that would take analysts days to compile.

4. **Scalable Architecture**  
   Built on Snowflake's data platform, this scales with your data volume and can integrate new data sources seamlessly.

5. **Competitive Advantage**  
   This capability positions PatientPoint as a technology-forward partner for pharmaceutical advertisers.

---

## Backup Questions (If Time Permits)

| Question | Best For |
|----------|----------|
| "What's the average time from first impression to conversion for our top campaigns?" | CMO - Attribution |
| "Which medical specialties are underrepresented in our inventory mix?" | CEO - Growth Strategy |
| "Show me campaigns where we're overspending relative to conversion rates" | CFO - Cost Optimization |
| "Find premium inventory opportunities in the Southwest region" | Sales - Territory Planning |
| "Which screen types deliver the best completion rates for video ads?" | CMO - Creative Strategy |

---

## Demo Environment Checklist

- [ ] Agent is running and responsive
- [ ] Sample data is loaded (1.8M+ rows)
- [ ] All three Cortex Search services are active
- [ ] All three Semantic Views are created
- [ ] Warehouse is sized appropriately (MEDIUM recommended for demo)

---

## Handling Questions

**"How accurate is the AI?"**  
> The AI uses Cortex Analyst to generate SQL queries against our actual data, so the numbers are 100% accurate. The recommendations are based on patterns in the data, similar to what an experienced analyst would identify.

**"What about data security?"**  
> All data stays within Snowflake's secure environment. The AI never sees raw patient data—only aggregated, HIPAA-compliant cohort information.

**"How long did this take to build?"**  
> The core infrastructure was built in [X weeks]. The key enabler is Snowflake's unified platform where our data, AI models, and applications all live together.

**"Can we customize this for specific partners?"**  
> Absolutely. We can create partner-specific views and even deploy dedicated agents for key accounts with tailored instructions and data access.

