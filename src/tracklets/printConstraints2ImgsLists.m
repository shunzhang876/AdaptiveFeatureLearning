function printConstraints2ImgsLists(projInfo,smallBox,...
    must_link_list,not_link_list,output_dir,write)

%load context/smallBox.mat
%load dets/tracks_Tara_face.mat
rand('seed',0);
warning off;
% write = 1;

img_dir = projInfo.imgDir;
% out_dir = [projInfo.resDir,'_patches/'];
out_dir1 = [output_dir,'linkImages/'];
out_dir2 = [output_dir,'linkImages/'];
if exist(out_dir1,'dir')~=7
    mkdir(out_dir1);
else
    if write
        unix(['rm -rf ',out_dir1]);
        mkdir(out_dir1);
    end
end

disp('Printing patches of linkImages...');
must_link_list = writePatch(must_link_list,smallBox,img_dir,out_dir1,write);
not_link_list = writePatch(not_link_list,smallBox,img_dir,out_dir1,write);

list_label = [ones(length(must_link_list),1); zeros(length(not_link_list),1)];
list_images = [must_link_list, not_link_list];

rnd_idx = randperm(length(list_label));
ratio = 0.8;
tr_num = round(ratio*length(list_label));

train_images = list_images(rnd_idx(1:tr_num));
test_images = list_images(rnd_idx(tr_num+1:end));
train_labels = list_label(rnd_idx(1:tr_num));
test_labels = list_label(rnd_idx(tr_num+1:end));

%%
file1 = [output_dir,'all_sim1.txt'];
fid1 = fopen(file1,'w');

for i=1:length(list_images)
    fprintf(fid1,'%s %d\n',list_images(i).img_name1, list_images(i).label1);
    fprintf(fid1,'%s %d\n',list_images(i).img_name2, list_images(i).label2);
end
fclose(fid1);


file1 = [output_dir,'train_sim1.txt'];
file2 = [output_dir,'train_sim2.txt'];
fid1 = fopen(file1,'w');
fid2 = fopen(file2,'w');
for i=1:length(train_images)
    fprintf(fid1,'%s %d\n',train_images(i).img_name1, train_labels(i));%train_images(i).label1, 
    fprintf(fid2,'%s %d\n',train_images(i).img_name2, train_labels(i));%train_images(i).label2,
end
fclose(fid1);
fclose(fid2);

file1 = [output_dir,'val_sim1.txt'];
file2 = [output_dir,'val_sim2.txt'];
fid1 = fopen(file1,'w');
fid2 = fopen(file2,'w');
for i=1:length(test_images)
    fprintf(fid1,'%s %d\n',test_images(i).img_name1, test_labels(i));%test_images(i).label1, 
    fprintf(fid2,'%s %d\n',test_images(i).img_name2, test_labels(i));%test_images(i).label2, 
end
fclose(fid1);
fclose(fid2);

getImgLabel(output_dir);

%%
function list = writePatch(list,smallBox,img_dir,out_dir,write)

list(1).img_name1 = [];
% pool1 = cell(length(list),1);
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
parfor i=1:length(list)
    frame = list(i).frame1;
    node = list(i).node1;
%     box = smallBox(frame).box(node,:);
    label = list(i).label1;
    name = smallBox(frame).name;%[num2str(frame,'%05d'),'.jpg'];
    new_name = [num2str(frame,'%05d'),'_',num2str(node),'_label',num2str(label),'.jpg'];
    list(i).img_name1 = [out_dir,new_name];
    
    f_b(i) = frame;
    n_b(i) = node;
    l_b(i) = label;
    %flag(frame).sel(node) = 1;
%     pool1{i} = new_name;
end
for i=1:length(f_b)
    flag(f_b(i)).sel(n_b(i)) = 1;
    smallBox(f_b(i)).label(n_b(i)) = l_b(i);
end


list(1).img_name2 = [];
% pool2 = cell(length(list),1);
f_b = zeros(length(list),1);
n_b = zeros(length(list),1);
l_b = zeros(length(list),1);
parfor i=1:length(list)
    frame = list(i).frame2;
    node = list(i).node2;
%     box = smallBox(frame).box(node,:);
    label = list(i).label2;
    name = smallBox(frame).name; %name = [num2str(frame,'%05d'),'.jpg'];
    new_name = [num2str(frame,'%05d'),'_',num2str(node),'_label',num2str(label),'.jpg'];
    list(i).img_name2 = [out_dir,new_name];
    
    f_b(i) = frame;
    n_b(i) = node;
    l_b(i) = label;
    %flag(frame).sel(node) = 1;
%     pool2{i} = new_name;
end
for i=1:length(f_b)
    flag(f_b(i)).sel(n_b(i)) = 1;
    smallBox(f_b(i)).label(n_b(i)) = l_b(i);
end

% write
if write
    disp('--Imwriting patches...');
    tic;
    parfor i=1:length(flag)
        for j=1:smallBox(i).num
            if flag(i).sel(j)
                frame = i;
                node = j;
                name = smallBox(frame).name; %name = [num2str(frame,'%05d'),'.jpg'];
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
    % disp('--Imwriting patches done...');
end