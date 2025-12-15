"""
=============================================================================
PatientPoint Ad Tech Demo - Inventory Explorer Page
=============================================================================
Natural language search and exploration of available ad inventory.
Uses Cortex Search for semantic discovery.
=============================================================================
"""

import streamlit as st

# Try to import Snowpark
try:
    from snowflake.snowpark.context import get_active_session
    session = get_active_session()
    IN_SNOWFLAKE = True
except:
    IN_SNOWFLAKE = False
    session = None

st.set_page_config(
    page_title="Inventory Explorer",
    page_icon="🔍",
    layout="wide"
)

st.markdown("# 🔍 Inventory Explorer")
st.markdown("Discover available ad placements using natural language search.")

st.divider()

# Search Section
st.markdown("## 🔎 Search Inventory")

search_query = st.text_input(
    "Search for ad placements",
    placeholder="e.g., 'premium cardiology waiting room displays in Texas'",
    help="Use natural language to find relevant ad inventory"
)

col1, col2, col3, col4 = st.columns(4)

with col1:
    filter_specialty = st.selectbox(
        "Medical Specialty",
        ["All", "Cardiology", "Endocrinology", "Oncology", "Primary Care", 
         "Neurology", "Pulmonology", "Dermatology", "Orthopedics"]
    )

with col2:
    filter_region = st.selectbox(
        "Region",
        ["All", "Northeast", "Southeast", "Midwest", "Southwest", "West"]
    )

with col3:
    filter_daypart = st.selectbox(
        "Daypart",
        ["All", "Morning", "Afternoon", "Evening", "All Day"]
    )

with col4:
    filter_premium = st.selectbox(
        "Slot Type",
        ["All", "Premium Only", "Standard Only"]
    )

if st.button("🔍 Search", use_container_width=True, type="primary"):
    st.session_state.search_executed = True
    st.session_state.search_query = search_query

st.divider()

