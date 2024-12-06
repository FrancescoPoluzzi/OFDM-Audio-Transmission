function[symbol] = qpsk_modulator (txbits)
    txbits = reshape(txbits,[],2);
    GrayMap = 1/sqrt(2) * [(-1-1j) (-1+1j) ( 1-1j) ( 1+1j)];
    symbol = GrayMap(bi2de(txbits, 'left-msb')+1).';
end