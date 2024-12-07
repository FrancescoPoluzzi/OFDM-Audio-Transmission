function [data] = interpolator(epsilon, data_length, os_factor,type)

data = zeros(1,data_length);

for ii=1:data_length
   
     epsilon_tmp = epsilon(ii);
     
     % offset of sample
     sample_diff   = floor(epsilon_tmp*os_factor); % integer offset
     int_diff      = mod(epsilon_tmp*os_factor,1); % fractional offset (interval [0 1) )
    
     % linear
     if type == "linear"
         y = filtered_rx_signal(idx_start+sample_diff:idx_start+sample_diff+1);
         y_hat = (1-int_diff)*y(1) + int_diff*y(2);
         data(ii) = y_hat;
     end
     % cubic
     if type == "cubic"
         y = filtered_rx_signal(idx_start+sample_diff-1:idx_start+sample_diff+2);
         A = [ -1 1 -1 1; 0 0 0 1; 1 1 1 1; 8 4 2 1];
         c = inv(A)*y;
         y_hat = c(1)*int_diff^3+c(2)*int_diff^2+c(3)*int_diff+c(4);
         data(ii) = y_hat;
     end
     
    end

end