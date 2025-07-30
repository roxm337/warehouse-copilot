from sqlalchemy import create_engine, Column, Integer, String, DECIMAL, Text, DateTime, Boolean, BigInteger, Date, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session, relationship
from sqlalchemy.sql import func
from datetime import datetime, date
from decimal import Decimal
from typing import Optional, List, Dict, Any
import os
from dotenv import load_dotenv

load_dotenv()

# Database configuration with fallback to SQLite
DATABASE_URL = os.getenv(
    "DATABASE_URL", 
    "mysql+pymysql://root:toor@localhost/kasmifood_admin"
)

# Try to create engine with error handling
try:
    engine = create_engine(DATABASE_URL, echo=False)
    # Test the connection
    test_conn = engine.connect()
    test_conn.close()
    print("✅ Connected to MySQL database")
except Exception as e:
    print(f"⚠️ MySQL connection failed: {e}")
    print("🔄 Falling back to SQLite database...")
    DATABASE_URL = "sqlite:///./food_management.db"
    engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False}, echo=False)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Database Models
class Category(Base):
    __tablename__ = "categories"
    
    id = Column(BigInteger, primary_key=True, index=True)
    name = Column(String(255))
    parent_id = Column(BigInteger, nullable=False, default=0)
    position = Column(Integer, nullable=False)
    status = Column(Boolean, nullable=False, default=True)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())
    image = Column(String(255), default='def.png')
    panel_image = Column(String(255), default='def.png')
    priority = Column(Integer, default=1)

class Product(Base):
    __tablename__ = "products"
    
    id = Column(BigInteger, primary_key=True, index=True)
    is_base = Column(Boolean, nullable=False, default=False)
    parent_id = Column(BigInteger)
    status = Column(Boolean, nullable=False, default=True)
    manufacturer_reference = Column(String(255))
    warranty_years = Column(Integer)
    name = Column(String(255))
    description = Column(Text)
    image = Column(Text)
    technical_file = Column(Text)
    nutrition_fact_image = Column(String(255), default='def.png')
    nutrition_fact = Column(Text)
    price = Column(DECIMAL(10, 2), nullable=False, default=0)
    tax = Column(DECIMAL(8, 2), nullable=False, default=0)
    attributes = Column(Text)
    attribute_ids = Column(Text)
    discount = Column(DECIMAL(8, 2), nullable=False, default=0)
    discount_type = Column(String(20), nullable=False, default='percent')
    tax_type = Column(String(20), nullable=False, default='percent')
    unit = Column(String(255), nullable=False, default='pc')
    low_stock_limit = Column(Integer)
    capacity = Column(DECIMAL(8, 2))
    daily_needs = Column(Boolean, nullable=False, default=False)
    popularity_count = Column(Integer, nullable=False, default=0)
    is_featured = Column(Boolean, nullable=False, default=False)
    view_count = Column(Integer, nullable=False, default=0)
    maximum_order_quantity = Column(Integer, nullable=False, default=0)
    minimum_order_quantity = Column(Integer, nullable=False, default=0)
    weight = Column(DECIMAL(8, 2))
    length = Column(DECIMAL(8, 2))
    width = Column(DECIMAL(8, 2))
    height = Column(DECIMAL(8, 2))
    category_ids = Column(Text)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())
    is_deleted = Column(Boolean, nullable=False, default=False)

class WarehouseProduct(Base):
    __tablename__ = "warehouse_products"
    
    id = Column(BigInteger, primary_key=True, index=True)
    warehouse_id = Column(BigInteger, nullable=False)
    product_id = Column(BigInteger, ForeignKey('products.id'), nullable=False)
    quantity = Column(Integer, nullable=False, default=0)
    price = Column(DECIMAL(10, 2), nullable=False)
    cost_price = Column(DECIMAL(10, 2), nullable=False)
    status = Column(String(255), nullable=False)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())
    
    # Relationships
    product = relationship("Product")

class Order(Base):
    __tablename__ = "orders"
    
    id = Column(BigInteger, primary_key=True, index=True)
    user_id = Column(BigInteger)
    is_guest = Column(Boolean, nullable=False, default=False)
    order_amount = Column(DECIMAL(8, 2), nullable=False, default=0)
    coupon_discount_amount = Column(DECIMAL(8, 2), nullable=False, default=0)
    coupon_discount_title = Column(String(255))
    payment_status = Column(String(255), nullable=False, default='unpaid')
    order_status = Column(String(255), nullable=False, default='placed')
    total_tax_amount = Column(DECIMAL(8, 2), nullable=False, default=0)
    payment_method = Column(String(30))
    transaction_reference = Column(String(30))
    delivery_address_id = Column(BigInteger)
    created_at = Column(DateTime, default=func.now())
    updated_at = Column(DateTime, default=func.now(), onupdate=func.now())
    checked = Column(Boolean, nullable=False, default=False)
    delivery_man_id = Column(BigInteger)
    delivery_charge = Column(DECIMAL(8, 2), default=0)
    order_note = Column(Text)
    coupon_code = Column(String(255))
    order_type = Column(String(255), nullable=False, default='delivery')
    date = Column(Date)
    delivery_date = Column(Date)
    callback = Column(String(255))
    extra_discount = Column(DECIMAL(8, 2), nullable=False, default=0)
    delivery_address = Column(Text)
    payment_by = Column(String(255))
    payment_note = Column(String(255))
    free_delivery_amount = Column(DECIMAL(8, 2), default=0)
    weight_charge_amount = Column(DECIMAL(8, 2), nullable=False, default=0)

