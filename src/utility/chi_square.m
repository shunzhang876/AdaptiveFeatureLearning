function res = chi_square(a,b)

res = sum(((a-b).^2)./(a+b+eps))/2;