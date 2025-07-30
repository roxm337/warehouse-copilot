"""
Test script for the Warehouse Management Agent
Run this after starting the FastAPI server to test functionality
"""

import requests
import json
import time

BASE_URL = "http://localhost:8000"

def test_endpoint(method, endpoint, data=None, params=None):
    """Test a specific endpoint and return the response"""
    url = f"{BASE_URL}{endpoint}"
    try:
        if method.upper() == "POST":
            response = requests.post(url, json=data)
        else:
            response = requests.get(url, params=params)
        
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"Error testing {endpoint}: {e}")
        return None

def main():
    print("🏭 Testing Intelligent Warehouse Management Agent")
    print("=" * 50)
    
    # Test health check
    print("\n1. Testing health check...")
    result = test_endpoint("GET", "/")
    if result:
        print(f"✅ Health check passed: {result['status']}")
    
    # Test warehouse stats
    print("\n2. Testing warehouse statistics...")
    result = test_endpoint("GET", "/warehouse/stats")
    if result:
        print(f"✅ Found {result['total_products']} products, {result['low_stock_products']} low stock")
    
    # Test low stock products
    print("\n3. Testing low stock products...")
    result = test_endpoint("GET", "/warehouse/low-stock")
    if result:
        print(f"✅ {result['low_stock_count']} products need reordering")
    
    # Test natural language chat
    print("\n4. Testing natural language queries...")
    test_queries = [
        "What products are running low on stock?",
        "Show me the warehouse statistics",
        "How many electronics are in stock?",
        "Tell me about product PRD-0001"
    ]
    
    for query in test_queries:
        print(f"\nQuery: '{query}'")
        result = test_endpoint("POST", "/chat", {"message": query})
        if result:
            print(f"✅ Intent: {result['query_analysis']['intent']}")
            print(f"📝 Response: {result['reply'][:100]}...")
        time.sleep(1)  # Rate limiting
    
    # Test advanced warehouse query
    print("\n5. Testing advanced warehouse query...")
    result = test_endpoint("POST", "/warehouse/query", {
        "query": "Give me a comprehensive warehouse report", 
        "include_context": True
    })
    if result:
        print(f"✅ Advanced query processed: {result['reply'][:100]}...")
    
    # Test product details
    print("\n6. Testing product details...")
    result = test_endpoint("GET", "/warehouse/product/PRD-0001")
    if result:
        print(f"✅ Product found: {result['name']} - Stock: {result['stock_level']}")
    
    print("\n🎉 All tests completed!")
    print("\nNow you can:")
    print("- Visit http://localhost:8000/docs for interactive API docs")
    print("- Use the /chat endpoint with natural language queries")
    print("- Explore warehouse data through various endpoints")

if __name__ == "__main__":
    main()
