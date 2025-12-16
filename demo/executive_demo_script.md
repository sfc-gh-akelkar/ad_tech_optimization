# PatientPoint AI-Powered Campaign Optimization
## Executive Demo Script

**Customer:** PatientPoint  
**Duration:** 20-25 minutes  
**Goal:** Demonstrate how Snowflake Intelligence transforms ad-tech decision-making with AI-powered insights that drive measurable business outcomes

---

## 🎯 FOCUS FRAMEWORK: Challenge → Action → Result

> **For Mike, Patrick, and Drew:** Three business outcomes that matter to PatientPoint's bottom line.

---

### 💰 MAKE MONEY: Faster Insights, Smarter Decisions

| CHALLENGE | ACTION | RESULT |
|-----------|--------|--------|
| Ad ops spends **hours analyzing** campaign performance across 5+ siloed systems | Deploy **Cortex Agent with Semantic Views** for natural language queries | **80% faster** time-to-insight (hours → seconds) |
| Pattern recognition requires **manual cross-referencing** of campaign, partner, and performance data | AI identifies patterns across campaigns, partners, and therapeutic areas **automatically** | **10x more campaigns analyzed** per analyst per week |
| Delayed insights mean **missed optimization windows** | Real-time answers enable **same-day decisions** | Pattern recognition in **<30 seconds** (Demo: Q1, Q5) |

---

### 💵 SAVE MONEY: Proactive Campaign Optimization

| CHALLENGE | ACTION | RESULT |
|-----------|--------|--------|
| **Underperforming campaigns** discovered too late (at QBRs) | Deploy **AI-powered campaign monitoring** with proactive alerts | **Early warning system** prevents partner churn |
| Campaign optimization is **reactive** (after partners complain) | Automated recommendations for **creative, placement, budget** adjustments | **15-25% ROAS improvement** on flagged campaigns |
| No unified view connecting **spend to partner outcomes** | Cross-dimensional analysis surfacing **actionable optimization targets** | **$5-10M annually** in recovered ad spend (Demo: Q2, Q5) |

---

### 🛡️ REDUCE RISK: Protect & Grow Partner Relationships

| CHALLENGE | ACTION | RESULT |
|-----------|--------|--------|
| **No unified competitive view** for partner conversations | Deploy **competitive intelligence AI** with industry benchmarking | **"49.7% ROAS outperformance"** — the pitch to Novo Nordisk |
| Campaign planning takes **days, not hours** | **Instant inventory discovery** with natural language search | Campaign planning: **days → minutes** (Demo: Q3) |
| Can't quickly answer **"Why PatientPoint?"** with data | Automated performance summaries with **AI-generated insights** | **90% faster QBR prep** (Demo: Q4) |

---

### 📊 Question-to-Result Mapping

| Demo Question | Business Result | What It Proves |
|---------------|-----------------|----------------|
| **Q1:** Top 5 campaigns by ROAS + patterns | 💰 MAKE MONEY | AI finds GLP-1 dominance, partner patterns in **15 seconds** |
| **Q2:** Underperforming campaigns + partner ROI | 💵 SAVE MONEY | Proactive alerts + optimization → **prevent partner churn** |
| **Q3:** Premium inventory for diabetes campaign | 🛡️ REDUCE RISK | Mayo Clinic, Stanford slots with CPMs → **campaign planning in minutes** |
| **Q4:** GLP-1 competitive position vs. benchmarks | 🛡️ REDUCE RISK | "49.7% outperformance" → **the partner pitch** |
| **Q5:** Novo Nordisk 20% investment allocation | 💰💵 BOTH | Partner advisory → **strategic relationship, not just vendor** |

---

### 🎯 The Executive Pitch (30 seconds)

