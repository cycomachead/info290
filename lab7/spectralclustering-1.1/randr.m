function [x y] = randr(R,n,v)
if nargin < 3, v = 0.05;end 
        
r = R*(1+rand(1,n)*v); % Taking square root gives uniform distribution
t = 2*pi*rand(1,n); % Theta
x = r.*cos(t); % Change to cartesian coordinates
y = r.*sin(t);
