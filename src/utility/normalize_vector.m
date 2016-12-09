function N =  normalize_vector(M)
% This fuction is to normalize the row vector
N=M;
[r c] = size(M);
sum = 0;
for j=1:c
    sum = sum+M(j);
end
for j=1:c
    N(j) = M(j)/sum;
end
