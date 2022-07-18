function [l,dl,dsurr] = llb_retest(x,D,mu,nui,doprior,options);
%
% [l,dl,surrugatedata] = llb(x,D,mu,nui,doprior,options);
%
% log likelihood (l) and gradient (dl) of simple bias model
%
% Use this within emfit.m to fit RL type models to a group of subjects using
% EM.
%
% Quentin Huys 2021

dodiff=nargout==2;
np = size(x,1);

selfposbias = x(1:2);
selfposbias_retest = x(3:4);

% add Gaussian prior with mean mu and variance nui^-1 if doprior = 1
[l,dl] = logGaussianPrior(x,mu,nui,doprior);

a = D.a;
r = D.r;
wordVal = D.wordVal;
avatarVal = D.avatarVal;

Q = zeros(2,1);

if options.generatesurrogatedata==1
	a = zeros(size(a));
	dodiff=0;
end


%%%%%%%%%  TEST contribution


for t=1:96;
	if ~isnan(a(t));

		bl = 1+(t>48);

		wv = (-wordVal(t)+3)/2;

		Q(1) = selfposbias(bl)*wordVal(t);
		Q(2) = 0;
		q0 = Q;

		l0 = q0-max(q0);
		l0 = l0 - log(sum(exp(l0)));
		p = exp(l0);

		if options.generatesurrogatedata==1
			[a(t),r(t)] = generatera(p,wordVal(t),avatarVal(t));
		end
		l = l+l0(a(t));

		if dodiff
			tmp = [wordVal(t);0];
			dl(bl)   = dl(bl) + tmp(a(t)) - p'*tmp;
		end

	else
		if options.generatesurrogatedata==1
			a(t) = NaN;
			r(t) = NaN;
		end
	end
end


%%%%%%%%%  RETEST contribution

%  need to reset the Q's and the gradients for the next run
Q = zeros(2,1);



for t=97:192;
	if ~isnan(a(t));

		bl = 1+(t>144);

		wv = (-wordVal(t)+3)/2;

		Q(1) = selfposbias_retest(bl)*wordVal(t);
		Q(2) = 0;
		q0 = Q;

		l0 = q0-max(q0);
		l0 = l0 - log(sum(exp(l0)));
		p = exp(l0);

		if options.generatesurrogatedata==1
			[a(t),r(t)] = generatera(p,wordVal(t),avatarVal(t));
		end
		l = l+l0(a(t));

		if dodiff
			tmp = [wordVal(t);0];
			dl(bl+2)   = dl(bl+2) + tmp(a(t)) - p'*tmp;
		end

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

