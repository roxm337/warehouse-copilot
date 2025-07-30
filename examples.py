"""
Usage Examples for the Intelligent Warehouse Management Agent
Run these examples after starting the server with: uvicorn main:app --reload
"""

import requests
import json

BASE_URL = "http://localhost:8000"

def make_request(method, endpoint, data=None):
    """Make a request to the API and print the response"""
    url = f"{BASE_URL}{endpoint}"
    
    try:
        if method.upper() == "POST":
            response = requests.post(url, json=data)
        else:
            response = requests.get(url)
        
        response.raise_for_status()
        result = response.json()
        
        print(f"\n🔗 {method.upper()} {endpoint}")
        if data:
            print(f"📤 Request: {json.dumps(data, indent=2)}")
        print(f"📥 Response: {json.dumps(result, indent=2)}")
        
    except requests.exceptions.RequestException as e:
        print(f"❌ Error: {e}")

def main():
    print("🏭 Intelligent Warehouse Management Agent - Usage Examples")
    print("=" * 60)
    
    # Example 1: Health Check
    print("\n1️⃣ Health Check")
    make_request("GET", "/")
    
    # Example 2: Warehouse Statistics
    print("\n2️⃣ Warehouse Statistics")
    make_request("GET", "/warehouse/stats")
    
    # Example 3: Natural Language Chat - Low Stock Query
    print("\n3️⃣ Natural Language Query - Low Stock")
    make_request("POST", "/chat", {
        "message": "Which products are running low on stock and need reordering?"
    })
    
    # Example 4: Natural Language Chat - Inventory Summary
    print("\n4️⃣ Natural Language Query - Warehouse Summary")
    make_request("POST", "/chat", {
        "message": "Give me a comprehensive warehouse report with statistics"
    })
    
    # Example 5: Natural Language Chat - Shipment Status
    print("\n5️⃣ Natural Language Query - Shipment Status")
    make_request("POST", "/chat", {
        "message": "What shipments are currently in transit?"
    })
    
    # Example 6: Natural Language Chat - Product Information
    print("\n6️⃣ Natural Language Query - Product Info")
    make_request("POST", "/chat", {
        "message": "Tell me about product PRD-0001"
    })
    
    # Example 7: Advanced Warehouse Query
    print("\n7️⃣ Advanced Warehouse Query")
    make_request("POST", "/warehouse/query", {
        "query": "How many electronics products do we have and what's their total value?",
        "include_context": True
    })
    
    # Example 8: Get Low Stock Products (Direct API)
    print("\n8️⃣ Direct API - Low Stock Products")
    make_request("GET", "/warehouse/low-stock")
    
    # Example 9: Get Products by Category
    print("\n9️⃣ Direct API - Products by Category")
    make_request("GET", "/warehouse/products?category=Electronics")
    
    # Example 10: Get Delayed Shipments
    print("\n🔟 Direct API - Delayed Shipments")
    make_request("GET", "/warehouse/shipments?status=delayed")
    
    print("\n" + "=" * 60)
    print("✅ All examples completed!")
    print("\n💡 Try these natural language queries:")
    print("   • 'What's our inventory worth?'")
    print("   • 'Which categories have the most products?'")
    print("   • 'Show me urgent reorder recommendations'")
    print("   • 'What's the status of our deliveries?'")
    print("   • 'How many products are in location A-01?'")
    print("\n🌐 Visit http://localhost:8000/docs for interactive API documentation")

if __name__ == "__main__":
    main()
