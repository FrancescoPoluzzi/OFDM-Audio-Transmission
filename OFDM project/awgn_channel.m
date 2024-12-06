function [noisy_signal] = awgn_channel(signal, SNR)
% add AWGN gaussian noise to the signal and outputs the noisy signal.

    % Convert SNR from dB to linear
    SNRlin = 10 .^ (SNR/10);

    signal_power = mean(abs(signal).^2);

    noise_power = signal_power / SNRlin;
    
    awgn_real = randn(size(signal)) * sqrt(noise_power/2); % noise power is the variance for a zero-mean gaussian distribution
    awgn_imag = randn(size(signal)) * sqrt(noise_power/2);
    awgn = awgn_real + 1j * awgn_imag;

    % Add AWGN
    noisy_signal = signal + awgn;
    
end
