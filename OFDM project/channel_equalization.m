function [H_est,eq_symbols] = channel_equalization(rx_payload, rx_training, training_symbol)
    % Estimate the channel frequency response
    H_est = rx_training ./ training_symbol;
    
    % Equalize the received data symbols
    eq_symbols = rx_payload ./ H_est;
end