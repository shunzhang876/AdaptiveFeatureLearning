function projInfo = labelDets(projInfo,display)
% projInfo = labelDets(projInfo,en_display)
% ---------------------------------------------------------------
% Adaptive Discriminative Feature Learning
% Copyright (c) 2016, Shun Zhang

% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.
% ---------------------------------------------------------------

if nargin<2
    display = 0;
end

res = projInfo.faceDets.res;
gt_bbs = projInfo.faceDets.gt_bbs;

%% scale res boxes
scaleXY = projInfo.faceDets.scaleXY;
scaleX = scaleXY(1);
scaleY = scaleXY(2);
img_f1 = imread(res(1).im);
[width,height,~] = size(img_f1);
for i=1:length(res)
    bbox = res(i).boxes;
    if ~isempty(res(i).boxes)
        for j=1:size(bbox,1)
            % bbox(j,:) = crop_patch(img_f1, bbox(j,:), 'square', crop_size, padding);
            box = bbox(j,:);
            x=box(1); y=box(2);
            w=box(3)-box(1); h=box(4)-box(2);
            xc=x+w/2; yc=y+h/2;
            nw=scaleX*w; nh=scaleY*h;
            box(1)=xc-nw/2; %x1
            box(3)=xc+nw/2; %x2
            box(2)=yc-nh/2; %y1
            box(4)=yc+nh/2; %y2
            
            box(1) = max(box(1),1);
            box(2) = max(box(2),1);
            box(3) = min(box(3),height);
            box(4) = min(box(4),width);
            bbox(j,:) = box;
        end
    end
    res(i).boxes = bbox;
end


%% label all face candidates
%disp('Get labels of face candidates...');
disp('Label Detections...');
for i=1:length(res)
    if isempty(res(i).boxes)
        projInfo.faceDets.res(i).label = [];
        continue;
    end
    
    box = res(i).boxes(:,1:4);
    projInfo.faceDets.res(i).label = zeros(size(box,1),1); % 0-neg, 1-6 label
    for ii=1:size(box,1)
        overlap = zeros(length(gt_bbs),1);
        for jj=1:length(gt_bbs)
            bbs = gt_bbs{jj}(i,:);
            if bbs(3)==0 && bbs(4)==0
                overlap(jj) = 0;
            else
                overlap(jj) = computeOverlap(box(ii,:),bbs);
            end
        end
        [val,idx] = max(overlap);
        if val>0.4
            projInfo.faceDets.res(i).label(ii) = idx;
        end
    end
end

% display label figures
if display
    for i=1:length(res)
        fprintf('%d/%d\n',i,length(res));
        res(i).im = [img_dir,num2str(i,'%04d'),'.jpg'];
        if isempty(res(i).boxes)
            res(i).label = [];
            continue;
        end
        
        im = imread(res(i).im);
        box = floor(res(i).boxes(:,1:4));
        for j=1:size(box,1)
            patch = im(box(j,2):box(j,4),box(j,1):box(j,3),:);
            label = res(i).label(j);
            imwrite(patch,['res/',num2str(label),'/',num2str(i,'%04d'),num2str(j),'.jpg']);
        end
    end
end
