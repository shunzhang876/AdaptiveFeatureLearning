function genTracklet(dataset)
% genTracklet(dataset)
% Eg. genTracklet('Tara')
% ---------------------------------------------------------------
% Adaptive Discriminative Feature Learning
% Copyright (c) 2016, Shun Zhang

% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.
% ---------------------------------------------------------------

% main_demo
% 0- load dets
% 1- face track
% 2- generate constraints
% 3- finetune network
% 4- recompute features
% 5- spectral clustering
% 6- result visualization

close all;
addpath(genpath('src'));

% parameters
initPara;

disp('---------- Load Face Detections ----------');
projInfo = loadDemoDets(projInfo);

%
disp('---------- Form Face Track ----------');
projInfo = formFaceTrack(projInfo,1,0,1);                   % gen_win, display, run 
projInfo = deleteDets(projInfo);

%%
disp('---------- Generate Patches ----------');
projInfo = labelDets(projInfo);
projInfo = labelTracks(projInfo);
projInfo = genPatchesList(projInfo,1);                    % write

% 
projInfo.fea.feaDir = [projInfo.myResDir,'_feaAP/'];
projInfo.fea.img_list = [projInfo.resDir,'imgs_list.txt'];

%%
disp('---------- Generate Constraints ----------');
projInfo = genProjConstraints(projInfo,1,1);                % print_patches, run

save([projInfo.myResDir,'projInfo1.mat'],'projInfo');

%disp('---------- Mission Completed! ----------');
