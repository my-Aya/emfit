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

subplot(221); 

for mdl=1:nModls
	R.(models(mdl).name) = load(sprintf('%s/%s',fitResults,models(mdl).name));
	LL(mdl,:) = R.(models(mdl).name).stats.LL;
	pc(mdl,:) = exp(-LL(mdl,:)./[Data.Nch]);
	PL(mdl,:) = R.(models(mdl).name).stats.PL;
	pc(mdl,:) = exp(-PL(mdl,:)./[Data.Nch]);
	p(mdl,:) = 1-binocdf(pc(mdl,:).*[Data.Nch],[Data.Nch],.5); 
	
end

plot(pc(mdl,:),'o');
hon
pcx = pc; pcx(p<.05)=NaN; 
plot(pcx,'r*');
plot([1 Nsj],[.5 .5],'k');
hof



subplot(2,2,2);

aa = [Data.a];
aa = reshape(aa(1,:)-1,150,22)'; 
plot(mean(aa),'k--','linewidth',1); 
hon

for mdl=1:nModls;
	for sj=1:Nsj; 
		nsample = numel(SurrogateData(sj).(models(mdl).name)); 
		ax = [SurrogateData(sj).(models(mdl).name).a]; 
		as(:,mdl,sj) = mean(reshape(ax(1,:),T,nsample)'-1);
	end
end

plot(mean(as,3),'linewidth',2);
hof

subplot(2,2,3);

i = p<.05; 
plot(mean(aa(i,:)),'ko--','linewidth',1); 
hon
plot(mean(as(:,1,i),3),'linewidth',2);
hof

subplot(2,2,4);

plot(mean(aa(~i,:)),'ko--','linewidth',1); 
hon
plot(mean(as(:,1,~i),3),'linewidth',2);
hof


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

keyboard

