function [window,trcletsInfo] = genShortTrcletsFaces(img_path,window,res,para)
% [window,tracklet_information] = genShortTrcletsFaces(img_path,window,detections,para)
% ---------------------------------------------------------------
% Adaptive Discriminative Feature Learning
% Copyright (c) 2016, Shun Zhang

% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.
% ---------------------------------------------------------------

global nBins theta1 theta2 sigma_p sigma_s theta3 theta4

skip_probable_link = para(1);
skip_computTrclets = para(2);

%% generate trajectories
allDets = cell(length(window),1);
for frame=1:length(window)
    dets = [];
    nNodes = window{frame}.nNodes;
    if ~isempty(nNodes)
        dets_id = [frame*ones(nNodes,1),(1:nNodes)'];
    end
    allDets{frame} = dets_id;
end
toLinkDets = cell2mat(allDets);

%%
%disp(['-- Generate Linkable Pairs --'])
if(~skip_probable_link)
    %tic
    link = cell(getRow(toLinkDets),1);
    parfor i=1:getRow(toLinkDets)
        ri = toLinkDets(i,:);
        ind=find(toLinkDets(:,1)==ri(1)+1);
        for j=1:length(ind)
            rj = toLinkDets(ind(j),:);
            [Plink_ij,mu] = computeLink(ri,rj,window,sigma_p,sigma_s);
            link{i}{j}.ri = ri;
            link{i}{j}.rj = rj;
            link{i}{j}.prob = Plink_ij;
        end
    end
    
    ct = 0;
    temp = cell(length(link),1);
    for i=1:length(link)
        num = length(link{i});
        if num>0
            temp(ct+1:ct+num) = link{i};
            ct = ct+num;
        end
    end
    link = temp;
    
    a = [];
    n=1;
    for k=1:length(link)
        if isempty(link{k}), continue; end
        Plink_ij = link{k}.prob;
        if(Plink_ij>=theta1)
            a(n,:) = [link{k}.ri,link{k}.rj,link{k}.prob];
            n = n+1;
        end
    end
    link = a;

else
    %load(['mat/',name,'_link.mat'],'link');
end
%disp(['-- ',num2str(length(link)),'pairs '])

%disp(['-- Two-Threshold Linking --'])
if ~skip_computTrclets
    minDist = cell(getRow(link),1);
    parfor k=1:getRow(link)
        ri = link(k,1:2);
        rj = link(k,3:4);
        Plink_ij = link(k,5);
        if(Plink_ij<theta1)
            continue;
        end;
        minDist{k} = theta1;
        
        % rk==ri
        ind = find(link(:,1)==ri(1));
        for kk=1:length(ind)
            rk = link(ind(kk),1:2);
            prob = link(ind(kk),5);
            if(k~=ind(kk) && rk(2)==ri(2))
                temp = Plink_ij - prob;
                if(temp<minDist{k})
                    minDist{k} = temp;
                end
            end
        end
        
        % rk==rj
        ind = find(link(:,3)==rj(1));
        for kk=1:length(ind)
            rk = link(ind(kk),3:4);
            prob = link(ind(kk),5);
            if(k~=ind(kk) && rk(2)==rj(2))
                temp = Plink_ij - prob;
                if(temp<minDist{k})
                    minDist{k} = temp;
                end;
            end
        end
    end
    
    tracklets = [];
    ct =1;
    for k=1:getRow(link)
        if(minDist{k}>theta2)
            tracklets(ct,:) = link(k,:);
            ct = ct+1;
        end
    end
    %
    trcletsInfo = [];
    for i=1:getRow(tracklets)
        trcletsInfo{i}.num = 1;
        trcletsInfo{i}.ri = tracklets(i,1:2);
        trcletsInfo{i}.rj = tracklets(i,3:4);
        trcletsInfo{i}.traj = [tracklets(i,1:2); tracklets(i,3:4)];
    end;
    
    changeRate = 1;
    while(1)
        [trcletsInfo,tracklets,changeRate] = linkConsecutiveFrame(trcletsInfo,tracklets);
        if(changeRate==0)
            break;
        end;
    end;
else
    %load(['mat/',name,'_trclets.mat'],'tracklets');
    %load(['mat/',name,'_trcletsInfo.mat'],'trcletsInfo');
end

%% link some tracklets that are similar and concecutive
link_1st = link;
tracklets_1st = tracklets;
trcletsInfo_1st = trcletsInfo;

pair2 = [];
link2 = [];
ct = 1;
%disp(['-- Link Probable Trclets in 3 frames --'])
for i=1:getRow(tracklets)
    rj = tracklets(i,3:4);
    ind = find(tracklets(:,1)<=rj(1)+3);
    if isempty(ind) continue; end
    temp = tracklets(ind,:);
    ind2 = find(temp(:,1)>rj(1));
    if isempty(ind2) continue; end
    trlet = tracklets(ind(ind2),:);
    for j=1:getRow(trlet)
        [Plink_ij mu] = computeLink(rj,trlet(j,1:2),window,sigma_p,sigma_s);
        if(Plink_ij>=theta3)
            link2(ct,:) = [tracklets(i,:),tracklets(ind(ind2(j)),:),Plink_ij;];
            link2_idx(ct,:) = [i,ind(ind2(j))];
            ct = ct+1;
        end
    end
end

minDist = cell(getRow(link2),1);
parfor i=1:getRow(link2)
    ri = link2(i,3:4);
    rj = link2(i,6:7);
    Plink_ij = link2(i,end);
    
    minDist{i} = theta3;
    
    % rk==ri
    ind = find(link2(:,3)==ri(1));
    for kk=1:length(ind)
        rk = link2(ind(kk),3:4);
        prob = link2(ind(kk),end);
        if(i~=ind(kk) && rk(2)==ri(2))
            temp = Plink_ij - prob;
            if(temp<minDist{i})
                minDist{i} = temp;
            end;
        end
    end
    
    % rk==rj
    ind = find(link2(:,6)==rj(1));
    for kk=1:length(ind)
        rk = link2(ind(kk),6:7);
        prob = link2(ind(kk),end);
        if(i~=ind(kk) && rk(2)==rj(2))
            temp = Plink_ij - prob;
            if(temp<minDist{i})
                minDist{i} = temp;
            end;
        end
    end
end

ct=1;
tracklets2 = [];
tracklets2_idx = [];
for i=1:getRow(link2)
    if(minDist{i}>theta4)
        tracklets2(ct,:) = link2(i,:);
        tracklets2_idx(ct,:) = link2_idx(i,:);
        ct = ct+1;
    end;
end

trcletsInfo2 = trcletsInfo_1st; 
lens = length(trcletsInfo2);
for i=1:lens
    if isempty(tracklets2_idx)
        continue;
    end
    ii = lens-i+1;
    ind = find(tracklets2_idx(:,2)==ii);
    if ~isempty(ind)
        id1 = tracklets2_idx(ind,1);
        id2 = tracklets2_idx(ind,2);
        trclet1 = trcletsInfo2{id1};
        trclet2 = trcletsInfo2{id2};
        nMiss = trclet2.ri(1)-trclet1.rj(1)-1;
        traj_miss = [];
        for j=1:nMiss
            traj_miss(j,:) = [trclet1.rj(1)+j,0];
        end
        
        trcletsInfo2{id1}.num = trclet1.num+nMiss+trclet2.num;
        trcletsInfo2{id1}.ri = trclet1.ri;
        trcletsInfo2{id1}.rj = trclet2.rj;
        trcletsInfo2{id1}.traj = [trclet1.traj; traj_miss; trclet2.traj];
        trcletsInfo2(id2) = [];
    end
end

trcletsInfo = trcletsInfo2;
lens = length(trcletsInfo);

para = [sigma_p,sigma_s,theta1,theta2,theta3];
trcletsInfo = linkMultiFrames(tracklets2,trcletsInfo,window,6);
trcletsInfo = linkMultiFrames(tracklets2,trcletsInfo,window,6);
trcletsInfo = linkMultiFrames(tracklets2,trcletsInfo,window,8);
trcletsInfo = linkMultiFrames(tracklets2,trcletsInfo,window,8);
trcletsInfo = linkMultiFrames(tracklets2,trcletsInfo,window,10);
trcletsInfo = linkMultiFrames(tracklets2,trcletsInfo,window,10);
trcletsInfo = linkMultiFrames(tracklets2,trcletsInfo,window,15);
trcletsInfo = linkMultiFrames(tracklets2,trcletsInfo,window,15);
trcletsInfo = linkMultiFrames(tracklets2,trcletsInfo,window,20);
trcletsInfo = linkMultiFrames(tracklets2,trcletsInfo,window,20);
