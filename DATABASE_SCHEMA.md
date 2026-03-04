# Database Schema Documentation

## Overview

This document describes the database schema used by the HRIS Mobile Application backend. The backend uses PostgreSQL/MySQL relational database.

---

## Database Design Principles

1. **Normalization**: Third Normal Form (3NF)
2. **Relationships**: Foreign keys for referential integrity
3. **Constraints**: NOT NULL, UNIQUE, CHECK constraints
4. **Indexes**: Optimized for frequent queries
5. **Audit Trail**: created_at, updated_at timestamps

---

## Entity Relationship Diagram

```
┌─────────────┐         ┌──────────────────┐
│   Users     │◄────────┤ Auth_Logs        │
├─────────────┤         └──────────────────┘
│ id (PK)     │
│ email       │         ┌──────────────────┐
│ password    │◄────────┤ DTR_Records      │
│ first_name  │         └──────────────────┘
│ last_name   │
│ phone       │         ┌──────────────────┐
│ gender      │◄────────┤ User_Credentials │
│ birth_date  │         └──────────────────┘
│ created_at  │
│ updated_at  │         ┌──────────────────┐
└─────────────┘◄────────┤ User_Photos      │
                        └──────────────────┘

                        ┌──────────────────┐
              ┌────────►│ Family_Members   │
              │         └──────────────────┘
              │
              │         ┌──────────────────┐
              ├────────►│ Education_Records│
              │         └──────────────────┘
              │
              │         ┌──────────────────┐
              └────────►│ Work_Experience  │
                        └──────────────────┘
```

---

## Table: Users

**Purpose**: Core user information

```sql
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  phone VARCHAR(20),
  gender ENUM('Male', 'Female', 'Other'),
  birth_date DATE,
  
  -- Address
  street_address VARCHAR(255),
  city VARCHAR(100),
  province VARCHAR(100),
  postal_code VARCHAR(10),
  country VARCHAR(100),
  
  -- Status
  is_active BOOLEAN DEFAULT true,
  email_verified BOOLEAN DEFAULT false,
  last_login_at TIMESTAMP,
  
  -- Audit
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_email (email),
  INDEX idx_created_at (created_at)
);
```

**Fields Description**:
- `id`: Auto-incrementing primary key
- `email`: Unique email for login
- `password`: Hashed password (never store plaintext)
- `first_name`, `last_name`: User's name
- `phone`: Contact number
- `gender`: M/F/Other
- `birth_date`: Date of birth
- `is_active`: Account status
- `email_verified`: Email verification status
- `last_login_at`: Last successful login

---

## Table: User_Credentials

**Purpose**: Government and official IDs

```sql
CREATE TABLE user_credentials (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL,
  credential_type VARCHAR(100),
  
  -- Types: SSS, TIN, PHILHEALTH, PAGIBIG, DRIVER_LICENSE, PASSPORT
  
  credential_value VARCHAR(255) NOT NULL,
  issued_date DATE,
  expiry_date DATE,
  issuing_authority VARCHAR(255),
  
  -- Audit
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id),
  INDEX idx_credential_type (credential_type)
);
```

**Credential Types**:
- SSS (Social Security System)
- TIN (Tax Identification Number)
- PHILHEALTH (Health Insurance)
- PAGIBIG (Housing Benefit)
- DRIVER_LICENSE
- PASSPORT
- BIRTH_CERTIFICATE

---

## Table: User_Photos

**Purpose**: Store profile photo metadata

```sql
CREATE TABLE user_photos (
  id SERIAL PRIMARY KEY,
  user_id INTEGER UNIQUE NOT NULL,
  photo_path VARCHAR(500) NOT NULL,
  file_name VARCHAR(255),
  file_size INTEGER,
  upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id)
);
```

---

## Table: DTR_Records

**Purpose**: Daily Time Record entries

```sql
CREATE TABLE dtr_records (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL,
  record_date DATE NOT NULL,
  
  -- Check-in
  check_in_time TIME,
  check_in_location VARCHAR(255),
  check_in_latitude DECIMAL(10, 8),
  check_in_longitude DECIMAL(11, 8),
  
  -- Check-out
  check_out_time TIME,
  check_out_location VARCHAR(255),
  check_out_latitude DECIMAL(10, 8),
  check_out_longitude DECIMAL(11, 8),
  
  -- Status
  status ENUM('Present', 'Absent', 'Late', 'Incomplete') DEFAULT 'Incomplete',
  remarks TEXT,
  
  -- Audit
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  UNIQUE KEY unique_user_date (user_id, record_date),
  INDEX idx_user_id (user_id),
  INDEX idx_record_date (record_date)
);
```

**Status Values**:
- `Present`: Checked in and out on time
- `Absent`: No check-in recorded
- `Late`: Checked in after scheduled time
- `Incomplete`: Only check-in or Check-out recorded

---

## Table: Authentication_Logs

**Purpose**: Track authentication events

```sql
CREATE TABLE authentication_logs (
  id SERIAL PRIMARY KEY,
  user_id INTEGER,
  email VARCHAR(255),
  
  -- Event type
  event_type ENUM('LOGIN', 'LOGOUT', 'LOGIN_FAILED', 'PASSWORD_CHANGE', 'TOKEN_REFRESH'),
  
  -- Details
  ip_address VARCHAR(50),
  user_agent TEXT,
  status ENUM('Success', 'Failed'),
  error_message TEXT,
  
  -- Audit
  logged_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
  INDEX idx_user_id (user_id),
  INDEX idx_logged_at (logged_at),
  INDEX idx_email (email)
);
```

---

## Table: Family_Members

