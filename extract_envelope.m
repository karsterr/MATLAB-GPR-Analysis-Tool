function envelope_data = extract_envelope(gained_data)
% EXTRACT_ENVELOPE: GPR sinyalinin polaritesinden (alt-üst salınımları) 
% arındırılarak genel yapıyı ve enerjiyi / yansıma katsayısı genlik 
% sınırlarını çıkartmaya yarayan Dijital Sinyal İşleme tekniğidir (Hilbert Dönüşümü vb.)
%
% NOT: Hilbert Dönüşümü sinyalin imajiner (sanal) eksendeki gösterimini 
% sağladığı için matematiksel modül/genlik (abs) kullanılarak genlik 
% zarfı çıkarılır.

    disp('  -> [DSP Adım 4]: Zarf Çıkarma (Envelope Detection)...');
    
    [numX, numY, maxZ] = size(gained_data);
    envelope_data = zeros(numX, numY, maxZ);
    
    % Sinyal zarfı çıkarma 
    for x = 1:numX
        for y = 1:numY
            current_trace = squeeze(gained_data(x, y, :));
            
            % Hilbert Dönüşümü MATLAB'de hazır "hilbert" (Signal Processing 
            % Toolbox gerekebilir, bu nedenle kendimiz temel bir Rectifier
            % uygulayabiliriz yoksa). Ancak "abs(hilbert(x))" temel frekans/zaman 
            % alanıdır. Biz projede Görüntü İşleme Toolbox (Image Processing)
            % kullanmadığımızdan sinyal işleme araçları kullanıyoruz veya
            % matematiksel zarf uyguluyoruz (Doğrultma & Düşük Geçiren Filtre). 
            % 
            % Biz Hilbert kullanarak Zarf Genliği bulalım:
            % abs() genlik değerini verir
            analytic_signal = hilbert(current_trace);
            envelope = abs(analytic_signal);
            
            envelope_data(x, y, :) = envelope;
        end
    end
end
