# 🏭 KasmiFood AI Management System

A comprehensive AI-powered food management platform combining a FastAPI backend with natural language processing and a modern Flutter mobile application. This system enables restaurant and food business owners to manage inventory, orders, and operations through intelligent conversational interfaces.

## 🌟 Project Overview

This project consists of three main components:

### 🤖 **AI Backend Agent** (`/backend`)
- FastAPI-based intelligent service powered by Groq's Mixtral/Llama3 LLMs
- Natural language understanding for food management queries
- Real-time database integration with MySQL
- RESTful API for all food management operations
- Advanced context-aware AI responses

### 📱 **Flutter Mobile App** (`/panel_ui`)
- Modern cross-platform mobile application
- Intuitive dashboard for food business management
- Real-time chat with AI assistant
- Order management and inventory tracking
- Responsive design optimized for mobile devices

### 🌐 **Web Panel** (Integrated in backend)
- Browser-based management interface
- Real-time statistics and analytics
- Interactive charts and reports
- Complete warehouse operations dashboard

## ✨ Key Features

### 🧠 **AI-Powered Intelligence**
- **Natural Language Processing**: Ask questions in plain English
- **Intent Recognition**: Understands food business queries automatically
- **Context-Aware Responses**: Provides intelligent insights based on real data
- **Multi-Language Support**: Groq LLM integration for advanced conversations

### 📊 **Food Management Operations**
- **Inventory Management**: Track stock levels, ingredients, and supplies
- **Order Processing**: Monitor order status from placement to delivery
- **Real-time Analytics**: Performance metrics and business insights
- **Low Stock Alerts**: Automatic notifications for reordering
- **Category Management**: Organize products by food categories

### 🔄 **Cross-Platform Accessibility**
- **Mobile App**: Native performance on iOS and Android
- **Web Interface**: Browser-based access for desktop users
- **API Integration**: RESTful endpoints for third-party integrations
- **Real-time Sync**: Data synchronization across all platforms

## 🚀 Quick Start Guide

### Prerequisites

#### For Backend:
- Python 3.8+
- MySQL Database
- use LLMs API Key

#### For Mobile App:
- Flutter SDK 3.0+
- Dart 3.0+
- Android Studio / Xcode (for device testing)

### 🔧 Installation & Setup

#### 1. **Backend Setup**

```bash
cd backend

python -m venv venv
source venv/bin/activate 

pip install -r requirements.txt

# Set up environment variables
cp .env.example .env

# Initialize database
python database_service.py

uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

**Backend will be available at:** `http://localhost:8000`  
**API Documentation:** `http://localhost:8000/docs`

#### 2. **Flutter Mobile App Setup**

```bash
cd panel_ui

flutter pub get

flutter run

Or

flutter build apk          # Android
flutter build ios          # iOS
flutter build web          # Web
```

#### 3. **Database Configuration**

The system uses MySQL for production and SQLite for development:

```sql
-- Create database (MySQL)
CREATE DATABASE kasmifood_admin;

-- Import initial schema
mysql -u username -p kasmifood_admin < database.sql
```

## 📡 API Endpoints

### Core AI Chat Interface
```http
POST /chat
POST /warehouse/query
```

### Food Management Operations
```http
GET  /warehouse/stats           # Business statistics
GET  /warehouse/products        # Product inventory
GET  /warehouse/low-stock       # Low stock alerts
GET  /warehouse/shipments       # Order tracking
GET  /warehouse/product/{id}    # Product details
```

### Health & System
```http
GET  /                         # Health check
GET  /health                   # System status
```

## 💬 Example Queries

The AI understands natural language queries like:

### 📦 **Inventory Management**
```
"What food items are running low on stock?"
"Show me today's inventory status"
"How many ingredients do we have for pizza?"
"What's the total value of our food inventory?"
```

### 🍽️ **Order & Kitchen Operations**
```
"What orders are ready for delivery?"
"Show me pending orders from today"
"Which meals are most popular this week?"
"How many orders are we processing right now?"
```

