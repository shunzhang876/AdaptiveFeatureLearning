function projInfo = deleteDets(projInfo)
% projInfo = deleteDets(projInfo)
% ---------------------------------------------------------------
% Adaptive Discriminative Feature Learning
% Copyright (c) 2016, Shun Zhang

% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.
% ---------------------------------------------------------------

disp('Delete detections that are not in tracks...');
res = projInfo.faceDets.res;
trajs = projInfo.trajs;

for frame=1:length(res)
    if isempty(res(frame).boxes)
        continue;
    end
    bbs = res(frame).boxes;
    nNode = find(trajs.W(frame,:));
    if length(nNode)==size(bbs,1), continue; end

    flag = zeros(size(bbs,1),1);
    for ii=1:size(bbs,1)
        bb1 = bbs(ii,1:4);
        for jj=1:length(nNode)
            bb2(1) = trajs.X(frame,nNode(jj));
            bb2(2) = trajs.Y(frame,nNode(jj));
            bb2(3) = trajs.W(frame,nNode(jj))+bb2(1);
            bb2(4) = trajs.H(frame,nNode(jj))+bb2(2);
            
            ov = computeOverlap(bb1,bb2);
            if ov==1
                flag(ii) = 1;
            end
        end
    end
    res(frame).boxes = res(frame).boxes(find(flag),:);
    res(frame).idTrck = res(frame).idTrck(find(flag),:);
    res(frame).num = size(res(frame).boxes,1);
%     res(frame).label = res(frame).label(find(flag),:);
end

cnt=0;
for i=1:length(res)
    cnt = cnt+size(res(i).boxes,1);
end

traj_n = sum(sum(trajs.trajMatrix));
if cnt~=traj_n
    disp('Delete dets has error!');
    keyboard;
end

projInfo.faceDets.resDets = projInfo.faceDets.res;
projInfo.faceDets.res = res;
