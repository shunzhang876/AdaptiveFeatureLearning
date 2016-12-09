function evalMTTthrCurves(projInfo)

projInfo.fea.feaDir = [projInfo.myResDir,'_feaAP/'];
fea_method = 'FineTune';
disp([fea_method,'-fc8 eval MTT metrics...']);
out_dir = [projInfo.fea.feaDir,fea_method,'/'];
fea_mat = [projInfo.fea.feaDir,fea_method,'/cluster_purity_fc8','.mat'];
Ts = genLinkedTs1(projInfo,out_dir,fea_mat,0.3);

function Ts=genLinkedTs1(projInfo,out_dir,fea_mat,thr)

% def: thr = 0.3;
if nargin<4
    thr = 0.3;
end

load(fea_mat);
%%
res = projInfo.faceDets.res;
trajs = projInfo.trajs;
nObj = length(trajs.obj_id);
len = length(trajs.frameNums);

mNLink = zeros(nObj,nObj);
for i=1:len
    nNodes = find(trajs.trajMatrix(i,:)>0);
    if isempty(nNodes), continue; end;
    [A,B] = meshgrid(nNodes,nNodes);
    C = [A(:) B(:)];
    for j=1:size(C,1)
        if C(j,1)==C(j,2), continue; end
        mNLink(C(j,1),C(j,2)) = 1;
    end
end

%%
TsInit = [];
for i=1:nObj
    idx = find(trajs.trajMatrix(:,i));
    
    TsInit(i).id = i;
    TsInit(i).im = [];
    TsInit(i).num = 0;
    TsInit(i).frame = [];
    TsInit(i).nodes = [];
    TsInit(i).boxes = [];
    % TsInit(i).feas = [];
    TsInit(i).gt_id = [];
    
    for j=1:length(idx)
        frame = idx(j);
        idTrcks1 = res(frame).idTrck;
        idx2 = find(idTrcks1==i);
        % fea = res(frame).fea(idx2,:);
        
        TsInit(i).im{j,1} = [projInfo.resDir,'_patches/',res(frame).patches{idx2}];
        TsInit(i).num = TsInit(i).num+1;
        TsInit(i).frame = [TsInit(i).frame;frame];
        TsInit(i).nodes = [TsInit(i).nodes;idx2];
        TsInit(i).boxes = [TsInit(i).boxes;res(frame).boxesOrig(idx2,:)];
        % TsInit(i).feas = [TsInit(i).feas;fea];
        TsInit(i).gt_id = [TsInit(i).gt_id; res(frame).label(idx2,:)];
    end
end

%%
% idx = find(pair(:,3)<thr);
% pair_idx = pair(idx,:);
pair_idx = pair;

if isempty(idx)
    Ts = [];
    disp('Error: pair is empty!!');
    return;
end

% metrics=[recall, precision, FAR, Ngt, MT, PT, ML, fp_n, missDets_n, idswitches, FRA, MOTA, MOTP, MOTAL];
global metrics_HAC num_pair gt_st
num_pair = 0;
metrics_HAC = [];
gt_st = [];

Ts = TsInit;
for i=1:3:length(pair_idx)
    fprintf('%s: %d/%d...\n',projInfo.video_name,i,length(pair_idx));
    if mNLink(pair_idx(i,1),pair_idx(i,2))
        disp(['must-not-link pair: - ',num2str(i),' - ',...
            num2str(pair_idx(i,1)),' ',num2str(pair_idx(i,2))]);
        continue;
    end
    Ts = mergeTs(Ts,pair_idx(i,1),pair_idx(i,2));
    
    num_pair = i;
    metrics_HAC{num_pair} = [];
    %if i>197
    printOutXml1(projInfo,out_dir,Ts,TsInit);
    %end
end

save([out_dir,'metrics_HAC.mat'],'metrics_HAC');
%%
if 0
    out_dir = [projInfo.myResDir,'FinalTrajs/'];
    mkdir_if_missing(out_dir);
    obj_id = 0;
    for i=1:nObj
        if Ts(i).num==0
            continue;
        end
        fprintf('%d/%d\n',i,nObj);
        obj_id = obj_id+1;
        out_dir_sub = [out_dir,num2str(obj_id,'%02d'),'/'];
        mkdir_if_missing(out_dir_sub);
        
        cout = 0;
        for j=1:length(Ts(i).id)
            trck_id = Ts(i).id(j);
            trck_num = TsInit(trck_id).num;
            for k=1:trck_num
                st = k;%cout+k;
                src = TsInit(trck_id).im{st};
                ind = findstr(src,'/');
                name = [num2str(trck_id,'%03d'),'_',src(ind(end)+1:end)];
                dst = [out_dir_sub,name];
                copyfile(src,dst);
            end
        end
        disp('next');
        %     pause;
    end
end


%%
function Ts = mergeTs(Ts,ni,nj)

