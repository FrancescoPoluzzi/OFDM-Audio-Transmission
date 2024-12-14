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
%conf.audiosystem ='bypass'; % no channel at all
conf.audiosystem = 'awgn'; % simulated awgn channel
%conf.audiosystem ='native'; 
%conf.audiosystem ='matlab';

conf.what_to_send = 'random'; % send random bits
%conf.what_to_send = 'image';  % send an image

if strcmp(conf.what_to_send,'image')
    src_img = imread('image.jpg'); % read the image\
    if size(src_img, 3) == 3
        % The image has three channels, so it's in color (RGB). Convert to grayscale.
        src_img = rgb2gray(src_img);
    end
    [rows, cols] = size(src_img);
    pixel_values = src_img(:);
    bits_matrix = de2bi(pixel_values, 8, 'left-msb');
    tx_bit_stream = bits_matrix(:);
    tx_bit_stream = logical(tx_bit_stream);
    conf.nbits   = length(tx_bit_stream);    % number of bits 

elseif strcmp(conf.what_to_send,'random')
    conf.nbits = 10000;
    tx_bit_stream = randi([0 1],conf.nbits,1);
   
end


conf.f_s     = 48000;   % sampling frequency
conf.f_sym   = 100; % symbol rate (only for BPSK preamble)

conf.modulation_order = 2; % BPSK:1, QPSK:2
conf.f_c     = 8000; % carrier frequency
conf.n_carriers = 1024;
conf.n_payload_symbols = 4 ; % Number of multi-carrier QPSK symbols per frame
conf.bitsperframe = conf.n_carriers*conf.n_payload_symbols*2; 
conf.nframes = ceil(conf.nbits/conf.bitsperframe);       % number of frames to transmit
conf.last_frame_padding =  conf.nframes * conf.bitsperframe - conf.nbits;
if conf.last_frame_padding > 0
    tx_bit_stream = [tx_bit_stream; zeros(conf.last_frame_padding, 1)];
end
rx_bit_stream = zeros(size(tx_bit_stream));

conf.bitsXsymb = conf.n_carriers*2; % Because we are using QPSK
conf.spacing = 5; % spacing between symbols in Hz
conf.os_factor = ceil(conf.f_s / (conf.spacing * conf.n_carriers));   % OS factor of our system. It will feed OSIFFT and OSFFT.
conf.rolloff = 0.22;
conf.os_factor_preamble  =96;% conf.f_s/conf.f_sym; % oversampling factor for BPSK preamble
conf.symbol_length = conf.os_factor*conf.n_carriers;
conf.cp_len = conf.symbol_length/2; % length of cyclic prefix == half of the symbol length
conf.tx_filterlen = 20;
conf.npreamble  = 100;
conf.bitsps     = 16;   % bits per audio sample
conf.offset     = 0;
conf.training_bits = randi([0,1],conf.n_carriers,1); 
conf.training_symbol = 1 - 2 * conf.training_bits; % BPSK-mapped training sequence
conf.BW_BB = ceil((conf.n_carriers +1)/2)*conf.spacing; 

% Init Section
% all calculations that you only have to do once

if mod(conf.os_factor,1) ~= 0
   disp('WARNING: Sampling rate must be a multiple of the symbol rate'); 
end
conf.nsyms      = ceil(conf.nbits/conf.modulation_order);

% Initialize result structure with zero
res.biterrors   = zeros(conf.nframes,1);
res.rxnbits     = zeros(conf.nframes,1);

% TODO: To speed up your simulation pregenerate data you can reuse
% beforehand.

% Results    

for k=1:conf.nframes
    
    % Generate random data
    %txbits = randi([0 1],conf.nbits,1);
    txbits = tx_bit_stream((k-1)*conf.bitsperframe +1 : k*conf.bitsperframe);

    % TODO: Implement tx() Transmit Function
    % Generate Preamble
    txsignal = tx(txbits, conf, k);
    % there is IFFT and CP insertion done inside these functions
    
    % Normalization
    % preamble  
    avgEpreamble = sum(abs(txsignal).^2)/length(txsignal);        
    txsignal = (1/sqrt(avgEpreamble))*txsignal;


    txsignal = up_conversion(txsignal, conf.f_c, conf.f_s);

    % % % % % % % % % % % %
    % Begin
    % Audio Transmission
    %
    
    peakvalue       = max(abs(txsignal));
    normtxsignal    = txsignal / (peakvalue + 0.3);
    
    % create vector for transmission
    rawtxsignal = [ zeros(conf.f_s,1) ; normtxsignal ;  zeros(conf.f_s,1) ]; % add padding before and after the signal
    rawtxsignal = [  rawtxsignal  zeros(size(rawtxsignal)) ]; % add second channel: no signal
    txdur       = length(rawtxsignal)/conf.f_s; % calculate length of transmitted signal
    
%     wavwrite(rawtxsignal,conf.f_s,16,'out.wav')   
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
    

    % End
    % Audio Transmission   
    % % % % % % % % % % % %
    
    % TODO: Implement rx() Receive Function
    [rxbits, conf]       = rx(rxsignal,conf, k);

    rx_bit_stream((k-1)*conf.bitsperframe +1 : k*conf.bitsperframe) = rxbits;

    if strcmp(conf.what_to_send,'random')
        % Plot received signal for debugging
        figure;
        plot(rxsignal);
        title('Received Signal')
      
        figure;
        plot(txsignal);
        title('Sent Signal')
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

