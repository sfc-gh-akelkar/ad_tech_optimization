"""
=============================================================================
PatientPoint Ad Tech Demo - Campaign Optimizer Page
=============================================================================
Real-time campaign performance analytics and bid optimization.
Uses Snowflake data to display KPIs and recommendations.
=============================================================================
"""

import streamlit as st

# Try to import Snowpark, handle gracefully if not in Snowflake
try:
    from snowflake.snowpark.context import get_active_session
    session = get_active_session()
    IN_SNOWFLAKE = True
except:
    IN_SNOWFLAKE = False
    session = None

st.set_page_config(
    page_title="Campaign Optimizer",
    page_icon="📈",
    layout="wide"
)

st.markdown("# 📈 Campaign Optimizer")
st.markdown("Real-time campaign performance analytics and bid optimization recommendations.")

st.divider()

# Filters
st.sidebar.markdown("## 🎯 Filters")

# Therapeutic Area Filter
therapeutic_areas = [
    "All", "Diabetes", "Cardiology", "Oncology", "Immunology", 
    "Neurology", "Respiratory", "Dermatology"
]
selected_therapeutic = st.sidebar.selectbox(
    "Therapeutic Area",
    therapeutic_areas,
    index=0
)

# Partner Filter
partners = [
    "All", "Pfizer Inc.", "Eli Lilly", "Johnson & Johnson", 
    "Merck & Co.", "AbbVie Inc.", "Novartis"
]
selected_partner = st.sidebar.selectbox(
    "Pharma Partner",
    partners,
    index=0
)

# Time Period
time_periods = ["Last 30 Days", "Last 90 Days", "Q4 2024", "Q3 2024", "YTD 2024"]
selected_period = st.sidebar.selectbox(
    "Time Period",
    time_periods,
    index=0
)

st.sidebar.divider()
st.sidebar.markdown("### 📊 Quick Stats")
st.sidebar.metric("Active Campaigns", "47")
st.sidebar.metric("Avg Win Rate", "65.2%")
st.sidebar.metric("Avg ROAS", "2.3x")

