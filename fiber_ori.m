function [H,ang]=fiber_ori(img,threshold,pixel)
% Use Gaussian-Like convolution to detect the change in image gradient to find the
% appropriate single fiber orientation.
% By Zhenqing Li 09/27/2008
% Usage:
%   [histogram1, histogram2]=fiber_ori(img,threshold,pixel)
%   img is the file name of the image 
%   threshold is defined as the background color of the image
%   pixel is the sub-region size, which can be treated as the fiber
%   diameter. The retured histogram value is the histogram matrix which
%   store the histogram of the image.
%   Histogram1 stores the histogram data for 5 deg interval while
%   histogram2 stores the histogram data for 1 deg interval
  ## The file was further modified to use for LZ hair direction analysis
  ## New functional returns return the 1 deg bin histogram and the angle.

m=imread(img);
% Construct the matrix
sigma=2.5;
for i=-3:3
    for j=-3:3
        Hx(i+4,j+4)=(2*i)/sigma^2*exp(-(i^2+j^2)/sigma^2);
        Hy(i+4,j+4)=(2*j)/sigma^2*exp(-(i^2+j^2)/sigma^2);
    end
end
if (isgray(m)~=1)
    m=rgb2gray(m);
end
% Convolve the image with filter
A=zeros(1,180); % Accuminator functions
histogram=zeros(1,180); % Initialize a matrix which count the histogram of the angle
sum=0; % Initialize the fiber number.
P=zeros(1,36);
mx=conv2(single(m),single(Hx),'same');
my=conv2(single(m),single(Hy),'same');

%Calculate the gradient maginification matrix and angle matrix
[h,w]=size(m);
msum=zeros(h,w);
mangle=zeros(h,w); %Initialization
for i=1:h
    for j=1:w
        msum(i,j)=(mx(i,j)^2+my(i,j)^2);
        mangle(i,j)=180*atan(mx(i,j)/my(i,j))/3.14+90;
    end
end
% Pixel size is customized pixels for one subregion.
%angle=zeros(floor(w/pixel),floor(h/pixel));
imshow(m);
hold on;
up=floor((pixel+1)/2);
down=floor((pixel-1)/2);
dstep=ceil(pixel/7);
sang=((h-down-pixel-up-pixel)/pixel)*((w-down-pixel-up-pixel)/pixel);
tang=zeros(sang,1);
sum=0;
for i=up+pixel:pixel:h-down-pixel
    for j=up+pixel:pixel:w-down-pixel
        % Into one subregion
        judge=0;
        for o=-1:+1
            for p=-1:+1
                if m(i+o,j+p)<=threshold % if center and adjacent 4 points are less than threshold. Skip this region
                    judge=1;
                    continue;
                end
            end
        end
        if judge==1
            continue;
        end
        o=0;
        p=0;
        %        if (m(i,j)<=threshold | m(i-1,j)<=threshold | m(i+1,j)<=threshold | m(i,j-1)<=threshold | m(i,j+1)<=threshold)
%            continue;
%        end
        A=zeros(1,180); % A matrix should be re-initialized before.

        for k=1:180
            for o=-down:dstep:down
                for p=-down:dstep:down
                    % Calculate the accuminator function
                    A(k)=A(k)+msum(i+o,j+p)*(exp(2*cos(2*3.14*(k-1-mangle(i+o,j+p))/180))/exp(2));
                end
            end
        end
        [xx xc]=max(A);
        %angle(ceil((i+down)/pixel),ceil((j+down)/pixel))=xc-90; % The local maximum of this cell is stored in to angle matrix
        %rectangle('Position',[j-down,i-down,pixel,pixel]);
        % Draw the local fiber direction
%        if xc-1>90
%            xc=(180-xc);
%        end
        tang(sum+1,1)=xc;
	histogram(xc)=histogram(xc)+1;
        sum=sum+1;
        if abs(down*tan(3.14*(xc-1)/180))>down
            dy=down;
            dx=down/tan(3.14*(xc-1)/180);
        else dy=down*tan(3.14*(xc-1)/180);
             dx=down;
        end
        plot([j+dx,j-dx],[i+dy,i-dy],'r-','LineWidth',2);
    end
end
for i=1:180
    histogram(i)=histogram(i)/sum;
end
## for i=1:36
##     for j=1:5
##         P(i)=P(i)+histogram(j+(i-1)*5);
##     end
## end
ang=zeros(sum,1);
for i=1:sum
    ang(i,1)=tang(i,1);
end
H=histogram;
end

        


