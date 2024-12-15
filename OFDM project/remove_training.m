function payloadsymbols = remove_training(rx_with_training, conf)
if strcmp(conf.training_type, 'Block')
    % Preallocate space for payload
    payloadsymbols = zeros(conf.n_payload_symbols * conf.n_carriers, 1);
    
    for i = 1:conf.n_training_symbols
        start_idx = (i-1)*conf.n_carriers*(conf.block_interval+1) + 1;
        
        payload_start = start_idx + conf.n_carriers;
        payload_end   = payload_start + conf.n_carriers*conf.block_interval - 1;
        
        payloadsymbols((i-1)*conf.n_carriers*conf.block_interval + 1 : i*conf.n_carriers*conf.block_interval) = ...
            rx_with_training(payload_start : payload_end);
    end
end
end