# Results Section
if st.session_state.get('search_executed', False):
    
    query_text = st.session_state.get('search_query', '')
    
    st.markdown(f"## 📍 Search Results")
    if query_text:
        st.caption(f"Showing results for: *\"{query_text}\"*")
    
    if IN_SNOWFLAKE and session and query_text:
        # Use Cortex Search
        try:
            # Build filter object
            filter_parts = []
            if filter_specialty != "All":
                filter_parts.append(f'"@eq": {{"specialty": "{filter_specialty}"}}')
            if filter_region != "All":
                filter_parts.append(f'"@eq": {{"region": "{filter_region}"}}')
            if filter_daypart != "All" and filter_daypart != "All Day":
                filter_parts.append(f'"@eq": {{"daypart": "{filter_daypart}"}}')
            
            if filter_parts:
                filter_clause = ', "filter": {' + ', '.join(filter_parts) + '}'
            else:
                filter_clause = ''
            
            search_sql = f"""
            SELECT
                SNOWFLAKE.CORTEX.SEARCH_PREVIEW(
                    'AD_TECH.CORTEX.INVENTORY_SEARCH_SVC',
                    '{{
                        "query": "{query_text}",
                        "columns": ["slot_id", "slot_name", "specialty", "facility_name", 
                                   "city", "state", "region", "screen_type", "daypart", 
                                   "base_cpm", "daily_impressions", "is_premium"],
                        "limit": 20
                        {filter_clause}
                    }}'
                ) as results
            """
            
            results = session.sql(search_sql).collect()
            
            if results:
                import json
                result_data = json.loads(results[0]['RESULTS'])
                
                if 'results' in result_data and result_data['results']:
                    st.success(f"Found {len(result_data['results'])} matching ad placements")
                    
                    for i, slot in enumerate(result_data['results']):
                        with st.expander(
                            f"📍 {slot.get('slot_name', 'Unknown Slot')} | "
                            f"${slot.get('base_cpm', 0):.2f} CPM | "
                            f"{slot.get('specialty', 'N/A')}"
                        ):
                            col1, col2, col3 = st.columns(3)
                            
                            with col1:
                                st.markdown("**Location**")
                                st.write(f"🏥 {slot.get('facility_name', 'N/A')}")
                                st.write(f"📍 {slot.get('city', '')}, {slot.get('state', '')}")
                                st.write(f"🗺️ {slot.get('region', 'N/A')}")
                            
                            with col2:
                                st.markdown("**Specifications**")
                                st.write(f"🖥️ {slot.get('screen_type', 'N/A')}")
                                st.write(f"⏰ {slot.get('daypart', 'N/A')}")
                                st.write(f"⭐ {'Premium' if slot.get('is_premium') else 'Standard'}")
                            
                            with col3:
                                st.markdown("**Metrics**")
                                st.write(f"💰 ${slot.get('base_cpm', 0):.2f} CPM")
                                st.write(f"👀 {slot.get('daily_impressions', 0):,} daily impressions")
                                st.write(f"🩺 {slot.get('specialty', 'N/A')}")
                else:
                    st.info("No matching inventory found. Try adjusting your search terms.")
                    
        except Exception as e:
            st.error(f"Search error: {e}")
            st.info("Showing demo results instead.")
            st.session_state.show_demo = True
    else:
        st.session_state.show_demo = True
    
    # Demo results
    if st.session_state.get('show_demo', not IN_SNOWFLAKE):
        import pandas as pd
        
        demo_slots = [
            {
                "slot_name": "Austin Heart Hospital - Waiting Room TV 55\"",
                "specialty": "Cardiology",
                "facility_name": "Austin Heart Hospital",
                "city": "Austin",
                "state": "TX",
                "region": "Southwest",
                "screen_type": "Waiting Room TV",
                "daypart": "Morning",
                "base_cpm": 18.50,
                "daily_impressions": 245,
                "is_premium": True
            },
            {
                "slot_name": "Houston Medical Center - Digital Display 65\"",
                "specialty": "Cardiology",
                "facility_name": "Houston Regional Medical Center",
                "city": "Houston",
                "state": "TX",
                "region": "Southwest",
                "screen_type": "Digital Display",
                "daypart": "All Day",
                "base_cpm": 22.00,
                "daily_impressions": 320,
                "is_premium": True
            },
            {
                "slot_name": "Dallas Cardiology Clinic - Check-in Kiosk",
                "specialty": "Cardiology",
                "facility_name": "Dallas Cardiology Associates",
                "city": "Dallas",
                "state": "TX",
                "region": "Southwest",
                "screen_type": "Check-in Kiosk",
                "daypart": "Morning",
                "base_cpm": 12.00,
                "daily_impressions": 150,
                "is_premium": False
            },
            {
                "slot_name": "San Antonio Heart Center - Exam Room Display",
                "specialty": "Cardiology",
                "facility_name": "San Antonio Heart Center",
                "city": "San Antonio",
                "state": "TX",
                "region": "Southwest",
                "screen_type": "Exam Room Display",
                "daypart": "Afternoon",
                "base_cpm": 25.00,
                "daily_impressions": 80,
                "is_premium": True
            },
            {
                "slot_name": "Phoenix Cardiology - Waiting Room TV",
                "specialty": "Cardiology",
                "facility_name": "Phoenix Cardiology Group",
                "city": "Phoenix",
                "state": "AZ",
                "region": "Southwest",
                "screen_type": "Waiting Room TV",
                "daypart": "Morning",
                "base_cpm": 16.00,
                "daily_impressions": 200,
                "is_premium": False
            }
        ]
        
        st.success(f"Found {len(demo_slots)} matching ad placements (demo data)")
        
        for i, slot in enumerate(demo_slots):
            with st.expander(
                f"📍 {slot['slot_name']} | "
                f"${slot['base_cpm']:.2f} CPM | "
                f"{slot['specialty']}"
            ):
                col1, col2, col3 = st.columns(3)
                
                with col1:
                    st.markdown("**Location**")
                    st.write(f"🏥 {slot['facility_name']}")
                    st.write(f"📍 {slot['city']}, {slot['state']}")
                    st.write(f"🗺️ {slot['region']}")
                
                with col2:
                    st.markdown("**Specifications**")
                    st.write(f"🖥️ {slot['screen_type']}")
                    st.write(f"⏰ {slot['daypart']}")
                    st.write(f"⭐ {'Premium' if slot['is_premium'] else 'Standard'}")
                
                with col3:
                    st.markdown("**Metrics**")
                    st.write(f"💰 ${slot['base_cpm']:.2f} CPM")
                    st.write(f"👀 {slot['daily_impressions']:,} daily impressions")
                    st.write(f"🩺 {slot['specialty']}")

