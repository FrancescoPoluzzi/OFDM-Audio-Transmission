function [beginning_of_data, phase_of_peak, magnitude_of_peak, found] = frame_sync(rx_signal, L, detection_threshold, frame_sync_length)
% Full function for frame synchronization. It handles preamble generation,
% correlation for frame detection, estimation of initial phase offset, and
% estimation oof the channel's magnitude (for receiver's diversity)
% Also considers oversampling.
% Outputs initial data index, initial phase offset and magnitude of the
% channel.

% Frame synchronizer.
% rx_signal is the noisy received signal, and L is the oversampling factor (L=1 in chapter 2, L=4 in all later chapters).
% The returned value is the index of the first data symbol in rx_signal.

if (rx_signal(1) == 0)
    warning('Signal seems to be noise-free. The frame synchronizer will not work in this case.');
end

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
            phase_of_peak = angle(c);
            magnitude_of_peak = abs(c/frame_sync_length);
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
phase_of_peak = 0;
magnitude_of_peak = 0;
warning('No synchronization sequence found.');
return