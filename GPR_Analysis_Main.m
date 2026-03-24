%% ============================================================================
%  YERALTI RADARI (GPR) VERİ ANALİZİ SİSTEMİ
%  Ground Penetrating Radar (GPR) Data Analysis System
%  Koyan & Tronicke 2019 Dataset Analizi
%  
%  Bu script:
%  - Gerçek GPR verisini H5 formatından okur
%  - Yeraltı porozite modelini (Ground Truth) yükler
%  - 2D C-Scan haritalama ve korrelasyon analizi yapar
%  - 3D görselleştirme ile sinyal dağılımını gösterir
%  - Sinyal-Porozite ilişkisini istatistiksel olarak analiz eder
%  
%  This script:
%  - Loads real GPR data from H5 format
%  - Imports subsurface porosity model (Ground Truth)
%  - Performs 2D C-Scan mapping and correlation analysis
%  - Provides 3D visualization of signal distribution
%  - Statistically analyzes signal-porosity relationship
%  
%  Yazarlar / Authors: Original by Philipp Koyan (2019)
%  Optimizasyon / Optimization: Efe Can Kara (2026)
%  ============================================================================

clc; clear; close all;

%% ============================================================================
%  BÖLÜM 1: VERİ YÜKLEME (SECTION 1: DATA LOADING)
%  ============================================================================

fprintf('\n==================== BAŞLANGAÇ ====================\n');
fprintf('Veri yükleniyor... / Loading data...\n\n');

% Dataset klasörü tanımla
veri_klasoru = 'dataset/Koyan_Tronicke_2019/';
dosya_gpr = fullfile(veri_klasoru, 'GPR_Data.h5');
dosya_model = fullfile(veri_klasoru, 'Porosity_Model.h5');

% Dosyaların varlığını kontrol et
if ~isfile(dosya_gpr) || ~isfile(dosya_model)
    error('HATA: Veri dosyaları bulunamadı. %s ve %s kontrol edin.', dosya_gpr, dosya_model);
end

%% --- GPR VERİSİ OKUMA ---
% GPR 3D verisini oku: (Zaman, X, Y) boyutları
fprintf('1. GPR verisi okunuyor (%s)...\n', dosya_gpr);
gpr_verisi = h5read(dosya_gpr, '/gprData');  % [time x y] boyutları
x_vektoru = h5read(dosya_gpr, '/xvec');      % X ekseni координ (m)
y_vektoru = h5read(dosya_gpr, '/yvec');      % Y ekseni координ (m)
t_vektoru = h5read(dosya_gpr, '/tvec');      % Zaman vektoru (ns)

% Metadata okuma
dt = h5readatt(dosya_gpr, '/', 'dt');        % Time sampling interval (ns)
fc = h5readatt(dosya_gpr, '/', 'centre_freq'); % Merkez frekans (MHz)
res = h5readatt(dosya_gpr, '/', 'model discretization'); % Model çözünürlüğü (m)
nprofiles = h5readatt(dosya_gpr, '/', 'nprofiles'); % Profil sayısı
nsamples = h5readatt(dosya_gpr, '/', 'nsamples');   % Her izde örnek sayısı
ntraces = h5readatt(dosya_gpr, '/', 'ntraces');     % Toplam iz sayısı

fprintf('   → GPR veritabanı yüklendi: %d profil, %d iz, %d örnek\n', nprofiles, ntraces, nsamples);
fprintf('   → Merkez frekans: %g MHz, Model çözünürlüğü: %g m\n', fc, res);

%% --- POROZITE MODELİ OKUMA ---
% Porozite verisini oku: (Z, X, Y) boyutları (Ground Truth)
fprintf('2. Porozite modeli okunuyor (%s)...\n', dosya_model);
porozite_verisi = h5read(dosya_model, '/porosity');  % [z x y] boyutları
x_model = h5read(dosya_model, '/xvec');
y_model = h5read(dosya_model, '/yvec');
z_model = h5read(dosya_model, '/zvec');

fprintf('   → Porozite modeli yüklendi: [%d × %d × %d] voxel\n', ...
    size(porozite_verisi, 1), size(porozite_verisi, 2), size(porozite_verisi, 3));

fprintf('\n✓ Tüm veriler başarıyla yüklendi.\n\n');

%% ============================================================================
%  BÖLÜM 2: VERİ İŞLEME VE C-SCAN HARITALAMA (SECTION 2: DATA PROCESSING & C-SCAN)
%  ============================================================================

fprintf('==================== C-SCAN ANALİZİ ====================\n');
fprintf('2D harita oluşturuluyor (3D verinin 2D indirgenmesi)...\n\n');

