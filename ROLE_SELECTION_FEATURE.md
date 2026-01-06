# 🔐 ROLE SELECTION FEATURE - LOGIN UPDATE

## ✨ NEW FEATURE: Pilih Role saat Login

Sekarang saat login, kamu bisa **memilih role** sebagai:

- 👶 **Anak** (Child Dashboard)
- 👨‍👩‍👧 **Orang Tua** (Parent Dashboard)

---

## 📝 CARA MENGGUNAKAN

### 1. **Saat Login Screen**

- Kamu akan melihat 2 tombol pilihan:
  - `👶 Anak`
  - `👨‍👩‍👧 Orang Tua`
- **Klik salah satu** sesuai role yang ingin diakses
- Tombol yang dipilih akan **highlight dengan warna biru**

### 2. **Isi Email & Password**

- Masukkan email: `user@example.com`
- Masukkan password: `password`
- Klik **Masuk**

### 3. **Navigasi Otomatis**

Setelah login berhasil, sistem akan otomatis membawa kamu ke:

- **Jika pilih "Anak"** → Dashboard Anak (Home screen)
- **Jika pilih "Orang Tua"** → Dashboard Orang Tua (Parent screen)

---

## 🎯 TESTING SEKARANG

**Quick Test:**

```
Email: user@example.com
Password: password

Pilih: Orang Tua (👨‍👩‍👧)
Tekan: Masuk
Hasil: Masuk ke Parent Dashboard ✅
```

---

## 📁 FILES UPDATED

### `lib/views/screens/auth/login_screen.dart`

**Changes:**

- ✅ Added `_selectedRole` state variable
- ✅ Added Role Selection buttons (Anak/Orang Tua)
- ✅ Updated `_navigateToHome()` untuk routing berdasarkan role
- ✅ Beautiful tab-style selector dengan icons

### `lib/views/screens/auth/register_screen.dart`

**Status:** ✅ Already has role selection (tidak perlu update)

---

## 🎨 UI UPDATE

Role selector di login screen sekarang menampilkan:

```
┌─────────────────────────────────┐
│   Login Sebagai                 │
├─────────────────────────────────┤
│  [👶 Anak] [👨‍👩‍👧 Orang Tua]     │
│   ✓ Active                      │
└─────────────────────────────────┘
```

---

## 🚀 ROUTES YANG DIGUNAKAN

Setelah login dengan role yang dipilih:

| Role          | Route     | Screen              |
| ------------- | --------- | ------------------- |
| **Anak**      | `/child`  | Dashboard Anak      |
| **Orang Tua** | `/parent` | Dashboard Orang Tua |

Routes ini sudah ada di `main.dart`:

```dart
GetPage(name: '/child', page: () => const HomeScreen(initialRole: 'child')),
GetPage(name: '/parent', page: () => const HomeScreen(initialRole: 'parent')),
```

---

## 💡 FITUR TAMBAHAN

Dengan role selection ini, sekarang bisa:

- ✅ Test child dashboard dengan mudah
- ✅ Test parent dashboard dengan mudah
- ✅ Switch role hanya dengan logout dan login lagi
- ✅ Simulasi both perspectives

---

## ⚙️ IMPLEMENTATION DETAIL

### Code yang ditambahkan:

**1. State Variable:**

```dart
String _selectedRole = 'child'; // Default: anak
```

**2. Role Selector Widget:**

```dart
Container(
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12),
    color: const Color(0xFFF3F4F6),
  ),
  padding: const EdgeInsets.all(4),
  child: Row(
    children: [
      // Button Anak
      Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _selectedRole = 'child'),
          child: Container(
            // styling...
            child: Row(
              children: [
                Icon(Icons.child_care),
                Text('Anak'),
              ],
            ),
          ),
        ),
      ),
      // Button Orang Tua (similar)
    ],
  ),
)
```

**3. Navigation Logic:**

```dart
void _navigateToHome() {
  if (_selectedRole == 'parent') {
    Navigator.pushReplacementNamed(context, '/parent');
  } else {
    Navigator.pushReplacementNamed(context, '/child');
  }
}
```

---

## ✅ STATUS

- ✅ Login screen updated dengan role selector
- ✅ Navigation logic updated
- ✅ Routes ready di main.dart
- ✅ Both parent & child dashboards accessible
- ✅ Ready untuk testing!

---

## 🎯 NEXT TIME

Untuk testing, gunakan flow:

1. **Logout** → Back to login
2. **Pilih role** (Anak atau Orang Tua)
3. **Login** → Masuk ke dashboard sesuai role

Mudah! 🎉