# Database service class
class DatabaseService:
    def __init__(self):
        self.db = SessionLocal()
    
    def close(self):
        self.db.close()
    
    def __enter__(self):
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        self.close()
    
    # Product operations
    def get_products(self, limit: int = 100, category_id: Optional[int] = None, 
                    low_stock_only: bool = False) -> List[Product]:
        """Get products with optional filters"""
        query = self.db.query(Product).filter(
            Product.status == True,
            Product.is_deleted == False
        )
        
        if category_id:
            query = query.filter(Product.category_ids.contains(f'"id":{category_id}'))
        
        if low_stock_only:
            # Join with warehouse_products to check stock levels
            query = query.join(WarehouseProduct).filter(
                WarehouseProduct.quantity <= Product.low_stock_limit
            )
        
        return query.limit(limit).all()
    
    def get_product_by_id(self, product_id: int) -> Optional[Product]:
        """Get a specific product by ID"""
        return self.db.query(Product).filter(
            Product.id == product_id,
            Product.status == True,
            Product.is_deleted == False
        ).first()
    
    def get_warehouse_products(self, warehouse_id: Optional[int] = None) -> List[WarehouseProduct]:
        """Get warehouse products with inventory information"""
        query = self.db.query(WarehouseProduct).join(Product).filter(
            Product.status == True,
            Product.is_deleted == False
        )
        
        if warehouse_id:
            query = query.filter(WarehouseProduct.warehouse_id == warehouse_id)
        
        return query.all()
    
    def get_low_stock_products(self, warehouse_id: Optional[int] = None) -> List[Dict[str, Any]]:
        """Get products with low stock levels"""
        query = self.db.query(WarehouseProduct, Product).join(Product).filter(
            Product.status == True,
            Product.is_deleted == False,
            WarehouseProduct.quantity <= Product.low_stock_limit
        )
        
        if warehouse_id:
            query = query.filter(WarehouseProduct.warehouse_id == warehouse_id)
        
        results = []
        for wp, p in query.all():
            results.append({
                'id': p.id,
                'name': p.name,
                'current_stock': wp.quantity,
                'reorder_point': p.low_stock_limit or 10,
                'price': float(p.price),
                'warehouse_id': wp.warehouse_id,
                'category_ids': p.category_ids,
                'status': wp.status
            })
        
        return results
    
    # Category operations
    def get_categories(self, parent_id: int = 0) -> List[Category]:
        """Get categories, optionally filtered by parent"""
        return self.db.query(Category).filter(
            Category.status == True,
            Category.parent_id == parent_id
        ).all()
    
    def get_category_by_id(self, category_id: int) -> Optional[Category]:
        """Get a specific category by ID"""
        return self.db.query(Category).filter(
            Category.id == category_id,
            Category.status == True
        ).first()
    
    # Order operations
    def get_orders(self, status: Optional[str] = None, limit: int = 100) -> List[Order]:
        """Get orders with optional status filter"""
        query = self.db.query(Order)
        
        if status:
            query = query.filter(Order.order_status == status)
        
        return query.order_by(Order.created_at.desc()).limit(limit).all()
    
    def get_order_by_id(self, order_id: int) -> Optional[Order]:
        """Get a specific order by ID"""
        return self.db.query(Order).filter(Order.id == order_id).first()
    
    # Statistics operations
    def get_warehouse_stats(self) -> Dict[str, Any]:
        """Get comprehensive warehouse statistics"""
        
        # Total products
        total_products = self.db.query(Product).filter(
            Product.status == True,
            Product.is_deleted == False
        ).count()
        
        # Low stock products
        low_stock_count = self.db.query(WarehouseProduct).join(Product).filter(
            Product.status == True,
            Product.is_deleted == False,
            WarehouseProduct.quantity <= Product.low_stock_limit
        ).count()
        
        # Total inventory value
        inventory_value_result = self.db.query(
            func.sum(WarehouseProduct.quantity * WarehouseProduct.price)
        ).join(Product).filter(
            Product.status == True,
            Product.is_deleted == False
        ).scalar()
        
        total_inventory_value = float(inventory_value_result or 0)
        
        # Categories count
        categories = self.db.query(Category).filter(Category.status == True).all()
        category_stats = {}
        for cat in categories:
            products_in_category = self.db.query(Product).filter(
                Product.status == True,
                Product.is_deleted == False,
                Product.category_ids.contains(f'"id":{cat.id}')
            ).count()
            if products_in_category > 0:
                category_stats[cat.name] = products_in_category
        
        # Order status stats
        order_statuses = ['placed', 'confirmed', 'processing', 'delivered', 'canceled']
        order_stats = {}
        for status in order_statuses:
            count = self.db.query(Order).filter(Order.order_status == status).count()
            if count > 0:
                order_stats[status] = count
        
        # Average stock level
        avg_stock_result = self.db.query(
            func.avg(WarehouseProduct.quantity)
        ).join(Product).filter(
            Product.status == True,
            Product.is_deleted == False
        ).scalar()
        
        average_stock_level = float(avg_stock_result or 0)
        
        return {
            'total_products': total_products,
            'low_stock_products': low_stock_count,
            'total_inventory_value': total_inventory_value,
            'categories': category_stats,
            'order_status': order_stats,
            'average_stock_level': average_stock_level
        }
    
    def search_products(self, query: str, limit: int = 50) -> List[Product]:
        """Search products by name or description"""
        return self.db.query(Product).filter(
            Product.status == True,
            Product.is_deleted == False,
            Product.name.contains(query)
        ).limit(limit).all()

