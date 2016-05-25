function  DSim=exp1_ABMarket_param(Rb,Rw,nPar)
%ABMARKET Summary of this function goes here
%   Detailed explanation goes here

clear DSim;
clc;

nConsumer=100;
nGen=2;
targetPower=100;

genVariance=0;
consumerVariance=0;

[genList,conList]=dsim.genModel(nConsumer,nGen,targetPower,genVariance,consumerVariance);

deviation=0;%0.05;
genTC=60*60*2/(2*pi);
conTC=60*60*2/(2*pi);
genMag=0;%targetPower/nGen*0.1;
conMag=targetPower/nConsumer*0.35;
genTS=0;
conTS=60*60*0;

[genList,conList] = dsim.addTimeModel(genList,conList,genTC,conTC,genMag,conMag,genTS,conTS,deviation);

predictVariance=0.001;
predictOffset=-0.1; %Pct
predictLAConst=30;

[genList,conList] = dsim.addPredictModel(genList,conList,predictVariance,predictOffset,predictLAConst);

DSim=dsim.DSim.getInstance();
ISO=dsim.ISO();
ISO.OPT.a=1;
ISO.OPT.y=2; %Expansion y
ISO.OPT.p=0.5; %Contraction B
ISO.OPT.o=0.9; %Shrink coeff.
ISO.OPT.Rw=Rw;
ISO.OPT.Rb=Rb;
ISO.nVar=nPar;
DSim.addAgent(ISO);


Bandwidth=1e9;
Latency=0;
CommMtoISO=dsim.Comm(Bandwidth,Latency);
DSim.addAgent(CommMtoISO);
CommISOtoM=dsim.Comm(Bandwidth,Latency);
DSim.addAgent(CommISOtoM);

ISO.commAgentId=CommISOtoM.id;

for i=1:length(genList)
    agent=genList{i};
    agent.ISOid=ISO.id;
    agent.commAgentId=CommMtoISO.id;
    DSim.addAgent(agent);
end

for i=1:length(conList)
    agent=conList{i};
    agent.ISOid=ISO.id;
    agent.commAgentId=CommMtoISO.id;
    DSim.addAgent(agent);
end

scenario=dsim.MktScenario();
%scenario.addEvent(20,@addLatencyScenario);
scenario.addEvent(200,@addLoadScenario);
%scenario.addEvent(120,@remLatencyScenario);
scenario.addEvent(400,@remLoadScenario);
DSim.addAgent(scenario);

logger=dsim.MktLogger();
DSim.addAgent(logger);


DSim.run(600);

%{
figure;
pH=logger.priceHist(2:end);
rH=logger.residualHist(2:end);
tH=logger.timeHist(2:end);
plotyy(tH,pH,tH,rH);
%}


end

function addLatencyScenario(DSim)

aList=DSim.getAgentsByName('dsim.Comm');
for i=1:length(aList)
    agent=aList{i};
    agent.Bandwidth=1e3;
    agent.Latency=20;
end

end

function addLoadScenario(DSim)

aList=DSim.getAgentsByName('dsim.MktPlayer');
for i=1:length(aList)
    agent=aList{i};
    if agent.Pmax>0
        agent.APmax=0.5;
        agent.APmin=0.1;
    end
end

end

function remLoadScenario(DSim)

aList=DSim.getAgentsByName('dsim.MktPlayer');
for i=1:length(aList)
    agent=aList{i};
    if agent.Pmax>0
        agent.APmax=0;
        agent.APmin=0;
    end
end

end

function remLatencyScenario(DSim)

aList=DSim.getAgentsByName('dsim.Comm');
for i=1:length(aList)
    agent=aList{i};
    agent.Bandwidth=1e9;
    agent.Latency=0;
end

end



function [ residual,genAmt,conAmt ] = calcPowerLevels( price, conList, genList, time )
%MKTTESTFUN Summary of this function goes here
%   Detailed explanation goes here

genAmt=0;
conAmt=0;


for i=1:length(genList)
    p=genList{i}.calcPower(price,time);
    genAmt=genAmt+p;
end

for i=1:length(conList)
    p=conList{i}.calcPower(price,time);
    conAmt=conAmt+p;
end

residual=abs(genAmt+conAmt);

end


function plotPrices(price,time,conList,genList)


genAmt=zeros(length(price),1);
conAmt=zeros(length(price),1);

for k=1:length(price)
[~,genAmt(k),conAmt(k)]=calcPowerLevels( price(k), conList, genList, time );
end

figure;
hold all;
plot(price,abs(genAmt));
plot(price,conAmt);
plot(price,abs(genAmt+conAmt));
legend('Generation','Consumption','Residual');
grid on;
xlabel('Price');
ylabel('Power Level');
hold off;

%{
figure;
hold all;
plot(abs(genAmt),price);
plot(conAmt,price);
plot(abs(genAmt+conAmt),price);
legend('Generation','Consumption','Residual');
grid on;
xlabel('Power Level');
ylabel('Price');
hold off;
%}

end

function plotDualScenario(DSim1,DSim2)

DSim1=DSimBase;
DSim2=DSimLat;

logger1=DSim1.getAgentsByName('dsim.MktLogger');
logger1=logger1{1};
logger2=DSim2.getAgentsByName('dsim.MktLogger');
logger2=logger2{1};

figure;
pH=logger1.priceHist(2:end);
rH=logger1.residualHist(2:end);
pL=logger2.priceHist(2:end);
rL=logger2.residualHist(2:end);
tH=logger1.timeHist(2:end);
[ah]=plotyy(tH,pH,tH,rH);
line(tH,pL,'parent',ah(1));
line(tH,rL,'parent',ah(2));
set(get(ah(1),'Ylabel'),'String','Price') 
set(get(ah(2),'Ylabel'),'String','Loading')
xlabel('Time (s)');

end
