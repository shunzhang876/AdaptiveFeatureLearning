function boxes = scaleBox(boxes,scale,width,height)
% boxes = scaleBox(boxes,scale,width,height)
% ---------------------------------------------------------------
% Adaptive Discriminative Feature Learning
% Copyright (c) 2016, Shun Zhang

% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.
% ---------------------------------------------------------------

% extend the box range
% box=[x1,y1,x2,y2]

for ii=1:size(boxes,1)
    box = boxes(ii,1:4);
    
    xc = (box(1)+box(3))/2;
    yc = (box(2)+box(4))/2;
    
    w = (box(3)-box(1))*scale;
    h = (box(4)-box(2))*scale;
    
    x1 = max(xc-w/2,1);
    y1 = max(yc-h/2,1);
    x2 = min(xc+w/2,height);
    y2 = min(yc+h/2,width);

    boxes(ii,1:4) = [x1,y1,x2,y2];
end
