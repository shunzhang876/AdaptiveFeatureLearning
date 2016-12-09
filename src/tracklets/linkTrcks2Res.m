function projInfo = linkTrcks2Res(projInfo,res,trcletsInfo)
% project_info = linkTrcks2Res(projInfo,detections,tracklet_info)
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
    num = size(res(i).boxes,1);
    res(i).num = num;
    if num
        res(i).idTrck = (-1)*ones(num,1);
    else
        res(i).idTrck = [];
    end
end

for id=1:length(trcletsInfo)
    traj = trcletsInfo{id}.traj;
    for i=1:size(traj,1)
        frame = traj(i,1);
        idx = traj(i,2);
        if idx==0, continue; end
        res(frame).idTrck(idx) = id;
    end
end

projInfo.faceDets.res = res;
