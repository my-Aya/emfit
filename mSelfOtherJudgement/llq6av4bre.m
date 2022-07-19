function [l,dl,dsurr] = llq6av4b(x,D,mu,nui,doprior,options);
%
% [l,dl,surrugatedata] = llq6av4b(x,D,mu,nui,doprior,options);
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

rho_retest = exp(x(7));
alpha_retest = 1./(1+exp(-x(8)));
selfposbias_retest = x(9:12);

% add Gaussian prior with mean mu and variance nui^-1 if doprior = 1
[l,dl] = logGaussianPrior(x,mu,nui,doprior);

a = D.a;
r = D.r;
wordVal = D.wordVal;
avatarVal = D.avatarVal;
av = D.avatarId;

Q = zeros(2,2,12);
dqdr = zeros(2,2,12);
dqda = zeros(2,2,12);

if options.generatesurrogatedata==1
	a = zeros(size(a));
	dodiff=0;
end

%%%%%%%%%  TEST contribution

for t=1:96;
	if ~isnan(a(t));

		bl = 1+(t>48);
		wv = (-wordVal(t)+3)/2;
		q0 = Q(:,wv,av(t));
		q0(1) = q0(1) + selfposbias(bl+wordVal(t)+1)*wordVal(t);

		l0 = q0-max(q0);
		l0 = l0 - log(sum(exp(l0)));
		p = exp(l0);

		if options.generatesurrogatedata==1
			[a(t),r(t)] = generatera(p,wordVal(t),avatarVal(t));
		end
		l = l+l0(a(t));

		if dodiff
			dl(1) = dl(1) + dqdr(a(t),wv,av(t)) - p'*dqdr(:,wv,av(t));
			dl(2) = dl(2) + dqda(a(t),wv,av(t)) - p'*dqda(:,wv,av(t));

			tmp = [wordVal(t);0];
			dl(3+bl+wordVal(t))   = dl(3+bl+wordVal(t)) + tmp(a(t)) - p'*tmp;

			dqdr(a(t),wv,av(t)) = dqdr(a(t),wv,av(t)) + alpha*(rho*r(t) - dqdr(a(t),wv,av(t)));
			dqdr(3-a(t),wv,av(t)) = dqdr(3-a(t),wv,av(t)) + alpha*(-rho*r(t) - dqdr(3-a(t),wv,av(t)));
			dqdr(a(t),3-wv,av(t)) = dqdr(a(t),3-wv,av(t)) + alpha*(-rho*r(t) - dqdr(a(t),3-wv,av(t)));
			dqdr(3-a(t),3-wv,av(t)) = dqdr(3-a(t),3-wv,av(t)) + alpha*(rho*r(t) - dqdr(3-a(t),3-wv,av(t)));
			dqda(a(t),wv,av(t)) = dqda(a(t),wv,av(t)) + alpha*(1-alpha)*(rho*r(t)-Q(a(t),wv,av(t))) + alpha*(-dqda(a(t),wv,av(t)));
			dqda(3-a(t),wv,av(t)) = dqda(3-a(t),wv,av(t)) + alpha*(1-alpha)*(-rho*r(t)-Q(3-a(t),wv,av(t))) + alpha*(-dqda(3-a(t),wv,av(t)));
			dqda(a(t),3-wv,av(t)) = dqda(a(t),3-wv,av(t)) + alpha*(1-alpha)*(-rho*r(t)-Q(a(t),3-wv,av(t))) + alpha*(-dqda(a(t),3-wv,av(t)));
			dqda(3-a(t),3-wv,av(t)) = dqda(3-a(t),3-wv,av(t)) + alpha*(1-alpha)*(rho*r(t)-Q(3-a(t),3-wv,av(t))) + alpha*(-dqda(3-a(t),3-wv,av(t)));
		end

		Q(  a(t),wv,av(t)) = Q(  a(t),wv,av(t))+alpha*( rho*r(t)-Q(  a(t),wv,av(t)));
		Q(3-a(t),wv,av(t)) = Q(3-a(t),wv,av(t))+alpha*(-rho*r(t)-Q(3-a(t),wv,av(t)));
		Q(  a(t),3-wv,av(t)) = Q(  a(t),3-wv,av(t))+alpha*(-rho*r(t)-Q(  a(t),3-wv,av(t)));
		Q(3-a(t),3-wv,av(t)) = Q(3-a(t),3-wv,av(t))+alpha*( rho*r(t)-Q(3-a(t),3-wv,av(t)));

	else
		if options.generatesurrogatedata==1
			a(t) = NaN;
			r(t) = NaN;
		end
	end
