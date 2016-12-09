function projInfo = labelTracks(projInfo,display)
% projInfo = labelTracks(projINfo,display)
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
trajs = projInfo.trajs;
nclusters = projInfo.nbclusters;

%%
disp('Label tracks...');
len = length(trajs.frameNums);
nObj = length(trajs.obj_id);
trajMatrix = trajs.trajMatrix;

labels = zeros(len,nObj);
isRect = sum(trajMatrix,2);
idx = find(isRect);
for i=1:length(idx)
    nNodes = find(trajMatrix(idx(i),:));
    
    for ii=1:length(nNodes)
        x = trajs.X(idx(i),nNodes(ii));
        y = trajs.Y(idx(i),nNodes(ii));
        w = trajs.W(idx(i),nNodes(ii));
        h = trajs.H(idx(i),nNodes(ii));
        box = [x,y,x+w,y+h];        
        
        overlap = zeros(nclusters,1);
        for jj=1:nclusters
            bbs = gt_bbs{jj}(idx(i),:);
            if bbs(3)==0 && bbs(4)==0
                overlap(jj) = 0;
            else
                overlap(jj) = computeOverlap(box,bbs);
            end
        end
        [val,ind] = max(overlap);
        if val>0.4
            labels(idx(i),nNodes(ii)) = ind;
        end
    end
end

% disp('label tracks');
trajs.labels = zeros(nObj,1);
for i=1:nObj
    count = zeros(nclusters,1);
    for j=1:nclusters
        ind = find(labels(:,i)==j);
        count(j) = sum(ind);
    end
    [val,ind] = max(count);
    if val==0
        continue;
    end
    trajs.labels(i) = ind;
end

projInfo.trajs = trajs;