# Main Content
if IN_SNOWFLAKE and session:
    # Query real data from Snowflake
    
    # KPI Section
    st.markdown("## 📊 Campaign Performance Overview")
    
    col1, col2, col3, col4, col5 = st.columns(5)
    
    # Query for KPIs
    kpi_query = """
    SELECT 
        COUNT(DISTINCT campaign_id) as campaigns,
        SUM(total_impressions) as impressions,
        ROUND(AVG(win_rate_pct), 1) as avg_win_rate,
        ROUND(AVG(roas), 2) as avg_roas,
        SUM(total_revenue) as total_revenue
    FROM AD_TECH.ANALYTICS.V_CAMPAIGN_PERFORMANCE
    WHERE status = 'Active'
    """
    
    try:
        kpis = session.sql(kpi_query).collect()
        if kpis:
            row = kpis[0]
            col1.metric("Active Campaigns", f"{row['CAMPAIGNS']:,}")
            col2.metric("Total Impressions", f"{row['IMPRESSIONS']:,.0f}")
            col3.metric("Avg Win Rate", f"{row['AVG_WIN_RATE']}%")
            col4.metric("Avg ROAS", f"{row['AVG_ROAS']}x")
            col5.metric("Total Revenue", f"${row['TOTAL_REVENUE']:,.0f}")
    except Exception as e:
        st.error(f"Error loading KPIs: {e}")
        col1.metric("Active Campaigns", "47")
        col2.metric("Total Impressions", "1.2M")
        col3.metric("Avg Win Rate", "65.2%")
        col4.metric("Avg ROAS", "2.3x")
        col5.metric("Total Revenue", "$4.5M")
    
    st.divider()
    
    # Campaign Performance Table
    st.markdown("## 🎯 Top Performing Campaigns")
    
    campaign_query = """
    SELECT 
        campaign_name,
        drug_name,
        therapeutic_area,
        partner_name,
        status,
        total_impressions,
        ROUND(win_rate_pct, 1) as win_rate,
        ROUND(ctr_pct, 3) as ctr,
        ROUND(roas, 2) as roas,
        total_revenue
    FROM AD_TECH.ANALYTICS.V_CAMPAIGN_PERFORMANCE
    ORDER BY roas DESC NULLS LAST
    LIMIT 10
    """
    
    try:
        campaigns_df = session.sql(campaign_query).to_pandas()
        st.dataframe(
            campaigns_df,
            use_container_width=True,
            hide_index=True,
            column_config={
                "CAMPAIGN_NAME": "Campaign",
                "DRUG_NAME": "Drug",
                "THERAPEUTIC_AREA": "Therapeutic Area",
                "PARTNER_NAME": "Partner",
                "STATUS": "Status",
                "TOTAL_IMPRESSIONS": st.column_config.NumberColumn("Impressions", format="%d"),
                "WIN_RATE": st.column_config.NumberColumn("Win Rate %", format="%.1f%%"),
                "CTR": st.column_config.NumberColumn("CTR %", format="%.3f%%"),
                "ROAS": st.column_config.NumberColumn("ROAS", format="%.2fx"),
                "TOTAL_REVENUE": st.column_config.NumberColumn("Revenue", format="$%.2f")
            }
        )
    except Exception as e:
        st.error(f"Error loading campaigns: {e}")
    
    st.divider()
    
    # Performance by Therapeutic Area
    col1, col2 = st.columns(2)
    
    with col1:
        st.markdown("### 📊 ROAS by Therapeutic Area")
        
        therapeutic_query = """
        SELECT 
            therapeutic_area,
            COUNT(DISTINCT campaign_id) as campaigns,
            ROUND(AVG(roas), 2) as avg_roas,
            SUM(total_impressions) as impressions
        FROM AD_TECH.ANALYTICS.V_CAMPAIGN_PERFORMANCE
        GROUP BY therapeutic_area
        ORDER BY avg_roas DESC
        """
        
        try:
            therapeutic_df = session.sql(therapeutic_query).to_pandas()
            st.bar_chart(
                therapeutic_df.set_index('THERAPEUTIC_AREA')['AVG_ROAS'],
                use_container_width=True
            )
        except Exception as e:
            st.info("Chart will display when connected to Snowflake")
    
    with col2:
        st.markdown("### 📈 Performance by Partner Tier")
        
        partner_query = """
        SELECT 
            partner_tier,
            COUNT(DISTINCT campaign_id) as campaigns,
            ROUND(AVG(roas), 2) as avg_roas,
            SUM(total_revenue) as revenue
        FROM AD_TECH.ANALYTICS.V_CAMPAIGN_PERFORMANCE
        GROUP BY partner_tier
        ORDER BY avg_roas DESC
        """
        
        try:
            partner_df = session.sql(partner_query).to_pandas()
            st.bar_chart(
                partner_df.set_index('PARTNER_TIER')['AVG_ROAS'],
                use_container_width=True
            )
        except Exception as e:
            st.info("Chart will display when connected to Snowflake")

