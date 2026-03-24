# Yeraltı Radar (GPR) Veri Doğrulama & Analiz Paketi

**Ground Penetrating Radar Data Verification & Analysis Suite**

## Genel Bakış / Overview

Bu depo, Yeraltı Radar (GPR) verilerinin ileri görselleştirilmesi, işlenmesi ve doğrulanması için kapsamlı bir MATLAB paketi içerir. Paket, simule edilen GPR yansıma verisini gerçek bir porozite modeli ile karşılaştırmasını sağlayarak HDF5 veri formatlarını kullanır.

**Amaç:** Koyan & Tronicke (2019) tarafından sağlanan gerçek GPR simulasyon verisini analiz ederek, radar sinyalinin yeraltı yapısını (porozite) ne kadar başarıyla temsil ettiğini istatistiksel yöntemlerle araştırmak.

This repository contains a comprehensive MATLAB suite for the advanced visualization, processing, and verification of Ground Penetrating Radar (GPR) data using HDF5 formats.

---

##  Hızlı Başlangıç / Quick Start

**Tam Analizi Çalıştır (Önerilen):**

```matlab
run GPR_Analysis_Main.m
```

Bu komut otomatik olarak:

- ✅ GPR ve porozite verisini H5 formatından yükler
- ✅ 2D C-Scan karşılaştırma haritalarını oluşturur
- ✅ Spatial interpolation ile veri hizalanmasını gerçekleştirir
- ✅ Sinyal-porozite Pearson korelasyonunu hesaplar
- ✅ 4-panel 2D görselleştirmeyi oluşturur (C-Scan, Model, Fark, Scatter)
- ✅ Optimize edilmiş 3D nokta bulutu görselleştirmesini yapıyor
- ✅ Sonuçları konsol ve workspace değişkeninde kaydeder

**Tahmini Çalışma Süresi:** ~10 saniye

---

## Özellikler / Features

### 1. HDF5 Veri İntegrasyonu

- \.h5\ dosyalarından yüksek boyutlu verileri verimli şekilde okuma
- Otomatik metadata çıkartma (merkez frekans, model çözünürlüğü)
- Göreli yollar: Repo herhangi bir konuma taşınabilir

### 2. Çok Boyutlu Görselleştirme

- **B-Scan'ler:** Profil kesitleri (x-t ve zaman-derinlik görünümleri)
- **Zaman İzleri:** Derinliğe bağlı sinyal analizi
- **C-Scan'ler:** 3D veriyi 2D'ye dönüştürme (Maksimum Genlik Yöntemi)
- **3D Nokta Bulutları:** Akıllı seyreltme ile interaktif grafikleri

### 3. Doğrulama & Korrelasyon Analizi

- **2D Karşılaştırma:** GPR sinyali vs. porozite modeli yan yana analiz
- **Pearson Korelasyonu:** İstatistiksel ilişki ölçümü (r  [-1, 1])
- **Fark Haritaları:** GPR ve gerçek modeli arasındaki farkları gösterir
- **Scatter Analizi:** Trend çizgisi ile korrelasyon görseli

### 4. Optimize Edilmiş 3D Renderiz

- **Akıllı Seyreltme:** Düşük enerjili gürültüyü filtreler ve nokta sayısını sınırlar
- **GPU Uyumlu:** ~30,000 noktayla 60+ FPS döndürme sağlar
- **Performans:** Kritik bölgeleri koruyor, ön plan harcamasını azaltıyor

### 5. Otomatik Vize Raporu Hazırlığı

- **İstatistiksel Özet:** Korrelasyon, sinyal özellikleri, model istatistikleri
- **Biçimlendirilmiş Çıktı:** Konsol çıkışı 1-sayfa rapor için optimize edilmiş
- **Çalışma Alanı Depolama:** Sonuçlar \simulation_results\ yapısında kaydedilir

---

## 📁 Dosya Yapısı / File Structure

```
MATLAB-GPR-Analysis-Tool/
│
├── 🔴 GPR_Analysis_Main.m            ← ⭐ BURADAN BAŞLAYIN (Main entry point)
│
├── 📚 Import_GPR_Data.m              ← B-Scan ve Time-Slice explorer (referans)
├── 📚 Import_Porosity_Model.m        ← 3D porozite model explorer (referans)
│
├── 📄 README.md                      ← Bu dosya (Türkçe dokümantasyon)
├── 📋 .gitignore                     ← Git ignore kuralları
│
└── 📊 dataset/Koyan_Tronicke_2019/
    ├── GPR_Data.h5                  ← 3D GPR veri (501 MB)
    └── Porosity_Model.h5             ← 3D porozite model (543 MB)
```

