# คู่มือรัน Test Scripts ด้วย Docker (ใช้ได้กับทุก Platform)

วิธีนี้ง่ายที่สุด และใช้ได้กับ **Windows, Mac, Linux** เหมือนกันหมด!

---

## วิธีการ: รัน Test Scripts ผ่าน Docker Container

### ขั้นตอนที่ 1: เริ่มระบบ

```bash
# เริ่ม web และ database services
docker-compose up -d
```

### ขั้นตอนที่ 2: รันการทดสอบ (เลือก 1 ใน 2 วิธี)

#### 🎯 วิธีที่ 1: ใช้ Docker Run แบบง่าย (แนะนำที่สุด)

**รันทดสอบทีละอัน:**

```bash
# Performance Testing
docker run --rm --network="host" -v "${PWD}/test-scripts:/scripts" ubuntu:22.04 bash -c "apt-get update > /dev/null && apt-get install -y curl bc jq > /dev/null 2>&1 && bash /scripts/performance-test.sh"

# Availability Testing
docker run --rm --network="host" -v "${PWD}/test-scripts:/scripts" -v /var/run/docker.sock:/var/run/docker.sock ubuntu:22.04 bash -c "apt-get update > /dev/null && apt-get install -y curl bc jq docker.io > /dev/null 2>&1 && bash /scripts/availability-test.sh"

# Scalability Testing
docker run --rm --network="host" -v "${PWD}/test-scripts:/scripts" -v /var/run/docker.sock:/var/run/docker.sock ubuntu:22.04 bash -c "apt-get update > /dev/null && apt-get install -y curl bc jq docker.io > /dev/null 2>&1 && bash /scripts/scalability-test.sh"

# รันทดสอบทั้งหมดพร้อมกัน
docker run --rm --network="host" -v "${PWD}/test-scripts:/scripts" -v /var/run/docker.sock:/var/run/docker.sock ubuntu:22.04 bash -c "apt-get update > /dev/null && apt-get install -y curl bc jq docker.io > /dev/null 2>&1 && bash /scripts/run-all-tests.sh"
```

**สำหรับ Windows (PowerShell):** ใช้ `${PWD}` แบบเดียวกัน
**สำหรับ Windows (CMD):** แทนที่ `${PWD}` ด้วย `%cd%`

---

#### 🚀 วิธีที่ 2: ใช้ Docker Compose (สะดวกกว่า)

**Build test runner image ครั้งแรก:**
```bash
docker-compose build test-runner
```

**รันการทดสอบ:**

```bash
# รันทดสอบทีละอัน
docker-compose run --rm test-runner bash /workspace/test-scripts/performance-test.sh
docker-compose run --rm test-runner bash /workspace/test-scripts/availability-test.sh
docker-compose run --rm test-runner bash /workspace/test-scripts/scalability-test.sh

# รันทดสอบทั้งหมดพร้อมกัน
docker-compose run --rm test-runner bash /workspace/test-scripts/run-all-tests.sh
```

---

## คำสั่งแบบสั้น (สร้าง Alias)

### สำหรับ Windows (PowerShell)

เพิ่มใน PowerShell Profile:
```powershell
function Test-Performance { docker run --rm --network="host" -v "${PWD}/test-scripts:/scripts" ubuntu:22.04 bash -c "apt-get update > /dev/null && apt-get install -y curl bc jq > /dev/null 2>&1 && bash /scripts/performance-test.sh" }
function Test-Availability { docker run --rm --network="host" -v "${PWD}/test-scripts:/scripts" -v /var/run/docker.sock:/var/run/docker.sock ubuntu:22.04 bash -c "apt-get update > /dev/null && apt-get install -y curl bc jq docker.io > /dev/null 2>&1 && bash /scripts/availability-test.sh" }
function Test-Scalability { docker run --rm --network="host" -v "${PWD}/test-scripts:/scripts" -v /var/run/docker.sock:/var/run/docker.sock ubuntu:22.04 bash -c "apt-get update > /dev/null && apt-get install -y curl bc jq docker.io > /dev/null 2>&1 && bash /scripts/scalability-test.sh" }
function Test-All { docker run --rm --network="host" -v "${PWD}/test-scripts:/scripts" -v /var/run/docker.sock:/var/run/docker.sock ubuntu:22.04 bash -c "apt-get update > /dev/null && apt-get install -y curl bc jq docker.io > /dev/null 2>&1 && bash /scripts/run-all-tests.sh" }
```

