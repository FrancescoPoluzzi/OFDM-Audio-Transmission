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
    nb_tot_symbs = conf.n_payload_symbols + 1; % Total symbols (training + payload)

    % Initialize phase estimation matrix
    hat_matrix = zeros(conf.n_carriers, nb_tot_symbs);

    % Initialize output matrix for equalized symbols
    eq_symbols = zeros(conf.n_carriers, nb_tot_symbs);
    nb_symbs_between_training = 2; % We set it??
    % Loop over each set of training + payload symbols
    for i = 1:nb_symbs_between_training + 1:nb_tot_symbs

        % Extract the training symbol from the received symbols
        training_rx = rx_symbols(:, i);

        % Estimate the channel using the training symbol
        H_hat = training_rx ./ training_symbol;

        % Store the phase shift from the training symbol
        hat_matrix(:, i) = mod(angle(H_hat), 2 * pi);

        % Equalize the training symbol
        eq_symbols(:, i) = training_rx .* exp(-1i * hat_matrix(:, i)) ./ abs(H_hat);

        % Process subsequent payload symbols until the next training symbol
        for j = i + 1 : min(i + conf.nb_symbs_between_training, nb_tot_symbs)
            % Retrieve the previous phase shift
            theta_hat_prev = hat_matrix(:, j - 1);

            % Estimate the current phase shift
            theta_hat = (1 / 4) * angle(-(rx_symbols(:, j).^4));

            % Shift the estimated phase to align with the previous one
            theta_hat_shifted = shift + theta_hat;
            theta_hat_prev_matrix = repmat(theta_hat_prev, 1, 6);

            % Select the closest phase shift for each subcarrier
            [~, idx] = min(abs(theta_hat_shifted - theta_hat_prev_matrix), [], 2);
            for k = 1:conf.n_carriers
                theta_hat_correct(k,1) = theta_hat_shifted(k, idx(k));
            end
            % Smooth the phase estimate and store it
            hat_matrix(:, j) = mod(0.01 * theta_hat_correct + 0.99 * theta_hat_prev, 2 * pi);

            % Equalize the payload symbol
            eq_symbols(:, j) = rx_symbols(:, j) .* exp(-1i * hat_matrix(:, j)) ./ abs(H_hat);
        end
    end
end
