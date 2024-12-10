function [corrected_symbols] = phase_tracking(rx_symbols, training_symbols, N, num_symbols)
    % rx_symbols - payload 
    % N: Number of subcarriers
    % num_symbols: Number of symbols to process

    phase_offsets = zeros(1, num_symbols);  
    corrected_symbols = zeros(size(rx_symbols));  
    accumulated_phase_offset = 0;  
    
    for k = 1:num_symbols
       
        phase_offset = angle(rx_symbols(k) / pilot_symbols(k));
        accumulated_phase_offset = accumulated_phase_offset + phase_offset;
        corrected_symbols(k) = rx_symbols(k) * exp(-1j * accumulated_phase_offset);

        phase_offsets(k) = accumulated_phase_offset;
        
        % Check if phase tracking is needed (e.g., if accumulated phase exceeds threshold)
        if abs(accumulated_phase_offset) > pi / 4  
            disp(['Phase tracking needed at symbol ', num2str(k)]);
            
        end
    end
end