% % % % %
% Wireless Receivers: algorithms and architectures
% Audio Transmission Framework 
%
%
%   3 operating modes:
%   - 'matlab' : generic MATLAB audio routines (unreliable under Linux)
%   - 'native' : OS native audio system
%       - ALSA audio tools, most Linux distrubtions
%       - builtin WAV tools on Windows 
%   - 'bypass' : no audio transmission, takes txsignal as received signal

% Configuration Values
%conf.audiosystem   ='bypass'; % no channel at all
%conf.audiosystem    = 'awgn'; % simulated awgn channel
%conf.audiosystem   ='native'; 
conf.audiosystem   ='matlab';

n_carriers_list = 2.^(8:12); % Powers of 2: 256, 512, 1024
tracking_methods = {'Comb', 'Block_Viterbi', 'Block'};
results = struct();
ber_results = zeros(length(n_carriers_list), length(tracking_methods));

for t_idx = 1:length(tracking_methods)
    conf.tracking_method = tracking_methods{t_idx};
    for n_idx = 1:length(n_carriers_list)
        conf.n_carriers = n_carriers_list(n_idx);


conf.show_plots = false; % set to true to show all the plots

if strcmp(conf.what_to_send,'image')
    src_img = imread('image.jpg'); % read the image\
    if size(src_img, 3) == 3
        % The image has three channels, so it's in color (RGB). Convert to grayscale.
        src_img = rgb2gray(src_img);
    end
    [rows, cols]    = size(src_img);
    pixel_values    = src_img(:);
    bits_matrix     = de2bi(pixel_values, 8, 'left-msb');
    tx_bit_stream   = bits_matrix(:);
    tx_bit_stream   = logical(tx_bit_stream);
    conf.nbits      = length(tx_bit_stream);    % number of bits 

elseif strcmp(conf.what_to_send,'random')
    conf.nbits = 10000;
    tx_bit_stream = randi([0 1],conf.nbits,1);
end

conf.f_s                = 48000;        % sampling frequency
conf.f_sym              = 100;          % symbol rate (only for BPSK preamble)
conf.modulation_order   = 2;            % BPSK:1, QPSK:2
conf.f_c                = 8000;         % carrier frequency

conf.n_payload_symbols  = 8 ;           % Number of multi-carrier QPSK symbols per frame

if strcmp(conf.tracking_method,'Block')  | strcmp(conf.tracking_method,'Block_Viterbi')
    conf.block_interval = 4 ; % how many payload symbols each training symbol
    conf.n_training_symbols = ceil(conf.n_payload_symbols/conf.block_interval);
    conf.bitsperframe = conf.n_carriers*conf.n_payload_symbols*2; 

elseif strcmp(conf.tracking_method,'Comb')
    conf.comb_training_interval = 4; % each how many subcarriers to insert a training symbol
    conf.n_training_symbols = 1; % we'll still send the training symbol at the beginning of the frame 
    conf.n_trainings_per_symbol = conf.n_carriers/conf.comb_training_interval;
    conf.bitsperframe = (conf.n_carriers-conf.n_trainings_per_symbol)*conf.n_payload_symbols*2; 
end

conf.nframes = ceil(conf.nbits/conf.bitsperframe);       % number of frames to transmit
conf.last_frame_padding =  conf.nframes * conf.bitsperframe - conf.nbits;

if conf.last_frame_padding > 0
    tx_bit_stream = [tx_bit_stream; zeros(conf.last_frame_padding, 1)];
end

rx_bit_stream = zeros(size(tx_bit_stream));

conf.bitsXsymb           = conf.n_carriers*2; % Because we are using QPSK
conf.spacing             = 5; % spacing between symbols in Hz
conf.os_factor           = ceil(conf.f_s / (conf.spacing * conf.n_carriers));   % OS factor of our system. It will feed OSIFFT and OSFFT.
conf.rolloff             = 0.22;
conf.os_factor_preamble  = 96; % conf.f_s/conf.f_sym; % oversampling factor for BPSK preamble
conf.symbol_length       = conf.os_factor*conf.n_carriers;
conf.cp_len              = conf.symbol_length/2; % length of cyclic prefix == half of the symbol length
conf.tx_filterlen        = 20;
conf.npreamble           = 100;
conf.bitsps              = 16;   % bits per audio sample
conf.offset              = 0;
conf.training_bits       = randi([0,1],conf.n_carriers,1); 
conf.training_symbol     = 1 - 2 * conf.training_bits; % BPSK-mapped training sequence
conf.BW_BB               = ceil((conf.n_carriers +1)/2)*conf.spacing; 

% Init Section
% all calculations that you only have to do once

if mod(conf.os_factor,1) ~= 0
   disp('WARNING: Sampling rate must be a multiple of the symbol rate'); 
end
conf.nsyms = ceil(conf.nbits/conf.modulation_order);

% Initialize result structure with zero
res.biterrors   = zeros(conf.nframes,1);
res.rxnbits     = zeros(conf.nframes,1);

% Results    

