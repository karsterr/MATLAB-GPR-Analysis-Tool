function bg_removed_data = apply_background_removal(dewowed_data)
% APPLY_BACKGROUND_REMOVAL: GPR antenin sinyal gönderip alırken cihaz 
% üzerinden doğrudan gelen yatay yansımaları (arka plan gürültüsü) temizler.
% Tüm matris/veri küpü üzerindeki ortalama profili referans alarak işlemi
% yapan matematiksel DSP çıkarma adımıdır. Görüntü işleme araçları sıfırdır.

    disp('  -> [DSP Adım 2]: Background Removal (Arka Plan Temizleme)...');
    
    [numX, numY, maxZ] = size(dewowed_data);
    bg_removed_data = zeros(numX, numY, maxZ);
    
    % Arka Plan Ortalama İzi (Global Mean Trace)
    % Her X eksenindeki tüm Y noktalarına (hattına) ait veya kübün 
    % bütünü üzerindeki ortak anten yansımaları.
    % Biz, her derinlik (Z) seviyesindeki tüm X-Y konumlarının ortalamasını 
    % alarak bir "Arka Plan (Background)" izi oluşturacağız.
    
    mean_background_trace = zeros(maxZ, 1);
    
    for z = 1:maxZ
        % Belirli derinlikteki Z ekseni için X-Y alanından ortalamalar
        z_slice = dewowed_data(:, :, z);
        mean_background_trace(z) = mean(z_slice(:));
    end
    
    % Şimdi, tespit edilen arka plan izini (Antenin kendisinden 
    % gelen hava, vb) her bir gerçek izden çıkarıyoruz:
    for x = 1:numX
        for y = 1:numY
            current_trace = squeeze(dewowed_data(x, y, :));
            bg_removed_data(x, y, :) = current_trace - mean_background_trace;
        end
    end
end
