function [] = plots(conf, h)
    % N - OFDM symbol length

    % channel spectrum evaluation in time domain
    % channel response evolves over time for a 
    % specific subcarrier or set of subcarriers
    N = conf.symbol_length;
    figure;
    plot(abs(h)); % channel spectrum
    xlabel('Subcarrier Index');
    ylabel('Magnitude');
    title('Channel Frequency Response');
    grid on;
    % channel spectrum evaluation in frequency domain
    % the channel response varies across subcarriers
    Ts = 1/conf.spacing;  % Time to send a sample of an OFDM symbol; 
    time = 0 : Ts : (conf.n_payload_symbols + 1 - 1) * Ts;
    for i = 1 : 32 : conf.n_carriers % define the nb subcarriers!!
        plot(time, 20*log10(abs(h(i, :))./ max(abs(h(i, :))) ));
        hold on;
        f = conf.spacing * i;
    end
    xlabel('Time, s');
    ylabel('Magnitude, dB')
    title('Channel Magnitude over Time');
    grid on;
    for i = 1 : 32 : conf.n_carriers
        plot(time, unwrap(angle(h(i, :))));
        hold on;
        f = conf.spacing * i;
    end
    for i = 1 : 32 : conf.n_carriers
    % Check if there's variation in the phase
    if any(abs(h(i, :)) > 1e-10)  % Check for significant magnitude
        phase = unwrap(angle(h(i, :)));
        plot(time, phase);
        hold on;
    else
        disp(['Subcarrier ', num2str(i), ' has no significant channel response.']);
    end
    end
    xlabel('Time, s');
    ylabel('Phase, rad')
    title('Channel Phase over Time');
    grid on;
    
    % delay spread - time dispersion of the received signal due to
    % multipath propagation
    % Calculated from Channel Impulse Response - how the channel disperses
    % over time
  
    figure;
    CIR = ifft(h,N,2);
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
