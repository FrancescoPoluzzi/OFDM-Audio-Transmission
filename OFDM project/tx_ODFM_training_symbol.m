function [txsignal, conf] = tx_OFDM_training_symbol(txbits,conf,k)
% Digital Transmitter
%
%   [txsignal conf] = tx_OFDM_training_symbol(txbits,conf,k) transmit a OFDM
%   training multicarrier symbol, handling mapping to BPSK,
%   performing inferse fft, adding cyclic prefix and and mixing in
%   frequency domain. We'll need to map 
%   
%

training_symbol =-1 + 2*txbits; % map training bits to BPSK
training_ofdm_symbol = osifft(training_symbol, conf.os_factor); % inverse descrete fourier tranform

cp_ofdm_symbol = zeros(1, length(training_ofdm_symbol)+conf.cp_len);
cyclic_prefix = training_ofdm_symbol(end-conf.cp_len+1: end);
cp_ofdm_symbol(1:conf.cp_len) = cyclic_prefix; % get cyclic prefix
cp_ofdm_symbol(conf.cp_len+1:end) = training_ofdm_symbol; % add cyclic prefix to symbol

% Mixing
txsignal = up_conversion(cp_ofdm_symbol, conf.f_c, conf.f_s);