แล้วใช้งาน:
```powershell
Test-Performance
Test-Availability
Test-Scalability
Test-All
```

### สำหรับ Linux/Mac (Bash/Zsh)

เพิ่มใน `~/.bashrc` หรือ `~/.zshrc`:
```bash
alias test-performance='docker run --rm --network="host" -v "${PWD}/test-scripts:/scripts" ubuntu:22.04 bash -c "apt-get update > /dev/null && apt-get install -y curl bc jq > /dev/null 2>&1 && bash /scripts/performance-test.sh"'
alias test-availability='docker run --rm --network="host" -v "${PWD}/test-scripts:/scripts" -v /var/run/docker.sock:/var/run/docker.sock ubuntu:22.04 bash -c "apt-get update > /dev/null && apt-get install -y curl bc jq docker.io > /dev/null 2>&1 && bash /scripts/availability-test.sh"'
alias test-scalability='docker run --rm --network="host" -v "${PWD}/test-scripts:/scripts" -v /var/run/docker.sock:/var/run/docker.sock ubuntu:22.04 bash -c "apt-get update > /dev/null && apt-get install -y curl bc jq docker.io > /dev/null 2>&1 && bash /scripts/scalability-test.sh"'
alias test-all='docker run --rm --network="host" -v "${PWD}/test-scripts:/scripts" -v /var/run/docker.sock:/var/run/docker.sock ubuntu:22.04 bash -c "apt-get update > /dev/null && apt-get install -y curl bc jq docker.io > /dev/null 2>&1 && bash /scripts/run-all-tests.sh"'
```

แล้วใช้งาน:
```bash
test-performance
test-availability
test-scalability
test-all
```

---

## คำอธิบายคำสั่ง

```bash
docker run --rm \
  --network="host" \                                    # ใช้ host network เพื่อเข้าถึง localhost:3000
  -v "${PWD}/test-scripts:/scripts" \                   # Mount test scripts เข้า container
  -v /var/run/docker.sock:/var/run/docker.sock \       # ให้เข้าถึง Docker daemon (สำหรับ availability & scalability tests)
  ubuntu:22.04 \                                        # ใช้ Ubuntu 22.04 image
  bash -c "apt-get update > /dev/null && \              # ติดตั้ง dependencies
           apt-get install -y curl bc jq docker.io > /dev/null 2>&1 && \
           bash /scripts/run-all-tests.sh"              # รัน test script
```

---

## ข้อดีของวิธีนี้

✅ **ใช้ได้กับทุก Platform** - Windows, Mac, Linux เหมือนกันหมด
✅ **ไม่ต้องติดตั้งอะไรเพิ่ม** - มีแค่ Docker พอ
✅ **ไม่ต้องกังวลเรื่อง chmod** - Docker จัดการให้
✅ **Environment เหมือนกันหมด** - ทุกคนใช้ Ubuntu 22.04
✅ **เรียนรู้ Docker** - ฝึกใช้ Docker commands

---

## หมายเหตุ

- คำสั่งจะติดตั้ง dependencies (curl, bc, jq, docker.io) ทุกครั้งที่รัน
- ถ้าต้องการเร็วขึ้น ใช้วิธีที่ 2 (Docker Compose) แทน เพราะ build image ไว้แล้ว
- สำหรับ Performance test ไม่ต้อง mount docker.sock ก็ได้
