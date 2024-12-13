function rx_symbols_no_cp = remove_cyclic_prefix(rx_signal, start_idx, conf)
    % Remove CP from a series of OFDM symbols
    % rx_signal : Received time-domain signal (multiple OFDM symbols)
    % N          : OFDM symbol length
    % Ncp        : Cyclic prefix length
    % start_idx  : Start index of the first OFDM symbol

    num_symbols = conf.n_payload_symbols+1;
    rx_symbols_no_cp = zeros(num_symbols*conf.symbol_length, 1);

    for i = 1:num_symbols
        % Start and end index of the symbol without CP
        symbol_start = start_idx + conf.cp_len + (i-1) * (conf.symbol_length + conf.cp_len);
        symbol_end = symbol_start + conf.symbol_length - 1;
        start_out_idx = (i-1)*conf.symbol_length + 1;
        end_out_idx = i*conf.symbol_length;

        rx_symbols_no_cp(start_out_idx:end_out_idx) = rx_signal(symbol_start:symbol_end);
    end
end