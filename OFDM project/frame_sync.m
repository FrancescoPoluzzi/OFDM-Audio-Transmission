function [beginning_of_data, found] = frame_sync(rx_signal, conf, detection_threshold)

L = conf.os_factor_preamble;

pulse = rrc(L, conf.rolloff, conf.tx_filterlen*conf.os_factor_preamble);
rx_signal = conv(rx_signal, pulse, 'same');

frame_sync_length = conf.npreamble;

% Calculate the frame synchronization sequence and map it to BPSK: 0 -> +1, 1 -> -1
frame_sync_sequence = 1 - 2*lfsr_framesync(frame_sync_length);

% When processing an oversampled signal (L>1), the following is important:
% Do not simply return the index where T exceeds the threshold for the first time. Since the signal is oversampled, so will be the
% peak in the correlator output. So once we have detected a peak, we keep on processing the next L samples and return the index
% where the test statistic takes on the maximum value.
% The following two variables exist for exactly this purpose.
current_peak_value = 0;
samples_after_threshold = L;

for i = L * frame_sync_length + 1 : length(rx_signal)
    r = rx_signal(i - L * frame_sync_length : L : i - L); % The part of the received signal that is currently inside the correlator.
    c = frame_sync_sequence' * r;
    T = abs(c)^2 / abs(r' * r);
    
    if (T > detection_threshold || samples_after_threshold < L)
        samples_after_threshold = samples_after_threshold - 1;
        if (T > current_peak_value)
            beginning_of_data = i;
            % TODO
            % for phase detection, we need to have an initial phase for the
            % first symbol. We use the phase of the peak of the correlator
            % output of the preamble to find this phase
            current_peak_value = T;
        end
        if (samples_after_threshold == 0)
            found = 1;
            return;
        end
    end
end
found = 0;
beginning_of_data = 0;

warning('No synchronization sequence found.');
return