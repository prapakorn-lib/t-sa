# เฉลยแบบประเมินข้อสอบปฏิบัติ Docker
## ระบบจำหน่ายตั๋วคอนเสิร์ต (Concert Ticket Sales System)

**⚠️ เอกสารนี้สำหรับอาจารย์/ผู้สอนเท่านั้น - ห้ามแจกจ่ายให้นักศึกษา**

**สำคัญ: คำตอบทั้งหมดนี้ต้องได้มาจากการ run ระบบจริงเท่านั้น**

---

## ส่วนที่ 1: การตรวจสอบระบบและ Configuration (25 คะแนน)

### คำถาม 1.1: Port Configuration

**1. ระบบนี้ใช้ Port อะไรบ้างสำหรับ Web Service? (3 คะแนน)**

**เฉลย:**
```bash
$ docker ps
# หรือ
$ docker-compose ps
```

- **Host Port:** 8347
- **Container Port:** 8347

**วิธีตรวจสอบเพิ่มเติม:**
```bash
$ docker port concert-web
8347/tcp -> 0.0.0.0:8347
```

---

**2. Database ใช้ Port อะไร? (3 คะแนน)**

**เฉลย:**
```bash
$ docker port concert-db
# หรือ
$ docker inspect concert-db | grep -A 5 "Ports"
```

- **Database Port:** 54321 (host) -> 54321 (container)

---

**3. ทดสอบว่าสามารถเข้าถึง Web Service ได้จริงหรือไม่? (3 คะแนน)**

**เฉลย:**
```bash
$ curl http://localhost:8347/health
```

**ผลที่ได้:**
```json
{
  "status": "healthy",
  "database": "connected",
  "timestamp": "2024-xx-xxTxx:xx:xx.xxxZ"
}
```

- **Port ที่ใช้ทดสอบ:** 8347
- **Response Status:** healthy
- **Database Status:** connected

---

### คำถาม 1.2: Environment Variables

**4. Web Container มี Environment Variable อะไรบ้าง? (4 คะแนน)**

**เฉลย:**
```bash
$ docker inspect concert-web -f '{{.Config.Env}}'
# หรือ
$ docker exec concert-web env
```

**ค่าที่ต้องระบุ:**
- **BUILD_ID:** BLD-2024-X9K7M3
- **APP_VERSION:** 2.4.7
- **DEPLOY_ENV:** exam-production
- **DB_PORT:** 54321

---

**5. Database Container ตั้งค่า PGPORT เป็นเท่าไร? (2 คะแนน)**

**เฉลย:**
```bash
$ docker inspect concert-db -f '{{.Config.Env}}'
# หรือ
$ docker exec concert-db env | grep PGPORT
```

- **PGPORT:** 54321

---

**6. Database Instance ID และ Cluster Name คืออะไร? (3 คะแนน)**

**เฉลย:**
```bash
$ docker exec concert-db env | grep DB_
```

- **DB_INSTANCE_ID:** PGDB-X7M9K4N2
- **DB_CLUSTER:** exam-cluster-01

**หมายเหตุ:** ค่าเหล่านี้ไม่สามารถเดาได้จาก code ต้อง inspect container จริง

---

### คำถาม 1.3: System Info API

**7. เรียก API `/api/system/info` และบันทึกข้อมูลที่ได้ (7 คะแนน)**

**เฉลย:**
```bash
$ curl http://localhost:8347/api/system/info | jq
```

**ผลที่ได้:**
```json
{
  "application": {
    "buildId": "BLD-2024-X9K7M3",
    "version": "2.4.7",
    "deployEnv": "exam-production",
    "port": 8347,
    "nodeVersion": "v20.x.x",
    "uptime": xxx
  },
  "database": {
    "host": "db",
    "port": "54321",
    "name": "concert_db",
    "instanceId": "PGDB-X7M9K4N2",
    "cluster": "exam-cluster-01",
    "serverPort": 54321,
    "poolMax": 20,
    "poolIdleTimeout": 30000
  },
  "network": {
    "hostname": "xxxxxxxxxxxx",
    "platform": "linux",
    "arch": "x64"
  }
}
```