Ts(ni).id = [Ts(ni).id;Ts(nj).id];
Ts(ni).im = [Ts(ni).im;Ts(nj).im];
Ts(ni).num = Ts(ni).num+Ts(nj).num;
Ts(ni).frame = [Ts(ni).frame;Ts(nj).frame];
Ts(ni).nodes = [Ts(ni).nodes;Ts(nj).nodes];
% Ts(ni).feas = [Ts(ni).feas;Ts(nj).feas];
Ts(ni).gt_id = [Ts(ni).gt_id;Ts(nj).gt_id];

Ts(nj).id = [];
Ts(nj).im = [];
Ts(nj).num = 0;
Ts(nj).frame = [];
Ts(nj).nodes = [];
% Ts(nj).feas = [];
Ts(nj).gt_id = [];


function printOutXml1(projInfo,out_dir,Ts,TsInit)

res = projInfo.faceDets.res;
et_f = length(res);
nObj = length(Ts);

%% print tracklet xml
% %%
% start_frame = 1;
% end_frame = et_f;
% if ~exist([out_dir,'MOT_HAC/'],'dir')
%     mkdir([out_dir,'MOT_HAC/']);
% end
% outFile = [out_dir,'MOT_HAC/out_',projInfo.network_loss,'_trcklet.xml'];
% 
% InitFrame = 0;
% disp(['Print ','out_',projInfo.network_loss,'_trcklet.xml...']);
% fid=fopen(outFile,'w');
% fprintf(fid,'<?xml version = "1.0"?>\n');
% fprintf(fid,'<Video fname="%s" start_frame="%d" end_frame="%d">\n',...
%     ['out_',projInfo.network_loss,'_trcklet.xml'],start_frame+InitFrame,end_frame+InitFrame);
% obj_id = 0;
% for i=1:nObj
%     if TsInit(i).num==0
%         continue;
%     end
%     fprintf('%d/%d\n',i,nObj);
%     obj_id = i;%obj_id+1;
%     
%     trck_ids = sort(TsInit(i).id,'ascend');
%     start_frame = TsInit(trck_ids(1)).frame(1);
%     end_frame = TsInit(trck_ids(end)).frame(end);
%     
%     fprintf(fid,...
%         '  <Trajectory obj_id="%d" start_frame="%d" end_frame="%d">\n',...
%         obj_id,start_frame+InitFrame,end_frame+InitFrame);
%     
%     for ii=1:length(trck_ids)   
%         frameIdx = TsInit(trck_ids(ii)).frame;
%         boxes = TsInit(trck_ids(ii)).boxes;
%         for j=1:length(frameIdx)
%             x = boxes(j,1);
%             y = boxes(j,2);
%             width = boxes(j,3)-x;
%             height = boxes(j,4)-y;
%             
%             fprintf(fid,'		<Frame frame_no="%d" x="%d" y="%d" width="%d" height="%d" observation="%d"></Frame>\n',...
%                 frameIdx(j)+InitFrame,floor(x),floor(y),floor(width),floor(height),1);
%         end;
%     end
%     fprintf(fid,'	</Trajectory>\n');
% end;
% fprintf(fid,'</Video>');
% fclose(fid);
% 
% evalTrajs(projInfo,out_dir,outFile);

%% print final xml
start_frame = 1;
end_frame = et_f;
outFile = [out_dir,'MOT_HAC/out_',projInfo.network_loss,'.xml'];
if ~exist([out_dir,'MOT_HAC/'],'dir')
    mkdir([out_dir,'MOT_HAC/']);
end

InitFrame = 0;
disp(['Print ','out_',projInfo.network_loss,'.xml...']);
fid=fopen(outFile,'w');
fprintf(fid,'<?xml version = "1.0"?>\n');
fprintf(fid,'<Video fname="%s" start_frame="%d" end_frame="%d">\n',...
    ['out_',projInfo.network_loss,'.xml'],start_frame+InitFrame,end_frame+InitFrame);

obj_id = 0;
for i=1:nObj
    if Ts(i).num==0
        continue;
    end
    %fprintf('%d/%d\n',i,nObj);
    obj_id = i;%obj_id+1;
    
    trck_ids = sort(Ts(i).id,'ascend');
    start_frame = TsInit(trck_ids(1)).frame(1);
    end_frame = TsInit(trck_ids(end)).frame(end);
    
    fprintf(fid,...
        '  <Trajectory obj_id="%d" start_frame="%d" end_frame="%d">\n',...
        obj_id,start_frame+InitFrame,end_frame+InitFrame);
    
    for ii=1:length(trck_ids)   
        frameIdx = TsInit(trck_ids(ii)).frame;
        boxes = TsInit(trck_ids(ii)).boxes;
        for j=1:length(frameIdx)
            x = boxes(j,1);
            y = boxes(j,2);
            width = boxes(j,3)-x;
            height = boxes(j,4)-y;
            
            fprintf(fid,'		<Frame frame_no="%d" x="%d" y="%d" width="%d" height="%d" observation="%d"></Frame>\n',...
                frameIdx(j)+InitFrame,floor(x),floor(y),floor(width),floor(height),1);
        end;
    end
    fprintf(fid,'	</Trajectory>\n');
