# 🏭 Intelligent Warehouse Management Agent

A FastAPI-based intelligent service that powers an AI agent for warehouse management. It interfaces with Groq's high-performance **Mixtral-8x7B** LLM to understand natural language inputs and generate intelligent, context-aware responses.

This backend enables warehouse managers to interact with warehouse data using plain English, ask operational questions, retrieve statistical reports, and receive decision-making support — without needing a graphical interface.

## ⚙️ Key Features

### 🧠 Natural Language Understanding (NLU)
- Accepts natural language queries and uses advanced LLM to interpret and respond accordingly
- Intent detection and entity extraction from user queries
- Context-aware prompt generation for improved responses

### 📊 Warehouse Data Access
- Simulates comprehensive inventory and shipment data
- Real-time access to product information, stock levels, and locations
- Shipment tracking and status monitoring

### 🎯 Smart Inference
- Contextualizes user queries with live data
- Passes enriched context as system prompts to the LLM
- Generates human-like, meaningful replies with warehouse-specific insights

### 🔌 REST API Interface
- Complete RESTful API for warehouse operations
- Multiple endpoints for different types of queries
- CORS support for web application integration

## 🚀 Quick Start

### Prerequisites
- Python 3.8+
- Groq API Key

### Installation

1. **Clone and navigate to the project:**
```bash
cd fastapi_groq_agent
```

2. **Create and activate virtual environment:**
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. **Install dependencies:**
```bash
pip install -r requirements.txt
```

4. **Set up environment variables:**
Create a `.env` file with your Groq API key:
```env
GROQ_API_KEY=your_groq_api_key_here
```

5. **Run the application:**
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at: `http://localhost:8000`
Interactive API docs: `http://localhost:8000/docs`

## 📡 API Endpoints

### Core Chat Interface
- **POST `/chat`** - Main chat interface for natural language warehouse queries
- **POST `/warehouse/query`** - Advanced warehouse query with detailed analysis

### Warehouse Data Access
- **GET `/warehouse/stats`** - Get comprehensive warehouse statistics
- **GET `/warehouse/low-stock`** - Get products below reorder point
- **GET `/warehouse/products`** - Get products with optional filters
- **GET `/warehouse/shipments`** - Get shipments with optional status filter
- **GET `/warehouse/product/{product_id}`** - Get detailed product information

### Health Check
- **GET `/`** - Health check and service information

## 💬 Example Queries

The system understands natural language queries like:

### Inventory Management
```
"What products are running low on stock?"
"Show me the current inventory status"
"How many electronics do we have in stock?"
"What's the total value of our inventory?"
```

### Product Information
```
"Tell me about product PRD-0001"
"Where is product PRD-0025 located?"
"What's the price of product PRD-0015?"
```

### Shipment Tracking
```
"What shipments are delayed?"
"Show me all pending deliveries"
"When will shipment SHP-0010 arrive?"
```

### Analytics & Reports
```
"Give me a warehouse summary"
"What categories do we stock?"
"Show me performance statistics"
"Which products need reordering?"
```

## 🏗️ Architecture

### Core Components

1. **`main.py`** - FastAPI application with all endpoints
2. **`warehouse_data.py`** - Data simulation and warehouse operations
3. **`nlu_processor.py`** - Natural language understanding and intent detection
4. **`requirements.txt`** - Python dependencies

### Data Models

- **Product**: ID, name, category, stock level, reorder point, price, location, supplier
- **Shipment**: ID, product ID, quantity, status, origin, destination, dates
- **Query Analysis**: Intent detection, entity extraction, confidence scoring

### NLU System

The system includes sophisticated natural language understanding:
- **Intent Detection**: Identifies query type (inventory, shipments, stats, etc.)
- **Entity Extraction**: Extracts product IDs, categories, statuses, numbers
- **Context Generation**: Creates relevant prompts for the LLM

## 🧪 Sample Data

The system includes simulated data:
- **50 sample products** across 5 categories
- **30 sample shipments** with various statuses
- **Realistic warehouse locations** and supplier information
- **Dynamic stock levels** and pricing

## 🔧 Configuration

### Environment Variables
```env
GROQ_API_KEY=your_groq_api_key_here
```

### Model Configuration
- **Primary Model**: `mixtral-8x7b-32768`
- **Temperature**: 0.7 (chat), 0.5 (warehouse queries)
- **Max Tokens**: 1000 (chat), 800 (warehouse queries)

## 📊 Response Format

### Chat Response
```json
{
  "reply": "AI generated response",
  "query_analysis": {
    "intent": "inventory_status",
    "entities": {"product_id": "PRD-0001"},
    "original_query": "user query",
    "confidence": 0.85
  },
  "timestamp": "2025-01-30T12:00:00"
}
```

### Warehouse Stats Response
```json
{
  "total_products": 50,
  "low_stock_products": 8,
  "total_inventory_value": 125432.50,
  "categories": {"Electronics": 12, "Clothing": 10},
  "shipment_status": {"delivered": 15, "in_transit": 8},
  "average_stock_level": 167.5
}
```