**คำตอบ:**
- Build ID: BLD-2024-X9K7M3
- Version: 2.4.7
- Port: 8347
- Node Version: v20.x.x (ขึ้นอยู่กับ Docker image)
- Uptime (seconds): ขึ้นอยู่กับเวลาที่รัน (ตัวเลขจะเปลี่ยนทุกครั้ง)
- Host: db
- Port: 54321
- Server Port: 54321
- Instance ID: PGDB-X7M9K4N2
- Cluster: exam-cluster-01
- Pool Max Connections: 20
- Pool Idle Timeout (ms): 30000
- Hostname: ขึ้นอยู่กับ Container ID
- Platform: linux
- Architecture: x64 (หรือ arm64 ถ้ารันบน ARM)

**การให้คะแนน:** ให้คะแนนถ้านักศึกษาเรียก API และบันทึกค่าได้ถูกต้อง

---

## ส่วนที่ 2: Docker Networking และ Architecture (15 คะแนน)

### คำถาม 2.1: Network Inspection

**8. Containers ใช้ Network อะไร? (4 คะแนน)**

**เฉลย:**
```bash
$ docker network ls
$ docker network inspect t-sa_concert-network
```

**คำตอบ:**
- **Network Name:** t-sa_concert-network
- **Network Driver:** bridge
- **Subnet:** 172.xx.0.0/16 (ค่าจะแตกต่างกันในแต่ละเครื่อง)
- **Gateway:** 172.xx.0.1 (ค่าจะแตกต่างกันในแต่ละเครื่อง)

**หมายเหตุ:** Subnet และ Gateway จะถูกสร้างแบบ dynamic โดย Docker

---

**9. IP Address ของแต่ละ Container คืออะไร? (3 คะแนน)**

**เฉลย:**
```bash
$ docker inspect concert-web -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
$ docker inspect concert-db -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
```

**คำตอบ:**
- **Web Container IP:** 172.xx.0.x (เช่น 172.18.0.3)
- **DB Container IP:** 172.xx.0.x (เช่น 172.18.0.2)

**หมายเหตุ:** IP addresses จะถูก assign แบบ dynamic ในแต่ละครั้งที่สร้าง containers

**การให้คะแนน:** ให้คะแนนถ้าตรวจสอบและบันทึกค่าได้ (ค่าที่ได้ไม่จำเป็นต้องเหมือนกัน)

---

**10. ทดสอบการเชื่อมต่อระหว่าง Containers (3 คะแนน)**

**เฉลย:**
```bash
$ docker exec -it concert-web sh
/app # ping -c 3 db
```

**ผลที่ได้:**
```
PING db (172.xx.0.x): 56 data bytes
64 bytes from 172.xx.0.x: seq=0 ttl=64 time=0.xxx ms
64 bytes from 172.xx.0.x: seq=1 ttl=64 time=0.xxx ms
64 bytes from 172.xx.0.x: seq=2 ttl=64 time=0.xxx ms

--- db ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.xxx/0.xxx/0.xxx ms
```

**คำตอบ:**
- **สามารถ ping ถึง db ได้หรือไม่:** ✅ ใช่
- **Round-trip time (avg):** ~0.1-0.5 ms (ค่าอาจแตกต่างกัน แต่ควรน้อยกว่า 1ms)

---

### คำถาม 2.2: Volume และ Data Persistence

**11. Volume อะไรบ้างที่ถูกสร้างขึ้น? (3 คะแนน)**

**เฉลย:**
```bash
$ docker volume ls
$ docker volume inspect t-sa_postgres-data
```

**คำตอบ:**
- **Volume Name:** t-sa_postgres-data
- **Mountpoint:** /var/lib/docker/volumes/t-sa_postgres-data/_data
- **Driver:** local

---

**12. ทดสอบ Data Persistence (2 คะแนน)**

**เฉลย:**
```bash
# 1. เข้า http://localhost:8347 และจองตั๋ว
# 2. docker-compose down
# 3. docker volume ls (ตรวจสอบ)
# 4. docker-compose up -d
# 5. เข้า http://localhost:8347 ตรวจสอบข้อมูล
```

