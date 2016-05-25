
nSweep_p1=8;
nSweep_p2=6;
randSeed=5;

dSimHist={};


fracSpace=logspace(0.3011,2.2,nSweep_p1);
latSpace=1:2:2*nSweep_p2;

parfor i=1:nSweep_p1
  	for k=1:nSweep_p2
        for j=1:randSeed
            dSimHist{i,k,j}=exp2_ABMarket_latency(latSpace(k),fracSpace(i),5); %latencyMag,latencyFrac,nPar)
        end
    end
end

return;

%Calc Optimal Response
DSim=dSimHist{1,1};

aList=DSim.getAgentsByName('dsim.MktPlayer');
for i=1:length(aList)
    agent=aList{i};
    if agent.Pmax>0
        agent.APmax=0;
        agent.APmin=0;
    end
end

MktList={};
ISO=[];
nAgents=length(DSim.agentList);
time=2:DSim.endTime;
for i=1:nAgents
    agent=DSim.agentList{i};
    if isa(agent,'dsim.ISO')
        ISO=agent;
    elseif isa(agent,'dsim.MktPlayer')
        MktList{end+1}=agent;
    end
end

optPrice=zeros(length(time),1);
parfor i=1:length(time)
    optPrice(i)=dsim.optimalPrice(MktList,[],time(i));
end

shiftOptPrice=optPrice;
aList=DSim.getAgentsByName('dsim.MktPlayer');
for i=1:length(aList)
    agent=aList{i};
    if agent.Pmax>0
        agent.APmax=0.5;
        agent.APmin=0.1;
    end
end

worstResidual=zeros(length(time),1);
parfor i=100:1:length(optPrice)
    shiftOptPrice(i)=dsim.optimalPrice(aList,[],time(i));
    worstResidual(i)=dsim.calcPowerLevels(optPrice(i),aList,[],time(i));
end


%Dsim{frac,lat}
%fracSpace=10:10:10*nSweep_p1;
%latSpace=1:nSweep_p2;
priceHist=[];
residualHist=[];
for i=1:length(fracSpace)
    for k=1:length(latSpace)
        priceHistt=[];
        residualHistt=[];
        for j=1:randSeed
            DSim=dSimHist{i,k};
            logger=DSim.getAgentsByName('dsim.MktLogger');
            logger=logger{1};
            priceHistt(j,:)=logger.priceHist(2:end);
            residualHistt(j,:)=abs(logger.residualHist(2:end));
        end
        priceHist(i,k,:)=mean(priceHistt,1);
        residualHist(i,k,:)=mean(residualHistt,1);
    end
end

%plot(squeeze(residualHist([7 8],1,:))')
%plot(fracSpace,mean(squeeze(residualHist(:,1,:))'))
%plot(latSpace,mean(squeeze(residualHist(7,:,:))'));
%plot(squeeze(residualHist([1 2 3 4],1,:))')

figure;
hold all;
y=mean(squeeze(mean(residualHist,2)),2);
y2=ones(length(y),1).*mean(worstResidual);
plot(1./fracSpace*100,y,'linewidth',2);
plot(1./fracSpace*100,y2,'--','linewidth',2);
hold off;
xlabel('Pct. of Impacted Clients');
ylabel('Mean Residual Power');
legend('Online','Fixed Price');
set(gca,'FontSize',16);



figure;
plot(latSpace,mean(squeeze(mean(residualHist,1)),2),'linewidth',2);
xlabel('Latency (1/Ts)');
ylabel('Mean Residual Power');
set(gca,'FontSize',16);



figure;
hold all;
x=2:size(priceHist,2)+1;
y1=mean(priceHist);
plot(x(1:1:end)/60,priceHist(:,1:1:end),'-','linewidth',2);
%plot((time(1:50:end)+1)/60,optPrice(1:50:end),':','linewidth',3);
plot((time(1:1:end)+1)/60,shiftOptPrice(1:1:end),':','linewidth',3);
%plot((time(1:1:end)+1)/60,touPrice(1:1:end),'--','linewidth',3);
xlabel('Time (m)');
ylabel('LMP ($)');
%legend('Online','Optimal');%,'TOU');
set(gca,'FontSize',16);
xlim([0 600/60]);
hold off;

figure;
hold on;
y1=(residualHist(1:6:end,:));
plot(x/60,y1(1,:),'linewidth',2);
plot(x/60,y1(2,:),'--','linewidth',2);
plot(x/60,y1(3,:),':','linewidth',2);
plot(x/60,y1(4,:),'-.','linewidth',2);
%plot((time(1:1:end)+1)/60,touResidual(1:1:end),'--','linewidth',2);
xlabel('Time (m)');
ylabel('Residual Power (W)');
%legend('Online','TOU');
legstr={};
k=1;
for i=1:6:length(rbParam)
    legstr{k}=['\beta = ' num2str(rbParam(i))];
    k=k+1;
end
legend('\beta=1e-5','\beta=1e-3','\beta=1e-1','\beta=10');
set(gca,'FontSize',16);
xlim([0 600/60]);
hold off;

figure;
y1=mean(residualHist(:,[1:199]),2);
y2=mean(residualHist(:,:),2);

semilogx(rbParam,y1,'linewidth',2);
hold on;
semilogx(rbParam,y2,'--','linewidth',2);
hold off;
xlabel('\beta');
ylabel('Average Residual Power');
set(gca,'FontSize',16);
legend('w/o Transient','w/ Transient');
xlim([rbParam(1) rbParam(end)]);



figure;
y1=mean(residualHist(:,[1:199]),2);
y2=mean(residualHist(:,:),2);

plot(nParam,y1,'linewidth',2);
hold on;
plot(nParam,y2,'--','linewidth',2);
hold off;
xlabel('n');
ylabel('Average Residual Power');
set(gca,'FontSize',16);
legend('w/o Transient','w/ Transient');
xlim([nParam(1) nParam(end)]);


figure;
hold on;
y1=(residualHist(1:2:end,:));
plot(x/60,y1(1,:),'linewidth',2);
plot(x/60,y1(2,:),'--','linewidth',2);
plot(x/60,y1(3,:),':','linewidth',2);
plot(x/60,y1(4,:),'-.','linewidth',2);
%plot((time(1:1:end)+1)/60,touResidual(1:1:end),'--','linewidth',2);
xlabel('Time (m)');
ylabel('Residual Power (W)');
%legend('Online','TOU');
legstr={};
k=1;
for i=1:6:length(rbParam)
    legstr{k}=['\beta = ' num2str(rbParam(i))];
    k=k+1;
end
legend('\beta=1e-5','\beta=1e-3','\beta=1e-1','\beta=10');
set(gca,'FontSize',16);
xlim([0 600/60]);
hold off;
