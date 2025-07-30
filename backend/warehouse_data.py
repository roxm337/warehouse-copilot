"""
Warehouse data simulation module
This module simulates warehouse inventory and shipment data for the AI agent
"""

from datetime import datetime, timedelta
import random
from typing import List, Dict, Any
from dataclasses import dataclass

@dataclass
class Product:
    id: str
    name: str
    category: str
    stock_level: int
    reorder_point: int
    unit_price: float
    location: str
    supplier: str

@dataclass
class Shipment:
    id: str
    product_id: str
    quantity: int
    status: str  # pending, in_transit, delivered, delayed
    origin: str
    destination: str
    expected_date: datetime
    actual_date: datetime = None

class WarehouseData:
    def __init__(self):
        self.products = self._generate_sample_products()
        self.shipments = self._generate_sample_shipments()
    
    def _generate_sample_products(self) -> List[Product]:
        """Generate sample product data"""
        categories = ["Electronics", "Clothing", "Home & Garden", "Sports", "Books"]
        locations = ["A-01", "A-02", "B-01", "B-02", "C-01", "C-02"]
        suppliers = ["TechSupply Co", "Fashion World", "Garden Plus", "SportMax", "BookDist"]
        
        products = []
        for i in range(1, 51):  # 50 sample products
            product = Product(
                id=f"PRD-{i:04d}",
                name=f"Product {i}",
                category=random.choice(categories),
                stock_level=random.randint(0, 500),
                reorder_point=random.randint(10, 50),
                unit_price=round(random.uniform(10.0, 500.0), 2),
                location=random.choice(locations),
                supplier=random.choice(suppliers)
            )
            products.append(product)
        return products
    
    def _generate_sample_shipments(self) -> List[Shipment]:
        """Generate sample shipment data"""
        statuses = ["pending", "in_transit", "delivered", "delayed"]
        origins = ["Warehouse A", "Warehouse B", "Supplier Hub"]
        destinations = ["Store 1", "Store 2", "Customer Direct", "Distribution Center"]
        
        shipments = []
        for i in range(1, 31):  # 30 sample shipments
            expected_date = datetime.now() + timedelta(days=random.randint(-10, 30))
            actual_date = expected_date + timedelta(days=random.randint(-2, 5)) if random.choice([True, False]) else None
            
            shipment = Shipment(
                id=f"SHP-{i:04d}",
                product_id=f"PRD-{random.randint(1, 50):04d}",
                quantity=random.randint(1, 100),
                status=random.choice(statuses),
                origin=random.choice(origins),
                destination=random.choice(destinations),
                expected_date=expected_date,
                actual_date=actual_date
            )
            shipments.append(shipment)
        return shipments
    
    def get_low_stock_products(self) -> List[Product]:
        """Get products with stock below reorder point"""
        return [p for p in self.products if p.stock_level <= p.reorder_point]
    
    def get_products_by_category(self, category: str) -> List[Product]:
        """Get products by category"""
        return [p for p in self.products if p.category.lower() == category.lower()]
    
    def get_shipments_by_status(self, status: str) -> List[Shipment]:
        """Get shipments by status"""
        return [s for s in self.shipments if s.status.lower() == status.lower()]
    
    def get_product_by_id(self, product_id: str) -> Product:
        """Get product by ID"""
        for product in self.products:
            if product.id == product_id:
                return product
        return None
    
    def get_total_inventory_value(self) -> float:
        """Calculate total inventory value"""
        return sum(p.stock_level * p.unit_price for p in self.products)
    
    def get_warehouse_stats(self) -> Dict[str, Any]:
        """Get comprehensive warehouse statistics"""
        total_products = len(self.products)
        low_stock_count = len(self.get_low_stock_products())
        total_value = self.get_total_inventory_value()
        
        category_counts = {}
        for product in self.products:
            category_counts[product.category] = category_counts.get(product.category, 0) + 1
        
        shipment_status_counts = {}
        for shipment in self.shipments:
            shipment_status_counts[shipment.status] = shipment_status_counts.get(shipment.status, 0) + 1
        
        return {
            "total_products": total_products,
            "low_stock_products": low_stock_count,
            "total_inventory_value": round(total_value, 2),
            "categories": category_counts,
            "shipment_status": shipment_status_counts,
            "average_stock_level": round(sum(p.stock_level for p in self.products) / total_products, 2)
        }

# Global warehouse data instance
warehouse_db = WarehouseData()
