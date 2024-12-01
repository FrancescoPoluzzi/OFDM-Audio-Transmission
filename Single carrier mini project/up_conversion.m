function sPB = up_conversion(sBB, fc, fs)
%UP_CONVERSION Upconvert a baseband signal to a passband signal
%   sPB = up_conversion(sBB, fc, fs)
%   Input:
%     sBB: complex baseband signal (array of complex numbers)
%     fc: carrier frequency (scalar)
%     fs: sampling frequency (scalar)
%   Output:
%     sPB: real passband signal after upconversion

% Ensure sBB is a column vector
sBB = sBB(:);

% Generate time vector based on sampling frequency
t = (0:length(sBB)-1)' / fs;

exp_component = exp(+1j * 2 * pi * fc * t);

% Perform upconversion
sPB_cmplx = sBB .* exp_component;

sPB = real(sPB_cmplx);

end

