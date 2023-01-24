function [l,dl,dsurr] = llcrosslearn(x,D,mu,nui,doprior,options);

dodiff=nargout==2;
np = length(x);

% transforming parameters
beta = exp(x(1));
eps = 1./(1+exp(-x(2)));

[l,dl] = logGaussianPrior(x,mu,nui,doprior);

a = D.a; 
r = D.r; 

V = zeros(2,1);
dVdb = zeros(2,1); 
dVde = zeros(2,1); 

T = length(a);
if options.generatesurrogatedata==1
	a(1,:) = zeros(1,T);
	r(1,:) = zeros(1,T);
	rewardSequence = D.rewardSequence; 
	dodiff=0;
end

for t=1:T

		v0 = V-max(V); 
		lpa = v0 - log(sum(exp(v0)));
		pa = exp(lpa); 

		if options.generatesurrogatedata==1
			[a(1,t),r(1,t)] = generatera(pa,rewardSequence(:,t));
		end

		l = l + lpa(a(1,t));

		if dodiff
			dl(1) = dl(1) + dVdb(a(1,t)) - pa'*dVdb; 
			dl(2) = dl(2) + dVde(a(1,t)) - pa'*dVde;

			dVdb(a(1,t)) = dVdb(a(1,t)) + eps(1)*(beta*r(1,t) - dVdb(a(1,t)));
			dVde(  a(1,t)) = dVde(  a(1,t)) + eps(1)*(1-eps(1))*(beta*r(1,t) - V(a(1,t))) + eps(1)*( - dVde(a(1,t)));
		end

		% learn self 
		V(  a(1,t)) = V(  a(1,t)) + eps(1)*(beta*r(1,t) - V(a(1,t)));

end
l = - l; 
dl = -dl; 

if options.generatesurrogatedata==1
	dsurr.a = a; 
	dsurr.r = r; 
end

