function [txsignal, conf] = tx_OFDM_payload_symbol(txbits,conf,k)
%
%   [txsignal conf] = tx_OFDM_payload_symbol(txbits,conf,k) transmits a OFDM
%   payload multicarrier symbol, handling mapping to QPSK (gray mapping),
%   performing inferse fft, adding cyclic prefix and and mixing in
%   frequency domain.
%   
%

payload_symbol = qpsk_modulator(txbits(k: k+conf.nbits-1)); % map payload bits
payload_ofdm_symbol = osifft(payload_symbol, conf.os_factor); % inverse descrete fourier tranform

cp_ofdm_symbol = zeros(1, length(payload_ofdm_symbols)+conf.cp_len);
cyclic_prefix = payload_ofdm_symbol(end-conf.cp_len+1: end);
cp_ofdm_symbol(1:conf.cp_len) = cyclic_prefix; % get cyclic prefix
cp_ofdm_symbol(conf.cp_len+1:end) = payload_ofdm_symbol; % add cyclic prefix to symbol

% Mixing
txsignal = up_conversion(cp_ofdm_symbol, conf.f_c, conf.f_s);


