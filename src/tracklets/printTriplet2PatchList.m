function printTriplet2PatchList(projInfo,res,trip_a,trip_p,trip_n,write)
% printTriplet2PatchList(projInfo,detections,trip_a,trip_p,trip_n,write)
% ---------------------------------------------------------------
% Adaptive Discriminative Feature Learning
% Copyright (c) 2016, Shun Zhang

% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.
% ---------------------------------------------------------------

output_dir = projInfo.myResDir;
img_dir = projInfo.imgDir;

out_dir1 = [output_dir,'trpImgs/'];
if exist(out_dir1,'dir')~=7
    mkdir(out_dir1);
else
    if write
        unix(['rm -rf ',out_dir1]);
        mkdir(out_dir1);
    end
end

%% load res
smallBox = res;
for i=1:length(smallBox)
    smallBox(i).box = res(i).boxes; % scaleBox(faceBoxes(i).box,scale,722,1282);
end

disp('Printing patches of trpImages...');
triplet = [trip_a, trip_p, trip_n];
list = writePatch(triplet,smallBox,img_dir,out_dir1,write);
num = length(trip_a);
trip_a = list(1:num);
trip_p = list(num+1:2*num);
trip_n = list(2*num+1:3*num);

rnd_idx = randperm(num);
ratio = 0.8;
tr_num = round(ratio*num);

train_a = trip_a(rnd_idx(1:tr_num));
train_p = trip_p(rnd_idx(1:tr_num));
train_n = trip_n(rnd_idx(1:tr_num));
val_a = trip_a(rnd_idx(tr_num+1:end));
val_p = trip_p(rnd_idx(tr_num+1:end));
val_n = trip_n(rnd_idx(tr_num+1:end));

file1 = [output_dir,'train_sim1.txt'];
file2 = [output_dir,'train_sim2.txt'];
file3 = [output_dir,'train_sim3.txt'];
fid1 = fopen(file1,'w');
fid2 = fopen(file2,'w');
fid3 = fopen(file3,'w');
for i=1:length(train_a)
    fprintf(fid1,'%s %d\n',train_a(i).img_name, 1);
    fprintf(fid2,'%s %d\n',train_p(i).img_name, 1);
    fprintf(fid3,'%s %d\n',train_n(i).img_name, 1);
end
fclose(fid1);
fclose(fid2);
fclose(fid3);

file1 = [output_dir,'val_sim1.txt'];
file2 = [output_dir,'val_sim2.txt'];
file3 = [output_dir,'val_sim3.txt'];
fid1 = fopen(file1,'w');
fid2 = fopen(file2,'w');
fid3 = fopen(file3,'w');
for i=1:length(val_a)
    fprintf(fid1,'%s %d\n',val_a(i).img_name, 1);
    fprintf(fid2,'%s %d\n',val_p(i).img_name, 1);
    fprintf(fid3,'%s %d\n',val_n(i).img_name, 1);
end
fclose(fid1);
fclose(fid2);
fclose(fid3);

save([output_dir,'trp.mat'],'train_a','train_p','train_n','val_a','val_p','val_n');

getImgLabels(output_dir);


%%
function list = writePatch(list,smallBox,img_dir,out_dir,write)

list(1).img_name = [];

flag = [];
flag(length(smallBox)).sel = [];
for i=1:numel(flag)
    if smallBox(i).num>0
        flag(i).sel = zeros(smallBox(i).num,1);
    end
end
for i=1:length(smallBox)
    idx = findstr(smallBox(i).im,'/');
    smallBox(i).name = smallBox(i).im(idx(end)+1:end);
end
f_b = zeros(length(list),1);
n_b = zeros(length(list),1);
l_b = zeros(length(list),1);
num_list = length(list);
tic;
parfor i=1:length(list)
    if mod(i-1,500000)==0
        fprintf('list-%d/%d\n',i,num_list);
    end
    frame = list(i).frame;
    node = list(i).node;
    label = list(i).label;
    name = smallBox(frame).name;
    new_name = [num2str(frame,'%05d'),'_',num2str(node),'_label',num2str(label),'.jpg'];
    list(i).img_name = [out_dir,new_name];
    
    f_b(i) = frame;
    n_b(i) = node;
    l_b(i) = label;
end
toc;
for i=1:length(f_b)
    flag(f_b(i)).sel(n_b(i)) = 1;
    smallBox(f_b(i)).label(n_b(i)) = l_b(i);
end

% write
if write
    disp('--Imwriting patches...');
    tic;
    parfor i=1:length(flag)
        if mod(i,5000)==0
            fprintf('flag-%d/%d\n',i,length(flag));
        end
        for j=1:smallBox(i).num
            if flag(i).sel(j)
                frame = i;
                node = j;
                name = smallBox(frame).name;
                label = smallBox(frame).label(node);
                box = smallBox(frame).box(node,:);
                box = floor(box);
                new_name = [num2str(frame,'%05d'),'_',num2str(node),'_label',num2str(label),'.jpg'];
                
                im = imread([img_dir,name]);
                patch = im(box(2):box(4),box(1):box(3),:);
                imwrite(patch,[out_dir,new_name]);
            end
        end
    end
    toc;
end


function getImgLabels(output_dir)

pwd_path = pwd;
cd(output_dir);

folder = 'trpImgs';
dir_folder = dir([folder,'/*.jpg']);
img_set = [];
cnt = 0;
for i=3:length(dir_folder)
    idx = findstr(dir_folder(i).name,'.jpg');
    cnt = cnt+1;
    img_set{cnt} = [folder,'/',dir_folder(i).name];
end

%% get labels
labels = [];
fprintf('All links: %d\n',length(img_set));
for i=1:length(img_set)
    name = img_set{i};
    idx = findstr(name,'label');
    idx2 = findstr(name,'.jpg');
    labels(i) = str2double(name(idx+5:idx2-1));
end

%% print
file = 'imgs_list.txt';
fid = fopen(file,'w');
for i=1:length(img_set)
    fprintf(fid,'%s %d\n',[pwd,'/',img_set{i}],labels(i));
end
fclose(fid);

cd(pwd_path);
