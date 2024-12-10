function [] = plots(payload, training_symbols, N, h, num_frames)
    % N - OFDM symbol length

    % channel spectrum evaluation
    figure;
    plot(abs(h)); % channel spectrum
    xlabel('Subcarrier Index');
    ylabel('Magnitude');
    title('Channel Frequency Response');
    grid on;

    % delay spread - time dispersion of the received signal due to
    % multipath propagation
    % Calculated from Channel Impulse Response - how the channel disperses
    % over time
    
    figure;
    CIR = ifft(h,N);
    plot(abs(CIR));
    xlabel('Sample Index (Time)');
    ylabel('Magnitude');
    title('Channel Impulse Response (CIR)');
    grid on;
     % Estimate delay spread (time dispersion)
    % Typically, delay spread is defined as the time between the first and last significant taps
    significant_taps = find(abs(CIR) > 0.1 * max(abs(CIR)));
    delay_spread = significant_taps(end) - significant_taps(1); % In samples
    disp(['Estimated Delay Spread: ', num2str(delay_spread), ' samples']);

    % Channel evolution over time 
    figure;
    imagesc(abs(h));  % Plot magnitude of channel evolution
    xlabel('Subcarrier Index');
    ylabel('Time Frame Index');
    title('Channel Evolution Over Time');
    colorbar;
    grid on;


end