> "PatientPoint is sitting on a goldmine of advertising data, but today it takes hours to turn that data into decisions. With Snowflake Intelligence, your team can ask questions in plain English and get AI-powered recommendations in seconds—not hours.
>
> **MAKE MONEY:** Pattern recognition that shows GLP-1 campaigns outperform by 50%—insights your team can act on today.
>
> **SAVE MONEY:** $5-10M in recovered ad spend through proactive campaign optimization—fix underperformers before partners notice.
>
> **REDUCE RISK:** A quantified value story—'Your campaigns outperform industry by 49.7%'—that wins and retains pharma partners.
>
> And it all runs inside your existing Snowflake environment—secure, scalable, and governed."

---

## Attendee Resonance Map

| Name | Title | Primary Interest | Demo Moment |
|------|-------|------------------|-------------|
| **Mike Walsh** | COO | Revenue optimization, operational scale | Q1: ROAS patterns, Q5: Budget allocation |
| **Patrick Arnold** | CTO | Architecture, security, platform capabilities | Closing: "Runs entirely in Snowflake" |
| **Sharon Patent** | CADO | Data strategy, AI/ML, governance | Q4: GLP-1 analysis, Data Context section |
| **Jonathan Richman** | SVP Software & Engineering | Implementation, integration | Q3: Inventory search, Technical architecture |
| **Liberty Holt** | VP Data & Analytics | Self-service analytics, data models | Q2: Campaign efficiency, Semantic layer |
| **Jennifer Kelly** | Sr Director Data Engineering | Data pipelines, quality, architecture | Data Context: Source systems integration |
| **JT Grant** | VP Ad Tech | Bidding optimization, inventory, campaigns | Q2: Bidding adjustments, Q3: Premium inventory |
| **Drew Amwoza** | SVP Technology, Architecture & Strategy | Strategic technology decisions | Q5: Cross-functional synthesis |
| **Chloé Varennes** | Director of Product Management, AdTech | Product features, user experience | All: Natural language interface |

---

## Opening (2 minutes)

> "Today we're going to show you how Snowflake Intelligence can transform PatientPoint's campaign optimization from reactive reporting to proactive, AI-driven recommendations. 
>
> Instead of dashboards that tell you what happened yesterday, you'll see an AI assistant that tells you what to do *right now*—and more importantly, *why*—built entirely on your existing Snowflake data platform."

**Key Framing:**
- This is NOT another BI tool
- This is a **decision engine** that understands PatientPoint's business
- Every answer connects to a **business outcome** (revenue, efficiency, growth)

---

## Data Context: Source Systems (3 minutes)

> "Before we dive in, let me show you what data the AI is working with. This simulates the integrated view you'd have in production from your actual source systems."

### Simulated Source Systems

| Source System | Data Type | What It Feeds | Production Reality |
|---------------|-----------|---------------|-------------------|
| **Salesforce CRM** | Partner contracts, tier levels, account status | Campaign metadata, partner relationships | Real: Pharma partner master data |
| **RTB/SSP Platform** | Real-time bids, win rates, pricing | Bidding performance metrics | Real: Bid logs at millions/day |
| **Ad Server (GAM/Freewheel)** | Impressions, completions, viewability | Delivery metrics | Real: Impression-level event stream |
| **Analytics Platform** | Engagement, conversions, dwell time | Performance outcomes | Real: Post-impression attribution |
| **Data Clean Room** | Privacy-safe audience matching | Cohort engagement data | Real: LiveRamp/Snowflake DCR |
| **Device MDM** | Screen locations, types, specs | Inventory attributes | Real: Device management system |
| **Facility Database** | Location, specialty, patient volume | Geographic/specialty targeting | Real: Practice management integration |

### Data Architecture (Show Diagram)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        SOURCE SYSTEMS (Simulated)                        │
├──────────────┬──────────────┬──────────────┬──────────────┬─────────────┤
│  Salesforce  │  RTB/SSP     │  Ad Server   │  Analytics   │ Clean Room  │
│  (CRM)       │  (Bids)      │  (Delivery)  │  (Outcomes)  │ (Audience)  │
└──────┬───────┴──────┬───────┴──────┬───────┴──────┬───────┴──────┬──────┘
       │              │              │              │              │
       ▼              ▼              ▼              ▼              ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         SNOWFLAKE DATA PLATFORM                          │
