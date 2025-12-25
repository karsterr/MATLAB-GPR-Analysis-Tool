%% OPTİMİZE EDİLMİŞ HIZLI 3D ISI HARİTASI
% Bu kod, bilgisayarı kasmadan 3D veri görselleştirmesi yapar.
% Yöntem: Veri seyreltme (Downsampling)

clc; clear; close all;

%% 1. VERİ YÜKLEME
filename = 'GPR_Data.h5';
if ~isfile(filename), error('Dosya bulunamadı!'); end

fprintf('Veri okunuyor...\n');
gprData = h5read(filename, '/gprData');
x = h5read(filename, '/xvec');
y = h5read(filename, '/yvec');
t = h5read(filename, '/tvec');

% Mutlak değer (Enerji)
data = abs(gprData);

%% 2. AKILLI SEYRELTME (OPTIMIZATION STEP)
fprintf('Veri optimize ediliyor...\n');

% Izgara oluştur
[X_grid, T_grid, Y_grid] = meshgrid(x, t, y);

% Eşik Değer: Sadece güçlü sinyalleri al (Max'ın %20'si altını at)
max_val = max(data(:));
esik = max_val * 0.20; 

% Eşiği geçen noktaları bul
indeksler = find(data > esik);

% --- KRİTİK NOKTA: NOKTA SAYISINI SINIRLA ---
hedef_nokta_sayisi = 30000; % Bilgisayarın rahat çevireceği ideal sayı
mevcut_nokta_sayisi = length(indeksler);

if mevcut_nokta_sayisi > hedef_nokta_sayisi
    % Eğer çok fazla nokta varsa, aralardan atlayarak seç
    atlama_orani = round(mevcut_nokta_sayisi / hedef_nokta_sayisi);
    secilen_indeksler = indeksler(1:atlama_orani:end);
    fprintf('Performans için veri %dx oranında seyreltildi.\n', atlama_orani);
else
    secilen_indeksler = indeksler;
end

% Seçilen verileri hazırla
x_pts = X_grid(secilen_indeksler);
y_pts = Y_grid(secilen_indeksler);
z_pts = T_grid(secilen_indeksler);
c_pts = data(secilen_indeksler);

fprintf('%d adet nokta çiziliyor... (Lütfen bekleyin)\n', length(secilen_indeksler));

%% 3. HIZLI ÇİZİM
figure('Name', 'Hızlı 3D Analiz', 'Color', 'k', 'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.7]);

% Nokta boyutunu biraz büyütelim (böylece az nokta olsa bile dolu görünür)
% 'filled' komutunu kaldırdık (daha hızlı render için)
scatter3(x_pts, y_pts, z_pts, 35, c_pts, '.'); 

% Görsel Ayarlar
colormap('jet');
c = colorbar;
c.Label.String = 'Sinyal Gücü';
c.Color = 'w';

xlabel('Mesafe X (m)'); ylabel('Mesafe Y (m)'); zlabel('Derinlik (ns)');
title('GPR 3D Analiz (Optimize Edilmiş)', 'Color', 'w', 'FontSize', 14);

set(gca, 'Color', 'k', 'XColor', 'w', 'YColor', 'w', 'ZColor', 'w');
set(gca, 'ZDir', 'reverse');
grid on;
axis tight;
view(45, 30);

% Döndürmeyi aktif et
rotate3d on;

disp('Tamamlandı! Fare ile rahatça döndürebilirsiniz.');