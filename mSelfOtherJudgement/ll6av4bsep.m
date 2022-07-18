function [l,dl,dsurr] = ll6av4bsep(x,D,mu,nui,doprior,options)
% 
% [l,dl,surrugatedata] = llb(x,D,mu,nui,doprior,options);
% 
% log likelihood (l) and gradient (dl) of simple bias model
% 
% Use this within emfit.m to tit RL type models to a group of subjects using
% EM. 
% 
% Quentin Huys 2021
% Modified by Kaustubh Kulkarni 2022

dodiff=nargout==2;
np = size(x,1);

rho = exp(x(1));
alpha_pos = 1./(1+exp(-x(2)));
alpha_neg = 1./(1+exp(-x(3)));
selfposbias = x(4:7);

% add Gaussian prior with mean mu and variance nui^-1 if doprior = 1 
[l,dl] = logGaussianPrior(x,mu,nui,doprior);

a = D.a; 
r = D.r; 
wordval = D.wordval; 
avatval = D.avatval;
av = D.avatid;

Q = zeros(2,2,12);
dqdr = zeros(2,2,12);
dqdapos = zeros(2,2,12);
dqdaneg = zeros(2,2,12);

if options.generatesurrogatedata==1
	a = zeros(size(a));
	dodiff=0;
end

for t=1:length(a)
	if ~isnan(a(t))

        bl = 1+(t>48);
		wv = (-wordval(t)+3)/2;
		q0 = Q(:,wv,av(t));
		q0(1) = q0(1) + selfposbias(bl+wordval(t)+1)*wordval(t);

		l0 = q0-max(q0);
		l0 = l0 - log(sum(exp(l0)));
		p = exp(l0);

        if options.generatesurrogatedata==1
			[a(t),r(t)] = generatera(p,wordval(t),avatval(t));
        end
        pe_type = (r(t) - Q(a(t),wv,av(t))) > 0;

		l = l+l0(a(t));

		if dodiff
			dl(1) = dl(1) + dqdr(a(t),wv,av(t)) - p'*dqdr(:,wv,av(t));
            dl(2) = dl(2) + dqdapos(a(t),wv,av(t)) - p'*dqdapos(:,wv,av(t));
            dl(3) = dl(3) + dqdaneg(a(t),wv,av(t)) - p'*dqdaneg(:,wv,av(t));
            tmp = [wordval(t);0];  
			dl(4+bl+wordval(t))   = dl(4+bl+wordval(t)) + tmp(a(t)) - p'*tmp;
            if pe_type
                dqdr(a(t),wv,av(t)) = dqdr(a(t),wv,av(t)) + alpha_pos*(rho*r(t) - dqdr(a(t),wv,av(t)));
			    dqdapos(a(t),wv,av(t)) = dqdapos(a(t),wv,av(t)) + alpha_pos*(1-alpha_pos)*(rho*r(t)-Q(a(t),wv,av(t))) + alpha_pos*(-dqdapos(a(t),wv,av(t)));
                dqdaneg(a(t),wv,av(t)) = dqdaneg(a(t),wv,av(t)) + alpha_pos*(-dqdaneg(a(t),wv,av(t)));
            else
                dqdr(a(t),wv,av(t)) = dqdr(a(t),wv,av(t)) + alpha_neg*(rho*r(t) - dqdr(a(t),wv,av(t)));
			    dqdaneg(a(t),wv,av(t)) = dqdaneg(a(t),wv,av(t)) + alpha_neg*(1-alpha_neg)*(rho*r(t)-Q(a(t),wv,av(t))) + alpha_neg*(-dqdaneg(a(t),wv,av(t)));
                dqdapos(a(t),wv,av(t)) = dqdapos(a(t),wv,av(t)) + alpha_neg*(-dqdapos(a(t),wv,av(t)));
            end
            
			
		end
        
        if pe_type
		    Q(  a(t),wv,av(t)) = Q(  a(t),wv,av(t))+alpha_pos*( rho*r(t)-Q(  a(t),wv,av(t)));
        else
            Q(  a(t),wv,av(t)) = Q(  a(t),wv,av(t))+alpha_neg*( rho*r(t)-Q(  a(t),wv,av(t)));
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

