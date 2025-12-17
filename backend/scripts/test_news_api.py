"""
Test script to see what ActuallyFreeAPI is returning
"""

import asyncio
import aiohttp
from datetime import datetime, timedelta


async def test_api():
    """Test the ActuallyFreeAPI to see what it returns"""

    base_url = "https://actually-free-api.vercel.app/api"

    # Test with date filter for last 30 days
    start_date = (datetime.now() - timedelta(days=30)).strftime("%Y-%m-%d")

    params = {
        "limit": 10,  # Just get 10 articles for testing
        "page": 1,
        "startDate": start_date
    }

    print(f"Testing API with params: {params}")
    print(f"Start date: {start_date}")
    print("=" * 60)

    async with aiohttp.ClientSession() as session:
        url = f"{base_url}/news"
        async with session.get(url, params=params, timeout=aiohttp.ClientTimeout(total=30)) as response:
            if response.status != 200:
                print(f"Error: API returned status {response.status}")
                return

            data = await response.json()
            articles = data.get("data", [])
            pagination = data.get("pagination", {})

            print(f"Total articles returned: {len(articles)}")
            print(f"Pagination: {pagination}")
            print("=" * 60)

            if articles:
                print("\nFirst 3 articles:")
                for i, article in enumerate(articles[:3], 1):
                    print(f"\n{i}. {article.get('title', 'No title')}")
                    print(f"   Source: {article.get('source', 'Unknown')}")
                    print(f"   Date: {article.get('pub_date', 'No date')}")
                    print(f"   Tickers: {article.get('tickers', [])}")
                    print(f"   Link: {article.get('link', 'No link')}")
            else:
                print("No articles returned!")


if __name__ == "__main__":
    asyncio.run(test_api())
