function [l] = llcrosslearn(x,a,r, doprior)

% default is to use prior
l = -1/2*x'*x/100;
switch nargin
  case 4
  	if ~doprior
  		l = 0;
  	end
  case 3
  otherwise
    error('3 inputs are accepted. or 4, with doprior')
end

% transforming parameters
beta = exp(x(1));
eps = 1./(1+exp(-x(2:3)));

V = zeros(2,2);


T = length(a);
player = 1; 
for t=1:T

		pa = exp(V(:,player))./sum(exp(V(:,player)));
		l(player) = l(player)+ log(pa(a(player,t)));
		% learn self then other
		V(a(1,t),1) = V(a(1,t),1) + eps(1)*(beta*r(1,t) - V(a(1,t),1));
		V(a(2,t),1) = V(a(2,t),1) + eps(2)*(beta*r(2,t) - V(a(2,t),1));
end
l = - l; 
