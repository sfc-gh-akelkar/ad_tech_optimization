"""
================================================================================
PATIENTPOINT COMMAND CENTER - STREAMLIT DASHBOARD
================================================================================
A sophisticated operations dashboard for monitoring interactive display fleet health.
Features real-time geospatial visualization, predictive analytics, and an
AI-powered operations agent for natural language queries.

PatientPoint's digital displays deliver patient engagement content and pharmaceutical
advertising across healthcare facilities nationwide.
================================================================================
"""

import streamlit as st
import pandas as pd
import numpy as np
import plotly.express as px
import plotly.graph_objects as go
import pydeck as pdk
from datetime import datetime, timedelta
import time
import json
from snowflake.snowpark import Session
import yaml

# ============================================================================
# PAGE CONFIGURATION
# ============================================================================
st.set_page_config(
    page_title="PatientPoint Command Center",
    page_icon="🏥",
    layout="wide",
    initial_sidebar_state="expanded"
)

# ============================================================================
# CUSTOM STYLING
# ============================================================================
st.markdown("""
<style>
    /* Main title styling */
    .main-header {
        font-size: 2.5rem;
        font-weight: 700;
        color: #1f77b4;
        text-align: center;
        padding: 1rem 0;
        border-bottom: 3px solid #1f77b4;
        margin-bottom: 2rem;
    }
    
    /* Metric card styling */
    .metric-card {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        padding: 1.5rem;
        border-radius: 10px;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        color: white;
    }
    
    /* Critical alert styling */
    .critical-alert {
        background-color: #ff4444;
        color: white;
        padding: 1rem;
        border-radius: 8px;
        font-weight: 600;
        text-align: center;
        margin: 1rem 0;
        animation: pulse 2s infinite;
    }
    
    @keyframes pulse {
        0%, 100% { opacity: 1; }
        50% { opacity: 0.7; }
    }
    
    /* Section headers */
    .section-header {
        font-size: 1.5rem;
        font-weight: 600;
        color: #2c3e50;
        margin-top: 2rem;
        margin-bottom: 1rem;
        border-left: 4px solid #1f77b4;
        padding-left: 1rem;
    }
    
    /* AI Agent styling */
    .ai-agent-header {
        background: linear-gradient(90deg, #00d2ff 0%, #3a7bd5 100%);
        color: white;
        padding: 1rem;
        border-radius: 8px 8px 0 0;
        font-weight: 600;
        font-size: 1.2rem;
    }
    
    /* Suggested query buttons */
    .stButton > button {
        width: 100%;
        border-radius: 6px;
        font-weight: 500;
        transition: all 0.3s;
    }
    
    /* Hide Streamlit branding */
    #MainMenu {visibility: hidden;}
    footer {visibility: hidden;}
</style>
""", unsafe_allow_html=True)

# ============================================================================
# SNOWFLAKE CONNECTION (Streamlit in Snowflake Native)
# ============================================================================
@st.cache_resource
def get_snowflake_session():
    """
    Establish Snowflake connection.
    In Streamlit in Snowflake (SiS), the connection is automatic.
    """
    try:
        # For Streamlit in Snowflake, use the native connection
        # This automatically uses the current session context
        return Session.builder.getOrCreate()
    except Exception as e:
        st.error(f"Failed to establish Snowflake session: {str(e)}")
        st.stop()

# ============================================================================
# DATA LOADING FUNCTIONS
# ============================================================================
@st.cache_data(ttl=300)  # Cache for 5 minutes
def load_fleet_health_data(_session):
    """Load real-time fleet health scores from Snowflake."""
    query = """
    SELECT 
        device_id,
        region,
        hospital_name,
        last_ping,
        cpu_load,
        voltage,
        memory_usage,
        temperature,
        uptime_hours,
        failure_probability,
        predicted_failure_type,
        latitude,
        longitude
    FROM PATIENTPOINT_OPS.DEVICE_ANALYTICS.FLEET_HEALTH_SCORED
    ORDER BY failure_probability DESC
    """
    return _session.sql(query).to_pandas()

