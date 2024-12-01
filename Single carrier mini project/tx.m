function [txsignal conf] = tx(txbits,conf,k)
% Digital Transmitter
%
%   [txsignal conf] = tx(txbits,conf,k) implements a complete transmitter
%   consisting of:
%       - modulator
%       - pulse shaping filter
%       - up converter
%   in digital domain.
%
%   txbits  : Information bits
%   conf    : Universal configuration structure
%   k       : Frame index
%
preamble = lfsr_framesync(conf.npreamble); % generate preamble of 100 bits (no need to map for bpsk)
preamble_mapped = -2 .* preamble + 1; % bpsk_modulate the preamble

payload_symbols = qpsk_modulator(txbits(k: k+conf.nbits-1)); % map payload bits

txsymbols = [preamble_mapped.', payload_symbols]; % insert preamble sequence

txsymbols_up = upsample(txsymbols, conf.os_factor); % add zeros between symbols

rolloff = 0.22;
tx_filterlen = 20;
pulse = rrc (conf.os_factor, rolloff, tx_filterlen);
filtered_tx_signal = conv(txsymbols_up, pulse, 'valid');

% dummy 400Hz sinus generation
%time = 1:1/conf.f_s:4;
%txsignal = 0.3*sin(2*pi*400 * time.');

txsignal = up_conversion(filtered_tx_signal, conf.f_c, conf.f_s);