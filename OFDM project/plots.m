function [] = plots(conf, h)

    N = conf.symbol_length; % OFDM symbol length
    Ts = 1/conf.spacing;    % Time to send a sample of an OFDM symbol
    time = 0 : Ts : (conf.n_payload_symbols + 1 - 1) * Ts; % Time vector

    % Channel Spectrum Evaluation (Frequency Domain)
    figure;
    plot(abs(h)); % channel spectrum
    xlabel('Subcarrier Index');
    ylabel('Magnitude');
    title('Channel Frequency Response');
    grid on;
    % Channel Spectrum Evaluation Over Time (Magnitude)
    figure;
    for i = 1 : 32 : conf.n_carriers % Iterate over selected subcarriers
        magnitude_dB = 20 * log10(abs(h(i, :)) ./ max(abs(h(i, :))));
        plot(time, magnitude_dB);
        hold on;
    end
    xlabel('Time (s)');
    ylabel('Magnitude (dB)');
    title('Channel Magnitude Evolution Over Time');
    %legend(arrayfun(@(x) ['Subcarrier ', num2str(x)], 1:32:conf.n_carriers, 'UniformOutput', false));
    grid on;

    % Channel Spectrum Evaluation Over Time (Phase)
    figure;
    for i = 1 : 32 : conf.n_carriers
        if any(abs(h(i, :)) > 1e-10) % Check for significant magnitude
            phase = unwrap(angle(h(i, :)));
            plot(time, phase);
            hold on;
        end
    end
    xlabel('Time (s)');
    ylabel('Phase (radians)');
    title('Channel Phase Evolution Over Time');
    %legend(arrayfun(@(x) ['Subcarrier ', num2str(x)], 1:32:conf.n_carriers, 'UniformOutput', false));
    grid on;

    % Channel Impulse Response (CIR)
    figure;
    CIR = ifft(h, N, 2); % Compute CIR using IFFT
    plot(abs(CIR));
    xlabel('Sample Index (Time)');
    ylabel('Magnitude');
    title('Channel Impulse Response (CIR)');
    grid on;

    % Estimate Delay Spread
    significant_taps = find(abs(CIR) > 0.1 * max(abs(CIR), [], 'all'));
    delay_spread = significant_taps(end) - significant_taps(1); % In samples
    disp(['Estimated Delay Spread: ', num2str(delay_spread), ' samples']);

    % Channel Evolution Over Time (Heatmap)
    figure;
    imagesc(abs(h)); % Plot magnitude of channel evolution
    xlabel('Subcarrier Index');
    ylabel('Time Frame Index');
    title('Channel Magnitude Evolution Over Time');
    colorbar;
    grid on;

    % Efficiency Calculations
    T_CP = conf.cp_len;          % Current CP length
    T_CP_new = delay_spread;        % Reduced CP length (based on delay spread)
    T_useful = conf.symbol_length;  % Useful symbol duration

    current_efficiency = T_useful / (T_useful + T_CP);
    new_efficiency = T_useful / (T_useful + T_CP_new);
    efficiency_increase = new_efficiency - current_efficiency;

    disp(['Current Efficiency: ', num2str(current_efficiency * 100), '%']);
    disp(['New Efficiency: ', num2str(new_efficiency * 100), '%']);
    disp(['Efficiency Increase: ', num2str(efficiency_increase * 100), '%']);

end
