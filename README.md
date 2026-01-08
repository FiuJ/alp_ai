Aplikasi ini adalah aplikasi khusus android untuk melakukan klasifikasi sampah menggunakan kamera _smartphone_. 
Dengan mengetahui jenis sampah yang ada, aplikasi ini akan memberikan rekomendasi untuk cara 
mendaur ulang jenis sampah tersebut untuk memberikan informasi kepada pengguna untuk rekomendasi
daur ulang yang bisa dilakukan.

**Cara menggunakan aplikasi ini melalui build apk :** 
- Install aplikasi melalui link berikut : https://drive.google.com/drive/folders/1Aa4Ag5bEdGXz9gRQ2nnR5QvgjZLOtNJD?usp=drive_link

**Cara menggunakan aplikasi ini jika mendownload lewat build apk : **
1. Download file app-release.apk pada google drive diatas, kemudian tekan file yang sudah didownload dan klik install.
2. Kemudian tekan aplikasi yang sudah terinstall dan akan masuk ke halaman scan.
3. Pada halaman pertama akan ditunjukan tab untuk melakukan klasifikasi, user bisa memilih
   untuk menggunakan kamera atau meng-_upload_ foto sampah yang dimiliki.
4. Setelah memfoto atau upload gambar sampah tersebut maka aplikasi ini akan menunjukan
   hasil jenis klasifikasi beserta rekomendasi cara mendaur ulang jenis sampah tersebut.
5. Untuk membuka tab _history_ user dapat berpindah melaui button history di kanan atas,
   kemudian terdapat tampilan sampah apa saja yang pernah di scan beserta cara untuk
   recyclenya.
6. Untuk melihat statistics sampah apa saja yang telah di _scan_ maka user bisa membuka
   melalui tab Statistics dikiri button history untuk melihat total jenis sampah yang
   telah di scan.


**Cara menggunakan aplikasi ini melalui flutter :**
- Buka website https://flutter.dev/
- Pilih menu Get Started dan Download Flutter sesuai OS device kalian.
- Lakukan set up installation flutter sesuai dengan OS pada device masing masing,
  untuk detail terkait OS yang berbeda bisa dilihat pada _Get Started_ di website
  resmi flutter
  https://docs.flutter.dev/get-started/quick?_gl=1*6uuj7h*_ga*Njg5NjgxMTE2LjE3Njc4ODMzMjY.*_ga_04YGWK0175*czE3Njc4ODMzMjckbzEkZzEkdDE3Njc4ODM1NDUkajUzJGwwJGgw
- Kemudian setelah menyelesaikan installation tersebut, buka terminal dan ketik
  "flutter doctor" untuk melihat apakah sudah terinstall semua. Jika sudah tercentang,
  maka flutter siap digunakan.
- Setelah itu install Visual Studio Code melalui link berikut :
  https://code.visualstudio.com/
  lakukan instalasi dan buka Visual Studio Code
- Setelah terbuka, pada tab extension di sebelah kiri, download extension :
  1. Flutter
  2. Dart
- Kemudian download github desktop pada link berikut https://desktop.github.com/download/
  lakukan instalasi dan buka github dekstop.
- Buka link github berikut : https://github.com/FiuJ/alp_ai
- Setelah terbuka, klik button "<> Code" berwarna hijau dan cari button "Open
  with GitHub Desktop"
- Kemudian akan masuk ke dalam GitHub desktop pada tab "URL", langsung tekan clone.
- Setelah loading untuk clone selesai, Hover mouse di bagian "Current Repository"
  dikiri atas untuk melihat path file disimpan.
- Buka Visual Studio Code, klik "File" dan klik "Open Folder" kemudian buka sesuai
  directory clone yang ada pada GitHub Desktop.
- Setelah terbuka, di directory root, tambahkan file .env dengan klik kanan lalu
  "New File" kemudian buat .env
- Isi file .env dengan
  GEMINI_API_KEY=(APIKEY)
- Untuk mendapatkan API KEY, Buka Google AI Studio https://aistudio.google.com/
- Login menggunakan akun Google dan klik "Get API KEY"
- Pilih "Create API KEY" lalu _copy_ API key yang ada dan masukan ke file .env sebelumnya
- Isi pada file .env akan seperti ini
  GEMINI_API_KEY=anfaufoajoOA
- kemudian persiapkan HP untuk menjalankan aplikasi ini
- Buka Setting, masuk ke "About Phone" lalu tekan "Build Number" sebanyak 7 kali
  hingga muncul "You are now a developer"
- Masukan "Developer Options" dan aktifkan "USB Debugging"
- Sambungkan HP ke laptop menggunakan kabel data
- Pada terminal Visual Studio Code, ketik "flutter devices" dan lihat Jika nama HP
  muncul, maka device sudah terhubung.
- Pastikan HP masih terhubung dengan kabel data kemudian pada terminal jalankan perintah:
  flutter run
- Tunggu proses build selesai dan Aplikasi akan otomatis terbuka di HP Android kamu.
- Jika terjadi error maka jalankan ini di terminal :
  flutter clean
  flutter pub get
  flutter run
- Pada halaman pertama akan ditunjukan tab untuk melakukan klasifikasi, user bisa memilih
  untuk menggunakan kamera atau meng-_upload_ foto sampah yang dimiliki.
- Setelah memfoto atau upload gambar sampah tersebut maka aplikasi ini akan menunjukan
  hasil jenis klasifikasi beserta rekomendasi cara mendaur ulang jenis sampah tersebut.
- Untuk membuka tab _history_ user dapat berpindah melaui button history di kanan atas,
  kemudian terdapat tampilan sampah apa saja yang pernah di scan beserta cara untuk
  recyclenya.
- Untuk melihat statistics sampah apa saja yang telah di _scan_ maka user bisa membuka
  melalui tab Statistics dikiri button history untuk melihat total jenis sampah yang
  telah di scan.























