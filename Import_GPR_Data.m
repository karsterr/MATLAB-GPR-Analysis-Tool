%% ============================================================================
%  GPR VERİSİ KÜTÜĞÜ YÜKLEME VE GÖRÜNÜM
%  LOADING AND VISUALIZATION OF GPR DATA
%
%  Koyan & Tronicke (2019) tarafından gprMax simulatörü ile oluşturulan
%  gerçek zemin penetrasyon radarı (GPR) verisini yükler ve görseller.
%
%  Loads and visualizes real GPR simulated data created by Koyan & Tronicke
%  (2019) using gprMax simulator.
%  
%  Author (Original): Philipp Koyan, Universitaet Potsdam, 2019
%  Optimized: Kara, 2026
%  ============================================================================

clc; clear; close all;

fprintf('\n==================== GPR VERİSİ GÖRÜNÜMÜ ====================\n');
fprintf('Koyan & Tronicke (2019) Dataset - Entegre Analiz\n\n');

%% ============================================================================
%  BÖLÜM 1: VERİ YÜKLEME VE METADATA OKUMA
%  (SECTION 1: DATA LOADING AND METADATA EXTRACTION)
%  ============================================================================

fprintf('Bölüm 1: GPR Verisi Yükleniyor...\n\n');

% GPR H5 dosyası (HDF5 format)
filename = fullfile('dataset/Koyan_Tronicke_2019', 'GPR_Data.h5');

if ~isfile(filename)
    error('HATA: Dosya bulunamadı - %s', filename);
end

% --- 3D GPR VERISININ OKUNMASI ---
gprData = h5read(filename, '/gprData');  % 3D veri: [zaman, x, y]

% --- METADATA (GEOMETRI VE PARAMETRELER) ---
dt = h5readatt(filename, '/', 'dt');                      % Zaman adımı (ns)
t = h5read(filename, '/tvec');                             % Zaman vektoru (ns)
vrs = h5readatt(filename, '/', 'gprMax');                  % gprMax versiyonu
fc = h5readatt(filename, '/', 'centre_freq');              % Merkez frekans (MHz)
res = h5readatt(filename, '/', 'model discretization');    % Model çözünürlüğü (m)
nprofiles = h5readatt(filename, '/', 'nprofiles');         % Profil sayısı
nsamples = h5readatt(filename, '/', 'nsamples');           % Her izde örnek sayısı
ntraces = h5readatt(filename, '/', 'ntraces');             % Toplam iz sayısı

% --- KOORDİNAT VEKTÖRLERI ---
x = h5read(filename, '/xvec');   % X ekseni (m)
y = h5read(filename, '/yvec');   % Y ekseni (m)
xoff = h5readatt(filename, '/', 'xoff');  % Kaynak-alıcı uzaklığı (m)

% Veri özetini göster
fprintf('✓ GPR Verisi Yüklendi:\n');
fprintf('  • Boyutlar: [%d (zaman) × %d (X) × %d (Y)]\n', ...
    size(gprData, 1), size(gprData, 2), size(gprData, 3));
fprintf('  • Profil sayısı (B-Scan): %d\n', nprofiles);
fprintf('  • Her profildeki iz sayısı (A-Scan): %d\n', ntraces);
fprintf('  • Örnek sayısı per iz: %d\n', nsamples);

fprintf('\n✓ Sistem Parametreleri:\n');
fprintf('  • Merkez Frekans: %g MHz\n', fc);
fprintf('  • Model Çözünürlüğü: %g m\n', res);
fprintf('  • Zaman Adımı: %g ns\n', dt);
fprintf('  • Kaynak-Alıcı Uzaklığı: %g m\n', xoff);

fprintf('\n✓ Geometri:\n');
fprintf('  • X Aralığı: [%.3f, %.3f] m (Adım: %.3f m)\n', ...
    x(1), x(end), x(2)-x(1));
fprintf('  • Y Aralığı: [%.3f, %.3f] m (Adım: %.3f m)\n', ...
    y(1), y(end), y(2)-y(1));
fprintf('  • Zaman Aralığı: [%.1f, %.1f] ns\n', t(1), t(end));

%% ============================================================================
%  BÖLÜM 2: GÖRSELLEŞTIRME I - X-T PROFİL İZLERİ (B-SCANS)
%  (SECTION 2: VISUALIZATION I - X-T PROFILE SLICES / B-SCANS)
%  ============================================================================

fprintf('\nBölüm 2: X-T Profil İzleri (B-Scan) Gösteriliyor...\n');
fprintf('(Her profil sabit Y pozisyonunda X''de değişim gösterir)\n\n');

figure('NumberTitle', 'off', 'Name', 'GPR X-T Profil İzleri (B-Scans)', ...
    'Color', 'w', 'Units', 'centimeters', 'Position', [1 1 40 20]);
movegui(gcf, 'center');

% İlk 5 profili göster (tüm profiller gösterilirse uzun zaman alır)
num_profiles_to_show = min(5, nprofiles);
step = max(1, floor(nprofiles / num_profiles_to_show));

