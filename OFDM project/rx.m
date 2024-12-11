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
    f_cutoff = conf.BW_BB + 0.05 * conf.BW_BB;      % Define the filter cutoff as 5% above the baseband BW
    rxsymbols = ofdmlowpass(rxsymbols,conf,f_cutoff);

    frame_detection_threshold = 150;

    found = 0;
    while(found == 0)
        [start_idx, found] = frame_sync(rxsymbols, conf, frame_detection_threshold);
        frame_detection_threshold = frame_detection_threshold - 10;
    end
    frame_detection_threshold
    start_idx
    
    training_symbol = rxsymbols(start_idx: start_idx+conf.symbol_length+conf.cp_len-1 );

    training_symbol_no_cp = training_symbol(conf.cp_len+1 : end);

    payload = rxsymbols(start_idx+conf.symbol_length+conf.cp_len : end);
    payload_no_cp  = remove_cyclic_prefix(payload, conf.symbol_length, conf.cp_len, 1);

    payload_no_cp = osfft(payload_no_cp, conf.os_factor);
    training_symbol_no_cp = osfft(training_symbol_no_cp, conf.os_factor);

   % phase_offsets = angle(payload_no_cp ./ training_symbol_no_cp); 
   % phase_corrected_rx_symbols = payload_no_cp .* exp(-1i *phase_offsets);

    payload_eq = channel_equalization(payload_no_cp, training_symbol_no_cp, conf.training_symbol);

    constellation = [(1+1j)/sqrt(2), (-1+1j)/sqrt(2), ...
                     (1-1j)/sqrt(2), (-1-1j)/sqrt(2)];
    bit_pairs = [0 0; 0 1; 1 0 ; 1 1];
    
    rxbits = reshape(demapper_general(training_symbol_no_cp, constellation, bit_pairs).', [], 1);
