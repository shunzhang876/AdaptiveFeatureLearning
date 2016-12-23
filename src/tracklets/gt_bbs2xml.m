function gt_bbs2xml(gt_bbs,gt_xml)
% gt_bbs2xml(gt_bbs,gt_xml)
% ---------------------------------------------------------------
% Adaptive Discriminative Feature Learning
% Copyright (c) 2016, Shun Zhang

% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.
% ---------------------------------------------------------------

bbs = gt_bbs;

start_frame = 1;
end_frame = size(gt_bbs{1},1);
InitFrame = 0; %start_frame-1;

% gt_xml = ['Tara_gt','.xml'];
fid=fopen(gt_xml,'w');
fprintf(fid,'<?xml version = "1.0"?>\n');
fprintf(fid,'<Video fname="%s" start_frame="%d" end_frame="%d">\n',...
    'gt',start_frame+InitFrame,end_frame+InitFrame);

for i=1:length(bbs)
    if(isempty(bbs{i}))
        continue;
    end;
    idx = find(bbs{i}(:,3));
    
    start_frame = idx(1);
    end_frame = idx(end);
    obj_id = i;
    
    fprintf(fid,...
        '  <Trajectory obj_id="%d" start_frame="%d" end_frame="%d">\n',...
        obj_id,start_frame+InitFrame,end_frame+InitFrame);
    
    frameIdx = reshape(idx,1,[]);
    for j=frameIdx
        x = bbs{i}(j,1);
        y = bbs{i}(j,2);
        width = bbs{i}(j,3)-bbs{i}(j,1);
        height = bbs{i}(j,4)-bbs{i}(j,2);
        obser = 1;

        fprintf(fid,'		<Frame frame_no="%d" x="%d" y="%d" width="%d" height="%d" observation="%d"></Frame>\n',...
            j+InitFrame,floor(x),floor(y),floor(width),floor(height),obser);
    end;
    fprintf(fid,'	</Trajectory>\n');
end
fprintf(fid,'</Video>');
fclose(fid);
