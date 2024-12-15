function [rxbits ,conf, h] = rx(rxsignal,conf, k)
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
    rxsymbols_filtered = ofdmlowpass(rxsymbols,conf,f_cutoff);

    start_idx = frame_sync(rxsymbols_filtered, conf);

    rxsignal_no_cp  = remove_cyclic_prefix(rxsymbols_filtered, start_idx, conf);
    rxsignal_no_cp_parallel = serial_to_parallel_rx(rxsignal_no_cp, conf); % Convert to parallel

    rxsymbols_no_cp = zeros(conf.n_carriers, conf.n_payload_symbols+1);
    for i = 1: (conf.n_payload_symbols+1)
         rxsymbols_no_cp(:,i) = osfft(rxsignal_no_cp_parallel(:,i), conf.os_factor);
    end

    rx_training = rxsymbols_no_cp(:,1);

    rx_payload = rxsymbols_no_cp(:,2:end);
    switch conf.tracking_method
    case 'Block'
        % Perform block tracking
        [h, payload_eq] = channel_equalization(rx_payload, rx_training, conf.training_symbol);

    case 'Block_Viterbi'
        % Perform block Viterbi tracking
        [h, payload_eq] = block_viterbi_tracking(rx_payload, rx_training, conf.training_symbol);

    otherwise
        error('Unknown tracking method specified in conf.tracking_method.');
    end

    %[ h, payload_eq ] = channel_equalization(rx_payload, rx_training, conf.training_symbol);
    payload_eq = parallel_to_serial(payload_eq);

    avg_E = sum(abs(payload_eq).^2)/length(payload_eq);
    normalized_payload =  (1/sqrt(avg_E))*payload_eq;
    
    rxbits_demapped = demapper(normalized_payload);

    rxbits = rxbits_demapped(1:conf.bitsperframe);