end;
fprintf(fid,'</Video>');
fclose(fid);

evalTrajs(projInfo,out_dir,outFile);

% %% add miss detections
% for i=1:nObj
%     frames = TsInit(i).frame;
%     boxes = TsInit(i).boxes;
%     TsInit(i).missFr = [];
%     TsInit(i).missBB = [];
%     for j=1:length(frames)
%         if j==1 || frames(j)-frames(j-1)==1
%             continue;
%         else
%            preFr = frames(j-1);
%            preX = boxes(j-1,1);
%            preY = boxes(j-1,2);
%            preW = boxes(j-1,3)-preX;
%            preH = boxes(j-1,4)-preY;
%            preXi = preX+preW/2;
%            preYi = preY+preH/2;
%            
%            nexFr = frames(j);
%            nexX = boxes(j,1);
%            nexY = boxes(j,2);
%            nexW = boxes(j,3)-nexX;
%            nexH = boxes(j,4)-nexY;
%            nexXi = nexX+nexW/2;
%            nexYi = nexY+nexH/2;
%            
%            gap = nexFr-preFr;
%            stepXY = ([nexXi, nexYi]-[preXi, preYi])./gap;
%            stepWH = ([nexW, nexH]-[preW, preH])./gap;
%            
%            missFr = preFr+1:1:nexFr-1;
%            missFr = reshape(missFr,[],1);
%            missBB = [];
%            TsInit(i).missFr = [TsInit(i).missFr;missFr];
%            for k=1:length(missFr)
%                dictFr = missFr(k);
%                dictXY = stepXY*k+[preXi,preYi];
%                dictWH = stepWH*k+[preW,preH];
%                
%                dictX1Y1 = dictXY-dictWH/2;
%                missBB(k,1) = dictX1Y1(1);
%                missBB(k,2) = dictX1Y1(2);
%                missBB(k,3) = dictX1Y1(1)+dictWH(1);
%                missBB(k,4) = dictX1Y1(2)+dictWH(2);
%            end
%            TsInit(i).missBB = [TsInit(i).missBB;missBB];
%         end
%     end
% end
% 
% %%
% start_frame = 1;
% end_frame = et_f;
% outFile = [out_dir,'MOT_HAC/out_',projInfo.network_loss,'_delShort_miss.xml'];
% 
% InitFrame = 0;
% disp(['Print ','out_',projInfo.network_loss,'_delShort_miss.xml...']);
% fid=fopen(outFile,'w');
% fprintf(fid,'<?xml version = "1.0"?>\n');
% fprintf(fid,'<Video fname="%s" start_frame="%d" end_frame="%d">\n',...
%     ['out_',projInfo.network_loss,'_delShort_miss.xml'],start_frame+InitFrame,end_frame+InitFrame);
% 
% obj_id = 0;
% for i=1:nObj
%     if Ts(i).num==0 || Ts(i).num<30
%         continue;
%     end
%     fprintf('%d/%d\n',i,nObj);
%     obj_id = i;%obj_id+1;
%     
%     trck_ids = sort(Ts(i).id,'ascend');
%     start_frame = TsInit(trck_ids(1)).frame(1);
%     end_frame = TsInit(trck_ids(end)).frame(end);
%     
%     fprintf(fid,...
%         '  <Trajectory obj_id="%d" start_frame="%d" end_frame="%d">\n',...
%         obj_id,start_frame+InitFrame,end_frame+InitFrame);
%     
%     for ii=1:length(trck_ids)   
%         frame1 = TsInit(trck_ids(ii)).frame;
%         boxes1 = TsInit(trck_ids(ii)).boxes;
%         frame2 = TsInit(trck_ids(ii)).missFr;
%         boxes2 = TsInit(trck_ids(ii)).missBB;
%         
%         frame12 = [frame1;frame2];
%         boxes12 = [boxes1;boxes2];
%         [frameIdx,Idx12] = sort(frame12,'ascend');
%         boxes = boxes12(Idx12,:);
%         
%         for j=1:length(frameIdx)
%             x = boxes(j,1);
%             y = boxes(j,2);
%             width = boxes(j,3)-x;
%             height = boxes(j,4)-y;
%             
%             fprintf(fid,'		<Frame frame_no="%d" x="%d" y="%d" width="%d" height="%d" observation="%d"></Frame>\n',...
%                 frameIdx(j)+InitFrame,floor(x),floor(y),floor(width),floor(height),1);
%         end;
%     end
%     fprintf(fid,'	</Trajectory>\n');
% end;
% fprintf(fid,'</Video>');
% fclose(fid);
% 
% evalTrajs(projInfo,out_dir,outFile);