for k=1:conf.nframes
    
    % Generate random data
    %txbits = randi([0 1],conf.nbits,1);
    txbits = tx_bit_stream((k-1)*conf.bitsperframe +1 : k*conf.bitsperframe);

    % Implementing tx() Transmit Function that forms the transmit signal
    % with the preamble, the training data and the payload data
    txsignal = tx(txbits, conf, k);
    
    % Normalization of the signal 
    avgEpreamble = sum(abs(txsignal).^2)/length(txsignal);        
    txsignal = (1/sqrt(avgEpreamble))*txsignal;

    % Up converting the signal
    txsignal = up_conversion(txsignal, conf.f_c, conf.f_s);

    peakvalue       = max(abs(txsignal));
    normtxsignal    = txsignal / (peakvalue + 0.3);
    
    % create vector for transmission
    rawtxsignal = [ zeros(conf.f_s,1) ; normtxsignal ;  zeros(conf.f_s,1) ]; % add padding before and after the signal
    rawtxsignal = [  rawtxsignal  zeros(size(rawtxsignal)) ]; % add second channel: no signal
    txdur       = length(rawtxsignal)/conf.f_s; % calculate length of transmitted signal
    
    % wavwrite(rawtxsignal,conf.f_s,16,'out.wav')   
    audiowrite('out.wav',rawtxsignal,conf.f_s)  
    
    % Platform native audio mode 
    if strcmp(conf.audiosystem,'native')
        
        % Windows WAV mode 
        if ispc()
            disp('Windows WAV');
            wavplay(rawtxsignal,conf.f_s,'async');
            disp('Recording in Progress');
            rawrxsignal = wavrecord((txdur+1)*conf.f_s,conf.f_s);
            disp('Recording complete')
            rxsignal = rawrxsignal(1:end,1);

        % ALSA WAV mode 
        elseif isunix()
            disp('Linux ALSA');
            cmd = sprintf('arecord -c 2 -r %d -f s16_le  -d %d in.wav &',conf.f_s,ceil(txdur)+1);
            system(cmd); 
            disp('Recording in Progress');
            system('aplay  out.wav')
            pause(2);
            disp('Recording complete')
            rawrxsignal = audioread('in.wav');
            rxsignal    = rawrxsignal(1:end,1);
        end
        
    % MATLAB audio mode
    elseif strcmp(conf.audiosystem,'matlab')
        disp('MATLAB generic');
        playobj = audioplayer(rawtxsignal,conf.f_s,conf.bitsps);
        recobj  = audiorecorder(conf.f_s,conf.bitsps,1);
        record(recobj);
        disp('Recording in Progress');
        playblocking(playobj)
        pause(0.5);
        stop(recobj);
        disp('Recording complete')
        rawrxsignal  = getaudiodata(recobj,'int16');
        rxsignal     = double(rawrxsignal(1:end))/double(intmax('int16')) ;
        
    elseif strcmp(conf.audiosystem,'bypass')
        SNRdB = 50;
        rxsignal = rawtxsignal(:,1);

  elseif strcmp(conf.audiosystem,'awgn')
        SNRdB = 20;
        rawrxsignal = rawtxsignal(:,1);
        rxsignal    = awgn_channel(rawrxsignal, SNRdB);

    end
    % Implementing rx() Receive Function
    [rxbits, conf, h]       = rx(rxsignal,conf, k);

    rx_bit_stream((k-1)*conf.bitsperframe +1 : k*conf.bitsperframe) = rxbits;

    if(conf.show_plots == true)
        if strcmp(conf.what_to_send,'random')
            % Plot received signal for debugging
            figure;
            plot(rxsignal);
            title('Received Signal')
          
            figure;
            plot(txsignal);
            title('Sent Signal')
        end
        plot_signal_spectrum(txsignal, rxsignal, conf);
    end

    res.rxnbits(k)      = length(rxbits);  
    res.biterrors(k)    = sum(rxbits ~= txbits);
    
end

if strcmp(conf.what_to_send,'image')

    % Remove zero padding to images
    if conf.last_frame_padding > 0
        tx_bit_stream = tx_bit_stream(1:end-conf.last_frame_padding);
        rx_bit_stream = rx_bit_stream(1:end-conf.last_frame_padding);
    end
    bits_matrix_reconstructed = reshape(rx_bit_stream, [], 8);
    pixel_values_reconstructed = uint8(bi2de(bits_matrix_reconstructed, 'left-msb'));
    img_reconstructed = reshape(pixel_values_reconstructed, rows, cols);
    % compare original image with the received one
    figure;
    subplot(1, 2, 1); 
    imshow(src_img); 
    title('Original Source Image');
    subplot(1, 2, 2);
    imshow(img_reconstructed);
    title('Reconstructed Image');
    sgtitle('Comparison of Original and Reconstructed Images');
end

per = sum(res.biterrors > 0)/conf.nframes
ber = sum(res.biterrors)/sum(res.rxnbits)

        ber_results(n_idx, t_idx) = ber; % Store BER for this configuration


    end
end

if(conf.show_plots == true)
    plots(conf,h)
end

% Plot BER vs. Number of Carriers and save the plot
figure;
hold on;
for t_idx = 1:length(tracking_methods)
    plot(n_carriers_list, ber_results(:, t_idx), '-o', 'DisplayName', tracking_methods{t_idx}, 'LineWidth', 1.5);
end
xlabel('Number of Carriers');
ylabel('BER');
title('BER vs. Number of Carriers for Different Tracking Methods');
legend('Location', 'best');
grid on;
% Automatically scale the y-axis based on the data
ylim('auto');

hold off;

% Create the directory if it doesn't exist
if ~exist('plots', 'dir')
    mkdir('plots');
end

% Save the plot as a PNG file without the axes toolbar
exportgraphics(gcf, 'plots/ber_vs_n_carriers.png', 'Resolution', 300);
