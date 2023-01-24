function [l,dl,dsurr] = llcrosslearn(x,D,mu,nui,doprior,options);

dodiff=(nargout==2);
np = length(x);

% transforming parameters
gamma = 1./(1+exp(-x(1)));
w = x(2:3);

[l,dl] = logGaussianPrior(x,mu,nui,doprior);

r = D.r; 
a = D.a; 
likSel = D.likSelf;
likOth = D.likOther;
likO4S = D.likOther4Self;

Tr = length(r);
Tl = length(likSel);
if options.generatesurrogatedata==1
	%a(1,:) = zeros(1,T);
	%r(1,:) = zeros(1,T);
	%rewardSequence = D.rewardSequence; 
	ygen = zeros(1,Tr); 
	dodiff=0;
end

yh = 0; 
dydg = 0; 
dydw1 = 0; 
dydw2 = 0; 

T = length(a);
for t=1:T

		if ~isnan(likSel(t))
			l = l - (likSel(t) - yh)^2; 
		end

		if dodiff
			if ~isnan(likSel(t))
				dl(1) = dl(1) - 2*(likSel(t)-yh)*-dydg; 
				dl(2) = dl(2) - 2*(likSel(t)-yh)*-dydw1; 
				dl(3) = dl(3) - 2*(likSel(t)-yh)*-dydw2; 
			end

			dydg = gamma*(1-gamma)*yh + gamma*dydg ; 
			dydw1 = gamma*dydw1 + r(1,t);
			dydw2 = gamma*dydw2 + r(2,t);

		end

		yh = gamma*yh + w(1)*r(1,t) + w(2)*r(2,t); 

		if options.generatesurrogatedata==1
			genyh(t) = yh; 
		end

end

l = -l; 
dl=-dl;

if options.generatesurrogatedata==1
	dsurr.likSelf = genyh;
end

