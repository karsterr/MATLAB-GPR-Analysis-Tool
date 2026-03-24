%% ============================================================================
%  POROZİTE MODELİ YÜKLEME VE GÖRÜNÜM
%  LOADING AND VISUALIZATION OF POROSITY MODEL
%
%  Koyan & Tronicke (2019) tarafından hazırlanan yeraltı porozite
%  modelini (Ground Truth) yükler ve 3D görselleştirir.
%
%  Loads and visualizes the subsurface porosity model (Ground Truth)
%  prepared by Koyan & Tronicke (2019).
%  
%  Author (Original): Philipp Koyan, Universitaet Potsdam, 2019
%  Optimized: Kara, 2026
%  ============================================================================

clc; clear; close all;

fprintf('\n==================== POROZİTE MODELİ ====================\n');
fprintf('Koyan & Tronicke (2019) Referans Modeli (Ground Truth)\n\n');

%% ============================================================================
%  BÖLÜM 1: VERİ YÜKLEME (SECTION 1: DATA LOADING)
%  ============================================================================

fprintf('Bölüm 1: Porozite Modeli Yükleniyor...\n\n');

% Porozite modeli H5 dosyası
filename = fullfile('dataset/Koyan_Tronicke_2019', 'Porosity_Model.h5');

if ~isfile(filename)
    error('HATA: Dosya bulunamadı - %s', filename);
end

% --- POROZITE VERİSİ ---
% 3D porozite veri: [derinlik(z) × X × Y]
porosity = h5read(filename, '/porosity');

% --- METADATA ---
res = h5readatt(filename, '/', 'mod_res');   % Model çözünürlüğü (m)

% --- KOORDİNAT VEKTÖRLERI ---
x = h5read(filename, '/xvec');  % X ekseni (m)
y = h5read(filename, '/yvec');  % Y ekseni (m)
z = h5read(filename, '/zvec');  % Z ekseni / Derinlik (m)

% --- POROZİTE RENKLENDİRMESİ ---
% Custom colormap (opsiyonel olarak H5''den okunan parula)
pcmap = h5read(filename, '/pcmap');

% Veri özetini göster
fprintf('✓ Porozite Modeli Yüklendi:\n');
fprintf('  • Boyutlar: [%d (Z/Derinlik) × %d (X) × %d (Y)]\n', ...
    size(porosity, 1), size(porosity, 2), size(porosity, 3));
fprintf('  • Model Çözünürlüğü: %.4f m\n', res);

fprintf('\n✓ Geometri Bilgileri:\n');
fprintf('  • X Aralığı: [%.3f, %.3f] m\n', x(1), x(end));
fprintf('  • Y Aralığı: [%.3f, %.3f] m\n', y(1), y(end));
fprintf('  • Z Aralığı (Derinlik): [%.3f, %.3f] m\n', z(1), z(end));
fprintf('  • Toplam Voxel: %d\n', numel(porosity));

fprintf('\n✓ Porozite Değerleri:\n');
fprintf('  • Minimum: %.4f\n', min(porosity(:)));
fprintf('  • Maksimum: %.4f\n', max(porosity(:)));
fprintf('  • Ortalama: %.4f\n', mean(porosity(:)));

%% ============================================================================
%  BÖLÜM 2: GÖRSELLEŞTIRME I - X-Z PROFİL RESİMLERİ
%  (SECTION 2: VISUALIZATION I - X-Z PROFILE SLICES)
%  ============================================================================

fprintf('\n\nBölüm 2: X-Z Profil İzleri Gösteriliyor...\n');
fprintf('(Her profil sabit Y''de X-Z kesitini gösterir / Vertical Sections)\n');

figure('NumberTitle', 'off', 'Name', 'Porozite Modeli - X-Z Kesitler', ...
    'Color', 'w', 'Units', 'centimeters', 'Position', [1 1 40 20]);
movegui(gcf, 'center');

% Y boyunca örnekle (tüm Y''yi göstermek çok zaman alır)
num_y_slices = min(10, numel(y));
y_indices = round(linspace(1, numel(y), num_y_slices));

for y_idx = y_indices
    % X-Z kesitini çıkar: [Z, X, Y(y_idx)] -> squeeze -> [Z, X]
    dat2show = squeeze(porosity(:, :, y_idx));
    
    imagesc(x, z, dat2show);
    axis image;
    colormap(gca, pcmap);  % Custom porozite colormap
    cb = colorbar;
    cb.Label.String = 'Porozite \Phi';
    
    % Renk ölçeğini sabit tut
    caxis([min(porosity(:)) max(porosity(:))]);
    
    title(sprintf('Porozite Modeli - X-Z Kesiti: Y = %.3f m', y(y_idx)), ...
        'FontSize', 12, 'FontWeight', 'bold');
    xlabel('X (m)', 'FontSize', 11);
    ylabel('Z Derinlik (m)', 'FontSize', 11);
    set(gca, 'FontSize', 11);
    
    drawnow;
    pause(1.0);  % Her kesit arasında bekle
