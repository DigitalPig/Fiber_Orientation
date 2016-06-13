function [H rho theta]=hough(img,thres,peaknum,rbin,tbin)
% Written by Zhenqing Li. To perform the Hough Transformation to the
% line detection.
% Usage:
% [H rho theta]=hough(img,thres,peaknum,rbin,tbin)
%b=edge(img,'canny');
%imshow(b);
b=im2bw(img,1);
[H R]=hough_line(b);
%[CX CY]=immaximas(H,1,90);
CX=zeros(peaknum,1);
CY=zeros(peaknum,1);
step=0;
%size(H)
%max(H(:,:))
i=max(H(:));
[hx hy]=size(H);
i_min=min(H(:));
while (i>i_min)
  disp(step)
%  disp(i)
  if i<thres
    CX=CX(1:step);
    CY=CY(1:step);
    disp("Lower than the threshold, STOP finding peaks!");
    break
    else if (step>=peaknum)
	disp("Reach the peaknumber. STOP finding peaks!");
	break
	endif
  endif
  [t_x t_y]=immaximas(H,1,i);
%    disp("before zeroing...")
%    max(H(:))
  if step <1
    disp("Finding peaks...")
  endif
  for j=1:size(t_x)(1)

%    disp(t_x(j))
    step=step+1;
    CX(step)=t_x(j);
    CY(step)=t_y(j);




%    t_x(j)
%    t_y(j)

for mi=-rbin:rbin
  for mj=-tbin:tbin
% Check if it reaches the boundary of the matrix

 
    if round(t_x(j)+mi)<1 
      mi=1-t_x(j);
    endif
    if round(t_y(j)+mj)<1 
      mj=1-t_y(j);
    endif
    if round(t_x(j)+mi)>hx 
      mi=hx-t_x(j);
    endif
    if round(t_y(j)+mj)>hy 
      mj=hy-t_y(j);
    endif
    H(round(t_x(j)+mi),round(t_y(j)+mj))=0;
  endfor
endfor
    
%    H(round(t_x(j)),round(t_y(j)))=0;
%    H(round(t_x(j)),round(t_y(j)))
%    H(round(t_x(j)-rbin),round(t_y(j)))=0;
%    H(round(t_x(j)+rbin),round(t_y(j)))=0;
%    H(round(t_x(j)),round(t_y(j)+tbin))=0;
%    H(round(t_x(j)),round(t_y(j)-tbin))=0;
%    H(round(t_x(j)-rbin),round(t_y(j)-tbin))=0;
%    H(round(t_x(j)-rbin),round(t_y(j)+tbin))=0;
%    H(round(t_x(j)+1),round(t_y(j)-1))=0;
%    H(round(t_x(j)+1),round(t_y(j)+1))=0;
%    disp("after zeroing...")
%    max(H(:))
  endfor
  if(size(t_x)(1)==0)
    i=i-1;
    else 
  i=max(H(:));
  endif
endwhile
%CX
%CY
%[n k]=size(CX);
%skip=0;
%rho(1)=R(round(CX(1)));
%theta(1)=(CY(1)-1-90)*3.14/180;
rho=R(round(CX(1:step)));
theta=((CY(1:step)-1-90)*3.14/180)';

%for i=2:n
%  if((CX(i)-CX(i-1)>2) | (CY(i)-CY(i-1)>1))
%    rho(i-skip)=R(round(CX(i)));
%    theta(i-skip)=(CY(i)-1-90)*3.14/180;
%    else 
%    skip=skip+1;  
%    disp(skip)
%   endif

%endfor
%deg=theta*180/3.14;
