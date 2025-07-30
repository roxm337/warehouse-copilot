"""
Natural Language Understanding module for warehouse queries
This module analyzes user queries and determines intent and extracts relevant information
"""

import re
from typing import Dict, List, Any, Optional
from enum import Enum

class QueryIntent(Enum):
    INVENTORY_STATUS = "inventory_status"
    LOW_STOCK = "low_stock"
    SHIPMENT_STATUS = "shipment_status"
    PRODUCT_INFO = "product_info"
    WAREHOUSE_STATS = "warehouse_stats"
    CATEGORY_QUERY = "category_query"
    REORDER_SUGGESTIONS = "reorder_suggestions"
    GENERAL_HELP = "general_help"
    UNKNOWN = "unknown"

class NLUProcessor:
    def __init__(self):
        self.intent_patterns = {
            QueryIntent.INVENTORY_STATUS: [
                r"inventory|stock level|how much.*stock|stock status",
                r"how many.*in stock|available.*quantity",
                r"check.*inventory|inventory.*report"
            ],
            QueryIntent.LOW_STOCK: [
                r"low stock|running low|need.*reorder|below.*reorder",
                r"stock alert|inventory alert|critical.*stock",
                r"need.*replenish|urgent.*stock"
            ],
            QueryIntent.SHIPMENT_STATUS: [
                r"shipment|shipping|delivery|ship.*status",
                r"track.*order|order.*status|delivery.*status",
                r"when.*arrive|expected.*delivery"
            ],
            QueryIntent.PRODUCT_INFO: [
                r"product.*detail|info.*product|tell me about",
                r"price.*product|cost.*item|product.*price",
                r"where.*located|location.*product"
            ],
            QueryIntent.WAREHOUSE_STATS: [
                r"warehouse.*report|overall.*status|summary",
                r"statistics|stats|performance|overview",
                r"total.*value|inventory.*value|worth"
            ],
            QueryIntent.CATEGORY_QUERY: [
                r"category|type.*product|products.*in.*category",
                r"electronics|clothing|books|sports|home.*garden",
                r"what.*categories|list.*categories"
            ],
            QueryIntent.REORDER_SUGGESTIONS: [
                r"reorder|replenish|order.*more|need.*order",
                r"suggestion.*restock|recommend.*order",
                r"what.*should.*order"
            ],
            QueryIntent.GENERAL_HELP: [
                r"help|what.*can.*do|commands|options",
                r"how.*use|guide|assistance"
            ]
        }
        
        self.category_mapping = {
            "electronics": "Electronics",
            "clothing": "Clothing",
            "fashion": "Clothing",
            "books": "Books",
            "sports": "Sports",
            "home": "Home & Garden",
            "garden": "Home & Garden"
        }
    
    def analyze_query(self, query: str) -> Dict[str, Any]:
        """
        Analyze user query and extract intent and entities
        """
        query = query.lower().strip()
        
        intent = self._detect_intent(query)
        entities = self._extract_entities(query, intent)
        
        return {
            "intent": intent,
            "entities": entities,
            "original_query": query,
            "confidence": self._calculate_confidence(query, intent)
        }
    
    def _detect_intent(self, query: str) -> QueryIntent:
        """Detect the intent of the user query"""
        for intent, patterns in self.intent_patterns.items():
            for pattern in patterns:
                if re.search(pattern, query, re.IGNORECASE):
                    return intent
        return QueryIntent.UNKNOWN
    
    def _extract_entities(self, query: str, intent: QueryIntent) -> Dict[str, Any]:
        """Extract relevant entities based on the detected intent"""
        entities = {}
        
        # Extract product ID
        product_id_match = re.search(r'prd-?\d{4}', query, re.IGNORECASE)
        if product_id_match:
            entities['product_id'] = product_id_match.group().upper().replace('-', '-') if '-' not in product_id_match.group() else product_id_match.group().upper()
        
        # Extract shipment ID
        shipment_id_match = re.search(r'shp-?\d{4}', query, re.IGNORECASE)
        if shipment_id_match:
            entities['shipment_id'] = shipment_id_match.group().upper().replace('-', '-') if '-' not in shipment_id_match.group() else shipment_id_match.group().upper()
        
        # Extract category
        for key, value in self.category_mapping.items():
            if key in query:
                entities['category'] = value
                break
        
        # Extract status keywords
        status_keywords = ['pending', 'in_transit', 'delivered', 'delayed', 'urgent', 'critical']
        for status in status_keywords:
            if status in query:
                entities['status'] = status
                break
        
        # Extract numbers
        numbers = re.findall(r'\d+', query)
        if numbers:
            entities['numbers'] = [int(n) for n in numbers]
        
        return entities
    
    def _calculate_confidence(self, query: str, intent: QueryIntent) -> float:
        """Calculate confidence score for the detected intent"""
        if intent == QueryIntent.UNKNOWN:
            return 0.0
        
        patterns = self.intent_patterns.get(intent, [])
        max_matches = 0
        
        for pattern in patterns:
            matches = len(re.findall(pattern, query, re.IGNORECASE))
            max_matches = max(max_matches, matches)
        
        return min(0.9, max_matches * 0.3 + 0.6) if max_matches > 0 else 0.5
    
    def generate_context_prompt(self, analysis: Dict[str, Any], warehouse_data: Any) -> str:
        """Generate context-aware prompt for the LLM based on query analysis"""
        intent = analysis['intent']
        entities = analysis['entities']
        
        context = "You are an intelligent warehouse management assistant. "
        
        if intent == QueryIntent.INVENTORY_STATUS:
            if 'product_id' in entities:
                product = warehouse_data.get_product_by_id(entities['product_id'])
                if product:
                    context += f"The user is asking about product {product.name} (ID: {product.id}). Current stock: {product.stock_level}, Location: {product.location}, Reorder point: {product.reorder_point}. "
        
        elif intent == QueryIntent.LOW_STOCK:
            low_stock = warehouse_data.get_low_stock_products()
            context += f"There are currently {len(low_stock)} products with low stock levels. "
            if low_stock:
                context += "Low stock products: " + ", ".join([f"{p.name} ({p.stock_level} units)" for p in low_stock[:5]])
        
        elif intent == QueryIntent.WAREHOUSE_STATS:
            stats = warehouse_data.get_warehouse_stats()
            context += f"Current warehouse statistics: {stats['total_products']} total products, {stats['low_stock_products']} low stock items, total inventory value: ${stats['total_inventory_value']}, average stock level: {stats['average_stock_level']}. "
        
        elif intent == QueryIntent.CATEGORY_QUERY:
            if 'category' in entities:
                products = warehouse_data.get_products_by_category(entities['category'])
                context += f"Found {len(products)} products in {entities['category']} category. "
        
        elif intent == QueryIntent.SHIPMENT_STATUS:
            if 'status' in entities:
                shipments = warehouse_data.get_shipments_by_status(entities['status'])
                context += f"There are {len(shipments)} shipments with {entities['status']} status. "
        
        context += "Provide helpful, accurate information based on the warehouse data and respond in a professional but friendly manner."
        
        return context

# Global NLU processor instance
nlu_processor = NLUProcessor()
