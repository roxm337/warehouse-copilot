import 'package:flutter/foundation.dart';
import '../models/warehouse_models.dart';
import '../services/warehouse_api_service.dart';

class ChatProvider with ChangeNotifier {
  // State variables
  List<ChatMessage> _messages = [];
  List<String> _errorMessages = [];
  bool _isLoading = false;
  String? _error;
  bool _isTyping = false;
  String _currentInput = '';

  // Getters
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isTyping => _isTyping;
  String get currentInput => _currentInput;
  
  bool get hasMessages => _messages.isNotEmpty;
  ChatMessage? get lastMessage => _messages.isNotEmpty ? _messages.last : null;
  bool get hasErrors => _errorMessages.isNotEmpty;

  // Initialize chat with welcome message
  void initialize() {
    if (_messages.isEmpty) {
      _addWelcomeMessage();
    }
  }

  // Send a message to the AI agent
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Clear any previous errors
    _clearError();

    // Add user message
    final userMessage = ChatMessage.user(message.trim());
    _addMessage(userMessage);
    _setTyping(true);

    try {
      // Send message to API
      final response = await WarehouseApiService.chatWithAgent(message.trim());
      
      // Add AI response
      final aiMessage = ChatMessage.ai(response.reply, analysis: response.queryAnalysis);
      _addMessage(aiMessage);
      
    } catch (e) {
      // Add error message and track it separately
      final errorMessage = ChatMessage.ai('Sorry, I encountered an error: ${e.toString()}');
      _addMessage(errorMessage);
      _errorMessages.add(e.toString());
      _setError('Failed to send message: ${e.toString()}');
    } finally {
      _setTyping(false);
    }
  }

  // Send a warehouse query (for natural language queries)
  Future<void> sendWarehouseQuery(String query) async {
    if (query.trim().isEmpty) return;

    _clearError();

    // Add user query
    final userMessage = ChatMessage.user(query.trim());
    _addMessage(userMessage);
    _setTyping(true);

    try {
      // Send query to warehouse API
      final response = await WarehouseApiService.warehouseQuery(query.trim());
      
      // Add AI response
      final aiMessage = ChatMessage.ai(response.reply, analysis: response.queryAnalysis);
      _addMessage(aiMessage);
      
    } catch (e) {
      // Add error message
      final errorMessage = ChatMessage.ai('Sorry, I couldn\'t process your warehouse query: ${e.toString()}');
      _addMessage(errorMessage);
      _errorMessages.add(e.toString());
      _setError('Failed to process query: ${e.toString()}');
    } finally {
      _setTyping(false);
    }
  }

  // Update current input (for typing indicators, etc.)
  void updateCurrentInput(String input) {
    _currentInput = input;
    notifyListeners();
  }

  // Clear current input
  void clearCurrentInput() {
    _currentInput = '';
    notifyListeners();
  }

  // Clear all messages
  void clearMessages() {
    _messages.clear();
    _errorMessages.clear();
    _clearError();
    _addWelcomeMessage();
  }

  // Clear specific message by ID
  void removeMessage(String messageId) {
    _messages.removeWhere((message) => message.id == messageId);
    notifyListeners();
  }

  // Retry last message
  Future<void> retryLastMessage() async {
    if (_messages.isEmpty) return;
    
    ChatMessage? lastUserMessage;
    for (int i = _messages.length - 1; i >= 0; i--) {
      if (_messages[i].isUser) {
        lastUserMessage = _messages[i];
        break;
      }
    }
    
    if (lastUserMessage != null) {
      // Remove the last AI response if it was an error
      if (_messages.last.content.startsWith('Sorry, I')) {
        _messages.removeLast();
      }
      
      await sendMessage(lastUserMessage.content);
    }
  }

  // Get suggested quick replies based on context
  List<String> getSuggestedReplies() {
    return [
      "Show me warehouse statistics",
      "What products are low in stock?",
      "Show recent shipments",
      "Find products in Electronics category",
      "What's the inventory value?",
      "Show delayed shipments",
      "Help me find a product",
    ];
  }

  // Get conversation summary
  String getConversationSummary() {
    if (_messages.isEmpty) return "No messages yet";
    
    final userMessages = _messages.where((m) => m.isUser).length;
    final aiMessages = _messages.where((m) => !m.isUser).length;
    final errorCount = _errorMessages.length;
    
    return "Messages: $userMessages user, $aiMessages AI" +
           (errorCount > 0 ? ", $errorCount errors" : "");
  }

  // Check if message is an error message
  bool isErrorMessage(ChatMessage message) {
    return !message.isUser && message.content.startsWith('Sorry, I');
  }

  // Private helper methods
  void _addMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }

  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage.ai(
      "👋 Hello! I'm your AI warehouse assistant. I can help you with:\n\n"
      "• Checking inventory levels and stock status\n"
      "• Finding products and categories\n"
      "• Tracking shipments and deliveries\n"
      "• Analyzing warehouse statistics\n"
      "• Answering questions about your warehouse operations\n\n"
      "Just ask me anything about your warehouse!"
    );
    
    _addMessage(welcomeMessage);
  }

  void _setTyping(bool typing) {
    _isTyping = typing;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Message formatting helpers
  String formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  // Export conversation (for debugging or sharing)
  Map<String, dynamic> exportConversation() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'messageCount': _messages.length,
      'messages': _messages.map((m) => {
        'id': m.id,
        'content': m.content,
        'isUser': m.isUser,
        'timestamp': m.timestamp.toIso8601String(),
        'queryAnalysis': m.queryAnalysis,
      }).toList(),
      'errors': _errorMessages,
    };
  }
}