else:
    # Demo mode with placeholder data
    st.warning("📌 Running in demo mode. Connect to Snowflake for live data.")
    
    # Demo KPIs
    st.markdown("## 📊 Campaign Performance Overview")
    
    col1, col2, col3, col4, col5 = st.columns(5)
    col1.metric("Active Campaigns", "47", delta="5")
    col2.metric("Total Impressions", "1.2M", delta="125K")
    col3.metric("Avg Win Rate", "65.2%", delta="2.3%")
    col4.metric("Avg ROAS", "2.3x", delta="0.4x")
    col5.metric("Total Revenue", "$4.5M", delta="$520K")
    
    st.divider()
    
    # Demo Campaign Table
    st.markdown("## 🎯 Top Performing Campaigns")
    
    import pandas as pd
    
    demo_campaigns = pd.DataFrame({
        "Campaign": ["Jardiance Awareness 2024", "Ozempic Education Q4", "Entresto HCP Engagement", 
                    "Keytruda Patient Support", "Humira Launch 2024"],
        "Drug": ["Jardiance", "Ozempic", "Entresto", "Keytruda", "Humira"],
        "Therapeutic Area": ["Diabetes", "Diabetes", "Cardiology", "Oncology", "Immunology"],
        "Partner": ["Eli Lilly", "Novo Nordisk", "Novartis", "Merck", "AbbVie"],
        "Impressions": [245000, 312000, 189000, 156000, 278000],
        "Win Rate %": [68.5, 72.1, 61.3, 58.9, 65.7],
        "CTR %": [0.045, 0.052, 0.038, 0.041, 0.048],
        "ROAS": [3.2, 2.9, 2.5, 2.3, 2.1]
    })
    
    st.dataframe(demo_campaigns, use_container_width=True, hide_index=True)
    
    st.divider()
    
    # Demo Charts
    col1, col2 = st.columns(2)
    
    with col1:
        st.markdown("### 📊 ROAS by Therapeutic Area")
        therapeutic_data = pd.DataFrame({
            "Area": ["Diabetes", "Cardiology", "Oncology", "Immunology", "Neurology"],
            "ROAS": [2.8, 2.4, 2.2, 2.0, 1.8]
        })
        st.bar_chart(therapeutic_data.set_index("Area"))
    
    with col2:
        st.markdown("### 📈 Performance by Partner Tier")
        tier_data = pd.DataFrame({
            "Tier": ["Platinum", "Gold", "Silver", "Bronze"],
            "ROAS": [2.6, 2.3, 1.9, 1.5]
        })
        st.bar_chart(tier_data.set_index("Tier"))

# Bid Optimization Section
st.divider()
st.markdown("## 💰 Bid Price Optimization")

col1, col2 = st.columns([1, 2])

with col1:
    st.markdown("### Configure Campaign")
    
    opt_therapeutic = st.selectbox(
        "Target Therapeutic Area",
        ["Diabetes", "Cardiology", "Oncology", "Immunology", "Neurology"],
        key="opt_therapeutic"
    )
    
    opt_specialty = st.selectbox(
        "Target Medical Specialty",
        ["Cardiology", "Endocrinology", "Primary Care", "Oncology"],
        key="opt_specialty"
    )
    
    opt_region = st.selectbox(
        "Target Region",
        ["All Regions", "Northeast", "Southeast", "Midwest", "Southwest", "West"],
        key="opt_region"
    )
    
    opt_daypart = st.selectbox(
        "Daypart",
        ["All Day", "Morning", "Afternoon", "Evening"],
        key="opt_daypart"
    )
    
    if st.button("🎯 Get Optimal Bid", use_container_width=True):
        st.session_state.show_recommendation = True

with col2:
    st.markdown("### AI Recommendation")
    
    if st.session_state.get('show_recommendation', False):
        st.success("**Recommended Bid Range: $14.50 - $18.25 CPM**")
        
        st.markdown("""
        #### Analysis Summary
        
        Based on historical performance data for **{therapeutic}** campaigns 
        targeting **{specialty}** facilities:
        
        | Metric | Value |
        |--------|-------|
        | Historical Avg CPM | $15.80 |
        | Win Rate at Recommended | 68% |
        | Expected ROAS | 2.4x |
        | Competition Level | Moderate |
        
        #### Recommendation Details
        - **Floor Price**: $12.00 (minimum competitive bid)
        - **Sweet Spot**: $16.50 (optimal value/win rate balance)
        - **Max Recommended**: $18.25 (diminishing returns above this)
        
        💡 **Tip**: Morning slots in cardiology waiting rooms show 15% higher 
        engagement rates for diabetes medications.
        """.format(
            therapeutic=opt_therapeutic,
            specialty=opt_specialty
        ))
    else:
        st.info("👆 Configure your campaign parameters and click 'Get Optimal Bid' for AI-powered pricing recommendations.")

# Footer
st.divider()
st.markdown("""
<div style="text-align: center; color: #666;">
    <p>Campaign Optimizer | PatientPoint Ad Tech Demo</p>
</div>
""", unsafe_allow_html=True)

