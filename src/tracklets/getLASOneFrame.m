function [loc,appr,wsize] = getLASOneFrame(path,m,ObjectNums,name,dets)
% [loc,appr,wsize] = getLASOneFrame(img_path,nBins,nDets,img_name,detections)
% ---------------------------------------------------------------
% Adaptive Discriminative Feature Learning
% Copyright (c) 2016, Shun Zhang

% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.
% ---------------------------------------------------------------

loc = [];
appr = [];
wsize = [];

if ObjectNums<=0
    return;
end

img = imread([path name]);
for i=1:ObjectNums
    x1 = floor(dets(i,1));
    y1 = floor(dets(i,2));
    x2 = floor(dets(i,3));
    y2 = floor(dets(i,4));
    loc(i,:) = [(x1+x2)/2, (y1+y2)/2];
    [w,h,s] = size(img);
    if(y1<1), y1=1;  end;
    if(x1<1), x1=1;  end;
    if(y2>w), y2=w; end;
    if(x2>h), x2=h; end;
    imgRect = img(y1:y2,x1:x2,:);
    if(0)
        u = getAppearance(imgRect,m);
        appr(i,:) = u;
    else
        if(0)
            u1 = (imhist(imgRect(:,:,1),m))';
            u2 = (imhist(imgRect(:,:,2),m))';
            u3 = (imhist(imgRect(:,:,3),m))';
            u = [u1 u2 u3];
        else
            Lab_bins = [m m m];
            image_lab=imgRect;
            image_lab=double(image_lab);
            R = image_lab(:,:,1); G = image_lab(:,:,2); B = image_lab(:,:,3);
            rr = min(floor(R/(255/Lab_bins(1))) + 1, Lab_bins(1));
            gg = min(floor(G/(255/Lab_bins(2))) + 1, Lab_bins(2));
            bb = min(floor(B/(255/Lab_bins(3))) + 1, Lab_bins(3));
            Q = (rr-1) * Lab_bins(2) * Lab_bins(3) + (gg-1) * Lab_bins(3) + bb + 1;
            [w,h] = size(Q);QQ = reshape(Q,1,w*h);
            [u,bin]=hist(QQ, 1:prod(Lab_bins));
        end;
        appr(i,:) = normalize_vector(u);
    end;
    wsize(i,:) = [x2-x1 y2-y1];
end
