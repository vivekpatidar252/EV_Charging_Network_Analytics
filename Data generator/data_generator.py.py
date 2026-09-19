import pandas as pd
import numpy as np
import random
from datetime import datetime, timedelta

# ============================================================
# CONFIGURATION
# ============================================================

random.seed(42)
np.random.seed(42)

OUTPUT = "../Data/Raw/"

START_DATE = datetime(2023, 1, 1)
END_DATE = datetime(2025, 12, 31)

# ============================================================
# 1. LOCATIONS
# ============================================================

locations_data = [
    [1, "Delhi", "Delhi", 28.6139, 77.2090, "Office District", 11320],
    [2, "Mumbai", "Maharashtra", 19.0760, 72.8777, "Shopping Mall", 21000],
    [3, "Bengaluru", "Karnataka", 12.9716, 77.5946, "Office District", 11000],
    [4, "Hyderabad", "Telangana", 17.3850, 78.4867, "Residential", 18500],
    [5, "Pune", "Maharashtra", 18.5204, 73.8567, "Office District", 16000],
    [6, "Chennai", "Tamil Nadu", 13.0827, 80.2707, "Shopping Mall", 17000],
    [7, "Kolkata", "West Bengal", 22.5726, 88.3639, "Residential", 24000],
    [8, "Ahmedabad", "Gujarat", 23.0225, 72.5714, "Highway", 12000],
    [9, "Jaipur", "Rajasthan", 26.9124, 75.7873, "Highway", 9000],
    [10, "Indore", "Madhya Pradesh", 22.7196, 75.8577, "Public Parking", 8500],
    [11, "Bhopal", "Madhya Pradesh", 23.2599, 77.4126, "Residential", 7000],
    [12, "Surat", "Gujarat", 21.1702, 72.8311, "Shopping Mall", 13500]
]

locations_df = pd.DataFrame(
    locations_data,
    columns=[
        "location_id",
        "city",
        "state",
        "latitude",
        "longitude",
        "location_type",
        "population_density"
    ]
)

locations_df.to_csv(OUTPUT + "locations.csv", index=False)

# ============================================================
# 2. STATIONS
# ============================================================

stations = []
station_id = 1

for _, location in locations_df.iterrows():

    density = location["population_density"]

    if density >= 18000:
        count = random.randint(18, 25)
    elif density >= 12000:
        count = random.randint(14, 18)
    else:
        count = random.randint(8, 13)

    for _ in range(count):

        opened_date = START_DATE - timedelta(
            days=random.randint(0, 730)
        )

        status = random.choices(
            ["Active", "Inactive"],
            weights=[96, 4]
        )[0]

        stations.append([
            station_id,
            location["location_id"],
            f"{location['city']} EV Hub {station_id}",
            opened_date.date(),
            status,
            random.randint(8, 30)
        ])

        station_id += 1

stations_df = pd.DataFrame(
    stations,
    columns=[
        "station_id",
        "location_id",
        "station_name",
        "opened_date",
        "status",
        "parking_slots"
    ]
)

stations_df.to_csv(OUTPUT + "stations.csv", index=False)

# ============================================================
# 3. CHARGERS
# ============================================================

chargers = []
charger_id = 1

charger_specs = {
    "AC": [(7, 22), ["Type 2"]],
    "DC Fast": [(30, 120), ["CCS", "CHAdeMO"]],
    "DC Ultra-Fast": [(150, 350), ["CCS"]]
}

for _, station in stations_df.iterrows():

    num_chargers = random.randint(3, 8)

    for _ in range(num_chargers):

        charger_type = random.choices(
            ["AC", "DC Fast", "DC Ultra-Fast"],
            weights=[35, 50, 15]
        )[0]

        power_range, connectors = charger_specs[charger_type]

        power_kw = round(
            random.uniform(power_range[0], power_range[1]),
            2
        )

        connector = random.choice(connectors)

        installation_date = pd.to_datetime(
            station["opened_date"]
        ) + timedelta(days=random.randint(0, 180))

        status = random.choices(
            ["Active", "Offline", "Maintenance"],
            weights=[92, 5, 3]
        )[0]

        chargers.append([
            charger_id,
            station["station_id"],
            charger_type,
            power_kw,
            connector,
            installation_date.date(),
            status
        ])

        charger_id += 1

chargers_df = pd.DataFrame(
    chargers,
    columns=[
        "charger_id",
        "station_id",
        "charger_type",
        "power_kw",
        "connector_type",
        "installation_date",
        "status"
    ]
)

chargers_df.to_csv(OUTPUT + "chargers.csv", index=False)

# ============================================================
# 4. CUSTOMERS
# ============================================================

customer_count = 20000

acquisition_channels = [
    "Organic",
    "Referral",
    "Digital Ads",
    "EV Dealership",
    "Corporate Partnership"
]

segments = ["Individual", "Corporate", "Fleet"]

cities = locations_df["city"].tolist()

customers = []

