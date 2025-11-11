# คู่มือสำหรับผู้ใช้ Windows

คู่มือนี้สำหรับนักศึกษาที่ใช้ Windows ในการทำข้อสอบ

---

## วิธีรัน Test Scripts บน Windows

มี **4 วิธีหลัก** ในการรันสคริปต์ทดสอบบน Windows:

### ✅ วิธีที่ 1: ใช้ PowerShell (แนะนำที่สุดสำหรับ Windows)

ผมได้สร้าง PowerShell scripts (`.ps1`) ไว้ให้แล้วใน `test-scripts/` folder

#### ขั้นตอนการใช้งาน:

1. **เปิด PowerShell** (ไม่ต้อง Run as Administrator)

2. **อนุญาตให้รัน scripts** (ครั้งแรกเท่านั้น):
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```
   - พิมพ์ `Y` แล้วกด Enter เมื่อถูกถาม

3. **รัน test scripts**:
   ```powershell
   # ไปที่โฟลเดอร์โปรเจค
   cd path\to\t-sa

   # รันการทดสอบ Performance
   .\test-scripts\performance-test.ps1

   # รันการทดสอบ Availability
   .\test-scripts\availability-test.ps1

   # รันการทดสอบ Scalability
   .\test-scripts\scalability-test.ps1

   # หรือรันทั้งหมดพร้อมกัน
   .\test-scripts\run-all-tests.ps1
   ```

#### ข้อดี:
- ✅ Native Windows - ไม่ต้องติดตั้งอะไรเพิ่ม
- ✅ รองรับ colors และ formatting สวยงาม
- ✅ ทำงานได้เหมือน shell scripts

#### ข้อเสีย:
- ⚠️ ต้อง Set-ExecutionPolicy ครั้งแรก

---

### ✅ วิธีที่ 2: ใช้ Git Bash (แนะนำถ้าติดตั้ง Git แล้ว)

Git Bash มากับ Git for Windows อยู่แล้ว (ส่วนใหญ่มีติดตั้งอยู่แล้ว)

#### ขั้นตอนการใช้งาน:

1. **เปิด Git Bash**
   - คลิกขวาที่โฟลเดอร์โปรเจค → "Git Bash Here"
   - หรือเปิดจากเมนู Start

2. **รัน shell scripts** (ไม่ต้อง chmod):
   ```bash
   # ใช้ shell scripts แบบเดียวกับ Linux/Mac
   bash test-scripts/performance-test.sh
   bash test-scripts/availability-test.sh
   bash test-scripts/scalability-test.sh

   # หรือรันทั้งหมด
   bash test-scripts/run-all-tests.sh
   ```

#### ข้อดี:
- ✅ ง่ายที่สุด
- ✅ ไม่ต้อง `chmod +x`
- ✅ ใช้คำสั่งเหมือน Linux/Mac

#### ข้อเสีย:
- ⚠️ ต้องมี Git for Windows ติดตั้งอยู่
- ⚠️ บาง command อาจทำงานช้ากว่า PowerShell

---

### ✅ วิธีที่ 3: ใช้ WSL (Windows Subsystem for Linux)

สำหรับผู้ที่ต้องการประสบการณ์ Linux แบบเต็มรูปแบบ

#### ขั้นตอนการติดตั้ง WSL2:

1. **เปิด PowerShell as Administrator** แล้วรัน:
   ```powershell
   wsl --install
   ```

2. **Restart เครื่อง**

3. **เปิด Ubuntu terminal** (จะติดตั้งให้อัตโนมัติ)

4. **Setup username/password** ตามที่ขอ

5. **ติดตั้ง Docker Desktop** (มันจะ integrate กับ WSL2 อัตโนมัติ)

#### ขั้นตอนการใช้งาน:

```bash
# เข้าไปที่โฟลเดอร์โปรเจค (ใน WSL)
cd /mnt/c/path/to/t-sa