**Purpose**: Employee family information

```sql
CREATE TABLE family_members (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL,
  relationship VARCHAR(50),
  
  -- Relationship: Spouse, Child, Parent, Sibling, Other
  
  first_name VARCHAR(100) NOT NULL,
  last_name VARCHAR(100) NOT NULL,
  birth_date DATE,
  contact_number VARCHAR(20),
  
  -- Audit
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id)
);
```

---

## Table: Education_Records

**Purpose**: Employee education background

```sql
CREATE TABLE education_records (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL,
  
  -- Level: Elementary, High School, Bachelor, Master, Doctoral
  education_level VARCHAR(50),
  
  school_name VARCHAR(255) NOT NULL,
  school_location VARCHAR(255),
  course_field VARCHAR(100),
  year_completed INTEGER,
  honors_received TEXT,
  
  -- Audit
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id)
);
```

---

## Table: Work_Experience

**Purpose**: Employment history

```sql
CREATE TABLE work_experience (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL,
  
  job_title VARCHAR(255) NOT NULL,
  company_name VARCHAR(255) NOT NULL,
  company_location VARCHAR(255),
  industry VARCHAR(100),
  
  -- Dates
  start_date DATE NOT NULL,
  end_date DATE,
  is_current BOOLEAN DEFAULT false,
  
  responsibilities TEXT,
  supervisor_name VARCHAR(255),
  
  -- Audit
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id)
);
```

---

## Table: Skills

**Purpose**: Employee skills and certifications

```sql
CREATE TABLE skills (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL,
  
  skill_name VARCHAR(255) NOT NULL,
  proficiency_level ENUM('Beginner', 'Intermediate', 'Advanced', 'Expert'),
  years_of_experience INTEGER,
  
  -- Certification
  certification_name VARCHAR(255),
  certification_date DATE,
  certification_expiry DATE,
  issuing_organization VARCHAR(255),
  
  -- Audit
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id)
);
```

---

## Sample Data

### Users Table
```json
{
  "id": 1,
  "email": "john.doe@company.com",
  "first_name": "John",
  "last_name": "Doe",
  "phone": "+63912345678",
  "birth_date": "1990-01-15",
  "city": "Manila",
  "province": "Metro Manila",
  "is_active": true,
  "created_at": "2024-01-01T10:00:00Z"
}
```

### DTR_Records Table
```json
{
  "id": 1,
  "user_id": 1,
  "record_date": "2024-03-03",
  "check_in_time": "08:00:00",
  "check_in_location": "Office",
  "check_out_time": "17:00:00",
  "check_out_location": "Office",
  "status": "Present",
  "created_at": "2024-03-03T08:00:00Z"
}
```

---

## Indexing Strategy

### Primary Indexes
```sql
-- User lookups
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at);

-- DTR queries
CREATE INDEX idx_dtr_user_date ON dtr_records(user_id, record_date);
CREATE INDEX idx_dtr_date_range ON dtr_records(record_date);

-- Credential lookups
CREATE INDEX idx_cred_user ON user_credentials(user_id);

-- Log searches
CREATE INDEX idx_auth_logs_user ON authentication_logs(user_id);
CREATE INDEX idx_auth_logs_date ON authentication_logs(logged_at);
```

---

## Backup & Recovery

### Backup Strategy
```bash
# Daily backup at 2 AM
0 2 * * * mysqldump -u root -p$MYSQL_PASSWORD hris_db > backup_$(date +%Y%m%d).sql

# Upload to cloud storage
0 3 * * * aws s3 cp backup_*.sql s3://hris-backups/
```

### Recovery Procedure
```bash
# Restore from backup
mysql -u root -p$MYSQL_PASSWORD hris_db < backup_20240303.sql

# Verify integrity
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM dtr_records;
```

---

## Performance Considerations

### Query Optimization
1. **Index Regularly Used Columns**: email, user_id, record_date
2. **Use Composite Indexes**: (user_id, record_date) for DTR
3. **Archive Old Records**: Move records > 2 years to archive table
4. **Connection Pooling**: Use 10-20 database connections

### Monitoring
```sql
-- Check slow queries
SELECT * FROM mysql.slow_log;

-- Monitor table sizes
SELECT table_name, ROUND(((data_length + index_length) / 1024), 2) AS size_kb
FROM information_schema.TABLES
WHERE table_schema = 'hris_db';

-- Check query performance
EXPLAIN SELECT * FROM users WHERE email = 'user@example.com';
```

---

## Migration Strategy

### Adding New Column
```sql
ALTER TABLE users
ADD COLUMN department VARCHAR(100) DEFAULT 'General';

-- Verify
DESCRIBE users;
```

### Creating New Table
```sql
CREATE TABLE departments (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE users
ADD COLUMN department_id INTEGER,
ADD FOREIGN KEY (department_id) REFERENCES departments(id);
```

---

## Data Privacy

### PII Protection
- Encrypt sensitive data at rest
- Use HTTPS for transmission
- Hash passwords with bcrypt
- Audit all access to personal data
- GDPR compliance for data retention

### Data Retention
- Active users: Keep indefinitely
- Inactive users: 2 years
- DTR records: 3 years
- Auth logs: 1 year
- Deleted user data: Permanent deletion after 30 days

---

## Next Steps

- Review [API_DOCUMENTATION.md](API_DOCUMENTATION.md) for API endpoints
- Check [SECURITY_GUIDELINES.md](SECURITY_GUIDELINES.md) for data security
- See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for database setup

---

**Document Version**: 1.0  
**Last Updated**: March 3, 2026  
**Database Version**: PostgreSQL 12+/MySQL 8.0+
