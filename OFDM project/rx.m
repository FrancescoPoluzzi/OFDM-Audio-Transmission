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
    for i = 1: (conf.n_payload_symbols+conf.n_training_symbols)
         rxsymbols_no_cp(:,i) = osfft(rxsignal_no_cp_parallel(:,i), conf.os_factor);
    end

    switch conf.tracking_method
    case 'Block'
        % Perform block tracking and remove training sequences
        % The total number of payload symbols is conf.n_payload_symbols,
        % arranged in conf.n_training_symbols blocks each containing conf.block_interval symbols.
        payload_eq = zeros(conf.n_carriers, conf.n_payload_symbols);
        for i = 1:conf.n_training_symbols
            training_col = 1 + (i-1)*(conf.block_interval+1);
            rx_training = rxsymbols_no_cp(:, training_col);
            payload_start_col = training_col + 1;
            payload_end_col   = training_col + conf.block_interval;
            rx_payload = rxsymbols_no_cp(:, payload_start_col:payload_end_col);
            [h, eq_payload_block] = channel_equalization(rx_payload, rx_training, conf.training_symbol);
            payload_eq(:, (i-1)*conf.block_interval + 1 : i*conf.block_interval) = eq_payload_block;
        end

    case 'Block_Viterbi'
        % Perform block tracking and remove training sequences
        % The total number of payload symbols is conf.n_payload_symbols,
        % arranged in conf.n_training_symbols blocks each containing conf.block_interval symbols.
        payload_eq = zeros(conf.n_carriers, conf.n_payload_symbols);
        h = zeros (conf.n_carriers, conf.n_payload_symbols+conf.n_training_symbols);
        for i = 1:conf.n_training_symbols
            training_col = 1 + (i-1)*(conf.block_interval+1);
            rx_training = rxsymbols_no_cp(:, training_col);
            payload_start_col = training_col + 1;
            payload_end_col   = training_col + conf.block_interval;
            rx_payload = rxsymbols_no_cp(:, payload_start_col:payload_end_col);
            [eq_payload_block, h(:,training_col:payload_end_col)] = viterbi_tracking(rx_payload, rx_training, conf);
            payload_eq(:, (i-1)*conf.block_interval + 1 : i*conf.block_interval) = eq_payload_block;
        end

    case  'Comb'
         % also in the Comb case, a pilot symbol is sent at the beginning
         % of the frame
         training_rx = rxsymbols_no_cp(:,1);
         payload_rx = rxsymbols_no_cp(:,2:end);
          [h, payload_eq_pilot] = channel_equalization(payload_rx, training_rx, conf.training_symbol);
         payload_eq = channel_equalization_comb (payload_eq_pilot, conf);

    otherwise
        error('Unknown tracking method specified in conf.tracking_method.');
    end

    %[ h, payload_eq ] = channel_equalization(rx_payload, rx_training, conf.training_symbol);
    payload_eq_serial = parallel_to_serial(payload_eq);

    if strcmp(conf.tracking_method,'Comb')
        payload_eq_serial = remove_training_comb(payload_eq_serial, conf);
    end

    avg_E = sum(abs(payload_eq_serial).^2)/length(payload_eq_serial);
    normalized_payload =  (1/sqrt(avg_E))*payload_eq_serial;
    
    rxbits_demapped = demapper(normalized_payload);

    rxbits = rxbits_demapped(1:conf.bitsperframe);