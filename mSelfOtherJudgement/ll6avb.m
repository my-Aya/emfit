function [l,dl,dsurr] = lld6avb(x,D,mu,nui,doprior,options);
% 
% [l,dl,surrugatedata] = llb(x,D,mu,nui,doprior,options);
% 
% log likelihood (l) and gradient (dl) of simple bias model
% 
% Use this within emfit.m to tit RL type models to a group of subjects using
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

Q = zeros(2,2,12);
dqdr = zeros(2,2,12);
dqda = zeros(2,2,12);

if options.generatesurrogatedata==1
	a = zeros(size(a));
	dodiff=0;
end

for t=1:length(a);
	if ~isnan(a(t));

		bl = 1+(t>48); % block is 1 for first 48 trials (self), 2 for last 48 (other) 
		wv = (-wordval(t)+3)/2; % transforms from 1/-1 to 1/2
		q0 = Q(:,wv,av(t)); 
		q0(1) = q0(1) + selfposbias(bl)*wordval(t);

		l0 = q0-max(q0);
		l0 = l0 - log(sum(exp(l0)));
		p = exp(l0); % generate the probability of actions based on current Q values and bias

		if options.generatesurrogatedata==1
			[a(t),r(t)] = generatera(p,wordval(t),avatval(t));
		end
		l = l+l0(a(t)); % combined log lik of current action

		if dodiff
			dl(1) = dl(1) + dqdr(a(t),wv,av(t)) - p'*dqdr(:,wv,av(t)); % calculate lik gradient for rho, based on current dqdr
			dl(2) = dl(2) + dqda(a(t),wv,av(t)) - p'*dqda(:,wv,av(t)); % calculate lik gradient for alpha, based on current dqda
			tmp = [wordval(t);0];  
			dl(2+bl)   = dl(2+bl) + tmp(a(t)) - p'*tmp; % calculate lik gradient for bias, based on p

			dqdr(a(t),wv,av(t)) = dqdr(a(t),wv,av(t)) + alpha*(rho*r(t) - dqdr(a(t),wv,av(t))); % update dqdr
			dqda(a(t),wv,av(t)) = dqda(a(t),wv,av(t)) + alpha*(1-alpha)*(rho*r(t)-Q(a(t),wv,av(t))) + alpha*(-dqda(a(t),wv,av(t))); % update dqda
		end

		Q(  a(t),wv,av(t)) = Q(  a(t),wv,av(t))+alpha*( rho*r(t)-Q(  a(t),wv,av(t))); % update Q value

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

