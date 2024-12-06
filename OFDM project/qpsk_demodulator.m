function bit_sequence = qpsk_demodulator(received_symbols)
%QPSK_DEMODULATOR Demodulate a sequence of QPSK symbols into bits
%   bit_sequence = qpsk_demodulator(received_symbols)
%   Input:
%     received_symbols: a 1D array of complex numbers (received QPSK symbols)
%   Output:
%     bit_sequence: a 1D array of bits (0s and 1s)

% Ensure received_symbols is a column vector
received_symbols = received_symbols(:);

% Define QPSK constellation points (Gray code mapping)
% Indices correspond to:
% 0 -> bits [0, 0] -> (1 + 1j)/√2
% 1 -> bits [0, 1] -> (-1 + 1j)/√2
% 2 -> bits [1, 0] -> (1 - 1j)/√2
% 3 -> bits [1, 1] -> (-1 - 1j)/√2
constellation = [(1+1j)/sqrt(2), (-1+1j)/sqrt(2), ...
                 (1-1j)/sqrt(2), (-1-1j)/sqrt(2)];

% Initialize array to hold symbol indices
symbol_indices = zeros(length(received_symbols), 1);

% Demodulate each received symbol
for k = 1:length(received_symbols)
    % Calculate Euclidean distances to each constellation point
    distances = abs(received_symbols(k) - constellation).^2;
    % Find the index of the closest constellation point
    [~, idx] = min(distances);
    % Store the index (adjusted for zero-based indexing)
    symbol_indices(k) = idx - 1;
end

% Map symbol indices back to bit pairs
% Preallocate bit sequence array
bit_pairs = zeros(length(symbol_indices), 2);

for k = 1:length(symbol_indices)
    idx = symbol_indices(k);
    % Extract bits from symbol index using bit manipulation
    % Since we used idx = bit1 * 2 + bit2 in the modulator,
    % we can reverse this process:
    bit1 = bitget(idx, 2); % Most significant bit
    bit2 = bitget(idx, 1); % Least significant bit
    bit_pairs(k, :) = [bit1, bit2];
end

% Reshape bit pairs into a 1D bit sequence
bit_sequence = reshape(bit_pairs.', [], 1);

end
