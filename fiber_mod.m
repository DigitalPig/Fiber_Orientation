function fiber_mod(gamma)
% Simulating scaffold's modulus relationship to orientation

theta=-pi/2:0.01:pi/2; % Define the angle of angular distribution
epsilon=[0:0.05:1]; % This is the scaffold strain
result1=zeros(1,21);
result2=zeros(1,21);
result3=zeros(1,21);
result4=zeros(1,21);
%gamma=0.2595; %gamma is the coefficient to determine the shape of the distribution.
R=@(x)(1./(pi*gamma*(1+(x./gamma).^2)));
subplot(2,2,2);plot(theta,R(theta));
a=10;
b=5;
v=0.5;
for i=1:21
    R1=@(x)(1./(pi*gamma*(1+(x./gamma).^2))).*a.*(exp(b.*epsilon(i)*((cos(x)).^2+v.*(sin(x)).^2))-1);
    R2=@(x)(1./(pi*gamma*(1+(x./gamma).^2))).*a.*(exp(b.*epsilon(i)*((cos(x+pi/6)).^2+v.*(sin(x+pi/6)).^2))-1);
    R3=@(x)(1./(pi*gamma*(1+(x./gamma).^2))).*a.*(exp(b.*epsilon(i)*((cos(x+pi/3)).^2+v.*(sin(x+pi/3)).^2))-1);
    R4=@(x)(1./(pi*gamma*(1+(x./gamma).^2))).*a.*(exp(b.*epsilon(i)*((cos(x+pi/2)).^2+v.*(sin(x+pi/2)).^2))-1);
    result1(i)=quad(R1,-pi/2,pi/2);
    result2(i)=quad(R2,-pi/2,pi/2);
    result3(i)=quad(R3,-pi/2,pi/2);
    result4(i)=quad(R4,-pi/2,pi/2);
end
subplot(2,2,[1 3]);plot(epsilon,result1,epsilon,result2,epsilon,result3,epsilon,result4)
legend('0 deg','30 deg', '60 deg', '90 deg','Location','Northwest');
xlabel('Strain');
ylabel('Stress');
slope=zeros(1,4);
p1=polyfit(epsilon(1:10),result1(1:10),1);
slope(1)=p1(1);
p2=polyfit(epsilon(1:10),result2(1:10),1);
slope(2)=p2(1);
p3=polyfit(epsilon(1:10),result3(1:10),1);
slope(3)=p3(1);
p4=polyfit(epsilon(1:10),result4(1:10),1);
slope(4)=p4(1);
deg=[0 30 60 90];
subplot(2,2,4);plot(deg,slope,'*');
end
    