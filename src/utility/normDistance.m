function res = normDistance(X,miu,sigma,para)

res=[];
if para == 1
    res=exp(-0.5*((X-miu).^2/sigma^2));
elseif para == 2
    miu1=miu(1); miu2=miu(2);
    sigma1=sigma(1); sigma2=sigma(2);
    res=exp(-0.5*((X(1)-miu1).^2/sigma1^2+(X(2)-miu2).^2/sigma2^2));
end