@st.cache_data(ttl=300)
def load_fleet_metrics(_session):
    """Load aggregated fleet health metrics."""
    query = """
    SELECT * FROM PATIENTPOINT_OPS.DEVICE_ANALYTICS.VW_FLEET_HEALTH_METRICS
    """
    return _session.sql(query).to_pandas()

@st.cache_data(ttl=300)
def load_regional_breakdown(_session):
    """Load regional health breakdown."""
    query = """
    SELECT * FROM PATIENTPOINT_OPS.DEVICE_ANALYTICS.VW_REGIONAL_HEALTH
    ORDER BY critical_count DESC
    """
    return _session.sql(query).to_pandas()

@st.cache_data(ttl=300)
def load_failure_type_analysis(_session):
    """Load failure type analysis."""
    query = """
    SELECT * FROM PATIENTPOINT_OPS.DEVICE_ANALYTICS.VW_FAILURE_TYPE_ANALYSIS
    ORDER BY device_count DESC
    """
    return _session.sql(query).to_pandas()

# ============================================================================
# CORTEX AGENT FUNCTIONS
# ============================================================================
def query_cortex_analyst(session, question, semantic_model_path="semantic_model.yaml"):
    """
    Query Cortex Analyst for structured data questions.
    Uses the semantic model to translate natural language to SQL.
    """
    try:
        # Load semantic model
        with open(semantic_model_path, 'r') as f:
            semantic_model = yaml.safe_load(f)
        
        # Use Cortex Complete via SQL call (SiS compatible)
        prompt = f"""You are a SQL expert analyzing medical device fleet data.
        
Semantic Model Context:
- Database: PATIENTPOINT_OPS.DEVICE_ANALYTICS
- Main Table: FLEET_HEALTH_SCORED
- Key Metrics: failure_probability (0-1), predicted_failure_type, region, hospital_name
- Critical devices have failure_probability > 0.85
- At-risk devices have failure_probability > 0.70

User Question: {question}

Generate a SQL query to answer this question. Return ONLY the SQL query, no explanation.
"""
        
        # Call Cortex Complete via SQL (works in Streamlit in Snowflake)
        llm_query = f"""
        SELECT SNOWFLAKE.CORTEX.COMPLETE(
            'mistral-large2',
            $${prompt}$$
        ) AS generated_sql
        """
        
        llm_result = session.sql(llm_query).collect()
        sql_query = llm_result[0]['GENERATED_SQL'] if llm_result else None
        
        if not sql_query:
            st.warning("Could not generate SQL query")
            return None, None
        
        # Execute the generated SQL
        result = session.sql(sql_query).to_pandas()
        return result, sql_query
        
    except Exception as e:
        st.error(f"Error querying Cortex Analyst: {str(e)}")
        return None, None

def query_cortex_search(session, question):
    """
    Query Cortex Search Service for unstructured documentation questions.
    Searches repair manuals and troubleshooting guides.
    """
    try:
        search_query = f"""
        SELECT
          SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
            'PATIENTPOINT_OPS.DEVICE_ANALYTICS.RUNBOOK_SEARCH_SERVICE',
            '{{
              "query": "{question}",
              "columns": ["title", "failure_category", "content", "severity", "estimated_repair_time", "safety_notes"],
              "limit": 3
            }}'
          ) AS search_results
        """
        
        result = session.sql(search_query).to_pandas()
        
        # Parse JSON results
        if not result.empty and 'SEARCH_RESULTS' in result.columns:
            search_results = json.loads(result['SEARCH_RESULTS'].iloc[0])
            return search_results.get('results', [])
        return []
        
    except Exception as e:
        st.error(f"Error querying Cortex Search: {str(e)}")
        return []

