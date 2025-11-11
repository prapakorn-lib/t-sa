# เฉลยข้อสอบ - Concert Ticket System
## Software Quality Testing Answer Key

**⚠️ สำหรับอาจารย์เท่านั้น - ห้ามแจกจ่าย**

---

## Performance Testing

### Test 1: Health Check API Response Time
- **มาตรฐาน:** < 500ms
- **ผลที่ออกแบบไว้:** ✅ **ผ่าน**
- **ค่าเฉลี่ยที่คาดหวัง:** ~50-200ms
- **การประเมิน:** ระบบตอบสนองเร็ว อยู่ในเกณฑ์มาตรฐาน

### Test 2: Concerts API Response Time
- **มาตรฐาน:** < 1000ms
- **ผลที่ออกแบบไว้:** ❌ **ไม่ผ่าน**
- **ค่าเฉลี่ยที่คาดหวัง:** ~800-900ms (มี artificial delay 800ms)
- **การประเมิน:** เกินมาตรฐาน - มีการ delay โดยเจตนาเพื่อแสดงปัญหา performance
- **สาเหตุ:** มีการเพิ่ม delay 800ms ใน code (จำลองการ query ที่ช้า)
- **วิธีแก้ไข:**
  - เพิ่ม database indexing
  - ใช้ caching (Redis)
  - Optimize SQL queries
  - ลด response payload size

### Test 3: Concurrent Requests Handling
- **มาตรฐาน:** รองรับ ≥ 10 concurrent requests (ทั้งหมดต้องสำเร็จ)
- **ผลที่ออกแบบไว้:** ❌ **ไม่ผ่าน**
- **ผลที่คาดหวัง:** 8 สำเร็จ, 2 ล้มเหลว (i=3 และ i=7 ถูก simulate ให้ล้มเหลว)
- **การประเมิน:** มี request บางส่วนล้มเหลว แสดงว่าระบบรองรับ concurrent load ไม่ดีพอ
- **สาเหตุ:** Connection pool limit, Resource exhaustion
- **วิธีแก้ไข:**
  - เพิ่ม connection pool size
  - ใช้ load balancer
  - Scale horizontal (เพิ่ม instances)
  - Implement queue system

---

## Availability Testing

### Test 1: Health Endpoint Check
- **มาตรฐาน:** Response code = 200
- **ผลที่ออกแบบไว้:** ✅ **ผ่าน**
- **ผลที่คาดหวัง:** status = "responding", responseCode = 200
- **การประเมิน:** Health endpoint ทำงานปกติ

### Test 2: Database Connection
- **มาตรฐาน:** Database ต้องเชื่อมต่อได้
- **ผลที่ออกแบบไว้:** ✅ **ผ่าน**
- **ผลที่คาดหวัง:** status = "connected", responseTime < 100ms
- **การประเมิน:** Database connection ทำงานปกติ

### Test 3: Container Health Status
- **มาตรฐาน:** Containers ต้อง healthy
- **ผลที่ออกแบบไว้:** ✅ **ผ่าน** (แต่ต้องเช็คจริงด้วย CLI)
- **ผลที่คาดหวัง:** web = "running", db = "running"
- **การประเมิน:** ต้องใช้คำสั่ง `docker-compose ps` หรือ `docker inspect` เพื่อเช็คจริง
- **คำสั่งเพื่อเช็คจริง:**
  ```bash
  docker-compose ps
  docker inspect concert-web --format='{{.State.Health.Status}}'
  docker inspect concert-db --format='{{.State.Health.Status}}'
  ```

**สรุป Availability:** ผ่านทุกข้อ - ระบบพร้อมใช้งาน

---

## Scalability Testing

### Test 1: Database Connection Pool
- **มาตรฐาน:** ≥ 18/20 queries สำเร็จ
- **ผลที่ออกแบบไว้:** ❌ **ไม่ผ่าน**
- **ผลที่คาดหวัง:** 17 สำเร็จ, 3 ล้มเหลว (i=5, 12, 18 ถูก simulate ให้ล้มเหลว)
- **การประเมิน:** Connection pool ไม่เพียงพอ (85% success rate)
- **สาเหตุ:**
  - Connection pool size เล็กเกินไป
  - Connection timeout
  - Database load เกิน capacity
- **วิธีแก้ไข:**
  - เพิ่ม `max` ใน connection pool config
  - ใช้ connection pooling แบบ advanced (pgBouncer)
  - Scale database (Read replicas)

### Test 2: Sustained Load Test
- **มาตรฐาน:** Success rate ≥ 95%
- **ผลที่ออกแบบไว้:** ❌ **ไม่ผ่าน**
- **ผลที่คาดหวัง:** 45 สำเร็จ, 5 ล้มเหลว = 90% success rate
- **การประเมิน:** ระบบรับ sustained load ไม่ดีพอ
- **สาเหตุ:**
  - Memory/CPU exhaustion
  - Event loop blocking
  - No horizontal scaling
- **วิธีแก้ไข:**
  - Implement caching layer
  - Horizontal scaling (multiple instances)
  - Load balancer (nginx)
  - Optimize code (async/await properly)
  - Add CDN for static assets

