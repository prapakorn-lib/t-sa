# Quick Start Guide - Concert Ticket System

## วิธีการใช้งานแบบง่ายที่สุด (แนะนำ!)

### ขั้นตอนที่ 1: เริ่มระบบ

```bash
docker-compose up -d
```

รอประมาณ 30 วินาที จนกว่า containers จะพร้อม

### ขั้นตอนที่ 2: เปิด Browser

**1. ทดสอบว่าระบบพร้อม:**
```
http://localhost:8347
```

**2. เข้าหน้าทดสอบ Software Quality:**
```
http://localhost:8347/tests
```

### ขั้นตอนที่ 3: รันการทดสอบ

1. **กดปุ่ม "🚀 รันทดสอบทั้งหมด"** (หรือรันทีละส่วน)
2. **รอผลการทดสอบ** (จะแสดงเป็น ✅ ผ่าน หรือ ❌ ไม่ผ่าน)
3. **บันทึกผล** ลงใน `test-report.md`

### ขั้นตอนที่ 4: ตอบคำถาม

เปิดไฟล์ `assessment.md` และตอบคำถามทั้งหมด 26 ข้อ

---

## การทดสอบแต่ละส่วน

### 1. Performance Testing (ประสิทธิภาพ)
- Health Check Response Time (< 500ms)
- Concerts API Response Time (< 1000ms)
- Concurrent Requests Handling (≥ 10 requests)

### 2. Availability Testing (ความพร้อมใช้งาน)
- Health Endpoint Check
- Database Connection
- Container Health Status

### 3. Scalability Testing (ความสามารถในการขยายระบบ)
- Database Connection Pool (20 concurrent queries)
- Sustained Load Test (50 requests)
- Container Scaling Information

---

## API Endpoints (สำหรับทดสอบเอง)

### Test APIs
```bash
# Performance Test
curl http://localhost:8347/api/tests/performance

# Availability Test
curl http://localhost:8347/api/tests/availability

# Scalability Test
curl http://localhost:8347/api/tests/scalability
```

### Application APIs
```bash
# Health Check
curl http://localhost:8347/health

# Get all concerts
curl http://localhost:8347/api/concerts

# Get specific concert
curl http://localhost:8347/api/concerts/1

# Create booking
curl -X POST http://localhost:8347/api/bookings \
  -H "Content-Type: application/json" \
  -d '{
    "concert_id": 1,
    "customer_name": "สมชาย ใจดี",
    "customer_email": "somchai@example.com",
    "num_tickets": 2
  }'

# Get all bookings
curl http://localhost:8347/api/bookings
```

---

## คำสั่ง Docker ที่ใช้บ่อย

```bash
# เริ่มระบบ
docker-compose up -d

# ดู logs
docker-compose logs -f

# ตรวจสอบสถานะ containers
docker-compose ps

# หยุดระบบ
docker-compose down

# หยุดและลบ data ทั้งหมด
docker-compose down -v

# Restart ระบบ
docker-compose restart

# Rebuild images
docker-compose build
```

---

## Troubleshooting

### ปัญหา: เข้า http://localhost:8347 ไม่ได้

**แก้ไข:**
1. ตรวจสอบว่า containers รันอยู่: `docker-compose ps`
2. ดู logs: `docker-compose logs web`
3. Restart: `docker-compose restart`

### ปัญหา: Database connection error

**แก้ไข:**
1. ตรวจสอบว่า db container healthy: `docker-compose ps`
2. รอให้ database พร้อม (30 วินาที)
3. Restart: `docker-compose restart web`

### ปัญหา: Port 3000 ถูกใช้อยู่

**แก้ไข:**
```bash
# หา process ที่ใช้ port 8347
# Windows:
netstat -ano | findstr :3000

# Mac/Linux:
lsof -i :3000

# Kill process หรือเปลี่ยน port ใน docker-compose.yml
```

---

## สรุปสั้นๆ สำหรับนักศึกษา

1. `docker-compose up -d` → เริ่มระบบ
2. เปิด Browser → `http://localhost:8347/tests`
3. กดปุ่ม "รันทดสอบทั้งหมด"
4. บันทึกผลใน `test-report.md`
5. ตอบคำถามใน `assessment.md`
6. เสร็จแล้ว!

**ไม่ต้องรันคำสั่งอะไรเพิ่ม - ทำผ่าน Web Browser ทั้งหมด!** 🎉
