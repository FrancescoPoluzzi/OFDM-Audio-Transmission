function qpsk_symbols = qpsk_modulator(bit_sequence)
%QPSK_MODULATOR Modulate a sequence of bits into normalized QPSK symbols
%   qpsk_symbols = qpsk_modulator(bit_sequence)
%   Input:
%     bit_sequence: a 1D array of bits (0s and 1s)
%   Output:
%     qpsk_symbols: a sequence of QPSK symbols (complex numbers)

% Ensure bit_sequence is a row vector
bit_sequence = bit_sequence(:).';

% Reshape bits into pairs
bit_pairs = reshape(bit_sequence, 2, []).';

% Convert bit pairs to symbol indices
symbol_indices = bit_pairs(:, 1) * 2 + bit_pairs(:, 2);

% Define QPSK mapping (Gray code)
% 00 -> (1+1j)/√2
% 01 -> (-1+1j)/√2
% 10 -> (1-1j)/√2
% 11 -> (-1-1j)/√2
mapping = [(1+1j)/sqrt(2), (-1+1j)/sqrt(2), (1-1j)/sqrt(2), (-1-1j)/sqrt(2)];

% Map indices to QPSK symbols
qpsk_symbols = mapping(symbol_indices + 1);

end
