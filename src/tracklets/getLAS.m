function outM = getLAS(window, m, path);
% out_window = getLAS(window,nBins,img_path)
% ---------------------------------------------------------------
% Adaptive Discriminative Feature Learning
% Copyright (c) 2016, Shun Zhang

% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.
% ---------------------------------------------------------------

T = length(window);

loc = [];
appr = [];
size = [];
loc = cell(T,1);
appr = cell(T,1);
size = cell(T,1);
parfor t = 1:T
    %fprintf(1,'%d.',t)
    if(mod(t,10)==0) fprintf(1,'%d.',t); end
    if(mod(t,500)==0) fprintf(1,'\n'); end
    ObjectNums = window{t}.nNodes;
    name = window{t}.name;
    dets = window{t}.detection;
    [loc{t},appr{t},size{t}] = getLASOneFrame(path,m,ObjectNums,name,dets);
end
parfor t = 1:T
    window{t}.location = loc{t};
    window{t}.appearance = appr{t};
    window{t}.size = size{t};
end
outM = window;
