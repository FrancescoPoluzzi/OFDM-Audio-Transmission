function [filtered_signal, h] = matched_filter(signal, os_factor, mf_length)
% Create a root-raised cosine filter and filter the signal with it. It
% outputs the full convolution sequence, hence it is necessary to remove
% the pulse shape tx filter's size from the beginning and the matched
% filter's size from the end of the output of this function. These size can
% be obtained with length(pulse)
% Inputs:
% os_factor is the oversampling factor (4 in our course)
% mf_length is the one-sided filter length. The total number of filter coefficients is 2*mf_length + 1, that is the center tap and mf_length taps to both sides.
    
    rolloff_factor = 0.22;
    
    h = rrc(os_factor, rolloff_factor, mf_length);
    filtered_signal = conv(h, signal, 'full'); 