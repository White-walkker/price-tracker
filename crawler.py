import os
os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = os.path.expanduser('~/price-tracker/gcp-key.json')

import requests
from bs4 import BeautifulSoup
from datetime import datetime
from google.cloud import bigquery

BASE_URL   = "https://webscraper.io/test-sites/e-commerce/static/computers/laptops"
PROJECT_ID = "celtic-bivouac-453916-n6"
DATASET    = "ecommerce_prices"
TABLE      = "product_prices"

def crawl_laptops():
    all_products = []
    page = 1

    while True:
        url = f"{BASE_URL}?page={page}"
        response = requests.get(url)
        soup = BeautifulSoup(response.text, "html.parser")

        products = soup.find_all("div", class_="thumbnail")
        if not products:
            break

        for product in products:
            name  = product.find("a", class_="title").text.strip()
            price = product.find("h4", class_="price").text.strip()
            price_clean = float(price.replace("$", "").replace(",", ""))

            desc = product.find("p", class_="description")
            description = desc.text.strip() if desc else ""

            print(f"✅ {name} → ${price_clean}")

            all_products.append({
                "product_name":     name,
                "price":            price_clean,
                "original_price":   price_clean,
                "discount_percent": 0.0,
                "website":          "webscraper.io",
                "url":              url,
                "crawled_at":       datetime.utcnow().isoformat()
            })

        print(f"--- Page {page} done ---")
        page += 1

    return all_products

def push_to_bigquery(data):
    try:
        client = bigquery.Client(project=PROJECT_ID)
        table_ref = f"{PROJECT_ID}.{DATASET}.{TABLE}"
        print(f"\nConnecting to: {table_ref}")

        errors = client.insert_rows_json(table_ref, data)

        if errors:
            print(f"❌ BigQuery errors:")
            for error in errors:
                print(error)
        else:
            print(f"✅ {len(data)} rows pushed to BigQuery successfully!")
    except Exception as e:
        print(f"❌ Exception: {e}")

if __name__ == "__main__":
    print("Starting crawler...")
    data = crawl_laptops()
    print(f"\nTotal crawled: {len(data)}")
    print("\nPushing to BigQuery...")
    push_to_bigquery(data)