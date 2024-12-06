function [data] = interpolator_cubic(filtered_rx_signal, epsilon, data_idx, data_length, os_factor)
% perform cubic interpolation to counter channel delay.
% has to be called after estimating epsilon with find_epsilon
% Inputs:
% - filtered_rx_signal: delayed matched-filterd signal
% - epsilon: sequence of estimated timing  delays
% - data_idx: starting index of the payload data
% - data_length
% - os_factor

data = zeros(1,data_length);
 % cubic interpolator
 matrix = [-1, 3, -3, 1;
           3, -6, 3, 0;
           -2, -3, 6, -1;
           0, 6 ,0, 0];

for ii=1:data_length
    
     idx_start  = data_idx+(ii-1)*os_factor;
     
     epsilon_tmp = epsilon(ii);
     % offset of sample
     % sample_diff is the integer part of the timing error, which represents 
     % a whole sample period shift in the sampling location
     sample_diff   = floor(epsilon_tmp*os_factor); % integer offset
     % int_diff:fractional part of the timing error, which represents a partial sample period shift. 
     % It captures any residual timing offset that is less than one sample period
     int_diff      = mod(epsilon_tmp*os_factor,1); % fractional offset (interval [0 1) )

     y2 = filtered_rx_signal(idx_start+sample_diff-1: idx_start+sample_diff+os_factor-2);
     c = (1/6) * matrix * y2;
     y_hat2 = c(1)*int_diff^3 + c(2)*int_diff^2 + c(3)*int_diff + c(4);
     data(ii) = y_hat2;

    end


end

