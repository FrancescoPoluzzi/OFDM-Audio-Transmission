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
conf.audiosystem ='bypass';% 'matlab'; % Values: 'matlab','native','bypass'
%conf.audiosystem ='native';
%conf.audiosystem ='matlab';

symbol_rates =  [ 100 200 ];
BER_values = zeros(length(symbol_rates));

for rate_idx = 1:length(symbol_rates)
    conf.f_s     = 48000;   % sampling frequency
    conf.f_sym   = symbol_rates(rate_idx); % symbol rate (only for BPSK preamble)
    conf.nframes = 1;       % number of frames to transmit
    conf.nbits   = 512;    % number of bits 
    conf.modulation_order = 2; % BPSK:1, QPSK:2
    conf.f_c     = 4000; % carrier frequency
    conf.n_carriers = 256;
    conf.bitsXsymb = conf.n_carriers*2; % Because we are using QPSK
    conf.spacing = 5; % spacing between symbols in Hz
    conf.os_factor = floor(conf.f_s/(conf.spacing*conf.n_carriers)); % oversampling factor for OFDM symbols
    if(mod(conf.f_s/(conf.spacing*conf.n_carriers),1)~=0)
        conf.spacing = conf.f_s/(conf.os_factor*conf.n_carriers);
    end
    conf.rolloff = 0.22;
    conf.os_factor_preamble  = conf.f_s/conf.f_sym; % oversampling factor for BPSK preamble
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
        txbits = randi([0 1],conf.nbits,1);
        
        % TODO: Implement tx() Transmit Function
       txpreamble = tx_preamble(conf, k);
       txtraining = tx_OFDM_training_symbol(conf, k);
       txpayload = tx_OFDM_payload_symbol(txbits, conf, k);

        txsignal = [txpreamble; txtraining; txpayload];
        
        % % % % % % % % % % % %
        % Begin
        % Audio Transmission
        %
        
        % normalize values
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
            rawrxsignal = rawtxsignal(:,1);
           % rxsignal    = awgn_channel(rawrxsignal, SNRdB);
            rxsignal = rawrxsignal;
        end
        
        %{
        % Plot received signal for debugging
        figure;
        plot(rxsignal);
        title('Received Signal')
    
        figure;
        plot(txsignal);
        title('Sent Signal')
        %}
        
        %
        % End
        % Audio Transmission   
        % % % % % % % % % % % %
        
        % TODO: Implement rx() Receive Function
        [rxbits, conf]       = rx(rxsignal,conf, k);
        
        res.rxnbits(k)      = length(rxbits);  
        res.biterrors(k)    = sum(rxbits ~= txbits);
        
    end
    per = sum(res.biterrors > 0)/conf.nframes
    ber = sum(res.biterrors)/sum(res.rxnbits)
    BER_values(rate_idx) = ber;
end

figure;
plot(symbol_rates, BER_values);
xlabel('Symbol rate');
ylabel('Bit error rate');
title('BER vs Symbol rate');


