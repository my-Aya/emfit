function [l,dl,dsurr] = test_ll6av4binit(x,D,mu,nui,doprior,options);
%
% [l,dl,surrugatedata] = ll6av4b(x,D,mu,nui,doprior,options);
%
% log likelihood (l) and gradient (dl) of ___
%
% Use this within emfit.m to tit RL type models to a group of subjects using
% EM.
%
% Quentin Huys 2021

dodiff=nargout==2;
np = size(x,1);

rho = exp(x(1));
alpha = 1./(1+exp(-x(2)));
selfposbias = x(3:6);
initb = x(7);
% initdone = 0;

% add Gaussian prior with mean mu and variance nui^-1 if doprior = 1
[l,dl] = logGaussianPrior(x,mu,nui,doprior);

a = D.a;
r = D.r;
wordval = D.wordval;
avatval = D.avatval;
av = D.avatid;

Q = zeros(2,2,12);
dqdr = zeros(2,2,12);
dqda = zeros(2,2,12);

if options.generatesurrogatedata==1
	a = zeros(size(a));
	dodiff=0;
end

for t=1:length(a);
	if ~isnan(a(t));

		bl = 1+(t>48);
		wv = (-wordval(t)+3)/2;
		q0 = Q(:,wv,av(t));
		q0(1) = q0(1) + selfposbias(bl+wordval(t)+1)*wordval(t)+initb*wordval(t);
        q0(2) = q0(2) - wordval(t)*initb;

		l0 = q0-max(q0);
		l0 = l0 - log(sum(exp(l0)));
		p = exp(l0);

		if options.generatesurrogatedata==1
			[a(t),r(t)] = generatera(p,wordval(t),avatval(t));
		end
		l = l+l0(a(t));

		if dodiff
			dl(1) = dl(1) + dqdr(a(t),wv,av(t)) - p'*dqdr(:,wv,av(t));
			dl(2) = dl(2) + dqda(a(t),wv,av(t)) - p'*dqda(:,wv,av(t));

			tmp = [wordval(t);0];
			dl(3+bl+wordval(t))   = dl(3+bl+wordval(t)) + tmp(a(t)) - p'*tmp;
            tmp = [wordval(t);-wordval(t)];
            dl(7) = dl(7) + tmp(a(t)) - p'*tmp;

			dqdr(a(t),wv,av(t)) = dqdr(a(t),wv,av(t)) + alpha*(rho*r(t) - dqdr(a(t),wv,av(t)));
			dqda(a(t),wv,av(t)) = dqda(a(t),wv,av(t)) + alpha*(1-alpha)*(rho*r(t)-Q(a(t),wv,av(t))) + alpha*(-dqda(a(t),wv,av(t)));
		end

		Q(  a(t),wv,av(t)) = Q(  a(t),wv,av(t))+alpha*( rho*r(t)-Q(  a(t),wv,av(t)));

	else
		if options.generatesurrogatedata==1
			a(t) = NaN;
			r(t) = NaN;
		end
	end
end

l = -l;
dl = -dl;

if options.generatesurrogatedata==1
	dsurr.a = a;
	dsurr.r = r;
end

