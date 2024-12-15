function tx_with_training = add_training(payloadsymbols, conf)

    if strcmp(conf.tracking_method,'Block')
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
    
    elseif strcmp(conf.tracking_method,'Comb')
        tx_with_training = zeros(conf.n_carriers*(conf.n_payload_symbols+conf.n_training_symbols), 1);
        tx_with_training(1: conf.n_carriers) = conf.training_symbol; % at the beginning of the frame, always send a pilot symbol
        payload_pos = 1;
        for i = 1:conf.n_payload_symbols
            % Initialize this MC symbol
            symbol_carriers = zeros(conf.n_carriers, 1);
            % Determine the training positions for this symbol:
            % Starting at index i, step by conf.comb_training_interval, until we have conf.n_trainings_per_symbol training carriers.
            training_positions = i : conf.comb_training_interval : conf.n_carriers;
            training_positions = training_positions(1:conf.n_trainings_per_symbol); 
            % (Assumes the parameters are chosen so that we can pick the first conf.n_trainings_per_symbol entries without running out)           
            % Insert the training values at these positions
            symbol_carriers(training_positions) = conf.training_symbol(training_positions);            
            % The remaining carriers are for payload data
            all_positions = 1:conf.n_carriers;
            non_training_positions = setdiff(all_positions, training_positions);            
            % Fill the non-training positions with payload data
            symbol_carriers(non_training_positions) = payloadsymbols(payload_pos : payload_pos + length(non_training_positions) - 1);
            payload_pos = payload_pos + length(non_training_positions);           
            % Place this MC symbol into the full sequence
            tx_with_training(i*conf.n_carriers + 1 : (i+1)*conf.n_carriers) = symbol_carriers;
            
        end
       
    else
        error('Unknown tracking method specified in conf.tracking_method.');
    end

end
