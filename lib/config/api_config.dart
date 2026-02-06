class ApiConfig {
  // Update this to your actual backend URL
  static const String baseUrl = 'http://10.0.2.2:8082';
  // static const String baseUrl = 'http://localhost:8082';
  
  static const String loginEndpoint = '/auth/login';
  static const String getUserEndpoint = '/adminuser/get-profile';
  static const String getEmployeeEndpoint = '/admin/get-user';
  static const String getEmployeePhoto = '/employee/image';
  static const String dtrEndpoint = '/adminuser/api/v1/dtr';
  static const String updateEmployeePhotoEndpoint = '/adminuser/update-employee-photo/';
  static const String updateUserEndpoint = '/adminuser/employees/service-records/update-record/';
 
}