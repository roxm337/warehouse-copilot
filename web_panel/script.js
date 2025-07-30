// Warehouse Management Panel JavaScript

// Configuration
const API_BASE_URL = 'http://localhost:8000';
let currentData = {
    stats: null,
    products: [],
    shipments: [],
    lowStockProducts: []
};

// Quick queries mapping
const quickQueries = {
    'low_stock': 'What products are running low on stock and need immediate attention?',
    'warehouse_stats': 'Give me a comprehensive overview of our warehouse operations',
    'delayed_shipments': 'Show me all delayed shipments and their expected delivery dates',
    'inventory_value': 'What is our total inventory value and which categories are most valuable?',
    'categories': 'Break down our inventory by categories with stock levels',
    'reorder_suggestions': 'Which products should we reorder immediately to avoid stockouts?'
};

// Initialize the application
document.addEventListener('DOMContentLoaded', function() {
    console.log('🏭 Warehouse Management Panel Initialized');
    checkHealthAndLoadData();
    setupEventListeners();
});

// Setup event listeners
function setupEventListeners() {
    // Tab switching
    document.querySelectorAll('[data-bs-toggle="pill"]').forEach(tab => {
        tab.addEventListener('shown.bs.tab', function(event) {
            const targetId = event.target.getAttribute('data-bs-target');
            handleTabSwitch(targetId);
        });
    });

    // Auto-refresh every 30 seconds
    setInterval(refreshData, 30000);
}

// Handle tab switching
function handleTabSwitch(targetId) {
    switch(targetId) {
        case '#dashboard':
            loadDashboardData();
            break;
        case '#products':
            loadProductsData();
            break;
        case '#shipments':
            loadShipmentsData();
            break;
        case '#analytics':
            loadAnalyticsData();
            break;
    }
}

// API Functions
async function apiCall(endpoint, options = {}) {
    try {
        const response = await fetch(`${API_BASE_URL}${endpoint}`, {
            headers: {
                'Content-Type': 'application/json',
                ...options.headers
            },
            ...options
        });

        if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        return await response.json();
    } catch (error) {
        console.error('API call failed:', error);
        updateConnectionStatus(false);
        throw error;
    }
}

// Health check and initial data load
async function checkHealthAndLoadData() {
    try {
        showLoadingState();
        await apiCall('/');
        updateConnectionStatus(true);
        await loadAllData();
        hideLoadingState();
        showToast('Connected to warehouse system', 'success');
    } catch (error) {
        updateConnectionStatus(false);
        hideLoadingState();
        showToast('Failed to connect to warehouse system', 'error');
    }
}

// Load all data
async function loadAllData() {
    try {
        const [stats, lowStock] = await Promise.all([
            apiCall('/warehouse/stats'),
            apiCall('/warehouse/low-stock')
        ]);

        currentData.stats = stats;
        currentData.lowStockProducts = lowStock.products;

        updateStatsCards(stats);
        updateLowStockAlert(lowStock.products);
        updateCategoryBreakdown(stats.categories);
        updateLastUpdated();

    } catch (error) {
        console.error('Failed to load data:', error);
        showToast('Failed to load warehouse data', 'error');
    }
}

// Refresh data
async function refreshData() {
    console.log('🔄 Refreshing data...');
    await loadAllData();
}

// Update connection status
function updateConnectionStatus(connected) {
    const statusIcon = document.getElementById('status-icon');
    const statusText = document.getElementById('status-text');
    const statusContainer = document.getElementById('connection-status');

    if (connected) {
        statusIcon.className = 'fas fa-circle text-success';
        statusText.textContent = 'Connected';
        statusContainer.className = 'nav-link connected';
    } else {
        statusIcon.className = 'fas fa-circle text-danger';
        statusText.textContent = 'Disconnected';
        statusContainer.className = 'nav-link disconnected';
    }
}

// Update statistics cards
function updateStatsCards(stats) {
    document.getElementById('total-products').textContent = stats.total_products || '--';
    document.getElementById('low-stock-count').textContent = stats.low_stock_products || '--';
    document.getElementById('inventory-value').textContent = 
        stats.total_inventory_value ? `$${stats.total_inventory_value.toLocaleString()}` : '--';
    document.getElementById('avg-stock-level').textContent = 
        stats.average_stock_level ? Math.round(stats.average_stock_level) : '--';
}