def composite_agent_query(session, question):
    """
    Composite Agent: Combines Cortex Analyst (structured) + Cortex Search (unstructured).
    Example: "Find all overheating devices and summarize the recommended repair steps."
    """
    try:
        # Step 1: Use Analyst to find relevant devices
        if "overheating" in question.lower():
            analyst_query = "SELECT device_id, hospital_name, region, failure_probability FROM FLEET_HEALTH_SCORED WHERE predicted_failure_type = 'Overheating' AND failure_probability > 0.70 ORDER BY failure_probability DESC"
            devices_df = session.sql(analyst_query).to_pandas()
            
            # Step 2: Use Search to get repair guidance
            search_results = query_cortex_search(session, "How to fix overheating devices?")
            
            return {
                "devices": devices_df,
                "repair_guidance": search_results,
                "type": "composite"
            }
        elif "memory leak" in question.lower():
            analyst_query = "SELECT device_id, hospital_name, region, failure_probability FROM FLEET_HEALTH_SCORED WHERE predicted_failure_type = 'Memory Leak' AND failure_probability > 0.70 ORDER BY failure_probability DESC"
            devices_df = session.sql(analyst_query).to_pandas()
            search_results = query_cortex_search(session, "How to fix memory leak issues?")
            
            return {
                "devices": devices_df,
                "repair_guidance": search_results,
                "type": "composite"
            }
        else:
            return None
            
    except Exception as e:
        st.error(f"Error in composite query: {str(e)}")
        return None

# ============================================================================
# VISUALIZATION FUNCTIONS
# ============================================================================
def create_geospatial_map(df):
    """
    Create an interactive geospatial map using PyDeck.
    Color-coded by risk level: Green (<50%), Yellow (50-80%), Red (>80%)
    """
    # Add color based on failure probability
    def get_color(prob):
        if prob > 0.80:
            return [255, 0, 0, 200]  # Red - Critical
        elif prob > 0.50:
            return [255, 165, 0, 200]  # Orange - Medium
        else:
            return [0, 255, 0, 200]  # Green - Healthy
    
    # Note: Column names from Snowflake are UPPERCASE
    df['color'] = df['FAILURE_PROBABILITY'].apply(get_color)
    df['radius'] = df['FAILURE_PROBABILITY'].apply(lambda x: 15000 if x > 0.8 else 10000)
    
    # Create PyDeck layer
    layer = pdk.Layer(
        "ScatterplotLayer",
        data=df,
        get_position=['LONGITUDE', 'LATITUDE'],
        get_color='color',
        get_radius='radius',
        pickable=True,
        opacity=0.8,
        stroked=True,
        filled=True,
        radius_scale=1,
        radius_min_pixels=3,
        radius_max_pixels=15,
    )
    
    # Set the viewport location
    view_state = pdk.ViewState(
        latitude=39.8283,
        longitude=-98.5795,
        zoom=3.5,
        pitch=0,
    )
    
    # Tooltip
    tooltip = {
        "html": "<b>Device:</b> {device_id}<br/>"
                "<b>Hospital:</b> {hospital_name}<br/>"
                "<b>Region:</b> {region}<br/>"
                "<b>Failure Probability:</b> {failure_probability:.1%}<br/>"
                "<b>Failure Type:</b> {predicted_failure_type}",
        "style": {
            "backgroundColor": "steelblue",
            "color": "white"
        }
    }
    
    # Render
    deck = pdk.Deck(
        layers=[layer],
        initial_view_state=view_state,
        tooltip=tooltip,
        map_style='mapbox://styles/mapbox/dark-v10'
    )
    
    return deck

def create_failure_type_chart(df):
    """Create a bar chart showing failure type distribution for at-risk devices."""
    fig = px.bar(
        df,
        x='predicted_failure_type',
        y='device_count',
        title='At-Risk Devices by Failure Type',
        labels={'device_count': 'Device Count', 'predicted_failure_type': 'Failure Type'},
        color='avg_probability',
        color_continuous_scale='Reds',
        text='device_count'
    )
    fig.update_traces(textposition='outside')
    fig.update_layout(
        xaxis_tickangle=-45,
        height=400,
        showlegend=False
    )
    return fig

