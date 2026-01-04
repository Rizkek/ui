# 📊 Statistic Insert Logic - NSFW Detection

## 🎯 Overview

Sistem ini akan **hanya menyimpan statistik deteksi NSFW jika level > 0** (Low, Medium, atau High). Level 0 (Safe) **tidak disimpan** untuk menghemat storage dan fokus pada konten bermasalah.

---

## 📋 Insert Logic Flow

```
Screenshot dikirim ke /api/detectnsfw
    ↓
API forward ke Python service
    ↓
Python return detection results
    ↓
Go classifier tentukan NSFW level (0-3)
    ↓
┌─────────────────────────────────┐
│  if nsfwLevel > 0:              │
│    - Level 1 = LOW   → SIMPAN  │
│    - Level 2 = MEDIUM → SIMPAN │
│    - Level 3 = HIGH   → SIMPAN │
│  else:                          │
│    - Level 0 = SAFE   → SKIP   │
└─────────────────────────────────┘
    ↓
updateStatisticDocument() dipanggil
    ↓
Firestore document di-update/create
```

---

## 🔧 Code Changes

### **File:** `detectnsfw.go`

**Sebelum:**
```go
// Update statistics in Firestore (regardless of NSFW level)
// Save setiap detection untuk tracking dan analytics
err = updateStatisticDocument(db, userEmail, application, nsfwLevel)
if err != nil {
    fmt.Printf("Error updating statistics: %v\n", err)
}
```

**Sesudah:**
```go
// Update statistics in Firestore ONLY if NSFW detected (level > 0)
// Level 0 = Safe, tidak perlu disimpan
// Level 1 = Low, Level 2 = Medium, Level 3 = High - semua disimpan
if nsfwLevel > 0 {
    err = updateStatisticDocument(db, userEmail, application, nsfwLevel)
    if err != nil {
        // Log error but don't fail the request
        fmt.Printf("Error updating statistics: %v\n", err)
    } else {
        fmt.Printf("✅ Statistics updated: email=%s, app=%s, level=%d\n", userEmail, application, nsfwLevel)
    }
} else {
    fmt.Printf("ℹ️ Level 0 (Safe) - No statistics saved: email=%s, app=%s\n", userEmail, application)
}
```

---

## 📦 Firestore Document Structure

### **Collection:** `nsfw_stats`

### **Document ID Format:**
```
emailpart_YYYY-MM-DD
```

**Contoh:**
- User: `bagasadhinugraha6@gmail.com`
- Tanggal: January 1, 2025
- Document ID: `bagasadhinugraha6_2025-01-01`

### **Document Fields:**

```json
{
  "userId": "bagasadhinugraha6@gmail.com",
  "date": "January 1, 2025",
  "grandTotal": 33,
  "totalLow": 18,
  "totalMedium": 11,
  "totalHigh": 4,
  "appCounts": {
    "chrome": {
      "total": 4,
      "low": 2,
      "medium": 1,
      "high": 1
    },
    "instagram": {
      "total": 10,
      "low": 7,
      "medium": 2,
      "high": 1
    },
    "tiktok": {
      "total": 8,
      "low": 3,
      "medium": 4,
      "high": 1
    },
    "gallery": {
      "total": 8,
      "low": 6,
      "medium": 2,
      "high": 0
    },
    "twitter": {
      "total": 3,
      "low": 0,
      "medium": 2,
      "high": 1
    }
  }
}
```

---

## 🔄 Insert/Update Logic Detail

### **Scenario 1: Document Belum Ada (First Detection Today)**

**Request:**
```
POST /api/detectnsfw
- email: bagasadhinugraha6@gmail.com
- application: chrome
- nsfw_level: 1 (Low)
```

**Action:** Create new document `bagasadhinugraha6_2025-11-04`

**Initial Document:**
```json
{
  "userId": "bagasadhinugraha6@gmail.com",
  "date": "November 4, 2025",
  "grandTotal": 1,
  "totalLow": 1,
  "totalMedium": 0,
  "totalHigh": 0,
  "appCounts": {
    "chrome": {
      "total": 1,
      "low": 1,
      "medium": 0,
      "high": 0
    }
  }
}
```

---

### **Scenario 2: Document Sudah Ada, App Baru**

**Request:**
```
POST /api/detectnsfw
- email: bagasadhinugraha6@gmail.com
- application: instagram
- nsfw_level: 2 (Medium)
```

**Action:** Update existing document, tambah app baru

**Updated Document:**
```json
{
  "userId": "bagasadhinugraha6@gmail.com",
  "date": "November 4, 2025",
  "grandTotal": 2,          // +1
  "totalLow": 1,
  "totalMedium": 1,         // +1
  "totalHigh": 0,
  "appCounts": {
    "chrome": {
      "total": 1,
      "low": 1,
      "medium": 0,
      "high": 0
    },
    "instagram": {          // NEW APP
      "total": 1,
      "low": 0,
      "medium": 1,
      "high": 0
    }
  }
}
```

