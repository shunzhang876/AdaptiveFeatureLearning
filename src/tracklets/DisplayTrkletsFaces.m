function trajs = DisplayTrkletsFaces(img_path,dataset_name,window,trcletsInfo,projInfo,show)
% trajs = DisplayTrkletsFaces(img_path,dataset_name,window,trcletsInfo,projInfo,display)
% ---------------------------------------------------------------
% Adaptive Discriminative Feature Learning
% Copyright (c) 2016, Shun Zhang

% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.
% ---------------------------------------------------------------

global video_start video_end

if nargin<6
    show = 0;
end

output = [projInfo.resDir,dataset_name,'_trclets/'];
if exist(output,'dir')~=7
    mkdir(output);
end

%%
trajs = [];
trajs.img_dir = img_path;
TLength=length(trcletsInfo);
trajs.frameNums=video_start:1:video_end;
nFrame = length(trajs.frameNums);
trajs.X=zeros(nFrame,TLength);
trajs.Y=zeros(nFrame,TLength);
trajs.H=zeros(nFrame,TLength);
trajs.W=zeros(nFrame,TLength);
trajs.trajMatrix=zeros(nFrame,TLength);
trajs.L=zeros(TLength,1);
trajs.obj_id=zeros(TLength,1);
trajs.trcletsInfo = trcletsInfo;

obj_id = 0;
for i=1:length(trcletsInfo)
    ri = trcletsInfo{i}.ri;
    rj = trcletsInfo{i}.rj;
    st = (ri(1)-1)*2+video_start;
    et = (rj(1)-1)*2+video_start;
    obj_id = obj_id+1;
    
    trajs.obj_id(i)=obj_id;
    
    traj = trcletsInfo{i}.traj;
    
    trajs.L(i)=getRow(traj);
    
    for j=1:getRow(traj)
        id = traj(j,:);
        
        obser = id(2);
        nFrame = (id(1)-1)*1+video_start;
        if obser~=0
            x = window{id(1)}.detection(id(2),1);
            y = window{id(1)}.detection(id(2),2);
            width = window{id(1)}.detection(id(2),3)-window{id(1)}.detection(id(2),1);
            height = window{id(1)}.detection(id(2),4)-window{id(1)}.detection(id(2),2);

            trajs.X(id(1),i)=x;
            trajs.Y(id(1),i)=y;
            trajs.W(id(1),i)=width;
            trajs.H(id(1),i)=height;
            trajs.trajMatrix(id(1),i)=1;
        else
        end
    end
end

%% show images
if show
Otrajs = trajs;
ImgNum = (video_end-video_start)/1+1;
for i=1:ImgNum
    if(mod(i,10)==0) fprintf(1,'%d.',i); end
    if(mod(i,500)==0) fprintf(1,'\n'); end
    nNodes = find(trajs.trajMatrix(i,:)>0);
    if isempty(nNodes), continue; end;
    
    img_name = (i-1)*1+video_start;
    filename = [trajs.img_dir,window{i}.name];
    im = imread(filename);
    
    clf;
    axis equal;
    axis on;
    imagesc(im);
    title([num2str(img_name),'.jpg']);
    text(30,30,['#F',num2str(i)],'FontSize',10,'Color','y');
    
    for j=1:length(nNodes)
        obser = trajs.trajMatrix(i,nNodes(j));
        x1 = Otrajs.X(i,nNodes(j));
        y1 = Otrajs.Y(i,nNodes(j));
        x2 = Otrajs.X(i,nNodes(j))+Otrajs.W(i,nNodes(j));
        y2 = Otrajs.Y(i,nNodes(j))+Otrajs.H(i,nNodes(j));
        id = Otrajs.obj_id(nNodes(j));
        
        if obser==1
            line([x1 x1 x2 x2 x1]', [y1 y2 y2 y1 y1]', 'color',getColorFromID(id), 'linewidth', 3);
            text(x1,y1-10,num2str(id),'FontSize',18,'Color',getColorFromID(id));
        end
    end
    % visualize bbox
    F1 = getframe;
    imwrite(F1.cdata, [output,num2str(img_name,'%05d'),'.jpg']);
end
end