**คำตอบ:**
- **Volume ยังอยู่หลัง down หรือไม่:** ✅ ใช่ (docker-compose down ไม่ลบ volumes)
- **ข้อมูล bookings ยังอยู่หรือไม่:** ✅ ใช่ (ข้อมูลถูกเก็บใน volume)

---

## ส่วนที่ 3: Performance Testing (15 คะแนน)

### คำถาม 3.1: ผลการทดสอบ Performance

**13. ทดสอบ Performance และบันทึกผล (10 คะแนน)**

**เฉลย:**
```bash
$ curl http://localhost:8347/api/tests/performance | jq
# หรือเข้า http://localhost:8347/tests
```

**ผลที่คาดหวัง:**

**Health Check Test:**
- Average Response Time: 50-200 ms (ขึ้นอยู่กับเครื่อง)
- Standard (มาตรฐาน): 500 ms
- ผ่านหรือไม่? ✅ **ผ่าน** (< 500ms)

**Concerts API Test:**
- Average Response Time: 900-950 ms
- Standard (มาตรฐาน): 1000 ms
- ผ่านหรือไม่? ⚠️ **ไม่ผ่าน** (ใกล้มาตรฐานแต่มี artificial delay 800ms)

**Concurrent Requests Test:**
- Success: 8/10
- Failed: 2/10
- ผ่านหรือไม่? ❌ **ไม่ผ่าน** (ต้องสำเร็จ 10/10)

**หมายเหตุ:**
- Concerts API มี artificial delay 800ms จงใจ (ดู server.js:125)
- Concurrent test มีการจำลองความล้มเหลว 2 ครั้ง (i=3, i=7)

---

**14. วิเคราะห์สาเหตุที่ไม่ผ่าน (5 คะแนน)**

**เฉลย:**

**สาเหตุ:**

1. **Concerts API ช้า:**
   - มี artificial delay 800ms ใน code (server.js บรรทัด 125)
   - ทำให้ response time เฉลี่ยอยู่ที่ ~900ms
   - ใกล้มาตรฐาน 1000ms แต่บางครั้งอาจเกิน

2. **Concurrent Requests ล้มเหลว:**
   - โค้ดจำลองความล้มเหลว 2 ครั้ง (บรรทัด 138-140)
   - เมื่อ i = 3 และ i = 7 จะ return status 500
   - ทำให้ได้เพียง 8/10 แทนที่จะเป็น 10/10

**วิธีแก้ไข:**

1. **ลดหรือลบ artificial delay:**
   ```javascript
   // ลบบรรทัดนี้ใน server.js:125
   await delay(800);
   ```

2. **ลบ simulated failures:**
   ```javascript
   // ลบ if condition ที่สร้าง failed requests (บรรทัด 138-140)
   if (i === 3 || i === 7) {
     concurrentTests.push(Promise.resolve({ statusCode: 500 }));
   }
   ```

3. **เพิ่ม performance optimization:**
   - เพิ่ม caching
   - เพิ่ม database indexing
   - ใช้ connection pooling ที่มีประสิทธิภาพมากขึ้น

**การให้คะแนน:**
- อธิบายสาเหตุถูกต้อง: 3 คะแนน
- แนะนำวิธีแก้ไขที่สมเหตุสมผล: 2 คะแนน

---

## ส่วนที่ 4: Availability Testing (15 คะแนน)

### คำถาม 4.1: ทดสอบ Health Checks

**15. ตรวจสอบ Health Check Configuration (6 คะแนน)**

**เฉลย:**
```bash
$ docker inspect concert-web -f '{{.State.Health.Status}}'
$ docker inspect concert-db -f '{{.State.Health.Status}}'
```

**คำตอบ:**
- **Web Health Status:** healthy
- **DB Health Status:** healthy

**Health Test Commands:**
```bash
$ docker inspect concert-web -f '{{json .Config.Healthcheck}}'
$ docker inspect concert-db -f '{{json .Config.Healthcheck}}'
```

- **Web Health Test Command:**
  ```
  CMD node -e require('http').get('http://localhost:8347/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})
  ```

- **DB Health Test Command:**
  ```
  CMD-SHELL pg_isready -U postgres -p 54321
  ```

---

**16. ทดสอบ Auto-Restart (6 คะแนน)**

