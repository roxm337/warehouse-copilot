from fastapi import FastAPI, HTTPException, Query, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import requests
import os
from dotenv import load_dotenv
from typing import Optional, List, Dict, Any
import logging
from datetime import datetime
from sqlalchemy.orm import Session

# Import our custom modules
from database_service import DatabaseService, get_db, Product, Category, Order, WarehouseProduct
from nlu_processor import nlu_processor, QueryIntent

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

load_dotenv()
GROQ_API_KEY = os.getenv("GROQ_API_KEY")

app = FastAPI(
    title="AI-Powered Food Management System",
    description="AI-powered restaurant/food management system with natural language interface connected to real database",
    version="2.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Pydantic models
class Message(BaseModel):
    message: str = Field(..., description="Natural language query about warehouse operations")

class WarehouseQuery(BaseModel):
    query: str = Field(..., description="Natural language warehouse query")
    include_context: bool = Field(default=True, description="Include warehouse context in response")

class APIResponse(BaseModel):
    reply: str
    query_analysis: Optional[Dict[str, Any]] = None
    timestamp: datetime = Field(default_factory=datetime.now)

def generate_context_prompt_with_db(query_analysis: Dict[str, Any], db_service: DatabaseService) -> str:
    """Generate context-aware prompt using real database data"""
    
    # Get current database stats
    stats = db_service.get_warehouse_stats()
    
    # Base context
    context = f"""You are an AI assistant for a food management system. You have access to real-time data from our food database.

Current System Status:
- Total Products: {stats['total_products']}
- Low Stock Products: {stats['low_stock_products']}  
- Total Inventory Value: €{stats['total_inventory_value']:.2f}
- Product Categories: {', '.join(stats['categories'].keys())}
- Average Stock Level: {stats['average_stock_level']:.1f} units

Query Intent: {query_analysis.get('intent', 'general')}
Detected Entities: {query_analysis.get('entities', {})}

You should provide helpful, accurate responses about:
- Food products and inventory management
- Stock levels and reorder alerts  
- Order status and delivery tracking
- Product categories and pricing
- Restaurant/food business operations

Be conversational, helpful, and use the real data provided to give accurate information."""

    # Add specific context based on intent
    if query_analysis.get('intent') == 'low_stock':
        low_stock = db_service.get_low_stock_products()
        if low_stock:
            context += f"\n\nCurrent Low Stock Items ({len(low_stock)} total):\n"
            for item in low_stock[:5]:  # Show first 5
                context += f"- {item['name']}: {item['current_stock']} units (reorder at {item['reorder_point']})\n"
    
    elif query_analysis.get('intent') == 'inventory_status':
        context += f"\n\nInventory Summary:\n"
        for category, count in stats['categories'].items():
            context += f"- {category}: {count} products\n"
    
    return context

@app.get("/", tags=["Health"])
def read_root():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "AI-Powered Food Management System",
        "version": "2.0.0",
        "database": "kasmifood_admin",
        "timestamp": datetime.now()
    }

@app.post("/chat", response_model=APIResponse, tags=["AI Agent"])
def chat_with_food_agent(message: Message, db: Session = Depends(get_db)):
    """
    Main chat endpoint for food management queries.
    Accepts natural language input and provides intelligent responses.
    """
    try:
        # Create database service instance
        db_service = DatabaseService()
        
        # Analyze the user query
        query_analysis = nlu_processor.analyze_query(message.message)
        logger.info(f"Query analysis: {query_analysis}")
        
        # Generate context-aware system prompt with real data
        context_prompt = generate_context_prompt_with_db(query_analysis, db_service)
        
        # Prepare the LLM request
        url = "https://api.groq.com/openai/v1/chat/completions"
        headers = {
            "Authorization": f"Bearer {GROQ_API_KEY}",
            "Content-Type": "application/json"
        }

        payload = {
            "model": "llama3-8b-8192",  # Using a known working model
            "messages": [
                {"role": "system", "content": context_prompt},
                {"role": "user", "content": message.message}
            ],
            "temperature": 0.7,
            "max_tokens": 1000,
            "stream": False
        }

        response = requests.post(url, headers=headers, json=payload)
        response.raise_for_status()
        result = response.json()
        reply = result["choices"][0]["message"]["content"]
        
        db_service.close()
        
        return APIResponse(
            reply=reply,
            query_analysis=query_analysis
        )
        
    except Exception as e:
        logger.error(f"Error in chat endpoint: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Service error: {str(e)}")

