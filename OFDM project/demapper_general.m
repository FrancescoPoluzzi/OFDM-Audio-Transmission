function [demapped] = demapper_general(symbols, constellation,bit_values)
% Demaps a sequence of noisy symbols relative to any consellation by
% minimizing the euclidean distance.
% Inputs:
% - symbols: noisy symbols sequence.
% - constellation: complex constellation alphabet sequence. Example for
%   QPSK gray mapping:     constellation = [ (-1 - 1i)/sqrt(2), ... 
%                                            (-1 + 1i)/sqrt(2), ... 
%                                           (1 + 1i)/sqrt(2), ... 
%                                            (1 - 1i)/sqrt(2) ];    
% - bit values: corresponding bit mapping of the constellation given as
%   input. It has M rows and Q cols. Example for QPSK gray mapping:
%   bit_values = [0 0; 0 1; 1 1; 1 0];


    [ ~,Q] = size(bit_values);
    demapped = zeros(length(symbols), Q);
       % Demap each noisy QPSK symbol to its nearest ideal constellation point
    for i = 1:length(symbols)
        % Calculate the distance between the noisy symbol and each ideal point
        distances = abs(symbols(i) - constellation);
        
        % Find the index of the nearest constellation point
        [~, nearest_idx] = min(distances);
        
        % Map to the corresponding bit pair
        demapped(i, :) = bit_values(nearest_idx, :);
    end
end
