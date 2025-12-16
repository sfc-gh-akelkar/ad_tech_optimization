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

### 💵 SAVE MONEY: Eliminate Wasted Ad Spend

| CHALLENGE | ACTION | RESULT |
|-----------|--------|--------|
| **15-25% of ad spend wasted** on underperforming audience segments | Deploy **AI-powered audience optimization** with real-time recommendations | **$5-10M annually** in recovered ad spend |
| Bid adjustments are **reactive** (after poor performance) | Automated bid adjustment recommendations **with specific percentages** | **40-60% bid reduction** on low-converters |
| No unified view connecting **audience engagement to outcomes** | Cross-dimensional analysis surfacing **actionable reallocation targets** | **15-25% ROAS improvement** (Demo: Q2, Q5) |

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
| **Q2:** Underperforming audiences + bid adjustments | 💵 SAVE MONEY | Specific 40-60% bid reductions → **direct ROAS impact** |
| **Q3:** Premium inventory for diabetes campaign | 🛡️ REDUCE RISK | Mayo Clinic, Stanford slots with CPMs → **campaign planning in minutes** |
| **Q4:** GLP-1 competitive position vs. benchmarks | 🛡️ REDUCE RISK | "49.7% outperformance" → **the partner pitch** |
| **Q5:** 20% budget allocation for max ROAS | 💰💵 BOTH | Cross-functional synthesis → **investment decisions, not guesses** |

---

### 🎯 The Executive Pitch (30 seconds)

> "PatientPoint is sitting on a goldmine of advertising data, but today it takes hours to turn that data into decisions. With Snowflake Intelligence, your team can ask questions in plain English and get AI-powered recommendations in seconds—not hours.
>
> **MAKE MONEY:** Pattern recognition that shows GLP-1 campaigns outperform by 50%—insights your team can act on today.
>
> **SAVE MONEY:** $5-10M in recovered ad spend through AI-powered audience optimization and smarter bid management.
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
| **Liberty Holt** | VP Data & Analytics | Self-service analytics, data models | Q2: Audience optimization, Semantic layer |
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

## Question 2: Audience Optimization & Bidding Strategy

### 📋 The Question
> **"Which audience segments are underperforming, and what real-time adjustments should we make to our bidding strategy?"**

### 🎯 Business Outcome
**Cost Efficiency through Smart Bidding**
- Stop overspending on low-converting audiences
- Reallocate budget to high-performers
- Improve ROAS through better targeting

### 👥 Attendee Resonance
| Attendee | Why This Matters to Them |
|----------|--------------------------|
| **JT Grant (VP Ad Tech)** | "This is real-time bid optimization guidance I can action today." |
| **Liberty Holt (VP Data)** | "The AI is surfacing audience insights that would require custom analytics." |
| **Chloé Varennes (Dir PM)** | "This could become a self-service tool for campaign managers." |

### ✅ Expected Response Highlights
- Underperformers: 18-24 Male General Wellness (1.5% engagement), 35-44 Male Mental Wellness (1.5%)
- Pattern: **Male segments underperforming** across the board
- Pattern: **"General Wellness" too broad** → poor engagement
- Recommendation: **40-60% bid reduction** on worst performers
- Reallocation target: 45-54 Female Cancer Awareness (4.0% engagement, 20% conversion)

### 💬 Talking Points

**After the response:**

> **For JT (VP Ad Tech):** "JT, the AI isn't just identifying problems—it's giving you specific bid adjustments with percentages. '40-60% reduction on sub-1.8% engagement segments' is something your team can implement in your DSP today."

> **For Liberty (VP Data):** "Liberty, notice the pattern recognition: male segments underperforming across health categories, 'General Wellness' being too broad. These are the kinds of cross-dimensional insights that typically require custom analysis."

> **For Mike (COO):** "Mike, the bottom line here is efficiency. We're not spending more—we're spending smarter. The expected impact is 15-25% ROAS improvement through reallocation."

### 🏢 Production Considerations

**Data Requirements:**
- Real-time or near-real-time engagement data
- Cohort-level aggregation with k-anonymity (min 50 members)
- Historical bid performance by audience segment

**Governance:**
- HIPAA compliance: All audience data aggregated, no individual-level data
- Bid adjustment thresholds: Who can approve 40%+ changes?

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

## Question 5: Strategic Budget Allocation

### 📋 The Question
> **"If we increase our digital health ad spend by 20%, where should we allocate for maximum ROAS?"**

### 🎯 Business Outcome
**Data-Driven Investment Decisions**
- Optimize incremental budget allocation
- Balance proven winners vs. growth opportunities
- Quantify expected ROI before spending

### 👥 Attendee Resonance
| Attendee | Why This Matters to Them |
|----------|--------------------------|
| **Mike Walsh (COO)** | "This is how I want to make investment decisions—with AI-backed recommendations." |
| **Drew Amwoza (SVP Tech Strategy)** | "This is the cross-functional synthesis that shows the platform's full power." |
| **JT Grant (VP Ad Tech)** | "This is actionable budget guidance with specific percentages." |

### ✅ Expected Response Highlights
- **35% → Wegovy/Weight Loss** (proven 6.0x ROAS)
- **25% → Ozempic/Diabetes** (consistent 5.0x+ performance)
- **15% → Cardiology inventory** (high volume, efficient CPM)
- **10% → Oncology exam rooms** (premium engagement)
- **10% → Merck oncology** (scale proven 4.8x performer)
- **5% → Mounjaro growth** (competitive positioning)
- Expected impact: 15-25% overall portfolio ROAS improvement

### 💬 Talking Points

**After the response:**

> **For Mike (COO):** "Mike, this is the CFO conversation: 'If we invest 20% more, here's exactly where it goes and why, with projected 15-25% ROAS lift.' That's a business case, not a guess."

> **For Drew (SVP Tech Strategy):** "Drew, notice what just happened: the AI synthesized campaign performance data, inventory analytics, and partner insights into a unified recommendation. That's three data domains in one answer—exactly the kind of cross-functional intelligence that's typically siloed."

> **For JT (VP Ad Tech):** "JT, the specificity here is key: '35% to Wegovy, 15% to cardiology inventory.' Your team can take this recommendation and build a media plan from it today."

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
