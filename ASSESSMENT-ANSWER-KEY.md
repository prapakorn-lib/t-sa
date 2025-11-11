# เฉลยแบบประเมินข้อสอบปฏิบัติ Docker
## ระบบจำหน่ายตั๋วคอนเสิร์ต (Concert Ticket Sales System)

**⚠️ เอกสารนี้สำหรับอาจารย์/ผู้สอนเท่านั้น - ห้ามแจกจ่ายให้นักศึกษา**

---

## ส่วนที่ 1: ความเข้าใจเกี่ยวกับสถาปัตยกรรมระบบ (Architecture Understanding)

### คำถาม 1.1: ชนิดของสถาปัตยกรรม

**1. ระบบนี้ใช้สถาปัตยกรรมแบบใด?**

**เฉลย:** ✅ 2-tier Architecture

**อธิบาย:** ระบบแบ่งเป็น 2 ชั้นคือ
- Tier 1: Application Layer (Web + Business Logic) - Node.js/Express
- Tier 2: Data Layer - PostgreSQL Database

---

**2. อธิบายความแตกต่างระหว่าง 2-tier และ 3-tier Architecture พร้อมยกตัวอย่าง**

**เฉลย:**

**2-tier Architecture:**
- แบ่งระบบเป็น 2 ชั้น: Presentation + Business Logic รวมกัน (Tier 1) และ Data Layer (Tier 2)
- Business Logic อยู่กับ Application Layer
- ตัวอย่าง: ระบบนี้ที่ใช้ Node.js/Express (รวม UI + Business Logic) + PostgreSQL (Database)
- ข้อดี: ง่ายต่อการพัฒนา, จัดการน้อยกว่า
- ข้อเสีย: ยากต่อการ scale แยกส่วน

**3-tier Architecture:**
- แบ่งระบบเป็น 3 ชั้น: Presentation Layer (Tier 1), Business Logic Layer (Tier 2), Data Layer (Tier 3)
- แต่ละชั้นแยกออกจากกันอย่างชัดเจน
- ตัวอย่าง: React/Vue.js (Frontend) + Node.js API (Backend) + PostgreSQL (Database)
- ข้อดี: Scale ได้แยกส่วน, แก้ไขส่วนใดส่วนหนึ่งได้โดยไม่กระทบส่วนอื่น
- ข้อเสีย: ซับซ้อนกว่า, ต้องจัดการหลาย service

**คะแนน:** 5 คะแนน (ให้คะแนนเต็มถ้าอธิบายความแตกต่างได้ชัดเจนและยกตัวอย่างได้ถูกต้อง)

---

**3. ระบุ tier ต่างๆ ในระบบนี้ และบอกบทบาทของแต่ละ tier**

**เฉลย:**

- **Tier 1:** Application Layer (Web Service Container)
  - **บทบาท:** รับ HTTP requests, ประมวลผล business logic, render HTML views (EJS), เชื่อมต่อกับ database, ส่ง responses กลับไปยัง client

- **Tier 2:** Data Layer (Database Container)
  - **บทบาท:** จัดเก็บข้อมูลถาวร (concerts, bookings), รับคำสั่ง SQL queries, จัดการ transactions, รักษาความสมบูรณ์ของข้อมูล (data integrity)

**คะแนน:** 5 คะแนน (อธิบายบทบาทได้ถูกต้องและครบถ้วน)

---

**4. หากต้องการเปลี่ยนเป็น 3-tier Architecture จะต้องแยก tier ไหนออกมา และเพราะเหตุใด?**

**เฉลย:**

ต้องแยก **Tier 1 (Application Layer)** ออกเป็น 2 ส่วน:

**แยกเป็น:**
1. **Presentation Layer (Frontend)** - SPA เช่น React, Vue.js, Angular
   - รับผิดชอบเฉพาะ UI/UX
   - ส่ง HTTP requests ไปยัง API

2. **Business Logic Layer (Backend API)** - Node.js REST API
   - รับผิดชอบ business logic, data validation
   - เชื่อมต่อกับ Database
   - ส่ง JSON responses

3. **Data Layer (Database)** - PostgreSQL (เหมือนเดิม)

**เหตุผล:**
- **Separation of Concerns:** แยกหน้าที่ให้ชัดเจน, ง่ายต่อการ maintain
- **Scalability:** Scale Frontend และ Backend แยกกันได้ตามความต้องการ
- **Development:** ทีม Frontend และ Backend ทำงานแยกกันได้
- **Reusability:** Backend API สามารถใช้กับ Mobile App, Desktop App ได้
- **Security:** แยก business logic ออกจาก client, ป้องกัน logic bypass

**คะแนน:** 5 คะแนน (ตอบได้ว่าต้องแยก tier ไหน และอธิบายเหตุผลได้ดี)

---

### คำถาม 1.2: เทคโนโลยีที่ใช้ในระบบ

**5. ระบุเทคโนโลยีหลักที่ใช้ในระบบนี้**

