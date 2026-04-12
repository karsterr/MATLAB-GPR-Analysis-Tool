function visualize_3d_gpr(envelope_data, x_axis, y_axis, z_axis)
% VISUALIZE_3D_GPR: Matematiksel eşikleme kurallarına (Thresholding) bağlı kalarak 
% tespit edilen farklı anomali karakterlerindeki noktaları scatter3 (nokta 
% dağılım) komutu ile 3 boyutlu MATLAB alanında çizer. Ekran dökümünde
% x, y, z koordinat sistemi Z ekseni derinliğe dönük olacak şekilde ("reverse") 
% ve döndürülebilir (view3) olarak yapılandırılmıştır.

    disp('  -> [Görselleştirme]: Eşikleme Algoritmaları ile 3B Çizim Yapılıyor...');
    
    [numX, numY, maxZ] = size(envelope_data);
    
    % Veriyi boyutlarına göre dağılım/nokta objesi olarak (Line veya 
    % Matrix'den Array'e) çıkaracağız ki 'scatter3' e yollayalım.
    % Yalnızca eşik (threshold) değerini aşan pikselleri dahil edeceğiz,
    % böylece performans kazanıp net şekiller elde ederiz (Noise filtreleme).

    % Sinyalin istatistiksel genlikleri eşikleme için hesaplanır
    
    % DİKKAT ÇEKİCİ DSP DOKUNUŞU (FIR Low-Pass Filter):
    % Z ekseni (derinlik) boyunca rastgele yüksek frekanslı gürültüleri (spikes) 
    % baskılamak ve gerçek kütlelerin enerjisini öne çıkarmak için "Hareketli Ortalama" 
    % (Moving Average / movmean) ile sinyali yumuşatıyoruz.
    smoothed_envelope = movmean(envelope_data, 5, 3); % Z ekseninde 5 birimlik pencere
    
    max_amp = max(smoothed_envelope(:));
    
    % Malzeme/Eşik Tespiti:
    % Arkadaşınızın görseline uygun şekilde 4 farklı kategoriye ayırıyoruz:
    % 1) Ana Boru (Kırmızı) - En yüksek genlikler
    % 2) İnce / İkincil Yapılar (Turuncu) - Yüksek genlikler
    % 3) Kablo (Sarı) - Orta genlikler
    % 4) Mağara / Boşluk / Arka Plan Yapıları (Mavi/Cyan) - Düşük genlikler
    
    red_threshold    = max_amp * 0.75; 
    orange_threshold = max_amp * 0.50; 
    yellow_threshold = max_amp * 0.30; 
    cyan_threshold   = max_amp * 0.15; 
    
    % Veri setinin TAMAMINI görebileceğiniz vektörel mantığa geçildi
    [X, Y, Z] = ndgrid(x_axis, y_axis, z_axis);
    
    % İndeksleri matris mantıksal sorgusuyla çok hızlı buluyoruz
    idx_red    = smoothed_envelope >= red_threshold;
    idx_orange = (smoothed_envelope >= orange_threshold) & (smoothed_envelope < red_threshold);
    idx_yellow = (smoothed_envelope >= yellow_threshold) & (smoothed_envelope < orange_threshold);
    idx_cyan   = (smoothed_envelope >= cyan_threshold)   & (smoothed_envelope < yellow_threshold);
    
    %% Çizim Bölümü (SCATTER3)
    % Arkadaşınızın çıktısındaki siyah arkaplana uyumlu hale getiriyoruz
    fig = figure('Name', 'GPR 3 Boyutlu Veri Küpü Analizi', 'Color', 'k', ...
                 'Position', [100 100 1000 700]);
    
    % Eksenlerin arkaplanını da koyu yapmak için
    ax = axes('Parent', fig);
    set(ax, 'Color', 'k', 'XColor', 'w', 'YColor', 'w', 'ZColor', 'w', 'GridColor', 'w');
    
    hold on;
    grid on;
    
    % 1. Mağara / Düşük Genlikli Katman (Açık Mavi/Cyan)
    if sum(idx_cyan(:)) > 0
        h_cyan = scatter3(X(idx_cyan), Y(idx_cyan), Z(idx_cyan), ...
            15, [0 0.8 1], 'filled', ...
            'MarkerFaceAlpha', 0.2, 'MarkerEdgeAlpha', 0.2); % Arkada şeffaf bir bulut tabakası
    else
        h_cyan = scatter3(NaN, NaN, NaN, 15, [0 0.8 1], 'filled');
    end
    
    % 2. Kablo (Sarı) Çizimi
    if sum(idx_yellow(:)) > 0
        h_yellow = scatter3(X(idx_yellow), Y(idx_yellow), Z(idx_yellow), ...
            30, [1 1 0], 'filled', ...
            'MarkerFaceAlpha', 0.4, 'MarkerEdgeAlpha', 0.4);
    else
        h_yellow = scatter3(NaN, NaN, NaN, 30, [1 1 0], 'filled');
    end
    
    % 3. İnce Yapılar (Turuncu) Çizimi
    if sum(idx_orange(:)) > 0
        h_orange = scatter3(X(idx_orange), Y(idx_orange), Z(idx_orange), ...
            45, [1 0.5 0], 'filled', ...
            'MarkerFaceAlpha', 0.7, 'MarkerEdgeAlpha', 0.7);
    else
        h_orange = scatter3(NaN, NaN, NaN, 45, [1 0.5 0], 'filled');
    end

    % 4. Ana Boru (Kırmızı) Çizimi
    if sum(idx_red(:)) > 0
        h_red = scatter3(X(idx_red), Y(idx_red), Z(idx_red), ...
            60, [1 0 0], 'filled', 'MarkerEdgeColor', 'none'); 
    else
        h_red = scatter3(NaN, NaN, NaN, 60, [1 0 0], 'filled');
    end

    %% Eksen Ayarları
    xlabel('En');
    ylabel('Boy');
    zlabel('Derinlik');
    title('GPR 3D Haritası (Kırmızı: Ana Boru, Turuncu: İnce, Sarı: Kablo, Mavi: Mağara)', 'Color', 'w');
    
    % GPR algısında Derinlik (Z), yeryüzünden aşağı doğru aktığı için eksen TERS çevrilir:
    set(gca, 'ZDir', 'reverse');
    
    %% Legend ve Görünüm Menüsü
    % Legend'i şeffaf yaparak modern bir görüntü sağlayalım
    lgd = legend([h_red, h_orange, h_yellow, h_cyan], ...
           {'Ana Boru', 'İnce', 'Kablo', 'Mağara'}, ...
           'Location', 'northeastoutside', 'TextColor', 'w');
    set(lgd, 'Color', 'none', 'Box', 'off');
    
    % Arkadaşınızdaki gibi hafif çapraz yatay/boy ağırlıklı bir açı verelim
    view(-45, 30); 
    rotate3d on;   % Etkileşimli döndürme modu
    
    hold off;
end
