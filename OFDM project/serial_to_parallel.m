function parallel_data = serial_to_parallel(serial_data, num_carriers)
    % Splits serial_data into num_carriers parallel streams
    % serial_data: Input serial bit stream (column vector)
    % num_carriers: Number of OFDM subcarriers
    % Returns parallel_data: Matrix of size (num_carriers, num_symbols)
    
    num_symbols = ceil(length(serial_data) / num_carriers);
    padded_serial_data = [serial_data; zeros(num_symbols * num_carriers - length(serial_data), 1)];
    parallel_data = reshape(padded_serial_data, num_carriers, num_symbols);
end