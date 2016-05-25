function [genList,conList] = genModel(nConsumer,nGen,targetPower,genVariance,consumerVariance)



avgGenPower=targetPower/nGen;
avgConsumerPower=targetPower*1.5/nConsumer;
minConsumerPower=avgConsumerPower/5;

ISOid=0;

conList={};
genList={};

for i=1:nGen
    Pmin=-avgGenPower+genVariance*randn();
    Pmax=0;
    PrMin=30;
    PrMax=80;
    mkt=dsim.MktPlayer(Pmax,Pmin,PrMax,PrMin,ISOid);
    
    genList{i}=mkt;
end

for i=1:nConsumer
    Pmax=avgConsumerPower+consumerVariance*randn();
    %Pmin=Pmax-1e-3;
    Pmin=minConsumerPower;
    PrMin=0;
    PrMax=100;
    mkt=dsim.MktPlayer(Pmax,Pmin,PrMax,PrMin,ISOid);
    
    conList{end+1}=mkt;
end


end