**เฉลย:**
```bash
$ docker stop concert-web
$ sleep 15
$ docker ps -a | grep concert-web
```

**ผลที่ได้:**
```
concert-web   Up 5 seconds (healthy)   8347/tcp
```

**คำตอบ:**
- **Status หลัง stop:** Restarting → Up
- **Container restart อัตโนมัติหรือไม่:** ✅ ใช่
- **Restart Count:** 1 (หรือมากกว่า ขึ้นอยู่กับจำนวนครั้งที่ทดสอบ)

**ตรวจสอบ Restart Count:**
```bash
$ docker inspect concert-web -f '{{.RestartCount}}'
```

---

**17. ทดสอบ Availability API (3 คะแนน)**

**เฉลย:**
```bash
$ curl http://localhost:8347/api/tests/availability | jq
```

**ผลที่ได้:**
```json
{
  "healthEndpoint": {
    "status": "responding",
    "responseCode": 200
  },
  "databaseConnection": {
    "status": "connected",
    "responseTime": 5-20
  },
  "containerHealth": {
    "web": "running",
    "db": "running",
    "note": "Use docker-compose ps to verify health status"
  }
}
```

**คำตอบ:**
- **Health Endpoint Response Code:** 200
- **Database Connection Status:** connected
- **Database Response Time:** 5-20 ms (ค่าอาจแตกต่างกัน)

---

## ส่วนที่ 5: Scalability Testing (15 คะแนน)

### คำถาม 5.1: Database Connection Pool

**18. ทดสอบ Scalability และบันทึกผล (6 คะแนน)**

**เฉลย:**
```bash
$ curl http://localhost:8347/api/tests/scalability | jq
```

**ผลที่คาดหวัง:**

**Database Connection Pool Test:**
- Success: 17/20
- Failed: 3/20
- Success Rate: 85% (ต้อง ≥90%)
- ผ่านหรือไม่: ❌ **ไม่ผ่าน**

**Sustained Load Test:**
- Success: 45/50
- Failed: 5/50
- Success Rate: 90% (ต้อง ≥95%)
- ผ่านหรือไม่: ❌ **ไม่ผ่าน**

**หมายเหตุ:**
- มีการจำลองความล้มเหลวจงใจใน code
- DB Pool: ล้มเหลวที่ i=5, 12, 18 (server.js:212-214)
- Load Test: ล้มเหลวทุก 10 requests (i%10===9) (server.js:230-232)

---

**19. ทดสอบการ Scale Web Service (6 คะแนน)**

**เฉลย:**
```bash
$ docker-compose up -d --scale web=3
```

**ผลที่ได้:**
```
ERROR: for concert-web  Cannot start service web: driver failed programming external connectivity
on endpoint t-sa_web_2: Bind for 0.0.0.0:8347 failed: port is already allocated
```

**คำตอบ:**
- **สามารถ scale ได้หรือไม่:** ❌ ไม่
- **จำนวน containers ที่รันอยู่:** 1
- **Error Message:**
  ```
  Cannot start service web: driver failed programming external connectivity
  Bind for 0.0.0.0:8347 failed: port is already allocated
  ```

---

**20. ถ้าไม่สามารถ scale ได้ สาเหตุคืออะไร? (3 คะแนน)**

**เฉลย:**

**สาเหตุ:**

1. **Fixed Port Mapping Conflict:**
   - docker-compose.yml กำหนด port mapping แบบ fixed: "8347:8347"
   - เมื่อ scale เป็น 3 replicas ทั้ง 3 containers พยายามใช้ port 8347 บน host
   - Docker ไม่อนุญาตให้หลาย containers bind port เดียวกัน
   - Container แรกได้ port ไปแล้ว, containers ที่ 2 และ 3 ไม่สามารถ start ได้

2. **Solution:**
   - ลบ fixed port mapping ออก
   - ใช้ reverse proxy (Nginx/HAProxy) เป็น load balancer
   - Reverse proxy expose port 8347, แล้วแบ่ง traffic ไปยัง web containers
   - Web containers ไม่ต้อง expose ports ออกนอก

