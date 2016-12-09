% initialization
% ---------------------------------------------------------------
% Adaptive Discriminative Feature Learning
% Copyright (c) 2016, Shun Zhang

% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.
% ---------------------------------------------------------------

warning off;
% if(matlabpool('size')<=0)
%     matlabpool('open',10);
% end

%%
projInfo = [];
projInfo.video_name = [];
projInfo.method_face_det = 'HeadHunter';
projInfo.method_conts = 'trcks';
projInfo.method_feature = 'PreTrain';
projInfo.home = [pwd,'/'];
projInfo.imgDir = [];
projInfo.sceneShots = [];
projInfo.nbclusters = [];

%% 
switch dataset
    case 'Tara'
        projInfo.video_name = 'Tara';
        projInfo.imgDir = [projInfo.home,'data/Tara/'];
        projInfo.sceneShots = [projInfo.home,'dets/idxSceneChange_Tara.mat'];
        projInfo.context.ExtractNumOfTrckMustNot = 20;
        projInfo.context.ExtractNumOfTrckMust = 20;
        projInfo.network_loss = 'Triplet';
        projInfo.scaleBox = 2.2;
        projInfo.nbclusters = 6;
        projInfo.network_loss = 'Triplet';
        projInfo.scaleBox = 2.2;
        projInfo.nbclusters = 6;
end

%% init resutls path
projInfo.currDir = [projInfo.home];
projInfo.resDir = [projInfo.currDir,'_FaceRes/',...
    projInfo.video_name,'_',projInfo.method_face_det,'/'];
projInfo.myResDir = [projInfo.resDir,...
    projInfo.method_conts,'_s',num2str(projInfo.scaleBox),'_',projInfo.network_loss,'/'];
mkdir_if_missing(projInfo.myResDir);
mkdir_if_missing([projInfo.resDir,'mat']);
