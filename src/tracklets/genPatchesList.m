function projInfo = genPatchesList(projInfo,write,display)
% projINfo = genPatchesList(projINfo,write,display)
% ---------------------------------------------------------------
% Adaptive Discriminative Feature Learning
% Copyright (c) 2016, Shun Zhang

% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.
% ---------------------------------------------------------------

if nargin<2
    write = 0;
end
if nargin<3
    display = 0;
end

crop_size = 227;
padding = 16;
scale = projInfo.scaleBox;

res = projInfo.faceDets.res;

img_f1 = imread(res(1).im);
[width,height,~] = size(img_f1);

disp('Scale boxes...');
for i=1:length(res)
    bbox = res(i).boxes;
    res(i).boxesOrig = res(i).boxes;
    if ~isempty(res(i).boxes)
        for j=1:size(bbox,1)
            bbox(j,:) = crop_patch(img_f1, bbox(j,:), 'square', crop_size, padding);
        end
        res(i).boxes = scaleBox(bbox,scale,width,height);
    end
end

if display
    disp('Display scaled dets...');
    out_dir = [projInfo.resDir,'_scaleDets/'];
    mkdir_if_missing(out_dir);
    
    for i=1:length(res)
        im = imread(res(i).im);
        imshow(im);
        title(['frame-',num2str(i)]);
        for j=1:size(res(i).boxes,1)
            bb = res(i).boxes(j,1:4);
            rectBox(bb,'r');
            text(double(bb(1)),double(bb(2)-10),num2str(j),...
                'Color','r','FontSize',25);
        end
        F1 = getframe;
        imwrite(F1.cdata,[out_dir,num2str(i,'%04d'),'.jpg']);
    end
end

%%
disp('Split Patches...');
out_dir = [projInfo.resDir,'_patches/'];

img_dir = projInfo.imgDir;
for i=1:length(res)
    bbs = res(i).boxes;
    res(i).patches = [];
    for node=1:size(bbs,1)
        box = floor(bbs(node,:));
        label = res(i).label(node);
        new_name = [num2str(i,'%05d'),'_',num2str(node),'_label',num2str(label),'.jpg'];
        res(i).patches{node} = new_name;
    end
end

if write
    if exist(out_dir,'dir')~=7
        mkdir(out_dir);
    else
        unix(['rm -rf ',out_dir]);
        mkdir(out_dir);
    end
    
    tic;
    parfor i=1:length(res)
        for j=1:res(i).num
            new_name = res(i).patches{j};
            box = floor(res(i).boxes(j,:));
            
            im = imread(res(i).im);
            patch = im(box(2):box(4),box(1):box(3),:);
            imwrite(patch,[out_dir,new_name]);
        end
    end
    toc;
end
projInfo.faceDets.res = res;

if write
    file = [projInfo.resDir,'imgs_list.txt'];
    fid = fopen(file,'w');
    for i=1:length(res)
        if isempty(res(i).boxes)
            continue;
        end
        for j=1:size(res(i).boxes,1)
            name = [projInfo.resDir,'_patches/',res(i).patches{j}];
            label = res(i).label(j);
            fprintf(fid,'%s %d\n',name,label);
        end
    end
    fclose(fid);
end
