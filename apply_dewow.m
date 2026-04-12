function [dewowed_data] = apply_dewow(gpr_data_3d)
% APPLY_DEWOW: Bu fonksiyon, 3 boyutlu GPR veri setindeki (X, Y, Z) her bir 
% tarama/iz (trace) için sinyali merkeze çekme işlemini (DC offset kaldırma) yapar.
%
% Kısıtlamalar: Görüntü işleme araç kutuları kullanılmamıştır.
% Matematiksel olarak: Her sütunun/izin ortalama (mean) değeri, o izin
% kendisinden çıkartılır. Bazen "Low Frequency Wow" düşük geçiren (Low-Pass)
% sinyal ile giderilir. Bu basit De-wow da aynı görevi görür.

    disp('  -> [DSP Adım 1]: De-wow (Merkeze Çekme) uygulanıyor...');
    
    [numX, numY, maxZ] = size(gpr_data_3d);
    
    dewowed_data = zeros(numX, numY, maxZ);
    
    % Her bir X (genişlik) ve Y (uzunluk) konumu için Z (derinlik) 
    % sinyalinin üzerindeki düşük frekans kaymasını (sapmayı) kaldır.
    for x = 1:numX
        for y = 1:numY
            % İzin kendisi
            current_trace = squeeze(gpr_data_3d(x, y, :)); 
            
            % Sinyalin tüm derinliği üzerindeki ortalama değerini hesapla
            mean_val = mean(current_trace); 
            
            % Sinyalin kendisinden bu ortalamayı (DC kaymasını) çıkar
            dewowed_data(x, y, :) = current_trace - mean_val;
        end
    end
end
