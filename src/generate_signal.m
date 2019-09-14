% 生成基音周期固定的单位样值串
% sr: 采样率
% freq: 基音频率
% duration: 信号时长
function s = generate_signal(sr, freq, duration)
    sample_per_cycle = sr/freq;
    NS = round(freq*duration);
    s = zeros(1, round(sr*duration))';
    
    for k = 0:NS-1
        s(round(sample_per_cycle*k)+1) = 1;
    end
end