function clustering_tracklets(dataset)
% clustering_tracklets(dataset_name)
% E.g., clustering_tracklets('Tara')
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

addpath(genpath('src'))

% initialize parameters
initPara;
load([projInfo.myResDir,'projInfo1.mat']);

%% load all features
fea_set = {'HOG','AlexNet','PreTrain','VGG-Face','AdaptTriplet'};
ExtFeasFromCaffeModel_2nd_run(projInfo,fea_set);

%% visualize the clustering results
feaEvalFinal(projInfo);