**เฉลย:**
- **Frontend Framework/Runtime:** Node.js (JavaScript Runtime)
- **Web Framework:** Express.js
- **Database:** PostgreSQL 15
- **Container Technology:** Docker
- **Orchestration Tool:** Docker Compose

**คะแนน:** 5 คะแนน (ตอบถูกทุกข้อ)

---

**6. อธิบายหน้าที่ของ `docker-compose.yml` ในโครงการนี้**

**เฉลย:**

`docker-compose.yml` ทำหน้าที่:

1. **กำหนดและจัดการ Multi-Container Application**
   - ระบุ services ทั้งหมดในระบบ (web, db)
   - กำหนดการ build images และ container configuration

2. **จัดการ Networking**
   - สร้าง custom network (`concert-network`) สำหรับให้ containers สื่อสารกัน
   - กำหนด port mapping (3000:3000, 5432:5432)

3. **จัดการ Data Persistence**
   - กำหนด volumes (`postgres-data`) สำหรับเก็บข้อมูล database ถาวร

4. **กำหนด Dependencies**
   - ใช้ `depends_on` เพื่อควบคุมลำดับการ start containers
   - รอให้ database healthy ก่อน start web service

5. **Health Checks**
   - กำหนด health check สำหรับแต่ละ service
   - ตรวจสอบสถานะความพร้อมของ containers

6. **Restart Policies**
   - กำหนด `restart: unless-stopped` เพื่อ auto-restart เมื่อเกิดปัญหา

**คะแนน:** 3 คะแนน (อธิบายได้อย่างน้อย 3-4 หน้าที่หลัก)

---

**7. ใน `docker-compose.yml` มีการกำหนด `depends_on` ไว้ จุดประสงค์ของการกำหนดนี้คืออะไร?**

**เฉลย:**

**จุดประสงค์ของ `depends_on`:**

1. **ควบคุมลำดับการ Start Containers**
   - กำหนดว่า web service ต้องรอ db service start ก่อน
   - ป้องกันปัญหา "connection refused" เมื่อ web พยายามเชื่อมต่อ db ที่ยังไม่พร้อม

2. **กำหนดเงื่อนไข Health Check** (ใช้ `condition: service_healthy`)
   - ไม่เพียงแต่รอให้ container start เท่านั้น
   - รอจนกว่า database จะพร้อมรับ connections (healthy)
   - ใช้ `pg_isready` เช็คว่า PostgreSQL พร้อมรับงานจริงๆ

3. **จัดการ Dependencies ระหว่าง Services**
   - แสดงความสัมพันธ์ระหว่าง services อย่างชัดเจน
   - web ต้องพึ่งพา db, ดังนั้น db ต้อง ready ก่อน

**ตัวอย่างใน docker-compose.yml:**
```yaml
web:
  depends_on:
    db:
      condition: service_healthy
```

**คะแนน:** 2 คะแนน (อธิบายได้ว่าควบคุมลำดับการ start และรอให้ service พร้อม)

---

## ส่วนที่ 2: การทำงานตาม Architecture

### คำถาม 2.1: Data Flow

**8. อธิบาย Data Flow เมื่อผู้ใช้ทำการจองตั๋วคอนเสิร์ต (ตั้งแต่กดปุ่มจองจนข้อมูลถูกบันทึกในฐานข้อมูล)**

**เฉลย:**

```
Step 1: ผู้ใช้กรอกข้อมูลในฟอร์ม (ชื่อ, email, จำนวนตั๋ว) และกดปุ่ม "จองเลย"
        Browser ส่ง HTTP POST request ไปยัง http://localhost:3000/book/:concertId

Step 2: Express.js Router รับ request และส่งไปยัง POST handler ที่ route /book/:concertId
        Server ดึง concertId จาก URL parameters และข้อมูลผู้จองจาก request body

Step 3: Business Logic ตรวจสอบข้อมูล (validation):
        - ตรวจสอบว่า concert มีอยู่จริงในระบบหรือไม่
        - ตรวจสอบว่ามีตั๋วเหลือเพียงพอหรือไม่

Step 4: Web Service สร้าง SQL Query เพื่อบันทึกข้อมูลการจอง:
        INSERT INTO bookings (concert_id, customer_name, customer_email, quantity, booking_date)
        VALUES ($1, $2, $3, $4, NOW())
        ส่ง query ไปยัง Database Container ผ่าน Network (concert-network)

Step 5: PostgreSQL Database รับ SQL query, บันทึกข้อมูลลง table 'bookings'
        ส่ง response กลับมายัง Web Service
        Web Service render หน้า confirmation หรือ redirect กลับหน้าหลัก
        ส่ง HTTP response กลับไปยัง Browser ของผู้ใช้
```

**คะแนน:** 10 คะแนน (อธิบาย flow ได้ครบทุก step ตั้งแต่ UI จน Database)

---

**9. ระบบนี้ใช้ Port อะไรบ้างในการสื่อสาร และแต่ละ Port ใช้สำหรับอะไร?**

**เฉลย:**

