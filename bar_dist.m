function bar_dist(array,X,a,b,c,string1)
% Plot the functional distribution 
% Usage:
%   bar_dist(array,X,a,b,c,string)
%   array is the array, X is the x coordinations. a,b,c is the
%   coefficients. string1 is for title. string2 is for text notation.

X2=[-90:1:90];
Y=a*exp(-((X2-b)/c).^2);
bar(X,array);
hold on;
plot(X2,Y,'r-','LineWidth',2)
xlabel('Angle (Deg)')
title(string1)
