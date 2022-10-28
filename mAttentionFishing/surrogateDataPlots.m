function surrogateDataPlots(Data,models,SurrogateData,bestmodel,fitResults)

nModls = length(models);
Nsj = length(Data);

nfig=get(gcf,'Number');

mkdir figs 

%--------------------------------------------------------------------
% compare with surrogate data 
%--------------------------------------------------------------------
% either generate new data: 
nfig=nfig+1; figure(nfig);clf;

T = length(Data(1).a); 

subplot(2,4,1); 

for mdl=1:nModls
	R.(models(mdl).name) = load(sprintf('%s/%s',fitResults,models(mdl).name));
	LL(mdl,:) = R.(models(mdl).name).stats.LL;
	pc(mdl,:) = exp(-LL(mdl,:)./[Data.Nch]);
	PL(mdl,:) = R.(models(mdl).name).stats.PL;
	pc(mdl,:) = exp(-PL(mdl,:)./[Data.Nch]);
	p(mdl,:) = 1-binocdf(pc(mdl,:).*[Data.Nch],[Data.Nch],.5); 
	
	for sj=1:Nsj; 
		nsample = numel(SurrogateData(sj).(models(mdl).name)); 
		ax = [SurrogateData(sj).(models(mdl).name).a]; 
		as(:,mdl,sj) = mean(reshape(ax(1,:),T,nsample)'-1);
	end
end

plot(pc(mdl,:),'o');
hon
pcx = pc; pcx(p<.05)=NaN; 
plot(pcx,'r*');
plot([1 Nsj],[.5 .5],'k');
hof
xlabel('Subject');
ylabel('Choice posterior likelihood');

subplot(2,4,2); 
i=p<.05; 

plot(R.(models(mdl).name).E(1,:),pc,'o');
hon
plot(R.(models(mdl).name).E(1,~i),pc(~i),'r*');
hof
xlabel('beta');
ylabel('Choice posterior likelihood');


subplot(2,2,2);

aa = [Data.a];
aa = reshape(aa(1,:)-1,150,Nsj)'; 
plot(mean(aa),'k--','linewidth',1); 
hon
plot(mean(as,3),'linewidth',2);
hof
title('All data');
ylabel('Self choices');

subplot(2,2,3);

i = p<.05; 
plot(mean(aa(i,:)),'ko--','linewidth',1); 
hon
plot(mean(as(:,1,i),3),'linewidth',2);
hof
title('Well fit');
ylabel('Self choices');

subplot(2,2,4);

plot(mean(aa(~i,:)),'ko--','linewidth',1); 
hon
plot(mean(as(:,1,~i),3),'linewidth',2);
hof
title('Poor fit');
ylabel('Self choices');

myfig(gcf,[fitResults '/figs/SurrogateDataPlots' ])

if isfield(Data,'spin');
	nfig=nfig+1; figure(nfig);clf;

	spin =[Data.spin]; 

	subplot(131); [c,p] = corr(spin',R.llcrosslearn.E','type','spearman');         bar(c); title('All');
		set(gca,'xticklabel',{'\beta','self','other'})
	subplot(132); [c,p] = corr(spin(i)',R.llcrosslearn.E(:,i)','type','spearman'); bar(c); title('good subjects');
		set(gca,'xticklabel',{'\beta','self','other'})
	subplot(133); [c,p] = corr(spin(~i)',R.llcrosslearn.E(:,~i)','type','spearman'); bar(c); title('bad subjects');
		set(gca,'xticklabel',{'\beta','self','other'})

	nfig=nfig+1; figure(nfig);clf;
	subplot(131); m=mean(R.llcrosslearn.E');       s=std(R.llcrosslearn.E')/sqrt(Nsj);        mybar(m,.7);hon; mydeb(0,m,s);hof; title('All'); set(gca,'xticklabel',{'\beta','self','other'})
	subplot(132); m=mean(R.llcrosslearn.E(:,i)');  s=std(R.llcrosslearn.E(:,i)')/sqrt(sum(i));   mybar(m,.7);hon; mydeb(0,m,s);hof; title('good subjects'); set(gca,'xticklabel',{'\beta','self','other'})
	subplot(133); m=mean(R.llcrosslearn.E(:,~i)'); s=std(R.llcrosslearn.E(:,~i)')/sqrt(sum(~i));  mybar(m,.7);hon; mydeb(0,m,s);hof; title('bad subjects'); set(gca,'xticklabel',{'\beta','self','other'})

	myfig(gcf,[fitResults '/figs/SpinCorrelations']);
end

if isfield(Data,'trueParam');
	nfig=nfig+1; figure(nfig);clf;
	for mdl=1:nModls;
		E = R.(models(mdl).name).E; 
		trueE = [Data.trueParam]; 
		subplot(nModls,3,1); c = diag(corr(E',trueE','type','spearman')); mybar(c,.7); ylim([0 1]);if mdl==1; title('All');end
			set(gca,'xticklabel',models(mdl).parnames)
			ylabel('Correlation with true parameters');
		subplot(nModls,3,2); c = diag(corr(E(:,i)',trueE(:,i)','type','spearman')); mybar(c,.7); ylim([0 1]); if mdl==1; title('Ok fit');end
			set(gca,'xticklabel',models(mdl).parnames)
			ylabel('Correlation with true parameters');
		subplot(nModls,3,3); c = diag(corr(E(:,~i)',trueE(:,~i)','type','spearman')); mybar(c,.7);ylim([0 1]); if mdl==1; title('Bad fit');end
			set(gca,'xticklabel',models(mdl).parnames)
			ylabel('Correlation with true parameters');
	end
	myfig(gcf,[fitResults '/figs/TrueParamsCorrelationsGoodPoorSubjects']);
	
end

keyboard

