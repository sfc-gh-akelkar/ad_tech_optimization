# PatientPoint Predictive Maintenance Demo

AI/ML-based predictive maintenance system for digital screen fleet management.

## 🎯 Project Goal

Build a demo showing how Snowflake's Cortex AI and ML capabilities can:
- Predict device failures before they occur
- Automatically remediate issues remotely
- Provide transparent, assumption-driven business impact estimates (no “fudged” metrics)

## 📋 Progress Tracker

### ✅ Act 1: Foundation & Monitoring

**Status:** Implemented

**What we're building:**
- Database schema for devices, telemetry, maintenance history
- Synthetic data generator (100 devices, 30 days of telemetry)
- Basic Streamlit monitoring dashboard
- One "degrading" device (Device #4532) showing power supply issues

### ✅ Act 2: Anomaly Detection + Watchlist (simulated)
- Anomaly scoring (baseline 14d vs scoring 1d)
- Ranked watchlist + explainable “why flagged”
- Semantic view + Cortex Agent tool

### ✅ Act 3: Failure Prediction (24–48h) + Accuracy Tracking (demo)
- Simulated 24–48h predictions + predicted failure type
- Demo evaluation metrics (explicitly demo-only vs deterministic scenario incidents)

### ✅ Act 4: Remediation Knowledge Base (Cortex Search)
- Knowledge base table + Cortex Search service

### ✅ Act 5: Automated Remote Remediation (simulated)
- Work orders generated from watchlist/predictions
- Remote runbooks + simulated executions + escalation

### ✅ Act 6: Executive KPIs (observed + assumption-driven estimates)
- Executive KPI view powered by real incident history
- Transparent assumptions table for any counterfactual estimates

### ✅ Snowflake Intelligence (Cortex Agent)
- Native semantic views + Cortex Search + Agent orchestration (`auto`)

See `FOCUS_FRAMEWORK.md` for the Challenge → Action → Result mapping.

---

## 🚀 Act 1 Setup Instructions

### Step 1: Run SQL Scripts in Snowsight

**1a. Create Database and Tables**

Open Snowsight SQL worksheet and run:

```bash
sql/01_setup_database.sql
```

This creates:
- `PREDICTIVE_MAINTENANCE` database
- Schemas: `RAW_DATA`, `ANALYTICS`, `OPERATIONS`
- Tables: `DEVICE_INVENTORY`, `SCREEN_TELEMETRY`, `MAINTENANCE_HISTORY`
- Reference data for device models
- Useful views

**Expected result:** ✅ Message saying "Act 1 Database Setup Complete!"

**1b. Generate Synthetic Data**

In the same or new SQL worksheet, run:

```bash
sql/02_generate_sample_data.sql
```

This generates:
- 100 devices across US locations
- ~864,000 telemetry records (30 days × 5-min intervals × 100 devices)
- 150 historical maintenance records
- Device #4532 with degrading power supply pattern

**Expected result:** 
- ✅ "Act 1 Data Generation Complete!"
- Verification queries showing device counts and Device 4532 status

**Time:** This takes 30-60 seconds to generate all data.

---

### Step 2: Create Streamlit App

**2a. Create New Streamlit App in Snowsight**

1. In Snowsight, go to **Projects > Streamlit**
2. Click **+ Streamlit App**
3. Name it: `PatientPoint Fleet Monitoring`
4. Select database: `PREDICTIVE_MAINTENANCE`
5. Select warehouse: (any warehouse, e.g., `COMPUTE_WH`)

**2b. Paste Code**

1. Delete the default template code
2. Copy all contents from: `streamlit/01_Fleet_Monitoring.py`
3. Paste into the Streamlit editor
4. Click **Run**

**Expected result:** Dashboard loads showing:
- Fleet overview with health metrics
- Device priority queue
- Device #4532 available in the deep dive selector

---

### Step 3: Validate Act 1

Use the dashboard to verify:

**✅ Fleet Overview:**
- Total devices: 100
- Most devices should be "Healthy" (green)
- 2-10 devices should show "Warning" or "Critical"

**✅ Device #4532 Deep Dive:**
1. Select Device #4532 from dropdown
2. Go to "🌡️ Temperature" tab
3. **You should see:** Temperature climbing from ~65°F to ~82°F+ over the last 7 days
4. Go to "⚡ Power" tab
5. **You should see:** Power consumption climbing from ~100W to ~215W+ with spikes
6. Go to "⚠️ Errors" tab
7. **You should see:** Error count increasing over the last week

**✅ Comparison:**
1. Select a different device (e.g., 4501)
2. **You should see:** Normal, stable metrics with small random variation

---

## 📊 What Data Looks Like

### Device #4532 (Problem Device)
- **Pattern:** Power supply degradation
- **Symptoms:** 
  - Temperature: 65°F → 82°F (climbing)
  - Power: 100W → 215W with spikes
  - Errors: 0-2/hour → 12-15/hour
- **Timeline:** Normal for 23 days, degrading over last 7 days
- **Expected failure:** Would fail in next 1-2 days without intervention

### Device #7821 (Secondary Problem)
- **Pattern:** Display panel issue
- **Symptoms:** Normal temperature/power, but different failure mode
- **Use for:** Showing different failure types in later acts

### Other Devices
- **90 devices:** Normal operation with noise
- **8 devices:** Minor anomalies (slightly elevated metrics)

---

## 🎬 Demo Script for Act 1

**For stakeholders:**

> "This is the PatientPoint digital screen fleet - 100 devices across 15 cities. Right now, most devices show healthy status (green), but we have a few requiring attention.
> 
> Let me show you Device #4532 in Chicago. [Click on device]
> 
> Look at the temperature chart - for the first 23 days, it's stable around 65°F. But starting about a week ago, it begins climbing. Today it's at 82°F.
> 
> Now look at power consumption - same pattern. Stable at 100 watts, but now spiking to 215 watts with irregular peaks.
> 
> This is a classic power supply degradation pattern. Without predictive maintenance, an operator would need to manually check all 100 devices daily to spot this. And by the time they notice, the device might have already failed during business hours - that's lost ad revenue and an emergency field tech dispatch.
> 
> In Act 2, we'll add machine learning to automatically detect these patterns and alert operators before failures occur."

---

## 🛠️ Troubleshooting

### Issue: "Object does not exist" errors

**Solution:** Make sure you ran both SQL scripts in order:
1. `01_setup_database.sql` first
2. `02_generate_sample_data.sql` second

### Issue: Streamlit shows "No data"

**Solution:** Check your database context:
```sql
USE DATABASE PREDICTIVE_MAINTENANCE;
USE SCHEMA RAW_DATA;
SELECT COUNT(*) FROM DEVICE_INVENTORY;  -- Should return 100
SELECT COUNT(*) FROM SCREEN_TELEMETRY;  -- Should return ~864,000
```

### Issue: Device #4532 doesn't show degradation

**Solution:** Verify the data generation worked:
```sql
SELECT 
    DEVICE_ID,
    TIMESTAMP,
    TEMPERATURE_F,
    POWER_CONSUMPTION_W
FROM SCREEN_TELEMETRY
WHERE DEVICE_ID = '4532'
ORDER BY TIMESTAMP DESC
LIMIT 50;
```

Temperature and power should be elevated in recent records.

### Issue: Charts load slowly

**Solution:** 
- Use a larger warehouse (M or L) for better query performance
- The CLUSTER BY on SCREEN_TELEMETRY should help with time-series queries

---

## 📁 File Structure

```
/
├── sql/
│   ├── 01_setup_database.sql       # Database schema
│   └── 02_generate_sample_data.sql # Synthetic data generation
│
├── streamlit/
│   └── 01_Fleet_Monitoring.py      # Act 1 dashboard
│
└── README.md                        # This file
```

---

## 🎓 Key Concepts Demonstrated

### Act 1 Teaches:

1. **Time-series data modeling** in Snowflake
2. **Clustering** for performance on large tables
3. **Views** for reusable business logic
4. **Synthetic data generation** with realistic patterns
5. **Streamlit** in Snowflake for interactive dashboards
6. **Altair charts** for telemetry visualization

### Not Yet Implemented (Coming in Later Acts):

- ❌ Anomaly detection (Act 2)
- ❌ Predictive models (Act 3)
- ❌ Cortex Search (Act 4)
- ❌ Automated remediation (Act 5)
- ❌ ROI calculations (Act 6)
- ❌ Natural language queries (Act 7)

---

## ✅ Act 1 Validation Checklist

Before moving to Act 2, confirm:

- [ ] Database `PREDICTIVE_MAINTENANCE` exists
- [ ] Tables have data:
  - [ ] `DEVICE_INVENTORY`: 100 rows
  - [ ] `SCREEN_TELEMETRY`: ~864,000 rows
  - [ ] `MAINTENANCE_HISTORY`: 150 rows
- [ ] Streamlit dashboard loads without errors
- [ ] Fleet overview shows correct metrics
- [ ] Device #4532 shows degradation pattern in charts
- [ ] Can select different devices and see their telemetry
- [ ] All 4 tabs (Temperature, Power, Errors, System) work

---

## 🚦 Ready for Act 2?

Once Act 1 is validated, let me know and I'll build:

**Act 2: Anomaly Detection**
- Cortex ML anomaly detection on telemetry
- Automatic flagging of devices with unusual patterns
- Watch list dashboard
- Comparison: Manual threshold rules vs. ML detection

**What you'll be able to demo:**
> "Instead of setting manual threshold rules, we use Cortex ML to learn each device's normal behavior. Device #4532 is automatically flagged because its pattern deviates 26% from its baseline - even before it crosses critical thresholds."

---

## 📞 Questions?

This is Act 1 of 8. Each act builds on the previous one, and you can validate at every step.

Ready to begin? Run the SQL scripts and create the Streamlit app!

