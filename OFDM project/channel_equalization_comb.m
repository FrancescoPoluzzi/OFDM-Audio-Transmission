function eqsymbols = channel_equalization_comb(rxsymbols, conf)
% CHANNEL_EQUALIZATION_COMB Equalize channel using comb-type training.
%
%   rxsymbols is an (N_carriers x N_symbols) matrix of received multi-carrier symbols
%   after CP removal and frequency shift correction.
%   conf.training_symbol is a (N_carriers x 1) vector containing the known 
%   training values for each subcarrier.
%
%   The comb training pattern inserts training symbols at intervals of
%   conf.comb_training_interval carriers, shifting the starting position by one
%   for each subsequent symbol.
%
%   This function:
%   1) For each column (MC symbol), determine which carriers are training carriers.
%   2) Estimate the channel on those carriers: h = rx_training / training_symbol.
%   3) Use this h to equalize all subsequent symbols for those carriers.

    % Copy input for output
    eqsymbols = rxsymbols;

    % Number of carriers and symbols
    [N_carriers, N_symbols] = size(rxsymbols);

    % Iterate over each MC symbol (column)
    for i = 1:N_symbols
        % Identify the training positions for this symbol
        first_training_position = mod(i-1, conf.comb_training_interval) + 1; % Ensure valid MATLAB index
        training_positions = first_training_position : conf.comb_training_interval : N_carriers;
        training_positions = training_positions(1:conf.n_trainings_per_symbol);

        % Extract the received training carriers
        rx_training_carriers = eqsymbols(training_positions, i);

        % Known training reference for these carriers
        ref_training_carriers = conf.training_symbol(training_positions);

        % Estimate the channel for these carriers
        h_est = rx_training_carriers ./ ref_training_carriers;

        % Now equalize these carriers for this symbol and all subsequent symbols
        % Division by h_est will remove the channel effect from those carriers.
        eqsymbols(training_positions, i:end) = eqsymbols(training_positions, i:end) ./ h_est;
    end
end
