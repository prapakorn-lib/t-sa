# แบบประเมินข้อสอบปฏิบัติ Docker
## ระบบจำหน่ายตั๋วคอนเสิร์ต (Concert Ticket Sales System)

**คำเตือน: คำถามทั้งหมดต้องใช้การ run ระบบจริง ไม่สามารถตอบจาก code หรือ config เพียงอย่างเดียว**

---

## ส่วนที่ 1: การตรวจสอบระบบและ Configuration (System Inspection)

**คำสั่งเริ่มต้น:**
```bash
docker-compose up -d --build
docker-compose ps
```

### คำถาม 1.1: Port Configuration (ต้อง inspect จริง)

1. ระบบนี้ใช้ Port อะไรบ้างสำหรับ Web Service? (ต้องตรวจสอบจาก container ที่ running)
   ```bash
   # ใช้คำสั่ง: docker ps หรือ docker-compose ps
   ```
   - **Host Port:** _______
   - **Container Port:** _______

2. Database ใช้ Port อะไร? (ต้องตรวจสอบจาก running container)
   ```bash
   # ใช้คำสั่ง: docker inspect concert-db | grep -A 5 "Ports"
   # หรือ: docker port concert-db
   ```
   - **Database Port:** _______

3. ทดสอบว่าสามารถเข้าถึง Web Service ได้จริงหรือไม่? (ต้องทดสอบด้วย curl หรือ browser)
   ```bash
   # ใช้คำสั่ง: curl http://localhost:[PORT]/health
   ```
   - **Port ที่ใช้ทดสอบ:** _______
   - **Response Status:** _______
   - **Database Status:** _______

---

### คำถาม 1.2: Environment Variables (ต้อง inspect container)

4. Web Container มี Environment Variable อะไรบ้าง? ระบุค่าที่สำคัญ (ต้องใช้ docker inspect)
   ```bash
   # ใช้คำสั่ง: docker inspect concert-web -f '{{.Config.Env}}'
   # หรือ: docker exec concert-web env
   ```
   - **BUILD_ID:** _______________________________
   - **APP_VERSION:** _______________________________
   - **DEPLOY_ENV:** _______________________________
   - **DB_PORT:** _______________________________

5. Database Container ตั้งค่า PGPORT เป็นเท่าไร? (ต้อง inspect)
   ```bash
   # ใช้คำสั่ง: docker inspect concert-db -f '{{.Config.Env}}'
   ```
   - **PGPORT:** _______

6. Database Instance ID และ Cluster Name คืออะไร? (ไม่สามารถดูจาก docker-compose.yml ได้ ต้อง run)
   ```bash
   # ใช้คำสั่ง: docker exec concert-db env | grep DB_
   ```
   - **DB_INSTANCE_ID:** _______________________________
   - **DB_CLUSTER:** _______________________________

---

### คำถาม 1.3: System Info API (ต้องเรียก API จริง)

7. เรียก API `/api/system/info` และบันทึกข้อมูลที่ได้
   ```bash
   # ใช้คำสั่ง: curl http://localhost:[PORT]/api/system/info | jq
   ```

   **Application Info:**
   - Build ID: _______________________________
   - Version: _______________________________
   - Port: _______
   - Node Version: _______________________________
   - Uptime (seconds): _______

   **Database Info:**
   - Host: _______________________________
   - Port: _______
   - Server Port: _______
   - Instance ID: _______________________________
   - Cluster: _______________________________
   - Pool Max Connections: _______
   - Pool Idle Timeout (ms): _______

   **Network Info:**
   - Hostname: _______________________________
   - Platform: _______________________________
   - Architecture: _______________________________

---

## ส่วนที่ 2: Docker Networking และ Architecture

### คำถาม 2.1: Network Inspection

8. Containers ใช้ Network อะไร? (ต้อง inspect)
   ```bash
   # ใช้คำสั่ง: docker network ls
   # และ: docker network inspect t-sa_concert-network
   ```
   - **Network Name:** _______________________________
   - **Network Driver:** _______________________________
   - **Subnet:** _______________________________
   - **Gateway:** _______________________________

9. IP Address ของแต่ละ Container คืออะไร? (ต้อง inspect)
   ```bash
   # ใช้คำสั่ง: docker inspect concert-web -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'
   ```
   - **Web Container IP:** _______________________________
   - **DB Container IP:** _______________________________

10. ทดสอบการเชื่อมต่อระหว่าง Containers (ต้อง exec เข้าไปใน container)
    ```bash
    # เข้าไปใน web container: docker exec -it concert-web sh
    # ping db container: ping -c 3 db
    # หรือทดสอบ: nc -zv db [DB_PORT]
    ```
    - **สามารถ ping ถึง db ได้หรือไม่:** [ ] ใช่  [ ] ไม่
    - **Round-trip time (avg):** _______ ms

