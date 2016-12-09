function gt_xml2mat(gtFile)
% gt_xml2mat(gtFile)
% ---------------------------------------------------------------
% Adaptive Discriminative Feature Learning
% Copyright (c) 2016, Shun Zhang

% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.
% ---------------------------------------------------------------

%% 1- read gtInfo from xml;

disp('-- Read gt_xml and write gt_xml.mat ...');
gtFile_mat = [gtFile,'.mat'];
if ~exist(gtFile_mat,'file')
    fdoc=importdata(gtFile);
    Video=fdoc.getFirstChild;
    start_frame=str2num(Video.getAttribute('start_frame'));
    end_frame=str2num(Video.getAttribute('end_frame'));
    Trajectory=Video.getElementsByTagName('Trajectory');
    TLength=Trajectory.getLength;
    gtInfo.frameNums=start_frame:end_frame;
    gtInfo.X=zeros(end_frame-start_frame+1,TLength);
    gtInfo.Y=zeros(end_frame-start_frame+1,TLength);
    gtInfo.H=zeros(end_frame-start_frame+1,TLength);
    gtInfo.W=zeros(end_frame-start_frame+1,TLength);
    for i=0:TLength-1
        fprintf('%d/%d\n',i+1,TLength);
        Tstart=str2num(Trajectory.item(i).getAttribute('start_frame'));
        Tend=str2num(Trajectory.item(i).getAttribute('end_frame'));
        Frame=Trajectory.item(i).getElementsByTagName('Frame');
        num_f = Frame.getLength;
        
        xx  = zeros(num_f,1); yy = zeros(num_f,1);
        ww = zeros(num_f,1); hh = zeros(num_f,1);
        frame_no = zeros(num_f,1);
        for j=0:num_f-1
            xx(j+1)=str2num(Frame.item(j).getAttribute('x'));
            yy(j+1)=str2num(Frame.item(j).getAttribute('y'));
            ww(j+1)=str2num(Frame.item(j).getAttribute('width'));
            hh(j+1)=str2num(Frame.item(j).getAttribute('height'));
            frame_no(j+1)=str2num(Frame.item(j).getAttribute('frame_no'));
        end
        for j=0:num_f-1
            gtInfo.X(frame_no(j+1)-start_frame+1,i+1)=xx(j+1)+ww(j+1)/2;
            gtInfo.Y(frame_no(j+1)-start_frame+1,i+1)=yy(j+1)+hh(j+1);
            gtInfo.W(frame_no(j+1)-start_frame+1,i+1)=ww(j+1);
            gtInfo.H(frame_no(j+1)-start_frame+1,i+1)=hh(j+1);
        end
    end
    save(gtFile_mat,'gtInfo','TLength','start_frame','end_frame');
end
