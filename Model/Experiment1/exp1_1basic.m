
nSweep=8;

dSimHist={};

parfor i=1:nSweep
    dSimHist{i}=exp1_ABMarket();
end

return;

%Calc Optimal Response
DSim=dSimHist{1};
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

touWindow=5*60;
touMid=floor(touWindow/2);
touPrice=optPrice;
touWindowPrice=touPrice(touMid:touWindow:end);
touResidual=zeros(length(time),1);
parfor i=1:length(time)-1;
    k=floor(time(i)/touWindow)+1;
    touPrice(i)=touWindowPrice(k);
    touResidual(i)=dsim.calcPowerLevels(touPrice(i),MktList,[],time(i));
end


priceHist=[];
residualHist=[];
for i=1:nSweep
    DSim=dSimHist{i};
    logger=DSim.getAgentsByName('dsim.MktLogger');
    logger=logger{1};
    priceHist(i,:)=logger.priceHist(2:end);
    residualHist(i,:)=abs(logger.residualHist(2:end));
    
end
figure;
hold all;
x=2:size(priceHist,2)+1;
y1=mean(priceHist);
plot(x(1:1:end)/60,y1(1:1:end),'-','linewidth',2);
plot((time(1:50:end)+1)/60,optPrice(1:50:end),':','linewidth',3);
plot((time(1:20:end)+1)/60,touPrice(1:20:end),'--','linewidth',3);
xlabel('Time (m)');
ylabel('LMP ($)');
legend('Online','Optimal','TOU');
set(gca,'FontSize',16);
xlim([0 60]);
hold off;

figure;
hold on;
plot(x/60,mean(residualHist),'linewidth',2);
plot((time(1:20:end)+1)/60,touResidual(1:20:end),'--','linewidth',2);
xlabel('Time (m)');
ylabel('Residual Power (W)');
legend('Online','TOU');
set(gca,'FontSize',16);
xlim([0 60]);
hold off;

onlineM=mean(mean(residualHist));
touM=mean(touResidual);
diff=touM-onlineM;
pctChange=diff/touM*100
