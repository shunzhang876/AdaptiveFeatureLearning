function [trip_a,trip_p,trip_n] = constTriplet(nObj,mNLink,faceTrcks,extract_num,projInfo)
% [anchor,pos,neg] = constTriplet(nObj,mNLink,faceTrcks,extract_num,projInfo)
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
trajs = projInfo.trajs;

%% Generate Triplets
trip_a = [];
trip_p = [];
trip_n = [];
cout = 0;

% 1. find all tracklets to generate triplets
must_not_link_tracks = [];
for i=1:nObj-1
    idx = find(mNLink(i+1:nObj,i));
    must_not_link_tracks = [must_not_link_tracks; idx+i,i*ones(length(idx),1)];
end

% 2. 
face_tracks = faceTrcks;

% 3. generate all must not link constraints
for i=1:size(must_not_link_tracks,1)
    pair_id = must_not_link_tracks(i,:);
    
    for jj=1:2
        if jj==2
            pair_id = [pair_id(2),pair_id(1)];
        end
        face_track1 = face_tracks{pair_id(1)};
        face_track2 = face_tracks{pair_id(2)};
        
        % image_pair_list = [];
        for j=1:length(face_track1)-1               % anchor
            idTrcks1 = res(face_track1(j)).idTrck;
            idx2 = find(idTrcks1==pair_id(1));
            cnt_p = 0;
            frame_p = face_track1(j+1:length(face_track1));
            frame_pp = frame_p(randperm(length(frame_p)));
            cnt_n = 0;
            frame_n = face_track2(1:length(face_track2));
            frame_nn = frame_n(randperm(length(frame_n)));
            
            for m=1:extract_num                     % positive
                cnt_p = cnt_p+1;
                if cnt_p>length(frame_pp), break; end
                idTrcks11 = res(frame_pp(m)).idTrck;
                idx22 = find(idTrcks11==pair_id(1));
                cnt_n = 0;
                
                for k=1:extract_num                 % negative
                    cnt_n = cnt_n+1;
                    if cnt_n>length(frame_nn), break; end
                    
                    cout = cout+1;
                    trip_a(cout).frame = face_track1(j);
                    trip_a(cout).node = idx2;
                    trip_a(cout).label = trajs.labels(pair_id(1));
                    
                    
                    trip_p(cout).frame = frame_pp(m);
                    trip_p(cout).node = idx22;
                    trip_p(cout).label = trajs.labels(pair_id(1));
                    
                    idTrcks2 = res(frame_nn(k)).idTrck;
                    ind2 = find(idTrcks2==pair_id(2));
                    trip_n(cout).frame = frame_nn(k);
                    trip_n(cout).node = ind2;
                    trip_n(cout).label = trajs.labels(pair_id(2));
                end
            end
        end
    end
end


trip_a;