for customer_id in range(1, customer_count + 1):

    signup_date = START_DATE - timedelta(
        days=random.randint(0, 365)
    )

    segment = random.choices(
        segments,
        weights=[80, 12, 8]
    )[0]

    customers.append([
        customer_id,
        signup_date.date(),
        segment,
        random.choice(cities),
        random.choice(acquisition_channels),
        (
            datetime(1965, 1, 1)
            + timedelta(days=random.randint(6000, 18000))
        ).date()
    ])

customers_df = pd.DataFrame(
    customers,
    columns=[
        "customer_id",
        "signup_date",
        "customer_segment",
        "city",
        "acquisition_channel",
        "date_of_birth"
    ]
)

customers_df.to_csv(OUTPUT + "customers.csv", index=False)

# ============================================================
# 5. VEHICLES
# ============================================================

vehicle_models = {
    "Tata Nexon EV": (30.2, "SUV"),
    "Tata Tiago EV": (24.0, "Hatchback"),
    "MG ZS EV": (50.3, "SUV"),
    "Mahindra XUV400": (39.4, "SUV"),
    "Hyundai Kona Electric": (39.2, "SUV"),
    "Hyundai Ioniq 5": (72.6, "SUV"),
    "BYD Atto 3": (60.5, "SUV"),
    "Kia EV6": (77.4, "SUV"),
    "Tata Punch EV": (35.0, "Hatchback"),
    "Mahindra BE 6": (59.0, "SUV")
}

vehicles = []
vehicle_id = 1

for customer_id in customers_df["customer_id"]:

    num_vehicles = random.choices(
        [1, 2],
        weights=[95, 5]
    )[0]

    for _ in range(num_vehicles):

        model = random.choice(list(vehicle_models.keys()))
        battery, vehicle_type = vehicle_models[model]

        vehicles.append([
            vehicle_id,
            customer_id,
            model,
            vehicle_type,
            battery,
            random.randint(2020, 2025)
        ])

        vehicle_id += 1

vehicles_df = pd.DataFrame(
    vehicles,
    columns=[
        "vehicle_id",
        "customer_id",
        "vehicle_model",
        "vehicle_type",
        "battery_capacity_kwh",
        "purchase_year"
    ]
)

vehicles_df.to_csv(OUTPUT + "vehicles.csv", index=False)

# ============================================================
# 6. SUBSCRIPTIONS
# ============================================================

subscriptions = []

plans = {
    "Basic": 199,
    "Premium": 499,
    "Fleet": 999
}

subscription_id = 1

# Around 50% customers have subscription history
subscription_customers = customers_df.sample(
    n=int(customer_count * 0.50),
    random_state=42
)

for _, customer in subscription_customers.iterrows():

    plan = random.choices(
        list(plans.keys()),
        weights=[55, 35, 10]
    )[0]

    start = pd.to_datetime(customer["signup_date"]) + timedelta(
        days=random.randint(0, 180)
    )

    if start > END_DATE:
        continue

    duration = random.randint(90, 730)

    end = start + timedelta(days=duration)

    status = (
        "Active"
        if end >= END_DATE
        else random.choices(
            ["Expired", "Cancelled"],
            weights=[85, 15]
        )[0]
    )

    subscriptions.append([
        subscription_id,
        customer["customer_id"],
        plan,
        start.date(),
        min(end, END_DATE).date(),
        plans[plan],
        status
    ])

    subscription_id += 1

subscriptions_df = pd.DataFrame(
    subscriptions,
    columns=[
        "subscription_id",
        "customer_id",
        "plan_name",
        "start_date",
        "end_date",
        "monthly_fee",
        "status"
    ]
)

subscriptions_df.to_csv(
    OUTPUT + "subscriptions.csv",
    index=False
)

# ============================================================
# 7. CHARGING SESSIONS
# ============================================================

session_count = 500000

vehicle_to_customer = dict(
    zip(
        vehicles_df["vehicle_id"],
        vehicles_df["customer_id"]
    )
)

active_chargers = chargers_df[
    chargers_df["status"] != "Offline"
]["charger_id"].tolist()

sessions = []

for session_id in range(1, session_count + 1):

    charger = random.choice(active_chargers)

    customer = random.choice(
        customers_df["customer_id"].tolist()
    )

    customer_vehicles = vehicles_df[
        vehicles_df["customer_id"] == customer
    ]["vehicle_id"].tolist()

    vehicle = random.choice(customer_vehicles)

    # Peak-hour weighting
    date = START_DATE + timedelta(
        days=random.randint(
            0,
            (END_DATE - START_DATE).days
        )
    )

    peak = random.choices(
        [True, False],
        weights=[60, 40]
    )[0]

    if peak:
        hour = random.choice(
            list(range(7, 11)) +
            list(range(18, 22))
        )
    else:
        hour = random.randint(0, 23)

    minute = random.randint(0, 59)

    start_time = date.replace(
        hour=hour,
        minute=minute,
        second=random.randint(0, 59)
    )

    charger_type = chargers_df.loc[
        chargers_df["charger_id"] == charger,
        "charger_type"
    ].iloc[0]

    if charger_type == "AC":
        energy = round(random.uniform(5, 25), 2)
        duration = random.randint(45, 180)
        rate = random.uniform(8, 12)

    elif charger_type == "DC Fast":
        energy = round(random.uniform(15, 70), 2)
        duration = random.randint(20, 100)
        rate = random.uniform(12, 18)

    else:
        energy = round(random.uniform(25, 120), 2)
        duration = random.randint(15, 70)
        rate = random.uniform(15, 22)

    end_time = start_time + timedelta(
        minutes=duration
    )

    session_status = random.choices(
        ["Completed", "Failed", "Cancelled"],
        weights=[93, 4, 3]
    )[0]

    amount = round(energy * rate, 2)

    # Small discount for subscription customers
    if customer in subscriptions_df["customer_id"].values:
        amount = round(amount * random.uniform(0.85, 0.95), 2)

    sessions.append([
        session_id,
        customer,
        vehicle,
        charger,
        start_time,
        end_time,
        energy,
        session_status,
        amount
    ])

    if session_id % 100000 == 0:
        print(f"{session_id:,} sessions generated")

