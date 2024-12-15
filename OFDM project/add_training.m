function tx_with_training = add_training(payloadsymbols, conf)
    if strcmp(conf.training_type,'Block')
        % The total length after adding training:
        % Each training section = (1 training block + conf.block_interval payload blocks)
        % Each block has conf.n_carriers samples.
        % Total = conf.n_training_symbols * (conf.block_interval + 1) * conf.n_carriers
        % This should match conf.n_carriers*(conf.n_payload_symbols+conf.n_training_symbols),
        % implying conf.n_payload_symbols = conf.n_training_symbols * conf.block_interval.
        
        tx_with_training = zeros(conf.n_carriers*(conf.n_payload_symbols+conf.n_training_symbols), 1);
        
        for i = 1:conf.n_training_symbols
            start_idx = (i-1)*conf.n_carriers*(conf.block_interval+1) + 1;
            
            tx_with_training(start_idx : start_idx+conf.n_carriers-1) = conf.training_symbol;
            
            payload_start = start_idx + conf.n_carriers;
            payload_end = payload_start + conf.n_carriers*conf.block_interval - 1;
            
            tx_with_training(payload_start : payload_end) = ...
            payloadsymbols((i-1)*conf.n_carriers*conf.block_interval + 1 : i*conf.n_carriers*conf.block_interval);
        end
    
    elseif strcmp(conf.training_type,'Comb')
       
    end
end
