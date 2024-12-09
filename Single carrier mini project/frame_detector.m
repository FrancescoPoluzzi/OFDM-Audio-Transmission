function [start] = frame_detector(p,r, thr)
% Input :   p: preamble (shape = (100, 1)), r: received signal (shape = (Nr, 1)), thr: scalar threshold 
% output:   start: signal start index
% same as correlator but this does not output the correlation sequence
% but directly the starting index

Np = size(p,1);
Nr = size(r,1);
c = zeros(Nr-Np, 1);
c_norm = zeros(Nr-Np, 1);
% TODO:
for i = 1:(Nr-Np+1) % iterate over output values
    c_n = 0;
    norm_term = 0;
    for j = 1:Np    % iterate over preamble
        c_n = c_n + conj(p(j))*r(j+i-1);
        norm_term = norm_term + (abs(r(j+i-1))^2);
    end
    % All the same as correlator.m until now
    correlation = (abs(c_n)^2)  / norm_term;
    if (correlation > thr)
        start = i+Np; % we have to take into account the premble length
        return;
    end
end

% end...
% after loop no threshold reached
disp('Frame start not found.')
start = -1;
end

