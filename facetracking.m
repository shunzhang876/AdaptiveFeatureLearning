function facetracking(dataset)
% facetracking(dataset_name)
% E.g., facetracking('Tara')
% ---------------------------------------------------------------
% Adaptive Discriminative Feature Learning
% Copyright (c) 2016, Shun Zhang

% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.
% ---------------------------------------------------------------

close all;

warning off;
addpath(genpath('src'));

% initialize parameters
initPara;
load([projInfo.myResDir,'projInfo1.mat']);

%%linking tracklets
projInfo.fea.feaDir = [projInfo.myResDir,'_feaAP/'];
projInfo.fea.img_list = [projInfo.resDir,'imgs_list.txt'];
fea_method = 'AdaptTriplet';
out_dir = [projInfo.fea.feaDir,fea_method,'/'];
fea_mat = [projInfo.fea.feaDir,fea_method,'/cluster_purity_fc8_consts','.mat'];

scores_HAC_consts(projInfo,fea_method);
Ts = genLinkedTs(projInfo,out_dir,fea_mat,5);

%% visualize tracking results
visualizeXML(projInfo,out_dir);
