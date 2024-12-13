function serial_data = parallel_to_serial(parallel_data)
    % Combines parallel data streams into a single serial stream
    % parallel_data: Input matrix of parallel streams (num_carriers x num_symbols)
    % Returns serial_data: Single-column vector combining all elements in row-major order
    
    serial_data = reshape(parallel_data, [], 1);
end