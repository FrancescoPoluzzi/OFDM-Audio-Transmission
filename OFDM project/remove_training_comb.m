function payloadsymbols = remove_training_comb(serial_data, conf)
% REMOVE_TRAINING_COMB removes comb-type training carriers from the serial data.
%
% serial_data: A column vector of length conf.n_carriers*conf.n_payload_symbols
%              containing both payload and training carriers arranged in a comb pattern.
%
% conf: Configuration structure containing:
%   - n_carriers : Number of carriers per MC symbol
%   - n_payload_symbols : Number of MC payload symbols
%   - n_trainings_per_symbol : Number of training carriers inserted per MC symbol
%   - comb_training_interval : Interval at which training carriers are inserted
%   - training_type = 'Comb'
%
% After removing the training carriers, the resulting payload will have
% (conf.n_carriers - conf.n_trainings_per_symbol)*conf.n_payload_symbols samples.

    % Reshape serial data into (n_carriers x n_payload_symbols)
    rxsymbols = reshape(serial_data, conf.n_carriers, conf.n_payload_symbols);

    % Initialize the output payload:
    % Each symbol originally had (conf.n_carriers - conf.n_trainings_per_symbol) payload carriers.
    payloadsymbols = zeros((conf.n_carriers - conf.n_trainings_per_symbol)*conf.n_payload_symbols, 1);

    payload_pos = 1; % index to fill into payloadsymbols
    for i = 1:conf.n_payload_symbols
        % Determine training positions for this MC symbol
        first_training_position = mod(i-1, conf.comb_training_interval) + 1; % Ensure valid MATLAB index
        training_positions = first_training_position : conf.comb_training_interval : conf.n_carriers;
        training_positions = training_positions(1:conf.n_trainings_per_symbol);

        % Identify the non-training positions
        all_positions = 1:conf.n_carriers;
        non_training_positions = setdiff(all_positions, training_positions);

        % Extract only the payload carriers (non-training) for this symbol
        payload_carriers = rxsymbols(non_training_positions, i);

        % Place them into the output vector
        payloadsymbols(payload_pos:payload_pos+length(payload_carriers)-1) = payload_carriers;
        payload_pos = payload_pos + length(payload_carriers);
    end
end
