function s = generate_signal(sr, freq, duration)
    sample_per_cycle = sr/freq;
    NS = round(freq*duration);
    s = zeros(1, round(sr*duration))';
    
    for k = 0:NS-1
        s(round(sample_per_cycle*k)+1) = 1;
    end
end