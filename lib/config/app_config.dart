class AppConfig {
  // Replace with your computer's IP address where the backend is running
  // For example: 'http://192.168.1.100:3000'
  // To find your IP, run 'ipconfig' in Windows command prompt
  static const String baseUrl = 'http://192.168.0.145:3031'; // Your actual IP address with correct port
  // static const String baseUrl = 'http://localhost:3000'; // For web
  // static const String baseUrl = 'http://YOUR_IP_ADDRESS:3000'; // For physical device
  
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
} 