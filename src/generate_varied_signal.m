function s = generate_varied_signal(sr, duration)
    s_len = round(sr*duration);
    s = zeros(1, s_len)';
    pulse_pos = 1;
    while pulse_pos <= s_len
        s(pulse_pos) = 1;
        m = ceil(pulse_pos/(0.01*sr));
        pulse_pos = pulse_pos+80+5*mod(m, 50);       
    end
end
