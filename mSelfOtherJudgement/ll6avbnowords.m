function [l,dl,dsurr] = ll6avbnowords(x,D,mu,nui,doprior,options);
%
% [l,dl,surrugatedata] = ll6avbnowords(x,D,mu,nui,doprior,options);
%
% log likelihood (l) and gradient (dl) of __
%
% Use this within emfit.m to fit RL type models to a group of subjects using
% EM.
%
% Quentin Huys 2021

dodiff=nargout==2;
np = size(x,1);

rho = exp(x(1));
alpha = 1./(1+exp(-x(2)));
selfposbias = x(3:4);

% add Gaussian prior with mean mu and variance nui^-1 if doprior = 1
[l,dl] = logGaussianPrior(x,mu,nui,doprior);

a = D.a;
r = D.r;
wordval = D.wordval;
avatval = D.avatval;
av = D.avatid;

Q = zeros(2,12);
dqdr = zeros(2,12);
dqda = zeros(2,12);

if options.generatesurrogatedata==1
	a = zeros(size(a));
	dodiff=0;
end

for t=1:length(a);
	if ~isnan(a(t));

		bl = 1+(t>48);
		wv = (-wordval(t)+3)/2;
		q0 = Q(:,av(t));
		q0(1) = q0(1) + selfposbias(bl)*wordval(t);

		l0 = q0-max(q0);
		l0 = l0 - log(sum(exp(l0)));
		p = exp(l0);

		if options.generatesurrogatedata==1
			[a(t),r(t)] = generatera(p,wordval(t),avatval(t));
		end
		l = l+l0(a(t));

		if dodiff
			dl(1) = dl(1) + dqdr(a(t),av(t)) - p'*dqdr(:,av(t));
			dl(2) = dl(2) + dqda(a(t),av(t)) - p'*dqda(:,av(t));
			tmp = [wordval(t);0];
			dl(2+bl)   = dl(2+bl) + tmp(a(t)) - p'*tmp;

			dqdr(a(t),av(t)) = dqdr(a(t),av(t)) + alpha*(rho*r(t) - dqdr(a(t),av(t)));
			dqda(a(t),av(t)) = dqda(a(t),av(t)) + alpha*(1-alpha)*(rho*r(t)-Q(a(t),av(t))) + alpha*(-dqda(a(t),av(t)));
		end

		Q(  a(t),av(t)) = Q(  a(t),av(t))+alpha*( rho*r(t)-Q(  a(t),av(t)));

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

