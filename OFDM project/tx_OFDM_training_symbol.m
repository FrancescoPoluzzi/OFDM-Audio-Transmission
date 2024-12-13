function [txsignal, conf] = tx_OFDM_training_symbol(conf,k)
% Digital Transmitter
%
%   [txsignal conf] = tx_OFDM_training_symbol(txbits,conf,k) transmit a OFDM
%   training multicarrier symbol, handling mapping to BPSK,
%   performing inferse fft, adding cyclic prefix and and mixing in
%   frequency domain. We'll need to map 
%   
%

%n_singlecarries_syms = conf.n_carriers;
%padding_len = conf.n_carriers;
%OFDM_frame_vec = [conf.training_symbol ; zeros(padding_len, 1)];
%OFDM_frame = reshape(OFDM_frame_vec, [conf.nb_subcarriers, n_singlecarries_syms]);
% Serial-to-Parallel Conversion
parallel_bits = serial_to_parallel(conf.training_symbol, conf.n_carriers);
training_ofdm_symbol = osifft(parallel_bits, conf.os_factor); % inverse descrete fourier tranform

cp_ofdm_symbol = zeros(1, length(training_ofdm_symbol)+conf.cp_len);
cyclic_prefix = training_ofdm_symbol(end-conf.cp_len+1: end);
cp_ofdm_symbol(1:conf.cp_len) = cyclic_prefix; % get cyclic prefix
cp_ofdm_symbol(conf.cp_len+1:end) = training_ofdm_symbol; % add cyclic prefix to symbol

% Mixing
%txsignal = up_conversion(cp_ofdm_symbol, conf.f_c, conf.f_s);
%txsignal = cp_ofdm_symbol.';
txsignal = parallel_to_serial(cp_ofdm_symbol);