├─────────────────────────────────────────────────────────────────────────┤
│  BRONZE LAYER          SILVER LAYER           GOLD LAYER                │
│  (Raw Events)    ──►   (Cleansed)      ──►   (Business Ready)           │
│                                                                          │
│  • Bid logs             • Validated bids       • T_CAMPAIGN_PERFORMANCE │
│  • Impression events    • Matched impressions  • T_INVENTORY_ANALYTICS  │
│  • Device heartbeats    • Enriched inventory   • T_AUDIENCE_INSIGHTS    │
└─────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                         SNOWFLAKE INTELLIGENCE                           │
├────────────────────────┬────────────────────────┬───────────────────────┤
│   CORTEX SEARCH        │   SEMANTIC VIEWS       │   CORTEX AGENT        │
│   (Natural Language)   │   (Business Terms)     │   (AI Orchestration)  │
├────────────────────────┼────────────────────────┼───────────────────────┤
│  • Inventory Search    │  • Campaign Analytics  │  • Campaign Optimizer │
│  • Campaign Search     │  • Inventory Analytics │    Agent              │
│  • Audience Search     │  • Audience Insights   │                       │
└────────────────────────┴────────────────────────┴───────────────────────┘
```

### 💡 Role-Specific Callouts

**For Jennifer (Data Engineering):**
> "In production, this would be Snowpipe for streaming bid data at millions of events per day, Fivetran or Airbyte for CRM sync, and Dynamic Tables for real-time gold layer aggregations. The medallion architecture is already a pattern you'd likely adopt."

**For Sharon (CADO):**
> "The Data Clean Room integration is critical for the audience data—it enables pharma partners like Pfizer or Novo Nordisk to bring their own patient data for privacy-safe matching without ever exposing PII. That's the foundation for the cohort-level insights you'll see."

**For Patrick (CTO):**
> "Key point: everything runs inside your Snowflake account. No data leaves your environment, no external AI APIs, and it scales on your existing compute infrastructure."

---

## Question 1: Portfolio Performance & Pattern Recognition

### 📋 The Question
> **"What are our top 5 performing campaigns by ROAS, and what do they have in common that we can replicate across our portfolio?"**

### 🎯 Business Outcome
**Revenue Growth through Pattern Replication**
- Identify the DNA of successful campaigns
- Scale what works across the portfolio
- Stop wasting budget on underperforming patterns

### 👥 Attendee Resonance
| Attendee | Why This Matters to Them |
|----------|--------------------------|
| **Mike Walsh (COO)** | "This tells me where our revenue engine is strongest and how to scale it." |
| **JT Grant (VP Ad Tech)** | "This is the analysis my team does manually—now it's instant and consistent." |
| **Sharon Patent (CADO)** | "The AI is finding patterns across dimensions my team would need weeks to surface." |

### ✅ Expected Response Highlights
- Top 5 campaigns: Wegovy (6.0x), Ozempic (5.1x, 5.03x), Wegovy (5.0x), Mounjaro (5.0x)
- Pattern: **GLP-1/Weight Loss dominance** (4 of 5 top campaigns)
- Pattern: **Novo Nordisk + Eli Lilly** (Platinum partners)
- Pattern: **Direct Response + Education** campaign types outperform Awareness

### 💬 Talking Points

**After the response:**

> **For Mike (COO):** "Mike, notice how the AI doesn't just give you numbers—it gives you the *why*. GLP-1s are dominating because of audience demand in weight management. That's actionable intelligence for your partner development team."

> **For JT (VP Ad Tech):** "JT, this analysis would typically take your ad ops team hours to compile—pulling data from multiple systems, running pivots, looking for patterns. Now it's a 15-second conversation."

> **For Sharon (CADO):** "Sharon, this is connecting campaign data, partner data, and performance data in a single query. The semantic layer we built means the AI understands what 'ROAS' means in PatientPoint's context."

### 🏢 Production Considerations

**Data Requirements:**
- Campaign master data with drug/therapeutic area mapping
- Partner hierarchy with tier classifications
- Consistent ROAS calculation methodology

**Governance:**
- Business definitions for metrics (ROAS, CTR, Conversion) must be standardized
- Partner data access controls (can everyone see all partners?)

---

## Question 2: Campaign Efficiency & Partner ROI

### 📋 The Question
> **"Which campaigns are underperforming relative to their budget, and what changes would improve partner ROI?"**

### 🎯 Business Outcome
**Proactive Partner Success & Revenue Protection**
- Identify underperforming campaigns before partners notice
- Provide actionable recommendations to improve ROI
- Protect partner relationships through data-driven optimization

### 👥 Attendee Resonance
| Attendee | Why This Matters to Them |
|----------|--------------------------|
| **Mike Walsh (COO)** | "Partner retention depends on proving and improving ROI proactively." |
| **JT Grant (VP Ad Tech)** | "This is campaign optimization I can action with my team today." |
| **Sharon Patent (CADO)** | "Proactive insights prevent partner churn—this is the early warning system." |

### ✅ Expected Response Highlights
- Underperformers: Campaigns with ROAS below 3.5x (portfolio average)
- Pattern: **Awareness campaigns underperform** Direct Response by 15-20%
- Pattern: **Certain therapeutic areas** (e.g., General Wellness) show lower engagement
- Recommendation: **Shift budget** from underperformers to proven formats
- Specific actions: Creative refresh, placement optimization, therapeutic focus

### 💬 Talking Points

**After the response:**

> **For Mike (COO):** "Mike, this is partner retention in action. Instead of waiting for a QBR where Pfizer asks 'why is our campaign underperforming?', you're proactively calling them with solutions. That's the difference between losing a partner and expanding a relationship."

> **For JT (VP Ad Tech):** "JT, the AI identified which campaigns need attention and gave specific recommendations—creative refresh, placement optimization, budget reallocation. Your team can action this today, not wait for month-end reports."

> **For Sharon (CADO):** "Sharon, this is the early warning system. The AI is connecting spend, performance, and partner expectations to flag issues before they become problems. That's proactive data strategy."

### 🏢 Production Considerations

**Data Requirements:**
- Campaign spend and performance data (daily or weekly refresh)
- Partner-level ROAS targets and benchmarks
- Historical performance by campaign type, therapeutic area

**Governance:**
- Partner data access controls: Who can see which partner's performance?
- Escalation thresholds: When does underperformance trigger a review?
- Action authority: Who approves budget reallocation recommendations?

---

## Question 3: Inventory Discovery & Campaign Planning

### 📋 The Question
> **"Show me premium inventory availability in cardiology and endocrinology practices for a new diabetes campaign"**

### 🎯 Business Outcome
**Faster Campaign Planning & Better Targeting**
- Reduce time from campaign brief to media plan
- Identify optimal inventory for therapeutic area
- Maximize reach in relevant specialties

### 👥 Attendee Resonance
| Attendee | Why This Matters to Them |
|----------|--------------------------|
| **JT Grant (VP Ad Tech)** | "This is the inventory discovery my team does manually—now it's instant." |
| **Jonathan Richman (SVP Eng)** | "This is natural language search against structured data—powerful UX." |
| **Chloé Varennes (Dir PM)** | "This could be a product feature for pharma partner self-service." |

### ✅ Expected Response Highlights
- **Cardiology slots:** Mayo Clinic ($52 CPM, 88% fill), Cleveland Clinic ($48 CPM), Mass General ($60 CPM)
- **Endocrinology slots:** UCLA Medical ($58 CPM), Stanford Health ($62 CPM, 3.5% engagement)
- Strategic mix: Volume play (Mayo/Cleveland) + Premium targeting (Stanford/Mass General)
- Budget estimate: $140K-180K monthly for full premium access

### 💬 Talking Points

**After the response:**

> **For JT (VP Ad Tech):** "JT, in seconds we went from 'I need cardiology inventory' to a specific media plan with CPMs, fill rates, and budget estimates. That's a workflow that usually takes a planner half a day."

> **For Jonathan (SVP Eng):** "Jonathan, this is Cortex Search under the hood—it's semantic search, not keyword matching. The AI understood that 'diabetes campaign' means we want endocrinology *and* cardiology because diabetes patients often have cardiovascular comorbidities."

> **For Chloé (Dir PM):** "Chloé, imagine giving your pharma partners a branded interface where they can ask these questions directly. 'Find inventory for my new drug launch in oncology practices in the Northeast.' That's a product differentiator."

### 🏢 Production Considerations

**Data Requirements:**
- Real-time inventory availability (or near-real-time)
- Facility master data with specialty, location, patient volume
- Historical performance by slot for recommendations

**Data Hygiene:**
- Consistent facility naming across systems
- Specialty taxonomy alignment (ICD vs. internal codes)
- CPM accuracy (are these floor prices or historical averages?)

---

## Question 4: Competitive Intelligence & Market Position

### 📋 The Question
> **"What's our competitive position with GLP-1 medications compared to industry benchmarks?"**

### 🎯 Business Outcome
**Strategic Confidence & Partner Value Proposition**
- Quantify PatientPoint's performance advantage
- Arm sales team with competitive data
- Justify premium pricing with partners

### 👥 Attendee Resonance
| Attendee | Why This Matters to Them |
|----------|--------------------------|
| **Mike Walsh (COO)** | "This is the 'why PatientPoint' story for partner negotiations." |
| **Sharon Patent (CADO)** | "The AI is synthesizing across campaigns to create market intelligence." |
| **Drew Amwoza (SVP Tech Strategy)** | "This is competitive differentiation through data intelligence." |

### ✅ Expected Response Highlights
- **ROAS Leadership:** 5.23x vs 3.49x industry average (+49.7% outperformance)
- **CTR Excellence:** 3.30% vs 2.47% industry (+33.6% higher)
- **Conversion Strength:** 11.0% vs 9.0% industry (+23.0% better)
- GLP-1 portfolio: $4.56M invested across Wegovy, Ozempic, Mounjaro
- All top 5 campaigns are GLP-1 medications

### 💬 Talking Points

**After the response:**

> **For Mike (COO):** "Mike, this is your pitch to Novo Nordisk and Eli Lilly: 'Your GLP-1 campaigns outperform industry benchmarks by 50% on our platform.' That's a revenue conversation, not a cost conversation."

> **For Sharon (CADO):** "Sharon, the AI calculated that 5.23x average ROAS across 5 campaigns vs. our portfolio average of 3.49x. It's not just reporting—it's synthesizing data to answer a strategic question."

> **For Drew (SVP Tech Strategy):** "Drew, this is the kind of intelligence that differentiates PatientPoint. Any ad network can show impressions. We're showing *outcome-driven performance* with AI-generated insights."

### 🏢 Production Considerations

**Data Requirements:**
- Industry benchmark data (where does this come from?)
- Competitive intelligence integration (optional)
- Consistent performance metrics across drug categories

**Governance:**
- Can we share competitive position data with partners?
- How do we source/validate "industry average" benchmarks?

---

## Question 5: Partner Investment Advisory

### 📋 The Question
> **"Novo Nordisk wants to increase their PatientPoint investment by 20%. Where should we recommend they allocate for maximum ROAS?"**

### 🎯 Business Outcome
**Strategic Partner Advisory**
- Position PatientPoint as a strategic partner, not just a media seller
- Provide data-driven allocation recommendations
- Demonstrate platform intelligence that justifies premium pricing

### 👥 Attendee Resonance
| Attendee | Why This Matters to Them |
|----------|--------------------------|
| **Mike Walsh (COO)** | "This positions us as strategic advisors to pharma partners—that's relationship stickiness." |
| **Drew Amwoza (SVP Tech Strategy)** | "This is the cross-functional synthesis that shows the platform's full power." |
| **JT Grant (VP Ad Tech)** | "This is the recommendation engine my team needs for partner conversations." |
| **Chloé Varennes (Dir PM)** | "This could be a self-service product feature for partners." |

### ✅ Expected Response Highlights
- **40% → Wegovy campaigns** (proven 5.5x ROAS, highest performer)
- **35% → Ozempic portfolio** (consistent 5.0x+ across Direct Response + Education)
- **15% → Premium endocrinology inventory** (Stanford, UCLA—highest engagement)
- **10% → Cardiology waiting rooms** (diabetes comorbidity reach)
- Rationale tied to Novo Nordisk's specific performance history
- Expected impact: Maintain/improve 5.0x+ portfolio ROAS

### 💬 Talking Points

**After the response:**

> **For Mike (COO):** "Mike, this is how you become a strategic partner, not just a vendor. When Novo Nordisk asks 'where should we spend more?', you have an AI-backed answer in 15 seconds. That's the kind of intelligence that justifies premium pricing and deepens the relationship."

> **For Drew (SVP Tech Strategy):** "Drew, notice what just happened: the AI synthesized Novo Nordisk's historical performance, current inventory availability, and therapeutic area patterns into a unified recommendation. That's partner-specific intelligence that would normally take a team days to compile."

> **For Chloé (Dir PM):** "Chloé, imagine giving Novo Nordisk a branded portal where they can ask this question themselves: 'Where should I allocate my next $500K?' That's a product differentiator—self-service investment optimization."

### 🏢 Production Considerations

**Data Requirements:**
- Unified view of campaign + inventory performance
- Historical ROAS by campaign type, therapeutic area, partner
- Inventory capacity and availability

**Governance:**
- Budget allocation authority: Who approves AI recommendations?
- Investment guardrails: Maximum % to any single campaign/partner?

---

## Closing: Path to Production (3 minutes)

### Key Takeaways by Role

| Attendee | Key Takeaway |
|----------|--------------|
| **Mike Walsh** (COO) | AI-driven decisions that directly connect to revenue optimization |
| **Patrick Arnold** (CTO) | Runs entirely in Snowflake—secure, scalable, no external dependencies |
| **Sharon Patent** (CADO) | AI that understands your data semantics and enforces governance |
| **Jonathan Richman** (SVP Eng) | Declarative configuration—agents defined in SQL, version controlled |
| **Liberty Holt** (VP Data) | Self-service analytics that scales to partners and internal teams |
| **Jennifer Kelly** (Sr Dir DE) | Semantic layer governs how AI interprets your data model |
| **JT Grant** (VP Ad Tech) | Real-time campaign optimization insights without custom development |
| **Drew Amwoza** (SVP Tech) | Strategic platform capability that differentiates PatientPoint |
| **Chloé Varennes** (Dir PM) | New product capabilities for pharma partner self-service |

### How PatientPoint Gets Here: Production Roadmap

```
┌────────────────────────────────────────────────────────────────────────────┐
│ PHASE 1: DATA FOUNDATION (4-6 weeks)                                       │
├────────────────────────────────────────────────────────────────────────────┤
│ • Assess current data landscape (what systems, what quality?)              │
│ • Design medallion architecture (Bronze → Silver → Gold)                   │
│ • Build data pipelines (Snowpipe, Fivetran, or existing ETL)               │
│ • Establish data governance framework (definitions, ownership, access)     │
├────────────────────────────────────────────────────────────────────────────┤
│ PHASE 2: INTELLIGENCE LAYER (4-6 weeks)                                    │
├────────────────────────────────────────────────────────────────────────────┤
│ • Define semantic model (business terms → technical columns)               │
│ • Build Cortex Search services (inventory, campaigns, audiences)           │
│ • Create Cortex Analyst semantic views                                     │
│ • Configure Cortex Agent with PatientPoint-specific instructions           │
├────────────────────────────────────────────────────────────────────────────┤
│ PHASE 3: DEPLOYMENT & ADOPTION (2-4 weeks)                                 │
├────────────────────────────────────────────────────────────────────────────┤
│ • Deploy to internal users (ad ops, analytics, sales)                      │
│ • Build Streamlit interface for specific use cases                         │
│ • Integrate with existing workflows (Slack, email alerts)                  │
│ • Training and change management                                           │
├────────────────────────────────────────────────────────────────────────────┤
│ PHASE 4: PARTNER EXTENSION (Optional)                                      │
├────────────────────────────────────────────────────────────────────────────┤
│ • Partner-specific agents with data access controls                        │
│ • Branded self-service interface for pharma partners                       │
│ • Secure data sharing for campaign insights                                │
└────────────────────────────────────────────────────────────────────────────┘
```

### Critical Success Factors

| Factor | What PatientPoint Needs |
|--------|------------------------|
| **Data Acquisition** | Streaming pipelines for bid/impression data, batch sync for CRM/partner data |
| **Data Governance** | Business glossary defining ROAS, CTR, conversion; data ownership matrix |
| **Data Hygiene** | Consistent naming (facilities, campaigns), deduplication, validation rules |
| **Access Control** | Role-based access to sensitive data (partner performance, audience insights) |
| **Change Management** | Training for ad ops, analytics, sales on AI-assisted workflows |

### Summary Points

1. **From Dashboards to Decisions**  
   Instead of building reports, teams ask questions and get actionable recommendations instantly.

2. **Privacy-First by Design**  
   All audience insights are aggregated and HIPAA compliant—no individual patient data is ever exposed.

3. **Cross-Functional Intelligence**  
   The AI connects campaign, inventory, audience, and partner data to surface insights that would take analysts days to compile.

4. **Scalable Architecture**  
   Built on Snowflake's data platform, this scales with your data volume and can integrate new data sources seamlessly.

5. **Competitive Advantage**  
   This capability positions PatientPoint as a technology-forward partner for pharmaceutical advertisers—and potentially a product differentiator.

---

## Demo Environment Checklist

- [ ] Agent is running and responsive
- [ ] Sample data is loaded (25 campaigns, 30 inventory, 20 cohorts)
- [ ] All three Cortex Search services are active
- [ ] All three Semantic Views are created
- [ ] Warehouse is sized appropriately (MEDIUM recommended for demo)

---

## Handling Questions

**"How accurate is the AI?"**  
> "The AI uses Cortex Analyst to generate SQL queries against your actual data, so the numbers are 100% accurate. The recommendations are based on patterns in the data, similar to what an experienced analyst would identify—but in seconds instead of hours."

**"What about data security?"**  
> "All data stays within Snowflake's secure environment. The AI never sees raw patient data—only aggregated, HIPAA-compliant cohort information. This runs on your compute, in your account, with your access controls."

**"How long did this take to build?"**  
> "This demo environment was built in about 2 weeks. In production, the timeline depends on data readiness—if your data is already in Snowflake, the intelligence layer can be built in 4-6 weeks. The key enabler is Snowflake's unified platform where data, AI, and applications all live together."

**"Can we customize this for specific partners?"**  
> "Absolutely. We can create partner-specific views and even deploy dedicated agents for key accounts with tailored instructions and data access controls. Imagine giving Novo Nordisk their own 'Campaign Optimizer' that only sees their data."

**"What if the AI gives a wrong recommendation?"**  
> "The AI is a decision *support* tool, not a decision *maker*. All recommendations should be reviewed by your team before implementation. The value is in speed and pattern recognition—the judgment is still human."

---

## Backup Questions (If Time Permits)

| Question | Tests | Best For |
|----------|-------|----------|
| "What's the average time from first impression to conversion for our top campaigns?" | Attribution analysis | Sharon (CADO) |
| "Which medical specialties are underrepresented in our inventory mix?" | Inventory gap analysis | JT (VP Ad Tech) |
| "Show me campaigns where we're overspending relative to conversion rates" | Efficiency analysis | Mike (COO) |
| "Find premium inventory opportunities in the Southwest region" | Geographic search | Sales use case |
| "Which screen types deliver the best completion rates for video ads?" | Creative optimization | Chloé (Dir PM) |
