function [rxbits conf] = rx(rxsignal,conf,k)
    % Digital Receiver
    %
    %   [txsignal conf] = tx(txbits,conf,k) implements a complete causal
    %   receiver in digital domain.
    %
    %   rxsignal    : received signal
    %   conf        : configuration structure
    %   k           : frame index
    %
    %   Outputs
    %
    %   rxbits      : received bits
    %   conf        : configuration structure
    %
    frame_detection_threshold = 50;
    preamble = lfsr_framesync(conf.npreamble); % generate preamble of 100 bits (no need to map for bpsk)
    preamble_bpsk = -2 .* preamble + 1;
    
    rxsymbols = down_conversion(rxsignal, conf.f_c, conf.f_s);
    
    rxsymbols = lowpass(rxsymbols, conf);
    
    [start_idx, phase_of_peak, ~] = frame_sync(rxsymbols, conf.os_factor, frame_detection_threshold, conf.npreamble);
    
    filtered_rx_symbols = matched_filter(rxsymbols, conf.os_factor, 20);
    
    cum_err = 0;
    preamble_start = start_idx-conf.npreamble*conf.os_factor;
    for ii = 0 : conf.npreamble-1
        idx_start  = preamble_start + ii*conf.os_factor;
        idx_range  = idx_start: idx_start+conf.os_factor-1;
        segment    = filtered_rx_symbols(idx_range);
        x = abs(segment).^2; % calculate power
        idx_complex = 0:conf.os_factor-1;
        cmplx = (-1i) .^ idx_complex;
        cum_err = cum_err + sum( x .* cmplx.');
    end 

    cum_err=0;

    % find delays
    [epsilon, ~] = find_epsilon(filtered_rx_symbols, conf.os_factor, start_idx, conf.nsyms, cum_err);
    timing_corrected_rx_symbols = interpolator_linear(filtered_rx_symbols, epsilon, start_idx, conf.nsyms, conf.os_factor);
    phase_offs = phase_offset_estimation_filter(timing_corrected_rx_symbols, conf.nsyms, phase_of_peak);
    phase_corrected_rx_symbols = timing_corrected_rx_symbols.' .* exp(-1i .* phase_offs);
    
    constellation = [(1+1j)/sqrt(2), (-1+1j)/sqrt(2), ...
                     (1-1j)/sqrt(2), (-1-1j)/sqrt(2)];
    bit_pairs = [0 0; 0 1; 1 0 ; 1 1];
    
    %rxbits = reshape(demapper_general(phase_corrected_rx_symbols, constellation, bit_pairs).', [], 1);
    %rxbits = not(rxbits);
    
    %payload = downsample(filtered_rx_symbols(start_idx:start_idx+conf.nsyms*conf.os_factor-1), conf.os_factor);
    %rxbits = reshape(demapper_general(payload, constellation, bit_pairs).', [], 1);
    
    rxbits = reshape(demapper_general(timing_corrected_rx_symbols, constellation, bit_pairs).', [], 1);

    % dummy 
    %rxbits = zeros(conf.nbits,1);