function projInfo = formFaceTrack(projInfo,run_load_detsfile,display,run)
% project_information = formFaceTrack(projInfo,en_load_detsfile,display,en)
% ---------------------------------------------------------------
% Adaptive Discriminative Feature Learning
% Copyright (c) 2016, Shun Zhang

% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.
% ---------------------------------------------------------------

% two parts
% 1. link detections into short trclets
% 2. link short trclets into long trajectory

if ~run
    load([projInfo.resDir,'mat/face_tracks.mat'],'trajs');
    load([projInfo.resDir,'mat/res_faceDets_Refine.mat'],'res');
    projInfo.faceDets.resOrig = projInfo.faceDets.res;
    projInfo.faceDets.res = res;
    projInfo.trajs = trajs;
    projInfo = linkTrcks2Res(projInfo,res,trajs.trcletsInfo);
    return;
end

warning('off');
% if(matlabpool('size')<=0)
%     matlabpool('open',4);
% end
% matlabpool close

%% parameters
global video_start video_end dataset_name nBins
global alpha_p alpha_a alpha_s sigma_p sigma_s
global theta1 theta2 theta3 theta4

dataset_name = projInfo.video_name; 
imgTestDir = projInfo.imgDir;
typeID = 2; 
ext = '.xml';
skip_probable_link = 0;
skip_computTrclets = 0;
skip_link_dets = 0;

nBins = 10;
enBMMF = 0;
enShow = 0; 
timegap = 30;

theta1 = 0.6; theta2 = 0.2;
theta3 = 0.7; theta4 = 0.3;
sigma_p = [20,20];
sigma_s = [20,20];
alpha_p = 50;
alpha_a = 0.01;
alpha_s = 50;
pos_ri = ones(1,2);
appr_ri = ones(1,3*nBins);
size_ri = ones(1,2);
ApMu = mvnpdf(pos_ri,pos_ri,alpha_p*eye(2));
AaMu = mvnpdf(appr_ri,appr_ri,alpha_a*eye(length(appr_ri)));
AsMu = mvnpdf(size_ri,size_ri,alpha_s*eye(2));
mu = 1;

load(projInfo.sceneShots);
% delete some detections with high overlap
if 1
    res = projInfo.faceDets.res;
    res = refineDets(res);
    save([projInfo.resDir,'mat/res_faceDets_Refine.mat'],'res');
    projInfo.faceDets.resOrig = projInfo.faceDets.res;
    projInfo.faceDets.res = res;
end

outXml = ['tracklet/',dataset_name,'_',num2str(typeID),'_ShortTrclets.xml'];
finalXml = ['tracklet/',dataset_name,'_',num2str(typeID),'_Trajectories.xml'];
finalTxt = ['tracklet/',dataset_name,'_',num2str(typeID),'_Trajectories.txt'];

% if ~exist('tracklet/'), mkdir('tracklet/'); end
% if ~exist('mat/'), mkdir('mat/'); end

img_path = imgTestDir;
video_start = 1;
video_end = length(res);

%% link detections into short trcklets
disp(['********** link detections into short trcklets  **********'])
para_skip = [skip_probable_link,skip_computTrclets];
    
if (run_load_detsfile)
    image = cell(length(res),1);
    for i=1:length(res)
        idx = findstr(res(i).im,'/');
        image{i}.name = res(i).im(idx(end)+1:end);
        image{i}.framenum = i-1;
        image{i}.nNodes = size(res(i).boxes,1);
        image{i}.detection = res(i).boxes;
    end
    
    window = image;
    
    tic;
    window = getLAS(window, nBins, img_path);
    toc;
    save([projInfo.resDir,'mat/',dataset_name,'_win.mat'],'window');
else
    load([projInfo.resDir,'mat/',dataset_name,'_win.mat'],'window');
end

st = 1;
trcletsInfo = [];
for i=1:length(idxSceneChange)
    et = idxSceneChange(i);
    if et>video_end
        disp('Error Scene Change Detections!!!')
        keyboard;
    end
    
    win = window(st:et);
    [~,trclets] = genShortTrcletsFaces(img_path,win,res,para_skip);
    if i>1
        for ii=1:length(trclets)
            trclets{ii}.ri(1) = trclets{ii}.ri(1)+st-1;
            trclets{ii}.rj(1) = trclets{ii}.rj(1)+st-1;
            trclets{ii}.traj(:,1) = trclets{ii}.traj(:,1)+st-1;
        end
    end
    trcletsInfo = [trcletsInfo, trclets];
    st = et+1;
end

%% delete some short trclets
len = length(trcletsInfo);
for i=1:len
    j=len-i+1;
    if trcletsInfo{j}.num<2
        trcletsInfo(j) = [];
    end
end

%% Display results
trajs = DisplayTrkletsFaces(img_path,dataset_name,window,trcletsInfo,projInfo,display);
projInfo.trajs = trajs;

projInfo = linkTrcks2Res(projInfo,res,trcletsInfo);
save([projInfo.resDir,'mat/face_tracks.mat'],'trajs');

disp(['********** Complete tracklet linking  **********'])
