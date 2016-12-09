function trcletsInfo=linkMultiFrames(tracklets_bak,trcletsInfo,window,gap)
% trcletsInfo = linkMultiFrame(tracklets,trcletsInfo,window,timegap
% ---------------------------------------------------------------
% Adaptive Discriminative Feature Learning
% Copyright (c) 2016, Shun Zhang

% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.
% ---------------------------------------------------------------

% sigma_p = para(1);
% sigma_s = para(2);
% theta1 = para(3);
% theta2 = para(4);
% theta3 = para(5);
global nBins theta1 theta2 sigma_p sigma_s theta3 theta4

tracklets = [];
for i=1:length(trcletsInfo)
    ri = trcletsInfo{i}.ri;
    rj = trcletsInfo{i}.rj;
    tracklets(i,:) = [ri,rj];
end


pair2 = [];
link2 = [];
ct = 1;
%disp(['-- Link Probable Trclets in 3 frames --'])
for i=1:getRow(tracklets)
    rj = tracklets(i,3:4);
    ind = find(tracklets(:,1)<=rj(1)+gap);
    if isempty(ind) continue; end
    temp = tracklets(ind,:);
    ind2 = find(temp(:,1)>rj(1));
    if isempty(ind2) continue; end
    trlet = tracklets(ind(ind2),:);
    for j=1:getRow(trlet)
        [Plink_ij mu] = computeLink(rj,trlet(j,1:2),window,sigma_p,sigma_s);
        if(Plink_ij>=0.5) % theta3=0.7
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

trcletsInfo2 = trcletsInfo; 
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
