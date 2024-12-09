function rx_symbols_no_cp = remove_cyclic_prefix_payload(rx_signal, N, Ncp, start_idx)
    % Remove CP from a series of OFDM symbols
    % rx_signal : Received time-domain signal (multiple OFDM symbols)
    % N          : OFDM symbol length
    % Ncp        : Cyclic prefix length
    % start_idx  : Start index of the first OFDM symbol

    num_symbols = floor(length(rx_signal(start_idx:end)) / (N + Ncp));
    rx_symbols_no_cp = zeros(num_symbols, N);

    for i = 1:num_symbols
        % Start and end index of the symbol without CP
        symbol_start = start_idx + (i-1) * (N + Ncp) + Ncp;
        symbol_end = symbol_start + N - 1;

        rx_symbols_no_cp(i, :) = rx_signal(symbol_start:symbol_end);
    end
end