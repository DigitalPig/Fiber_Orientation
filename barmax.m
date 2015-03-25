function H=barmax(h)
% To move the histogram picture to the center.
% Usage:
%   H=barmax(h) where H is the moved histgram picture.

[m n]=size(h); % we use n
[a b]=max(h);
delta=b-ceil(n/2);
if delta>0 
for i=1:n
    if (i-delta<=0)
        j=n+(i-delta);
    else
        j=i-delta;
    end
    H(j)=h(i);
end
else if delta<0
        for i=1:n
            if i-delta>n
                j=(i-delta-n);
            else
                j=i-delta;
            end
            H(j)=h(i);
        end
    else H=h;
    end
end
end

        
