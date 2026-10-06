# Piket Kelas

Website jadwal piket kelas untuk 5–31 Oktober 2026. Menampilkan siapa yang **piket**, **tidak piket**, atau **kabur**.

- Pengunjung hanya bisa melihat jadwal.
- Admin masuk lewat tombol **Admin** (password: `naz`) dan bisa mengedit jadwal setiap hari.
- Menu edit baru dibuat setelah password benar, dan semua perubahan dicek password-nya di database, bukan hanya di tampilan.

## File

| File | Fungsi |
|---|---|
| `index.html` | Seluruh website (HTML, CSS, JS) |
| `schema.sql` | Tabel, aturan keamanan, dan password admin di Supabase |
| `README.md` | Panduan ini |

## Cara pasang

1. Buat project gratis di [supabase.com](https://supabase.com).
2. Buka **SQL Editor**, tempel isi `schema.sql`, lalu klik **Run**.
3. Buka **Project Settings → API**, salin **Project URL** dan **anon / publishable key**.
4. Di `index.html`, isi dua baris ini:
   ```js
   const SUPABASE_URL = "https://xxxx.supabase.co";
   const SUPABASE_KEY = "kunci-anon-kamu";
   ```
5. Upload `index.html` ke Vercel (atau GitHub yang tersambung ke Vercel) dan deploy ulang.

## Cara pakai admin

1. Klik **Admin**, masukkan password.
2. Pilih tanggal (5–31 Oktober 2026).
3. Klik **+ Tambah siswa**, pilih nama dan status, lalu **Simpan**.
4. Nama siswa baru ditambahkan di bagian **Daftar siswa**.
5. Klik **Lihat sebagai siswa** untuk keluar dari tampilan admin.

## Ganti password admin

Jalankan di SQL Editor (ganti `passwordbaru`):

```sql
update public.settings
set value = extensions.crypt('passwordbaru', extensions.gen_salt('bf'))
where key = 'admin_password_hash';
```

## Perpanjang tanggal

Ubah `START` dan `END` di `index.html`, serta batas tanggal `2026-10-05` dan `2026-10-31` di fungsi `admin_save_date` pada `schema.sql`.

## Catatan keamanan

Password `naz` pendek dan mudah ditebak. Kalau situs dipakai banyak orang, ganti dengan password yang lebih panjang.