// Update low stock alert
function updateLowStockAlert(products) {
    const container = document.getElementById('low-stock-products');
    
    if (!products || products.length === 0) {
        container.innerHTML = `
            <div class="text-center text-success">
                <i class="fas fa-check-circle me-2"></i>
                All products are well stocked!
        </div>`;
        return;
    }

    const html = `
        <div class="alert alert-warning">
            <strong>${products.length} products</strong> need immediate attention
        </div>
        <div class="list-group list-group-flush">
            ${products.slice(0, 5).map(product => `
                <div class="list-group-item d-flex justify-content-between align-items-center">
                    <div>
                        <strong>${product.name}</strong> (${product.id})
                        <br><small class="text-muted">Location: ${product.location}</small>
                    </div>
                    <span class="badge ${product.current_stock === 0 ? 'bg-danger' : 'bg-warning'}">
                        ${product.current_stock} units
                    </span>
                </div>
            `).join('')}
        </div>
        ${products.length > 5 ? `
            <div class="text-center mt-2">
                <small class="text-muted">and ${products.length - 5} more items...</small>
            </div>
        ` : ''}
    `;
    
    container.innerHTML = html;
}

// Update category breakdown
function updateCategoryBreakdown(categories) {
    const container = document.getElementById('category-breakdown');
    
    if (!categories || Object.keys(categories).length === 0) {
        container.innerHTML = '<div class="text-muted">No categories available</div>';
        return;
    }

    const html = Object.entries(categories).map(([category, count]) => `
        <div class="d-flex justify-content-between align-items-center mb-2">
            <span>${category}</span>
            <span class="badge bg-primary">${count}</span>
        </div>
    `).join('');
    
    container.innerHTML = html;
}

// Chat Functions
async function sendMessage() {
    const input = document.getElementById('chat-input');
    const message = input.value.trim();
    
    if (!message) return;
    
    input.value = '';
    addMessageToChat(message, true);
    
    const sendBtn = document.getElementById('send-btn');
    sendBtn.disabled = true;
    sendBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i>';
    
    try {
        const response = await apiCall('/chat', {
            method: 'POST',
            body: JSON.stringify({ message })
        });
        
        addMessageToChat(response.reply, false, response.query_analysis);
    } catch (error) {
        addMessageToChat('Sorry, I encountered an error processing your request. Please try again.', false);
        showToast('Failed to send message', 'error');
    } finally {
        sendBtn.disabled = false;
        sendBtn.innerHTML = '<i class="fas fa-paper-plane"></i>';
    }
}

// Send quick query
function sendQuickQuery(queryType) {
    const query = quickQueries[queryType];
    if (query) {
        document.getElementById('chat-input').value = query;
        sendMessage();
    }
}

// Add message to chat
function addMessageToChat(content, isUser, analysis = null) {
    const messagesContainer = document.getElementById('chat-messages');
    const messageDiv = document.createElement('div');
    messageDiv.className = `message ${isUser ? 'user-message' : 'ai-message'}`;
    
    let html = `
        <div class="message-content">
            ${isUser ? '<strong>You:</strong> ' : '<strong>AI Assistant:</strong> '}${content}
        </div>
        <div class="message-time">${new Date().toLocaleTimeString()}</div>
    `;
    
    if (analysis && !isUser) {
        html += `
            <div class="query-analysis">
                <span class="intent-badge">${analysis.intent}</span>
                <span class="confidence-score">Confidence: ${Math.round(analysis.confidence * 100)}%</span>
            </div>
        `;
    }
    
    messageDiv.innerHTML = html;
    messagesContainer.appendChild(messageDiv);
    messagesContainer.scrollTop = messagesContainer.scrollHeight;
}

// Handle chat input keypress
function handleChatKeyPress(event) {
    if (event.key === 'Enter') {
        sendMessage();
    }
}

// Clear chat
function clearChat() {
    const messagesContainer = document.getElementById('chat-messages');
    messagesContainer.innerHTML = `
        <div class="message ai-message">
            <div class="message-content">
                <strong>AI Assistant:</strong> Hello! I'm your intelligent warehouse management assistant. Ask me anything about your inventory, shipments, or warehouse operations!
            </div>
            <div class="message-time">Just now</div>
        </div>
    `;
}

// Load dashboard data
async function loadDashboardData() {
    // Dashboard data is loaded in loadAllData()
    console.log('📊 Dashboard data loaded');
}

// Load products data
async function loadProductsData() {
    try {
        const response = await apiCall('/warehouse/products');
        currentData.products = response.products;
        updateProductsTable(response.products);
        populateCategoryFilter();
    } catch (error) {
        console.error('Failed to load products:', error);
        showToast('Failed to load products', 'error');
    }
}

