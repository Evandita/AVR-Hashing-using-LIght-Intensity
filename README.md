# AVR Hashing using Light Intensity

## Latar Belakang

Hashing adalah sebuah konsep pada bidang keamanan jaringan yang seringkali digunakan karena sangat bermanfaat dalam menjaga data yang bersifat sensitif. Dengan dilakukannya hashing, maka data yang tersimpan akan terenkripsi secara satu arah, sehingga mampu menambahkan lapisan keamanan.

Akan tetapi, hal ini belum menjamin data tersebut 100% aman. Hal ini dikarenakan algoritma dari fungsi matematis yang digunakan untuk hashing mayoritas masih diprogram pada sistem semua, sehingga apabila perentas data berhasil mempelajari cara kerja sistem tersebut, maka seluruh data yang telah di-hashing dapat dipredeksi secara perlahan.

Hal ini juga belum melibatkan faktor kekuatan algoritma hashing itu sendiri, di mana semakin lemah algoritma yang digunakan, maka semakin mudah pula data untuk diprediksi. Semakin kuat algoritma hashing juga belum tentu lebih baik karena akan memberikan beban tambahan pada CPU juga.

## Pendekatan Solusi

Untuk memperkuat algoritma Hashing yang sudah ada, maka salah satu pendekatan yang dapat dilakukan adalah dengan melibatkan sebuah variabel dengan nilai yang sangat sulit untuk diprediksi, untuk proses hashing tersebut. Di sinilah tempat di mana nilai besaran fisik mulai berperan. 

Nilai acak yang dihasilkan oleh program, tentu berbeda dengan nilai acak yang didapat dari hasil pengambilan data pada dunia nyata. Hal ini dikarenakan pada dunia nyata, banyak sekali faktor yang memengaruhi besaran tersebut, sehingga sangat sulit untuk memprediksi nilainya. Di sisi lain, nilai yang dihasilkan oleh program, cenderung lebih mudah untuk diprediksi karena hanya seseorang programmer yang menulis seluruh aturan penentuan besaran nilai acak, sehingga faktor yang terlibat umumnya masih terbatas. Selain itu, penggunaan nilai fisik juga mengurangi beban CPU dalam proses hashing karena tidak perlu menjalankan program untuk menhasilkan nilai acak.

Selebihnya, pendekatan solusi ini merupakan bentuk inspirasi dari penggunaan lava lamp sebagai alat bantu enkripsi data yang diterapkan oleh perusahaan jaringan besar bernama cloudflare. Meskipun begitu, metode yang dilakukan oleh perusahaan tersebut sangat kompleks karena sudah melibatkan pembacaan indera untuk mengambil “nilai acak” dari lava lamp tersebut, sehingga solusi AVR Hash Key Generator Using Light Intensity dilahirkan sebagai bentuk alternatif yang lebih sederhana dengan biaya yang lebih terjangkau, serta masih menerapkan konsep yang sama.


## Alur Kerja Rangkaian

Secara garis besar, rancangan rangkaian akan memiliki 3 macam input nilai (LDR, Potentiometer untuk LED, Potentiometer untuk delay) dan 2 macam output nilai (Hash Key + Hashed Data, disturbance LED). Dikarenakan seluruh input nilai bersifat kontinu dan bukan diskrit, maka akan menggunakan port analog (A0, A1, A2) pada Arduino Uno yang nantinya akan diubah menjadi nilai diskrit melalui proses konversi ADC. Lalu untuk output, hasil Hash Key beserta Hashed Data akan ditampilkan pada serial monitor melalui protokol USART, sedangkan untuk disturbance led dapat menggunakan pin digital pada PORTD Arduino Uno. Berikut merupakan bentuk representasi flowchart untuk cara AVR menerima data, mengolah data, dan menampilkan data:

![](/img/alurKerja.png)

