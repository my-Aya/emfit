function model = modelList; 
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

i=0; 

i=i+1; 
model(i).descr = 'Attention task self-learning only, one beta';
model(i).name = 'llbe';			
model(i).npar = 2;
model(i).parnames = {'\beta','\alpha_{self}'};
model(i).parnames_untr = {'log \beta','siginv \alpha_{self}'};
model(i).partransform = {'@(x)exp(x)','@(x)1./(1+exp(-x))'};

i=i+1; 
model(i).descr = 'Attention task self-learning only, one beta, bias by other''s action';
model(i).name = 'llbeb';			
model(i).npar = 3;
model(i).parnames = {'\beta','\alpha_{self}','bias'};
model(i).parnames_untr = {'log \beta','siginv \alpha_{self}','b'};
model(i).partransform = {'@(x)exp(x)','@(x)1./(1+exp(-x))','@(x)x'};

i=i+1; 
model(i).descr = 'Attention task self-learning before other-learning, one beta';
model(i).name = 'llcrosslearn';			
model(i).npar = 3;
model(i).parnames = {'\beta','\alpha_{self}','\alpha_{other}'};
model(i).parnames_untr = {'log \beta','siginv \alpha_{self}','siginv \alpha_{other}'};
model(i).partransform = {'@(x)exp(x)','@(x)1./(1+exp(-x))','@(x)1./(1+exp(-x))'};

i=i+1; 
model(i).descr = 'Attention task self-learning before other-learning, one beta';
model(i).name = 'llcrosslearn2b2e';			
model(i).npar = 4;
model(i).parnames = {'\beta_{self}','\beta_{other}','\alpha_{self}','\alpha_{other}'};
model(i).parnames_untr = {'log \beta_{self}','log \beta_{other}','siginv \alpha_{self}','siginv \alpha_{other}'};
model(i).partransform = {'@(x)exp(x)','@(x)exp(x)','@(x)1./(1+exp(-x))','@(x)1./(1+exp(-x))'};

i=i+1; 
model(i).descr = 'Attention task Likelihood ratings - self';
model(i).name = 'llratings';			
model(i).npar = 3;
model(i).parnames = {'\gamma','w_{self}','w_{other}'};
model(i).parnames_untr = {'siginv \gamma','w_{self}','w_{other}'};
model(i).partransform = {'@(x)1./(1+exp(-x))','@(x)x','@(x)x'};

i=i+1; 
model(i).descr = 'Attention task self-learning + Likelihood ratings - self';
model(i).name = 'llratingsbe';			
model(i).npar = 7;
model(i).parnames = {'\beta','\alpha_{self}','\gamma','w_{selfRew}','w_{otherRew}','w_{Value}','w_{Time}'};
model(i).parnames_untr = {'log \beta','siginv \alpha_{self}','siginv \gamma','w_{selfRew}','w_{otherRew}','w_{Value}','w_{Time}'};
model(i).partransform = {'@(x)exp(x)','@(x)1./(1+exp(-x))','@(x)1./(1+exp(-x))','@(x)x','@(x)x','@(x)x','@(x)x'};
