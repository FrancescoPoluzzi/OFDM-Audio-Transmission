function bit_sequence = qpsk_demodulator(received_symbols)

% Define QPSK constellation points (Gray code mapping)

GrayMap = 1/sqrt(2) * [(-1-1j) (-1+1j) ( 1-1j) ( 1+1j)];

 % Find the closest constellation points
 [~, indices] = min(abs(received_symbols(:) - GrayMap).^2, [], 2);

 % Convert indices to binary (0-based)
bit_pairs = de2bi(indices - 1, 2, 'left-msb');

% Reshape bit pairs into a 1D bit sequence
bit_sequence = reshape(bit_pairs.', [], 1);

end
