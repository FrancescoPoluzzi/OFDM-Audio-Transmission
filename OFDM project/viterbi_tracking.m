function [eq_symbols, hat_matrix] = viterbi_tracking(rx_symbols, training_symbol, conf)
    % Viterbi Tracking and Training-Based Equalization
    %
    % Inputs:
    %   rx_symbols        : Received OFDM symbols (matrix: subcarriers x symbols)
    %   training_symbol   : Known training symbol (vector: subcarriers x 1)
    %   conf              : Configuration structure 
    % Outputs:
    %   eq_symbols : Equalized payload symbols (matrix: subcarriers x symbols)
    %   hat_matrix      : Estimated phase shifts (matrix: subcarriers x symbols)

    % Constants
    shift = zeros(conf.n_carriers, 6) + pi/2 * (-1:4); % Phase shift matrix
    
    training_rx = training_symbol;

    % Initialize phase estimation matrix
    hat_matrix = zeros(conf.n_carriers, conf.block_interval+1);

    % Initialize output matrix for equalized symbols
    eq_symbols = zeros(conf.n_carriers, conf.block_interval);

    % Estimate the channel using the training symbol
    H_hat = training_rx ./ conf.training_symbol;

    % Store the phase shift from the training symbol
    hat_matrix(:,1) = mod(angle(H_hat), 2 * pi);


    % Process subsequent payload symbols until the next training symbol
    for j = 1 : conf.block_interval
        % Retrieve the previous phase shift
        theta_hat_prev = hat_matrix(:, j);

        % Estimate the current phase shift
        theta_hat = (1 / 4) * angle(-(rx_symbols(:, j).^4));

      % Shift the estimated phase to align with the previous one
        theta_hat_shifted = shift + theta_hat; % (n_carriers x 6)
        theta_hat_prev_matrix = repmat(theta_hat_prev, 1, 6); % (n_carriers x 6)
    
        % Select the closest phase shift for each subcarrier
        [~, idx] = min(abs(theta_hat_shifted - theta_hat_prev_matrix), [], 2); % (n_carriers x 1)
        
        % Correct theta_hat by selecting the closest shifted phase
        % Vectorized approach replaces the for-loop
        theta_hat_correct = theta_hat_shifted(sub2ind(size(theta_hat_shifted), (1:conf.n_carriers)', idx));
        % theta_hat_correct is now a (n_carriers x 1) vector
        
        % Smooth the phase estimate and store it
        hat_matrix(:, j+1) = mod(0.5 * theta_hat_correct + 0.5 * theta_hat_prev, 2 * pi);

        % Equalize the payload symbol
        eq_symbols(:, j) = rx_symbols(:, j) .* exp(-1i * hat_matrix(:, j+1)) ./ abs(H_hat);
    end
    
end
