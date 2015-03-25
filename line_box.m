function deg=line_box(r,theta,img)
% To calculate the lines intercepting with box boundaries.
% Usage: 
%       deg=line_box(r,theta,img)
[k n]=size(r);
[ny nx]=size(img);
center_x=(nx-1)/2;
center_y=(ny-1)/2;
%C_X=round(center_x);
%C_Y=round(center_y);
for i=1:n
T_X(i)=(center_x+r(i)*cos(theta(i)));
T_Y(i)=(-center_y+r(i)*sin(theta(i)));
end
for i=1:n
  if ((r(i)>0 & theta(i)>0) | (r(i)<0 & theta(i)>0))
%  disp("Condition1")
  slope(i)=tan(theta(i));
  deg(i)=theta(i)*180/3.14;
  else 
%    disp("condition2");
    slope(i)=tan(theta(i));
    deg(i)=theta(i)*180/3.14;
  end
  end

for i=1:n
  X1(i)=T_X(i)-20;
  X2(i)=T_X(i)+20;
%if (theta(i)>=0.1 | theta(i)>=-pi/2)
Y1(i)=slope(i)*(X1(i)-T_X(i))+T_Y(i);
Y2(i)=slope(i)*(X2(i)-T_X(i))+T_Y(i);
%else if( (theta(i)<0.1) | (theta(i)+pi/2 <0.1))
%Y1(i)=T_Y(i)-10;
%Y2(i)=T_Y(i)+10;
%X1(i)=X2(i)=T_X(i);
%endif
%endif
end
imshow(img);
%for i=1:n
%  if (Y1(i)>ny-1)
%    Y1(i)=ny-1;
%    X1(i)=(Y1(i)-T_Y(i))/slope(i)+T_X(i);
%    X1(i)
%    Y1(i)
%  else if (Y1(i)<0)
%      Y1(i)=0;
%      X1(i)=(Y1(i)-T_Y(i))/slope(i)+T_X(i);
%      end
%  end
%  if (Y2(i)>ny-1)
%    Y2(i)=ny-1;
%    X2(i)=(Y2(i)-T_Y(i))/slope(i)+T_X(i);
%  else if (Y1(i)<0)
%      Y2(i)=0;
%      X2(i)=(Y2(i)-T_Y(i))/slope(i)+T_X(i);
%      end
%  end
%end
%  hold on;
%[X1(1) X2(1)]
%[Y1(1) Y2(1)]
for i=1:n
  line([X1(i) X2(i)],[-Y1(i) -Y2(i)]);
%  pause;
%  plot(X2(i),Y2(i),'r-');
end
