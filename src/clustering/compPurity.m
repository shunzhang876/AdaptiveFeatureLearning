function purity = compPurity(TsInit)


N = 0;
purity = 0;

for i=1:length(TsInit)
    if TsInit(i).num==0,
        continue;
    end
    
    labels = TsInit(i).gt_id;
    uId = unique(labels);
    nums = zeros(length(uId),1);
    for j=1:length(uId)
        idx = find(labels==uId(j));
        nums(j) = length(idx);
    end
    
    [val,ind] = max(nums);
    p = val/length(labels);
    
    TsInit(i).purity = p;
    N = N+length(labels);
end

score = 0;
for i=1:length(TsInit)
    if TsInit(i).num==0,
        continue;
    end
    
    score = score+TsInit(i).purity*TsInit(i).num;
end
purity = score/N;