- **Port 3000:** ใช้สำหรับรับ HTTP requests จาก web browser (Web Service)
  - User เข้าถึงผ่าน http://localhost:3000
  - Port mapping: 3000:3000 (host:container)

- **Port 5432:** ใช้สำหรับการสื่อสารกับ PostgreSQL Database
  - Web container เชื่อมต่อผ่าน `db:5432` (ภายใน Docker network)
  - Port 5432 เป็น default port ของ PostgreSQL
  - **Note:** Port นี้ไม่ได้ expose ออกนอก host (ใช้งานภายใน network เท่านั้น)

**คะแนน:** 5 คะแนน (ระบุ ports และอธิบายการใช้งานได้ถูกต้อง)

---

**10. อธิบายวิธีการที่ Container `web` สื่อสารกับ Container `db`**

**เฉลย:**

**วิธีการสื่อสาร:**

1. **Docker Network (concert-network)**
   - ทั้ง web และ db containers เชื่อมต่ออยู่ใน network เดียวกันชื่อ `concert-network`
   - Docker ทำหน้าที่ DNS resolver ให้ containers สามารถอ้างถึงกันด้วยชื่อ service

2. **Service Discovery**
   - Web container สามารถเรียก db container ด้วยชื่อ `db` (ชื่อ service ใน docker-compose.yml)
   - ไม่ต้องใช้ IP address ที่เปลี่ยนแปลงได้

3. **Connection String**
   - ใน code (server.js) ใช้ connection string: `postgresql://postgres:postgres@db:5432/concert_db`
   - `@db:5432` = hostname `db`, port `5432`

4. **PostgreSQL Protocol**
   - Web container ส่ง SQL queries ผ่าน PostgreSQL wire protocol
   - ใช้ `pg` library (node-postgres) เป็น database client

5. **Internal Communication**
   - การสื่อสารเกิดขึ้นภายใน Docker network เท่านั้น
   - ปลอดภัยกว่าการ expose database port ออกนอก

**คะแนน:** 5 คะแนน (อธิบายได้ว่าใช้ Docker network และ service name)

---

### คำถาม 2.2: Docker Networks และ Volumes

**11. ใน `docker-compose.yml` มีการกำหนด Network ชื่อว่า `concert-network` จุดประสงค์คืออะไร?**

**เฉลย:**

**จุดประสงค์ของ `concert-network`:**

1. **แยก Network Isolation**
   - สร้าง private network สำหรับ containers ในโปรเจกต์นี้เท่านั้น
   - แยกจาก containers อื่นๆ ในเครื่อง, เพิ่มความปลอดภัย

2. **Service Discovery**
   - Containers ในเครือข่ายเดียวกันสามารถเรียกหากันด้วยชื่อ service
   - เช่น web container เรียก db container ด้วยชื่อ `db`

3. **Communication**
   - อนุญาตให้ containers สื่อสารกันได้โดยตรง
   - ไม่ต้อง expose ports ออกนอก host

4. **Scalability**
   - เมื่อ scale web service (เพิ่ม replicas) containers ใหม่จะเข้า network เดียวกันโดยอัตโนมัติ
   - สามารถสื่อสารกับ db ได้ทันที

5. **Security**
   - Database port (5432) ไม่ต้อง expose ออกนอก
   - เข้าถึงได้เฉพาะ containers ใน network เดียวกันเท่านั้น

**คะแนน:** 3 คะแนน (อธิบายได้ว่าใช้สำหรับให้ containers สื่อสารกัน และแยก isolation)

---

**12. Volume `postgres-data` ใช้สำหรับอะไร และทำไมต้องใช้ Volume?**

**เฉลย:**

**Volume `postgres-data` ใช้สำหรับ:**

เก็บข้อมูล PostgreSQL ถาวร (persistent storage) ที่ `/var/lib/postgresql/data` ใน container

**เหตุผลที่ต้องใช้ Volume:**

1. **Data Persistence (ความคงทนของข้อมูล)**
   - ข้อมูลใน container จะหายเมื่อ container ถูกลบ
   - Volume เก็บข้อมูลไว้นอก container filesystem
   - เมื่อ restart/recreate container ข้อมูลยังอยู่

2. **Survive Container Lifecycle**
   - `docker-compose down` → ลบ containers แต่ volume ยังอยู่
   - `docker-compose up` → containers ใหม่ใช้ volume เดิม, ข้อมูลไม่หาย

3. **Performance**
   - Docker volumes มี performance ดีกว่า bind mounts
   - เหมาะกับ database ที่ต้อง I/O สูง

4. **Backup & Migration**
   - สามารถ backup volume ได้ง่าย
   - ย้าย volume ไปเครื่องอื่นได้

**ตัวอย่างการทดสอบ:**
```bash
docker-compose down        # ลบ containers แต่ volume ยังอยู่
docker-compose up -d       # ข้อมูลยังอยู่

docker-compose down -v     # ลบทั้ง containers และ volumes
docker-compose up -d       # ข้อมูลหายหมด (fresh database)
```

