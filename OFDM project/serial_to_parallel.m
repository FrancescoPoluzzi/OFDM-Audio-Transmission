function parallel_data = serial_to_parallel(serial_data, conf)
    % Splits serial_data into num_carriers parallel streams.
    % serial_data: Input serial data (column vector).
    % conf.carriers: Number of OFDM subcarriers.
    % conf.symbol_length: Total length of one OFDM symbol (in samples/bits).
    %
    % Returns:
    %   parallel_data: A matrix with 'conf.carriers' rows. The columns represent 
    %   the samples for each symbol and subcarrier. If sc_symbol_len = 1, 
    %   the size is (conf.carriers, num_symbols). Otherwise, it is 
    %   (conf.carriers, num_symbols * sc_symbol_len).

    num_carriers = conf.n_carriers;
    mc_symbol_len = conf.n_carriers * (1+conf.n_payload_symbols);                 % Total samples per OFDM symbol
    sc_symbol_len = mc_symbol_len / num_carriers;       % Samples per carrier per OFDM symbol

    % Reshape the serial data into a matrix:
    % First, we reshape so that each column (or group of columns if sc_symbol_len>1)
    % represents all carriers for a given set of symbol samples.
    % The final shape will be:
    %   parallel_data: (num_carriers) x (num_ofdm_symbols * sc_symbol_len)
    %
    % Each block of 'sc_symbol_len' columns represents one OFDM symbol across all carriers.
    % If sc_symbol_len = 1, this simplifies to (num_carriers) x (num_ofdm_symbols).
    
    parallel_data = reshape(serial_data, [num_carriers, sc_symbol_len]);
end