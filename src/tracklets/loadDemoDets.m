function projInfo = loadDemoDets(projInfo,display)
% project_informaion = loadDemoDets(projInfor,display)
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
    display=0;
end

disp('Load Dets...');
switch projInfo.video_name
    case 'Tara'
        switch projInfo.method_face_det
            case 'HeadHunter'
                projInfo.faceDets.mat = 'dets/res_Tara_HeadHunter.mat';
                projInfo.faceDets.scaleXY = [1.1,1.4];
                projInfo.faceDets.thr = 0.08;
                img_dir = projInfo.imgDir;
                load(projInfo.faceDets.mat);
                
                for i=1:length(res)
                    res(i).im = [img_dir,num2str(i,'%05d'),'.jpg'];
                    for j=1:res(i).num
                        k = res(i).num-j+1;
                        if res(i).boxes(k,5)<projInfo.faceDets.thr
                            res(i).boxes(k,:) = [];
                        end
                    end
                    res(i).num = size(res(i).boxes,1);
                    if res(i).num>0
                        res(i).boxes(:,5) = [];
                    end
                end
                projInfo.faceDets.res = res;
        end
        projInfo.faceDets.gt_mat = [projInfo.currDir,'dets/gt_Tara/Tara_gt_bbs.mat'];
        projInfo.faceDets.gt_xml = [projInfo.currDir,'dets/gt_Tara/Tara_gt.xml'];
    
end

dets = projInfo.faceDets.res;
img_f1 = imread(dets(1).im);
[height,width,~] = size(img_f1);

for i=1:length(dets)
    bbox = dets(i).boxes;
    if isempty(bbox)
        continue;
    end
    
    idx = find(bbox(:,1)<1);
    if ~isempty(idx)
        dets(i).boxes(idx,1) = 1;
    end
    
    idx = find(bbox(:,2)<1);
    if ~isempty(idx)
        dets(i).boxes(idx,2) = 1;
    end
    
    idx = find(bbox(:,3)>width);
    if ~isempty(idx)
        dets(i).boxes(idx,3) = width;
    end
    
    idx = find(bbox(:,4)>height);
    if ~isempty(idx)
        dets(i).boxes(idx,4) = height;
    end
end
projInfo.faceDets.res = dets;

%% load gt_bbs;
load(projInfo.faceDets.gt_mat);
% gt_bbs = []
projInfo.faceDets.gt_bbs = gt_bbs;

%% transfer gt_bbs to gt_xml
if ~exist(projInfo.faceDets.gt_xml,'file')
    gt_xml = projInfo.faceDets.gt_xml;
    gt_bbs2xml(gt_bbs,gt_xml);
    gt_xml2mat(gt_xml);
end

% display detections
if display
    out_dir = [projInfo.resDir,'dets/'];
    mkdir(out_dir);
    for i=1:length(res)
        im = imread(res(i).im);
        imshow(im);
        
        for j=1:size(res(i).boxes,1)
            bb = res(i).boxes(j,:);
            bb(3) = bb(3)-bb(1);
            bb(4) = bb(4)-bb(2);
            rectangle('position',bb,'EdgeColor','r');
        end
        F1 = getframe;
        imwrite(F1.cdata,[out_dir,num2str(i),'.jpg']);
    end
end
