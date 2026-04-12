function gained_data = apply_gain(gpr_data, z_axis)
% APPLY_GAIN: Bu fonksiyon sinyal enerjisindeki derinlik (Z ekseni/zaman) 
% kaynaklı matematiksel zayıflamayı (Attenuation) engellemek ve derin anomali
% yapılarını netleştirmek için üstel (Exponential) Kazanç fonksiyonu uygular.

    disp('  -> [DSP Adım 3]: Gain (Derinlik Tavanlama Kazancı Uygulanıyor)...');
    
    [numX, numY, maxZ] = size(gpr_data);
    gained_data = zeros(numX, numY, maxZ);
    
    % Zaman / Derinlik adımları (z_axis indeksine paralel)
    % Üstel sönümleme (Exponential Gain) genlik katsayısı belirliyoruz:
    % Çok yüksek değerler gürültüyü abartabileceğinden düşük ve kontrollü bir alfa seçiyoruz.
    alpha = 0.005; % Derinlikteki zayıflamayı dengelemek için yumuşatılmış kazanç
    
    % Her z seviyesine uygulanacak kazanç matrisi veya vektörü
    gain_vector = exp(alpha .* z_axis(:));
    
    % Elektromanyetik dalgalar geometrik sönümleme de yaşar (mesafenin 
    % karesi vb). Burada exponential kazanç vektörü ile matris bazında çarparız.
    
    for x = 1:numX
        for y = 1:numY
            current_trace = squeeze(gpr_data(x, y, :)); 
            
            % Sinyal Kazancı (Gain) işlemi:
            % Derinlik seviyesi ile artan gain katsayısını noktadan noktaya (.*) çarpımıyla
            amplified_trace = current_trace .* gain_vector;
            
            gained_data(x, y, :) = amplified_trace;
        end
    end
end
