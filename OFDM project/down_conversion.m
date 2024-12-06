function sBB = down_conversion(rPB, fc, fs)
%DOWN_CONVERSION Downconvert a passband signal to a baseband signal
%   sBB = down_conversion(rPB, fc, fs)
%   Input:
%     rPB: real passband signal (array of real numbers)
%     fc: carrier frequency (scalar)
%     fs: sampling frequency (scalar)
%   Output:
%     sBB: complex baseband signal after downconversion

% Ensure rPB is a column vector
rPB = rPB(:);

% Generate time vector based on sampling frequency
t = (0:length(rPB)-1)' / fs;

% Compute complex exponential for downconversion
exp_component = exp(-1j * 2 * pi * fc * t);

% Perform downconversion
sBB = rPB .* exp_component;

end
