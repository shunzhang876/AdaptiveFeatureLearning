function res = refineDets(res)
% refined_detections = refineDets(detections)
% ---------------------------------------------------------------
% Adaptive Discriminative Feature Learning
% Copyright (c) 2016, Shun Zhang

% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.
% ---------------------------------------------------------------

for i=1:length(res)
    bbs = res(i).boxes;
    if size(bbs,1)<=1
        continue;
    end
    
    flag = zeros(size(bbs,1),1);
    for j=1:size(bbs,1)-1
        bb1 = bbs(j,1:4);
        area1 = (bb1(3)-bb1(1))*(bb1(4)-bb1(2));
        for k=j+1:size(bbs,1)
            bb2 = bbs(k,1:4);
            area2 = (bb2(3)-bb2(1))*(bb2(4)-bb2(2));
            isect = boxIntersect(bb1(1),bb1(3),bb1(4),bb1(2),bb2(1),bb2(3),bb2(4),bb2(2));
            if isect/area1>0.6
                flag(j) = 1;
            elseif isect/area2>0.6
                flag(k) = 1;
            end
        end
    end
    
    idx = find(flag==0);
    res(i).boxes = res(i).boxes(idx,:);
    %res(i).label = res(i).label(idx);
    %res(i).fea = res(i).fea(idx,:);
end
