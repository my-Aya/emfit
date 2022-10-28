function Data=generateExampleDataset(Nsj,resultsDir)
% 
% Data = generateExampleDataset(Nsj)
% 
% Generate example dataset containing Nsj subjects for affective Go/Nogo task using the
% standard model llbaepqx.m
% 
% Quentin Huys 2018 www.quentinhuys.com 


fprintf('Generating example dataset for attention fishing task\n')

% load other behaviour and fixed reward sequence 
rewardSequence = table2array(readtable('RewardSequence.csv'));

options.generatesurrogatedata=1; 

T = 150; 
for sj=1:Nsj; 
	Data(sj).ID = sprintf('Subj %i',sj);
	
	Data(sj).a = zeros(2,T);					% preallocate space
	Data(sj).r = zeros(2,T);					% preallocate space

	Data(sj).rewardSequence = rewardSequence(:,1:2)'; 
	Data(sj).a(2,:) = 1+(rewardSequence(:,3)'==2); 
	Data(sj).r(2,:) = rewardSequence(:,4)'; 

	Data(sj).Nch = T; 							% length 

	% realistic random parameters 
	Data(sj).trueParam = [1 1.5 -1.5 ]'+.7*randn(3,1);

	% generate choices A, state transitions S and rewards R 
	[foo,foo,dsurr] = llcrosslearn(Data(sj).trueParam,Data(sj),0,0,0,options); 
	Data(sj).a = dsurr.a;
	Data(sj).r = dsurr.r;
	Data(sj).trueModel='llcrosslearn';

end

fprintf('Saved example dataset as Data.mat\n');
save([resultsDir filesep 'Data.mat'],'Data');