### 📊 **Business Analytics**
```
"Give me a summary of today's sales"
"What food categories are performing best?"
"Show me this week's performance metrics"
"Which ingredients need reordering urgently?"
```

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    KasmiFood AI System                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐    ┌──────────────┐    ┌───────────────┐   │
│  │   Flutter   │    │   FastAPI    │    │     MySQL     │   │
│  │  Mobile App │◄──►│   Backend    │◄──►│   Database    │   │
│  │             │    │              │    │               │   │
│  └─────────────┘    └──────────────┘    └───────────────┘   │
│                            │                                │
│                            ▼                                │
│                     ┌──────────────┐                        │
│                     │(OpenRouter)AI│                        │
│                     │   LLM API    │                        │
│                     └──────────────┘                        │
│                                                             │
├─────────────────────────────────────────────────────────────┤
│  Features: AI Chat • Inventory • Orders • Analytics         │
└─────────────────────────────────────────────────────────────┘
```

## 🗂️ Project Structure

```
kasmifood-ai-system/
├── 📁 backend/                    # AI Backend Service
│   ├── 🐍 main.py                # FastAPI application
│   ├── 🗄️ database_service.py    # Database operations
│   ├── 🧠 nlu_processor.py       # Natural Language Understanding
│   ├── 📊 warehouse_data.py      # Data simulation & management
│   ├── 🐳 Dockerfile             # Container configuration
│   ├── 📋 requirements.txt       # Python dependencies
│   ├── 🧪 test_*.py              # Test suites
│   └── 🌐 web_panel/             # Web interface
│
├── 📁 panel_ui/                   # Flutter Mobile App
│   ├── 📱 lib/
│   │   ├── 🏠 screens/           # App screens
│   │   ├── 🧩 widgets/           # UI components
│   │   ├── 🔄 providers/         # State management
│   │   ├── 🌐 services/          # API integration
│   │   └── 📊 models/            # Data models
│   │
│   ├── 🤖 android/               # Android configuration
│   ├── 🍎 ios/                   # iOS configuration
│   └── 📋 pubspec.yaml           # Flutter dependencies
│
└── 📚 README.md                   # This file
```

## 🎯 Core Components Details

### Backend Services

#### 🧠 **NLU Processor**
- Advanced intent detection for food industry queries
- Entity extraction (products, quantities, orders)
- Context-aware prompt generation for AI responses

#### 🗄️ **Database Service**
- MySQL integration with SQLAlchemy ORM
- Real-time inventory tracking
- Order management and history
- Business analytics and reporting

#### 🤖 **AI Integration**
- Groq LLM API integration (Mixtral/Llama3)
- Context-enriched prompts with real business data
- Intelligent response generation for food operations

### Mobile App Features

#### 📊 **Dashboard**
- Real-time business metrics
- Sales performance indicators
- Inventory status overview
- Quick action buttons

#### 💬 **AI Assistant**
- Natural language chat interface
- Voice input support
- Context-aware responses
- Quick query suggestions

#### 📦 **Inventory Management**
- Product listing with search/filter
- Stock level monitoring
- Category-based organization
- Low stock alerts

#### 🛍️ **Order Management**
- Order status tracking
- Delivery management
- Customer information
- Payment status monitoring

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the backend directory:

```env
# Groq AI Configuration
GROQ_API_KEY=your_groq_api_key_here

# Database Configuration
DB_HOST=localhost
DB_PORT=3306
DB_USER=your_db_user
DB_PASSWORD=your_db_password
DB_NAME=kasmifood_admin

# Application Settings
DEBUG=True
API_HOST=0.0.0.0
API_PORT=8000
```

### Flutter Configuration

Update the API base URL in `lib/services/warehouse_api_service.dart`:

```dart
static const String baseUrl = 'http://your-backend-url:8000';
```

## 🧪 Testing

### Backend Testing
```bash
cd backend

# Run all tests
python -m pytest

# Run specific test files
python test_agent.py
python test_db.py

# Test API endpoints
python examples.py
```

### Flutter Testing
```bash
cd panel_ui

# Run unit tests
flutter test

# Run integration tests
flutter drive --target=test_driver/app.dart
```


#### Manual Deployment
```bash
# Install production server
pip install gunicorn

# Run with Gunicorn
gunicorn main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
```

### Mobile App Deployment

#### Android
```bash
flutter build apk --release
# APK will be in build/app/outputs/flutter-apk/
```

#### iOS
```bash
flutter build ios --release
# Open ios/Runner.xcworkspace in Xcode for App Store deployment
```

#### Web
```bash
flutter build web --release
# Deploy the build/web folder to your web server
```

## 📊 Monitoring & Analytics

### System Health
- `/health` endpoint for service monitoring
- Database connection status
- API response time metrics
- Error rate tracking

### Business Metrics
- Order volume and revenue tracking
- Inventory turnover rates
- Popular product analytics
- Customer behavior insights

## 🔐 Security Features

- API key authentication for external integrations
- Input validation and sanitization
- SQL injection prevention with ORM
- CORS configuration for web security
- Rate limiting for API endpoints

## 🤝 Contributing

### Development Workflow
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make your changes and test thoroughly
4. Update documentation if needed
5. Submit a pull request with detailed description

### Code Standards
- **Backend**: Follow PEP 8 Python style guide
- **Frontend**: Follow Dart style conventions
- **Commits**: Use conventional commit messages
- **Testing**: Maintain test coverage above 80%



## 🎯 Future Roadmap

### 🔮 **Upcoming Features**
- [ ] Voice command integration
- [ ] Advanced analytics dashboard
- [ ] Multi-restaurant support
- [ ] Integration with POS systems
- [ ] Recipe management system
- [ ] Supplier integration portal
- [ ] Customer feedback system
- [ ] Advanced reporting tools

### 🌍 **Platform Expansion**
- [ ] Desktop application (Windows/macOS/Linux)
- [ ] Apple Watch companion app
- [ ] Web PWA version
- [ ] API marketplace integrations


### Common Issues
- **Connection Problems**: Ensure backend is running and accessible
- **Database Issues**: Check MySQL connection and credentials
- **Build Errors**: Verify Flutter/Python versions and dependencies

---

**🎉 Built with ❤️ by @r10xM for the food industry using FastAPI, Flutter, and AI innovation.**

*Transform your food business with intelligent automation and insights.*
