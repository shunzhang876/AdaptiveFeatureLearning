function ExtFeasFromCaffeModel_2nd_run(projInfo,fea_set)
% ExtFeasFromCaffeModel_2nd_run(projInfo,fea_set)
% ---------------------------------------------------------------
% Adaptive Discriminative Feature Learning
% Copyright (c) 2016, Shun Zhang

% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.
% ---------------------------------------------------------------

caffemodel = [];

% fea_set = {'HOG','AlexNet','PreTrain','VGG-Face','AdaptTriplet'};
disp('clustering...');

for i=1:length(fea_set)
    projInfo.fea.feaDir = [projInfo.myResDir,'_feaAP/'];
    projInfo.fea.img_list = [projInfo.resDir,'imgs_list.txt'];
    fea_method = fea_set{i};
    
    scores_HAC(projInfo,fea_method);
end

disp('clustering finished');
