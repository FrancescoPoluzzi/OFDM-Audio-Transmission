function [rxbits ,conf] = rx(rxsignal,conf,k)
    % Digital Receiver
    %
    %   [txsignal conf] = tx(txbits,conf,k) implements a complete causal
    %   receiver in digital domain.
    %
    %   rxsignal    : received signal
    %   conf        : configuration structure
    %   k           : frame index
    %
    %   Outputs
    %
    %   rxbits      : received bits
    %   conf        : configuration structure
    %

    rxsymbols = down_conversion(rxsignal, conf.f_c, conf.f_s);
    rxsymbols = ofdmlowpass(rxsymbols,conf,conf.n_carriers*conf.spacing);

    frame_detection_threshold = 150;

    found = 0;
    while(found == 0)
        [start_idx, ~ , ~, found] = frame_sync(rxsymbols, conf.os_factor, frame_detection_threshold, conf.npreamble);
        frame_detection_threshold = frame_detection_threshold - 10;
    end
    
    training_symbol = rxsymbols(start_idx: start_idx+conf.symbol_length+conf.cp_len-1 );

    training_symbol_no_cp = training_symbol(conf.cp_len+1 : end);

    payload = rxsymbols(start_idx+conf.symbol_length+conf.cp_len : end);
    payload_no_cp  = remove_cyclic_prefix(payload, conf.symbol_length, conf.cp_len, 1);

    payload_no_cp = osfft(payload_no_cp, conf.os_factor);
    training_symbol_no_cp = osfft(training_symbol_no_cp, conf.os_factor);

    phase_offsets = angle(payload_no_cp ./ training_symbol_no_cp); 
    phase_corrected_rx_symbols = payload_no_cp .* exp(-1i *phase_offsets);

   % H_est = rx_symbols ./ training_symbol; // ASK QUESTION

    % Demapping QPSK
    constellation = 1/sqrt(2) * [(-1-1j) (-1+1j) ( 1-1j) ( 1+1j)];
    [~,ind] = min(abs(ones(conf.bitsXsymb/2,4)*diag(constellation) - diag(phase_corrected_rx_symbols)*ones(conf.bitsXsymb/2,4)),[],2);
    rxbits = de2bi(ind-1, 'left-msb',2);
    rxbits = rxbits(:);
    
   % rxbits = reshape(demapper_general(phase_corrected_rx_symbols, constellation, bit_pairs).', [], 1);

    %payload = downsample(filtered_rx_symbols(start_idx:start_idx+conf.nsyms*conf.os_factor-1), conf.os_factor);
    %rxbits = reshape(demapper_general(payload, constellation, bit_pairs).', [], 1);
    
    %rxbits = reshape(demapper_general(timing_corrected_rx_symbols, constellation, bit_pairs).', [], 1);

    % dummy 
    %rxbits = zeros(conf.nbits,1);