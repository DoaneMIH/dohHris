# HRIS Mobile Application - API Quick Reference

## API Overview

**Base URL**: `http://192.168.79.55:8082`

**Authentication**: Bearer token in `Authorization` header

**Content-Type**: `application/json`

---

## Authentication Endpoints

### Login
```
POST /auth/login
```

**Request**:
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response (200)**:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "employee": {
    "id": "EMP001",
    "name": "John Doe",
    "email": "john.doe@company.com",
    "department": "HR"
  }
}
```

**Error (401)**:
```json
{
  "error": "Invalid credentials",
  "statusCode": 401
}
```

---

## User Profile Endpoints

### Get User Profile
```
GET /adminuser/get-profile
```

**Headers**:
```
Authorization: Bearer {token}
Content-Type: application/json
```

**Response (200)**:
```json
{
  "users": {
    "id": "EMP001",
    "employeeId": "EMP001",
    "name": "John Doe",
    "email": "john.doe@company.com",
    "phone": "+1-555-0123",
    "dateOfBirth": "1990-05-15",
    "gender": "Male",
    "address": "123 Main St",
    "position": "HR Manager",
    "department": "Human Resources",
    "startDate": "2020-01-15"
  }
}
```

---

### Update User Profile
```
POST /adminuser/update-employee/{employeeId}
```

**Path Parameters**:
- `{employeeId}` - Employee ID (e.g., "EMP001")

**Request Body**:
```json
{
  "name": "John Doe",
  "phone": "+1-555-0123",
  "address": "123 Main St, City",
  "dateOfBirth": "1990-05-15"
}
```

**Response (200)**:
```json
{
  "success": true,
  "message": "Profile updated successfully"
}
```

---

### Get Employee Photo
```
GET /employee/image/{photoId}
```

**Path Parameters**:
- `{photoId}` - Photo identifier or filename

**Response (200)**:
- Binary image data (JPEG/PNG)

**Error (404)**:
```json
{
  "error": "Image not found"
}
```

---

### Update Employee Photo
```
POST /adminuser/update-employee-photo/{employeeId}
```

**Path Parameters**:
- `{employeeId}` - Employee ID

**Request**:
- Content-Type: `multipart/form-data`
- Form field: `photo` (binary image file)

**Response (200)**:
```json
{
  "success": true,
  "photoUrl": "/employee/image/EMP001_photo.jpg"
}
```

---

## Daily Time Record Endpoints

### Get DTR Records
```
GET /adminuser/api/v1/dtr/{userId}
```

**Path Parameters**:
- `{userId}` - User/Employee ID

**Query Parameters** (Optional):
- `month` - Month (1-12)
- `year` - Year (e.g., 2024)

**Response (200)**:
```json
{
  "dtrRecords": [
    {
      "id": "DTR001",
      "employeeId": "EMP001",
      "date": "2024-02-21",
      "timeIn": "08:00:00",
      "timeOut": "17:00:00",
      "hoursWorked": 9.0,
      "status": "Present"
    },
    {
      "id": "DTR002",
      "employeeId": "EMP001",
      "date": "2024-02-22",
      "timeIn": "08:15:00",
      "timeOut": "17:30:00",
      "hoursWorked": 9.25,
      "status": "Present"
    }
  ]
}
```

---

## Family Background Endpoints

### Get All Family Members
```
GET /adminuser/family/get-all-family/{employeeId}
```

**Response (200)**:
```json
{
  "family": [
    {
      "id": "FAM001",
      "employeeId": "EMP001",
      "relationship": "Spouse",
      "name": "Jane Doe",
      "dateOfBirth": "1992-03-20",
      "occupation": "Teacher"
    },
    {
      "id": "FAM002",
      "employeeId": "EMP001",
      "relationship": "Child",
      "name": "Jack Doe",
      "dateOfBirth": "2015-07-10",
      "occupation": "Student"
    }
  ]
}
```

---

### Add Family Member
```
POST /adminuser/family/add-family/{employeeId}
```

**Request Body**:
```json
{
  "relationship": "Spouse",
  "name": "Jane Doe",
  "dateOfBirth": "1992-03-20",
  "occupation": "Teacher"
}
```

**Response (201)**:
```json
{
  "success": true,
  "familyId": "FAM003",
  "message": "Family member added successfully"
}
```

---

### Update Family Member
```
POST /adminuser/family/update-family/{familyId}
```

**Request Body**:
```json
{
  "relationship": "Spouse",
  "name": "Jane Doe",
  "dateOfBirth": "1992-03-20",
  "occupation": "Principal"
}
```

**Response (200)**:
```json
{
  "success": true,
  "message": "Family member updated successfully"
}
```

---

### Delete Family Member
```
DELETE /adminuser/family/delete-family/{familyId}
```

**Response (200)**:
```json
{
  "success": true,
  "message": "Family member deleted successfully"
}
```

---

## Education Endpoints

### Get All Education Records
```
GET /adminuser/education/get-all-education/{employeeId}
```

**Response (200)**:
```json
{
  "education": [
    {
      "id": "EDU001",
      "employeeId": "EMP001",
      "school": "State University",
      "degree": "Bachelor's Degree",
      "field": "Information Technology",
      "yearGraduated": 2012,
      "honors": "Magna Cum Laude"
    }
  ]
}
```

---

### Add Education Record
```
POST /adminuser/education/add-education/{employeeId}
```

**Request Body**:
```json
{
  "school": "State University",
  "degree": "Bachelor's Degree",
  "field": "Information Technology",
  "yearGraduated": 2012,
  "honors": "Magna Cum Laude"
}
```

**Response (201)**:
```json
{
  "success": true,
  "educationId": "EDU002",
  "message": "Education record added successfully"
}
```

---

### Update Education Record
```
POST /adminuser/education/update-education/{educationId}
```

**Request Body**:
```json
{
  "school": "State University",
  "degree": "Master's Degree",
  "field": "Computer Science",
  "yearGraduated": 2015,
  "honors": "Summa Cum Laude"
}
```

---

### Delete Education Record
```
DELETE /adminuser/education/delete-education/{educationId}
```

---

## Work Experience Endpoints

### Get All Work Experience
```
GET /adminuser/work-experience/get-all-work-experience/{employeeId}
```

**Response (200)**:
```json
{
  "workExperience": [
    {
      "id": "WEX001",
      "employeeId": "EMP001",
      "company": "Tech Corp",
      "position": "Junior Developer",
      "startDate": "2012-06-01",
      "endDate": "2015-05-31",
      "isPresent": false,
      "description": "Developed web applications"
    }
  ]
}
```

---

### Add Work Experience
```
POST /adminuser/work-experience/add-work-experience/{employeeId}
```

**Request Body**:
```json
{
  "company": "Tech Corp",
  "position": "Senior Developer",
  "startDate": "2015-06-01",
  "endDate": "2020-05-31",
  "isPresent": false,
  "description": "Led development team"
}
```

---

### Update Work Experience
```
POST /adminuser/work-experience/update-work-experience/{experienceId}
```

---

### Delete Work Experience
```
DELETE /adminuser/work-experience/delete-work-experience/{experienceId}
```

---

## Voluntary Work Endpoints

### Get All Voluntary Work
```
GET /adminuser/voluntary-work/get-all-voluntary-work/{employeeId}
```

**Response (200)**:
```json
{
  "voluntaryWork": [
    {
      "id": "VOL001",
      "employeeId": "EMP001",
      "organization": "Red Cross",
      "position": "Volunteer",
      "startDate": "2018-01-01",
      "endDate": "2020-12-31",
      "description": "Provided medical assistance"
    }
  ]
}
```

---

### Add Voluntary Work
```
POST /adminuser/voluntary-work/add-voluntary-work/{employeeId}
```

**Request Body**:
```json
{
  "organization": "Red Cross",
  "position": "Volunteer",
  "startDate": "2021-01-01",
  "endDate": "2023-12-31",
  "description": "Provided medical assistance"
}
```

---

### Update Voluntary Work
```
POST /adminuser/voluntary-work/update-voluntary-work/{voluntaryId}
```

---

### Delete Voluntary Work
```
DELETE /adminuser/voluntary-work/delete-voluntary-work/{voluntaryId}
```

---

## Learning & Development Endpoints

### Get All Learning Records
```
GET /adminuser/learn-dev/get-all-learn-dev/{employeeId}
```

**Response (200)**:
```json
{
  "learningDevelopment": [
    {
      "id": "LD001",
      "employeeId": "EMP001",
      "trainingTitle": "Advanced Flutter Development",
      "provider": "Tech Academy",
      "startDate": "2023-01-15",
      "endDate": "2023-06-30",
      "certificateObtained": true,
      "certificateNumber": "CERT-2023-001"
    }
  ]
}
```

---

### Add Learning Record
```
POST /adminuser/learn-dev/add-learn-dev/{employeeId}
```

**Request Body**:
```json
{
  "trainingTitle": "Advanced Flutter Development",
  "provider": "Tech Academy",
  "startDate": "2023-01-15",
  "endDate": "2023-06-30",
  "certificateObtained": true,
  "certificateNumber": "CERT-2023-001"
}
```

---

### Update Learning Record
```
POST /adminuser/learn-dev/update-learn-dev/{learningId}
```

---

### Delete Learning Record
```
DELETE /adminuser/learn-dev/delete-learn-dev/{learningId}
```

---

## Civil Service Eligibility Endpoints

### Get Civil Service Records
```
GET /adminuser/civil-service/get-all-civil-service/{employeeId}
```

### Add Civil Service Record
```
POST /adminuser/civil-service/add-civil-service/{employeeId}
```

### Update Civil Service Record
```
POST /adminuser/civil-service/update-civil-service/{serviceId}
```

### Delete Civil Service Record
```
DELETE /adminuser/civil-service/delete-civil-service/{serviceId}
```

---

## Personal Reference Endpoints

### Get All References
```
GET /adminuser/person-reference/get-all-person-reference/{employeeId}
```

### Add Reference
```
POST /adminuser/person-reference/add-person-reference/{employeeId}
```

### Update Reference
```
POST /adminuser/person-reference/update-person-reference/{referenceId}
```

### Delete Reference
```
DELETE /adminuser/person-reference/delete-person-reference/{referenceId}
```

---

## Error Codes

| Code | Meaning | Solution |
|------|---------|----------|
| 200 | OK | Request successful |
| 201 | Created | Resource created successfully |
| 204 | No Content | Successful but no content |
| 400 | Bad Request | Invalid request format |
| 401 | Unauthorized | Invalid or expired token |
| 403 | Forbidden | Not authorized for resource |
| 404 | Not Found | Resource not found |
| 500 | Server Error | Backend error |
| 503 | Unavailable | Service temporarily unavailable |

---

## Common Response Patterns

### Success Response
```json
{
  "success": true,
  "data": { /* response data */ },
  "message": "Operation successful"
}
```

### Error Response
```json
{
  "success": false,
  "error": "Error message",
  "statusCode": 400
}
```

### List Response
```json
{
  "success": true,
  "data": [
    { /* item 1 */ },
    { /* item 2 */ }
  ],
  "total": 2,
  "page": 1
}
```

---

## Testing API Endpoints

### Using cURL

```bash
# Login
curl -X POST http://192.168.79.55:8082/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123"
  }'

# Get User Profile
curl -X GET http://192.168.79.55:8082/adminuser/get-profile \
  -H "Authorization: Bearer TOKEN_HERE" \
  -H "Content-Type: application/json"

# Get DTR Records
curl -X GET "http://192.168.79.55:8082/adminuser/api/v1/dtr/EMP001" \
  -H "Authorization: Bearer TOKEN_HERE"
```

### Using Postman

1. Import the API endpoints
2. Set `{{base_url}}` variable: `http://192.168.79.55:8082`
3. Add `Authorization` header with Bearer token
4. Execute requests

---

## Performance Tips

1. **Cache token**: Store and reuse token
2. **Minimize requests**: Use pagination or filters
3. **Batch operations**: Group related updates
4. **Error handling**: Implement retry logic
5. **Timeout**: Set 30-second request timeout

---

**Last Updated**: February 25, 2026
**API Version**: v1
