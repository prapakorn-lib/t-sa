# ข้อสอบปฏิบัติ Docker: ระบบจำหน่ายตั๋วคอนเสิร์ต
## Concert Ticket Sales System 
---

## ภาพรวมโครงการ

โปรเจคนี้เป็นข้อสอบปฏิบัติสำหรับทดสอบความสามารถในการใช้ Docker โดยสร้างระบบจำหน่ายตั๋วคอนเสิร์ต

### วัตถุประสงค์
1. ทดสอบความเข้าใจเกี่ยวกับ Docker และ Docker Compose
2. ทดสอบความเข้าใจเกี่ยวกับ Architecture
3. ประเมินระบบตาม Software Quality Attributes (Performance, Availability, Scalability)

---

## โครงสร้างโปรเจค

```
t-sa/
├── app/
│   ├── server.js              # Main application file
│   ├── package.json           # Node.js dependencies
│   ├── Dockerfile             # Docker image configuration
│   └── views/
│       └── index.ejs          # Frontend template
├── test-scripts/
│   ├── performance-test.sh    # Performance testing script
│   ├── availability-test.sh   # Availability testing script
│   ├── scalability-test.sh    # Scalability testing script
│   └── run-all-tests.sh       # Run all tests
├── docker-compose.yml         # Docker orchestration
├── assessment.md              # แบบประเมิน (ให้นักศึกษากรอก)
├── test-report.md             # แบบบันทึกผลการทดสอบ (ให้นักศึกษากรอก)
└── README.md                  # คู่มือนี้
```

---

## ความต้องการของระบบ (Prerequisites)

ต้องติดตั้งเพียง **Docker และ Docker Compose** เท่านั้น!

