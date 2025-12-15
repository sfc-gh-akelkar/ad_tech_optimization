"""
=============================================================================
PatientPoint Ad Tech Optimization Demo - Streamlit Application
=============================================================================
Main entry point for the Streamlit in Snowflake application.
Provides navigation to Campaign Optimizer, Inventory Explorer, and Agent Chat.

Deploy to Snowflake:
    CREATE STREAMLIT AD_TECH.APPS.AD_TECH_DEMO
    ROOT_LOCATION = '@AD_TECH.APPS.STREAMLIT_STAGE/ad_tech_demo'
    MAIN_FILE = 'Home.py'
    QUERY_WAREHOUSE = 'AD_TECH_WH';
=============================================================================
"""

import streamlit as st

# Page configuration
st.set_page_config(
    page_title="PatientPoint Ad Tech Optimizer",
    page_icon="🏥",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS for better styling
st.markdown("""
<style>
    .main-header {
        font-size: 2.5rem;
        font-weight: 700;
        color: #1E3A5F;
        margin-bottom: 0.5rem;
    }
    .sub-header {
        font-size: 1.2rem;
        color: #666;
        margin-bottom: 2rem;
    }
    .metric-card {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        padding: 1.5rem;
        border-radius: 12px;
        color: white;
        text-align: center;
    }
    .feature-card {
        background: #f8f9fa;
        padding: 1.5rem;
        border-radius: 12px;
        border-left: 4px solid #667eea;
        margin-bottom: 1rem;
    }
    .stButton>button {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
        border: none;
        padding: 0.5rem 2rem;
        border-radius: 8px;
        font-weight: 600;
    }
</style>
""", unsafe_allow_html=True)

# Header
st.markdown('<p class="main-header">🏥 PatientPoint Ad Tech Optimizer</p>', unsafe_allow_html=True)
st.markdown('<p class="sub-header">AI-Powered Healthcare Advertising Optimization Platform</p>', unsafe_allow_html=True)

st.divider()

# Overview Section
st.markdown("## 🎯 Platform Overview")

col1, col2, col3, col4 = st.columns(4)

with col1:
    st.metric(
        label="📊 Active Campaigns",
        value="100+",
        delta="12 new this month"
    )

with col2:
    st.metric(
        label="📍 Ad Placements",
        value="5,000+",
        delta="500 facilities"
    )

with col3:
    st.metric(
        label="👥 Audience Cohorts",
        value="200+",
        delta="Privacy-safe"
    )

with col4:
    st.metric(
        label="💊 Pharma Partners",
        value="20",
        delta="Top-tier brands"
    )

st.divider()

# Feature Cards
st.markdown("## 🚀 Demo Features")

col1, col2 = st.columns(2)

with col1:
    st.markdown("""
    <div class="feature-card">
        <h3>📈 Campaign Optimizer</h3>
        <p>Real-time bid optimization and campaign performance analytics. 
        Get AI-powered pricing recommendations based on historical data.</p>
        <ul>
            <li>Optimal bid price predictions</li>
            <li>ROAS analysis by therapeutic area</li>
            <li>Partner performance comparisons</li>
        </ul>
    </div>
    """, unsafe_allow_html=True)
    
    st.markdown("""
    <div class="feature-card">
        <h3>🔍 Inventory Explorer</h3>
        <p>Natural language search to discover available ad placements 
        across medical facilities nationwide.</p>
        <ul>
            <li>Search by specialty (Cardiology, Endocrinology, etc.)</li>
            <li>Filter by region, screen type, daypart</li>
            <li>View pricing and performance metrics</li>
        </ul>
    </div>
    """, unsafe_allow_html=True)

with col2:
    st.markdown("""
    <div class="feature-card">
        <h3>🤖 AI Agent Chat</h3>
        <p>Conversational AI assistant powered by Snowflake Cortex Agent 
        for intelligent campaign optimization.</p>
        <ul>
            <li>Natural language queries</li>
            <li>Multi-tool orchestration</li>
            <li>Automated visualizations</li>
        </ul>
    </div>
    """, unsafe_allow_html=True)
    
    st.markdown("""
    <div class="feature-card">
        <h3>👥 Audience Insights</h3>
        <p>Privacy-safe audience cohort discovery with HIPAA-compliant 
        analytics (k-anonymity enforced).</p>
        <ul>
            <li>Demographic segmentation</li>
            <li>Engagement pattern analysis</li>
            <li>Lookalike cohort discovery</li>
        </ul>
    </div>
    """, unsafe_allow_html=True)

st.divider()

# Quick Start Section
st.markdown("## 🎬 Demo Scenarios")

st.info("""
**Try these questions with the AI Agent:**

1. **Pricing Optimization:** "What's the optimal bid price for a diabetes campaign in cardiology waiting rooms?"

2. **Audience Targeting:** "Which audience segments have the highest engagement for heart medications?"

3. **Campaign Analysis:** "Compare Q4 2024 vs Q3 2024 campaign performance across all partners"

4. **Inventory Discovery:** "Find premium morning slots in Texas endocrinology clinics"

5. **Cross-functional:** "I'm launching a new GLP-1 drug. Recommend inventory and target audiences."
""")

# Navigation
st.markdown("## 📍 Navigate to Demo")

col1, col2, col3 = st.columns(3)

with col1:
    if st.button("📈 Campaign Optimizer", use_container_width=True):
        st.switch_page("pages/1_Campaign_Optimizer.py")

with col2:
    if st.button("🔍 Inventory Explorer", use_container_width=True):
        st.switch_page("pages/2_Inventory_Explorer.py")

with col3:
    if st.button("🤖 AI Agent Chat", use_container_width=True):
        st.switch_page("pages/3_Agent_Chat.py")

st.divider()

# Architecture
with st.expander("🏗️ Technical Architecture"):
    st.markdown("""
    ### Snowflake Capabilities Demonstrated
    
    | Component | Snowflake Feature | Purpose |
    |-----------|-------------------|---------|
    | Data Model | Dynamic Tables & Views | Real-time aggregations |
    | Semantic Layer | Semantic Views | Natural language to SQL |
    | Search | Cortex Search Services | Unstructured data discovery |
    | AI Assistant | Cortex Agents | Multi-tool orchestration |
    | Visualization | Data to Chart | Automated chart generation |
    | Application | Streamlit in Snowflake | Interactive demo UI |
    
    ### Data Pipeline
    ```
    Raw Data → Bronze Layer → Silver (Dim/Fact) → Gold (Aggregates) → Semantic Views → Cortex Agent
    ```
    
    ### Privacy & Compliance
    - All patient data is synthetic (HIPAA-safe demo)
    - K-anonymity enforced (minimum cohort size = 50)
    - Row-level security ready
    - Audit logging enabled
    """)

# Footer
st.divider()
st.markdown("""
<div style="text-align: center; color: #666; font-size: 0.9rem;">
    <p>PatientPoint Ad Tech Optimization Demo | Powered by Snowflake Cortex</p>
    <p>Built with ❄️ Snowflake Intelligence</p>
</div>
""", unsafe_allow_html=True)

