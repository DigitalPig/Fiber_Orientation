function bname=clean_data(name)
% To make all the angle value inside of the array from -90 to +90
% Usage:
%       clean_data(array_name)

[a b]=size(name);
for i=1:a
    if (name(i)>90)
        bname(i)=name(i)-180;
    else if (name(i)<-90)
            bname(i)=name(i)+180;
        else bname(i)=name(i);
        end
    end
    end
end

