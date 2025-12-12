"""
ACT 1: FLEET MONITORING DASHBOARD

Purpose: Basic monitoring interface for PatientPoint device fleet
Shows device health status and allows drilling into individual devices

Run this in Snowflake Streamlit:
1. Create new Streamlit app in Snowsight
2. Paste this code
3. Run the app

This is Act 1 - just monitoring, no ML predictions yet
"""

import streamlit as st
from snowflake.snowpark.context import get_active_session
import pandas as pd
import altair as alt

# Page configuration
st.set_page_config(
    page_title="PatientPoint Fleet Monitoring",
    page_icon="📺",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Get Snowflake session
session = get_active_session()

# Note: Streamlit in Snowflake is already connected to the database
# specified when creating the app. Use fully qualified table names.

#============================================================================
# HEADER
#============================================================================

st.title("📺 PatientPoint Fleet Monitoring")
st.markdown("**Act 1:** Real-time monitoring of digital screen fleet")

#============================================================================
# SIDEBAR - Filters
#============================================================================

st.sidebar.header("🔍 Filters")

# Get filter options
states = session.sql("""
    SELECT DISTINCT FACILITY_STATE 
    FROM PREDICTIVE_MAINTENANCE.RAW_DATA.DEVICE_INVENTORY 
    WHERE OPERATIONAL_STATUS = 'Active'
    ORDER BY FACILITY_STATE
""").to_pandas()

device_models = session.sql("""
    SELECT DISTINCT DEVICE_MODEL 
    FROM PREDICTIVE_MAINTENANCE.RAW_DATA.DEVICE_INVENTORY 
    WHERE OPERATIONAL_STATUS = 'Active'
    ORDER BY DEVICE_MODEL
""").to_pandas()

# State filter
selected_states = st.sidebar.multiselect(
    "State",
    options=states['FACILITY_STATE'].tolist(),
    default=[]
)

# Device model filter
selected_models = st.sidebar.multiselect(
    "Device Model",
    options=device_models['DEVICE_MODEL'].tolist(),
    default=[]
)

# Health status filter
health_filter = st.sidebar.multiselect(
    "Health Status",
    options=["HEALTHY", "WARNING", "CRITICAL"],
    default=["HEALTHY", "WARNING", "CRITICAL"]
)

#============================================================================
# MAIN DASHBOARD - Fleet Overview
#============================================================================

st.header("Fleet Overview")

# Build WHERE clause for filters
where_clauses = []
if selected_states:
    states_list = "', '".join(selected_states)
    where_clauses.append(f"FACILITY_STATE IN ('{states_list}')")
if selected_models:
    models_list = "', '".join(selected_models)
    where_clauses.append(f"DEVICE_MODEL IN ('{models_list}')")

where_sql = " AND " + " AND ".join(where_clauses) if where_clauses else ""

# Get fleet summary statistics
fleet_summary_query = f"""
    SELECT 
        COUNT(*) AS TOTAL_DEVICES,
        COUNT(CASE 
            WHEN TEMP_STATUS = 'CRITICAL' OR POWER_STATUS = 'CRITICAL' 
            THEN 1 END) AS CRITICAL_DEVICES,
        COUNT(CASE 
            WHEN (TEMP_STATUS = 'WARNING' OR POWER_STATUS = 'WARNING')
            AND (TEMP_STATUS != 'CRITICAL' AND POWER_STATUS != 'CRITICAL')
            THEN 1 END) AS WARNING_DEVICES,
        COUNT(CASE 
            WHEN TEMP_STATUS = 'NORMAL' AND POWER_STATUS = 'NORMAL' 
            THEN 1 END) AS HEALTHY_DEVICES,
        AVG(TEMPERATURE_F) AS AVG_TEMP,
        AVG(POWER_CONSUMPTION_W) AS AVG_POWER,
        SUM(ERROR_COUNT) AS TOTAL_ERRORS
    FROM PREDICTIVE_MAINTENANCE.RAW_DATA.V_DEVICE_HEALTH_SUMMARY
    WHERE 1=1 {where_sql}
"""

fleet_summary = session.sql(fleet_summary_query).to_pandas().iloc[0]

# Display metrics in columns
col1, col2, col3, col4 = st.columns(4)

with col1:
    st.metric(
        label="🟢 Healthy Devices",
        value=int(fleet_summary['HEALTHY_DEVICES']),
        delta=f"{(fleet_summary['HEALTHY_DEVICES'] / fleet_summary['TOTAL_DEVICES'] * 100):.1f}%"
    )

with col2:
    st.metric(
        label="🟡 Warning Devices",
        value=int(fleet_summary['WARNING_DEVICES']),
        delta=f"{(fleet_summary['WARNING_DEVICES'] / fleet_summary['TOTAL_DEVICES'] * 100):.1f}%",
        delta_color="inverse"
    )

with col3:
    st.metric(
        label="🔴 Critical Devices",
        value=int(fleet_summary['CRITICAL_DEVICES']),
        delta=f"{(fleet_summary['CRITICAL_DEVICES'] / fleet_summary['TOTAL_DEVICES'] * 100):.1f}%",
        delta_color="inverse"
    )

with col4:
    st.metric(
        label="📊 Total Fleet Size",
        value=int(fleet_summary['TOTAL_DEVICES'])
    )

st.divider()

# Additional metrics
col5, col6, col7 = st.columns(3)

with col5:
    st.metric(
        label="🌡️ Fleet Avg Temperature",
        value=f"{fleet_summary['AVG_TEMP']:.1f}°F"
    )

with col6:
    st.metric(
        label="⚡ Fleet Avg Power",
        value=f"{fleet_summary['AVG_POWER']:.1f}W"
    )

with col7:
    st.metric(
        label="⚠️ Total Active Errors",
        value=int(fleet_summary['TOTAL_ERRORS'])
    )

#============================================================================
# DEVICE LIST - Priority Queue
#============================================================================

st.header("Device Priority Queue")
st.markdown("Devices requiring attention (Critical and Warning status)")

# Get device list with health status
device_list_query = f"""
    SELECT 
        DEVICE_ID,
        DEVICE_MODEL,
        FACILITY_NAME,
        FACILITY_CITY,
        FACILITY_STATE,
        ENVIRONMENT_TYPE,
        TEMPERATURE_F,
        POWER_CONSUMPTION_W,
        ERROR_COUNT,
        TEMP_STATUS,
        POWER_STATUS,
        CASE 
            WHEN TEMP_STATUS = 'CRITICAL' OR POWER_STATUS = 'CRITICAL' THEN 'CRITICAL'
            WHEN TEMP_STATUS = 'WARNING' OR POWER_STATUS = 'WARNING' THEN 'WARNING'
            ELSE 'HEALTHY'
        END AS OVERALL_STATUS,
        LAST_REPORT_TIME,
        DEVICE_AGE_DAYS,
        DAYS_SINCE_MAINTENANCE
    FROM PREDICTIVE_MAINTENANCE.RAW_DATA.V_DEVICE_HEALTH_SUMMARY
    WHERE 1=1 {where_sql}
    ORDER BY 
        CASE 
            WHEN TEMP_STATUS = 'CRITICAL' OR POWER_STATUS = 'CRITICAL' THEN 1
            WHEN TEMP_STATUS = 'WARNING' OR POWER_STATUS = 'WARNING' THEN 2
            ELSE 3
        END,
        ERROR_COUNT DESC,
        TEMPERATURE_F DESC
"""

device_list = session.sql(device_list_query).to_pandas()

# Filter by health status selection
if health_filter:
    device_list = device_list[device_list['OVERALL_STATUS'].isin(health_filter)]

# Display count
st.markdown(f"**Showing {len(device_list)} devices**")

# Add status indicator column
def get_status_emoji(status):
    if status == 'CRITICAL':
        return '🔴'
    elif status == 'WARNING':
        return '🟡'
    else:
        return '🟢'

device_list['STATUS'] = device_list['OVERALL_STATUS'].apply(get_status_emoji) + ' ' + device_list['OVERALL_STATUS']

# Format the dataframe for display
display_df = device_list[[
    'STATUS', 'DEVICE_ID', 'DEVICE_MODEL', 'FACILITY_NAME', 
    'FACILITY_CITY', 'FACILITY_STATE', 'TEMPERATURE_F', 
    'POWER_CONSUMPTION_W', 'ERROR_COUNT'
]].copy()

display_df.columns = [
    'Status', 'Device ID', 'Model', 'Facility', 
    'City', 'State', 'Temp (°F)', 'Power (W)', 'Errors'
]

# Format numeric columns
display_df['Temp (°F)'] = display_df['Temp (°F)'].round(1)
display_df['Power (W)'] = display_df['Power (W)'].round(1)

# Display table with row selection
st.dataframe(
    display_df,
    use_container_width=True,
    hide_index=True,
    height=400
)

#============================================================================
# DEVICE DETAIL VIEW
#============================================================================

st.header("Device Deep Dive")

# Device selector
# Convert DEVICE_ID to string for Streamlit compatibility
device_id_options = device_list['DEVICE_ID'].astype(str).tolist()

# Try to default to device 4532 if it exists
default_index = 0
try:
    if '4532' in device_id_options:
        default_index = device_id_options.index('4532')
except:
    default_index = 0

selected_device_id = st.selectbox(
    "Select Device to Inspect",
    options=device_id_options,
    index=default_index
)

if selected_device_id:
    # Get device details
    device_info_query = f"""
        SELECT 
            d.*,
            s.TEMP_STATUS,
            s.POWER_STATUS,
            s.TEMPERATURE_F,
            s.POWER_CONSUMPTION_W,
            s.ERROR_COUNT,
            s.DEVICE_AGE_DAYS,
            s.DAYS_SINCE_MAINTENANCE
        FROM PREDICTIVE_MAINTENANCE.RAW_DATA.DEVICE_INVENTORY d
        LEFT JOIN V_DEVICE_HEALTH_SUMMARY s ON d.DEVICE_ID = s.DEVICE_ID
        WHERE d.DEVICE_ID = '{selected_device_id}'
    """
    
    device_info = session.sql(device_info_query).to_pandas().iloc[0]
    
    # Display device info
    col1, col2, col3 = st.columns(3)
    
    with col1:
        st.subheader("📍 Device Information")
        st.write(f"**Device ID:** {device_info['DEVICE_ID']}")
        st.write(f"**Model:** {device_info['DEVICE_MODEL']}")
        st.write(f"**Manufacturer:** {device_info['MANUFACTURER']}")
        st.write(f"**Firmware:** {device_info['FIRMWARE_VERSION']}")
        st.write(f"**Warranty:** {device_info['WARRANTY_STATUS']}")
    
    with col2:
        st.subheader("🏥 Location")
        st.write(f"**Facility:** {device_info['FACILITY_NAME']}")
        st.write(f"**City:** {device_info['FACILITY_CITY']}, {device_info['FACILITY_STATE']}")
        st.write(f"**Environment:** {device_info['ENVIRONMENT_TYPE']}")
        st.write(f"**Install Date:** {device_info['INSTALLATION_DATE']}")
        st.write(f"**Age:** {int(device_info['DEVICE_AGE_DAYS'])} days")
    
    with col3:
        st.subheader("🔧 Maintenance")
        st.write(f"**Last Service:** {device_info['LAST_MAINTENANCE_DATE']}")
        st.write(f"**Days Since:** {int(device_info['DAYS_SINCE_MAINTENANCE'])}")
        st.write(f"**Status:** {device_info['OPERATIONAL_STATUS']}")
        
        # Health indicators
        temp_emoji = '🔴' if device_info['TEMP_STATUS'] == 'CRITICAL' else '🟡' if device_info['TEMP_STATUS'] == 'WARNING' else '🟢'
        power_emoji = '🔴' if device_info['POWER_STATUS'] == 'CRITICAL' else '🟡' if device_info['POWER_STATUS'] == 'WARNING' else '🟢'
        
        st.write(f"**Temp Status:** {temp_emoji} {device_info['TEMP_STATUS']}")
        st.write(f"**Power Status:** {power_emoji} {device_info['POWER_STATUS']}")
    
    st.divider()
    
    # Get telemetry history for this device
    telemetry_query = f"""
        SELECT 
            TIMESTAMP,
            TEMPERATURE_F,
            POWER_CONSUMPTION_W,
            ERROR_COUNT,
            CPU_USAGE_PCT,
            NETWORK_LATENCY_MS
        FROM PREDICTIVE_MAINTENANCE.RAW_DATA.SCREEN_TELEMETRY
        WHERE DEVICE_ID = '{selected_device_id}'
        ORDER BY TIMESTAMP DESC
        LIMIT 8640  -- Last 30 days at 5-min intervals
    """
    
    telemetry_df = session.sql(telemetry_query).to_pandas()
    telemetry_df['TIMESTAMP'] = pd.to_datetime(telemetry_df['TIMESTAMP'])
    
    st.subheader("📈 Telemetry History (Last 30 Days)")
    
    # Create tabs for different metrics
    tab1, tab2, tab3, tab4 = st.tabs(["🌡️ Temperature", "⚡ Power", "⚠️ Errors", "💻 System"])
    
    with tab1:
        # Temperature chart
        temp_chart = alt.Chart(telemetry_df).mark_line(color='#FF6B6B').encode(
            x=alt.X('TIMESTAMP:T', title='Date'),
            y=alt.Y('TEMPERATURE_F:Q', title='Temperature (°F)', scale=alt.Scale(zero=False)),
            tooltip=['TIMESTAMP:T', alt.Tooltip('TEMPERATURE_F:Q', format='.1f')]
        ).properties(
            height=300,
            title='Device Temperature Over Time'
        ).interactive()
        
        # Add threshold lines
        model_info = session.sql(f"""
            SELECT TEMP_WARNING_THRESHOLD_F, TEMP_CRITICAL_THRESHOLD_F
            FROM PREDICTIVE_MAINTENANCE.RAW_DATA.DEVICE_MODELS_REFERENCE
            WHERE MODEL_NAME = '{device_info['DEVICE_MODEL']}'
        """).to_pandas().iloc[0]
        
        warning_line = alt.Chart(pd.DataFrame({'y': [model_info['TEMP_WARNING_THRESHOLD_F']]})).mark_rule(
            color='orange', strokeDash=[5, 5]
        ).encode(y='y:Q')
        
        critical_line = alt.Chart(pd.DataFrame({'y': [model_info['TEMP_CRITICAL_THRESHOLD_F']]})).mark_rule(
            color='red', strokeDash=[5, 5]
        ).encode(y='y:Q')
        
        st.altair_chart(temp_chart + warning_line + critical_line, use_container_width=True)
        
        # Statistics
        col1, col2, col3, col4 = st.columns(4)
        with col1:
            st.metric("Current", f"{telemetry_df.iloc[0]['TEMPERATURE_F']:.1f}°F")
        with col2:
            st.metric("Average", f"{telemetry_df['TEMPERATURE_F'].mean():.1f}°F")
        with col3:
            st.metric("Max", f"{telemetry_df['TEMPERATURE_F'].max():.1f}°F")
        with col4:
            st.metric("Min", f"{telemetry_df['TEMPERATURE_F'].min():.1f}°F")
    
    with tab2:
        # Power chart
        power_chart = alt.Chart(telemetry_df).mark_line(color='#4ECDC4').encode(
            x=alt.X('TIMESTAMP:T', title='Date'),
            y=alt.Y('POWER_CONSUMPTION_W:Q', title='Power (W)', scale=alt.Scale(zero=False)),
            tooltip=['TIMESTAMP:T', alt.Tooltip('POWER_CONSUMPTION_W:Q', format='.1f')]
        ).properties(
            height=300,
            title='Power Consumption Over Time'
        ).interactive()
        
        # Add threshold lines
        warning_power = alt.Chart(pd.DataFrame({'y': [model_info['POWER_WARNING_THRESHOLD_W']]})).mark_rule(
            color='orange', strokeDash=[5, 5]
        ).encode(y='y:Q')
        
        critical_power = alt.Chart(pd.DataFrame({'y': [model_info['POWER_CRITICAL_THRESHOLD_W']]})).mark_rule(
            color='red', strokeDash=[5, 5]
        ).encode(y='y:Q')
        
        st.altair_chart(power_chart + warning_power + critical_power, use_container_width=True)
        
        col1, col2, col3, col4 = st.columns(4)
        with col1:
            st.metric("Current", f"{telemetry_df.iloc[0]['POWER_CONSUMPTION_W']:.1f}W")
        with col2:
            st.metric("Average", f"{telemetry_df['POWER_CONSUMPTION_W'].mean():.1f}W")
        with col3:
            st.metric("Max", f"{telemetry_df['POWER_CONSUMPTION_W'].max():.1f}W")
        with col4:
            st.metric("Min", f"{telemetry_df['POWER_CONSUMPTION_W'].min():.1f}W")
    
    with tab3:
        # Error count chart
        error_chart = alt.Chart(telemetry_df).mark_bar(color='#FF6B6B').encode(
            x=alt.X('TIMESTAMP:T', title='Date'),
            y=alt.Y('ERROR_COUNT:Q', title='Errors per Hour'),
            tooltip=['TIMESTAMP:T', 'ERROR_COUNT:Q']
        ).properties(
            height=300,
            title='Error Count Over Time'
        ).interactive()
        
        st.altair_chart(error_chart, use_container_width=True)
        
        col1, col2, col3 = st.columns(3)
        with col1:
            st.metric("Current", int(telemetry_df.iloc[0]['ERROR_COUNT']))
        with col2:
            st.metric("Total (30d)", int(telemetry_df['ERROR_COUNT'].sum()))
        with col3:
            st.metric("Average", f"{telemetry_df['ERROR_COUNT'].mean():.1f}")
    
    with tab4:
        # CPU and Network charts
        col1, col2 = st.columns(2)
        
        with col1:
            cpu_chart = alt.Chart(telemetry_df).mark_line(color='#95E1D3').encode(
                x=alt.X('TIMESTAMP:T', title='Date'),
                y=alt.Y('CPU_USAGE_PCT:Q', title='CPU Usage (%)', scale=alt.Scale(domain=[0, 100])),
                tooltip=['TIMESTAMP:T', alt.Tooltip('CPU_USAGE_PCT:Q', format='.1f')]
            ).properties(
                height=250,
                title='CPU Usage'
            ).interactive()
            
            st.altair_chart(cpu_chart, use_container_width=True)
        
        with col2:
            network_chart = alt.Chart(telemetry_df).mark_line(color='#F38181').encode(
                x=alt.X('TIMESTAMP:T', title='Date'),
                y=alt.Y('NETWORK_LATENCY_MS:Q', title='Latency (ms)', scale=alt.Scale(zero=False)),
                tooltip=['TIMESTAMP:T', alt.Tooltip('NETWORK_LATENCY_MS:Q', format='.1f')]
            ).properties(
                height=250,
                title='Network Latency'
            ).interactive()
            
            st.altair_chart(network_chart, use_container_width=True)

#============================================================================
# FOOTER
#============================================================================

st.divider()
st.markdown("""
**Act 1 Status:** ✅ Basic monitoring operational  
**Next Act:** Add anomaly detection to automatically flag devices with unusual patterns  

*This dashboard shows real-time device health. In Act 2, we'll add machine learning 
to automatically detect anomalies instead of relying on threshold rules.*
""")