---

### คำถาม 2.2: Volume และ Data Persistence

11. Volume อะไรบ้างที่ถูกสร้างขึ้น? (ต้องตรวจสอบจริง)
    ```bash
    # ใช้คำสั่ง: docker volume ls
    # และ: docker volume inspect t-sa_postgres-data
    ```
    - **Volume Name:** _______________________________
    - **Mountpoint:** _______________________________
    - **Driver:** _______________________________

12. ทดสอบ Data Persistence (ต้องทำจริง)
    ```bash
    # 1. สร้างข้อมูลทดสอบ (จองตั๋ว 1 ใบ)
    # 2. docker-compose down
    # 3. docker volume ls (ตรวจสอบว่า volume ยังอยู่)
    # 4. docker-compose up -d
    # 5. ตรวจสอบข้อมูลยังอยู่หรือไม่
    ```
    - **Volume ยังอยู่หลัง down หรือไม่:** [ ] ใช่  [ ] ไม่
    - **ข้อมูล bookings ยังอยู่หรือไม่:** [ ] ใช่  [ ] ไม่

---

## ส่วนที่ 3: Performance Testing (ต้อง run tests จริง)

**⚠️ สำคัญ: เข้า http://localhost:[PORT]/tests และกดปุ่ม "ทดสอบ Performance" หรือใช้ curl**

### คำถาม 3.1: ผลการทดสอบ Performance

13. ทดสอบ Performance และบันทึกผล
    ```bash
    # เข้า: http://localhost:[PORT]/tests
    # กดปุ่ม: ทดสอบ Performance
    # หรือ: curl http://localhost:[PORT]/api/tests/performance | jq
    ```

    **Health Check Test:**
    - Average Response Time: _______ ms
    - Standard (มาตรฐาน): _______ ms
    - ผ่านหรือไม่? (เปรียบเทียบเอง): [ ] ผ่าน  [ ] ไม่ผ่าน

    **Concerts API Test:**
    - Average Response Time: _______ ms
    - Standard (มาตรฐาน): _______ ms
    - ผ่านหรือไม่? (เปรียบเทียบเอง): [ ] ผ่าน  [ ] ไม่ผ่าน

    **Concurrent Requests Test:**
    - Success: _______/10
    - Failed: _______/10
    - ผ่านหรือไม่? (ต้องสำเร็จ 10/10): [ ] ผ่าน  [ ] ไม่ผ่าน

14. วิเคราะห์สาเหตุที่ไม่ผ่าน (ถ้ามี)
    ```
    สาเหตุ:



    วิธีแก้ไข:


    ```

---

## ส่วนที่ 4: Availability Testing (ต้อง run tests จริง)

### คำถาม 4.1: ทดสอบ Health Checks

15. ตรวจสอบ Health Check Configuration
    ```bash
    # ใช้คำสั่ง: docker inspect concert-web -f '{{.State.Health.Status}}'
    # และ: docker inspect concert-db -f '{{.State.Health.Status}}'
    ```
    - **Web Health Status:** _______________________________
    - **DB Health Status:** _______________________________
    - **Web Health Test Command:** _______________________________
    - **DB Health Test Command:** _______________________________

16. ทดสอบ Auto-Restart (ต้องทดสอบจริง)
    ```bash
    # 1. docker stop concert-web
    # 2. รอ 10-20 วินาที
    # 3. docker ps -a | grep concert-web
    # 4. ตรวจสอบว่า container กลับมา running หรือไม่
    ```
    - **Status หลัง stop:** _______________________________
    - **Container restart อัตโนมัติหรือไม่:** [ ] ใช่  [ ] ไม่
    - **Restart Count:** _______

17. ทดสอบ Availability API
    ```bash
    # curl http://localhost:[PORT]/api/tests/availability | jq
    ```
    - **Health Endpoint Response Code:** _______
    - **Database Connection Status:** _______________________________
    - **Database Response Time:** _______ ms

---

## ส่วนที่ 5: Scalability Testing (ต้อง run tests จริง)

### คำถาม 5.1: Database Connection Pool

18. ทดสอบ Scalability และบันทึกผล
    ```bash
    # curl http://localhost:[PORT]/api/tests/scalability | jq
    ```

    **Database Connection Pool Test:**
    - Success: _______/20
    - Failed: _______/20
    - Success Rate: _______% (ต้อง ≥90%)
    - ผ่านหรือไม่: [ ] ผ่าน  [ ] ไม่ผ่าน

    **Sustained Load Test:**
    - Success: _______/50
    - Failed: _______/50
    - Success Rate: _______% (ต้อง ≥95%)
    - ผ่านหรือไม่: [ ] ผ่าน  [ ] ไม่ผ่าน

