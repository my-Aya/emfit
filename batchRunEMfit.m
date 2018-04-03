function batchRunEMfit(modelClassToFit,Data,resultsDir,varargin);
% 
% batchRunEMfit(modelClassToFit,pathToData,resultsDir);
% 
% Performs batch EM inference by first fitting a set of models from each model
% class, plotting the inferred parameters, performing iBIC model comparison,
% generating surrogate data and performing some visual comparisons of the true
% and surrogate data. 
%
% MODELCLASSTOFIT determines which model sets are fitted: 
% 
% 'mBasicRescorlaWagner';			% basic Rescorla-Wagner example 
% 'mAffectiveGoNogo';				% Guitart et al. 2012 
% 'mProbabilisticReward';			% Huys et al., 2013 
% 'mTwostep';							% Daw et al., 2011 
% 'mEffortCollins';	 				% Gold et al., 2013 
% 'mPruning'; 						   % Lally et al., 2017 
%   
% DATA (optional) contains the data.  See the dataformat.txt files in the model
% folders for instructions on how the data contained in DATA should be formatted
% for fitting. For demo purposes, a correct dataset is generated if no data is
% provided. 
% 
% RESULTSDIR (optional) is a path to a directory containing the results. If it
% is not provided then fitResults in the current working directory is used. 
% 
% MODELSTOFIT (optional) is a vector with indices of specific models to fit, as
% per the modelList definition in each model folder mXXXX. 
% 
% Quentin Huys, 2018 qhuys@cantab.net
% 
%==============================================================================

if exist('resultsDir')~=1 | isempty(resultsDir); 
	resultsDir = [pwd '/fitResults'];
end
warning('off','MATLAB:MKDIR:DirectoryExists');
mkdir(resultsDir);

if exist('varargin');
	i = find(cellfun(@(x)strcmpi(x,'modelsToFit'),varargin));
	if ~isempty(i); modelsToFit = varargin{i+1};end
end

%------------------------------------------------------------------------------
% MODEL CLASS - define which type of model to fit 
 
modelClass{1} = 'mBasicRescorlaWagner';			% basic example 
modelClass{2} = 'mAffectiveGoNogo';					% Guitart et al. 2012 
modelClass{3} = 'mProbabilisticReward';			% Huys et al., 2013 
modelClass{4} = 'mTwostep';							% Daw et al., 2011 
modelClass{5} = 'mEffortCollins';	 				% Gold et al., 2013 
modelClass{6} = 'mPruning'; 							% Lally et al., 2017 
modelClassToFit = find(cellfun(@(x)strcmp(x,modelClassToFit),modelClass)); 
if isempty(modelClassToFit); error('Model class not found');end

%==============================================================================
% everything below here should just run without alterations 

%------------------------------------------------------------------------------
% get model descriptions 
emfitpath = fileparts(which('batchRunEMfit'));
addpath([emfitpath '/lib']); 
cleanpath(modelClass);									% clean all model paths 
addpath(genpath([emfitpath '/' modelClass{modelClassToFit}]));	% add chosen model path
models=modelList; 										% get complete model list 
if exist('modelsToFit')
	models = models(modelsToFit); 							% select specific models to fit 
end

%------------------------------------------------------------------------------
% generate surrogate data if no data was provided
if ~exist('Data') | isempty(Data)
	fprintf('No data provided so generating example dataset\n');
	Data=generateExampleDataset(30); 			
end

%------------------------------------------------------------------------------
% fit models using emfit.m
options.checkgradients = 0;							% check gradients of models? 
options.bsub = 0; 										% submit to bsub? - in progress 
options.resultsDir = resultsDir; 					% directory with results
batchModelFit(Data,models,options); 				% perform the fitting

%------------------------------------------------------------------------------
% perform model comparison 
bestmodel = batchModelComparison(Data,models,resultsDir);

%------------------------------------------------------------------------------
% plot parameters of best model 
batchParameterPlots(Data,models,resultsDir,bestmodel); 

%------------------------------------------------------------------------------
% generate surrogate data 
options.nSamples=100;
batchGenerateSurrogateData(Data,models,options);

%------------------------------------------------------------------------------
% plot surrogate data, compare with real data (specific to model)
load([resultsDir '/SurrogateData']); 
surrogateDataPlots(Data,models,SurrogateData,bestmodel,resultsDir)

fprintf('\n\nAll done!\n\n')
