function [theta_hat] = phase_offset_estimation_filter(payload_data,data_length,initial_theta)
%PHASE_OFFSET_ESTIMATION
% Perform phase offset estimatiion for a PSK symbols sequence.
% Inputs:
% - payload-data: already timing-corrected sequence
% - data_length
% - intitial_theta: phase of the peak of the correlation with the preamble sequence

theta_hat = zeros(data_length+1, 1);
theta_hat(1) = initial_theta;

    for k = 1 : data_length
        
        % Phase estimation    
        %TODO 2 :  // Apply viterbi-viterbi algorithm on payload_data
        Theta_hat_nofilter = 0.25 * angle( -payload_data(k) ^4 ); % theta estimation (ViterbiViterbi)
        deltaTheta = Theta_hat_nofilter + pi/2*(-1:4); % find the 4 possible phase values
    
        %TODO 4 :
        [~, ind] = min(abs(deltaTheta - theta_hat(k)));
        theta = deltaTheta(ind);
        % low pass filter
        % This weighted combination acts as a simple low-pass filter for the 
        % phase estimates. By heavily weighting the previous phase (theta_hat(k)) 
        % and slightly weighting the current estimate (theta), the phase estimate 
        % theta_hat(k+1) becomes smooth and resistant to abrupt changes or noise. 
        % This smoothing helps eliminate high-frequency noise that might otherwise 
        % cause the phase estimate to fluctuate, leading to inaccurate demodulation.
        theta_hat(k+1) = mod(0.1*theta + 0.9*theta_hat(k), 2*pi); 
        
        %TODO 4 :
        payload_data(k) = payload_data(k) * exp(-1i * theta_hat(k+1));
    
    end
    theta_hat = theta_hat(2:end);
end
