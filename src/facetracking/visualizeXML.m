function visualizeXML(projInfo,out_dir)

outFile = [out_dir,'out_',projInfo.network_loss,'_spVideo.xml'];
stateInfo = readXMLE(outFile);

out_dir = [projInfo.myResDir,'sp_video/'];
mkdir_if_missing(out_dir);

res = projInfo.faceDets.res;
ext = 12;
for frame= 1:size(stateInfo.W,1)
    name = res(frame).im;
    img = imread(name);
    imshow(img);
    text(50,50,['#',num2str(frame)],'Color','w','FontSize',50);
    if ~exist('width','var')
        [width,height,~] = size(img);
    end
    
    
    idx = find(stateInfo.W(frame,:)>0);
    addr = [];
    for j=idx
        xi = stateInfo.Xi(frame,j);
        yi = stateInfo.Yi(frame,j);
        w = stateInfo.W(frame,j);
        h = stateInfo.H(frame,j);
        x1 = stateInfo.Xi(frame,j)-w/2;
        y1 = stateInfo.Yi(frame,j)-h;
        x2 = x1+w; y2 = y1+h;
        
        col = getColorFromID(j);
        
        if 1
        x1 = max(x1-ext,1);
        y1 = max(y1-ext,1);
        x2 = min(x2+ext,height);
        y2 = min(y2+ext,width);
        rectangle('Position',[x1,y1,x2-x1,y2-y1],...
                'EdgeColor',col,'LineWidth',10);
            text(double(x1),double(y1-45),num2str(j),...
                'Color',col,'FontSize',50);
        else
            x11 = max(x1-ext,1);
            y11 = max(y1-ext,1);
            x21 = min(x2+ext,height);
            y21 = min(y2+ext,width);
            
            x12 = max(x1,1);
            y12 = max(y1,1);
            x22 = min(x2,height);
            y22 = min(y2,width);
            
            color = col*255;
            for k=1:3
                img(y11:y12,x11:x21,k) = color(k);
                img(y22:y21,x11:x21,k) = color(k);
                img(y11:y21,x11:x12,k) = color(k);
                img(y12:y22,x22:x21,k) = color(k);
            end
            
            for k=1:3
                img(y11:y11+2,x11:x21,k) = 255;
                img(y12-2:y12,x12:x22,k) = 255;
                
                img(y22:y22+2,x12:x22,k) = 255;
                img(y21-2:y21,x11:x21,k) = 255;
                
                img(y11:y21,x11:x11+2,k) = 255;
                img(y12:y22,x12-2:x12,k) = 255;
                
                img(y12:y22,x22:x22+2,k) = 255;
                img(y11:y21,x21-2:x21,k) = 255;
            end
            imshow(img);
            addr(j,1:2) = [x1,y1];
        end
    end
    
    title(['#',num2str(frame),'-',name]);
    F1 = getframe;
    imwrite(F1.cdata,[out_dir,name(end-7:end)]);
end

%% 
function stateInfo = readXMLE(file)
fdoc=importdata(file);
Video=fdoc.getFirstChild;
start_frame=str2num(Video.getAttribute('start_frame'));
end_frame=str2num(Video.getAttribute('end_frame'));
Trajectory=Video.getElementsByTagName('Trajectory');
TLength=Trajectory.getLength;
stateInfo.frameNums=start_frame:end_frame;
stateInfo.Xi=zeros(end_frame-start_frame+1,TLength);
stateInfo.Yi=zeros(end_frame-start_frame+1,TLength);
stateInfo.H=zeros(end_frame-start_frame+1,TLength);
stateInfo.W=zeros(end_frame-start_frame+1,TLength);
for i=0:TLength-1
    Tstart=str2num(Trajectory.item(i).getAttribute('start_frame'));
    Tend=str2num(Trajectory.item(i).getAttribute('end_frame'));
    Frame=Trajectory.item(i).getElementsByTagName('Frame');
    for j=0:Frame.getLength-1
        xx=str2num(Frame.item(j).getAttribute('x'));
        yy=str2num(Frame.item(j).getAttribute('y'));
        ww=str2num(Frame.item(j).getAttribute('width'));
        hh=str2num(Frame.item(j).getAttribute('height'));
        frame_no=str2num(Frame.item(j).getAttribute('frame_no'));
        stateInfo.Xi(frame_no-start_frame+1,i+1)=xx+0.5*ww;
        stateInfo.Yi(frame_no-start_frame+1,i+1)=yy+hh;
        stateInfo.W(frame_no-start_frame+1,i+1)=ww;
        stateInfo.H(frame_no-start_frame+1,i+1)=hh;
    end
end