# ให้สิทธิ์ execute
chmod +x test-scripts/*.sh

# รัน scripts
./test-scripts/performance-test.sh
./test-scripts/availability-test.sh
./test-scripts/scalability-test.sh

# หรือรันทั้งหมด
./test-scripts/run-all-tests.sh
```

#### ข้อดี:
- ✅ Linux แท้ๆ บน Windows
- ✅ รองรับคำสั่งทุกอย่างเหมือน Linux
- ✅ Performance ดีกว่า Git Bash

#### ข้อเสีย:
- ⚠️ ต้องติดตั้ง WSL2 ก่อน (ใช้เวลาประมาณ 10-15 นาที)
- ⚠️ ต้องใช้ Windows 10 version 2004+ หรือ Windows 11

---

### ❌ วิธีที่ 4: รันใน Docker Container (ไม่แนะนำ)

วิธีนี้ซับซ้อนเกินความจำเป็น เพราะต้อง:
1. สร้าง Dockerfile สำหรับรัน scripts
2. Mount volumes
3. Network configuration

**สรุป: ไม่คุ้ม ใช้วิธีอื่นดีกว่า**

---

## คำแนะนำตามระดับความเชี่ยวชาญ

### 👶 ผู้เริ่มต้น (Beginner)
→ ใช้ **Git Bash** (วิธีที่ 2)
- ง่ายที่สุด
- ส่วนใหญ่มี Git ติดตั้งอยู่แล้ว
- คำสั่งเหมือน Linux

### 👨‍💻 ผู้ใช้ทั่วไป (Intermediate)
→ ใช้ **PowerShell** (วิธีที่ 1)
- Native Windows
- Performance ดี
- เรียนรู้ PowerShell ไปด้วย

### 🧙 ผู้เชี่ยวชาญ (Advanced)
→ ใช้ **WSL2** (วิธีที่ 3)
- Linux แท้ๆ
- เหมาะกับการพัฒนาจริง
- รองรับทุกอย่างเหมือน production

---

## ตัวอย่างการใช้งานบน Windows

### เริ่มระบบ Docker

```powershell
# PowerShell หรือ CMD
docker-compose up -d

# ตรวจสอบสถานะ
docker-compose ps

# ดู logs
docker-compose logs -f
```

### รันการทดสอบ

**แบบที่ 1: PowerShell**
```powershell
.\test-scripts\run-all-tests.ps1
```

**แบบที่ 2: Git Bash**
```bash
bash test-scripts/run-all-tests.sh
```

**แบบที่ 3: WSL**
```bash
./test-scripts/run-all-tests.sh
```

### เข้าใช้งานระบบ

เปิด Browser:
```
http://localhost:3000
```

### หยุดระบบ

```powershell
# หยุด containers
docker-compose down

# หยุดและลบ data
docker-compose down -v
```

---

## การแก้ปัญหา (Troubleshooting)

### ปัญหา: PowerShell ไม่ให้รัน script

**อาการ:**
```
cannot be loaded because running scripts is disabled on this system
```

**วิธีแก้:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

### ปัญหา: Git Bash หา `bc` ไม่เจอ

**อาการ:**
```
bc: command not found
```

**วิธีแก้:**
ใช้ PowerShell scripts แทน (`.ps1`) หรือติดตั้ง bc:
```bash
# ใน Git Bash
curl -O http://gnuwin32.sourceforge.net/downlinks/bc.php
```

หรือใช้ WSL แทน

---

### ปัญหา: Port 3000 ถูกใช้อยู่

**อาการ:**
```
Error: bind: address already in use
```

**วิธีแก้ (PowerShell):**
```powershell
# หา process ที่ใช้ port 3000
netstat -ano | findstr :3000

# Kill process (ใส่ PID จากคำสั่งด้านบน)
taskkill /PID <PID> /F
```

**วิธีแก้ (Git Bash/WSL):**
```bash
# หา และ kill process
netstat -ano | grep :3000
```

---

### ปัญหา: Docker ไม่ทำงาน

**ตรวจสอบ:**
1. Docker Desktop ต้อง**เปิดอยู่**
2. Docker Desktop ต้อง**รันเสร็จ** (ดูที่ system tray)
3. WSL2 integration ต้อง**เปิดใช้งาน** (ใน Docker Desktop Settings)

**วิธีตรวจสอบ:**
```powershell
docker --version
docker ps
```

---

## เปรียบเทียบ Shell Scripts vs PowerShell Scripts

| Feature | Shell Scripts (.sh) | PowerShell Scripts (.ps1) |
|---------|-------------------|------------------------|
| Windows Support | ต้องใช้ Git Bash/WSL | Native Windows |
| Performance | ปานกลาง-ดี | ดีมาก |
| Colors | ดี | ดีมาก |
| JSON Parsing | ต้องมี `jq` | Built-in |
| Easy to Use | ง่าย | ง่าย |
| ผลลัพธ์ | เหมือนกัน | เหมือนกัน |

**สรุป:** ทั้งสองแบบ**ให้ผลเหมือนกัน** เลือกตามความถนัด!

---

## ไฟล์ Scripts ที่มีให้

### Shell Scripts (สำหรับ Git Bash / WSL / Linux / Mac)
- `test-scripts/performance-test.sh`
- `test-scripts/availability-test.sh`
- `test-scripts/scalability-test.sh`
- `test-scripts/run-all-tests.sh`

### PowerShell Scripts (สำหรับ Windows PowerShell / CMD)
- `test-scripts/performance-test.ps1`
- `test-scripts/availability-test.ps1`
- `test-scripts/scalability-test.ps1`
- `test-scripts/run-all-tests.ps1`

**หมายเหตุ:** ทั้งสองแบบทำงานเหมือนกัน เลือกตามสะดวก!

---

## คำแนะนำเพิ่มเติม

### 💡 Tips สำหรับ Windows Users

1. **ใช้ Windows Terminal** แทน CMD ธรรมดา
   - ดาวน์โหลดฟรีจาก Microsoft Store
   - รองรับ tabs, colors, และ fonts สวยๆ
   - รวม PowerShell, CMD, Git Bash, WSL ในที่เดียว

2. **ติดตั้ง Docker Desktop**
   - จำเป็นสำหรับการรัน containers
   - ดาวน์โหลด: https://www.docker.com/products/docker-desktop

3. **อ่าน Output อย่างละเอียด**
   - PowerShell scripts มี colors ช่วยดู
   - สีเขียว = ผ่าน
   - สีแดง = ไม่ผ่าน
   - สีเหลือง = คำเตือน

4. **บันทึก Output**
   ```powershell
   # บันทึก output ลงไฟล์
   .\test-scripts\run-all-tests.ps1 | Tee-Object -FilePath results.txt
   ```

---

## Resources สำหรับ Windows Users

- [Git for Windows](https://git-scm.com/download/win)
- [Windows Terminal](https://aka.ms/terminal)
- [Docker Desktop for Windows](https://docs.docker.com/desktop/install/windows-install/)
- [WSL2 Installation Guide](https://docs.microsoft.com/en-us/windows/wsl/install)
- [PowerShell Documentation](https://docs.microsoft.com/en-us/powershell/)

---

## สรุป Quick Start สำหรับ Windows

```powershell
# 1. เปิด PowerShell
# 2. ไปที่โฟลเดอร์โปรเจค
cd path\to\t-sa

# 3. Set execution policy (ครั้งแรกเท่านั้น)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 4. เริ่ม Docker containers
docker-compose up -d

# 5. รันการทดสอบทั้งหมด
.\test-scripts\run-all-tests.ps1

# 6. เปิด Browser ไปที่
# http://localhost:3000
```

**หรือใช้ Git Bash:**

```bash
# 1. เปิด Git Bash
# 2. ไปที่โฟลเดอร์โปรเจค
cd /c/path/to/t-sa

# 3. เริ่ม Docker containers
docker-compose up -d

# 4. รันการทดสอบทั้งหมด
bash test-scripts/run-all-tests.sh
```

---

**ถ้ายังติดปัญหา ลองดูที่ README.md หรือถามอาจารย์ได้ครับ!**
