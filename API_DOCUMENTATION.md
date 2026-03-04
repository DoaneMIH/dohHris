# API Documentation

## Overview

Complete reference for all REST API endpoints used by the HRIS Mobile Application. The API runs on `http://192.168.79.55:8082` (development).

---

## Base Configuration

```dart
Base URL: http://192.168.79.55:8082
Protocol: HTTP/REST
Content-Type: application/json
Auth: Bearer Token (JWT)
Timeout: 30 seconds
```

---

## Authentication Endpoints

### 1. Login

**Endpoint**: `POST /auth/login`

**Description**: Authenticate user with email and password

**Request**:
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response Success (200)**:
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs...",
    "user": {
      "id": 1,
      "email": "user@example.com",
      "first_name": "John",
      "last_name": "Doe"
    }
  },
  "message": "Login successful"
}
```

**Response Error (401)**:
```json
{
  "success": false,
  "error": "Invalid email or password"
}
```

**Dart Implementation**:
```dart
Future<Map<String, dynamic>> login(String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': email,
        'password': password,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {'success': true, 'data': data['data']};
    } else {
      return {'success': false, 'error': 'Login failed'};
    }
  } catch (e) {
    return {'success': false, 'error': e.toString()};
  }
}
```

---

### 2. Refresh Token

**Endpoint**: `POST /auth/refresh`

**Description**: Refresh expired JWT token

**Headers**:
```
Authorization: Bearer {token}
```

**Request**:
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response Success (200)**:
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIs..."
  }
}
```

**Response Error (401)**:
```json
{
  "success": false,
  "error": "Unauthorized"
}
```

---

### 3. Logout

**Endpoint**: `POST /auth/logout`

**Description**: Invalidate current token

**Headers**:
```
Authorization: Bearer {token}
```

**Response Success (200)**:
```json
{
  "success": true,
  "message": "Logged out successfully"
}
```

---

## User Endpoints

### 4. Get User Profile

**Endpoint**: `GET /users/profile`

**Description**: Fetch authenticated user's profile

**Headers**:
```
Authorization: Bearer {token}
```

**Response Success (200)**:
```json
{
  "success": true,
  "data": {
    "users": {
      "id": 1,
      "email": "user@example.com",
      "first_name": "John",
      "last_name": "Doe",
      "phone": "+63912345678",
      "birth_date": "1990-01-15",
      "gender": "Male",
      "address": "123 Main Street",
      "city": "Manila",
      "province": "Metro Manila",
      "postal_code": "1200",
      "country": "Philippines",
      "created_at": "2024-01-01T10:00:00Z",
      "updated_at": "2024-03-03T15:30:00Z"
    },
    "credentials": [
      {
        "id": 1,
        "type": "SSS",
        "value": "123456789",
        "issued_date": "2020-01-01",
        "expiry_date": "2030-01-01"
      }
    ],
    "address": {
      "street": "123 Main Street",
      "city": "Manila"
    },
    "family": {
      "spouse_name": "Jane Doe",
      "children_count": 2
    },
    "education": [
      {
        "level": "Bachelor's",
        "school": "University Name"
      }
    ],
    "employment": [
      {
        "title": "Software Developer",
        "company": "Company Name",
        "start_date": "2021-01-01"
      }
    ]
  }
}
```

---

### 5. Get User by ID

**Endpoint**: `GET /users/{id}`

**Description**: Fetch specific user's profile (admin only)

**Parameters**:
- `id` (integer, required): User ID

**Headers**:
```
Authorization: Bearer {token}
```

**Response**: Similar to Get User Profile

---

### 6. Update User Profile

**Endpoint**: `PUT /users/{id}`

**Description**: Update user profile information

**Parameters**:
- `id` (integer, required): User ID

**Headers**:
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request**:
```json
{
  "first_name": "John",
  "last_name": "Doe",
  "phone": "+63912345678",
  "address": "123 Main Street"
}
```

**Response Success (200)**:
```json
{
  "success": true,
  "data": {
    "id": 1,
    "first_name": "John",
    "last_name": "Doe",
    "updated_at": "2024-03-03T15:30:00Z"
  },
  "message": "Profile updated successfully"
}
```

---

### 7. Upload Profile Photo

**Endpoint**: `POST /users/photo`

**Description**: Upload or update profile photo

**Headers**:
```
Authorization: Bearer {token}
Content-Type: multipart/form-data
```

**Form Data**:
- `photo` (file, required): Image file (JPEG, PNG)
- `user_id` (integer, required): User ID

**Response Success (200)**:
```json
{
  "success": true,
  "data": {
    "photo_url": "/uploads/photos/user_1.jpg",
    "message": "Photo uploaded successfully"
  }
}
```

