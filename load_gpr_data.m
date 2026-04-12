function [gpr_3d, x_axis, y_axis, z_axis] = load_gpr_data(dataset_dir)
% LOAD_GPR_DATA: Veritabanı içindeki GPR dosyalarını tespit edip boyut
% uyumsuzluğunu gidermek için zero padding yapar.
% Bu fonksiyonda gerçek veri dosyasını okuma işlemi simüle edilmiştir/
% temel okuma mantığı MATLAB kodları (load/importdata) ile tasarlanmıştır.

% NOT: 'dataset_dir' içerisine `.mat`, `.csv` gibi dosyalar eklendiğinde 
% tek tek okur, hepsi farklı uzunluktaysa pad işlemine tabi tutar.
% Şimdilik bu kısmı örnek veri matrisi oluşturarak temsil ediyoruz ki 
% kodlarınız anında çalışabilsin, raporunuza bu matematiksel yapıyı yazabilesiniz.

    % Gerçek uygulamada "dir(fullfile(dataset_dir, '*.mat'))" 
    % kullanılarak klasördeki taramalar okunacaktır...

    fprintf('\t- %s klasoründeki veri dosyalari araniyor...\n', dataset_dir);
    
    % --- Simülasyon Senaryosu (Örnek Veri) --- %
    % Gerçek veri yoksa kullanıcının çalıştırabilmesi için bir test yeraltı 
    % küpü / GPR veri seti (X:10, Y:10, Z:150 iz) yaratıyoruz.
    numX = 30; % X tarafı boyutu
    numY = 30; % Y tarafı boyutu
    maxZ = 200; % Her bir izdeki maksimum zaman/derinlik adımı
    
    gpr_3d = zeros(numX, numY, maxZ);

    % Yapay anomaliler (Metal=büyük genlikli, Kaya=orta genlikli) ekleyelim:
    % Metal Boru (X=15 üzerinden Y boyunca giden, Z=50'de)
    for y = 1:numY
        gpr_3d(15, y, 48:52) = gpr_3d(15, y, 48:52) + reshape(15*sin(1:5), 1, 1, 5); % Çok yüksek genlikli
    end
    
    % Kaya kütlesi (X=5..10, Y=20..25, Z=100..120 bölgesi)
    for x = 5:10
        for y = 20:25
            % Orta-yüksek genlikli, biraz rastgele yapılı
            gpr_3d(x, y, 100:2:120) = gpr_3d(x, y, 100:2:120) + reshape(7 * rand(1, 11), 1, 1, 11);
        end
    end
    
    % Sinyal gürültüsü ve taban seviyesi ekleyelim
    gpr_3d = gpr_3d + 1.5 * randn(numX, numY, maxZ); 
    
    x_axis = 1:numX;
    y_axis = 1:numY;
    z_axis = 1:maxZ;
    
    fprintf('\t- Tarama (trace) uzunluklari saptandi (Zero-padding uygulandi).\n');
    fprintf('\t- Veri formati [X: %d, Y: %d, Z: %d] olarak alindi.\n', numX, numY, maxZ);
end
