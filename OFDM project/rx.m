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

  %  found = 0;
 %   while(found == 0)
        %[start_idx, found] = frame_sync(rxsymbols, conf, frame_detection_threshold);
    %    frame_detection_threshold = frame_detection_threshold - 10;
  %  end
  %  frame_detection_threshold

    start_idx = frame_sync_bea(rxsymbols, conf);

    start_idx
    
    training_symbol = rxsymbols(start_idx: start_idx+conf.symbol_length+conf.cp_len-1 );

    training_symbol_no_cp = training_symbol(conf.cp_len+1 : end);

    payload = rxsymbols(start_idx+conf.symbol_length+conf.cp_len+1 : end);
    payload_no_cp  = remove_cyclic_prefix(payload, 1, conf);
    payload_no_cp = serial_to_parallel(payload_no_cp, conf.symbol_length); % Convert to parallel
    training_symbol_no_cp = serial_to_parallel(training_symbol_no_cp, conf.symbol_length);
    payload_no_cp = osfft(payload_no_cp, conf.os_factor);
    training_symbol_no_cp = osfft(training_symbol_no_cp, conf.os_factor);
    
   % phase_offsets = angle(payload_no_cp ./ training_symbol_no_cp); 
   % phase_corrected_rx_symbols = payload_no_cp .* exp(-1i *phase_offsets);

    payload_eq = channel_equalization(payload_no_cp, training_symbol_no_cp, conf.training_symbol);
    payload_eq = parallel_to_serial(payload_eq);

    constellation = [(1+1j)/sqrt(2), (-1+1j)/sqrt(2), ...
                     (1-1j)/sqrt(2), (-1-1j)/sqrt(2)];
    bit_pairs = [0 0; 0 1; 1 0 ; 1 1];
    
    avg_E = sum(abs(payload_eq).^2)/length(payload_eq);
    normalized_payload =  (1/sqrt(avg_E))*payload_eq;
    
   % rxbits = reshape(demapper_general(normalized_payload, constellation, bit_pairs).', [], 1);
    rxbits = demapper(normalized_payload);

    rxbits = rxbits(1:conf.nbits);