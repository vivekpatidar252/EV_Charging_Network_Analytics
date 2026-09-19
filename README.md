# EV Charging Network Analytics

## 📊 Advanced SQL Business Analytics Project

An end-to-end SQL case study analyzing an EV charging network across customers, vehicles, charging stations, chargers, sessions, payments, subscriptions, maintenance and energy usage.

The project focuses on turning operational data into business insights around:

- Charging demand
- Revenue performance
- Customer behavior
- Station performance
- Peak-hour demand
- Customer retention
- Operational efficiency
- Capacity and expansion opportunities

---

## 🎯 Business Problem

An EV charging company operates a network of charging stations across multiple Indian cities.

Management wants to understand:

1. How is charging demand changing over time?
2. Which cities and stations generate the most business?
3. When is charging demand highest?
4. Which customer segments drive usage and revenue?
5. How does customer activity change over time?
6. Which stations are operationally strong or weak?
7. Where should additional charging capacity be considered?

---

## 🗂️ Project Structure

```text
EV_CHARGING_ANALYTICS/
│
├── Analysis/
├── Data/
│   └── Raw/
├── Data_generator/
├── Database/
├── Documentation/
└── Reports/
```

---

## 🛠️ Tech Stack

- **MySQL 8.0**
- **SQL**
- CTEs
- Window Functions
- `LAG()`
- `RANK()`
- `NTILE()`
- Running totals
- Moving averages
- Cohort analysis
- Retention analysis
- Customer segmentation
- Performance scoring
- Power BI — basic KPI overview

---

## 📦 Dataset

The project contains approximately **1.54M+ records** across 10 tables.

| Table | Rows |
|---|---:|
| locations | 12 |
| stations | 186 |
| chargers | 1,019 |
| customers | 20,000 |
| vehicles | 20,991 |
| subscriptions | 10,000 |
| charging_sessions | 500,000 |
| payments | 500,000 |
| energy_consumption | 500,000 |
| maintenance | 1,252 |

Analysis period: **January 2023 – December 2025**

---

## 🧩 Database Schema

```text
locations
    │
    └── stations
            │
            └── chargers
                    │
                    ├── charging_sessions
                    │       ├── payments
                    │       └── energy_consumption
                    │
                    └── maintenance

customers
    ├── vehicles
    ├── subscriptions
    └── charging_sessions
```

---

## 🔎 SQL Analysis

The analysis is organized into:

### 1. Data Quality
- Duplicate checks
- NULL checks
- Foreign-key integrity
- Payment completeness
- Energy completeness
- Amount consistency

### 2. Core KPIs
- Total sessions
- Successful sessions
- Success rate
- Total revenue
- Total energy
- Active customers
- Average revenue/session
- Average energy/session
- Average session duration
- Revenue/kWh

### 3. Advanced Analytics
- Monthly demand
- Monthly revenue
- Monthly energy
- Monthly active customers
- Month-over-month growth
- City performance
- Station performance
- Peak-hour analysis
- Payment-method analysis
- Station revenue ranking
- Running revenue
- Three-month moving average
- Customer activity quartiles
- Session-to-session behavior using `LAG()`
- Station performance score
- Expansion analysis
- Cohort analysis
- Retention analysis
- Customer behavioral segmentation

---

## 📈 Key Findings

### Network demand is stable

| Year | Sessions |
|---|---:|
| 2023 | 166,895 |
| 2024 | 166,805 |
| 2025 | 166,300 |

Charging volume is broadly flat across the three years.

### Revenue is also broadly flat

| Year | Revenue |
|---|---:|
| 2023 | ~₹8.67 Cr |
| 2024 | ~₹8.64 Cr |
| 2025 | ~₹8.61 Cr |

### Peak demand

The strongest hourly demand occurs around morning and evening periods.

Examples:

- 19:00 → 46,237 sessions
- 08:00 → 46,152
- 20:00 → 46,094
- 10:00 → 45,975

### Customer mix

Individual customers dominate network activity.

| Segment | Customers | Sessions |
|---|---:|---:|
| Individual | 15,936 | 398,289 |
| Corporate | 2,390 | 59,849 |
| Fleet | 1,674 | 41,862 |

### Station performance

Performance varies significantly between stations.

The highest project performance score was recorded by:

**Surat EV Hub 180 — 97.18**

The scoring framework uses:

- 40% sessions
- 40% revenue
- 20% success rate

### Expansion analysis

The strict rule:

> Top 25% demand + Bottom 25% charger capacity

returned **0 stations**.

This means the dataset does not identify an obvious station that satisfies both conditions simultaneously.

---

## 💡 Business Insights

### 1. Stable demand, limited growth
The network has established a consistent demand base, but there is no strong year-over-year volume growth.

### 2. Station-level variation matters
Network-wide averages hide large differences between individual stations.

### 3. Peak-hour operations are important
Morning and evening demand concentration makes charger availability and maintenance timing important operational considerations.

### 4. Individual customers drive the majority of usage
Individual customers account for roughly 80% of sessions.

### 5. Occasional customers represent an engagement opportunity
The behavioral segmentation identifies a substantial Occasional segment compared with the very small High Value segment.

### 6. Expansion should be targeted
The strict demand-vs-capacity test did not identify a direct expansion candidate, so capacity decisions should incorporate multiple operational metrics.

---

## 📁 Main Deliverables

- `EV_Charging_Analytics_Professional_SQL.sql`
- `EV_Charging_Analytics_Insights_Report.pdf`
- Raw CSV datasets
- Power BI KPI overview

---

## ⚠️ Limitations

This is a **synthetic portfolio dataset**.

Some analytical thresholds, including behavioral segmentation and station scoring, are project-defined rules.

The uploaded analysis set used for the final insights did not include `energy_consumption.csv`; therefore energy-related analysis may use the `energy_kwh` field from `charging_sessions` where appropriate.

The findings should not be interpreted as real-world measurements of the Indian EV charging market.

---

## 🚀 Future Improvements

- Build a dedicated advanced Power BI dashboard
- Add dynamic pricing analysis
- Add charger utilization by station
- Build failure-rate analysis
- Improve cohort visualization
- Add geographic mapping
- Develop predictive demand forecasting
- Build a station expansion recommendation model

---

## 👨‍💻 Project Focus

**Data Analytics | SQL | Business Intelligence | EV Infrastructure**

This project demonstrates how SQL can be used not only for querying data, but also for:

**Data → Analysis → Insight → Business Decision**