Rancangan rangkaian akan menampilkan contoh hasil hashed data menggunakan nilai dari hash key yang bervariatif, sehingga dibutuhkan sebuah algoritma hash yang tertanam pada mikrokontroller Arduino Uno. Agar tidak membebani CPU mikrokontroller, maka algoritma hash yang digunakan masih tergolong sederhana (meskipun hal ini akan menimbulkan celah keamanan). Alur kerja dari algoritma hashing yang diimplementasikan pada Arduino Uno antara lain sebagai berikut:

![](/img/hash.png)

Selain perlunya algoritma hashing, sempat disinggung juga bahwa terdapat mekanisme pada rangkaian yang dapat menghasilkan delay pada rentang 0.5 detik sampai 2 detik melalui input potentiometer yang tersampung pada pin A1 di Arduino Uno. Sinyal analog yang diterima oleh pin A1 akan dikonversi menjadi nilai diskrit melalui proses ADC dengan interval nilai 0 – 1024. Nilai tersebut kemudian diolah sedemikian rupa sehingga mampu menghasilkan delay yang diinginkan memiliki alur kerja sebagai berikut:

![](/img/delay.png)

Selebihnya, terdapat juga input analog untuk disturbance led pada pin A2. Hasil konversi ADC dari input analog tersebut nantinya digunakan untuk menyalakan 0 sampai 5 LED yang terletak didekat LDR untuk menciptakan gangguan pada intensitas cahaya yang diterima. Berikut merupakan tabel pemetakan nilai interval ADC ke jumlah LED yang menyala:

ADC Value                   | ON LEDs
----------------------------|---------
00 0000 0000 - 00 0111 1111 | 0
00 1000 0000 - 00 1111 1111 | 1
01 0000 0000 - 01 1111 1111 | 2
10 0000 0000 - 10 1111 1111 | 3
11 0000 0000 - 11 0111 1111 | 4
11 1000 0000 - 11 1111 1111 | 5

Dapat diihat bahwa dengan nilai ADC yang berada pada interval 0 – 1024, dapat dibagi menjadi 6 kemungkinan kondisi dari disturbance led. Tujuan dari adanya beberapa LED sekaligus yang dapat diatur jumlah menyalanya adalah untuk menyesuaikan besar/kecilnya gangguan intensitas cahaya yang ingin diberikan. Berikut merupakan alur kerja rangkaian agar dapat mengimplementasikan tabel pemetakan di atas:

![](/img/led.png)

## Desain Rangkaian

Berdasarkan penjelasan rancangan rangkaian yang telah dibahas sebelumnya, dapat disimpulkan bahwa perkiraan komponen yang akan dibutuhkan untuk mengimplementasikan rangkaian asli antara lain sebagai berikut:

No | Komponen        | Penjelasan
---|-----------------|---------------
1  | Arduino Uno     | Mikrokontroller Rangkaian
2  | Jumper          | Kabel untuk menghubungkan antar komponen
3  | Resistor        | Mengatur arus pada LED
4  | LED (5)         | Untuk memberikan gangguan pada input LDR
5  | LDR             | Untuk mendapatkan besaran intensitas cahaya
6  | Potentiometer 1 | Untuk mengatur besar/kecil-nya delay
7  | Potentiometer 2 | Untuk mengatur besar/kecil-nya gangguan

Apabila seluruh komponen tersebut dirakit, maka kurang lebih akan didapatkan hasil sebagai berikut:

![](/img/desain.png)

![](/img/rangkaian.png)

Pada gambar di atas dapat dilihat bahwa sensor cahaya LDR terletak tepat di sebelah disturbance led untuk memaksimalkan efek gangguan yang dapat diberikan. Selain itu, terdapat juga 2 jenis potentiometer yang digunakan. Regulator Potentiometer yang terletak di sebelah kiri berguna untuk mengatur delay, sedangkan Slide Potentiometer yang terletak di sebelah kanan berguna untuk mengatur gangguan. 

## Link Simulasi

### Link Wokwi

https://wokwi.com/projects/400464062500201473

### Link YouTube

https://youtu.be/EYq948GAAsM?si=qqCs-83GXfIi-gpC
