function plot_filter(b, a)
    % Plot zeros and polars
    figure;
    zplane(b, a);

    % Plot frequency response
    figure;
    freqz(b, a, 2048);
    % Find maximum and mark it
    h_line = findobj(gca, 'Type', 'line');
    h = get(h_line, 'Ydata');
    [h_max, idx] = max(h(1:length(h)-1));
    w = get(h_line,'Xdata');
    w_max = w(idx);
    text(w_max-0.05, h_max + 4, ...
        ['(', num2str(w_max), ',', num2str(h_max), ')']);

    % Use `impz` to draw impulse response
    figure;
    subplot(2, 1, 1);
    impz(b, a, 100);
    title('Impulse Response (using `impz`)');

    % Use `filter` to draw impulse response
    x = zeros(1,100);
    x(1) = 1;
    y = filter(b, a, x);
    subplot(2, 1, 2);
    stem([1:100], y);
    title('Impulse Response (using `filter`)');
    xlabel('n (samples)');
    ylabel('Amplitude');
end