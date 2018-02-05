function [l,dl,a,r,Pa,Pa2] = llsrhop(x,D,mu,nui,doprior,op);
% 
% [l,dl,a,r,Pa,Pa2] = llsrhop(x,D,mu,nui,doprior,op);
% 
% log likelihood (l) and gradient (dl) of pruning model. Discount model but 
% fitting separate reward sensitivities to separate outcomes. 
% 
% Use this within emfit.m to tit RL type models to a group of subjects using EM. 
% 
% Huys QJM*, Eshel N*, O'Lions E, Sheridan L, Dayan P and Roiser JP (2012):
% Bonsai trees in your head: How the Pavlovian system sculpts goal-directed
% choices by pruning decision trees PLoS Comp Biol 8(3): e1002410 
%
% Huys QJM, Lally N, Faulkner P, Eshel N, Seifritz E, Gershman SJ, Dayan P and
% Roiser JP (2015): The interplay of approximate planning strategies PNAS,
% 112(10):3098-3103
%
% Quentin Huys 2011-2017 qhuys@cantab.net
np = length(x);
rho = x(1:4);							% sensitivities to outcomes 
pr = 1./(1+exp(-x(5)));				% flat pruning probability 

% add Gaussian prior with mean mu and variance nui^-1 if doprior = 1 
[lp,dlp] = logGaussianPrior(x,mu,nui,doprior);

Z = D.Z;

if nargout==3; Qp=zeros(length(D.an)-Z.include,2^max(D.dn));end


for k=1:length(D.an);

	dn=D.dn(k); 
	sn=D.sn(k); 
	an=D.an(k);
	i=1:2^dn;

	ri = Z.Ri(1:dn,i,dn-2,sn);
	pg = Z.D (1:dn,i,dn-2,sn);


	s  = Z.S (2:dn+1,i,dn-2,sn);	% V of next states added to R 
 
 
 
 
 
 
 
 
 

	r = rho(ri);
	prg = pr.^pg;

 
 

	Q0      = sum(r    .* prg ); 
	if nargout==3; Qp(k-Z.include+1,1:2^D.dn(k)) = Q0; end

	clear dQdr;
	for kk=1:4

		dQdr(kk,:) = sum((ri==kk) .* prg );
	end
	dQ0dprg = sum(r  .* pr.^(pg-1).*pg * pr*(1-pr));

 
 

	tmp = Q0;
	l0 = max(tmp);
	la = tmp-l0 - log(sum(exp(tmp-l0)));
	pa = exp(la);

	l(k) = la(an);

	for kk=1:4
		dl(kk,k) = dQdr(kk,an) - dQdr(kk,:)*pa';
	end
	dl(5,k) = dQ0dprg(an) - dQ0dprg*pa';

 
 
end
l  = -sum(l) - sum(lp);
dl = -sum(dl,2) - dlp;