| Dosya | Açıklama | Tip | Gerekli? |
|-------|----------|-----|----------|
| **GPR_Analysis_Main.m** | Tam analiz: veri yükleme + 2D + korelasyon + 3D | Script | ✅ KRİTİK |
| Import_GPR_Data.m | B-Scan görünümleri ve metadata görüntüleme | Utility | 🟡 Opsiyonel |
| Import_Porosity_Model.m | 3D porozite yapısı inceleme ve slicing | Utility | 🟡 Opsiyonel |
| GPR_Data.h5 | 3D GPR trace veritabanı | Data | ✅ KRİTİK |
| Porosity_Model.h5 | 3D porozite referans modeli (Ground Truth) | Data | ✅ KRİTİK |

---

## Veri Seti Bilgileri / Dataset Information

### Kaynak / Source

- **Veri Seti:** Koyan & Tronicke (2019) - Porozite Modeli
- **Simülatör:** gprMax
- **Format:** HDF5 (.h5)
- **Dosyalar:**
  - \GPR_Data.h5\ (501 MB) - 3D radar iz veritabanı
  - \Porosity_Model.h5\ (543 MB) - 3D porozite referans modeli

### Veri Durumu / Dataset Status

 **Repo'da dahil** - Veya hemen kullanılabilir
 **Boyut Optimize:** ~1 GB (VTK dosyaları kaldırıldı)

---

## Algoritma Detayları / Algorithm Details

### C-Scan Haritalama / C-Scan Mapping

3D GPR veri 2D harita'ya dönüştürülür (Maksimum Genlik Projeksiyonu):

$$M(x,y) = \max_{t} |S(x,y,t)|$$

**Yorumlama:**
- Yüksek değerler = Güçlü refleksiyonlar (anormal yapılar)
- Düşük değerler = Zayıf refleksiyonlar (homojen ortam)

### Spatial Interpolation / Uzaysal Hizalanma

GPR (51×310) ve porozite (401×639) farklı çözünürlükte olduğundan:

1. **Ortak bölge:** X[0.25, 15.70] m, Y[0.00, 10.00] m tanımlanır
2. **Referans ızgara:** 100×100 ızgara oluşturulur (linspace)
3. **Bilinear interpolation:** Her iki harita da referans ızgaraya hazırlanır (`interp2`)
4. **Korelasyon:** Aynı çözünürlükte verilere Pearson korelasyonu uygulanır

### Pearson Korelasyonu / Pearson Correlation

$$r = \frac{\sum (X_i - \mu_X)(Y_i - \mu_Y)}{\sqrt{\sum(X_i - \mu_X)^2 \sum(Y_i - \mu_Y)^2}}$$

**Yorumlama:**
- $r > 0.6$: Yüksek korrelasyon (iyi simulasyon)
- $0.4 < r < 0.6$: Orta korrelasyon
- $r < 0.2$: Zayıf korrelasyon (model revizyonu gerekli)
- $r ≈ 0$: Korelasyon yok

---

## ▶️ Analiz Çalıştırma / Running the Analysis

### Ana Analiz (Önerilen) / Main Analysis (Recommended)

```matlab
run GPR_Analysis_Main.m
```

**Çıktılar:**
- **Şekil 1:** 2D karşılaştırma (4-panel: C-Scan, Model, Fark, Scatter)
- **Şekil 2:** 3D nokta bulutu (interaktif)
- **Konsol:** Korelasyon katsayısı, istatistikler, durum mesajları
- **Workspace:** `simulation_results` yapısında tüm veriler

### Referans Script'ler / Reference Scripts

**B-Scan & Time-Slice Görünümü:**
```matlab
run Import_GPR_Data.m
```
→ Ham GPR verisini profil kesitleri ve zaman dilimləri olarak görüntüler

**3D Porozite Modeli:**
```matlab
run Import_Porosity_Model.m
```
→ Ground truth porozite yapısını 3D slicing ile incelemek için

---

## Gereklilikler / Requirements

