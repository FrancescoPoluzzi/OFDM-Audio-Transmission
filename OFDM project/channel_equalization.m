function eq_symbols = channel_equalization(rx_symbols, training_symbol)
    % Estimate the channel frequency response
    H_est = rx_symbols ./ training_symbol;
    
    % Equalize the received data symbols
    eq_symbols = rx_symbols ./ H_est;
end