% Mutlak değer al (Enerji / Energy)
gpr_enerji = abs(gpr_verisi);

%% --- C-SCAN: Maksimum Genlik Yöntemi ---
% Denklem / Equation: M(x,y) = max_t |S(x,y,t)|
% Derinlik boyunca maksimum sinyali al
gpr_c_scan = squeeze(max(gpr_enerji, [], 1))';  % [y x] >> [x y] olacak şekilde
fprintf('   → C-Scan haritası oluşturuldu (Max Amplitude): %d × %d piksel\n', ...
    size(gpr_c_scan, 1), size(gpr_c_scan, 2));

% Porozite haritası: Derinlik (Z) boyunca entegre et (X-Y planına indir)
% Porosity integration: Integrate along depth (Z) to project onto X-Y plane
% Bu, GPR maksimum genlik ile porozite dağılımını aynı X-Y düzlemde karşılaştırmamızı sağlar
porozite_model_2d = squeeze(sum(porozite_verisi, 1))';  % [x y] -> transpose -> [y x]
fprintf('   → Porozite modeli 2D haritaya indirgendi (Derinlik Entegrali): %d × %d piksel\n', ...
    size(porozite_model_2d, 1), size(porozite_model_2d, 2));

%% ============================================================================
%  BÖLÜM 3: SINYAL-POROZİTE KORRELASYON ANALİZİ
%  (SECTION 3: SIGNAL-POROSITY CORRELATION ANALYSIS)
%  ============================================================================

fprintf('\n==================== KORRELASYON ANALİZİ ====================\n');
fprintf('Sinyal-Porozite İlişkisi İnceleniyor...\n\n');

%% --- BOYUT UYUMSUZLUĞU FİKS: İnterpolasyon (Dimension Reconciliation) ---
% C-Scan ve Porozite haritaları farklı spatial çözünürlüklerde olabilir
% Her ikiyi de ortak bir koordinat gridi üzerine interpolate edelim

fprintf('   Adım 1: Ortak koordinat sistemi oluşturuluyor...\n');

% Overlapping X-Y region bul (her iki dataset de mevcut olan bölge)
x_min = max(x_vektoru(1), x_model(1));
x_max = min(x_vektoru(end), x_model(end));
y_min = max(y_vektoru(1), y_model(1));
y_max = min(y_vektoru(end), y_model(end));

% Ortak grid oluştur (daha ince çözünürlük için 100×100 piksel)
common_x = linspace(x_min, x_max, 100);
common_y = linspace(y_min, y_max, 100);
[XI, YI] = meshgrid(common_x, common_y);

fprintf('      → Overlapping bölge: X[%.3f, %.3f] Y[%.3f, %.3f]\n', x_min, x_max, y_min, y_max);

% GPR C-Scanı interpolate et (interp2: x ekseni = sütun, y ekseni = satır)
fprintf('   Adım 2: GPR C-Scan interpolasyonu...\n');
[Xgpr, Ygpr] = meshgrid(x_vektoru, y_vektoru);  % GPR koordinatları
gpr_interp = interp2(Xgpr, Ygpr, gpr_c_scan, XI, YI, 'linear', 0);
fprintf('      → Tamamlandı: [%d × %d] → [%d × %d]\n', ...
    size(gpr_c_scan, 1), size(gpr_c_scan, 2), size(gpr_interp, 1), size(gpr_interp, 2));

% Porozite haritasını interpolate et (x_model, y_model koordinatları)
fprintf('   Adım 3: Porozite modeli interpolasyonu...\n');
[Xporo, Yporo] = meshgrid(x_model, y_model);  % Porozite koordinatları
poro_interp = interp2(Xporo, Yporo, porozite_model_2d, XI, YI, 'linear', 0);
fprintf('      → Tamamlandı: [%d × %d] → [%d × %d]\n', ...
    size(porozite_model_2d, 1), size(porozite_model_2d, 2), size(poro_interp, 1), size(poro_interp, 2));

% Normalizasyon: Her iki harita da [0, 1] aralığına ölçekle
fprintf('   Adım 4: Normalizasyon...\n');
gpr_c_scan_norm = (gpr_interp - nanmin(gpr_interp(:))) / (nanmax(gpr_interp(:)) - nanmin(gpr_interp(:)));
porozite_norm = (poro_interp - nanmin(poro_interp(:))) / (nanmax(poro_interp(:)) - nanmin(poro_interp(:)));

% NaN değerleri sil (interpolation sırasında oluşabilir)
valid_idx = ~isnan(gpr_c_scan_norm(:)) & ~isnan(porozite_norm(:));
gpr_vec = gpr_c_scan_norm(valid_idx);
poro_vec = porozite_norm(valid_idx);

