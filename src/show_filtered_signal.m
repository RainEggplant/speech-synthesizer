function show_filtered_signal()
    L = 8000; % ÐÅºÅ³¤¶È
    e = generate_varied_signal(8000, 1);
    s = filter(1, [1, -1.3789, 0.9506], e);
    sound(s/max(abs(s)), 8000);
    
    % »­³ö s(n) ²¨ÐÎ
    figure;
    plot(s);
    
    % »­³ö e(n), s(n) ÆµÆ×
    E = fft(e);
    S = fft(s);
    freq = 0:4000;
    
    figure;
    subplot(2, 1, 1);
    plot(freq, abs(S(1:L/2+1)));
    ylabel('s(n) ÆµÆ×');
    
    subplot(2, 1, 2);
    plot(freq, abs(E(1:L/2+1)));
    ylabel('e(n) ÆµÆ×');
end
