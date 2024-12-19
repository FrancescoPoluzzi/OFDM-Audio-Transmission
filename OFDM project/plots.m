function [] = plots(conf, h)

    N = conf.symbol_length; % OFDM symbol length
    Ts = 1/conf.spacing;    % Time to send a sample of an OFDM symbol
    time = 0 : Ts : (conf.n_payload_symbols + conf.n_training_symbols -1 ) * Ts; % Time vector

    if strcmp(conf.tracking_method,'Comb') == false % with comb training we don't keep track of the channel

        %% Channel Spectrum Evaluation (Frequency Domain)
        % Average Channel Frequency Response Over Time
        h_avg = mean(abs(h), 2); % Average over columns (time samples)
        figure;
        plot(1:conf.n_carriers, h_avg, 'LineWidth', 1.5);
        xlabel('Subcarrier Index');
        ylabel('Average Magnitude');
        title('Average Channel Frequency Response');
        grid on;
        xlim([1 conf.n_carriers]); % Ensure x-axis spans all subcarriers
    
        %% Channel Spectrum Evaluation Over Time (Magnitude)
        figure;
        for i = 1 : 32 : conf.n_carriers % Iterate over selected subcarriers
            magnitude_dB = 20 * log10(abs(h(i, :)) ./ max(abs(h(i, :))));
            plot(time(1:length(magnitude_dB)), magnitude_dB);
            hold on;
        end
        xlabel('Time (s)');
        ylabel('Magnitude (dB)');
        title('Channel Magnitude Evolution Over Time');
        %legend(arrayfun(@(x) ['Subcarrier ', num2str(x)], 1:32:conf.n_carriers, 'UniformOutput', false));
        grid on;
    
        %% Channel Spectrum Evaluation Over Time (Phase)
        figure;
        hold on; % Hold the plot for multiple lines
        selected_subcarriers = 1:32:conf.n_carriers; % Select every 32nd subcarrier
        num_selected = length(selected_subcarriers); % Number of selected subcarriers
        % Preallocate for efficiency
        magnitude_dB = zeros(num_selected, conf.n_payload_symbols+conf.n_training_symbols);
        for idx = 1:num_selected
            i = selected_subcarriers(idx);
            h_i = abs(h(i, :));
            h_i_max = max(h_i);
            
            % Avoid division by zero
            if h_i_max > 1e-10
                magnitude_dB(idx, :) = 20 * log10(h_i ./ h_i_max);
            else
                magnitude_dB(idx, :) = -Inf; % Assign -Inf dB if max is zero
            end
            
            plot(time, magnitude_dB(idx, :), 'LineWidth', 1.2);
        end
        xlabel('Time (s)');
        ylabel('Magnitude (dB)');
        title('Channel Magnitude Evolution Over Time');
        grid on;
        legend(arrayfun(@(x) ['Subcarrier ', num2str(x)], selected_subcarriers, 'UniformOutput', false), 'Location', 'best');
        hold off;
    
        %% Channel Impulse Response (CIR)
        % Number of taps for CIR (assuming N = conf.n_carriers)
        N = conf.n_carriers;
        % Compute CIR using IFFT along the frequency (subcarrier) dimension (rows)
        CIR = ifft(h, N, 1); % Resulting in (n_carriers x time_samples)    
        % Plot CIR for specific time samples or average    
        % Option 1: Plot CIR for the first time sample
        time_sample = 1; % Change as needed
        CIR_first = CIR(:, time_sample);    
        figure;
        plot(1:N, abs(CIR_first), 'LineWidth', 1.5);
        xlabel('Tap Index');
        ylabel('Magnitude');
        ylim([0 1.5]);
        title(['Channel Impulse Response at Time Sample ', num2str(time_sample)]);
        grid on;
        xlim([1 N]);
    
        %% Channel Evolution Over Time (Heatmap)
        figure;
        imagesc(abs(h)); % Plot magnitude of channel evolution
        xlabel('Subcarrier Index');
        ylabel('Time Frame Index');
        title('Channel Magnitude Evolution Over Time');
        colorbar;
        grid on;

        %% Estimate Delay Spread
        significant_taps = find(abs(CIR) > 0.1 * max(abs(CIR), [], 'all'));
        delay_spread = significant_taps(end) - significant_taps(1); % In samples
        disp(['Estimated Delay Spread: ', num2str(delay_spread), ' samples']);

        %% Spectral Efficiency Calculations
        efficiency = conf.symbol_length/(conf.cp_len+conf.symbol_length);
    
        disp(['Spectral Efficiency: ', num2str(efficiency * 100), '%']);

    end

end