- **Docker Desktop** (version 20.10 หรือสูงกว่า) - [ดาวน์โหลด](https://www.docker.com/products/docker-desktop)
- **Docker Compose** (version 2.0 หรือสูงกว่า) - มากับ Docker Desktop

### ตรวจสอบการติดตั้ง

```bash
docker --version
docker-compose --version
```

---

## 🚀 วิธีใช้งาน (ง่ายมาก!)

**แค่เปิด Browser ไม่ต้องรันคำสั่งอะไรเลย!**

### Quick Start

```bash
# 1. เริ่มระบบ
docker-compose up -d

# 2. เปิด Browser ไปที่
http://localhost:3000/tests

# 3. กดปุ่ม "รันทดสอบทั้งหมด"
# 4. บันทึกผลลงใน test-report.md
```

**📖 อ่านคู่มือแบบย่อ: [QUICK-START.md](QUICK-START.md)**

---

## วิธีการอื่นๆ (สำหรับ Advanced Users)

หากต้องการรัน tests ผ่าน command line:
- **Docker method:** [SIMPLE-TEST-GUIDE.md](SIMPLE-TEST-GUIDE.md) - รันผ่าน Docker commands
- **Windows users:** [WINDOWS-GUIDE.md](WINDOWS-GUIDE.md) - PowerShell, Git Bash, WSL
- **Advanced Docker:** [DOCKER-TEST-GUIDE.md](DOCKER-TEST-GUIDE.md) - Docker Compose method

---

## วิธีการเริ่มต้น

### 1. Clone หรือ Download โปรเจค

```bash
git clone https://github.com/prapakorn-lib/t-sa.git
cd t-sa
```

### 2. เริ่มระบบด้วย Docker Compose

```bash
# Start all services
docker-compose up -d

# Check container status
docker-compose ps

# View logs
docker-compose logs -f
```

### 3. ตรวจสอบว่าระบบทำงาน

```bash
# Check health endpoint
curl http://localhost:3000/health

# Access the web application
# เปิด browser ไปที่: http://localhost:3000
```

### 4. หยุดระบบ

```bash
# Stop containers (keep data)
docker-compose down

# Stop containers and remove volumes (delete data)
docker-compose down -v
```

---

## API Endpoints

ระบบมี API endpoints ดังนี้:

### Health Check
```bash
GET /health
curl http://localhost:3000/health
```

### Get All Concerts
```bash
GET /api/concerts
curl http://localhost:3000/api/concerts
```

### Get Specific Concert
```bash
GET /api/concerts/:id
curl http://localhost:3000/api/concerts/1
```

### Create Booking
```bash
POST /api/bookings
curl -X POST http://localhost:3000/api/bookings \
  -H "Content-Type: application/json" \
  -d '{
    "concert_id": 1,
    "customer_name": "สมชาย ใจดี",
    "customer_email": "somchai@example.com",
    "num_tickets": 2
  }'
```

### Get All Bookings
```bash
GET /api/bookings
curl http://localhost:3000/api/bookings
```

---

## คำแนะนำในการทำข้อสอบ

### ขั้นตอนที่ 1: เรียนรู้และทำความเข้าใจระบบ

1. อ่านไฟล์ `docker-compose.yml` เพื่อเข้าใจสถาปัตยกรรม
2. อ่านไฟล์ `app/server.js` เพื่อเข้าใจการทำงานของแอปพลิเคชัน
3. ทดลองใช้งานระบบผ่าน Web Browser
4. ทดลองเรียก API ด้วย curl

### ขั้นตอนที่ 2: ตอบคำถามในแบบประเมิน

1. เปิดไฟล์ `assessment.md`
2. ตอบคำถามทั้งหมด 26 ข้อ
3. ตอบตามความเข้าใจของตนเอง อย่าคัดลอกจากเพื่อน

### ขั้นตอนที่ 3: ทดสอบระบบตาม Software Quality Attributes

**วิธีที่แนะนำ - ผ่าน Web Browser:**

1. เปิด Browser ไปที่ `http://localhost:3000/tests`
2. กดปุ่ม **"🚀 รันทดสอบทั้งหมด"** (หรือทดสอบทีละส่วน)
3. ดูผลการทดสอบที่แสดงบนหน้าเว็บ
4. บันทึกผลลงใน `test-report.md`

**สามารถดูผลการทดสอบแบบ JSON ได้ที่:**
- Performance: `http://localhost:3000/api/tests/performance`
- Availability: `http://localhost:3000/api/tests/availability`
- Scalability: `http://localhost:3000/api/tests/scalability`

**📖 ดูรายละเอียดเพิ่มเติม:** [QUICK-START.md](QUICK-START.md)

### ขั้นตอนที่ 4: วิเคราะห์และแก้ไขปัญหา

1. ดูผลการทดสอบที่ไม่ผ่าน
2. วิเคราะห์สาเหตุ
3. เสนอแนวทางแก้ไข
4. (Optional) แก้ไขโค้ดและทดสอบใหม่

### ขั้นตอนที่ 5: สรุปผลและส่งงาน

1. กรอกข้อมูลใน `test-report.md` ให้ครบถ้วน
2. ตรวจสอบว่าตอบคำถามทั้งหมดใน `assessment.md` แล้ว
3. ส่งไฟล์ทั้งสองพร้อมกัน

---

## คำสั่ง Docker ที่ใช้บ่อย

### Container Management

```bash
# List all containers
docker ps -a

# View container logs
docker logs concert-web
docker logs concert-db

# Execute command in container
docker exec -it concert-web sh
docker exec -it concert-db psql -U postgres -d concert_db

# Stop specific container
docker stop concert-web

# Restart container
docker restart concert-web

# Remove container
docker rm concert-web
```

### Image Management

```bash
# List images
docker images

# Build image
docker-compose build

# Remove unused images
docker image prune
```

### Network Management

```bash
# List networks
docker network ls

# Inspect network
docker network inspect t-sa_concert-network
```

### Volume Management

```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect t-sa_postgres-data

# Remove volume (WARNING: This deletes data!)
docker volume rm t-sa_postgres-data
```

---

## Software Quality Attributes

ระบบนี้ถูกออกแบบให้ทดสอบ 3 คุณลักษณะหลัก:

### 1. Performance (ประสิทธิภาพ)

**มาตรฐาน:**
- Health check API ต้องตอบกลับภายใน 500ms
- Concert API ต้องตอบกลับภายใน 1000ms
- รองรับ concurrent requests อย่างน้อย 10 requests

**การทดสอบ:**
- ใช้ `curl` วัด response time
- ทดสอบ concurrent requests ด้วย background processes

### 2. Availability (ความพร้อมใช้งาน)

**มาตรฐาน:**
- Container ต้องมี health check
- Container ต้อง restart อัตโนมัติเมื่อเกิดปัญหา
- Database ต้อง ready ก่อน web service

**การทดสอบ:**
- ตรวจสอบ health check status
- ทดสอบการ restart อัตโนมัติ
- ตรวจสอบ service dependencies

### 3. Scalability (ความสามารถในการขยายระบบ)

**มาตรฐาน:**
- สามารถ scale web service ได้
- Database connection pool รองรับหลาย connections
- ระบบรองรับ sustained load

**การทดสอบ:**
- ทดสอบการ scale ด้วย `docker-compose up -d --scale web=3`
- ทดสอบ concurrent database queries
- Load testing ด้วย 50 requests

---

## ปัญหาที่อาจพบและวิธีแก้ไข

### ปัญหา 1: Port Already in Use

**อาการ:** Error: bind: address already in use

**วิธีแก้:**
```bash
# หา process ที่ใช้ port 3000
sudo lsof -i :3000

# หยุด process หรือเปลี่ยน port ใน docker-compose.yml
```

### ปัญหา 2: Cannot Scale Web Service

**อาการ:** Error เมื่อ scale web service

**สาเหตุ:** Port mapping แบบ fixed (3000:3000) ไม่สามารถใช้กับหลาย containers

**วิธีแก้:**
- ลบ fixed port mapping หรือ
- ใช้ load balancer (nginx) หน้า web containers

### ปัญหา 3: Database Connection Failed

**อาการ:** Web service ไม่สามารถเชื่อมต่อ database

**วิธีแก้:**
```bash
# ตรวจสอบว่า DB container running
docker-compose ps

# ตรวจสอบ DB health
docker exec concert-db pg_isready -U postgres

# Restart services
docker-compose restart
```

### ปัญหา 4: Data Loss After Restart

**อาการ:** ข้อมูลหายหลัง restart

**สาเหตุ:** ใช้คำสั่ง `docker-compose down -v`

**วิธีแก้:**
- ใช้ `docker-compose down` (ไม่ใส่ -v)
- ตรวจสอบว่า volume ยังอยู่: `docker volume ls`

---

## เกณฑ์การให้คะแนน

### แบบประเมิน (assessment.md) - 65 คะแนน

- ส่วนที่ 1: สถาปัตยกรรม (25 คะแนน)
- ส่วนที่ 2: การทำงาน (20 คะแนน)
- ส่วนที่ 3: SQA (0 คะแนน - คะแนนอยู่ในการทดสอบจริง)
- ส่วนที่ 4: การทดสอบเพิ่มเติม (10 คะแนน)
- ส่วนที่ 5: คำสั่ง Docker (10 คะแนน)

### ผลการทดสอบจริง (test-report.md) - 35 คะแนน

- Performance Testing (10 คะแนน)
- Availability Testing (15 คะแนน)
- Scalability Testing (10 คะแนน)

**รวมทั้งหมด: 100 คะแนน**

---

## Tips สำหรับนักศึกษา

1. **อ่านโค้ดให้เข้าใจ:** อย่าเพิ่งรีบทดสอบ ให้อ่านโค้ดเพื่อเข้าใจการทำงานก่อน

2. **ทดสอบทีละขั้นตอน:** อย่ารันทุกอย่างพร้อมกัน ทดสอบทีละส่วน

3. **บันทึกผลอย่างละเอียด:** บันทึก screenshot, log, หรือ output ที่สำคัญ

4. **วิเคราะห์ปัญหา:** ถ้าไม่ผ่านการทดสอบ ให้หาสาเหตุและเสนอแนวทางแก้ไข

5. **ทดลองแก้ไข:** หากมีเวลา ลองแก้ไขปัญหาและทดสอบใหม่

6. **ใช้ Google/Documentation:** Docker docs และ Stack Overflow คือเพื่อนรัก

---

## Resources เพิ่มเติม

### Official Documentation
- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Express.js Documentation](https://expressjs.com/)

### Tutorials
- [Docker Tutorial for Beginners](https://docker-curriculum.com/)
- [Node.js with PostgreSQL](https://node-postgres.com/)

### Tools
- [Docker Desktop](https://www.docker.com/products/docker-desktop)
- [Postman](https://www.postman.com/) - สำหรับทดสอบ API
- [pgAdmin](https://www.pgadmin.org/) - สำหรับจัดการ PostgreSQL

---

## License

โปรเจคนี้ใช้สำหรับการศึกษาเท่านั้น

---

**หมายเหตุสำคัญ:**
- ห้ามคัดลอกคำตอบจากเพื่อน
- ต้องทำการทดสอบจริงและบันทึกผลจริง
- หากพบว่าคัดลอก จะได้ 0 คะแนน

**ขอให้โชคดีกับการสอบ!**
