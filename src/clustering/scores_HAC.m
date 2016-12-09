function scores_HAC(projInfo,fea_method,en)
% scores_HAC(projInfo,fea_method,en)
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

%% prepare datas
nbclusters = projInfo.nbclusters;
res_path = projInfo.resDir;

%% load video feature and load label
imgs_list = projInfo.fea.img_list;

gt = importdata(imgs_list);
labels = gt.data;
nsample = length(labels);

projInfo.context.rnt = 1;
%%
if strcmp(fea_method,'HOG');
    disp('---Compute clustering of all tracklets by HOG...');
    load([projInfo.fea.feaDir,fea_method,'/HOG.mat']);
    feas = feats(1:nsample,:);
    dim = size(feas,2);
    data = feas';
    
    [pair,purity] = algHAC(projInfo,feas,length(projInfo.trajs.obj_id),nbclusters,labels);
    save([projInfo.fea.feaDir,fea_method,'/cluster_purity.mat'],'purity','pair');
end

%%
if ~strcmp(fea_method,'HOG') && ~strcmp(fea_method,'AdaptTriplet')
    disp(['---Compute clustering of all tracklets by ',fea_method,'...']);
    load([projInfo.fea.feaDir,fea_method,'/fc7.mat']);
    feas = feats(1:nsample,:);
    dim = size(feas,2);
    data = feas';
    
    [pair,purity] = algHAC(projInfo,feas,length(projInfo.trajs.obj_id),nbclusters,labels);
    save([projInfo.fea.feaDir,fea_method,'/cluster_purity_fc7.mat'],'purity','pair');
end


%%
if ~strcmp(fea_method,'HOG') && ~strcmp(fea_method,'AlexNet') && ...
        ~strcmp(fea_method,'PreTrain') && ~strcmp(fea_method,'VGG-Face')
    load([projInfo.fea.feaDir,fea_method,'/fc8.mat']);
    feas = feats(1:nsample,:);
    
    disp('---Compute clustering of all tracklets by the learned adaptive features...');
    data = feas';
    
    [pair,purity] = algHAC(projInfo,feas,length(projInfo.trajs.obj_id),nbclusters,labels);
    save([projInfo.fea.feaDir,fea_method,'/cluster_purity_fc8.mat'],'purity','pair');
end
