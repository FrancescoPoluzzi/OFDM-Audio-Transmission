function [b] = demapper(symbol)
%DEMAPPER Summary of this function goes here
%   Detailed explanation goes here
bit1 = real(symbol) > 0;
bit2 = imag(symbol) > 0;

% b is a two colomn vector col1: real, col2: imag
b = [bit1 bit2];
b = b';
b = b(:);

end

