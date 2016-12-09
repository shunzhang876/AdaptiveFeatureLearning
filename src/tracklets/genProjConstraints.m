function projInfo = genProjConstraints(projInfo,print,run)
% projInfo = genProjConstraints(projInfo,print,run)
% ---------------------------------------------------------------
% Adaptive Discriminative Feature Learning
% Copyright (c) 2016, Shun Zhang

% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.
% ---------------------------------------------------------------

if ~run
    return;
end

%%
nclusters = projInfo.nbclusters;
img_dir = projInfo.imgDir;

%%
res = projInfo.faceDets.res;
trajs = projInfo.trajs; 
len = length(trajs.frameNums);
nObj = length(trajs.obj_id);
trajMatrix = trajs.trajMatrix;

%% must not link pairs
mNLink = zeros(nObj,nObj);
if 1
    for i=1:len
        nNodes = find(trajs.trajMatrix(i,:)>0);
        if isempty(nNodes), continue; end;
        [A,B] = meshgrid(nNodes,nNodes);
        C = [A(:) B(:)];
        for j=1:size(C,1)
            if C(j,1)==C(j,2), continue; end
            mNLink(C(j,1),C(j,2)) = 1;
        end
    end
end

%% randperm face tracks
rndFaceTrckMat = 'rndpermFaceTrck.mat';
if 1
    face_tracks = [];
    for i=1:nObj
        id = i;
        frame_idx1 = find(trajMatrix(:,id));
        sel_idx = randperm(length(frame_idx1));
        face_track1 = frame_idx1(sel_idx);
        
        face_tracks{i} = face_track1;
    end
end


%% generate obvious constraints
method = projInfo.method_conts;

extract_num = 10;
if strcmp(projInfo.network_loss,'Triplet')
    switch method
        case 'trcks'
            [trip_a, trip_p, trip_n] = ...
               constTriplet(nObj,mNLink,face_tracks,extract_num,projInfo);
            fprintf('Number of Triplets: %d\n',length(trip_a));
            printTriplet2PatchList(projInfo,res,trip_a,trip_p,trip_n,print);
            return;
    end
end