19. ทดสอบการ Scale Web Service (ต้องทำจริง)
    ```bash
    # docker-compose up -d --scale web=3
    ```
    - **สามารถ scale ได้หรือไม่:** [ ] ใช่  [ ] ไม่
    - **จำนวน containers ที่รันอยู่:** _______
    - **Error Message (ถ้ามี):**
    ```


    ```

20. ถ้าไม่สามารถ scale ได้ สาเหตุคืออะไร? (ต้องวิเคราะห์จาก error)
    ```
    สาเหตุ:



    ```

---

## ส่วนที่ 6: Container Resource Monitoring

### คำถาม 6.1: Resource Usage (ต้อง monitor จริง)

21. ตรวจสอบการใช้ทรัพยากรของ Containers
    ```bash
    # docker stats --no-stream
    # หรือ: docker stats --no-stream concert-web concert-db
    ```

    **Web Container:**
    - CPU Usage: _______%
    - Memory Usage: _______ MiB / _______ MiB
    - Memory Percentage: _______%
    - Network I/O (RX/TX): _______ / _______

    **DB Container:**
    - CPU Usage: _______%
    - Memory Usage: _______ MiB / _______ MiB
    - Memory Percentage: _______%
    - Network I/O (RX/TX): _______ / _______

22. ตรวจสอบ Container Logs (5 บรรทัดล่าสุด)
    ```bash
    # docker logs --tail 5 concert-web
    # docker logs --tail 5 concert-db
    ```
    - **Web Container มี Error หรือ Warning หรือไม่:** [ ] ใช่  [ ] ไม่
    - **DB Container มี Error หรือ Warning หรือไม่:** [ ] ใช่  [ ] ไม่

---

## ส่วนที่ 7: Advanced Docker Commands

### คำถาม 7.1: Inspection และ Debugging

23. ดูข้อมูลทั้งหมดของ Web Container
    ```bash
    # docker inspect concert-web | jq '.[]' | head -30
    ```
    - **Container ID (12 ตัวแรก):** _______________________________
    - **Image:** _______________________________
    - **Created:** _______________________________
    - **Restart Count:** _______
    - **Restart Policy:** _______________________________

24. ตรวจสอบ Process ที่รันอยู่ใน Container
    ```bash
    # docker exec concert-web ps aux
    ```
    - **PID ของ node process:** _______
    - **จำนวน process ทั้งหมด:** _______

25. ตรวจสอบ File System ใน Container
    ```bash
    # docker exec concert-web ls -la /app
    ```
    - **มีไฟล์ package.json หรือไม่:** [ ] ใช่  [ ] ไม่
    - **มีโฟลเดอร์ node_modules หรือไม่:** [ ] ใช่  [ ] ไม่
    - **มีโฟลเดอร์ views หรือไม่:** [ ] ใช่  [ ] ไม่

---

## สรุปผลการประเมิน

### ผลการทดสอบแต่ละหมวด

**Performance Testing**
- [ ] ผ่านทุกการทดสอบ (3/3)
- [ ] ผ่านบางส่วน (_____/3)
- [ ] ไม่ผ่าน

**Availability Testing**
- [ ] ผ่านทุกการทดสอบ
- [ ] ผ่านบางส่วน
- [ ] ไม่ผ่าน

**Scalability Testing**
- [ ] ผ่านทุกการทดสอบ
- [ ] ผ่านบางส่วน
- [ ] ไม่ผ่าน

### คะแนนรวม

- ส่วนที่ 1: System Inspection (25 คะแนน) = _______
- ส่วนที่ 2: Networking (15 คะแนน) = _______
- ส่วนที่ 3: Performance (15 คะแนน) = _______
- ส่วนที่ 4: Availability (15 คะแนน) = _______
- ส่วนที่ 5: Scalability (15 คะแนน) = _______
- ส่วนที่ 6: Resource Monitoring (10 คะแนน) = _______
- ส่วนที่ 7: Advanced Commands (5 คะแนน) = _______

**คะแนนรวมทั้งหมด: _______/100**

---

## ข้อเสนอแนะในการปรับปรุงระบบ

26. จากผลการทดสอบ มีข้อเสนอแนะในการปรับปรุงอย่างไร?
    ```
    1.


    2.


    3.


    ```

---

**หมายเหตุ:**
- ❗ คำถามทุกข้อต้องใช้การ run ระบบจริง
- ❗ ไม่สามารถตอบได้จากการอ่าน code หรือ config เพียงอย่างเดียว
- ❗ ต้องใช้ docker commands เพื่อ inspect, monitor, และทดสอบ
- ❗ Port numbers และ configuration values ต้องได้มาจาก running containers

**คะแนนเต็ม:** 100 คะแนน