**ตัวอย่างการแก้:**
```yaml
services:
  nginx:
    image: nginx:alpine
    ports:
      - "8347:80"
    depends_on:
      - web

  web:
    # ลบ ports ออก
    expose:
      - "8347"
```

**การให้คะแนน:**
- อธิบายสาเหตุ port conflict ได้: 2 คะแนน
- แนะนำวิธีแก้ไข (load balancer): 1 คะแนน

---

## ส่วนที่ 6: Container Resource Monitoring (10 คะแนน)

### คำถาม 6.1: Resource Usage

**21. ตรวจสอบการใช้ทรัพยากรของ Containers (7 คะแนน)**

**เฉลย:**
```bash
$ docker stats --no-stream concert-web concert-db
```

**ผลที่คาดหวัง (ค่าจะแตกต่างกันในแต่ละเครื่อง):**

**Web Container:**
- CPU Usage: 0.05-2.00%
- Memory Usage: 40-80 MiB / xxxxx MiB
- Memory Percentage: 0.5-2%
- Network I/O (RX/TX): xxxx / xxxx

**DB Container:**
- CPU Usage: 0.01-1.00%
- Memory Usage: 20-50 MiB / xxxxx MiB
- Memory Percentage: 0.3-1.5%
- Network I/O (RX/TX): xxxx / xxxx

**หมายเหตุ:** ค่าจะขึ้นอยู่กับ:
- ระบบปฏิบัติการ
- Hardware ของเครื่อง
- Load ที่มีอยู่ในขณะนั้น
- ไม่มีคำตอบที่ตายตัว

**การให้คะแนน:** ให้คะแนนถ้ารัน docker stats และบันทึกค่าได้

---

**22. ตรวจสอบ Container Logs (3 คะแนน)**

**เฉลย:**
```bash
$ docker logs --tail 5 concert-web
$ docker logs --tail 5 concert-db
```

**ผลตัวอย่าง:**

**Web Container:**
```
Server is running on port 8347
Database initialized successfully
Sample data inserted successfully
```

**DB Container:**
```
LOG:  database system is ready to accept connections
```

**คำตอบ:**
- **Web Container มี Error หรือ Warning หรือไม่:** ❌ ไม่ (ถ้า setup ถูกต้อง)
- **DB Container มี Error หรือ Warning หรือไม่:** ❌ ไม่ (ถ้า setup ถูกต้อง)

**หมายเหตุ:** ถ้ามี errors ให้คะแนนได้ถ้าบันทึกและอธิบายได้ถูกต้อง

---

## ส่วนที่ 7: Advanced Docker Commands (5 คะแนน)

### คำถาม 7.1: Inspection และ Debugging

**23. ดูข้อมูลทั้งหมดของ Web Container (2 คะแนน)**

**เฉลย:**
```bash
$ docker inspect concert-web | jq '.[0]' | head -30
```

**คำตอบ (ตัวอย่าง - ค่าจริงจะแตกต่างกัน):**
- **Container ID (12 ตัวแรก):** abc123def456 (จะแตกต่างกันในแต่ละเครื่อง)
- **Image:** t-sa-web หรือ t-sa_web
- **Created:** 2024-xx-xxTxx:xx:xx.xxxxxxxZ
- **Restart Count:** 0 (หรือมากกว่าถ้าเคย restart)
- **Restart Policy:** unless-stopped

---

**24. ตรวจสอบ Process ที่รันอยู่ใน Container (1 คะแนน)**

**เฉลย:**
```bash
$ docker exec concert-web ps aux
```

**ผลที่ได้:**
```
PID   USER     TIME  COMMAND
    1 root      0:00 node server.js
   xx root      0:00 ps aux
```

**คำตอบ:**
- **PID ของ node process:** 1
- **จำนวน process ทั้งหมด:** 2 (หรือมากกว่า ขึ้นอยู่กับเวลาที่รัน ps)

---

**25. ตรวจสอบ File System ใน Container (2 คะแนน)**

**เฉลย:**
```bash
$ docker exec concert-web ls -la /app
```

