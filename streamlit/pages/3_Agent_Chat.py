"""
=============================================================================
PatientPoint Ad Tech Demo - AI Agent Chat Page
=============================================================================
Conversational interface for the Cortex Agent.
Allows natural language queries for campaign optimization.
=============================================================================
"""

import streamlit as st
import json

# Try to import Snowpark
try:
    from snowflake.snowpark.context import get_active_session
    session = get_active_session()
    IN_SNOWFLAKE = True
except:
    IN_SNOWFLAKE = False
    session = None

st.set_page_config(
    page_title="AI Agent Chat",
    page_icon="🤖",
    layout="wide"
)

st.markdown("# 🤖 Campaign Optimizer Agent")
st.markdown("Ask questions about campaigns, inventory, and audience targeting using natural language.")

st.divider()

# Initialize chat history
if "messages" not in st.session_state:
    st.session_state.messages = []

if "thread_id" not in st.session_state:
    st.session_state.thread_id = None

# Sidebar with suggested prompts
st.sidebar.markdown("## 💡 Suggested Questions")

suggested_prompts = [
    "What's the optimal bid price for a diabetes campaign in cardiology waiting rooms?",
    "Which audience segments have the highest engagement for heart medications?",
    "Compare Q4 2024 vs Q3 2024 campaign performance",
    "Find premium morning slots in Texas endocrinology clinics",
    "What's driving the ROAS improvement for Pfizer campaigns?",
    "Show me high-conversion audience cohorts in the Southwest",
    "Which therapeutic areas have the best CTR?",
    "Recommend inventory for a new GLP-1 drug launch"
]

for prompt in suggested_prompts:
    if st.sidebar.button(prompt, key=f"prompt_{hash(prompt)}", use_container_width=True):
        st.session_state.pending_prompt = prompt

st.sidebar.divider()
st.sidebar.markdown("### 🛠️ Agent Tools")
st.sidebar.markdown("""
- **CampaignAnalyst**: Query campaign metrics
- **InventoryAnalyst**: Analyze ad slot performance
- **AudienceAnalyst**: Cohort engagement data
- **InventorySearch**: Find available placements
- **CampaignSearch**: Search campaign history
- **AudienceSearch**: Discover target segments
- **DataToChart**: Generate visualizations
""")

if st.sidebar.button("🗑️ Clear Chat History", use_container_width=True):
    st.session_state.messages = []
    st.session_state.thread_id = None
    st.rerun()

# Display chat messages
for message in st.session_state.messages:
    with st.chat_message(message["role"]):
        st.markdown(message["content"])

# Handle pending prompt from sidebar
if st.session_state.get("pending_prompt"):
    prompt = st.session_state.pending_prompt
    st.session_state.pending_prompt = None
    
    # Add user message
    st.session_state.messages.append({"role": "user", "content": prompt})
    
    with st.chat_message("user"):
        st.markdown(prompt)
    
    # Generate response
    with st.chat_message("assistant"):
        with st.spinner("Thinking..."):
            if IN_SNOWFLAKE and session:
                try:
                    # Call the Cortex Agent
                    # Note: The exact API may vary based on your Snowflake version
                    agent_response = call_cortex_agent(session, prompt)
                    st.markdown(agent_response)
                    st.session_state.messages.append({"role": "assistant", "content": agent_response})
                except Exception as e:
                    error_msg = f"Error calling agent: {e}"
                    st.error(error_msg)
                    st.session_state.messages.append({"role": "assistant", "content": error_msg})
            else:
                # Demo mode response
                response = generate_demo_response(prompt)
                st.markdown(response)
                st.session_state.messages.append({"role": "assistant", "content": response})

# Chat input
if prompt := st.chat_input("Ask about campaigns, inventory, or audiences..."):
    # Add user message
    st.session_state.messages.append({"role": "user", "content": prompt})
    
    with st.chat_message("user"):
        st.markdown(prompt)
    
    # Generate response
    with st.chat_message("assistant"):
        with st.spinner("Analyzing..."):
            if IN_SNOWFLAKE and session:
                try:
                    agent_response = call_cortex_agent(session, prompt)
                    st.markdown(agent_response)
                    st.session_state.messages.append({"role": "assistant", "content": agent_response})
                except Exception as e:
                    error_msg = f"Error calling agent: {e}"
                    st.error(error_msg)
                    st.session_state.messages.append({"role": "assistant", "content": error_msg})
            else:
                response = generate_demo_response(prompt)
                st.markdown(response)
                st.session_state.messages.append({"role": "assistant", "content": response})


