function [l,dl,dsurr] = llcrosslearn(x,D,mu,nui,doprior,options);

dodiff=nargout==2;
np = length(x);

% transforming parameters
beta = exp(x(1));
eps = 1./(1+exp(-x(2:3)));

[l,dl] = logGaussianPrior(x,mu,nui,doprior);

a = D.a; 
r = D.r; 

V = zeros(2,1);
V1 = zeros(2,1);
V2 = zeros(2,1);
dVdb = zeros(2,1); 
dVde1 = zeros(2,1); 
dVde2 = zeros(2,1); 
dV1de1 = zeros(2,1); 
dV2de1 = zeros(2,1); 
dV1de2 = zeros(2,1); 
dV2de2 = zeros(2,1); 

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
			dl(2) = dl(2) + dVde1(a(1,t)) - pa'*dVde1;
			dl(3) = dl(3) + dVde2(a(1,t)) - pa'*dVde2;

			dVdb(a(1,t)) = dVdb(a(1,t)) + eps(1)*(beta*r(1,t) - dVdb(a(1,t)));
			dVdb(a(2,t)) = dVdb(a(2,t)) + eps(2)*(beta*r(2,t) - dVdb(a(2,t)));

			dV1de1(  a(1,t)) = dVde1(  a(1,t)) + eps(1)*(1-eps(1))*(beta*r(1,t) - V(a(1,t))) + eps(1)*( - dVde1(a(1,t)));
			dV1de1(3-a(1,t)) = dVde1(3-a(1,t));

			dV2de1(  a(2,t)) = dV1de1(  a(2,t)) + eps(2)*( - dV1de1(a(2,t)));
			dV2de1(3-a(2,t)) = dV1de1(3-a(2,t));

			dVde1 = dV2de1; 
		end

		% learn self then other
		V1(  a(1,t)) = V(  a(1,t)) + eps(1)*(beta*r(1,t) - V(a(1,t)));
		V1(3-a(1,t)) = V(3-a(1,t));

		if dodiff

			dV1de2(  a(1,t)) = dVde2(  a(1,t)) + eps(1)*( - dVde2(a(1,t)));
			dV1de2(3-a(1,t)) = dVde2(3-a(1,t));

			dV2de2(  a(2,t)) = dV1de2(  a(2,t)) + eps(2)*(1-eps(2))*(beta*r(2,t) - V1(a(2,t))) + eps(2)*( - dV1de2(a(2,t)));
			dV2de2(3-a(2,t)) = dV1de2(3-a(2,t));

			dVde2 = dV2de2; 

		end

		% learn self then other
		V2(  a(2,t)) = V1(  a(2,t)) + eps(2)*(beta*r(2,t) - V1(a(2,t)));
		V2(3-a(2,t)) = V1(3-a(2,t));

		V = V2; 

end
l = - l; 
dl = -dl; 

if options.generatesurrogatedata==1
	dsurr.a = a; 
	dsurr.r = r; 
end