### Test 3: Container Scaling
- **การทดสอบ:** `docker-compose up -d --scale web=3`
- **ผลที่คาดหวัง:** ❌ **จะล้มเหลว** เพราะ port conflict (3000:3000 fixed)
- **การประเมิน:** ไม่สามารถ scale ได้เนื่องจาก architecture design
- **สาเหตุ:** Fixed port mapping ใน docker-compose.yml
- **วิธีแก้ไข:**
  1. ลบ fixed port mapping หรือใช้ dynamic ports
  2. เพิ่ม nginx load balancer:
     ```yaml
     nginx:
       image: nginx
       ports:
         - "80:80"
       depends_on:
         - web
     web:
       # ลบ ports หรือใช้ expose แทน
       expose:
         - "3000"
     ```
  3. ใช้ Docker Swarm หรือ Kubernetes

**สรุป Scalability:** ไม่ผ่าน 2/3 ข้อ - ระบบไม่พร้อมสำหรับ scale

---

## สรุปภาพรวม

### ผลการทดสอบทั้งหมด

| Category | Tests | Passed | Failed | Overall |
|----------|-------|--------|--------|---------|
| **Performance** | 3 | 1 (33%) | 2 (67%) | ❌ ไม่ผ่าน |
| **Availability** | 3 | 3 (100%) | 0 (0%) | ✅ ผ่าน |
| **Scalability** | 3 | 0 (0%) | 3 (100%) | ❌ ไม่ผ่าน |
| **รวม** | 9 | 4 (44%) | 5 (56%) | ❌ ไม่ผ่าน |

### ประเด็นหลักที่พบ

1. **Performance Issues:**
   - Concert API ช้าเกินมาตรฐาน
   - Concurrent requests มีบางส่วนล้มเหลว

2. **Scalability Issues (ร้ายแรง):**
   - Database connection pool ไม่เพียงพอ
   - Sustained load success rate ต่ำกว่า 95%
   - ไม่สามารถ scale containers ได้

3. **จุดแข็ง:**
   - Availability ดีมาก - ผ่านทุกข้อ
   - Health checks ทำงานถูกต้อง
   - Database connection stable

### แนวทางปรับปรุงระบบ

#### ระดับ Critical (ต้องแก้ด่วน)
1. เพิ่ม database connection pool size
2. เพิ่ม caching layer (Redis)
3. แก้ไข Docker compose เพื่อรองรับ scaling

#### ระดับ High (ควรแก้)
1. Optimize database queries
2. เพิ่ม load balancer
3. Implement horizontal scaling

#### ระดับ Medium (แก้ในอนาคต)
1. เพิ่ม monitoring (Prometheus/Grafana)
2. Implement auto-scaling
3. เพิ่ม rate limiting
4. CDN สำหรับ static assets

---

## คะแนนมาตรฐาน

### เกณฑ์การให้คะแนนตามผลการทดสอบ

**Performance (10 คะแนน)**
- Test 1 ผ่าน: 4 คะแนน
- Test 2 ไม่ผ่าน: 0 คะแนน
- Test 3 ไม่ผ่าน: 0 คะแนน
- **รวม: 4/10 คะแนน**

**Availability (15 คะแนน)**
- Test 1 ผ่าน: 5 คะแนน
- Test 2 ผ่าน: 5 คะแนน
- Test 3 ผ่าน: 5 คะแนน
- **รวม: 15/15 คะแนน**

**Scalability (10 คะแนน)**
- Test 1 ไม่ผ่าน: 0 คะแนน
- Test 2 ไม่ผ่าน: 0 คะแนน
- Test 3 ข้อมูล/วิเคราะห์: 2 คะแนน (คะแนนพื้นฐาน)
- **รวม: 2/10 คะแนน**

**รวมการทดสอบ: 21/35 คะแนน (60%)**

### เกณฑ์คะแนนนักศึกษา

การให้คะแนนนักศึกษาขึ้นอยู่กับ:
1. **การบันทึกผล (10 คะแนน):** บันทึกครบถ้วน ถูกต้อง
2. **การวิเคราะห์ (10 คะแนน):** วิเคราะห์ถูกต้องว่าผ่าน/ไม่ผ่าน พร้อมเหตุผล
3. **แนวทางแก้ไข (5 คะแนน):** เสนอวิธีแก้ไขที่สมเหตุสมผล
4. **คำถาม assessment.md (65 คะแนน):** ตามเฉลยในไฟล์ assessment.md

**รวม: 100 คะแนน**

---

## หมายเหตุสำหรับอาจารย์

### การปรับระดับความยาก

ถ้าต้องการปรับให้:
- **ง่ายขึ้น:** ลด delay ใน Performance Test
- **ยากขึ้น:** เพิ่ม failures มากขึ้น

### การแก้ไข Code

ไฟล์: `/app/server.js`

**Performance Test (line 123-132):**
```javascript
// ปรับ delay ได้ที่นี่
await delay(800); // เปลี่ยนเป็น 300 = ง่ายขึ้น, 1200 = ยากขึ้น
```

**Concurrent Test (line 138-140):**
```javascript
// ปรับจำนวน failures ได้ที่นี่
if (i === 3 || i === 7) { // เพิ่ม || i === 9 = ยากขึ้น
```

**Scalability Test (line 212):**
```javascript
// ปรับจำนวน failures
if (i === 5 || i === 12 || i === 18) { // เพิ่ม/ลดได้
```

---

**วันที่สร้างเฉลย:** 2025-11-11
**เวอร์ชัน:** 1.0
**ผู้จัด:** Claude Code
