# RestoQueue — Web Antrian Restoran

Aplikasi web statis yang siap di-host di **GitHub Pages**. Admin/petugas login, sedangkan monitor pelanggan dibuka dari perangkat lain. Data disimpan di Supabase dan disinkronkan menggunakan Supabase Realtime.

## Fitur yang tersedia

- Login admin/petugas melalui Supabase Auth.
- Dashboard jumlah pesanan aktif, disiapkan, siap diambil, dan selesai.
- Input pesanan berdasarkan sumber (GoFood, ShopeeFood, GrabFood, Offline Food).
- Status pesanan, panggilan ulang, hapus, pencarian, dan filter.
- Halaman monitor publik untuk TV/monitor pelanggan (`#monitor`).
- Sinkronisasi antrean realtime antarperangkat.
- Panggilan suara browser, pilihan suara perangkat, dan tes suara.
- Pengumuman nomor pesanan ukuran besar.
- Running text promosi dan gambar/GIF monitor.
- Pengaturan outlet, area pengambilan, suara, animasi, jadwal salat dan koordinat.
- Riwayat berdasarkan tanggal, laporan jumlah pesanan, ekspor CSV.
- Autosave ke database online setelah perubahan.

> Catatan: aplikasi ini adalah **sistem antrean**, bukan POS penjualan. Laporan saat ini menghitung jumlah pesanan, bukan omzet/laba, karena form antrean tidak mencatat nilai transaksi.

## 1. Buat proyek Supabase

1. Buka <https://supabase.com> dan buat proyek baru.
2. Catat **Project URL** dan **anon/public key** dari Project Settings → API (atau API Keys pada tampilan dashboard terbaru).
3. Jangan gunakan `service_role` / secret key di website.
4. Buka SQL Editor → New query.
5. Salin seluruh isi `supabase-schema.sql`, jalankan, dan pastikan kedua tabel berhasil dibuat.
6. Buka Authentication → Users → Add user, lalu buat akun admin pertama dengan email dan password.
7. Untuk tahap awal, buat akun petugas secara manual dari dashboard Supabase. Jangan membuka pendaftaran publik.
8. Pastikan Realtime aktif untuk tabel `app_state` dan `monitor_state` (Database → Publications / Realtime). Skrip SQL di atas mencoba menambahkannya otomatis.

### Cara kerja keamanan data

- `app_state` menyimpan seluruh pesanan dan pengaturan, dan hanya dapat dibaca/ditulis oleh akun yang login.
- `monitor_state` adalah salinan publik yang hanya berisi pesanan yang belum selesai dan pengaturan tampilan yang diperlukan monitor. Pengunjung monitor tidak diberi akses ke riwayat lengkap.
- Nomor dan nama pelanggan yang masih aktif akan terlihat pada layar monitor. Gunakan nama panggilan/inisial jika tidak ingin nama lengkap tampil di area publik.

## 2. Isi konfigurasi

Buka `config.js`, lalu ganti dua nilai contoh berikut:

```js
window.RESTOQUEUE_CONFIG = {
  url: 'https://PROJECT-REF.supabase.co',
  anonKey: 'MASUKKAN_SUPABASE_ANON_PUBLIC_KEY'
};
```

Gunakan Project URL dan anon/public key milik proyek Anda. Simpan file.

`config.js` memang disertakan sebagai template agar struktur folder bisa langsung diunggah. Website belum dapat login/sinkron sebelum konfigurasi Supabase asli dimasukkan.

## 3. Deploy ke GitHub Pages

1. Buat repository baru di GitHub, misalnya `restoqueue`.
2. Upload **seluruh isi folder ini** ke root repository (pastikan `index.html`, `config.js`, dan `supabase-schema.sql` berada di root).
3. Buka repository → Settings → Pages.
4. Pada **Build and deployment**, pilih **Deploy from a branch**.
5. Pilih branch `main` dan folder `/ (root)`, lalu Save.
6. Tunggu proses selesai. GitHub akan menampilkan alamat website, misalnya `https://username.github.io/restoqueue/`.

Jika menggunakan repository project (bukan `username.github.io`), file sudah memakai path relatif untuk `config.js`, sehingga dapat dijalankan pada subpath GitHub Pages.

## 4. Alamat monitor

Jika alamat admin Anda:

`https://username.github.io/restoqueue/`

maka alamat monitor adalah:

`https://username.github.io/restoqueue/#monitor`

Buka alamat admin di HP/komputer kasir. Buka alamat monitor di TV/komputer layar pelanggan. Login hanya diperlukan pada halaman admin.

## 5. Pengaturan awal yang disarankan

1. Login admin.
2. Buka Pengaturan dan atur nama resto, outlet, area pengambilan, suara, serta running text.
3. Atur koordinat outlet jika ingin menampilkan jadwal salat.
4. Klik Buka monitor dari admin, kemudian pada monitor klik **Aktifkan audio** satu kali. Browser memerlukan interaksi pengguna sebelum mengizinkan suara otomatis.
5. Buat pesanan uji dan pastikan muncul di monitor. Uji status Siap diambil dan Selesai.

## 6. Backup dan operasional

- Lakukan backup berkala dari Supabase (fitur backup bergantung pada paket Supabase yang digunakan). Paket gratis tidak boleh dianggap sebagai satu-satunya backup operasional.
- Jangan menghapus tabel `app_state` atau `monitor_state`.
- Simpan salinan repository dan file `config.js` di tempat aman.
- `config.js` berisi anon/public key yang memang digunakan browser; keamanan tetap bergantung pada Row Level Security yang disediakan di SQL.
- Jangan pernah mengunggah password, database password, service role key, atau secret key ke GitHub.
- Jika mengganti akun admin, buat akun baru dahulu dari Supabase Auth, uji login, baru nonaktifkan akun lama.

## 7. Batasan versi ini

- Sistem menggunakan satu kumpulan data untuk satu outlet (`id = main`).
- Semua akun Supabase yang dibuat sebagai petugas memiliki hak akses aplikasi yang sama; belum ada pembatasan peran owner/admin/kasir.
- Perubahan dari dua petugas pada saat yang persis bersamaan memakai pola penyimpanan satu dokumen JSON; untuk operasional banyak kasir serentak, tahap lanjutan yang disarankan adalah memindahkan pesanan ke tabel database per pesanan dengan transaksi server.
- Monitor publik menampilkan nomor dan nama pelanggan yang masih aktif.
- Panggilan suara memanfaatkan suara yang tersedia di browser/perangkat, bukan audio server.
- Fitur jadwal salat memerlukan internet dan sumber API eksternal; cocokkan dengan jadwal resmi setempat.

## Struktur folder

```text
restoqueue-web/
├── index.html          # Aplikasi web
├── config.js           # Konfigurasi Supabase (isi sebelum deploy)
├── supabase-schema.sql # Skema, kebijakan keamanan, dan Realtime
├── README.md           # Panduan deploy
└── .nojekyll           # Penanda GitHub Pages
```
