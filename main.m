% Ana Program: GPR Verisi 3 Boyutlu Görselleştirme Projesi
% Açıklama: Bu script, yer altı radarı (GPR) ham verilerini okur, sadece
% temel DSP tekniklerini kullanarak ön işlemden geçirir ve yapay zeka/matematiksel
% eşikleme ile yeraltı anomalilerini 3D scatter plot ile görselleştirir.

clear; clc; close all;

%% 1. Veri Okuma ve Ön İşleme
% dataset/ klasöründeki dosyaları tara ve uygun olanı matris olarak döndür.
% Tarama uzunlukları farklı olan matrisler zero-padding ile aynı boyuta getirilir.
disp('1. Veri yükleniyor ve ön işlemler yapılıyor (Zero-padding)...');
[gpr_data_3d, x_axis, y_axis, z_axis] = load_gpr_data('dataset');

%% 2. Sinyal İşleme Adımları
% Görüntü işleme algoritmaları kullanılmadan matematiksel ve DSP yöntemleri uygulanır.

disp('2. Sinyal İşleme adımları uygulanıyor...');

% Adım 2.1: De-wow (Merkeze Çekme)
% Amaç: Cihazdan veya anten bağlantısından gelen DC (Doğru Akım) sapmasını ve çok
% düşük frekanslı gürültüleri gidermek.
gpr_dewowed = apply_dewow(gpr_data_3d);

% Adım 2.2: Background Removal (Arka Plan Temizleme)
% Amaç: Tüm izlerde ortak olan, anten kaynaklı yatay çizgilenmeleri 
% ortalama değeri çıkararak silmek.
gpr_bg_removed = apply_background_removal(gpr_dewowed);

% Adım 2.3: Gain (Derinlik Kazancı Uygulaması)
% Amaç: Elektromanyetik dalgalar yer altında ilerledikçe zayıflar. Derin 
% noktalardan gelen zayıf yansımaları güçlendirmek için zamana (derinliğe) bağlı kazanç uygulanır.
% Burada, üstel (exponential) kazanç örneklendirilmiştir.
gpr_gained = apply_gain(gpr_bg_removed, z_axis);

% Adım 2.4: Zarf Çıkarma (Envelope Detection)
% Amaç: Sinyalin pozitif ve negatif salınımları yerine enerjisinin (kalınlığının)
% elde edilmesi (Hilbert Dönüşümü vb. matematiksel yöntemle). 
gpr_envelope = extract_envelope(gpr_gained);

%% 3 ve 4. Malzeme Ayrımı (Thresholding) ve 3 Boyutlu Görselleştirme
disp('3. Eşikleme ve 3 Boyutlu Görselleştirme (Scatter Plot) başlatılıyor...');
visualize_3d_gpr(gpr_envelope, x_axis, y_axis, z_axis);

disp('GPR Analiz işlemi tamamlandı.');
