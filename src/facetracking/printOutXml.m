function printOutXml(projInfo,out_dir,Ts,TsInit)
% printOutXml(projInfo,out_dir,Ts,TsInit)
% ---------------------------------------------------------------
% Adaptive Discriminative Feature Learning
% Copyright (c) 2016, Shun Zhang

% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.
% ---------------------------------------------------------------

res = projInfo.faceDets.res;
et_f = length(res);
nObj = length(Ts);

%% add miss detections
for i=1:nObj
    frames = TsInit(i).frame;
    boxes = TsInit(i).boxes;
    TsInit(i).missFr = [];
    TsInit(i).missBB = [];
    for j=1:length(frames)
        if j==1 || frames(j)-frames(j-1)==1
            continue;
        else
           preFr = frames(j-1);
           preX = boxes(j-1,1);
           preY = boxes(j-1,2);
           preW = boxes(j-1,3)-preX;
           preH = boxes(j-1,4)-preY;
           preXi = preX+preW/2;
           preYi = preY+preH/2;
           
           nexFr = frames(j);
           nexX = boxes(j,1);
           nexY = boxes(j,2);
           nexW = boxes(j,3)-nexX;
           nexH = boxes(j,4)-nexY;
           nexXi = nexX+nexW/2;
           nexYi = nexY+nexH/2;
           
           gap = nexFr-preFr;
           stepXY = ([nexXi, nexYi]-[preXi, preYi])./gap;
           stepWH = ([nexW, nexH]-[preW, preH])./gap;
           
           missFr = preFr+1:1:nexFr-1;
           missFr = reshape(missFr,[],1);
           missBB = [];
           TsInit(i).missFr = [TsInit(i).missFr;missFr];
           for k=1:length(missFr)
               dictFr = missFr(k);
               dictXY = stepXY*k+[preXi,preYi];
               dictWH = stepWH*k+[preW,preH];
               
               dictX1Y1 = dictXY-dictWH/2;
               missBB(k,1) = dictX1Y1(1);
               missBB(k,2) = dictX1Y1(2);
               missBB(k,3) = dictX1Y1(1)+dictWH(1);
               missBB(k,4) = dictX1Y1(2)+dictWH(2);
           end
           TsInit(i).missBB = [TsInit(i).missBB;missBB];
        end
    end
end

%% print face tracking xml
start_frame = 1;
end_frame = et_f;
outFile = [out_dir,'out_',projInfo.network_loss,'_spVideo.xml'];

InitFrame = 0;
disp(['Print ','out_',projInfo.network_loss,'_spVideo.xml...']);
fid=fopen(outFile,'w');
fprintf(fid,'<?xml version = "1.0"?>\n');
fprintf(fid,'<Video fname="%s" start_frame="%d" end_frame="%d">\n',...
    ['out_',projInfo.network_loss,'_spVideo.xml'],start_frame+InitFrame,end_frame+InitFrame);

obj_id = 0;
for i=1:nObj
    if Ts(i).num==0 || Ts(i).num<100
        continue;
    end
    obj_id = obj_id+1;
    
    trck_ids = sort(Ts(i).id,'ascend');
    start_frame = TsInit(trck_ids(1)).frame(1);
    end_frame = TsInit(trck_ids(end)).frame(end);
    
    fprintf(fid,...
        '  <Trajectory obj_id="%d" start_frame="%d" end_frame="%d">\n',...
        obj_id,start_frame+InitFrame,end_frame+InitFrame);
    
    for ii=1:length(trck_ids)   
        frame1 = TsInit(trck_ids(ii)).frame;
        boxes1 = TsInit(trck_ids(ii)).boxes;
        frame2 = TsInit(trck_ids(ii)).missFr;
        boxes2 = TsInit(trck_ids(ii)).missBB;
        
        frame12 = [frame1;frame2];
        boxes12 = [boxes1;boxes2];
        gt_ids12 = [TsInit(trck_ids(ii)).gt_id; zeros(length(frame2),1) ];
        [frameIdx,Idx12] = sort(frame12,'ascend');
        boxes = boxes12(Idx12,:);
        gt_ids = gt_ids12(Idx12,:);
        
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