// Update products table
function updateProductsTable(products) {
    const tbody = document.getElementById('products-tbody');
    
    if (!products || products.length === 0) {
        tbody.innerHTML = '<tr><td colspan="8" class="text-center text-muted">No products found</td></tr>';
        return;
    }
    
    tbody.innerHTML = products.map(product => `
        <tr>
            <td><code>${product.id}</code></td>
            <td>${product.name}</td>
            <td><span class="badge bg-secondary">${product.category}</span></td>
            <td>${product.stock_level}</td>
            <td>${product.reorder_point}</td>
            <td>$${product.unit_price.toFixed(2)}</td>
            <td><code>${product.location}</code></td>
            <td>
                <span class="status-badge ${getStockStatusClass(product)}">
                    ${getStockStatus(product)}
                </span>
            </td>
        </tr>
    `).join('');
}

// Get stock status
function getStockStatus(product) {
    if (product.stock_level === 0) return 'Out of Stock';
    if (product.stock_level <= product.reorder_point) return 'Low Stock';
    return 'In Stock';
}

// Get stock status CSS class
function getStockStatusClass(product) {
    if (product.stock_level === 0) return 'status-out-of-stock';
    if (product.stock_level <= product.reorder_point) return 'status-low-stock';
    return 'status-in-stock';
}

// Populate category filter
function populateCategoryFilter() {
    const select = document.getElementById('category-filter');
    const categories = [...new Set(currentData.products.map(p => p.category))];
    
    select.innerHTML = '<option value="">All Categories</option>' +
        categories.map(cat => `<option value="${cat}">${cat}</option>`).join('');
}

// Filter products
function filterProducts() {
    const categoryFilter = document.getElementById('category-filter').value;
    let filteredProducts = currentData.products;
    
    if (categoryFilter) {
        filteredProducts = filteredProducts.filter(p => p.category === categoryFilter);
    }
    
    updateProductsTable(filteredProducts);
}

// Filter low stock products
function filterLowStock() {
    const lowStockProducts = currentData.products.filter(p => p.stock_level <= p.reorder_point);
    updateProductsTable(lowStockProducts);
}

// Load shipments data
async function loadShipmentsData() {
    try {
        const response = await apiCall('/warehouse/shipments');
        currentData.shipments = response.shipments;
        updateShipmentsTable(response.shipments);
    } catch (error) {
        console.error('Failed to load shipments:', error);
        showToast('Failed to load shipments', 'error');
    }
}

// Update shipments table
function updateShipmentsTable(shipments) {
    const tbody = document.getElementById('shipments-tbody');
    
    if (!shipments || shipments.length === 0) {
        tbody.innerHTML = '<tr><td colspan="8" class="text-center text-muted">No shipments found</td></tr>';
        return;
    }
    
    tbody.innerHTML = shipments.map(shipment => `
        <tr>
            <td><code>${shipment.id}</code></td>
            <td><code>${shipment.product_id}</code></td>
            <td>${shipment.quantity}</td>
            <td>
                <span class="status-badge status-${shipment.status}">
                    ${shipment.status.replace('_', ' ')}
                </span>
            </td>
            <td>${shipment.origin}</td>
            <td>${shipment.destination}</td>
            <td>${new Date(shipment.expected_date).toLocaleDateString()}</td>
            <td>${shipment.actual_date ? new Date(shipment.actual_date).toLocaleDateString() : '--'}</td>
        </tr>
    `).join('');
}

// Filter shipments
function filterShipments() {
    const statusFilter = document.getElementById('shipment-status-filter').value;
    let filteredShipments = currentData.shipments;
    
    if (statusFilter) {
        filteredShipments = filteredShipments.filter(s => s.status === statusFilter);
    }
    
    updateShipmentsTable(filteredShipments);
}

// Load analytics data
function loadAnalyticsData() {
    if (currentData.stats) {
        createCategoryChart();
        createShipmentChart();
        updatePerformanceMetrics();
    }
}

// Create category chart
function createCategoryChart() {
    const ctx = document.getElementById('category-chart').getContext('2d');
    const categories = currentData.stats.categories;
    
    new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: Object.keys(categories),
            datasets: [{
                data: Object.values(categories),
                backgroundColor: [
                    '#FF6384',
                    '#36A2EB',
                    '#FFCE56',
                    '#4BC0C0',
                    '#9966FF'
                ]
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    position: 'bottom'
                }
            }
        }
    });
}

