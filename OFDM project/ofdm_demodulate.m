function freq_symbols = ofdm_demodulate(rx_symbols, N)
    % Perform FFT on the received OFDM symbol to transform recevied signal
    % from time to frequency domain
    freq_symbols = fft(rx_symbols, N); 
end