fprintf('      → Geçerli örnek sayısı: %d / %d\n', length(gpr_vec), numel(gpr_c_scan_norm));

% Pearson Korrelasyon Katsayısı hesapla (şimdi aynı boyutlardadırlar)
correlation_coeff = corr(gpr_vec, poro_vec);

% İstatistikler (orijinal ve interpolated verilerden)
gpr_mean = mean(gpr_c_scan(:));
gpr_std = std(gpr_c_scan(:));
gpr_max = max(gpr_c_scan(:));

gpr_interp_mean = nanmean(gpr_vec);
gpr_interp_std = nanstd(gpr_vec);

poro_mean = mean(porozite_model_2d(:));
poro_std = std(porozite_model_2d(:));

poro_interp_mean = nanmean(poro_vec);
poro_interp_std = nanstd(poro_vec);

fprintf('   → Pearson Korrelasyon Katsayısı: r = %.4f\n', correlation_coeff);
fprintf('   → GPR Sinyal (istatistikler - interpolated):\n');
fprintf('      Ort: %.4f, Std: %.4f\n', gpr_interp_mean, gpr_interp_std);
fprintf('   → Porozite Modeli (istatistikler - interpolated):\n');
fprintf('      Ort: %.4f, Std: %.4f\n', poro_interp_mean, poro_interp_std);

% Veri kalitesi göstergesi
if correlation_coeff > 0.5
    fprintf('   ✓ İyi korrelasyon: GPR sinyali porozite modelini iyi temsil ediyor\n');
elseif correlation_coeff > 0.3
    fprintf('   ~ Orta korrelasyon: Sinyal kısmen model uyumlu\n');
else
    fprintf('   ⚠ Düşük korrelasyon: Model geçerliliği sorgulanabilir\n');
end

fprintf('\n');

%% ============================================================================
%  BÖLÜM 4: GÖRSELLEŞTIRME I - 2D HARITALAR
%  (SECTION 4: VISUALIZATION I - 2D MAPS)
%  ============================================================================

fprintf('==================== 2D GÖRSELLEŞTIRME ====================\n');

% Şekil 1: GPR C-Scan ve Porozite Karşılaştırması (interpolated maps ile)
figure('Name', 'GPR 2D Dogrulama Analizi', 'Color', 'w', 'Units', 'normalized', ...
    'Position', [0.05 0.55 0.9 0.4]);

