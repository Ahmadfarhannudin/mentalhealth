# PRD: Aplikasi Kesehatan Mental Android

Oct 11, 2026 · Disusun oleh @farhan

## Ringkasan Produk

**Tenang** (nama kerja/placeholder) adalah aplikasi kesehatan mental berbasis Android yang membantu pengguna memantau suasana hati, melatih keterampilan coping berbasis CBT (Cognitive Behavioral Therapy), dan terhubung ke dukungan profesional saat dibutuhkan.

Aplikasi ini memposisikan diri sebagai alat *self-care* dan pencegahan dini, bukan alat diagnosis klinis — jembatan antara perawatan mandiri sehari-hari dan rujukan ke psikolog/psikiater berlisensi.

## Latar Belakang & Tujuan

Akses layanan kesehatan mental profesional di Indonesia masih terbatas — jumlah psikolog dan psikiater jauh di bawah rasio ideal terhadap populasi, biaya konsultasi relatif mahal untuk sebagian besar masyarakat, dan stigma sosial membuat banyak orang menunda mencari bantuan sampai kondisinya memburuk.

**Tujuan Bisnis**

- Membangun basis pengguna aktif yang berkelanjutan melalui model freemium
- Membuka jalur monetisasi lewat langganan premium dan kemitraan dengan penyedia layanan telehealth

**Tujuan Produk**

- Menyediakan alat pemantauan suasana hati dan latihan coping berbasis bukti (CBT) yang mudah diakses setiap hari
- Menurunkan hambatan awal untuk mencari bantuan dengan rujukan yang jelas ke tenaga profesional
- Menyediakan jalur eskalasi yang cepat dan aman saat pengguna menunjukkan tanda risiko krisis

## Target Pengguna & Persona

Fokus utama: dewasa muda usia 18-35 tahun di area urban dengan akses smartphone, yang mengalami stres ringan-sedang (kecemasan, burnout kerja/kuliah) dan belum pernah atau jarang mengakses layanan profesional.

| Persona | Usia & Latar | Kebutuhan Utama | Hambatan |
| --- | --- | --- | --- |
| Mahasiswa Cemas | 19-23, mahasiswa kota besar | Kelola kecemasan ujian/sosial, ruang aman untuk cerita | Biaya terbatas, takut stigma di kampus |
| Profesional Burnout | 25-34, pekerja kantoran | Kelola stres kerja, rutinitas self-care yang cepat dijalani di sela kesibukan | Waktu terbatas, enggan cuti untuk konsultasi |
| Pencari Dukungan Awal | 20-30, baru sadar butuh bantuan | Edukasi dasar kesehatan mental, langkah pertama sebelum ke profesional | Tidak tahu harus mulai dari mana, biaya konsultasi pertama |

## Fitur Utama (MVP)

| Fitur | Deskripsi | Prioritas |
| --- | --- | --- |
| Pelacak Suasana Hati | Catat mood harian dengan skala cepat + catatan singkat, lihat tren mingguan/bulanan | Harus ada |
| Jurnal Terpandu | Prompt jurnal harian untuk refleksi diri, bisa privat atau dibagikan ke terapis | Harus ada |
| Latihan Coping Berbasis CBT | Modul singkat: pernapasan, grounding, restrukturisasi pikiran negatif | Harus ada |
| Pengingat & Notifikasi Personal | Pengingat check-in mood dan latihan harian, dapat disesuaikan | Sebaiknya ada |
| Komunitas Dukungan Sebaya | Forum anonim termoderasi untuk berbagi pengalaman | Sebaiknya ada |
| Laporan untuk Terapis | Ekspor riwayat mood/jurnal dalam format ringkas untuk sesi konsultasi | Nice to have |

## Alur Pengguna Utama

**Onboarding**

1. Sambutan singkat + penjelasan privasi data
2. Asesmen awal ringan (opsional) untuk memahami kondisi pengguna
3. Pilih tujuan personal (kurangi cemas, perbaiki tidur, kelola stres kerja, dll.)
4. Pengaturan pengingat harian

**Penggunaan Harian**