for ii = 1:step:nprofiles
    % Her profili ayrı çıkar: [zaman, x] -> squeeze ile [zaman, x] formatına
    dat2show = squeeze(gprData(:, :, ii));
    
    imagesc(x, t, dat2show);
    axis image;
    colormap(gca, 'gray');
    caxis([-0.1 0.1]);  % Renk ölçeği (amplitude limits)
    
    title(sprintf('GPR B-Scan Profili: Y = %.3f m (%d/%d)', y(ii), ii, nprofiles), ...
        'FontSize', 12, 'FontWeight', 'bold');
    h = colorbar;
    h.YLabel.String = 'Genlik (V)';
    
    xlabel('X Mesafe (m)', 'FontSize', 11);
    ylabel('Zaman (ns) / Derinlik', 'FontSize', 11);
    pbaspect([1 (0.085*max(t)/2)/(x(end)-x(1)) 1]);
    set(gca, 'FontSize', 11);
    
    drawnow;
    pause(0.8);  % Her resimde kısa bekle
end

fprintf('✓ B-Scan profilleri gösterildi.\n');

%% ============================================================================
%  BÖLÜM 3: GÖRSELLEŞTIRME II - X-Y ZAMAN İZLERİ (TIME-SLICES)
%  (SECTION 3: VISUALIZATION II - X-Y TIME SLICES)
%  ============================================================================

fprintf('\nBölüm 3: X-Y Zaman İzleri (Time-Slice) Gösteriliyor...\n');
fprintf('(Her zaman seviyesi (derinliği) 2D plan harita gösterir)\n\n');

figure('NumberTitle', 'off', 'Name', 'GPR X-Y Zaman İzleri (Time-Slices)', ...
    'Color', 'w', 'Units', 'centimeters', 'Position', [1 1 40 20]);
movegui(gcf, 'center');

% Zaman 25ns''den sonrasını göster (erken zamanlar genellikle sistem enkodlaması)
start_time = find(t > 25, 1, 'first');
if isempty(start_time)
    start_time = 1;
end

time_step = max(1, floor((numel(t) - start_time) / 5));  % Yaklaşık 5 resim göster

for ii = start_time:time_step:numel(t)
    % Her zaman indeksinde [x, y] planını çıkar ve transpose et
    dat2show = squeeze(gprData(ii, :, :))';
    
    imagesc(x, y, dat2show);
    axis xy image;
    colormap(gca, 'gray');
    caxis([-0.1 0.1]);  % Renk ölçeği
    
    title(sprintf('GPR Time-Slice: t = %.2f ns (Derinlik Seviyesi)', t(ii)), ...
        'FontSize', 12, 'FontWeight', 'bold');
    h = colorbar;
    h.YLabel.String = 'Genlik (V)';
    
    xlabel('X Mesafe (m)', 'FontSize', 11);
    ylabel('Y Mesafe (m)', 'FontSize', 11);
    axis image;
    set(gca, 'FontSize', 11);
    
    drawnow;
    pause(0.8);  % Her resimde kısa bekle
end

fprintf('✓ Time-Slice profilleri gösterildi.\n');

%% SONUÇ
fprintf('\n==================== TAMAMLANDI ====================\n');
fprintf('✓ GPR verisi başarıyla yüklendi ve görselleştirildi.\n');
fprintf('✓ İki tür görünüm sunuldu:\n');
fprintf('  1. X-T Profiller (B-Scans): Sabit Y''de X-T değişimi\n');
fprintf('  2. X-Y Haritalar (Time-Slices): Sabit derinlikte 2D plan\n\n');
    ' m, source-receiver-offset: ' num2str(xoff) ' m'])

%% Visualization: GPR data 
% x-t-(inline|profile)-slices

f1=figure('NumberTitle','off','Name','GPR inline|profile slices');
set(f1,'Color',[1 1 1],'Menubar','none','Units','centimeters','Position',[1 1 40 20]);
movegui(f1,'center')

for ii=1:nprofiles
    dat2show=squeeze(gprData(:,:,ii));
    imagesc(x,t,dat2show);
    colormap gray
    caxis([-0.1 0.1])
    title(['GPR profile slice at y = ' num2str(y(ii)) ' m'])
    h = colorbar; 
    h.YLabel.String = 'Amplitude';
    xlabel('x in m')
    ylabel('t in ns')
    pbaspect([1 (0.085*max(t)/2)/(x(end)-x(1)) 1])
    set(gca,'FontSize',16)
    pause(.5)
end

% x-y-(time)-slices

f1=figure('NumberTitle','off','Name','GPR time slices');
set(f1,'Color',[1 1 1],'Menubar','none','Units','centimeters','Position',[1 1 40 20]);
movegui(f1,'center')

for ii=find(t>25,1,'first'):10:numel(t)
    dat2show=squeeze(gprData(ii,:,:))';
    imagesc(x,y,dat2show);
    colormap gray
    caxis([-0.1 0.1])
    title(['GPR time slice at t = ' num2str(round(t(ii),1)) ' ns'])
    h = colorbar; 
    h.YLabel.String = 'Amplitude';
    xlabel('x in m')
    ylabel('y in m')    
    axis xy
    axis image
    set(gca,'FontSize',16)
    pause(.5)
end