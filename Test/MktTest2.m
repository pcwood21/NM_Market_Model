function MktTest2
%MKTTEST2 Summary of this function goes here
%   Detailed explanation goes here


nConsumer=100;
nGen=2;
targetPower=100;

genVariance=0;
consumerVariance=0;

[genList,conList]=dsim.genModel(nConsumer,nGen,targetPower,genVariance,consumerVariance);

deviation=0.05;
genTC=60*60*24/(2*pi);
conTC=60*60*24/(2*pi);
genMag=0;%targetPower/nGen*0.1;
conMag=targetPower/nConsumer*0.65;
genTS=0;
conTS=60*60*0;

[genList,conList] = dsim.addTimeModel(genList,conList,genTC,conTC,genMag,conMag,genTS,conTS,deviation);


price=-10:0.5:150;
time=0;

plotPrices(price,time,conList,genList)
time=60*60*6;

plotPrices(price,time,conList,genList)



times=0:60*20:60*60*24;
optprice=zeros(length(times),1);
optload=zeros(length(times),1);

parfor i=1:length(times)
    pct=i/length(times)*100;
    fprintf(1,'A-Done: %3.1f\n',round(pct,1));
    optprice(i)=dsim.optimalPrice(genList,conList,times(i));
    [~,~,optload(i)]=calcPowerLevels( optprice(i), conList, genList, times(i) )
end

fixprice=zeros(length(times),1);
fixload=zeros(length(times),1);

for i=1:nConsumer
    Mkt=conList{i};
    Mkt.Pmax=Mkt.Pmax/2;
    Mkt.oldPmin=Mkt.Pmin;
    Mkt.Pmin=Mkt.Pmax-1e-3;
    conList{i}=Mkt;
end

parfor i=1:length(times)
    pct=i/length(times)*100;
    fprintf(1,'B-Done: %3.1f\n',round(pct,1));
    fixprice(i)=dsim.optimalPrice(genList,conList,times(i));
    [~,~,fixload(i)]=calcPowerLevels( fixprice(i), conList, genList, times(i) )
end

for i=1:nConsumer
    Mkt=conList{i};
    Mkt.Pmax=Mkt.Pmax*2;
    Mkt.Pmin=Mkt.oldPmin;
    conList{i}=Mkt;
end

figure;
[ax,~,~]=plotyy(times/3600,optprice,times/3600,(optload));
line(times/3600,fixprice,'parent',ax(1));
line(times/3600,fixload,'parent',ax(2));
set(get(ax(1),'Ylabel'),'String','Optimal Price') 
set(get(ax(2),'Ylabel'),'String','Loading')
set(ax(1),'ylim',[20 160],'ytick',20:20:160);
set(ax(2),'ylim',[0 140],'ytick',0:20:140);
xlabel('Time (h)');
grid on;

figure;
plot(times/3600,fixload,times/3600,optload)
legend('Fixed','Flexible');


ISO=dsim.ISO();
ISO.init();

optfun=@(x,t) calcPowerLevels( x, conList, genList, t );

t=0:5:max(times);
nmprice=zeros(length(t),1);
nmload=zeros(length(t),1);
nmgen=zeros(length(t),1);
for i=1:length(t)
    X=ISO.processPrices(0);
    nmprice(i)=X;
    [residual,nmgen(i),nmload(i)]= optfun(X,t(i));
    ISO.clientPower=residual+randn()*15;
    pctDone=i/length(t)*100;
    fprintf(1,'C-Done: %3.1f\n',round(pctDone,1));
end

%{
for i=1:length(t)
    [~,~,nmload(i)]=calcPowerLevels( nmprice(i), conList, genList, t(i) );
end
%}

figure;
[ax,~,~]=plotyy(t/3600,nmprice,t/3600,nmload);
set(get(ax(1),'Ylabel'),'String','Price') 
set(get(ax(2),'Ylabel'),'String','Loading')
line(times/3600,optprice,'parent',ax(1));
line(times/3600,optload,'parent',ax(2));
set(ax(1),'ylim',[20 160],'ytick',20:20:160);
set(ax(2),'ylim',[0 140],'ytick',0:20:140);
xlabel('Time (h)');


keyboard

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

