function plot_signal_spectrum(txsignal, conf)
    % This function plots the spectrum of the transmitted signal.
    % txsignal: The transmitted signal (time-domain signal)
    % conf.f_s: The sampling frequency
    % conf.f_c: The carrier frequency (for optional shifting)

    % Perform FFT on the transmitted signal
    TXSIGNAL = fftshift(fft(txsignal));

    % Generate the frequency range for plotting
    f_range = - conf.f_s / 2 : conf.f_s / length(txsignal) : conf.f_s / 2 - conf.f_s / length(txsignal);

    % Plot the magnitude of the spectrum
    figure;
    plot(f_range, abs(TXSIGNAL), 'b');
    xlabel('Frequency (Hz)');
    ylabel('Magnitude');
    title('Spectrum of Transmitted Signal');
    grid on;
end