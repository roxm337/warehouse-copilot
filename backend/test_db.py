#!/usr/bin/env python3
"""
Test script to verify database connectivity and data retrieval
"""

from database_service import DatabaseService

def test_database_connection():
    """Test basic database operations"""
    try:
        print("🔌 Testing database connection...")
        db_service = DatabaseService()
        
        print("✅ Database connection successful!")
        
        # Test basic operations
        print("\n📊 Testing warehouse statistics...")
        stats = db_service.get_warehouse_stats()
        print(f"Stats: {stats}")
        
        print("\n🍎 Testing product retrieval...")
        products = db_service.get_products()
        print(f"Found {len(products)} products")
        if products:
            print(f"Sample product: {products[0].name} - ${products[0].price}")
        
        print("\n📦 Testing orders retrieval...")
        orders = db_service.get_orders()
        print(f"Found {len(orders)} orders")
        if orders:
            print(f"Sample order: Order #{orders[0].id} - ${orders[0].order_amount}")
        
        print("\n⚠️ Testing low stock products...")
        low_stock = db_service.get_low_stock_products()
        print(f"Found {len(low_stock)} low stock products")
        
        db_service.close()
        print("\n✅ All database tests passed!")
        
    except Exception as e:
        print(f"❌ Database test failed: {str(e)}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    test_database_connection()
