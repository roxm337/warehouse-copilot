from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import requests
import os
from dotenv import load_dotenv
from typing import Optional, List, Dict, Any
import logging
from datetime import datetime

# Import our custom modules
from warehouse_data import warehouse_db, Product, Shipment
from nlu_processor import nlu_processor, QueryIntent

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

load_dotenv()
GROQ_API_KEY = os.getenv("GROQ_API_KEY")

app = FastAPI(
    title="Intelligent Warehouse Management Agent",
    description="AI-powered warehouse management system with natural language interface",
    version="1.0.0"
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

@app.get("/", tags=["Health"])
def read_root():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "Intelligent Warehouse Management Agent",
        "version": "1.0.0",
        "timestamp": datetime.now()
    }

@app.post("/chat", response_model=APIResponse, tags=["AI Agent"])
def chat_with_warehouse_agent(message: Message):
    """
    Main chat endpoint for warehouse management queries.
    Accepts natural language input and provides intelligent responses.
    """
    try:
        # Analyze the user query
        query_analysis = nlu_processor.analyze_query(message.message)
        logger.info(f"Query analysis: {query_analysis}")
        
        # Generate context-aware system prompt
        context_prompt = nlu_processor.generate_context_prompt(query_analysis, warehouse_db)
        
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
        
        return APIResponse(
            reply=reply,
            query_analysis=query_analysis
        )
        
    except Exception as e:
        logger.error(f"Error in chat endpoint: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Service error: {str(e)}")

@app.post("/warehouse/query", response_model=APIResponse, tags=["Warehouse"])
def advanced_warehouse_query(warehouse_query: WarehouseQuery):
    """
    Advanced warehouse query endpoint with detailed analysis
    """
    try:
        # Analyze the query
        analysis = nlu_processor.analyze_query(warehouse_query.query)
        
        # Generate response based on intent
        if analysis['intent'] == QueryIntent.WAREHOUSE_STATS:
            stats = warehouse_db.get_warehouse_stats()
            response_text = f"Here's your warehouse overview: {stats}"
        elif analysis['intent'] == QueryIntent.LOW_STOCK:
            low_stock = warehouse_db.get_low_stock_products()
            response_text = f"Low stock alert: {len(low_stock)} products need attention"
        else:
            # Use LLM for complex queries
            context_prompt = nlu_processor.generate_context_prompt(analysis, warehouse_db)
            
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
        
        return APIResponse(
            reply=response_text,
            query_analysis=analysis if warehouse_query.include_context else None
        )
        
    except Exception as e:
        logger.error(f"Error in warehouse query endpoint: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Query processing error: {str(e)}")

@app.get("/warehouse/stats", tags=["Warehouse"])
def get_warehouse_statistics():
    """Get comprehensive warehouse statistics"""
    try:
        return warehouse_db.get_warehouse_stats()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/warehouse/low-stock", tags=["Warehouse"])
def get_low_stock_products():
    """Get products with stock levels below reorder point"""
    try:
        low_stock = warehouse_db.get_low_stock_products()
        return {
            "low_stock_count": len(low_stock),
            "products": [
                {
                    "id": p.id,
                    "name": p.name,
                    "current_stock": p.stock_level,
                    "reorder_point": p.reorder_point,
                    "location": p.location
                } for p in low_stock
            ]
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/warehouse/products", tags=["Warehouse"])
def get_products(
    category: Optional[str] = Query(None, description="Filter by category"),
    low_stock_only: bool = Query(False, description="Show only low stock products")
):
    """Get warehouse products with optional filters"""
    try:
        if low_stock_only:
            products = warehouse_db.get_low_stock_products()
        elif category:
            products = warehouse_db.get_products_by_category(category)
        else:
            products = warehouse_db.products
        
        return {
            "total_count": len(products),
            "products": [
                {
                    "id": p.id,
                    "name": p.name,
                    "category": p.category,
                    "stock_level": p.stock_level,
                    "unit_price": p.unit_price,
                    "location": p.location,
                    "supplier": p.supplier
                } for p in products
            ]
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/warehouse/shipments", tags=["Warehouse"])
def get_shipments(status: Optional[str] = Query(None, description="Filter by status")):
    """Get warehouse shipments with optional status filter"""
    try:
        if status:
            shipments = warehouse_db.get_shipments_by_status(status)
        else:
            shipments = warehouse_db.shipments
        
        return {
            "total_count": len(shipments),
            "shipments": [
                {
                    "id": s.id,
                    "product_id": s.product_id,
                    "quantity": s.quantity,
                    "status": s.status,
                    "origin": s.origin,
                    "destination": s.destination,
                    "expected_date": s.expected_date.isoformat(),
                    "actual_date": s.actual_date.isoformat() if s.actual_date else None
                } for s in shipments
            ]
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/warehouse/product/{product_id}", tags=["Warehouse"])
def get_product_details(product_id: str):
    """Get detailed information about a specific product"""
    try:
        product = warehouse_db.get_product_by_id(product_id.upper())
        if not product:
            raise HTTPException(status_code=404, detail="Product not found")
        
        return {
            "id": product.id,
            "name": product.name,
            "category": product.category,
            "stock_level": product.stock_level,
            "reorder_point": product.reorder_point,
            "unit_price": product.unit_price,
            "location": product.location,
            "supplier": product.supplier,
            "total_value": product.stock_level * product.unit_price,
            "needs_reorder": product.stock_level <= product.reorder_point
        }
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

