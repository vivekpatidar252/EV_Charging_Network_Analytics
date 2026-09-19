import pandas as pd

df = pd.read_csv("Data/Raw/charging_sessions.csv")

print("Shape:", df.shape)
print("\nFirst 5 rows:")
print(df.head())

print("\nInfo:")
print(df.info())
