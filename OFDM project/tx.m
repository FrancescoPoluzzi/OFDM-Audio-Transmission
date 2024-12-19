function [txsignal, conf] = tx(txbits, conf, k)

preamble = lfsr_framesync(conf.npreamble); % generate preamble 
preamble_mapped = -2 .* preamble + 1; % bpsk_modulate the preamble

preamble_up = upsample(preamble_mapped, conf.os_factor_preamble); % add zeros between symbols

pulse = rrc (conf.os_factor_preamble, conf.rolloff, conf.tx_filterlen*conf.os_factor_preamble);
filtered_preamble = conv(preamble_up, pulse, 'same');

txbits = reshape(txbits, [2, length(txbits)/2]).';
payload_symbols = QPSK_GrayMap(txbits); % map payload bits

tx_symbols = add_training(payload_symbols, conf);

tx_symbols_parallel = serial_to_parallel(tx_symbols, conf);

ofdm_symbol_parallel = zeros(conf.symbol_length, conf.n_payload_symbols+1);
for i =  1 : conf.n_payload_symbols+conf.n_training_symbols
    ofdm_symbol_parallel(:,i) = osifft(tx_symbols_parallel(:,i), conf.os_factor);
end

% For every OFDM symbol take the last n CP samples and add them to
% the CP colummn.
cp_ofdm_symbol_parallel = zeros(conf.cp_len + conf.symbol_length, conf.n_payload_symbols+conf.n_training_symbols);
for i = 1: conf.n_payload_symbols+conf.n_training_symbols
    cyclic_prefix = ofdm_symbol_parallel(end-conf.cp_len+1:end, i);
    cp_ofdm_symbol_parallel(:,i) = [cyclic_prefix; ofdm_symbol_parallel(:,i)];
end

txsignal =[filtered_preamble; parallel_to_serial(cp_ofdm_symbol_parallel)] ;

end