**ผลที่ได้:**
```
drwxr-xr-x    1 root     root          xxxx xxx xx xx:xx .
drwxr-xr-x    1 root     root          xxxx xxx xx xx:xx ..
drwxr-xr-x    x root     root          xxxx xxx xx xx:xx node_modules
-rw-r--r--    1 root     root          xxxx xxx xx xx:xx package.json
-rw-r--r--    1 root     root          xxxx xxx xx xx:xx server.js
drwxr-xr-x    x root     root          xxxx xxx xx xx:xx views
...
```

**คำตอบ:**
- **มีไฟล์ package.json หรือไม่:** ✅ ใช่
- **มีโฟลเดอร์ node_modules หรือไม่:** ✅ ใช่
- **มีโฟลเดอร์ views หรือไม่:** ✅ ใช่

---

## สรุปการให้คะแนน

### การแบ่งคะแนนตามส่วน

| ส่วน | หัวข้อ | คะแนน |
|------|--------|-------|
| 1 | System Inspection | 25 |
| 2 | Networking | 15 |
| 3 | Performance | 15 |
| 4 | Availability | 15 |
| 5 | Scalability | 15 |
| 6 | Resource Monitoring | 10 |
| 7 | Advanced Commands | 5 |
| **รวม** | | **100** |

### เกณฑ์การให้คะแนน

**คะแนนเต็ม (100 คะแนน):**
- run ระบบได้สำเร็จ
- ตรวจสอบและบันทึกค่าได้ถูกต้องครบทุกข้อ
- วิเคราะห์ผลการทดสอบได้ถูกต้อง
- อธิบายปัญหาและแนะนำแก้ไขได้ดี

**A (80-100 คะแนน):**
- Run และ inspect ได้ครบทุกข้อ
- บันทึกค่าถูกต้อง
- วิเคราะห์และอธิบายได้ดี

**B (70-79 คะแนน):**
- Run และ inspect ได้ส่วนใหญ่
- บันทึกค่าถูกต้องเกือบทั้งหมด
- วิเคราะห์ได้พอสมควร

**C (60-69 คะแนน):**
- Run ระบบได้
- ตรวจสอบและบันทึกค่าได้บางส่วน
- วิเคราะห์พื้นฐานได้

**D (50-59 คะแนน):**
- Run ระบบได้ยาก หรือมีปัญหา
- ตรวจสอบได้เพียงบางส่วน

**F (<50 คะแนน):**
- ไม่สามารถ run ระบบได้
- หรือไม่สามารถตรวจสอบและบันทึกค่าได้

---

## หมายเหตุสำหรับผู้ตรวจ

### ค่าที่ไม่มีคำตอบตายตัว (ให้คะแนนถ้าตรวจสอบได้)

1. **Network Subnet/Gateway** - แตกต่างกันในแต่ละเครื่อง
2. **Container IP addresses** - dynamic allocation
3. **Uptime** - ขึ้นอยู่กับเวลาที่รัน
4. **Response times** - ขึ้นอยู่กับ hardware
5. **Memory/CPU usage** - ขึ้นอยู่กับ system load
6. **Container ID** - unique ทุกครั้ง

### ค่าที่ต้องตรงกับที่กำหนด (ตรวจให้เข้มงวด)

1. **Ports:** 8347, 54321
2. **BUILD_ID:** BLD-2024-X9K7M3
3. **APP_VERSION:** 2.4.7
4. **DEPLOY_ENV:** exam-production
5. **DB_INSTANCE_ID:** PGDB-X7M9K4N2
6. **DB_CLUSTER:** exam-cluster-01
7. **Pool Max:** 20
8. **Pool Idle Timeout:** 30000

### ผลการทดสอบที่ควรได้

**Performance:**
- Health check: ✅ ผ่าน (~50-200ms < 500ms)
- Concerts API: ⚠️ ใกล้เคียง/ไม่ผ่าน (~900ms ใกล้ 1000ms)
- Concurrent: ❌ ไม่ผ่าน (8/10)

**Availability:**
- ผ่านทั้งหมด ✅

**Scalability:**
- DB Pool: ❌ ไม่ผ่าน (85% < 90%)
- Load: ❌ ไม่ผ่าน (90% < 95%)
- Scale web: ❌ ไม่สามารถทำได้ (port conflict)

---

**สิ้นสุดเฉลย - เอกสารนี้สำหรับอาจารย์/ผู้สอนเท่านั้น**