- **MATLAB:** R2019b veya daha yeni
- **Araç Kutuları:** Signal Processing, Image Processing
- **Donanım:** 4GB RAM minimum (8GB önerilen)
- **İşletim Sistemi:** Windows (WSL2 uyumlu), macOS, Linux

---

## Konsol Çıktısı Örneği / Output Example

```
==================== BAŞLANGAÇ ====================
Veri yükleniyor... / Loading data...

 Tüm veriler başarıyla yüklendi.

==================== C-SCAN ANALİZİ ====================
    C-Scan haritası oluşturuldu: 51  310 piksel
    Porozite modeli 2D haritaya indirgendi: 401  639 piksel

==================== KORRELASYON ANALİZİ ====================
    Pearson Korrelasyon Katsayısı: r = -0.3252
    Düşük korrelasyon: Model revizyonu gerekebilir

==================== SONUÇLAR VE ÖZETİ ====================
   Pearson Korrelasyonu: r = -0.3252
   GPR Sinyal: Ort: 0.5538 V/m, Std: 0.1680 V/m
   Porozite Modeli: Ort: 0.4874, Std: 0.2014

 Analiz başarıyla tamamlandı.
```

---

## Sorun Giderme / Troubleshooting

| Sorun | Çözüm |
|-------|-------|
| **"Dosya bulunamadı"** | Veri dosyalarının yolunu kontrol edin |
| **Yavaş 3D döndürme** | Eşik değeri artırın: \esik = max_val * 0.30\ |
| **Bellek yetersiz** | İlk çalıştırmada biraz zaman alması normal |
| **Grafik görünmüyor** | MATLAB GUI modunun açık olduğundan emin olun |

---

## Gelecek Geliştirmeler / Future Enhancements

- [ ] İnteraktif GUI araçları
- [ ] Frekans bağımlı analiz
- [ ] Derinlik migrasyon algoritmaları
- [ ] Gerçek saha verileriyle karşılaştırma
- [ ] Makine öğrenmesi tabanlı anomali tespiti
- [ ] Toplu işleme

---

## Kaynak / References

1. **Koyan, P., & Tronicke, J. (2019).** "Modeling of simulated GPR reflection data..."
   _Journal of Applied Geophysics_

2. **Cassidy, N. J. (Ed.). (2009).** _Ground Penetrating Radar: Theory and Applications._
   Elsevier Science.

3. **MATLAB HDF5 Belgeleri:** https://www.mathworks.com/help/matlab/hdf5-files.html

---

## Ders Bilgileri / Course Information

**Öğretmen / Instructor:** Efe Can Kara  
**Vize / Midterm:** 1-sayfa rapor (Yöntem + İlk Sonuçlar)  
**Final / Final:** 3D görselleştirme + Detaylı analiz

---

## 📝 Değişiklik Günlüğü / Changelog

### v2.1 - Final Release (24 Mart 2026)

- ✅ Legacy scriptleri kaldırıldı (`Process_GPR_Data.m`, `Process_GPR_Data_2D.m`)
- ✅ Dataset klasörü temizlendi (Python dosyaları, duplikat .m dosyaları kaldırıldı)
- ✅ README.md güncellendi (final Türkçe dokümantasyon)
- ✅ `final_project.prj` ve `README.md.bak` kaldırıldı
- ✅ Repo boyutu: ~1.05 GB
- ✅ GitHub'a push için hazır

### v2.0 - Optimized Release (24 Mart 2026)

- ✅ Konsolide `GPR_Analysis_Main.m` oluşturuldu
- ✅ Pearson korelasyon analizi eklendi
- ✅ Spatial interpolation (100×100 grid) uygulandı
- ✅ VTK dosyaları kaldırıldı (1.4 GB tasarruf)
- ✅ Türkçe belgelendirme
- ✅ %73 boyut azaltma

### v1.0 - Original Release

- Veri yükleme scriptleri
- 2D ve 3D görselleştirme araçları
- 3.8 GB toplam boyut

---

**Son Güncelleme / Last Update:** 24 Mart 2026  
**Durum / Status:** ✅ **FINAL - GitHub Push Ready**

---

**Sorular mı var?** Konsol çıkışını kontrol edin, scriptlerdeki yorumları okuyun veya teknik detaylar için README_OPTIMIZATION.md dosyasını inceleyin.

**Questions?** Check console output, script comments, or review technical details in README_OPTIMIZATION.md.