end


%%%%%%%%%  RETEST contribution

%  need to reset the Q's and the gradients for the next run
Q = zeros(2,2,12);
dqdr = zeros(2,2,12);
dqda = zeros(2,2,12);


for t=97:192;
	if ~isnan(a(t));

		bl = 1+(t>144);
		wv = (-wordVal(t)+3)/2;
		q0 = Q(:,wv,av(t));
		q0(1) = q0(1) + selfposbias_retest(bl+wordVal(t)+1)*wordVal(t);

		l0 = q0-max(q0);
		l0 = l0 - log(sum(exp(l0)));
		p = exp(l0);

		if options.generatesurrogatedata==1
			[a(t),r(t)] = generatera(p,wordVal(t),avatarVal(t));
		end
		l = l+l0(a(t));

		if dodiff
			dl(7) = dl(7) + dqdr(a(t),wv,av(t)) - p'*dqdr(:,wv,av(t));
			dl(8) = dl(8) + dqda(a(t),wv,av(t)) - p'*dqda(:,wv,av(t));

			tmp = [wordVal(t);0];
			dl(9+bl+wordVal(t))   = dl(9+bl+wordVal(t)) + tmp(a(t)) - p'*tmp;

			dqdr(a(t),wv,av(t)) = dqdr(a(t),wv,av(t)) + alpha_retest*(rho_retest*r(t) - dqdr(a(t),wv,av(t)));
			dqdr(3-a(t),wv,av(t)) = dqdr(3-a(t),wv,av(t)) + alpha_retest*(-rho_retest*r(t) - dqdr(3-a(t),wv,av(t)));
			dqdr(a(t),3-wv,av(t)) = dqdr(a(t),3-wv,av(t)) + alpha_retest*(-rho_retest*r(t) - dqdr(a(t),3-wv,av(t)));
			dqdr(3-a(t),3-wv,av(t)) = dqdr(3-a(t),3-wv,av(t)) + alpha_retest*(rho_retest*r(t) - dqdr(3-a(t),3-wv,av(t)));
			dqda(a(t),wv,av(t)) = dqda(a(t),wv,av(t)) + alpha_retest*(1-alpha_retest)*(rho_retest*r(t)-Q(a(t),wv,av(t))) + alpha_retest*(-dqda(a(t),wv,av(t)));
			dqda(3-a(t),wv,av(t)) = dqda(3-a(t),wv,av(t)) + alpha_retest*(1-alpha_retest)*(-rho_retest*r(t)-Q(3-a(t),wv,av(t))) + alpha_retest*(-dqda(3-a(t),wv,av(t)));
			dqda(a(t),3-wv,av(t)) = dqda(a(t),3-wv,av(t)) + alpha_retest*(1-alpha_retest)*(-rho_retest*r(t)-Q(a(t),3-wv,av(t))) + alpha_retest*(-dqda(a(t),3-wv,av(t)));
			dqda(3-a(t),3-wv,av(t)) = dqda(3-a(t),3-wv,av(t)) + alpha_retest*(1-alpha_retest)*(rho_retest*r(t)-Q(3-a(t),3-wv,av(t))) + alpha_retest*(-dqda(3-a(t),3-wv,av(t)));
		end

		Q(  a(t),wv,av(t)) = Q(  a(t),wv,av(t))+alpha_retest*( rho_retest*r(t)-Q(  a(t),wv,av(t)));
		Q(3-a(t),wv,av(t)) = Q(3-a(t),wv,av(t))+alpha_retest*(-rho_retest*r(t)-Q(3-a(t),wv,av(t)));
		Q(  a(t),3-wv,av(t)) = Q(  a(t),3-wv,av(t))+alpha_retest*(-rho_retest*r(t)-Q(  a(t),3-wv,av(t)));
		Q(3-a(t),3-wv,av(t)) = Q(3-a(t),3-wv,av(t))+alpha_retest*( rho_retest*r(t)-Q(3-a(t),3-wv,av(t)));

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

