function [res,mu] = computeLink(ri,rj,window,sigma_p,sigma_s)
% [detections,mu] = computeLink(ri,rj,window,sigma_p,sigma_s)
% ---------------------------------------------------------------
% Adaptive Discriminative Feature Learning
% Copyright (c) 2016, Shun Zhang

% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.
% ---------------------------------------------------------------

%global alpha_p; global alpha_a; global alpha_s;
pos_ri = window{ri(1)}.location(ri(2),:);
size_ri = window{ri(1)}.size(ri(2),:);
appr_ri = window{ri(1)}.appearance(ri(2),:);
pos_rj = window{rj(1)}.location(rj(2),:);
size_rj = window{rj(1)}.size(rj(2),:);
appr_rj = window{rj(1)}.appearance(rj(2),:);

Apos=normDistance(pos_ri,pos_rj,sigma_p,2);
ApMu=1;
Aappr=1-chi_square(appr_ri,appr_rj);
AaMu=1;
Asize=normDistance(size_ri,size_rj,sigma_s,2);
AsMu=1;
res = 0.45*Apos+0.45*Aappr+0.1*Asize;
mu = 1;
