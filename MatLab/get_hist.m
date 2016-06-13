function R=get_hist(name)
% By Zhenqing Li 11/18/2008
% Usage:
% R=get_hist(array_name)

[m n]=size(name);
M=zeros(1,37);
sum=0;
for i=1:n
    k=(name(i)+90)/5;
    M(round(k)+1)=M(round(k)+1)+1;
    sum=sum+1;
end
for i=1:37
    M(i)=M(i)/sum;
end
R=barmax(M);
end
    