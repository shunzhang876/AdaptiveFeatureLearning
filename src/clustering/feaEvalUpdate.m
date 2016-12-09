function feaEvalUpdate(projInfo)

close all;

dataset = projInfo.video_name;
folder = projInfo.fea.feaDir;
fea_set = {'HOG','AlexNet','PreTrain','VGG-Face','FineTune'};

X = [];
Y = [];
for i=1:length(fea_set)
    fea_name = fea_set{i};
    if strcmp(fea_name,'HOG')
        matName = [folder,fea_set{i},'/cluster_purity.mat'];
    elseif ~strcmp(fea_name,'FineTune')
        matName = [folder,fea_set{i},'/cluster_purity_fc7.mat'];
    else
        matName = [folder,fea_set{i},'/cluster_purity_fc8.mat'];
    end
    load(matName);
    if i==1, X=1:length(purity); end
    Y(i,:) = purity(:,1)';
    if strcmp(fea_name,'FineTune')
        matName = [folder,fea_set{i},'/cluster_purity_fc8.mat'];
        load(matName);
        Y(i+1,:) = purity(:,1)';
    end
end

figure;
hold on;
for i=1:6
    plot(X,Y(i,:),'LineWidth',3);
end
axis([0, length(purity), 0, 1.01]);
if length(purity)>400,step = 50;
else step = 20; end
xticks = [0,projInfo.nbclusters,step:step:length(purity)];
set(gca,'xtick',xticks);
set(gca,'ytick',0:0.2:1);
grid on
set(gca, 'GridLineStyle' ,':');
xlabel('#clusters');
ylabel('Purity');

hold on;
ideal_y = 0:0.01:1;
ideal_x = projInfo.nbclusters*ones(1,length(ideal_y));
plot(ideal_x,ideal_y,'LineWidth',3,'LineStyle','-.','Color','m');

legs = {'HOG','AlexNet','PreTrain','VGG-Face','FT-Fc7','FT-Fc8'};
lag = [];
for i=1:length(legs)
    ind = find(X==projInfo.nbclusters);
    maxV = max(Y(i,:));
    lag{i} = [legs{i},' ',num2str(Y(i,ind),'%.2f'),'/',num2str(maxV,'%.2f')];
end
legend(lag{1},lag{2},lag{3},lag{4},lag{5},lag{6},'Ideal','Location','southeast');

set(gcf,'position',get(0,'screensize'));
saveas(gcf, [projInfo.myResDir,dataset,'_',projInfo.network_loss,'_HAC.jpg']);
close all;