sessions_df = pd.DataFrame(
    sessions,
    columns=[
        "session_id",
        "customer_id",
        "vehicle_id",
        "charger_id",
        "start_time",
        "end_time",
        "energy_kwh",
        "session_status",
        "amount"
    ]
)

sessions_df.to_csv(
    OUTPUT + "charging_sessions.csv",
    index=False
)

# ============================================================
# 8. PAYMENTS
# ============================================================

payments = []

payment_methods = ["UPI", "Card", "Wallet"]

for _, session in sessions_df.iterrows():

    payment_status = random.choices(
        ["Success", "Failed", "Refunded"],
        weights=[94, 4, 2]
    )[0]

    amount_paid = (
        session["amount"]
        if payment_status != "Refunded"
        else 0
    )

    payments.append([
        session["session_id"],
        session["session_id"],
        session["start_time"],
        random.choice(payment_methods),
        amount_paid,
        payment_status
    ])

payments_df = pd.DataFrame(
    payments,
    columns=[
        "payment_id",
        "session_id",
        "payment_date",
        "payment_method",
        "amount_paid",
        "payment_status"
    ]
)

payments_df["payment_id"] = range(
    1,
    len(payments_df) + 1
)

payments_df = payments_df[
    [
        "payment_id",
        "session_id",
        "payment_date",
        "payment_method",
        "amount_paid",
        "payment_status"
    ]
]

payments_df.to_csv(
    OUTPUT + "payments.csv",
    index=False
)

# ============================================================
# 9. ENERGY CONSUMPTION
# ============================================================

energy_df = sessions_df[
    [
        "session_id",
        "energy_kwh",
        "start_time"
    ]
].copy()

energy_df.insert(
    0,
    "energy_id",
    range(1, len(energy_df) + 1)
)

# Electricity cost per kWh
energy_df["energy_cost"] = (
    energy_df["energy_kwh"]
    * np.random.uniform(
        6.0,
        9.0,
        len(energy_df)
    )
).round(2)

energy_df.rename(
    columns={"start_time": "recorded_at"},
    inplace=True
)

energy_df.to_csv(
    OUTPUT + "energy_consumption.csv",
    index=False
)

# ============================================================
# 10. MAINTENANCE
# ============================================================

maintenance = []

issue_types = [
    "Hardware",
    "Software",
    "Connector",
    "Power Supply",
    "Cooling System"
]

maintenance_id = 1

for charger_id in chargers_df["charger_id"]:

    # Not every charger needs same amount of maintenance
    num_records = random.choices(
        [0, 1, 2, 3, 4],
        weights=[35, 30, 20, 10, 5]
    )[0]

    for _ in range(num_records):

        reported = START_DATE + timedelta(
            days=random.randint(
                0,
                (END_DATE - START_DATE).days
            )
        )

        downtime = round(
            random.uniform(2, 72),
            2
        )

        resolved = reported + timedelta(
            hours=downtime
        )

        status = (
            "Resolved"
            if resolved <= END_DATE
            else "Open"
        )

        maintenance.append([
            maintenance_id,
            charger_id,
            random.choice(issue_types),
            reported,
            resolved if status == "Resolved" else None,
            downtime,
            round(random.uniform(500, 15000), 2),
            status
        ])

        maintenance_id += 1

maintenance_df = pd.DataFrame(
    maintenance,
    columns=[
        "maintenance_id",
        "charger_id",
        "issue_type",
        "reported_date",
        "resolved_date",
        "downtime_hours",
        "maintenance_cost",
        "status"
    ]
)

maintenance_df.to_csv(
    OUTPUT + "maintenance.csv",
    index=False
)

# ============================================================
# FINAL SUMMARY
# ============================================================

print("\n" + "=" * 50)
print("DATA GENERATION COMPLETED")
print("=" * 50)

print("Locations:", len(locations_df))
print("Stations:", len(stations_df))
print("Chargers:", len(chargers_df))
print("Customers:", len(customers_df))
print("Vehicles:", len(vehicles_df))
print("Subscriptions:", len(subscriptions_df))
print("Sessions:", len(sessions_df))
print("Payments:", len(payments_df))
print("Energy:", len(energy_df))
print("Maintenance:", len(maintenance_df))

print("\nAll files saved to:")
print(OUTPUT)