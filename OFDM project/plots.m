function [] = plots(payload, training_symbols, N, h, num_frames)
    % N - OFDM symbol length

    % channel spectrum evaluation in time domain
    % channel response evolves over time for a 
    % specific subcarrier or set of subcarriers
    figure
    subplot(2,1,1);
    plot(abs(h)); % channel spectrum
    xlabel('Subcarrier Index');
    ylabel('Magnitude');
    title('Channel Frequency Response');
    grid on;
    % channel spectrum evaluation in frequency domain
    % the channel response varies across subcarriers
    Ts = 1/conf.spacing;  % Time to send a sample of an OFDM symbol; 
    time = 0 : Ts : (conf.OFDM_symbs_per_frame + conf.nb_training_symbs - 1) * Ts;
    figure
    for i = 1 : 32 : conf.nb_subcarriers % define the nb subcarriers!!
        plot(time, 20*log10(abs(h(i, :))./ max(abs(h(i, :))) ));
        hold on;
        f = conf.spacing * i;
    end
    xlabel('Time, s');
    ylabel('Magnitude, dB')
    title('Channel Magnitude over Time');
    grid on;
    subplot(2,1,2);
    for i = 1 : 32 : conf.nb_subcarriers
        plot(time, unwrap(angle(h(i, :))));
        hold on;
        f = conf.spacing * i;
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
