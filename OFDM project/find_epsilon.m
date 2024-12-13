function [epsilon, cum_err] = find_epsilon(filtered_rx_signal, L ,data_idx , data_length, initial_cum_err)
% Find the epsilon delays of each received sample. Returns an array of
% epsilon values and the cumulative sum (useful when using the preamble to
% improve timing estimation)
% Inputs:
% - filtered_rx_signal: matched-filtered received signal.
% - L: oversampling factor
% - data_idx: first index of the data (found with frame detection)
% - data_length: number of samples, considering oversampling
% - initial_cum_err: starting cumulative error. Set to 0 unless you used
%   the preamble to improve estimation.

    cum_err = initial_cum_err;
    diff_err = zeros(1,data_length);
    epsilon  = zeros(1,data_length);
    
    for i=1:data_length
         
         idx_start  = data_idx+(i-1)*L; % L*(n-1)
         % we take into account os_factor samples at the time
         idx_range  = idx_start:idx_start+L-1; % L*(n-1) to L*(n-1)+L-1
         segment    = filtered_rx_signal(idx_range);
        
         % Estimate timing error epsilon
         % TODO
         x = abs(segment).^2;
         idx_complex = 0:L-1; % [0,1,2,3]
         cmplx = (-1i) .^ idx_complex;
         diff_err(i) = sum( x .* cmplx.');
         cum_err     = cum_err + diff_err(i);
         epsilon(i)  = -(1/(2*pi))*angle(cum_err);
    end

end