def create_regional_heatmap(df):
    """Create a choropleth-style bar chart for regional analysis."""
    fig = px.bar(
        df,
        x='region',
        y='critical_count',
        title='Critical Devices by Region',
        labels={'critical_count': 'Critical Device Count', 'region': 'State'},
        color='avg_failure_prob',
        color_continuous_scale='RdYlGn_r',
        text='critical_count',
        hover_data=['total_devices', 'revenue_at_risk']
    )
    fig.update_traces(textposition='outside')
    fig.update_layout(
        xaxis_tickangle=-45,
        height=400
    )
    return fig

# ============================================================================
# MAIN APPLICATION
# ============================================================================
def main():
    # Header
    st.markdown('<div class="main-header">🏥 PatientPoint Command Center</div>', unsafe_allow_html=True)
    st.markdown("**Real-Time Interactive Display Fleet Monitoring & Predictive Maintenance**")
    
    # Initialize Snowflake session
    try:
        session = get_snowflake_session()
    except Exception as e:
        st.error(f"❌ Failed to connect to Snowflake: {str(e)}")
        st.info("💡 **Setup Instructions:**\n\n1. Run `setup_backend.sql` in your Snowflake account\n2. Configure Streamlit secrets with your Snowflake credentials\n3. Ensure the semantic model YAML is in the same directory")
        st.stop()
    
    # Sidebar - Controls
    with st.sidebar:
        st.image("https://via.placeholder.com/300x100/1f77b4/ffffff?text=PatientPoint+Ops", use_container_width=True)
        st.markdown("## ⚙️ Dashboard Controls")
        
        # Refresh button
        if st.button("🔄 Refresh Data", use_container_width=True, type="primary"):
            st.cache_data.clear()
            st.rerun()
        
        st.markdown("---")
        
        # Filters
        st.markdown("### 🔍 Filters")
        
        # Risk level filter
        risk_filter = st.multiselect(
            "Risk Level",
            ["Critical (>85%)", "High (70-85%)", "Medium (50-70%)", "Low (<50%)"],
            default=["Critical (>85%)", "High (70-85%)"]
        )
        
        # Region filter
        regions = ["All"] + sorted([
            "New York", "California", "Texas", "Illinois", "Massachusetts",
            "Pennsylvania", "Florida", "Ohio", "Michigan", "Washington"
        ])
        region_filter = st.selectbox("Region", regions)
        
        st.markdown("---")
        
        # System info
        st.markdown("### 📊 System Info")
        st.markdown(f"**Last Updated:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        st.markdown(f"**Data Refresh:** Every 5 minutes")
        st.markdown(f"**Displays Monitored:** 500")
        st.markdown(f"**ML Model:** XGBoost v2.1")
        
    # Load data
    with st.spinner("Loading fleet data..."):
        fleet_df = load_fleet_health_data(session)
        metrics_df = load_fleet_metrics(session)
        regional_df = load_regional_breakdown(session)
        failure_df = load_failure_type_analysis(session)
    
    # Apply filters
    filtered_df = fleet_df.copy()
    
    if region_filter != "All":
        filtered_df = filtered_df[filtered_df['REGION'] == region_filter]
    
    # ========================================================================
    # SECTION A: TOP-LINE KPIs (Metric Row)
    # ========================================================================
    st.markdown('<div class="section-header">📈 Fleet Health Overview</div>', unsafe_allow_html=True)
    
    if not metrics_df.empty:
        metrics = metrics_df.iloc[0]
        
        # Calculate fleet health percentage
        # Note: Snowflake returns column names in UPPERCASE
        fleet_health_pct = (1 - metrics['AVG_FAILURE_PROBABILITY']) * 100
        critical_devices = int(metrics['CRITICAL_DEVICES'])
        revenue_at_risk = float(metrics['REVENUE_AT_RISK_USD'])
        
        # Display critical alert if needed
        if critical_devices >= 15:
            st.markdown(
                f'<div class="critical-alert">⚠️ ALERT: {critical_devices} devices require immediate attention!</div>',
                unsafe_allow_html=True
            )
        
        # Metrics row
        col1, col2, col3, col4 = st.columns(4)
        
        with col1:
            st.metric(
                label="Fleet Health Score",
                value=f"{fleet_health_pct:.1f}%",
                delta="+2.3% vs last week",
                delta_color="normal"
            )
        
        with col2:
            st.metric(
                label="Predicted Failures (24h)",
                value=f"{critical_devices} Devices",
                delta=f"+{critical_devices - 15} from yesterday" if critical_devices > 15 else "Stable",
                delta_color="inverse"
            )
        
        with col3:
            st.metric(
                label="Revenue Protected",
                value=f"${revenue_at_risk:,.0f}",
                delta="Potential 24h loss prevented",
                delta_color="off"
            )
        
        with col4:
            offline_count = int(metrics.get('OFFLINE_DEVICES', 0))
            st.metric(
                label="Offline Devices",
                value=f"{offline_count}",
                delta="Normal" if offline_count < 5 else "Review needed",
                delta_color="normal" if offline_count < 5 else "inverse"
            )
    
    # ========================================================================
    # SECTION B: GEOSPATIAL FLEET MAP (The Hero Visual)
    # ========================================================================
    st.markdown('<div class="section-header">🗺️ Live Fleet Map</div>', unsafe_allow_html=True)
    
    col_map, col_legend = st.columns([4, 1])
    
    with col_map:
        if not filtered_df.empty:
            map_deck = create_geospatial_map(filtered_df)
            st.pydeck_chart(map_deck)
        else:
            st.warning("No devices match the selected filters.")
    
    with col_legend:
        st.markdown("**Risk Legend:**")
        st.markdown("🔴 **Critical** (>80%)")
        st.markdown("🟠 **Medium** (50-80%)")
        st.markdown("🟢 **Healthy** (<50%)")
        st.markdown("---")
        st.markdown(f"**Total Devices:** {len(filtered_df)}")
        st.markdown(f"**Critical:** {len(filtered_df[filtered_df['FAILURE_PROBABILITY'] > 0.80])}")
        st.markdown(f"**At Risk:** {len(filtered_df[filtered_df['FAILURE_PROBABILITY'] > 0.70])}")
    
    # ========================================================================
    # ADDITIONAL ANALYTICS
    # ========================================================================
    st.markdown('<div class="section-header">📊 Detailed Analytics</div>', unsafe_allow_html=True)
    
    col_chart1, col_chart2 = st.columns(2)
    
    with col_chart1:
        if not failure_df.empty:
            fig_failure = create_failure_type_chart(failure_df)
            st.plotly_chart(fig_failure, use_container_width=True)
    
    with col_chart2:
        if not regional_df.empty:
            fig_regional = create_regional_heatmap(regional_df.head(10))
            st.plotly_chart(fig_regional, use_container_width=True)
    
    # Critical devices table
    st.markdown('<div class="section-header">🚨 Critical Devices Requiring Immediate Action</div>', unsafe_allow_html=True)
    
    critical_df = filtered_df[filtered_df['FAILURE_PROBABILITY'] > 0.80].copy()
    critical_df = critical_df[[
        'DEVICE_ID', 'HOSPITAL_NAME', 'REGION', 'FAILURE_PROBABILITY', 
        'PREDICTED_FAILURE_TYPE', 'CPU_LOAD', 'TEMPERATURE', 'LAST_PING'
    ]].sort_values('FAILURE_PROBABILITY', ascending=False)
    
    if not critical_df.empty:
        st.dataframe(
            critical_df.style.background_gradient(subset=['FAILURE_PROBABILITY'], cmap='Reds'),
            use_container_width=True,
            height=300
        )
    else:
        st.success("✅ No critical devices at this time!")
    
    # ========================================================================
    # SECTION C: CORTEX AI CO-PILOT (Bottom Expander)
    # ========================================================================
    st.markdown("---")
    st.markdown('<div class="ai-agent-header">🤖 AI Operations Agent - Powered by Snowflake Cortex</div>', unsafe_allow_html=True)
    
    with st.expander("💬 Ask the AI Agent", expanded=False):
        st.markdown("""
        The AI Agent combines **Cortex Analyst** (for structured data queries) and **Cortex Search** (for repair manuals).
        Ask questions in natural language!
        """)
        
        # Suggested prompts
        st.markdown("**💡 Suggested Queries:**")
        
        col_btn1, col_btn2, col_btn3 = st.columns(3)
        
        with col_btn1:
            if st.button("📍 Critical devices in New York", use_container_width=True):
                st.session_state['agent_query'] = "Show me the list of critical devices in New York"
        
        with col_btn2:
            if st.button("🔧 Fix for Memory Leak", use_container_width=True):
                st.session_state['agent_query'] = "What is the standard fix for Memory Leak errors?"
        
        with col_btn3:
            if st.button("🔥 Overheating devices + repair steps", use_container_width=True):
                st.session_state['agent_query'] = "Find all overheating devices and summarize the recommended repair steps"
        
        # Custom query input
        user_query = st.text_input(
            "Or type your own question:",
            value=st.session_state.get('agent_query', ''),
            placeholder="e.g., What are the most common failure types in California?"
        )
        
        if st.button("🚀 Ask Agent", type="primary", use_container_width=True):
            if user_query:
                with st.spinner("AI Agent is thinking..."):
                    # Determine query type
                    if any(word in user_query.lower() for word in ["fix", "repair", "how to", "troubleshoot", "procedure"]):
                        # This is a SEARCH query (unstructured documentation)
                        st.markdown("**Query Type:** 🔍 Documentation Search (Cortex Search)")
                        results = query_cortex_search(session, user_query)
                        
                        if results:
                            for idx, result in enumerate(results, 1):
                                st.markdown(f"### 📄 Result {idx}: {result.get('title', 'N/A')}")
                                st.markdown(f"**Category:** {result.get('failure_category', 'N/A')}")
                                st.markdown(f"**Severity:** {result.get('severity', 'N/A')}")
                                st.markdown(f"**Estimated Time:** {result.get('estimated_repair_time', 'N/A')}")
                                
                                with st.expander("View Full Content"):
                                    st.text(result.get('content', 'No content available'))
                                
                                st.markdown(f"**⚠️ Safety Notes:** {result.get('safety_notes', 'N/A')}")
                                st.markdown("---")
                        else:
                            st.warning("No documentation found for this query.")
                    
                    elif "and" in user_query.lower() and any(word in user_query.lower() for word in ["find", "show", "list"]):
                        # This is a COMPOSITE query
                        st.markdown("**Query Type:** 🔀 Composite Query (Analyst + Search)")
                        result = composite_agent_query(session, user_query)
                        
                        if result and result['type'] == 'composite':
                            st.markdown("### 📊 Matching Devices:")
                            st.dataframe(result['devices'], use_container_width=True)
                            
                            st.markdown("### 🔧 Repair Guidance:")
                            for guidance in result['repair_guidance']:
                                st.markdown(f"**{guidance.get('title', 'Repair Guide')}**")
                                st.markdown(f"*{guidance.get('estimated_repair_time', 'N/A')}*")
                                with st.expander("View Details"):
                                    st.text(guidance.get('content', 'No content')[:500] + "...")
                        else:
                            st.warning("Could not process composite query.")
                    
                    else:
                        # This is an ANALYST query (structured data)
                        st.markdown("**Query Type:** 📊 Data Analysis (Cortex Analyst)")
                        result_df, sql = query_cortex_analyst(session, user_query)
                        
                        if result_df is not None and not result_df.empty:
                            st.markdown("### 📈 Results:")
                            st.dataframe(result_df, use_container_width=True)
                            
                            with st.expander("🔍 View Generated SQL"):
                                st.code(sql, language='sql')
                        else:
                            st.warning("No results found or query could not be processed.")
            else:
                st.warning("Please enter a question.")

if __name__ == "__main__":
    main()

