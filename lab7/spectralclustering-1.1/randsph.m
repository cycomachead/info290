function [x y] = randr(R,n)
r = R*sqrt(rand(1,n)); % Taking square root gives uniform distribution
t = 2*pi*rand(1,n); % Theta
x = r.*cos(t); % Change to cartesian coordinates
y = r.*sin(t);
