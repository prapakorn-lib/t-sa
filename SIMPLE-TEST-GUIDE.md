# วิธีรัน Test Scripts ด้วย Docker (แบบง่าย - ใช้ได้ทุก Platform)

วิธีนี้ **ใช้ได้กับ Windows, Mac, Linux** เหมือนกันหมด ไม่ต้องติดตั้งอะไรเพิ่มนอกจาก Docker!

---

## 🚀 Quick Start

### 1. เริ่มระบบ

```bash
docker-compose up -d
```

### 2. รันการทดสอบ

#### วิธีง่ายที่สุด: ใช้ Helper Scripts

**Linux/Mac/WSL:**
```bash
# ให้สิทธิ์ execute ครั้งแรก
chmod +x test-scripts/docker-test-runner.sh

# รันการทดสอบ
./test-scripts/docker-test-runner.sh performance
./test-scripts/docker-test-runner.sh availability
./test-scripts/docker-test-runner.sh scalability
./test-scripts/docker-test-runner.sh all
```

**Windows (PowerShell):**
```powershell
# รันการทดสอบ
.\test-scripts\docker-test-runner.ps1 performance
.\test-scripts\docker-test-runner.ps1 availability
.\test-scripts\docker-test-runner.ps1 scalability
.\test-scripts\docker-test-runner.ps1 all
```

---

## 📝 คำสั่งแบบเต็ม (ถ้าต้องการ Customize)

### Performance Testing

```bash
docker run --rm --network="host" -v "${PWD}/test-scripts:/scripts" ubuntu:22.04 bash -c "apt-get update > /dev/null 2>&1 && apt-get install -y curl bc jq > /dev/null 2>&1 && bash /scripts/performance-test.sh"
```

### Availability Testing

```bash
docker run --rm --network="host" -v "${PWD}/test-scripts:/scripts" -v /var/run/docker.sock:/var/run/docker.sock ubuntu:22.04 bash -c "apt-get update > /dev/null 2>&1 && apt-get install -y curl bc jq docker.io > /dev/null 2>&1 && bash /scripts/availability-test.sh"
```

### Scalability Testing

```bash
docker run --rm --network="host" -v "${PWD}/test-scripts:/scripts" -v /var/run/docker.sock:/var/run/docker.sock ubuntu:22.04 bash -c "apt-get update > /dev/null 2>&1 && apt-get install -y curl bc jq docker.io > /dev/null 2>&1 && bash /scripts/scalability-test.sh"
```

### รันทั้งหมดพร้อมกัน

```bash
docker run --rm --network="host" -v "${PWD}/test-scripts:/scripts" -v /var/run/docker.sock:/var/run/docker.sock ubuntu:22.04 bash -c "apt-get update > /dev/null 2>&1 && apt-get install -y curl bc jq docker.io > /dev/null 2>&1 && bash /scripts/run-all-tests.sh"
```

**หมายเหตุ Windows:**
- ใน **PowerShell**: ใช้ `${PWD}` ได้เลย
- ใน **CMD**: แทนที่ `${PWD}` ด้วย `%cd%`

---

## ✅ ข้อดีของวิธีนี้

1. **ใช้ได้ทุก Platform** - คำสั่งเดียวกันสำหรับ Windows/Mac/Linux
2. **ไม่ต้องติดตั้งอะไรเพิ่ม** - มีแค่ Docker พอ
3. **ไม่ต้อง chmod** - Docker จัดการให้
4. **Environment เหมือนกันหมด** - ทุกคนใช้ Ubuntu 22.04
5. **เรียนรู้ Docker** - ฝึกใช้ Docker commands จริง

---

## 📖 คำอธิบาย

```bash
docker run --rm \                                     # รันแล้วลบ container ทิ้ง
  --network="host" \                                  # ใช้ host network เพื่อเข้าถึง localhost:3000
  -v "${PWD}/test-scripts:/scripts" \                 # Mount test scripts เข้า container
  -v /var/run/docker.sock:/var/run/docker.sock \     # เข้าถึง Docker (สำหรับบางการทดสอบ)
  ubuntu:22.04 \                                      # ใช้ Ubuntu image
  bash -c "commands..."                               # รันคำสั่ง
```

---

## 🔧 Troubleshooting

### ปัญหา: "Cannot connect to Docker daemon"

**สาเหตุ:** Docker Desktop ไม่ได้เปิด

**วิธีแก้:**
1. เปิด Docker Desktop
2. รอจนกว่าจะขึ้น "Docker is running"
3. ทดสอบด้วย `docker ps`

### ปัญหา: "Error response from daemon: invalid mode"

**สาเหตุ:** Windows path ไม่ถูกต้อง

**วิธีแก้ (Windows):**
- ใช้ PowerShell แทน CMD
- หรือแทนที่ `${PWD}` ด้วย path แบบเต็ม เช่น `C:\Users\YourName\t-sa`

### ปัญหา: Tests ไม่เจอ localhost:3000

**สาเหตุ:** Network mode ไม่ถูกต้อง

**วิธีแก้:**
- ตรวจสอบว่า web service รันอยู่: `docker-compose ps`
- ทดสอบด้วย browser: http://localhost:3000

---

## 📚 วิธีการอื่นๆ (ถ้าต้องการ)

ถ้าไม่ต้องการใช้ Docker รัน tests สามารถดูวิธีอื่นได้ที่:
- **[WINDOWS-GUIDE.md](WINDOWS-GUIDE.md)** - วิธีรันด้วย PowerShell, Git Bash, WSL
- **[README.md](README.md)** - คู่มือฉบับเต็ม

---

## 📝 สรุป

**สำหรับนักศึกษา:**
1. ติดตั้ง Docker Desktop
2. Clone/Download โปรเจค
3. เปิด Terminal/PowerShell ไปที่โฟลเดอร์โปรเจค
4. รัน: `docker-compose up -d`
5. รันการทดสอบด้วย helper scripts:
   - Linux/Mac: `./test-scripts/docker-test-runner.sh all`
   - Windows: `.\test-scripts\docker-test-runner.ps1 all`
6. บันทึกผลใน `test-report.md`
7. ตอบคำถามใน `assessment.md`
8. ส่งงาน

**ง่ายมาก!** 🎉
