function extractFea_HOG()
% extractFea_HOG()
% ---------------------------------------------------------------
% Adaptive Discriminative Feature Learning
% Copyright (c) 2016, Shun Zhang

% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.
% ---------------------------------------------------------------

addpath(genpath('src/'));
feaDir = '_FaceRes/Tara_HeadHunter/trcks_s2.2_Triplet/_feaAP/';

file = '_FaceRes/Tara_HeadHunter/imgs_list.txt';
    
images = getFileD(file);
    
feas = cell(length(images),1);
feats = zeros(length(images),4356);
parfor i=1:length(images)
   name = images(i).im;
   im = imread(name);
   imR = imresize(im,[100,100]);
   feas{i} = extractHOGFeatures(imR);
   feats(i,:) = feas{i};
end

mkdir_if_missing([feaDir,'/HOG/']);
save([feaDir,'HOG/','HOG.mat'],'feats');
end

%%
function images = getFileD(file)

images = [];
count = 0;

fid = fopen(file,'r');
while (1)
    data = fgets(fid);
    if(data==-1)
        break;
    end
    [name num] = divide_string(data);
    count = count+1;
    images(count).im = name;
    images(count).label = num;
end
fclose(fid);
end