else:
    # Initial state
    st.info("👆 Enter a search query and click 'Search' to discover available ad inventory.")
    
    st.markdown("### 💡 Example Searches")
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.markdown("""
        **By Specialty:**
        - "Cardiology waiting room displays"
        - "Endocrinology clinics for diabetes campaigns"
        - "Oncology facilities with premium screens"
        
        **By Location:**
        - "Ad slots in Texas"
        - "Northeast region hospitals"
        - "Miami medical centers"
        """)
    
    with col2:
        st.markdown("""
        **By Screen Type:**
        - "Digital displays in waiting rooms"
        - "Exam room tablets"
        - "Check-in kiosk advertising"
        
        **Combined:**
        - "Premium morning slots in cardiology"
        - "High-volume facilities in Southeast"
        - "Affordable inventory for awareness campaigns"
        """)

# Inventory Summary Section
st.divider()
st.markdown("## 📊 Inventory Overview")

col1, col2, col3, col4 = st.columns(4)

col1.metric("Total Active Slots", "5,000+")
col2.metric("Facilities", "500+")
col3.metric("Avg CPM", "$14.50")
col4.metric("Daily Impressions", "750K+")

# Regional Breakdown
st.markdown("### 🗺️ Inventory by Region")

if IN_SNOWFLAKE and session:
    try:
        region_query = """
        SELECT 
            l.region,
            COUNT(DISTINCT i.slot_id) as slots,
            COUNT(DISTINCT l.location_id) as facilities,
            ROUND(AVG(i.base_cpm), 2) as avg_cpm,
            SUM(i.daily_impressions) as daily_impressions
        FROM AD_TECH.ANALYTICS.DIM_INVENTORY i
        JOIN AD_TECH.ANALYTICS.DIM_LOCATIONS l ON i.location_id = l.location_id
        WHERE i.is_active = TRUE
        GROUP BY l.region
        ORDER BY slots DESC
        """
        
        region_df = session.sql(region_query).to_pandas()
        
        col1, col2 = st.columns(2)
        
        with col1:
            st.dataframe(region_df, use_container_width=True, hide_index=True)
        
        with col2:
            st.bar_chart(region_df.set_index('REGION')['SLOTS'])
            
    except Exception as e:
        st.error(f"Error loading regional data: {e}")
else:
    import pandas as pd
    
    region_data = pd.DataFrame({
        "Region": ["Southwest", "Southeast", "West", "Northeast", "Midwest"],
        "Slots": [1200, 1100, 950, 900, 850],
        "Facilities": [120, 110, 95, 90, 85],
        "Avg CPM": [15.20, 14.80, 16.50, 17.20, 13.50],
        "Daily Impressions": [180000, 165000, 142500, 135000, 127500]
    })
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.dataframe(region_data, use_container_width=True, hide_index=True)
    
    with col2:
        st.bar_chart(region_data.set_index("Region")["Slots"])

# Footer
st.divider()
st.markdown("""
<div style="text-align: center; color: #666;">
    <p>Inventory Explorer | PatientPoint Ad Tech Demo</p>
</div>
""", unsafe_allow_html=True)

