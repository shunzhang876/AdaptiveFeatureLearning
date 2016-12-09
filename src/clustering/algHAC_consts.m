function [pair,purity] = algHAC_consts(projInfo,feas,nTrajs,nbclusters,labels)
% [pair,purity] = algHAC_consts(projInfo,feas,nTrajs,nClusters,gt_labels)
% ---------------------------------------------------------------
% Adaptive Discriminative Feature Learning
% Copyright (c) 2016, Shun Zhang

% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.
% ---------------------------------------------------------------

res = projInfo.faceDets.res;

cnt = 0;
for i=1:length(res)
    if isempty(res(i).boxes)
        continue;
    end
    num = size(res(i).boxes,1);
    res(i).fea = feas(cnt+1:cnt+num,:);
    cnt = cnt+num;
end


trajs = projInfo.trajs;
trajMatrix = trajs.trajMatrix;
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
    idx = find(trajMatrix(:,i));
    
    TsInit(i).id = i;
    TsInit(i).im = [];
    TsInit(i).num = 0;
    TsInit(i).frame = [];
    TsInit(i).nodes = [];
    TsInit(i).boxes = [];
    TsInit(i).feas = [];
    TsInit(i).gt_id = [];
    
    for j=1:length(idx)
        frame = idx(j);
        idTrcks1 = res(frame).idTrck;
        idx2 = find(idTrcks1==i);
        fea = res(frame).fea(idx2,:);
        
        TsInit(i).im{j,1} = [projInfo.resDir,'_patches/',res(frame).patches{idx2}];
        TsInit(i).num = TsInit(i).num+1;
        TsInit(i).frame = [TsInit(i).frame;frame];
        TsInit(i).nodes = [TsInit(i).nodes;idx2];
        TsInit(i).boxes = [TsInit(i).boxes;res(frame).boxesOrig(idx2,:)];
        TsInit(i).feas = [TsInit(i).feas;fea];
        TsInit(i).gt_id = [TsInit(i).gt_id; res(frame).label(idx2,:)];
    end   
end

purity = zeros(nObj,1);
purity(nObj) = compPurity(TsInit);

%%
thr = 99999;

pair = [];
flag = 0;
pre_num = [];
cout = 0;
Ts = TsInit;
dist = zeros(nObj,nObj);
while flag==0
    [Ts,pair,dist,pre_num,flag] = compDist(Ts,nObj,dist,pair,pre_num,mNLink);
    if flag==0
        cout = cout+1;
        purity(nObj-cout) = compPurity(Ts);
        fprintf('(%d-- (%d,%d: %.4f)\n',cout,pair(end,1),pair(end,2), pair(end,3));
    end
end
pair;


%%
function [Ts,pair,dist,pre_num,flag] = compDist(Ts,nObj,dist,pair,pre_num,mNLink)

if isempty(pair)
    parfor i=1:nObj
        if mod(i,50)==0
            fprintf('%d/%d\n',i,nObj);
        end
        num = Ts(i).num;
        
        for j=1:nObj
            col = Ts(j).num;
            
            if i==j || num==0 || col==0
                dist(i,j) = Inf;
                continue;
            end
            
            X = [Ts(i).feas;Ts(j).feas];
            [nn,kk] = size(X);
            tmp = sum(X.*X,2);
            tmp = repmat(tmp,1,nn);
            matrix = -2*X*X' + tmp + tmp';
            
            num = Ts(i).num;
            col = Ts(j).num;
            s_p = zeros(col,1);
            for k=1:num
                s_p = s_p+matrix(num+1:end,k);
            end
            dist(i,j) = sum(s_p)/num/col;
        end
    end
else
    pair_id = pair(end,1:2);
    for ii=[1,2]
        i = pair_id(ii);
        num = Ts(i).num;
        
        for j=1:nObj
            col = Ts(j).num;
            
            if i==j || num==0 || col==0
                dist(i,j) = Inf;
                dist(j,i) = Inf;
                continue;
            end
            
            d1 = dist(pair_id(1),j);
            d2 = dist(pair_id(2),j);
            N1 = pre_num(1);
            N2 = Ts(j).num;
            N3 = pre_num(2);
            
            dist(i,j) = (N1*N2*d1+N3*N2*d2)/(N1+N3)/N2;
            dist(j,i) = dist(i,j);
            
        end
        
    end
end

%%
if isempty(pair)
    for i=1:size(mNLink,1)
        idx = find(mNLink(:,i));
        if ~isempty(idx)
            dist(idx,i) = Inf;
        end
    end
end

%%
[valA,idxR] = min(dist);
[valB,idxC] = min(valA);

if dist(idxR(idxC),idxC)==Inf
    flag = 1;
    return;
else
    flag = 0;
    if idxR(idxC)<idxC
        pair = [pair; idxR(idxC),idxC,dist(idxR(idxC),idxC)];
    else
        pair = [pair; idxC,idxR(idxC),dist(idxR(idxC),idxC)];
    end
    pre_num = [];
    pre_num(1) = Ts(pair(end,1)).num;
    pre_num(2) = Ts(pair(end,2)).num;
    Ts = mergeTs(Ts,pair(end,1),pair(end,2));
end


%%
function Ts = mergeTs(Ts,ni,nj)

Ts(ni).id = [Ts(ni).id;Ts(nj).id];
Ts(ni).im = [Ts(ni).im;Ts(nj).im];
Ts(ni).num = Ts(ni).num+Ts(nj).num;
Ts(ni).frame = [Ts(ni).frame;Ts(nj).frame];
Ts(ni).nodes = [Ts(ni).nodes;Ts(nj).nodes];
Ts(ni).feas = [Ts(ni).feas;Ts(nj).feas];
Ts(ni).gt_id = [Ts(ni).gt_id;Ts(nj).gt_id];

Ts(nj).id = [];
Ts(nj).im = [];
Ts(nj).num = 0;
Ts(nj).frame = [];
Ts(nj).nodes = [];
Ts(nj).feas = [];
Ts(nj).gt_id = [];
