function Ts = genLinkedTs(projInfo,out_dir,fea_mat,thr)
% Ts = genLinkedTs(projInfo,out_dir,fea_mat,thr)
% ---------------------------------------------------------------
% Adaptive Discriminative Feature Learning
% Copyright (c) 2016, Shun Zhang

% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.
% ---------------------------------------------------------------

if nargin<4
    thr = 0.3;
end

%%
load(fea_mat);
res = projInfo.faceDets.res;
trajs = projInfo.trajs;
nObj = length(trajs.obj_id);
len = length(trajs.frameNums);

mNLink = zeros(nObj,nObj);
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

%%
TsInit = [];
for i=1:nObj
    idx = find(trajs.trajMatrix(:,i));
    
    TsInit(i).id = i;
    TsInit(i).im = [];
    TsInit(i).num = 0;
    TsInit(i).frame = [];
    TsInit(i).nodes = [];
    TsInit(i).boxes = [];
    TsInit(i).gt_id = [];
    
    for j=1:length(idx)
        frame = idx(j);
        idTrcks1 = res(frame).idTrck;
        idx2 = find(idTrcks1==i);
        
        TsInit(i).im{j,1} = [projInfo.resDir,'_patches/',res(frame).patches{idx2}];
        TsInit(i).num = TsInit(i).num+1;
        TsInit(i).frame = [TsInit(i).frame;frame];
        TsInit(i).nodes = [TsInit(i).nodes;idx2];
        TsInit(i).boxes = [TsInit(i).boxes;res(frame).boxesOrig(idx2,:)];
        TsInit(i).gt_id = [TsInit(i).gt_id; res(frame).label(idx2,:)];
    end
end

%%
idx = find(pair(:,3)<thr);
pair_idx = pair(idx,:);

if isempty(idx)
    Ts = [];
    disp('Error: pair is empty!!');
    return;
end

Ts = TsInit;
for i=1:length(pair_idx)
    if mNLink(pair_idx(i,1),pair_idx(i,2))
        disp(['must-not-link pair: - ',num2str(i),' - ',...
            num2str(pair_idx(i,1)),' ',num2str(pair_idx(i,2))]);
        continue;
    end
    Ts = mergeTs(Ts,pair_idx(i,1),pair_idx(i,2));
end

printOutXml(projInfo,out_dir,Ts,TsInit);


%%
function Ts = mergeTs(Ts,ni,nj)

Ts(ni).id = [Ts(ni).id;Ts(nj).id];
Ts(ni).im = [Ts(ni).im;Ts(nj).im];
Ts(ni).num = Ts(ni).num+Ts(nj).num;
Ts(ni).frame = [Ts(ni).frame;Ts(nj).frame];
Ts(ni).nodes = [Ts(ni).nodes;Ts(nj).nodes];
Ts(ni).gt_id = [Ts(ni).gt_id;Ts(nj).gt_id];

Ts(nj).id = [];
Ts(nj).im = [];
Ts(nj).num = 0;
Ts(nj).frame = [];
Ts(nj).nodes = [];
Ts(nj).gt_id = [];
