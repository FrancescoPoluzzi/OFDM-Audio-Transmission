function plot_signal_spectrum(txsignal, rxsignal, conf)
    % This function plots the spectrum of the transmitted signal.
    % txsignal: The transmitted signal (time-domain signal)
    % conf.f_s: The sampling frequency
    % conf.f_c: The carrier frequency (for optional shifting)

    % Perform FFT on the transmitted signal
    TXSIGNAL = fftshift(fft(txsignal));
    RXSIGNAL = fftshift(fft(rxsignal));

    % Generate the frequency range for plotting
    N = length(txsignal);
    f_range = linspace(-conf.f_s / 2, conf.f_s / 2, N);

    % Calculate magnitude of the spectrum
    magnitude_spectrum = abs(TXSIGNAL);

    % Plot the magnitude of the spectrum
    figure;
    plot(f_range, magnitude_spectrum, 'b');
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    title('Spectrum of Transmitted Signal');
    grid on;

    % Set sensible axis limits
    % Focus frequency axis around the carrier frequency ± bandwidth
    magnitude_threshold = max(magnitude_spectrum) * 0.01; % Threshold to focus on significant magnitudes
    significant_indices = find(magnitude_spectrum > magnitude_threshold);
    
    % Frequency limits (around significant frequencies)
    f_min = f_range(min(significant_indices));
    f_max = f_range(max(significant_indices));
    xlim([f_min, f_max]);

    % Magnitude limits
    ylim([0, max(magnitude_spectrum) * 1.1]); % Leave 10% padding above max magnitude



    % Generate the frequency range for plotting
    N = length(rxsignal);
    f_range = linspace(-conf.f_s / 2, conf.f_s / 2, N);

    % Calculate magnitude of the spectrum
    magnitude_spectrum = abs(RXSIGNAL);

    % Plot the magnitude of the spectrum
    figure;
    plot(f_range, magnitude_spectrum, 'b');
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    title('Spectrum of Transmitted Signal');
    grid on;

    % Set sensible axis limits
    % Focus frequency axis around the carrier frequency ± bandwidth
    magnitude_threshold = max(magnitude_spectrum) * 0.01; % Threshold to focus on significant magnitudes
    significant_indices = find(magnitude_spectrum > magnitude_threshold);
    
    % Frequency limits (around significant frequencies)
    f_min = f_range(min(significant_indices));
    f_max = f_range(max(significant_indices));
    xlim([f_min, f_max]);

    % Magnitude limits
    ylim([0, max(magnitude_spectrum) * 1.1]); % Leave 10% padding above max magnitude

    
end
