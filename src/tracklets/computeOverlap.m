function overlap = computeOverlap(bb1,bb2)
% overlap_ratio = computeOverlap(bb1,bb2)
% ---------------------------------------------------------------
% Adaptive Discriminative Feature Learning
% Copyright (c) 2016, Shun Zhang

% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.
% ---------------------------------------------------------------

% bb1 & bb2: [x1,y1,x2,y2]
overlap = 0;
col = min(bb1(3),bb2(3))-max(bb1(1),bb2(1));
if col<=0, return; end
row = min(bb1(4),bb2(4))-max(bb1(2),bb2(2));
if row<=0, return; end
intersection = row*col;
area1 = (bb1(3)-bb1(1))*(bb1(4)-bb1(2));
area2 = (bb2(3)-bb2(1))*(bb2(4)-bb2(2));
overlap = intersection/(area1+area2-intersection);