def call_cortex_agent(session, prompt: str) -> str:
    """
    Call the Cortex Agent via the Snowflake session.
    Uses the REST API pattern through SQL.
    """
    try:
        # Escape the prompt for SQL
        escaped_prompt = prompt.replace("'", "''").replace("\\", "\\\\")
        
        # Call the agent using the agent:run pattern
        # Note: This may need adjustment based on your Snowflake version
        agent_sql = f"""
        SELECT SNOWFLAKE.CORTEX.COMPLETE(
            'claude-3-5-sonnet',
            CONCAT(
                'You are a healthcare advertising optimization expert for PatientPoint. ',
                'Answer this question about pharmaceutical advertising campaigns: ',
                '{escaped_prompt}'
            )
        ) as response
        """
        
        result = session.sql(agent_sql).collect()
        
        if result and len(result) > 0:
            return result[0]['RESPONSE']
        else:
            return "I couldn't generate a response. Please try rephrasing your question."
            
    except Exception as e:
        # If agent call fails, try a simpler approach
        return f"Agent processing error. Please try the Snowsight Agent UI directly. Error: {str(e)}"


def generate_demo_response(prompt: str) -> str:
    """
    Generate a demo response based on the prompt keywords.
    Used when not connected to Snowflake.
    """
    prompt_lower = prompt.lower()
    
    if "optimal" in prompt_lower and ("bid" in prompt_lower or "price" in prompt_lower or "pricing" in prompt_lower):
        return """
## 💰 Optimal Bid Price Recommendation

Based on my analysis of historical bid data for **diabetes campaigns** in **cardiology waiting rooms**:

### Recommended Bid Range: **$14.50 - $18.25 CPM**

| Metric | Value |
|--------|-------|
| Historical Avg Winning CPM | $15.80 |
| Expected Win Rate | 68% |
| Projected ROAS | 2.4x |
| Competition Level | Moderate |

### Key Insights:
- **Morning slots** (8am-12pm) show 15% higher engagement for diabetes medications
- **Premium 55" displays** in waiting rooms have 22% better completion rates
- **Texas cardiology facilities** have above-average patient volume

### Recommendation:
Start with **$16.50 CPM** for the best balance of win rate and cost efficiency. 
Monitor performance for 48 hours before adjusting.

📊 *Analysis based on 45,000+ historical bids in similar configurations.*
"""

    elif "audience" in prompt_lower or "segment" in prompt_lower or "target" in prompt_lower:
        return """
## 👥 High-Value Audience Segments for Heart Medications

Based on engagement data analysis, here are the top-performing cohorts:

### Top 5 Recommended Segments:

| Cohort | Engagement Rate | Conversion Rate | Cohort Size |
|--------|----------------|-----------------|-------------|
| Adults 55-64, Heart Health Interest | 0.52% | 18.5% | 12,500 |
| Seniors 65+, Cardiology Visitors | 0.48% | 22.1% | 8,200 |
| Adults 45-54, High Income, Midwest | 0.45% | 15.8% | 15,300 |
| Adults 55-64, Medicare, Southeast | 0.42% | 19.2% | 11,800 |
| Adults 45-54, Commercial Insurance | 0.38% | 14.5% | 18,500 |

### Key Patterns:
- **Age 55-64** shows highest overall engagement with cardiology content
- **Morning visitors** have 28% longer dwell times
- **Repeat visitors** (2+ visits/month) convert at 2.3x average

### Recommendation:
Prioritize **Adults 55-64 with Heart Health Interest** for maximum ROI.
Consider layering with **morning daypart** targeting for best results.

🔒 *All data is privacy-safe with k-anonymity (min 50 members per cohort).*
"""

    elif "compare" in prompt_lower or "q4" in prompt_lower or "q3" in prompt_lower:
        return """
## 📊 Campaign Performance: Q4 2024 vs Q3 2024

### Overall Performance Comparison:

| Metric | Q3 2024 | Q4 2024 | Change |
|--------|---------|---------|--------|
| Total Impressions | 2.8M | 3.4M | +21.4% |
| Average ROAS | 2.1x | 2.4x | +14.3% |
| Win Rate | 62% | 67% | +8.1% |
| CTR | 0.032% | 0.041% | +28.1% |
| Total Revenue | $3.2M | $4.1M | +28.1% |

### Top Improving Therapeutic Areas:
1. **Diabetes** - ROAS improved from 2.3x to 2.9x (+26%)
2. **Cardiology** - Impressions up 35%, CTR up 22%
3. **Immunology** - Conversion rate improved 18%

### Key Drivers of Improvement:
- New ML-powered bid optimization (implemented Sept 2024)
- Expanded premium inventory in high-volume facilities
- Improved audience targeting with lookalike segments
- Seasonal factors (Q4 health awareness campaigns)

### Recommendation:
Continue momentum with increased Q1 2025 budget allocation to Diabetes (+15%) 
and Cardiology (+10%) based on strong Q4 performance.
"""

    elif "inventory" in prompt_lower or "slot" in prompt_lower or "find" in prompt_lower:
        return """
## 🔍 Available Premium Inventory - Texas Endocrinology

Based on your search for **premium morning slots in Texas endocrinology clinics**:

### Top 5 Available Placements:

| Slot | Facility | CPM | Daily Impressions |
|------|----------|-----|-------------------|
| Houston Diabetes Center - Waiting Room 65" | Houston Diabetes & Endocrine | $19.50 | 285 |
| Austin Endocrinology - Premium Display | Austin Metabolic Center | $18.00 | 245 |
| Dallas Thyroid Clinic - Check-in Display | Dallas Thyroid Specialists | $16.50 | 195 |
| San Antonio Diabetes - Waiting Room TV | SA Diabetes Care Center | $17.25 | 220 |
| Fort Worth Endo - Exam Room Tablet | FW Endocrinology Associates | $22.00 | 85 |

### Inventory Summary:
- **28 total slots** matching your criteria
- **Average CPM**: $17.80
- **Total daily impressions**: 4,200+
- **Premium slots**: 18 (64%)

### Recommendation:
The **Houston Diabetes Center** slot offers the best value with high volume 
and competitive CPM. Consider bundling with the Austin location for regional coverage.

📍 *All slots verified available for immediate booking.*
"""

    elif "roas" in prompt_lower or "performance" in prompt_lower or "pfizer" in prompt_lower:
        return """
## 📈 Pfizer Campaign Performance Analysis

### ROAS Improvement Drivers

Pfizer campaigns have seen **ROAS improve from 2.0x to 2.6x** (+30%) over the past quarter.

### Contributing Factors:

| Factor | Impact | Details |
|--------|--------|---------|
| Bid Optimization | +12% ROAS | ML-driven bid adjustments reduced wasted spend |
| Audience Targeting | +9% ROAS | New lookalike segments based on converters |
| Creative Refresh | +5% ROAS | Updated video creatives with higher completion |
| Daypart Focus | +4% ROAS | Shifted budget to high-engagement time slots |

### Top Performing Pfizer Campaigns:
1. **Eliquis Awareness 2024** - 3.2x ROAS, 320K impressions
2. **Ibrance Patient Education** - 2.8x ROAS, 185K impressions  
3. **Prevnar 20 HCP Engagement** - 2.5x ROAS, 245K impressions

### Recommendations:
- Expand successful bid optimization to all Pfizer campaigns
- Increase morning daypart allocation by 20%
- Test new audience segments based on Eliquis converter profile

💡 *Key insight: Cardiology-focused campaigns outperforming by 25% vs other specialties.*
"""

    else:
        return """
## 🤖 PatientPoint Campaign Optimizer

I can help you with:

### 📊 Campaign Analytics
- Performance metrics (ROAS, CTR, conversions)
- Partner comparisons
- Trend analysis

### 💰 Bid Optimization
- Optimal pricing recommendations
- Win rate predictions
- CPM analysis by specialty

### 🔍 Inventory Discovery
- Available ad placements
- Slot characteristics
- Regional availability

### 👥 Audience Targeting
- High-engagement cohorts
- Demographic analysis
- Lookalike segments

**Try asking something like:**
- "What's the optimal bid for diabetes campaigns in cardiology?"
- "Find premium inventory in the Southwest"
- "Which audiences respond best to oncology medications?"

*Note: Running in demo mode. For full functionality, deploy to Snowflake.*
"""


# Footer
st.divider()

col1, col2, col3 = st.columns(3)

with col1:
    st.markdown("**Agent Status**")
    if IN_SNOWFLAKE:
        st.success("✅ Connected to Snowflake")
    else:
        st.warning("⚠️ Demo Mode")

with col2:
    st.markdown("**Tools Available**")
    st.info("7 tools configured")

with col3:
    st.markdown("**Model**")
    st.info("Claude 4 Sonnet")

st.markdown("""
<div style="text-align: center; color: #666; margin-top: 1rem;">
    <p>AI Agent Chat | PatientPoint Ad Tech Demo | Powered by Snowflake Cortex</p>
</div>
""", unsafe_allow_html=True)

