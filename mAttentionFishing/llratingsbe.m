function [l,dl,dsurr] = llcrosslearn(x,D,mu,nui,doprior,options);

dodiff=nargout==2;
np = length(x);

% transforming parameters
beta = exp(x(1));
eps = 1./(1+exp(-x(2)));
gamma = 1./(1+exp(-x(3)));
w = x(4:7);

[l,dl] = logGaussianPrior(x,mu,nui,doprior);

r = D.r; 
a = D.a; 
likSel = D.likSelf;
likOth = D.likOther;
likOthMSelf = D.likOtherMSelf;
likO4S = D.likOther4Self;

Tr = length(r);
Tl = length(likSel);
if options.generatesurrogatedata==1
	a(1,:) = zeros(1,Tr);
	r(1,:) = zeros(1,Tr);
	rewardSequence = D.rewardSequence; 
	ygen = zeros(1,Tr); 
	dodiff=0;
	vv = zeros(2,Tr); 
end

V = zeros(2,1);
dVdb = zeros(2,1); 
dVde = zeros(2,1); 

yh = 0; 
dydb = 0; 
dyde = 0; 
dydg = 0; 
dydw1 = 0; 
dydw2 = 0; 
dydw3 = 0; 
dydw4 = 0; 

T = length(a);
for t=1:T

		v0 = V-max(V); 
		lpa = v0 - log(sum(exp(v0)));
		pa = exp(lpa); 

		if options.generatesurrogatedata==1
			[a(1,t),r(1,t)] = generatera(pa,rewardSequence(:,t));
		end

		if ~isnan(likSel(t))
			l = l - (likOthMSelf(t) - yh)^2 ; 
		end
		l = l + lpa(a(1,t));

		v0 = 10*V; v0 = v0-max(v0); 
		sm = exp(v0(1))/sum(exp(v0));

		if dodiff

			dl(1) = dl(1) + dVdb(a(1,t)) - pa'*dVdb; 
			dl(2) = dl(2) + dVde(a(1,t)) - pa'*dVde;


			if ~isnan(likSel(t))
				dl(1) = dl(1) - 2*(likSel(t)-yh)*-dydb; 
				dl(2) = dl(2) - 2*(likSel(t)-yh)*-dyde; 
				dl(3) = dl(3) - 2*(likSel(t)-yh)*-dydg; 
				dl(4) = dl(4) - 2*(likSel(t)-yh)*-dydw1; 
				dl(5) = dl(5) - 2*(likSel(t)-yh)*-dydw2; 
				dl(6) = dl(6) - 2*(likSel(t)-yh)*-dydw3; 
				dl(7) = dl(7) - 2*(likSel(t)-yh)*-dydw4; 
			end

			dsmdb = sm*(1-sm)*10*(dVdb(1)-dVdb(2));
			dsmde = sm*(1-sm)*10*(dVde(1)-dVde(2));

			%dydb = gamma*dydb + w(3)*dVdb(a(1,t));
			%dyde = gamma*dyde + w(3)*dVde(a(1,t));
			dydb = gamma*dydb + w(3)*(sm*dVdb(1) +(1-sm)*dVdb(2) + dsmdb*V(1) - dsmdb *V(2)); 
			dyde = gamma*dyde + w(3)*(sm*dVde(1) +(1-sm)*dVde(2) + dsmde*V(1) - dsmde *V(2)); 

			dydg = gamma*(1-gamma)*yh + gamma*dydg ; 
			dydw1 = gamma*dydw1 + r(1,t);
			dydw2 = gamma*dydw2 + r(2,t);
			dydw3 = gamma*dydw3 + sm*V(1)+(1-sm)*V(2);
			dydw4 = gamma*dydw4 + t; 

			dVdb(a(1,t)) = dVdb(a(1,t)) + eps(1)*(beta*r(1,t) - dVdb(a(1,t)));
			dVde(  a(1,t)) = dVde(  a(1,t)) + eps(1)*(1-eps(1))*(beta*r(1,t) - V(a(1,t))) + eps(1)*( - dVde(a(1,t)));


		end

		yh = gamma*yh + w(1)*r(1,t) + w(2)*r(2,t) + w(3)*(sm*V(1)+(1-sm)*V(2)) + w(4)*t; 

		V(  a(1,t)) = V(  a(1,t)) + eps(1)*(beta*r(1,t) - V(a(1,t)));

		if options.generatesurrogatedata==1
			ygen(t) = yh; 
			vv(:,t) = V; 
		end

end

l = -l; 
dl = -dl; 

if options.generatesurrogatedata==1
	dsurr.likSelf = ygen(:);
	dsurr.a = a; 
	dsurr.r = r; 
	dsurr.v = vv; 
	dsurr.likSelf = ygen; 
end

