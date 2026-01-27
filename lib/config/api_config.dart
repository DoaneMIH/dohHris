class ApiConfig {
  // Update this to your actual backend URL
  static const String baseUrl = 'http://localhost:8082';
  
  static const String loginEndpoint = '/auth/login';
  static const String getUserEndpoint = '/adminuser/get-profile';
  static const String getEmployeeEndpoint = '/admin/get-user';
  static const String refreshTokenEndpoint = '/auth/refresh-token';
  static const String getEmployeePhoto = '/employee/image';
 
}