---

### **Scenario 3: Document Sudah Ada, App Sudah Ada**

**Request:**
```
POST /api/detectnsfw
- email: bagasadhinugraha6@gmail.com
- application: chrome
- nsfw_level: 3 (High)
```

**Action:** Update existing document, increment counter app chrome

**Updated Document:**
```json
{
  "userId": "bagasadhinugraha6@gmail.com",
  "date": "November 4, 2025",
  "grandTotal": 3,          // +1
  "totalLow": 1,
  "totalMedium": 1,
  "totalHigh": 1,           // +1
  "appCounts": {
    "chrome": {
      "total": 2,           // +1
      "low": 1,
      "medium": 0,
      "high": 1             // +1
    },
    "instagram": {
      "total": 1,
      "low": 0,
      "medium": 1,
      "high": 0
    }
  }
}
```

---

### **Scenario 4: Level 0 (Safe) - NO INSERT**

**Request:**
```
POST /api/detectnsfw
- email: bagasadhinugraha6@gmail.com
- application: whatsapp
- nsfw_level: 0 (Safe)
```

**Action:** ❌ **SKIP** - Tidak insert/update apapun

**Console Log:**
```
ℹ️ Level 0 (Safe) - No statistics saved: email=bagasadhinugraha6@gmail.com, app=whatsapp
```

**Document:** Tidak berubah

---

## 📊 Aggregation Logic

### **Grand Totals:**
- `grandTotal`: Total semua deteksi NSFW (low + medium + high)
- `totalLow`: Total deteksi level 1 semua app
- `totalMedium`: Total deteksi level 2 semua app
- `totalHigh`: Total deteksi level 3 semua app

### **Per-App Counters:**
- `appCounts[appName].total`: Total deteksi app ini
- `appCounts[appName].low`: Total level 1 app ini
- `appCounts[appName].medium`: Total level 2 app ini
- `appCounts[appName].high`: Total level 3 app ini

### **Formula:**
```
grandTotal = totalLow + totalMedium + totalHigh
grandTotal = SUM(appCounts[*].total)

totalLow = SUM(appCounts[*].low)
totalMedium = SUM(appCounts[*].medium)
totalHigh = SUM(appCounts[*].high)
```

---

## 🧪 Testing Guide

### **Test 1: First Detection (Level 1 - Low)**

**Postman Request:**
```http
POST http://192.168.1.36:3000/api/detectnsfw
Authorization: Bearer <JWT_TOKEN>
Content-Type: multipart/form-data

Body:
- image: [upload file]
- application: chrome
```

**Expected Response:**
```json
{
  "nsfw_level": 1,
  "status": "success"
}
```

**Expected Console Log:**
```
✅ Statistics updated: email=user@gmail.com, app=chrome, level=1
```

**Check Firestore:**
1. Buka Firebase Console → Firestore Database
2. Collection: `nsfw_stats`
3. Document ID: `user_2025-11-04`
4. Verify fields:
   - `grandTotal`: 1
   - `totalLow`: 1
   - `appCounts.chrome.total`: 1
   - `appCounts.chrome.low`: 1

---

### **Test 2: Second Detection Same App (Level 2 - Medium)**

**Postman Request:**
```http
POST http://192.168.1.36:3000/api/detectnsfw
Authorization: Bearer <JWT_TOKEN>
Content-Type: multipart/form-data

Body:
- image: [upload file]
- application: chrome
```

**Expected Response:**
```json
{
  "nsfw_level": 2,
  "status": "success"
}
```

**Expected Console Log:**
```
✅ Statistics updated: email=user@gmail.com, app=chrome, level=2
```

**Check Firestore:**
- `grandTotal`: 2 (was 1, now +1)
- `totalLow`: 1 (unchanged)
- `totalMedium`: 1 (was 0, now +1)
- `appCounts.chrome.total`: 2 (was 1, now +1)
- `appCounts.chrome.medium`: 1 (was 0, now +1)

---

### **Test 3: Third Detection New App (Level 3 - High)**

**Postman Request:**
```http
POST http://192.168.1.36:3000/api/detectnsfw
Authorization: Bearer <JWT_TOKEN>
Content-Type: multipart/form-data

Body:
- image: [upload file]
- application: instagram
```

**Expected Response:**
```json
{
  "nsfw_level": 3,
  "status": "success"
}
```

**Check Firestore:**
- `grandTotal`: 3 (was 2, now +1)
- `totalHigh`: 1 (was 0, now +1)
- `appCounts.instagram`: NEW KEY
- `appCounts.instagram.total`: 1
- `appCounts.instagram.high`: 1

---

### **Test 4: Level 0 (Safe) - Should NOT Insert**

