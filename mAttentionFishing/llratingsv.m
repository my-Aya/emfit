function [l,dl,dsurr] = llcrosslearn(x,D,mu,nui,doprior,options);

dodiff=nargout==2;
np = length(x);

% transforming parameters
beta = exp(x(1));
eps = 1./(1+exp(-x(2)));
gamma = 1./(1+exp(-x(3)));
w = x(4:5);

[l,dl] = logGaussianPrior(x,mu,nui,doprior);

r = D.r; 
a = D.a; 
likSel = D.likSelf;
likOth = D.likOther;
likO4S = D.likOther4Self;

Tr = length(r);
Tl = length(likSel);
if options.generatesurrogatedata==1
	a(1,:) = zeros(1,Tr);
	r(1,:) = zeros(1,Tr);
	rewardSequence = D.rewardSequence; 
	ygen = zeros(1,Tr); 
	dodiff=0;
end

V = zeros(2,1);
dVdb = zeros(2,1); 
dVde = zeros(2,1); 

yh = 0; 
dydg = 0; 
dydw1 = 0; 
dydw2 = 0; 

T = length(a);
for t=1:T

		v0 = V-max(V); 
		lpa = v0 - log(sum(exp(v0)));
		pa = exp(lpa); 

		if options.generatesurrogatedata==1
			[a(1,t),r(1,t)] = generatera(pa,rewardSequence(:,t));
		end

		if ~isnan(likSel(t))
			l = l - (likSel(t) - yh)^2 ; 
		end
		l = l + lpa(a(1,t));

		if dodiff

			dl(1) = dl(1) + dVdb(a(1,t)) - pa'*dVdb; 
			dl(2) = dl(2) + dVde(a(1,t)) - pa'*dVde;

			dVdb(a(1,t)) = dVdb(a(1,t)) + eps(1)*(beta*r(1,t) - dVdb(a(1,t)));
			dVde(  a(1,t)) = dVde(  a(1,t)) + eps(1)*(1-eps(1))*(beta*r(1,t) - V(a(1,t))) + eps(1)*( - dVde(a(1,t)));

			if ~isnan(likSel(t))
				dl(3) = dl(3) - 2*(likSel(t)-yh)*-dydg; 
				dl(4) = dl(4) - 2*(likSel(t)-yh)*-dydw1; 
				dl(5) = dl(5) - 2*(likSel(t)-yh)*-dydw2; 
			end

			dydg = gamma*(1-gamma)*yh + gamma*dydg ; 
			dydw1 = gamma*dydw1 + r(1,t);
			dydw2 = gamma*dydw2 + r(2,t);

		end

		yh = gamma*yh + w(1)*r(1,t) + w(2)*r(2,t); 

		V(  a(1,t)) = V(  a(1,t)) + eps(1)*(beta*r(1,t) - V(a(1,t)));

		if options.generatesurrogatedata==1
			ygen(t) = yh; 
		end

end

l = -l; 
dl = -dl; 

if options.generatesurrogatedata==1
	dsurr.likSelf = ygen;
	dsurr.a = a; 
	dsurr.r = r; 
end