end

fprintf('✓ X-Z kesitleri gösterildi.\n');

%% ============================================================================
%  BÖLÜM 3: GÖRSELLEŞTIRME II - X-Y DERINLIK PLANLARı
%  (SECTION 3: VISUALIZATION II - X-Y DEPTH MAPS)
%  ============================================================================

fprintf('\n\nBölüm 3: X-Y Derinlik Planları Gösteriliyor...\n');
fprintf('(Her harita sabit Z derinliğinde X-Y planını gösterir / Horizontal Slices)\n');

figure('NumberTitle', 'off', 'Name', 'Porozite Modeli - X-Y Derinlik Planları', ...
    'Color', 'w', 'Units', 'centimeters', 'Position', [1 1 40 20]);
movegui(gcf, 'center');

% Z boyunca örnekle (derinlik)
z_step = max(1, floor(numel(z) / 12));  % Yaklaşık 12 derinlik göster

for z_idx = 20:z_step:numel(z)
    % X-Y planını çıkar: [Z(z_idx), X, Y] -> squeeze -> transpose -> [Y, X]
    dat2show = squeeze(porosity(z_idx, :, :))';
    
    imagesc(x, y, dat2show);
    axis image xy;
    colormap(gca, pcmap);
    cb = colorbar;
    cb.Label.String = 'Porozite \Phi';
    cb.TickLength = 0;
    
    % Renk ölçeğini sabit tut
    caxis([min(porosity(:)) max(porosity(:))]);
    
    title(sprintf('Porozite Modeli - X-Y Planı: Z = %.3f m (Derinlik)', z(z_idx)), ...
        'FontSize', 12, 'FontWeight', 'bold');
    xlabel('X (m)', 'FontSize', 11);
    ylabel('Y (m)', 'FontSize', 11);
    set(gca, 'FontSize', 11);
    
    drawnow;
    pause(0.8);  % Her harita arasında bekle
end

fprintf('✓ X-Y derinlik planları gösterildi.\n');

%% ============================================================================
%  BÖLÜM 4: 3D GÖRSELLEŞTIRME (İSTEĞE BAĞLI)
%  (SECTION 4: 3D VISUALIZATION - OPTIONAL)
%  ============================================================================

fprintf('\n\nBölüm 4: 3D Hacimsel Görselleştirme (İsteğe Bağlı)...\n');
fprintf('(Yüksek hafıza kullanımı - küçük modeller için uygun)\n\n');

% Küçük örnekle 3D gösterim (tam model çok büyük olabilir)
step_3d = 2;  % Her 2. voxel''i göster

[X_3d, Z_3d, Y_3d] = meshgrid(x(1:step_3d:end), z(1:step_3d:end), y(1:step_3d:end));
porosity_3d = porosity(1:step_3d:end, 1:step_3d:end, 1:step_3d:end);

figure('NumberTitle', 'off', 'Name', 'Porozite Modeli - 3D Görünüm', ...
    'Color', 'w', 'Units', 'centimeters', 'Position', [1 1 40 20]);
movegui(gcf, 'center');

% 3D Slice Visualization
slice(X_3d, Y_3d, Z_3d, porosity_3d, x(round(numel(x)/2)), ...
    y(round(numel(y)/2)), z(round(numel(z)/2)));

colormap(pcmap);
cb = colorbar;
cb.Label.String = 'Porozite \Phi';
caxis([min(porosity(:)) max(porosity(:))]);

title('Porozite Modeli - 3D Görünüş (Slice Visualization)', ...
    'FontSize', 12, 'FontWeight', 'bold');
xlabel('X (m)');
ylabel('Y (m)');
zlabel('Z Derinlik (m)');
set(gca, 'FontSize', 10);
axis tight;
grid on;

fprintf('✓ 3D görünüş oluşturuldu.\n');

%% SONUÇ
fprintf('\n==================== TAMAMLANDI ====================\n');
fprintf('✓ Porozite modeli başarıyla yüklendi ve görselleştirildi.\n');
fprintf('✓ Üç tür görünüm sunuldu:\n');
fprintf('  1. X-Z Profil İzleri: Dikey kesitler (sabit Y)\n');
fprintf('  2. X-Y Derinlik Planları: Yatay haritalar (sabit Z)\n');
fprintf('  3. 3D Hacimsel: Slice visualization\n\n');