@app.post("/warehouse/query", response_model=APIResponse, tags=["Food Management"])
def advanced_food_query(warehouse_query: WarehouseQuery, db: Session = Depends(get_db)):
    """
    Advanced food management query endpoint with detailed analysis
    """
    try:
        # Create database service instance
        db_service = DatabaseService()
        
        # Analyze the query
        analysis = nlu_processor.analyze_query(warehouse_query.query)
        
        # Generate response based on intent
        if analysis['intent'] == QueryIntent.WAREHOUSE_STATS:
            stats = db_service.get_warehouse_stats()
            response_text = f"Here's your food management overview: {stats}"
        elif analysis['intent'] == QueryIntent.LOW_STOCK:
            low_stock = db_service.get_low_stock_products()
            response_text = f"Low stock alert: {len(low_stock)} products need attention"
        else:
            # Use LLM for complex queries
            context_prompt = generate_context_prompt_with_db(analysis, db_service)
            
            url = "https://api.groq.com/openai/v1/chat/completions"
            headers = {
                "Authorization": f"Bearer {GROQ_API_KEY}",
                "Content-Type": "application/json"
            }

            payload = {
                "model": "llama3-8b-8192",
                "messages": [
                    {"role": "system", "content": context_prompt},
                    {"role": "user", "content": warehouse_query.query}
                ],
                "temperature": 0.5,
                "max_tokens": 800,
                "stream": False
            }

            response = requests.post(url, headers=headers, json=payload)
            response.raise_for_status()
            result = response.json()
            response_text = result["choices"][0]["message"]["content"]
        
        db_service.close()
        
        return APIResponse(
            reply=response_text,
            query_analysis=analysis if warehouse_query.include_context else None
        )
        
    except Exception as e:
        logger.error(f"Error in food query endpoint: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Query processing error: {str(e)}")

@app.get("/warehouse/stats", tags=["Food Management"])
def get_food_statistics(db: Session = Depends(get_db)):
    """Get comprehensive food management statistics"""
    try:
        db_service = DatabaseService()
        stats = db_service.get_warehouse_stats()
        db_service.close()
        return stats
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/warehouse/low-stock", tags=["Food Management"])
def get_low_stock_products(db: Session = Depends(get_db)):
    """Get products with stock levels below reorder point"""
    try:
        db_service = DatabaseService()
        low_stock = db_service.get_low_stock_products()
        db_service.close()
        
        return {
            "low_stock_count": len(low_stock),
            "products": low_stock
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/warehouse/products", tags=["Food Management"])
def get_all_products(db: Session = Depends(get_db)):
    """Get all products in the food management system"""
    try:
        db_service = DatabaseService()
        products = db_service.get_products()
        db_service.close()
        return products
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/warehouse/shipments", tags=["Food Management"])
def get_all_shipments(db: Session = Depends(get_db)):
    """Get all shipments/orders in the food management system"""
    try:
        db_service = DatabaseService()
        shipments = db_service.get_orders()
        db_service.close()
        return shipments
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/warehouse/product/{product_id}", tags=["Food Management"])
def get_product_details(product_id: int, db: Session = Depends(get_db)):
    """Get detailed information about a specific product"""
    try:
        db_service = DatabaseService()
        product = db_service.get_product_by_id(product_id)
        db_service.close()
        
        if not product:
            raise HTTPException(status_code=404, detail="Product not found")
        
        return product
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Additional API Endpoints
@app.get("/health", tags=["System"])
def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "timestamp": datetime.now().isoformat()}


