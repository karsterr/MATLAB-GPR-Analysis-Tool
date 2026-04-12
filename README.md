# GPR 3D Modelleme Projesi - Radyofrekans ve Sinyal Isleme Tabanli Yeralti Analiz Araci

## 1. Özet (Abstract)
Bu proje, Yer Alti Radari (GPR) verilerini isleyip analiz ederek yeralti anomalilerini 3 boyutlu haritalamayi amaçlayan, tamamen dijital sinyal isleme (DSP) teknikleri tabanli akademik bir çalismadir. Hazir görüntü isleme kütüphaneleri (image processing) kasitli olarak kullanilmamis olup, yalnizca saf sinyal isleme yaklasimlari (DSP) tercih edilmistir. Böylece zemin yapisi ile yeralti hedeflerinin (borular, bosluklar vb.) yansima karakterleri derinlemesine ve elektromanyetik temellere uygun bir sekilde incelenmistir.

## 2. Giris
Yeralti haritalamasi, kentsel altyapi projeleri ve arkeolojik çalismalar basta olmak üzere boru, kablo, magara gibi yapilarin tespitinde kritik önem tasir. GPR cihazlari elektromanyetik dalgalari kullanarak yeraltinin yüksek çözünürlüklü profillerini sunar. Bu proje, elde edilen karmasik GPR verilerindeki gürültüleri filtreleyerek hedefleri yapay siniflandirmalar üzerinden tanimlanabilir hale getirmeyi hedefler.

## 3. Metodoloji ve Sinyal Isleme Adimlari (DSP Pipeline)
GPR verilerinden maksimum bilginin elde edilmesi için sinyal bazinda matematiksel adimlar sirasiyla uygulanmaktadir:

* **Veri Ön Isleme (Zero-Padding):** 
Tarama uzunluklari ve veri matrisleri farkli olan GPR kesitleri, zero-padding yöntemi ile ortak bir hacme (grid) sahip olacak sekilde ayni boyuta getirilir.
* **De-wow (Merkeze Çekme):** 
Cihazdan veya anten baglantisindan gelen doÄŸru akÄ±m (DC) sapmalarini ve çok düsük frekansli gürültüleri veya drift etkilerini sinyalden arindirmak için uygulanir.
* **Background Removal (Arka Plan Temizleme):** 
Tüm izlerde (trace'lerde) ortak olan ve yatay çizgiler seklinde beliren anten kaynakli gürültüler (direct wave vb.), yatay düzlem boyunca ortalama degerin çikarilmasi teknigiyle (mean subtraction) temizlenir.
* **Gain (Kazanç):** 
Elektromanyetik dalgalar derinlere indikçe zayiflamaya ugrar. Derin noktalardan gelen zayif yansimalari güçlendirmek amaciyla derinlige (zamana) bagli geometrik kazanç formülleri (örnegin üstel/exponential gain) uygulanir.
* **Zarf Çikarma (Envelope Detection):** 
Sinyalin hizli salinimlari yerine enerjisinin (kalinliginin) incelenmesi için sinyalin zarfi, Hilbert Dönüsümü veya esdeger matematiksel yöntemlerle elde edilir.

## 4. Kod Mimarisi ve Isleyis
Sistem modüler .m betikleri etrafinda kurgulanmistir:
- dataset/ klasörüne eklenen çok kesitli tarama verileri load_gpr_data.m üzerinden otomatik olarak okunur.
- Koordinasyon ve DSP komutlari main.m içinden orkestre edilir. Ana dosya yardimci fonksiyonlari hiyerarsik olarak çagirir, GPR verisini filtreden geçirir ve görsellestirme adimina hazirlar.

## 5. Esikleme (Thresholding) ve Siniflandirma Mantigi
Boru, kablo, magara veya yeralti bosluklari gibi yapilari ayirt etmek için sinyal genligine dayali bir siniflandirma yapilir:
- **Ana Boru / Kalin Boru:** En yüksek genliklere sahip hedefler.
- **Ince Boru:** Orta genlikte ve daha kisitli bir bölgede enerjisi yigilmis hedefler.
- **Kablo:** Sinyalin daha düsük bölgesel ve ince saçilimlari.
- **Magara:** Faz degisimi (parlak yankilar) birakan, daha keskin ancak sinyalin devam ettigi yapilar (kod içerisinde spesifik threshold limitleriyle ayristirilmistir).

Son asamada ise, tüm veri kümesi scatter3 fonksiyonu yardimiyla malzeme türüne göre renklendirilerek (Colormap) 3D uzayda isaretlenir. 

## 6. Kurulum ve Çalistirma
Projeyi kendi cihazinizda çalistirmak için:
1. Depoyu klonlayin veya indirin.
2. Veri setini [BURAYA LINK GELECEK] adresinden indirin.
3. Indirdiginiz veri setini (büyük boyutlu dosyalari) proje içerisindeki `dataset/` klasörüne tasiyin.
4. Proje klasörünü MATLAB üzerinde aktif çalisma dizini (Current Folder) yapin.
5. main.m dosyasini çalistirin. Konsol çiktilarinda islenen her bir adimi görebilir, islem bitiminde 3 boyutlu sonuç plot ekranina erisebilirsiniz.