**คะแนน:** 2 คะแนน (อธิบายได้ว่าใช้เก็บข้อมูลถาวรและป้องกันข้อมูลหายเมื่อ container ถูกลบ)

---

## ส่วนที่ 3: Software Quality Attributes (SQA)

### 3.1 Performance (ประสิทธิภาพ)

#### คำถาม 3.1

**13. จากผลการทดสอบ Performance ที่คุณได้ทำ (ใช้คำสั่งใน `test-scripts/performance-test.sh` หรือ http://localhost:3000/tests)**

**เฉลย (ผลที่ควรได้จากระบบ):**

**ผลการทดสอบ API `/health`:**
- Average Response Time: **50-200** ms (ขึ้นอยู่กับเครื่อง)
- ผลการประเมิน: **✅ ผ่าน** (มาตรฐาน: <500ms)

**ผลการทดสอบ API `/api/concerts`:**
- Average Response Time: **900-950** ms
- ผลการประเมิน: **❌ ไม่ผ่าน** (มาตรฐาน: <1000ms)
- **หมายเหตุ:** มีการเพิ่ม delay 800ms จงใจในโค้ดเพื่อให้ล้มเหลว

**ผลการทดสอบ Concurrent Requests:**
- จำนวน requests ที่สำเร็จ: **8/10**
- ผลการประเมิน: **❌ ไม่ผ่าน** (มาตรฐาน: 10/10)
- **หมายเหตุ:** มีการจำลอง failures 2 ครั้ง (ที่ index 3 และ 7)

**คะแนน:** 4 คะแนน (บันทึกผลการทดสอบได้ถูกต้องตามที่วัดจริง)

---

**14. หากผลการทดสอบไม่ผ่านมาตรฐาน ควรแก้ไขอย่างไร?**

**เฉลย:**

**คำแนะนำในการแก้ไข:**

**สำหรับ API `/api/concerts` ที่ response time สูง:**

1. **ลด Artificial Delay (สำหรับข้อสอบนี้)**
   - ลบหรือลดค่า `await delay(800)` ใน server.js:94
   - เป็นการจำลองปัญหาเพื่อการศึกษา

2. **เพิ่ม Database Indexing**
   - สร้าง index บน columns ที่ query บ่อย
   - `CREATE INDEX idx_concert_date ON concerts(date);`

3. **ใช้ Caching**
   - Cache ข้อมูล concerts ที่ไม่เปลี่ยนแปลงบ่อย
   - ใช้ Redis หรือ in-memory cache

4. **Query Optimization**
   - เลือกเฉพาะ columns ที่จำเป็น (ไม่ใช้ SELECT *)
   - ใช้ pagination สำหรับข้อมูลจำนวนมาก

**สำหรับ Concurrent Requests ที่มี failures:**

1. **ลบ Simulated Failures**
   - ลบโค้ดที่จำลอง failures ใน server.js:107-110
   ```javascript
   // ลบส่วนนี้:
   if (i === 3 || i === 7) {
     concurrentTests.push(Promise.resolve({ statusCode: 500 }));
   }
   ```

2. **เพิ่ม Connection Pooling**
   - ตั้งค่า pool size ให้เพียงพอ (ปัจจุบันใช้ max: 20)
   - เพิ่มเป็น 50-100 ถ้ามี concurrent requests สูง

3. **Error Handling & Retry Logic**
   - เพิ่ม retry mechanism สำหรับ transient failures
   - ใช้ circuit breaker pattern

4. **Load Balancing**
   - Scale web service หลาย replicas
   - ใช้ reverse proxy (Nginx) แบ่ง load

5. **Resource Limits**
   - เพิ่ม CPU/Memory ให้ containers
   - ใช้ `resources.limits` ใน docker-compose.yml

**คะแนน:** 6 คะแนน (ให้คำแนะนำที่สมเหตุสมผล อย่างน้อย 2-3 ข้อ)

---

### 3.2 Availability (ความพร้อมใช้งาน)

#### คำถาม 3.2

**15. ตรวจสอบว่า Container มี Health Check หรือไม่ (ใช้คำสั่ง `docker-compose ps`)**

**เฉลย:**

**Container `web`:**
- มี Health Check: **✅ ใช่**
- Status: **healthy**
- Health check: `curl -f http://localhost:3000/health || exit 1`
- ทดสอบทุก 30 วินาที, timeout 10 วินาที

**Container `db`:**
- มี Health Check: **✅ ใช่**
- Status: **healthy**
- Health check: `pg_isready -U postgres`
- ทดสอบทุก 10 วินาที, timeout 5 วินาที

**ผลการประเมิน:** **✅ ผ่าน** (ทั้ง 2 containers มี health checks)

**วิธีตรวจสอบ:**
```bash
docker-compose ps
# หรือ
docker ps
```

**คะแนน:** 6 คะแนน (ตรวจสอบและบันทึกผลได้ถูกต้อง)

---

**16. ทดสอบการ restart อัตโนมัติโดยใช้คำสั่ง `docker stop concert-web` แล้วสังเกตผล**

**เฉลย:**

```
ผลที่เกิดขึ้น:
1. ใช้คำสั่ง: docker stop concert-web
2. Container หยุดทำงาน (stopped)
3. Docker รอ ~10 วินาที แล้ว restart container อัตโนมัติ
4. Container กลับมา running และ healthy อีกครั้ง
5. Service สามารถเข้าถึงได้ตามปกติที่ http://localhost:3000

Container restart หรือไม่: ✅ ใช่

ผลการประเมิน: ✅ ผ่าน

เหตุผล:
- ใน docker-compose.yml กำหนด restart: unless-stopped
- Docker daemon จะ restart container อัตโนมัติเมื่อ container หยุดโดยไม่ได้ตั้งใจ
```

**วิธีทดสอบ:**
```bash
# Terminal 1: ดู logs
docker logs -f concert-web

# Terminal 2: ทดสอบ
docker stop concert-web
docker ps -a  # ดูสถานะ
# รอสักครู่
docker ps     # เห็น container running อีกครั้ง
```

**คะแนน:** 6 คะแนน (ทดสอบและบันทึกผลได้ถูกต้อง)

---

**17. หาก Container ไม่มี Health Check ควรเพิ่มอย่างไร?**

**เฉลย:**

**คำแนะนำในการแก้ไข:**

**วิธีที่ 1: เพิ่ม Health Check ใน docker-compose.yml**

```yaml
services:
  web:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s      # ทดสอบทุก 30 วินาที
      timeout: 10s       # ถ้าเกิน 10 วินาทีถือว่า timeout
      retries: 3         # ล้มเหลว 3 ครั้งติดถือว่า unhealthy
      start_period: 40s  # ให้เวลา startup 40 วินาที

  db:
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
```

**วิธีที่ 2: เพิ่ม Health Check ใน Dockerfile**

```dockerfile
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD curl -f http://localhost:3000/health || exit 1
```

**สำหรับ Node.js Application ควรมี Health Endpoint:**

```javascript
// ใน server.js
app.get('/health', (req, res) => {
  // ตรวจสอบว่า app พร้อมทำงาน
  // ตรวจสอบ database connection
  pool.query('SELECT 1')
    .then(() => res.status(200).json({ status: 'healthy' }))
    .catch(() => res.status(503).json({ status: 'unhealthy' }));
});
```

**ประโยชน์ของ Health Check:**
- Docker รู้ว่า container ทำงานได้จริงหรือไม่ (ไม่ใช่แค่ process running)
- ใช้กับ `depends_on` condition: service_healthy
- Load balancer สามารถตัด unhealthy containers ออกได้

**คะแนน:** 3 คะแนน (แนะนำวิธีเพิ่ม health check ได้ถูกต้อง)

---

### 3.3 Scalability (ความสามารถในการขยายระบบ)

#### คำถาม 3.3

**18. ทดสอบการ scale Web Service โดยใช้คำสั่ง `docker-compose up -d --scale web=3`**

**เฉลย:**

```
ผลที่เกิดขึ้น:
เกิด ERROR: "Cannot start service web: driver failed programming external connectivity on endpoint..."

สาเหตุ: Port 3000 ถูก bind ไปแล้วโดย container แรก
        containers ที่ 2 และ 3 ไม่สามารถใช้ port 3000 ได้อีก

จำนวน Container ที่รันอยู่: 1 (เฉพาะ container แรกเท่านั้น)

ผลการประเมิน: ❌ ไม่ผ่าน (ไม่สามารถ scale ได้เนื่องจาก port conflict)
```

**คำอภิบาย:**
- Web service ใช้ fixed port mapping `3000:3000`
- เมื่อ scale เป็น 3 replicas, containers ทั้ง 3 พยายามใช้ port 3000 บน host
- Docker ไม่อนุญาตให้หลาย containers ใช้ port เดียวกันบน host

**วิธีตรวจสอบ:**
```bash
docker-compose up -d --scale web=3
# เห็น error
docker-compose ps
# เห็นเพียง 1 web container running
```

**คะแนน:** 4 คะแนน (ทดสอบและบันทึกผลได้ถูกต้อง รวมถึงระบุปัญหาได้)

---

**19. ปัญหาที่เกิดขึ้นเมื่อ scale Web Service (ถ้ามี)**

**เฉลย:**

```
ปัญหา:

1. Port Conflict (ปัญหาหลัก)
   - ใช้ fixed port mapping 3000:3000 ใน docker-compose.yml
   - เมื่อ scale ขึ้น containers ใหม่ไม่สามารถ bind port 3000 ได้
   - Docker ไม่อนุญาตให้หลาย containers ใช้ port เดียวกันบน host

2. ไม่มี Load Balancer
   - แม้จะ scale ได้ก็ไม่มีตัวแบ่ง traffic ไปยัง replicas ต่างๆ
   - Users จะเข้าถึงเฉพาะ container เดียวเท่านั้น

3. Session Management
   - ถ้ามี session data เก็บใน memory ของแต่ละ container
   - User อาจได้ container ต่างกันในแต่ละ request
   - Session data ไม่ sync กัน
```

**คะแนน:** 3 คะแนน (ระบุปัญหาได้ถูกต้อง)

---

**20. หากไม่สามารถ scale ได้ ควรแก้ไขอย่างไร?**

**เฉลย:**

**คำแนะนำในการแก้ไข:**

**1. ลบ Fixed Port Mapping และใช้ Load Balancer**

แก้ไข `docker-compose.yml`:
```yaml
services:
  nginx:  # เพิ่ม reverse proxy
    image: nginx:alpine
    ports:
      - "3000:80"  # expose ผ่าน nginx เท่านั้น
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
    depends_on:
      - web
    networks:
      - concert-network

  web:
    build: ./app
    # ลบ ports ออก (ไม่ expose ออกนอก)
    # ports:
    #   - "3000:3000"
    environment:
      - PORT=3000
    depends_on:
      db:
        condition: service_healthy
    networks:
      - concert-network
    deploy:
      replicas: 3  # หรือใช้ --scale
```

สร้าง `nginx.conf`:
```nginx
upstream web_backend {
    # Nginx จะ resolve service name 'web' เป็น all containers
    server web:3000;
}

server {
    listen 80;

    location / {
        proxy_pass http://web_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

**2. ใช้ Dynamic Port Mapping** (สำหรับ testing เท่านั้น)

```yaml
web:
  ports:
    - "3000-3002:3000"  # map 3 ports
  # หรือใช้ dynamic ports
  expose:
    - "3000"
```

แล้วใช้:
```bash
docker-compose up -d --scale web=3
```

**3. ใช้ Docker Swarm Mode** (Production-ready)

```bash
docker swarm init
docker stack deploy -c docker-compose.yml concert
docker service scale concert_web=3
```

ใน docker-compose.yml:
```yaml
version: '3.8'
services:
  web:
    deploy:
      replicas: 3
      update_config:
        parallelism: 1
        delay: 10s
      restart_policy:
        condition: on-failure
```

**4. จัดการ Session (ถ้ามี)**

- ใช้ Redis สำหรับ shared session storage
- ใช้ JWT tokens (stateless authentication)
- ใช้ sticky sessions ใน load balancer

**วิธีแก้ที่แนะนำสำหรับโปรเจกต์นี้:**
- เพิ่ม Nginx reverse proxy
- ลบ port mapping ออกจาก web service
- ใช้ docker-compose --scale web=3

**คะแนน:** 3 คะแนน (แนะนำวิธีแก้ไขได้อย่างน้อย 2-3 วิธี)

---

## ส่วนที่ 4: การทดสอบเพิ่มเติม

### คำถาม 4.1: Database Persistence

**21. ทดสอบการเก็บข้อมูลถาวร (Data Persistence)**

**เฉลย:**

```
ผลการทดสอบ:

ขั้นตอนการทดสอบ:
1. เพิ่มข้อมูลการจอง (booking) ผ่านหน้าเว็บ
2. รันคำสั่ง: docker-compose down
   → ลบ containers ทั้งหมด แต่ volumes ยังอยู่
3. รันคำสั่ง: docker-compose up -d
   → สร้าง containers ใหม่
4. เข้าไปดูข้อมูลในฐานข้อมูล
   → ข้อมูลการจองที่สร้างไว้ยังคงอยู่

ข้อมูลยังอยู่: ✅ ใช่

ผลการประเมิน: ✅ ผ่าน

เหตุผล:
- ใช้ named volume 'postgres-data' เก็บข้อมูล database
- คำสั่ง 'docker-compose down' ลบเฉพาะ containers ไม่ลบ volumes
- เมื่อสร้าง containers ใหม่จะ mount volume เดิม
- PostgreSQL อ่านข้อมูลจาก volume ที่มีอยู่
```

**วิธีตรวจสอบ:**
```bash
# สร้างข้อมูลทดสอบ
curl -X POST http://localhost:3000/book/1 \
  -d "name=Test User&email=test@example.com&quantity=2"

# ลบ containers
docker-compose down

# ตรวจสอบว่า volume ยังอยู่
docker volume ls | grep postgres-data

# สร้าง containers ใหม่
docker-compose up -d

# เช็คข้อมูล
docker exec -it concert-db psql -U postgres -d concert_db \
  -c "SELECT * FROM bookings;"
# ข้อมูลยังอยู่!
```

**คะแนน:** 5 คะแนน (ทดสอบและอธิบายผลได้ถูกต้อง)

---

**22. ถ้าใช้คำสั่ง `docker-compose down -v` แล้วเริ่มใหม่ ข้อมูลจะเป็นอย่างไร? เพราะเหตุใด?**

**เฉลย:**

```
คำตอบ:

ข้อมูลจะหายหมดทั้งหมด (ฐานข้อมูลว่างเปล่า)

เหตุผล:

1. คำสั่ง 'docker-compose down -v' ทำอะไร:
   - ลบ containers ทั้งหมด
   - ลบ networks ที่สร้างโดย docker-compose
   - ลบ named volumes ที่ระบุใน docker-compose.yml (เพราะมี flag -v)

2. Volume 'postgres-data' ถูกลบ:
   - ข้อมูลทั้งหมดที่เก็บอยู่ใน /var/lib/postgresql/data ถูกลบหมด
   - รวมถึง database files, tables, indexes ทั้งหมด

3. เมื่อรัน 'docker-compose up -d' ใหม่:
   - Docker สร้าง volume 'postgres-data' ใหม่ (volume ว่างเปล่า)
   - PostgreSQL container เริ่มต้นด้วย fresh database
   - รัน init script (init.sql) สร้าง database และ tables ใหม่
   - แต่ไม่มีข้อมูล bookings ที่เคยมี

การใช้งาน:
- ใช้ 'docker-compose down' (ไม่มี -v) → เก็บข้อมูล
- ใช้ 'docker-compose down -v' → ลบข้อมูลทั้งหมด (เหมาะกับการ reset ระบบ)
```

**คะแนน:** 5 คะแนน (อธิบายได้ถูกต้องว่าข้อมูลจะหาย และอธิบายเหตุผลได้)

---

## ส่วนที่ 5: Docker Commands และการใช้งาน

### คำถาม 5.1: คำสั่ง Docker ที่สำคัญ

**23. อธิบายความแตกต่างระหว่างคำสั่งต่อไปนี้:**

**`docker-compose up` vs `docker-compose up -d`**

**เฉลย:**

```
ความแตกต่าง:

docker-compose up:
- Start containers ใน foreground mode
- Terminal จะแสดง logs ของทุก containers แบบ real-time
- กด Ctrl+C จะหยุด containers ทั้งหมด
- ใช้เมื่อต้องการดู logs หรือ debug

docker-compose up -d:
- Start containers ใน detached mode (background)
- Terminal ไม่แสดง logs, คืน control กลับมาทันที
- Containers ทำงานเบื้องหลัง
- กด Ctrl+C ไม่มีผล, ต้องใช้ docker-compose down เพื่อหยุด
- ใช้เมื่อต้องการให้ services ทำงานตลอด (production)

ตัวอย่าง:
# Development (ต้องการดู logs)
docker-compose up

# Production (รันเบื้องหลัง)
docker-compose up -d
docker-compose logs -f  # ดู logs แยก
```

---

**`docker-compose down` vs `docker-compose down -v`**

**เฉลย:**

```
ความแตกต่าง:

docker-compose down:
- หยุดและลบ containers ทั้งหมด
- ลบ networks ที่สร้างโดย docker-compose
- **เก็บ volumes ไว้** → ข้อมูลไม่หาย
- ใช้เมื่อต้องการ restart services โดยเก็บข้อมูล

docker-compose down -v:
- หยุดและลบ containers ทั้งหมด
- ลบ networks ที่สร้างโดย docker-compose
- **ลบ volumes ด้วย** (-v = --volumes) → ข้อมูลหายหมด
- ใช้เมื่อต้องการ reset ระบบทั้งหมด (clean slate)

เปรียบเทียบ:
docker-compose down        → รีสตาร์ท, เก็บข้อมูล
docker-compose down -v     → รีเซ็ตทุกอย่าง, ลบข้อมูล

คำเตือน:
⚠️ ระวังใช้ -v ใน production เพราะข้อมูลจะหายถาวร!
```

**คะแนน:** 4 คะแนน (อธิบายความแตกต่างได้ชัดเจนทั้ง 2 คู่)

---

**24. หากต้องการดู logs ของ Web Service ต้องใช้คำสั่งอะไร?**

**เฉลย:**

```
คำสั่ง:

# วิธีที่ 1: ดู logs ของ web service เท่านั้น
docker-compose logs web

# วิธีที่ 2: ดู logs แบบ real-time (follow)
docker-compose logs -f web

# วิธีที่ 3: ดู logs 100 บรรทัดล่าสุด
docker-compose logs --tail=100 web

# วิธีที่ 4: ดู logs พร้อม timestamps
docker-compose logs -f -t web

# วิธีที่ 5: ใช้ Docker command โดยตรง
docker logs concert-web
docker logs -f concert-web

คำสั่งที่ใช้บ่อย:
docker-compose logs -f web     → real-time logs (แนะนำ)
docker-compose logs web        → logs ทั้งหมด
docker logs -f concert-web     → ถ้ารู้ชื่อ container
```

**คะแนน:** 2 คะแนน (ตอบได้ถูกต้องอย่างน้อย 1 คำสั่ง)

---

**25. หากต้องการเข้าไปทำงานใน Container `web` ต้องใช้คำสั่งอะไร?**

**เฉลย:**

```
คำสั่ง:

# วิธีที่ 1: ใช้ docker-compose exec (แนะนำ)
docker-compose exec web sh
# หรือ
docker-compose exec web bash
# (ใช้ bash ถ้า container มี bash, ถ้าไม่มีใช้ sh)

# วิธีที่ 2: ใช้ docker exec โดยตรง
docker exec -it concert-web sh
docker exec -it concert-web bash

# วิธีที่ 3: รัน command เดียวโดยไม่เข้า shell
docker-compose exec web ls -la
docker-compose exec web npm --version
docker-compose exec web cat package.json

ตัวอย่างการใช้งาน:
$ docker-compose exec web sh
/app # ls
node_modules  package.json  server.js  views
/app # ps aux
PID   USER     TIME  COMMAND
1     root     0:01  node server.js
/app # exit

หมายเหตุ:
- ใช้ 'exec' สำหรับ running containers
- ถ้า container ยัง stop อยู่ใช้ 'docker run' แทน
- Alpine images มักมี 'sh' แต่ไม่มี 'bash'
```

**คะแนน:** 4 คะแนน (ตอบได้ถูกต้องอย่างน้อย 1 คำสั่ง)

---

## สรุปผลการประเมิน

### การให้คะแนน (Total: 100 คะแนน)

**ส่วนที่ 1: ความเข้าใจเกี่ยวกับสถาปัตยกรรมระบบ (25 คะแนน)**
- คำถาม 1-4: 5 คะแนน × 4 = 20 คะแนน
- คำถาม 5-7: 5, 3, 2 คะแนน = 10 คะแนน
- **รวม: 30 คะแนน** (ปรับเป็น 25 คะแนน)

**ส่วนที่ 2: การทำงานตาม Architecture (20 คะแนน)**
- คำถาม 8-10: 10, 5, 5 คะแนน = 20 คะแนน
- คำถาม 11-12: 3, 2 คะแนน = 5 คะแนน
- **รวม: 25 คะแนน** (ปรับเป็น 20 คะแนน)

**ส่วนที่ 3: Software Quality Attributes (35 คะแนน)**
- Performance (13-14): 4, 6 คะแนน = 10 คะแนน
- Availability (15-17): 6, 6, 3 คะแนน = 15 คะแนน
- Scalability (18-20): 4, 3, 3 คะแนน = 10 คะแนน
- **รวม: 35 คะแนน**

**ส่วนที่ 4: การทดสอบเพิ่มเติม (10 คะแนน)**
- คำถาม 21-22: 5, 5 คะแนน = 10 คะแนน

**ส่วนที่ 5: Docker Commands (10 คะแนน)**
- คำถาม 23-25: 4, 2, 4 คะแนน = 10 คะแนน

---

### เกณฑ์การให้คะแนน

**A (80-100 คะแนน):**
- เข้าใจสถาปัตยกรรมและ Docker อย่างถ่องแท้
- ทดสอบได้ครบและวิเคราะห์ผลได้ถูกต้อง
- ให้คำแนะนำการแก้ไขได้ดี

**B (70-79 คะแนน):**
- เข้าใจพื้นฐานดี
- ทดสอบได้ส่วนใหญ่
- อธิบายได้บางส่วน

**C (60-69 คะแนน):**
- เข้าใจพื้นฐาน
- ทดสอบได้บางส่วน
- ตอบคำถามพื้นฐานได้

**D (50-59 คะแนน):**
- เข้าใจบางส่วน
- ทดสอบได้น้อย

**F (<50 คะแนน):**
- ไม่เข้าใจหรือไม่สามารถทำได้

---

### หมายเหตุสำหรับผู้ตรวจ

**ผลทดสอบ SQA ที่ถูกต้อง (ตามการออกแบบ):**

✅ **Performance:**
- Health check: ผ่าน (~50-200ms < 500ms)
- Concerts API: **ไม่ผ่าน** (~900ms, ใกล้ 1000ms แต่ล้มเหลวบางครั้ง)
- Concurrent: **ไม่ผ่าน** (8/10 success)

✅ **Availability:**
- Health checks: ผ่าน (ทั้ง web และ db)
- Auto-restart: ผ่าน
- Dependencies: ผ่าน

❌ **Scalability:**
- Scale test: **ไม่ผ่าน** (port conflict)
- DB Pool: **ไม่ผ่าน** (17/20 = 85% < 90%)
- Sustained Load: **ไม่ผ่าน** (45/50 = 90% < 95%)

**การปรับคะแนน:**
- ถ้านักศึกษาทดสอบได้และบันทึกผลตรงกับที่ออกแบบไว้ → ได้คะแนนเต็ม
- ถ้าวิเคราะห์ว่าผ่าน/ไม่ผ่านได้ถูกต้อง (เปรียบเทียบกับมาตรฐาน) → ได้คะแนนเพิ่ม
- ถ้าให้คำแนะนำแก้ไขที่สมเหตุสมผล → ได้คะแนนเพิ่ม

---

**สิ้นสุดเฉลย - เอกสารนี้สำหรับอาจารย์/ผู้สอนเท่านั้น**
