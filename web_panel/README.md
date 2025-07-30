# 🌐 Intelligent Warehouse Management Web Panel

A modern, responsive web interface for the Intelligent Warehouse Management Agent built with HTML5, CSS3, and JavaScript. This web panel provides a complete dashboard for managing warehouse operations through natural language interactions.

## ✨ Features

### 🏠 **Dashboard Overview**
- Real-time warehouse statistics
- Low stock alerts with visual indicators
- Category breakdown charts
- Connection status monitoring
- Auto-refresh every 30 seconds

### 🤖 **AI Assistant Chat**
- Natural language conversations with the warehouse AI
- Quick query buttons for common operations
- Query analysis display (intent detection, confidence scores)
- Chat history with timestamps
- Real-time message processing

### 📦 **Products Management**
- Complete product listing with search and filters
- Category-based filtering
- Low stock product filtering
- Stock status indicators
- Product details with locations and suppliers

### 🚚 **Shipments Tracking**
- Real-time shipment status monitoring
- Status-based filtering (pending, in transit, delivered, delayed)
- Expected vs actual delivery dates
- Visual status badges

### 📊 **Analytics & Reports**
- Interactive charts (category distribution, shipment status)
- Performance metrics with progress bars
- Exportable JSON reports
- Visual data representation

## 🚀 Quick Start

### Prerequisites
- FastAPI warehouse agent running on `http://localhost:8000`
- Modern web browser (Chrome, Firefox, Safari, Edge)
- Python 3.6+ (for the development server)

### Installation & Setup

1. **Navigate to the web panel directory:**
```bash
cd web_panel
```

2. **Start the web server:**
```bash
python serve.py
```
   
   Or specify a custom port:
```bash
python serve.py 8080
```

3. **Open your browser:**
   The server will automatically open `http://localhost:3000` in your default browser.

4. **Ensure FastAPI backend is running:**
   Make sure your warehouse management API is running on `http://localhost:8000`

## 🎨 Interface Components

### Navigation Sidebar
- **Dashboard**: Overview with key metrics and alerts
- **AI Assistant**: Chat interface for natural language queries
- **Products**: Product management and inventory tracking  
- **Shipments**: Shipment tracking and status monitoring
- **Analytics**: Charts, reports, and performance metrics

### Statistics Cards
- **Total Products**: Current product count
- **Low Stock Items**: Products needing attention
- **Inventory Value**: Total monetary value of inventory
- **Average Stock Level**: Mean stock level across all products

### AI Chat Features
- **Quick Queries**: Pre-defined buttons for common questions
- **Query Analysis**: Shows detected intent and confidence
- **Real-time Responses**: Instant AI responses from the backend
- **Chat History**: Persistent conversation history

## 🔧 Configuration

### API Endpoint
The web panel connects to the FastAPI backend at `http://localhost:8000`. To change this:

1. Edit `script.js`
2. Modify the `API_BASE_URL` constant:
```javascript
const API_BASE_URL = 'http://your-api-server:port';
```

### Auto-refresh Interval
By default, data refreshes every 30 seconds. To change this:

1. Edit `script.js`
2. Modify the interval in the `setupEventListeners()` function:
```javascript
setInterval(refreshData, 60000); // 60 seconds
```

## 💬 Sample Queries

Try these natural language queries in the AI Assistant:

### Inventory Management
- "What products are running low on stock?"
- "Show me all electronics in inventory"
- "What's our total inventory value?"
- "Which products need reordering immediately?"

### Shipment Tracking
- "What shipments are delayed?"
- "Show me all pending deliveries"
- "How many shipments are in transit?"

### Analytics
- "Give me a warehouse summary report"
- "What categories have the most products?"
- "Show me performance statistics"

## 🎯 Features in Detail

### Real-time Updates
- Automatic data refresh every 30 seconds
- Connection status indicator
- Live chat responses
- Dynamic table updates

### Responsive Design
- Mobile-friendly interface
- Bootstrap-based responsive layout
- Touch-friendly controls
- Adaptive navigation

### Visual Indicators
- Color-coded status badges
- Progress bars for metrics
- Interactive charts
- Loading states and animations

### User Experience
- Toast notifications for actions
- Smooth animations and transitions
- Intuitive navigation
- Error handling with user feedback

## 🛠️ Technical Details

### Technologies Used
- **Frontend**: HTML5, CSS3, JavaScript (ES6+)
- **CSS Framework**: Bootstrap 5.1.3
- **Icons**: Font Awesome 6.0.0
- **Charts**: Chart.js
- **Server**: Python HTTP server

### Browser Compatibility
- Chrome 70+
- Firefox 65+
- Safari 12+
- Edge 79+

### Performance Features
- Lazy loading for large datasets
- Optimized API calls
- Efficient DOM updates
- Minimal external dependencies

## 📱 Mobile Experience

The web panel is fully responsive and optimized for mobile devices:
- Touch-friendly interface
- Responsive navigation
- Optimized chat interface
- Mobile-optimized tables

## 🔍 Troubleshooting

### Common Issues

**1. "Failed to connect to warehouse system"**
- Ensure FastAPI server is running on `http://localhost:8000`
- Check CORS settings in FastAPI
- Verify network connectivity

**2. "Chat not responding"**
- Check Groq API key configuration
- Verify FastAPI server logs
- Ensure proper API endpoints

**3. "Data not loading"**
- Refresh the page
- Check browser console for errors
- Verify API endpoints are accessible

### Debug Mode
Open browser Developer Tools (F12) to see:
- Network requests to API
- JavaScript console logs
- Error messages and stack traces

## 🚀 Production Deployment

### Using a Production Server

For production use, replace the Python development server with a proper web server:

**Nginx Configuration:**
```nginx
server {
    listen 80;
    server_name your-domain.com;
    root /path/to/web_panel;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

**Apache Configuration:**
```apache
<VirtualHost *:80>
    DocumentRoot /path/to/web_panel
    ServerName your-domain.com
    
    <Directory /path/to/web_panel>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

### Docker Deployment
```dockerfile
FROM nginx:alpine
COPY . /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

## 🤝 Contributing

To contribute to the web panel:

1. Fork the repository
2. Make your changes in the `web_panel` directory
3. Test with the FastAPI backend
4. Submit a pull request

## 📄 License

This web panel is part of the Intelligent Warehouse Management System and follows the same MIT License.

---

**🎉 Enjoy managing your warehouse with AI-powered intelligence!**
