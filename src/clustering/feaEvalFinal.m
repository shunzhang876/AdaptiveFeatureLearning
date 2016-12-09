function feaEvalFinal(projInfo)
% feaEvalFinal(projInfo)
% ---------------------------------------------------------------
% Adaptive Discriminative Feature Learning
% Copyright (c) 2016, Shun Zhang

% The code may be used free of charge for non-commercial and
% educational purposes, the only requirement is that this text is
% preserved within the derivative work. For any other purpose you
% must contact the authors for permission. This code may not be
% redistributed without written permission from the authors.
% ---------------------------------------------------------------

close all;

dataset = projInfo.video_name;
folder = projInfo.resDir;
Triplet_dir = [folder,projInfo.method_conts,'_s',num2str(projInfo.scaleBox),...
    '_','Triplet','/'];
fea_set = {'Triplet','VGG-Face','PreTrain','AlexNet','HOG'};

X = [];
Y = [];
for i=1:length(fea_set)
    fea_name = fea_set{i};
    if strcmp(fea_name,'HOG')
        matName = [Triplet_dir,'_feaAP/',fea_set{i},'/cluster_purity.mat'];
    elseif strcmp(fea_name,'AlexNet')||strcmp(fea_name,'PreTrain')||strcmp(fea_name,'VGG-Face')
        matName = [Triplet_dir,'_feaAP/',fea_set{i},'/cluster_purity_fc7.mat'];
    elseif strcmp(fea_name,'Triplet')
        matName = [Triplet_dir,'_feaAP/AdaptTriplet/cluster_purity_fc8.mat'];
    else
        keyboard;
    end
    load(matName);
    if i==1, X=1:length(purity); end
    Y(i,:) = purity(:,1)';
end

figure;
hold on;
colors = [ 
    255,0,0;    % red       1
    0,255,0;    % green     2
    0,0,255;    % blue      3
    25,25,25;   % black     4
    255,0,255;  % magenta   5
    0,255,255;  % cyan      6
    212,212,0;  % yellow    7
    244,164,96; % sandybrown 8
    218,112,214;% orchild   9
    0,191,255;  % deepskyblue 10
    34,139,34;  % forestgreen 11
    139,0,0;];  % darkred   12;
colors = colors/255;
col = [colors(1,:);colors(2,:);colors(8,:);colors(3,:);colors(7,:);colors(4,:)];
for i=1:length(fea_set)
    if strcmp(fea_set{i},'Triplet')
        plot(X,Y(i,:),'LineWidth',3,'Color',col(i,:),'LineStyle',':');
    else
        plot(X,Y(i,:),'LineWidth',3,'Color',col(i,:));
    end
end

if length(purity)<80, len = length(purity);
else len = 80; end
axis([1, len, 0, 1.01]);

step = 20;
xticks = [1,projInfo.nbclusters,step:step:len];
set(gca,'xtick',xticks);
set(gca,'ytick',0:0.2:1);
grid on
set(gca, 'GridLineStyle' ,':');
xlabel('#Clusters');
ylabel('Weighted Purity');

hold on;
ideal_y = 0:0.01:1;
ideal_x = projInfo.nbclusters*ones(1,length(ideal_y));
plot(ideal_x,ideal_y,'LineWidth',2,'LineStyle','--','Color','m');

legs = {'Ours-Triplet','VGG-Face','Pre-trained','AlexNet','HOG'};
lag = [];
for i=1:length(legs)
    ind = find(X==projInfo.nbclusters);
    maxV = max(Y(i,:));
    lag{i} = ['[',num2str(Y(i,ind),'%.2f'),'] ',legs{i}];
end
AX=legend(lag{1},lag{2},lag{3},lag{4},lag{5},'Ideal Clusters',...
    'Location','southeast');

set(AX,'FontSize',15);


tit = [];
switch projInfo.video_name
    case 'Tara'
        tit = 'Tara';
end
set(gca,'FontSize',15);
%title(tit);

print(gcf,'-depsc','-painters',...
    [projInfo.resDir,dataset,'_HAC_80cls.eps']);
saveas(gcf, [projInfo.resDir,dataset,'_HAC_80cls.jpg']);

close all;
