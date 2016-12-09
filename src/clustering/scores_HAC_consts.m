function scores_HAC_consts(projInfo,fea_method,en)
% scores_HAC_consts(projInfo,fea_method,en)
% ---------------------------------------------------------------
% Adaptive Discriminative Feature Learning
% Copyright (c) 2016, Shun Zhang

% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.
% ---------------------------------------------------------------

if nargin<3
    en = 0;
end

%% parameters
nbclusters = projInfo.nbclusters;
res_path = projInfo.resDir;

%% load video feature and load label
imgs_list = projInfo.fea.img_list;

gt = importdata(imgs_list);
labels = gt.data;
nsample = length(labels);

%%
load([projInfo.fea.feaDir,fea_method,'/fc8.mat']);
feas = feats(1:nsample,:);
data = feas';
    
[pair,purity] = algHAC_consts(projInfo,feas,length(projInfo.trajs.obj_id),nbclusters,labels);
save([projInfo.fea.feaDir,fea_method,'/cluster_purity_fc8_consts.mat'],'purity','pair');