**Postman Request:**
```http
POST http://192.168.1.36:3000/api/detectnsfw
Authorization: Bearer <JWT_TOKEN>
Content-Type: multipart/form-data

Body:
- image: [safe image]
- application: whatsapp
```

**Expected Response:**
```json
{
  "nsfw_level": 0,
  "status": "success"
}
```

**Expected Console Log:**
```
ℹ️ Level 0 (Safe) - No statistics saved: email=user@gmail.com, app=whatsapp
```

**Check Firestore:**
- Document `user_2025-11-04` **TIDAK BERUBAH**
- `grandTotal`: 3 (masih sama)
- `appCounts.whatsapp`: **TIDAK ADA** (tidak dibuat)

---

## 🎨 Console Log Examples

### **Success Insert:**
```
📸 Starting first actual capture...
📱 Current app: Chrome
📤 Sending to API: http://192.168.1.36:3000/api/detectnsfw
✅ API call successful: 200
📊 Parsed NSFW Level: 1
🚨 NSFW detected! Triggering alert...
✅ Statistics updated: email=user@gmail.com, app=chrome, level=1
```

### **Skip Level 0:**
```
📸 Starting first actual capture...
📱 Current app: WhatsApp
📤 Sending to API: http://192.168.1.36:3000/api/detectnsfw
✅ API call successful: 200
📊 Parsed NSFW Level: 0
ℹ️ Level 0 (Safe) - No statistics saved: email=user@gmail.com, app=whatsapp
```

---

## 📝 API Endpoint Comparison

### **1. Insert Statistic** (Automatic via `/api/detectnsfw`)
```http
POST /api/detectnsfw
Authorization: Bearer <JWT_TOKEN>
Content-Type: multipart/form-data

Body:
- image: [file]
- application: [text]

Response:
{
  "nsfw_level": 1,
  "status": "success"
}
```

**Side Effect:** If `nsfw_level > 0`, insert/update ke Firestore

---

### **2. Get Statistic** (Manual via `/api/statistic`)
```http
GET /api/statistic?period=today
Authorization: Bearer <JWT_TOKEN>

Response:
{
  "period": "today",
  "email": "user@gmail.com",
  "statistics": {
    "totalGrandTotal": 33,
    "totalLow": 18,
    "totalMedium": 11,
    "totalHigh": 4,
    "appBreakdown": { ... }
  }
}
```

---

### **3. Generate Dummy Statistic** (For Testing)
```http
POST /api/statistic/dummy
Content-Type: application/json

Body:
{
  "email": "user@gmail.com",
  "period": "7days"
}

Response:
{
  "message": "Dummy statistics generation completed",
  "createdCount": 7,
  "skippedCount": 0
}
```

---

## 🚀 Benefits of Level > 0 Only

### **1. Storage Optimization**
- Hemat space Firestore
- Hanya simpan data yang penting (konten bermasalah)
- Safe content (level 0) tidak perlu tracking

### **2. Performance**
- Kurang write operations ke Firestore
- Faster response time
- Reduced billing costs

### **3. Privacy**
- Tidak tracking semua aktivitas user
- Fokus pada konten yang perlu diawasi
- Lebih privacy-friendly

### **4. Data Clarity**
- Dashboard hanya show konten bermasalah
- Clear insight tentang app mana yang paling rawan
- Easier to spot patterns

---

## 🐛 Troubleshooting

### **Problem:** "Statistik tidak tersimpan padahal level > 0"

**Solution:**
1. Check console log: apakah ada error message?
   ```
   Error updating statistics: <error detail>
   ```
2. Verify JWT token valid
3. Check Firestore rules: apakah allow write?
4. Verify email format dari JWT token

---

### **Problem:** "Level 0 masih tersimpan"

**Solution:**
Pastikan code sudah di-update dengan `if nsfwLevel > 0`:
```go
if nsfwLevel > 0 {
    err = updateStatisticDocument(db, userEmail, application, nsfwLevel)
    // ...
}
```

---

### **Problem:** "Document ID format salah"

**Solution:**
Format harus: `emailpart_YYYY-MM-DD`

Check di code:
```go
emailPart := strings.Split(email, "@")[0]
docID := fmt.Sprintf("%s_%04d-%02d-%02d", emailPart, now.Year(), int(now.Month()), now.Day())
```

Example: `bagasadhinugraha6_2025-11-04`

---

## 📞 Summary

✅ **Insert Logic:** Hanya simpan jika `nsfw_level > 0` (1, 2, atau 3)

✅ **Document Format:** Sesuai dengan dummy.go (userId, date, grandTotal, totals, appCounts)

✅ **Aggregation:** Grand totals + per-app breakdown dengan counters (low, medium, high)

✅ **Storage Efficient:** Skip level 0 untuk hemat storage dan fokus pada konten bermasalah

✅ **Console Logging:** Clear feedback untuk debugging dan monitoring

---

**Happy Coding! 🚀**
