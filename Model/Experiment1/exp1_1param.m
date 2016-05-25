
nSweep=8;

dSimHist={};

rbParam=logspace(-5,3,nSweep);
rwParam=logspace(-5,1,nSweep);
nParam=1:nSweep;

parfor i=1:nSweep
    %rbParam(i)
    dSimHist{i}=exp1_ABMarket_param(0.06,0.02,nParam(i));%rwParam(i));rbParam(i)
end

return;

%Calc Optimal Response
DSim=dSimHist{1};

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

shiftOptPrice=optPrice;
aList=DSim.getAgentsByName('dsim.MktPlayer');
for i=1:length(aList)
    agent=aList{i};
    if agent.Pmax>0
        agent.APmax=0.5;
        agent.APmin=0.1;
    end
end

parfor i=200:1:399
    shiftOptPrice(i)=dsim.optimalPrice(aList,[],time(i));
    touResidual(i)=dsim.calcPowerLevels(touPrice(i),aList,[],time(i));
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
