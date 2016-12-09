function res = Bcoefficient(a,b)

absA = sqrt(sum(a.^2));
absB = sqrt(sum(b.^2));
if(absA==0 || absB==0)
    res = 0;
else
    res = sum(a.*b)/(absA*absB);
end;