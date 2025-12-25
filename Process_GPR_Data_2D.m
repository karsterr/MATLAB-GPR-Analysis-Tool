%% GPR FINAL PROJESI: YERALTI RADAR VERISININ DOGRULANMASI
% GPR sinyal genlikleri ile gercek yeralti modelinin karsilastirilmasi.

clc; clear; close all;

%% 1. VERI DOSYALARININ YUKLENMESI
dosya_gpr = 'GPR_Data.h5';
dosya_model = 'Porosity_Model.h5';

if ~isfile(dosya_gpr) || ~isfile(dosya_model)
    error('Veri dosyalari bulunamadi. Lutfen .h5 dosyalarini kontrol edin.');
end

% GPR verisinin okunmasi
gpr_verisi = h5read(dosya_gpr, '/gprData');
x_vektoru = h5read(dosya_gpr, '/xvec');
y_vektoru = h5read(dosya_gpr, '/yvec');

% Model verisinin okunmasi (Dogrulama icin)
porozite_verisi = h5read(dosya_model, '/porosity');

%% 2. VERI ISLEME (C-SCAN HARITALAMA)
% 3 Boyutlu verinin 2 Boyutlu haritaya indirgenmesi (Max Genlik Yontemi)

% GPR icin mutlak deger ve derinlik boyunca maksimum izdusum
gpr_harita = squeeze(max(abs(gpr_verisi), [], 1))';

% Gercek model icin derinlik boyunca toplam yogunluk
model_harita = squeeze(sum(porozite_verisi, 1))';

%% 3. GORSELLESTIRME VE KARSILASTIRMA
figure('Name', 'GPR Dogrulama Analizi', 'Color', 'w', 'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.5]);

% Grafik 1: GPR Sinyal Gucu
subplot(1, 2, 1);
imagesc(x_vektoru, y_vektoru, gpr_harita);
axis xy image;
colormap(gca, 'jet');
colorbar;
title('GPR Radar Tespiti (Sinyal Gucu)');
xlabel('Mesafe X (m)');
ylabel('Mesafe Y (m)');

% Grafik 2: Gercek Zemin Modeli
subplot(1, 2, 2);
imagesc(x_vektoru, y_vektoru, model_harita);
axis xy image;
colormap(gca, 'parula');
colorbar;
title('Referans Yeralti Modeli (Ground Truth)');
xlabel('Mesafe X (m)');
ylabel('Mesafe Y (m)');

sgtitle('Analiz Sonucu: Radar Verisi ve Model Dogrulamasi', 'FontSize', 14, 'FontWeight', 'bold');