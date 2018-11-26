function [pt, dv, da, dz, dt] = wfpt_prep(b,v,sp,time)
% Prepares data to calculate the probability for Wiener first passage time
% according to Navarro et al 2009.
pt = []; 
dv = [];
da = [];
dz = [];
dt = [];
err = 10^(-29);

% Probability of making low choice (1)
% Drift rate is defined as negative if value for high options is better. 
% Thus, sign for drift rate must be swapped for low choice.
% Starting point is defined, such that 1-sp is the distance to boundaries
% for low choice
[pt(1), dv(1), da(1), dz(1), dt(1)] = wfpt_all(time,-v,b,b-sp,err);


% Probability of making high choice (2)
[pt(2), dv(2), da(2), dz(2), dt(2)]  = wfpt_all(time,v,b,sp,err); 

end         