**Dart Implementation**:
```dart
Future<Map<String, dynamic>> uploadPhoto(File imageFile, String token) async {
  try {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}/users/photo'),
    );
    
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath(
      'photo',
      imageFile.path,
    ));
    
    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    
    if (response.statusCode == 200) {
      return {'success': true, 'data': json.decode(responseData)};
    }
    return {'success': false, 'error': 'Upload failed'};
  } catch (e) {
    return {'success': false, 'error': e.toString()};
  }
}
```

---

## DTR (Daily Time Record) Endpoints

### 8. Get DTR Records

**Endpoint**: `GET /dtr/records`

**Description**: Fetch user's DTR records

**Query Parameters**:
- `start_date` (string, optional): YYYY-MM-DD format
- `end_date` (string, optional): YYYY-MM-DD format
- `limit` (integer, optional): Default 50

**Headers**:
```
Authorization: Bearer {token}
```

**Response Success (200)**:
```json
{
  "success": true,
  "data": {
    "records": [
      {
        "id": 1,
        "user_id": 1,
        "date": "2024-03-03",
        "check_in_time": "08:00:00",
        "check_out_time": "17:00:00",
        "check_in_location": "Office",
        "check_out_location": "Office",
        "status": "Present",
        "remarks": ""
      }
    ],
    "total": 45,
    "page": 1,
    "per_page": 50
  }
}
```

---

### 9. Record Check-In

**Endpoint**: `POST /dtr/checkin`

**Description**: Record employee check-in time

**Headers**:
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request**:
```json
{
  "check_in_time": "08:00:00",
  "location": "Office",
  "latitude": 14.5753,
  "longitude": 121.0312
}
```

**Response Success (200)**:
```json
{
  "success": true,
  "data": {
    "id": 1,
    "date": "2024-03-03",
    "check_in_time": "08:00:00",
    "message": "Check-in recorded successfully"
  }
}
```

**Response Error (409)**:
```json
{
  "success": false,
  "error": "Already checked in today"
}
```

---

### 10. Record Check-Out

**Endpoint**: `POST /dtr/checkout`

**Description**: Record employee check-out time

**Headers**:
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Request**:
```json
{
  "check_out_time": "17:00:00",
  "location": "Office",
  "latitude": 14.5753,
  "longitude": 121.0312
}
```

**Response Success (200)**:
```json
{
  "success": true,
  "data": {
    "id": 1,
    "date": "2024-03-03",
    "check_out_time": "17:00:00",
    "message": "Check-out recorded successfully"
  }
}
```

---

## HTTP Status Codes

| Code | Meaning | Scenario |
|------|---------|----------|
| 200 | OK | Request successful |
| 201 | Created | Resource created |
| 400 | Bad Request | Invalid request data |
| 401 | Unauthorized | Missing/invalid token |
| 403 | Forbidden | Access denied |
| 404 | Not Found | Resource not found |
| 409 | Conflict | Duplicate record |
| 500 | Server Error | Server error |

---

## Error Response Format

All error responses follow this format:

```json
{
  "success": false,
  "error": "Error message",
  "code": "ERROR_CODE"
}
```

---

## Authentication

### Bearer Token

All endpoints (except login) require Bearer token authentication:

```
Authorization: Bearer <token>
```

### Token Refresh

Tokens expire after 5 minutes. Auto-refresh happens every 4 minutes:

```dart
// In TokenManager
Future<bool> _refreshToken() async {
  final response = await http.post(
    Uri.parse('${ApiConfig.baseUrl}${ApiConfig.refreshEndpoint}'),
    headers: {
      'Authorization': 'Bearer $_token',
      'Content-Type': 'application/json',
    },
    body: json.encode({
      'email': _email,
      'password': _password,
    }),
  );
  
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    _token = data['data']['token'];
    return true;
  }
  return false;
}
```

---

## Rate Limiting

- **Limit**: 100 requests per minute per user
- **Headers**: `X-RateLimit-Remaining: 99`
- **Exceeds**: Returns 429 (Too Many Requests)

---

## CORS Headers

```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization
```

---

## Testing API Endpoints

### Using cURL

```bash
# Login
curl -X POST http://192.168.79.55:8082/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"password123"}'

# Get Profile
curl -X GET http://192.168.79.55:8082/users/profile \
  -H "Authorization: Bearer <token>"

# Check In
curl -X POST http://192.168.79.55:8082/dtr/checkin \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"check_in_time":"08:00:00","location":"Office"}'
```

### Using Postman

1. Import collection into Postman
2. Set base URL: `http://192.168.79.55:8082`
3. Set Bearer token in Authorization tab
4. Test endpoints

---

## Next Steps

- Review [ARCHITECTURE.md](ARCHITECTURE.md) for system design
- Check [TROUBLESHOOTING_GUIDE.md](TROUBLESHOOTING_GUIDE.md) for API issues
- See [CODE_STYLE_GUIDE.md](CODE_STYLE_GUIDE.md) for implementation examples

---

**Document Version**: 1.0  
**Last Updated**: March 3, 2026  
**API Version**: 1.0
