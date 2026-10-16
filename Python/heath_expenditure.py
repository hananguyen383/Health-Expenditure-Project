
import requests
import pandas as pd
from io import StringIO

# Website URL
url = "https://en.wikipedia.org/wiki/List_of_countries_by_total_health_expenditure_per_capita"

# Download the webpage
headers = {
    "User-Agent": "Mozilla/5.0 (compatible; DataAnalysisProject/1.0)"
}

response = requests.get(url, headers=headers, timeout=30)
response.raise_for_status()

# Extract all HTML tables
tables = pd.read_html(StringIO(response.text))

print(f"Found {len(tables)} tables.")

# Save each table as a separate CSV file
for i, table in enumerate(tables, start=1):
    filename = f"health_expenditure_table_{i}.csv"
    table.to_csv(filename, index=False, encoding="utf-8-sig")

    print(f"Saved: {filename}")
    print(table.head(3))
    print("-" * 50)