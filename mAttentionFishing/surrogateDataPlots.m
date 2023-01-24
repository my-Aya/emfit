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

subplot(2,4,1); 
	plot(pc(bestmodel,:),'o');
	hon
	pcx = pc(bestmodel,:); pcx(p(bestmodel,:)<.05)=NaN; 
	plot(pcx,'r*');
	plot([1 Nsj],[.5 .5],'k');
	hof
	xlabel('Subject');
	ylabel('Choice posterior likelihood');

subplot(2,4,2); 

	i=p(bestmodel,:)<.05; 

	plot(R.(models(bestmodel).name).E(1,:),pc(bestmodel,:),'o');
	hon
	plot(R.(models(bestmodel).name).E(1,~i),pc(bestmodel,~i),'r*');
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
	legend({'Data',models.name})

subplot(2,2,3);
	i = p(bestmodel,:)<.05; 
	plot(mean(aa(i,:)),'ko--','linewidth',1); 
	hon
	plot(mean(as(:,:,i),3),'linewidth',2);
	hof
	title('Well fit');
	ylabel('Self choices');

subplot(2,2,4);
	plot(mean(aa(~i,:)),'ko--','linewidth',1); 
	hon
	plot(mean(as(:,:,~i),3),'linewidth',2);
	hof
	title('Poor fit');
	ylabel('Self choices');

myfig(gcf,[fitResults '/figs/SurrogateDataPlots' ])

if isfield(Data,'spin');
	nfig=nfig+1; figure(nfig);clf;

	spin =[Data.spin]; 
	j=~isnan(spin);


	subplot(131); [c] = corr(spin(j)',R.(models(bestmodel).name).E(:,j)','type','spearman');         bar(c); title('All');
		set(gca,'xticklabel',models(bestmodel).parnames);
		ylabel('Spearman correlation with SPIN');
	subplot(132); [c] = corr(spin(i&j)',R.(models(bestmodel).name).E(:,i&j)','type','spearman'); bar(c); title('good subjects');
		set(gca,'xticklabel',models(bestmodel).parnames);
	subplot(133); [c] = corr(spin(~i&j)',R.(models(bestmodel).name).E(:,~i&j)','type','spearman'); bar(c); title('bad subjects');
		set(gca,'xticklabel',models(bestmodel).parnames);
	myfig(gcf,[fitResults '/figs/SpinCorrelations']);

	nfig=nfig+1; figure(nfig);clf;
	subplot(131); 
		m=mean(R.(models(bestmodel).name).E');
		s=std(R.(models(bestmodel).name).E')/sqrt(Nsj);        
		mybar(m,.7);hon;
		mydeb(0,m,s);hof; title('All');
		set(gca,'xticklabel',models(bestmodel).parnames); ylabel('Mean \pm ste / 90%CI parameter estimates')
	subplot(132); 
		m=mean(R.(models(bestmodel).name).E(:,i)');
		s=std(R.(models(bestmodel).name).E(:,i)')/sqrt(sum(i));   
		mybar(m,.7);hon;
		mydeb(0,m,s);hof; title('good subjects');
		set(gca,'xticklabel',models(bestmodel).parnames);
	subplot(133); 
		m=mean(R.(models(bestmodel).name).E(:,~i)');
		s=std(R.(models(bestmodel).name).E(:,~i)')/sqrt(sum(~i));  
		mybar(m,.7);hon;
		mydeb(0,m,s);hof; title('bad subjects');
		set(gca,'xticklabel',models(bestmodel).parnames); 
	myfig(gcf,[fitResults '/figs/MeanParametersGoodBadFits']);

	nfig=nfig+1; figure(nfig);clf;
		for mdl=1:nModls
			for k=1:models(mdl).npar
				subplot(nModls,models(mdl).npar,k+(mdl-1)*models(mdl).npar)
					j = ~isnan(spin);
					spinj = spin(j);
					e = R.(models(mdl).name).E(k,j); 
					X = [ones(sum(~isnan(spin)),1) spinj'];
					a = (X'*X)\X'*e'; 
					plot(spinj,e,'k.','markersize',15);
					hon
					plot(spinj,X*a,'r');
					i = p(mdl,j)<.05; 
					a = (X(i,:)'*X(i,:))\X(i,:)'*e(i)'; 
					plot(spinj(i),e(i),'bo','markersize',10);
					plot(spinj(i),X(i,:)*a,'b');
					hof
					xlabel('spin');
					ylabel(models(mdl).parnames_untr(k));
					[cx,px] = corr(e',spinj','type','spearman');
					[cy,py] = corr(e(i)',spinj(i)','type','spearman');
					title(sprintf('all: c=%.2g p=%.2g, good: c=%.2g p=%.2g',cx,px,cy,py));
			end
		end
		   myfig(gcf,[fitResults '/figs/SpinFullCorrelationDetails']);

	% nfig=nfig+1; figure(nfig);clf;
	% 	i = p(mdl,:)<.05; 
	% 	e = R.llcrosslearn2b2e.E; 
	% 	de = e(3,:)-e(4,:);
	% 	[cx,px] = corr(de',spin','type','spearman');
	% 	a = (X'*X)\X'*de'; 
	% 	plot(spin,de,'k.','markersize',15);
	% 	hon
	% 	plot(spin,X*a,'r');
	% 	plot(spin(i),de(i),'r.','markersize',20);
	% 	[cxi,pxi] = corr(de(i)',spin(i)','type','spearman');
	% 	hof


end

if isfield(Data,'likSelf');
	nfig=nfig+1; figure(nfig);clf;
	nx=ceil(sqrt(Nsj));
	for sj=1:Nsj
		subplot(nx,nx,sj);
		surrlikSelf = mean(reshape([SurrogateData(sj).(models(mdl).name).likSelf],T,nsample)'); 
		surrv       = mean(reshape([SurrogateData(sj).(models(mdl).name).v],2,T,nsample),3); 

		i = ~isnan(Data(sj).likSelf); 

		plot(surrlikSelf,'r');
		hon
		plot(find(i),Data(sj).likSelf(i),'k.-','linewidth',2);
		plot(find(i),surrlikSelf(i),'r.','linewidth',2,'markersize',20);
		hof
		set(gca,'xticklabel',[],'yticklabel',[]);
		[cx,px] = corr(surrlikSelf(i)',Data(sj).likSelf(i));
		title(sprintf('c=%.2g¸ p=%.2g',cx,px));
	end

keyboard

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