// Create shipment chart
function createShipmentChart() {
    const ctx = document.getElementById('shipment-chart').getContext('2d');
    const statuses = currentData.stats.shipment_status;
    
    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: Object.keys(statuses).map(s => s.replace('_', ' ')),
            datasets: [{
                label: 'Shipments',
                data: Object.values(statuses),
                backgroundColor: '#36A2EB'
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    display: false
                }
            }
        }
    });
}

// Update performance metrics
function updatePerformanceMetrics() {
    const container = document.getElementById('performance-metrics');
    const stats = currentData.stats;
    
    const stockTurnoverRate = ((stats.total_products - stats.low_stock_products) / stats.total_products * 100).toFixed(1);
    const fulfillmentRate = 85.2; // This would come from real data
    const avgOrderValue = (stats.total_inventory_value / stats.total_products).toFixed(2);
    
    container.innerHTML = `
        <div class="row">
            <div class="col-md-4">
                <div class="metric-card">
                    <h4>${stockTurnoverRate}%</h4>
                    <p>Stock Availability Rate</p>
                    <div class="progress">
                        <div class="progress-bar bg-success" style="width: ${stockTurnoverRate}%"></div>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="metric-card">
                    <h4>${fulfillmentRate}%</h4>
                    <p>Order Fulfillment Rate</p>
                    <div class="progress">
                        <div class="progress-bar bg-primary" style="width: ${fulfillmentRate}%"></div>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="metric-card">
                    <h4>$${avgOrderValue}</h4>
                    <p>Average Product Value</p>
                    <div class="progress">
                        <div class="progress-bar bg-info" style="width: 75%"></div>
                    </div>
                </div>
            </div>
        </div>
    `;
}

// Generate report
function generateReport() {
    const reportData = {
        timestamp: new Date().toISOString(),
        stats: currentData.stats,
        low_stock_products: currentData.lowStockProducts,
        total_products: currentData.products.length,
        total_shipments: currentData.shipments.length
    };
    
    const blob = new Blob([JSON.stringify(reportData, null, 2)], {
        type: 'application/json'
    });
    
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `warehouse-report-${new Date().toISOString().split('T')[0]}.json`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
    
    showToast('Report downloaded successfully', 'success');
}

// Utility Functions
function updateLastUpdated() {
    document.getElementById('last-updated').textContent = 
        `Last updated: ${new Date().toLocaleTimeString()}`;
}

function showLoadingState() {
    document.body.classList.add('loading');
}

function hideLoadingState() {
    document.body.classList.remove('loading');
}

function showToast(message, type = 'info') {
    const toastContainer = document.getElementById('toast-container');
    const toastId = 'toast-' + Date.now();
    
    const toastHtml = `
        <div class="toast toast-${type}" id="${toastId}" role="alert">
            <div class="toast-header">
                <i class="fas fa-${getToastIcon(type)} me-2"></i>
                <strong class="me-auto">Warehouse System</strong>
                <small>just now</small>
                <button type="button" class="btn-close" data-bs-dismiss="toast"></button>
            </div>
            <div class="toast-body">
                ${message}
            </div>
        </div>
    `;
    
    toastContainer.insertAdjacentHTML('beforeend', toastHtml);
    
    const toastElement = document.getElementById(toastId);
    const toast = new bootstrap.Toast(toastElement);
    toast.show();
    
    // Remove toast element after it's hidden
    toastElement.addEventListener('hidden.bs.toast', () => {
        toastElement.remove();
    });
}

function getToastIcon(type) {
    switch(type) {
        case 'success': return 'check-circle';
        case 'error': return 'exclamation-circle';
        case 'warning': return 'exclamation-triangle';
        default: return 'info-circle';
    }
}

// Add some CSS for metric cards
const style = document.createElement('style');
style.textContent = `
    .metric-card {
        background: white;
        padding: 1.5rem;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        text-align: center;
        margin-bottom: 1rem;
    }
    .metric-card h4 {
        font-size: 2rem;
        font-weight: bold;
        margin-bottom: 0.5rem;
        color: #2196F3;
    }
    .metric-card p {
        margin-bottom: 1rem;
        color: #6c757d;
    }
    .progress {
        height: 6px;
        border-radius: 3px;
    }
`;
document.head.appendChild(style);

console.log('✅ Warehouse Management Panel JavaScript loaded successfully');
