clear all;
clc;
close all;

nConsumer=100;
nGen=2;
targetPower=100;

avgGenPower=targetPower/nGen;
avgConsumerPower=targetPower/nConsumer;

genVariance=5;
consumerVariance=2;

ISOid=0;

conList={};
genList={};

for i=1:nGen
    Pmin=-avgGenPower+genVariance*randn();
    Pmax=0;
    PrMin=30;
    PrMax=55;
    mkt=dsim.MktPlayer(Pmax,Pmin,PrMax,PrMin,ISOid);
    
    genList{i}=mkt;
end

for i=1:nConsumer
    Pmin=0;
    Pmax=avgConsumerPower+consumerVariance*randn();
    PrMin=0;
    PrMax=100;
    mkt=dsim.MktPlayer(Pmax,Pmin,PrMax,PrMin,ISOid);
    
    conList{end+1}=mkt;
end


price=-10:0.5:150;

genAmt=zeros(length(price),1);
conAmt=zeros(length(price),1);
residual=zeros(length(price),1);
time=0;

for k=1:length(price)
[residual(k),genAmt(k),conAmt(k)]=MktTestFun( price(k), conList, genList, time );
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