# Dependency to get database session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def create_sample_data():
    """Create sample data for SQLite database"""
    try:
        session = SessionLocal()
        
        # Check if data already exists
        if session.query(Product).first():
            session.close()
            return
        
        print("🔄 Creating sample food data...")
        
        # Create categories
        drinks_cat = Category(id=1, name="Drinks", parent_id=0, position=1)
        hot_cat = Category(id=2, name="hot", parent_id=0, position=2)
        cold_cat = Category(id=3, name="cold", parent_id=0, position=3)
        cake_cat = Category(id=4, name="Cake", parent_id=0, position=4)
        
        session.add_all([drinks_cat, hot_cat, cold_cat, cake_cat])
        
        # Create sample products (simplified for SQLite)
        products = [
            Product(id=1, name="Kamini sausages", price=Decimal("4.99"), status=True),
            Product(id=2, name="Gouda cheese", price=Decimal("7.50"), status=True),
            Product(id=3, name="Chicken breast", price=Decimal("12.99"), status=True),
            Product(id=4, name="Coca Cola", price=Decimal("2.99"), status=True),
            Product(id=5, name="Chocolate cake", price=Decimal("15.99"), status=True),
            Product(id=6, name="Fresh milk", price=Decimal("3.49"), status=True),
        ]
        
        session.add_all(products)
        
        # Create warehouse products with stock levels
        warehouse_products = [
            WarehouseProduct(id=1, warehouse_id=1, product_id=1, quantity=150, price=Decimal("4.99"), cost_price=Decimal("3.50"), status="active"),
            WarehouseProduct(id=2, warehouse_id=1, product_id=2, quantity=85, price=Decimal("7.50"), cost_price=Decimal("5.25"), status="active"),
            WarehouseProduct(id=3, warehouse_id=1, product_id=3, quantity=200, price=Decimal("12.99"), cost_price=Decimal("9.50"), status="active"),
            WarehouseProduct(id=4, warehouse_id=1, product_id=4, quantity=300, price=Decimal("2.99"), cost_price=Decimal("1.50"), status="active"),
            WarehouseProduct(id=5, warehouse_id=1, product_id=5, quantity=25, price=Decimal("15.99"), cost_price=Decimal("10.99"), status="active"),
            WarehouseProduct(id=6, warehouse_id=1, product_id=6, quantity=120, price=Decimal("3.49"), cost_price=Decimal("2.25"), status="active"),
        ]
        
        session.add_all(warehouse_products)
        
        # Create sample orders
        orders = [
            Order(id=1, user_id=1, order_amount=Decimal("45.97"), order_status="delivered", 
                 created_at=datetime.now()),
            Order(id=2, user_id=2, order_amount=Decimal("28.48"), order_status="processing", 
                 created_at=datetime.now()),
            Order(id=3, user_id=3, order_amount=Decimal("67.23"), order_status="delivered", 
                 created_at=datetime.now()),
        ]
        
        session.add_all(orders)
        session.commit()
        session.close()
        
        print("✅ Sample data created successfully!")
        
    except Exception as e:
        print(f"❌ Error creating sample data: {e}")
        if 'session' in locals():
            session.rollback()
            session.close()

# Initialize database if using SQLite
if "sqlite" in DATABASE_URL.lower():
    print("🔧 Setting up SQLite database...")
    Base.metadata.create_all(bind=engine)
    create_sample_data()

# Global database service instance
db_service = DatabaseService()
