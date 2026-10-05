# Website Piket Kelas — versi siap database

File `index.html` adalah frontend yang sudah punya tampilan siswa + panel admin demo.
File `schema.sql` adalah struktur tabel untuk Supabase.

PENTING:
Versi ini belum online dan belum menyimpan ke database internet. Password `piket123` hanya password demo dan BUKAN keamanan nyata.

Agar benar-benar online:
1. Buat project Supabase gratis.
2. Jalankan `schema.sql` di SQL Editor.
3. Buat akun Authentication untuk admin.
4. Hubungkan `index.html` ke Supabase JS dan ganti penyimpanan localStorage dengan query tabel `piket`.
5. Deploy `index.html` ke Vercel/Cloudflare Pages/GitHub Pages.

Keamanan:
- Pengunjung: SELECT saja.
- Admin: INSERT/UPDATE/DELETE melalui akun Authentication.
- Jangan menaruh service-role key di HTML/browser.
- Hanya publish anon/public key yang memang aman untuk frontend.
