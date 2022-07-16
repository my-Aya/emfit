function model = kk_modelList
%
% A file like this should be contained in each model class folder and list the
% models to be run, together with some descriptive features.
%
% GENERAL INFO:
%
% list the models to run here. The models must be defined as likelihood functions in
% the models folder. They must have the form:
%
%    [l,dl,dsurr] = ll(parameters,dataToFit,PriorMean,PriorInverseCovariance,doPrior,otherOptions)
%
% where otherOptions.generatesurrogatedata is a binary flag defining whether to apply the prior, and
% doGenerate is a flag defining whether surrogate data (output in asurr) is
% generated.
%
% name: names of model likelihood function in folder models
% npar: number of paramters for each
% parnames: names of parameters for plotting
% partransform: what to do to the (transformed) parameter estimates to transform them into the
% parameters
%
% SPECIFIC INFO:
%
% This contain models for the self/other judgement task.
%
% Quentin Huys 2021

i=0;

i=i+1;
model(i).descr = 'simple model (no learning) with self and other bias towards accepting positive words';
model(i).name = 'llb';
model(i).npar = 2;
model(i).parnames = {'bias self','bias other'};
model(i).parnames_untr = {'b_s','b_o'};
model(i).partransform = {'@(x)x','@(x)x'};

% i=i+1;
% model(i).descr = 'RW model, restart for each avatar and two self/other bias parameters (shared across words). Words are part of state';
% model(i).name = 'll6avb';
% model(i).npar = 4;
% model(i).parnames = {'\rho','\alpha','bias self','bias other'};
% model(i).parnames_untr = {'log \rho','siginv \alpha','b_s','b_o'};
% model(i).partransform = {'@(x)exp(x)','@(x)1./(1+exp(-x))','@(x)x','@(x)x'};
% 
% i=i+1;
% model(i).descr = 'RW model with double update (for opposite action, same word), restart for each avatar and two self/other bias parameters (shared across words). Words are part of state';
% model(i).name = 'lld6avb';
% model(i).npar = 4;
% model(i).parnames = {'\rho','\alpha','bias self','bias other'};
% model(i).parnames_untr = {'log \rho','siginv \alpha','b_s','b_o'};
% model(i).partransform = {'@(x)exp(x)','@(x)1./(1+exp(-x))','@(x)x','@(x)x'};

i=i+1;
model(i).descr = 'RW model with quadruple update (for all 4 action-word combinations), restart for each avatar and two self/other bias parameters (shared across words). Words are part of state';
model(i).name = 'llq6avb';
model(i).npar = 4;
model(i).parnames = {'\rho','\alpha','bias self','bias other'};
model(i).parnames_untr = {'log \rho','siginv \alpha','b_s','b_o'};
model(i).partransform = {'@(x)exp(x)','@(x)1./(1+exp(-x))','@(x)x','@(x)x'};

i=i+1;
model(i).descr = 'RW model with quadruple update (sep LR), restart for each avatar and two self/other bias parameters (shared across words). Words are part of state';
model(i).name = 'llq6avbsep';
model(i).npar = 5;
model(i).parnames = {'\rho','\alpha_pos','\alpha_neg','bias self','bias other'};
model(i).parnames_untr = {'log \rho','siginv \alpha_pos','siginv \alpha_neg','b_s','b_o'};
model(i).partransform = {'@(x)exp(x)','@(x)1./(1+exp(-x))','@(x)1./(1+exp(-x))','@(x)x','@(x)x'};

% i=i+1;
% model(i).descr = 'RW model, restart for each avatar and two self/other bias parameters (shared across words). No words in state';
% model(i).name = 'll6avbnowords';
% model(i).npar = 4;
% model(i).parnames = {'\rho','\alpha','bias self','bias other'};
% model(i).parnames_untr = {'log \rho','siginv \alpha','b_s','b_o'};
% model(i).partransform = {'@(x)exp(x)','@(x)1./(1+exp(-x))','@(x)x','@(x)x'};

% i=i+1;
% model(i).descr = 'RW model with double update (for opposite action), restart for each avatar and two self/other bias parameters (shared across words). No words in state';
% model(i).name = 'lld6avbnowords';
% model(i).npar = 4;
% model(i).parnames = {'\rho','\alpha','bias self','bias other'};
% model(i).parnames_untr = {'log \rho','siginv \alpha','b_s','b_o'};
% model(i).partransform = {'@(x)exp(x)','@(x)1./(1+exp(-x))','@(x)x','@(x)x'};

i=i+1;
model(i).descr = 'RW model, restart for each avatar and four bias parameters (self/other, pos/neg words). Words are part of state';
model(i).name = 'll6av4b';
model(i).npar = 6;
model(i).parnames = {'\rho','\alpha','bias self neg','bias other neg', 'bias self pos', 'bias other pos'};
model(i).parnames_untr = {'log \rho','siginv \alpha','b_{s,n}','b_{o,n}','b_{s,p}','b_{o,p}'};
model(i).partransform = {'@(x)exp(x)','@(x)1./(1+exp(-x))','@(x)x','@(x)x','@(x)x','@(x)x'};

i=i+1;
model(i).descr = 'RW model (sep LR), restart for each avatar and four bias parameters (self/other, pos/neg words). Words are part of state';
model(i).name = 'll6av4bsep';
model(i).npar = 7;
model(i).parnames = {'\rho','\alpha_pos','\alpha_neg','bias self neg','bias other neg', 'bias self pos', 'bias other pos'};
model(i).parnames_untr = {'log \rho','siginv \alpha_pos','siginv \alpha_neg','b_{s,n}','b_{o,n}','b_{s,p}','b_{o,p}'};
model(i).partransform = {'@(x)exp(x)','@(x)1./(1+exp(-x))','@(x)1./(1+exp(-x))','@(x)x','@(x)x','@(x)x','@(x)x'};

i=i+1;
model(i).descr = 'RW model with quadruple update, restart for each avatar and four bias parameters (self/other, pos/neg words). Words are part of state';
model(i).name = 'llq6av4b';
model(i).npar = 6;
model(i).parnames = {'\rho','\alpha','bias self neg','bias other neg', 'bias self pos', 'bias other pos'};
model(i).parnames_untr = {'log \rho','siginv \alpha','b_{s,n}','b_{o,n}','b_{s,p}','b_{o,p}'};
model(i).partransform = {'@(x)exp(x)','@(x)1./(1+exp(-x))','@(x)x','@(x)x','@(x)x','@(x)x'};

%%% FIX
i=i+1;
model(i).descr = 'RW model with quadruple update (sep LR), restart for each avatar and four bias parameters (self/other, pos/neg words). Words are part of state';
model(i).name = 'llq6av4bsep';
model(i).npar = 7;
model(i).parnames = {'\rho','\alpha_pos','\alpha_neg','bias self neg','bias other neg', 'bias self pos', 'bias other pos'};
model(i).parnames_untr = {'log \rho','siginv \alpha_pos','siginv \alpha_neg','b_{s,n}','b_{o,n}','b_{s,p}','b_{o,p}'};
model(i).partransform = {'@(x)exp(x)','@(x)1./(1+exp(-x))','@(x)1./(1+exp(-x))','@(x)x','@(x)x','@(x)x','@(x)x'};

nModls = i;
fprintf('%i models in model list\n',nModls);
