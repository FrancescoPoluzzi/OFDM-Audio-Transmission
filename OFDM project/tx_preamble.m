function [txsignal, conf] = tx_preamble(conf,k)
%
%   [txsignal conf] = tx_preamble(txbits,conf,k) transmits the BPSK-mapped
%   (single carrier) preamble for frame synchronization and initial channel estimation.
%   
%
preamble = lfsr_framesync(conf.npreamble); % generate preamble 
preamble_mapped = -2 .* preamble + 1; % bpsk_modulate the preamble

preamble_up = upsample(preamble_mapped, conf.os_factor_preamble); % add zeros between symbols

pulse = rrc (conf.os_factor_preamble, conf.rolloff, conf.tx_filterlen*conf.os_factor_preamble);
filtered_preamble = conv(preamble_up, pulse, 'same');

txsignal = filtered_preamble;
%txsignal = up_conversion(filtered_preamble, conf.f_c, conf.f_s);
