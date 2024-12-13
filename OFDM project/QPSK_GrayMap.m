function [symbols] = QPSK_grayMap(in_bits)
%QPSK_GRAYMAP

% Define a known normalized sequence of symbols:
GrayMap = 1/sqrt(2) * [(-1-1j) (-1+1j) ( 1-1j) ( 1+1j)];
symbols = GrayMap(bi2de(in_bits, 'left-msb')+1).';
end

