function m=pn_20(array)

[a b]=max(array);
m=0;
for i=-3:4
    m=m+array(b+i);
end
end