%% Grafik 1: GPR C-Scan (İnterpolasyonlu / Interpolated)
subplot(1, 2, 1);
contourf(XI, YI, gpr_interp, 20);  % Contour plot for better visualization
axis xy image;
colormap(gca, 'jet');
cb1 = colorbar;
cb1.Label.String = 'Sinyal Gücü (V)';
title('GPR C-Scan: Maksimum Genlik (İnterpolasyonlu)', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('X Mesafe (m)');
ylabel('Y Mesafe (m)');
grid on; grid minor;

%% Grafik 2: Porozite Modeli (İnterpolasyonlu / Interpolated)
subplot(1, 2, 2);
contourf(XI, YI, poro_interp, 20);  % Contour plot
axis xy image;
colormap(gca, 'parula');
cb2 = colorbar;
cb2.Label.String = 'Porozite (%)';
title('Porozite Modeli: Ground Truth (İnterpolasyonlu)', 'FontSize', 12, 'FontWeight', 'bold');
xlabel('X Mesafe (m)');
ylabel('Y Mesafe (m)');
grid on; grid minor;

sgtitle(sprintf('2D Analiz: Sinyal-Porozite Korrelasyonu (r=%.3f)', correlation_coeff), ...
    'FontSize', 13, 'FontWeight', 'bold');

fprintf('   ✓ 2D harita görselleştirildi (Figure 1)\n');

%% ============================================================================
%  BÖLÜM 5: GÖRSELLEŞTIRME II - 3D OPTİMİZE GÖRÜNÜM
%  (SECTION 5: VISUALIZATION II - 3D OPTIMIZED VIEW)
%  ============================================================================

fprintf('\n==================== 3D GÖRSELLEŞTIRME ====================\n');
fprintf('Performans açısından optimize 3D görünüm hazırlanıyor...\n\n');

% Izgara oluştur / Create coordinate grid
[X_grid, T_grid, Y_grid] = meshgrid(x_vektoru, t_vektoru, y_vektoru);

%% --- AKILLI SEYRELTİŞ (SMART DOWNSAMPLING) ---
% Yöntem: İki aşamalı seyreltme
% 1. Aşama: Eşik değer (Threshold) - Sadece güçlü sinyalleri tut
% 2. Aşama: Nokta sınırı (Point limit) - Performans için maksimum nokta sayısı

fprintf('   Aşama 1: Eşik Değeri Uygulanıyor...\n');

% Eşik değeri: Max'ın %20'si altını at (gürültü filtrelemesi)
% Threshold: Remove points below 20% of max (noise filtering)
max_val = max(gpr_enerji(:));
esik = max_val * 0.20; 

% Eşiği geçen noktaları bul
indeksler = find(gpr_enerji > esik);
fprintf('      → Filtreleme sonrası nokta sayısı: %d (Toplam: %d, Oranı: %.1f%%)\n', ...
    length(indeksler), numel(gpr_enerji), 100*length(indeksler)/numel(gpr_enerji));

fprintf('   Aşama 2: Performans Sınırı Uygulanıyor...\n');

% Hedef nokta sayısı (bilgisayarın rahat döndürebileceği)
% Target point count (comfortable to rotate on standard hardware)
hedef_nokta_sayisi = 30000;
mevcut_nokta_sayisi = length(indeksler);

if mevcut_nokta_sayisi > hedef_nokta_sayisi
    % Eğer çok fazla nokta varsa, aralardan atlayarak seç
    atlama_orani = round(mevcut_nokta_sayisi / hedef_nokta_sayisi);
    secilen_indeksler = indeksler(1:atlama_orani:end);
    fprintf('      → Veri %dx oranında seyreltildi (%d nokta)\n', atlama_orani, length(secilen_indeksler));
else
    secilen_indeksler = indeksler;
    fprintf('      → Seyreltme gerekmedi (%d nokta)\n', length(secilen_indeksler));
end

% Seçilen verileri hazırla (koordinatlar ve renkler)
x_pts = X_grid(secilen_indeksler);
y_pts = Y_grid(secilen_indeksler);
z_pts = T_grid(secilen_indeksler);
c_pts = gpr_enerji(secilen_indeksler);

fprintf('\n   Işleniyor... 3D Görünüm oluşturuluyor.\n');

%% --- 3D ÇİZİM ---
figure('Name', 'GPR 3D Yansiyan Yorumlama', 'Color', 'w', 'Units', 'normalized', ...
    'Position', [0.05 0.05 0.9 0.4]);

scatter3(x_pts, y_pts, z_pts, 40, c_pts, 'filled', 'MarkerEdgeColor', 'none', ...
    'MarkerFaceAlpha', 0.6);

colormap('jet');
cb = colorbar;
cb.Label.String = 'Sinyal Amplitüdü (V)';

xlabel('X Mesafe (m)'); 
ylabel('Y Mesafe (m)'); 
zlabel('Zaman / Derinlik (ns)');
title('3D Yeraltı Radar Görüntüsü (Optimize Edilmiş)', 'FontSize', 12, 'FontWeight', 'bold');

set(gca, 'ZDir', 'reverse');  % Derinliği Z ekseninin ters yönüne ayarla
grid on;
axis tight;
view(45, 30);
rotate3d on;

fprintf('   ✓ 3D görünüm hazırlandı (Figure 2)\n');
fprintf('   ℹ Fare: Döndürme için sol tıkla ve sürükle\n');

%% ============================================================================
%  BÖLÜM 6: ÖZETLEMEYİ VE MIDTERM RAPORU İÇİN SONUÇLAR
%  (SECTION 6: SUMMARY & RESULTS FOR MIDTERM REPORT)
%  ============================================================================

fprintf('\n==================== SONUÇLAR VE ÖZETİ ====================\n\n');

fprintf('DATASET BİLGİLERİ / DATASET INFORMATION:\n');
fprintf('   → Araştırma Alanı / Study Area: Koyan & Tronicke (2019)\n');
fprintf('   → Yüzey Boyutu / Survey Dimension: %.1f m × %.1f m\n', ...
    x_vektoru(end) - x_vektoru(1), y_vektoru(end) - y_vektoru(1));
fprintf('   → Derinlik Aralığı / Depth Range: 0 - %.1f ns ≈ 0 - %.1f m\n', ...
    t_vektoru(end), t_vektoru(end) * 0.03);  % Yaklaşık hız: 0.03 m/ns
fprintf('   → Merkez Frekans / Center Frequency: %.0f MHz\n', fc);
fprintf('   → Model Çözünürlüğü / Model Resolution: %.3f m\n', res);

fprintf('\nYÖNTEM ÖZETİ / METHOD SUMMARY:\n');
fprintf('   1. Veri İşleme / Processing:\n');
fprintf('      → C-Scan Haritalama: 3D veriyi 2D''ye max-amplitude yöntemi ile indirgedi\n');
fprintf('      → Normalize: Tüm veriler [0, 1] aralığına ölçeklendirildi\n');
fprintf('   2. Doğrulama / Verification:\n');
fprintf('      → Pearson Korrelasyon: r = %.4f\n', correlation_coeff);
fprintf('      → İstatistiksel Analiz: Sinyal ve model özellikleri karşılaştırıldı\n');
fprintf('   3. Görselleştirme / Visualization:\n');
fprintf('      → 2D Haritalar: GPR Sinyali vs. Porozite Modeli\n');
fprintf('      → 3D Scatter Plot: Smart downsampling ile optimize edildi (%d nokta)\n', ...
    length(secilen_indeksler));

fprintf('\nANALİZ SONUÇLARI / ANALYSIS RESULTS:\n');
fprintf('   GPR Sinyal Özellikleri / Signal Properties (aligned grid):\n');
fprintf('      • Ortalama / Mean: %.4f\n', gpr_interp_mean);
fprintf('      • Standart Sapma / Std Dev: %.4f\n', gpr_interp_std);
fprintf('   Porozite Modeli Özellikleri / Model Properties (aligned grid):\n');
fprintf('      • Ortalama / Mean: %.4f\n', poro_interp_mean);
fprintf('      • Standart Sapma / Std Dev: %.4f\n', poro_interp_std);

fprintf('\nYORUM / INTERPRETATION:\n');
if correlation_coeff > 0.6
    fprintf('   ✓ YÜKSEK KORELASYON: GPR sinyalleri porozite dağılımıyla iyi uyum gösteriyor.\n');
    fprintf('     Simulasyon doğruluğu YÜKSEK.\n');
elseif correlation_coeff > 0.4
    fprintf('   ~ ORTA KORELASYON: GPR sinyalleri kısmen porozite dağılımıyla uyumlu.\n');
    fprintf('     Bazı sistem faktörleri ve kalitesi beklenebilir.\n');
else
    fprintf('   ⚠ DÜŞÜK KORELASYON: İstatistiksel ilişki zayıf.\n');
    fprintf('     Model revizyonu veya kalibrasyon gerekebilir.\n');
end

fprintf('\n');
fprintf('==================== TAMAMLANDI ====================\n');
fprintf('✓ Analiz başarıyla tamamlandı.\n');
fprintf('✓ İki grafik (2D ve 3D) oluşturuldu.\n');
fprintf('✓ Korrelasyon ve istatistiksel veriler hesaplandı.\n');

% Sonuçları workspace'e kaydet
simulation_results.correlation = correlation_coeff;
% Sonuçları workspace'e kaydet
simulation_results.correlation = correlation_coeff;
simulation_results.gpr_stats_original = struct('mean', gpr_mean, 'std', gpr_std, 'max', gpr_max);
simulation_results.gpr_stats_aligned = struct('mean', gpr_interp_mean, 'std', gpr_interp_std);
simulation_results.porosity_stats_original = struct('mean', poro_mean, 'std', poro_std);
simulation_results.porosity_stats_aligned = struct('mean', poro_interp_mean, 'std', poro_interp_std);
simulation_results.dataset_info = struct('fc_mhz', fc, 'res_m', res, ...
    'profiles', nprofiles, 'traces', ntraces, 'samples', nsamples);
simulation_results.alignment_info = struct('x_min', x_min, 'x_max', x_max, ...
    'y_min', y_min, 'y_max', y_max, 'grid_size', [100, 100], ...
    'valid_samples', length(gpr_vec));

% Interpolated maps (for potential further analysis)
simulation_results.gpr_interpolated = gpr_interp;
simulation_results.porosity_interpolated = poro_interp;
simulation_results.common_grid = struct('X', XI, 'Y', YI);

fprintf('→ Sonuçlar workspace değişkeninde saklanmıştır: ''simulation_results''\n');
fprintf('→ Aligned grid istatistikleri: simulation_results.gpr_stats_aligned ve simulation_results.porosity_stats_aligned\n');
fprintf('→ İnterpolated haritalar: simulation_results.gpr_interpolated, simulation_results.porosity_interpolated\n');
fprintf('→ Grafikler interaktif olduğundan kaydedilmek istenirse:\n');
fprintf('   saveas(gcf, ''gpr_analysis_results.fig'')\n\n');

%% ============================================================================
% SCRIPT SONU / END OF SCRIPT
%% ============================================================================