1. Buka aplikasi, isi check-in mood cepat (< 30 detik)
2. Aplikasi menyarankan satu latihan singkat sesuai mood yang tercatat
3. Pengguna dapat menulis jurnal atau langsung menutup aplikasi

## Spesifikasi Teknis

- **Platform**: Android native (Kotlin), minimum SDK 26 (Android 8.0) untuk menjangkau mayoritas perangkat di Indonesia
- **Arsitektur**: MVVM dengan Jetpack Compose untuk UI
- **Backend**: REST API (Node.js/Express atau Firebase sebagai alternatif cepat untuk MVP) + database terenkripsi untuk data mood dan jurnal
- **Autentikasi**: Email/OTP dan opsi login sosial, dengan opsi akun anonim untuk pengguna yang mengutamakan privasi
- **Penyimpanan Lokal**: Data sensitif (jurnal, mood) dienkripsi di perangkat sebelum disinkronkan
- **Notifikasi**: Firebase Cloud Messaging untuk pengingat terjadwal
- **Analitik**: Pelacakan event teragregasi dan terenkripsi, tanpa mengaitkan ke konten jurnal pribadi

## Keamanan, Privasi & Kepatuhan

Data kesehatan mental adalah data sensitif — penanganannya harus lebih ketat dibanding aplikasi pada umumnya.

- **Enkripsi**: Data saat transit (TLS) dan saat disimpan (AES-256), khususnya untuk entri jurnal dan hasil asesmen
- **Kepatuhan Regulasi**: Mengikuti UU No. 27/2022 tentang Pelindungan Data Pribadi (PDP) — persetujuan eksplisit sebelum pengumpulan data, hak pengguna untuk menghapus data
- **Batasan Klinis**: Aplikasi secara eksplisit menyatakan dirinya bukan pengganti diagnosis atau pengobatan profesional; semua konten coping ditinjau oleh psikolog klinis berlisensi sebelum dipublikasikan
- **Tanpa Iklan pada Data Sensitif**: Tidak ada pembagian data jurnal/mood ke pihak ketiga untuk tujuan periklanan
- **Audit Keamanan Berkala**: Penetration testing dan audit privasi dilakukan sebelum setiap rilis besar

## Metrik Keberhasilan (KPI)

| Kategori | Metrik | Target Awal (6 bulan pasca-peluncuran) |
| --- | --- | --- |
| Akuisisi | Unduhan aplikasi | 50.000 |
| Aktivasi | Penyelesaian onboarding | > 70% dari pengguna yang mendaftar |
| Engagement | Rata-rata check-in mood per minggu | >= 4 kali/pengguna aktif |
| Retensi | Retensi Hari ke-30 (D30) | >= 20% |
| Dampak | Perubahan skor kecemasan (GAD-7) setelah 4 minggu pemakaian rutin | Penurunan rata-rata terukur pada kohort yang mengisi asesmen |

## Roadmap & Timeline

&#91;embedded content: roadmap · 4 fase, 1 gate keputusan\]

Empat fase selama 12 bulan, dengan satu gate keputusan go/no-go sebelum peluncuran publik berdasarkan hasil closed beta.

## Risiko & Mitigasi

| Risiko | Dampak | Mitigasi |
| --- | --- | --- |
| Pengguna dalam krisis tidak mendapat respons cepat | Tinggi — keselamatan pengguna | Belum ada mitigasi di MVP ini — perlu ditinjau ulang sebelum rilis karena risikonya tetap ada |
| Dianggap memberi "diagnosis" medis tanpa izin resmi | Tinggi — risiko legal/regulasi | Posisikan sebagai aplikasi wellness/self-care, bukan alat diagnosis; konsultasi hukum sejak awal pengembangan |
| Pelanggaran privasi data sensitif | Tinggi — kepercayaan pengguna, legal | Enkripsi end-to-end, audit keamanan berkala, kepatuhan UU PDP |
| Retensi rendah setelah minggu pertama | Sedang — keberlanjutan bisnis | Notifikasi personalisasi, gamifikasi ringan, onboarding yang relevan secara personal |
| Konten coping yang tidak akurat atau berisiko | Tinggi — keselamatan pengguna | Seluruh konten direview dan disetujui oleh psikolog klinis berlisensi sebelum publikasi |
|  |  |  |
