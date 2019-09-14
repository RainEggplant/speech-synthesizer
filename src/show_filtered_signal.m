% 绘制经滤波器作用后的信号波形与频谱
function show_filtered_signal()
    L = 8000; % 信号长度
    e = generate_varied_signal(8000, 1);
    s = filter(1, [1, -1.3789, 0.9506], e);
    sound(s/max(abs(s)), 8000);
    
    % 画出 s(n) 波形
    figure;
    plot(s);
    
    % 画出 e(n), s(n) 频谱
    E = fft(e);
    S = fft(s);
    freq = 0:4000;
    
    figure;
    subplot(2, 1, 1);
    plot(freq, abs(S(1:L/2+1)));
    ylabel('s(n) 频谱');
    
    subplot(2, 1, 2);
    plot(freq, abs(E(1:L/2+1)));
    ylabel('e(n) 频谱');
end
