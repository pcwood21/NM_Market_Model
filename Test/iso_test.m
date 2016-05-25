
clear all;
clc;

numGen=2;
numConsumer=20;
numPlayers=numGen+numConsumer;
x0=0;

genB=rand(numGen,1)*numConsumer/numGen/20;
genC=rand(numGen,1)*numConsumer/numGen/10;
conB=1*rand(numConsumer,1)*numGen/numConsumer*5;
conC=1*rand(numConsumer,1)*numGen/numConsumer/10;
%sum(1./(1+exp(conB.*x)))
optfun=@(x) abs(-sum(1./(1+exp(conB.*x))) + sum(5./(1+exp(-genB.*x))));

%testing
x=0.01:0.01:10;
for i=1:length(x)
    y(i)=optfun(x(i));
end
%plot(x,y);


ISO=dsim.ISO();

ISO.init();

nTestPoints=2;
x0=linspace(0,10,nTestPoints);
for i=1:length(x0)
    f0(i)=optfun(x0(i));
end
%ISO.OPT.setParams(x0,f0);

nIter=1;
X=0;
xLog=[];
xvLog=[];
[xv]=fminsearch(optfun,0);
while nIter<1000 %&& optfun(X)>0.001
    X=ISO.processPrices(0);
    ISO.clientPower=optfun(X);
    if ISO.priceState==1
    xLog(end+1)=X;
    xvLog(end+1)=xv;
    nIter=nIter+1;
    end
    
    if mod(nIter,200)==100
        genB=rand(numGen,1)*numConsumer/numGen/20;
        genC=rand(numGen,1)*numConsumer/numGen/10;
        conB=1*rand(numConsumer,1)*numGen/numConsumer*5;
        conC=1*rand(numConsumer,1)*numGen/numConsumer/10;
        optfun=@(x) abs(-sum(1./(1+exp(conB.*x))) + sum(5./(1+exp(-genB.*x))));
        [xv]=fminsearch(optfun,0);
        %ISO.init();
    end
end
nIter
P=optfun(X)

figure;
hold all;
plot(xLog);
plot(xvLog);
plot(abs(xLog-xvLog));
grid on;
ylim([0 6]);
xlabel('Time (Iteration)');
ylabel('Market Price');
legend('Actual','Optimal','Error');
hold off;

return;




clear all;
close all;
clc;

numGen=2;
numConsumer=20;
numPlayers=numGen+numConsumer;
x0=0;

genB=rand(numGen,1)*numConsumer/numGen/20;
genC=rand(numGen,1)*numConsumer/numGen/10;
conB=1*rand(numConsumer,1)*numGen/numConsumer*5;
conC=1*rand(numConsumer,1)*numGen/numConsumer/10;
%sum(1./(1+exp(conB.*x)))
optfun=@(x) abs(-sum(1./(1+exp(conB.*x))) + sum(5./(1+exp(-genB.*x))));

ISO=dsim.ISO();

ISO.init();

nTestPoints=2;
x0=linspace(0,10,nTestPoints);
for i=1:length(x0)
    f0(i)=optfun(x0(i));
end
%ISO.OPT.setParams(x0,f0);

nIter=1;
X=0;
xLog=[];
xvLog=[];
[xv]=fminsearch(optfun,0);
while nIter<1000 %&& optfun(X)>0.001
    X=ISO.processPrices(0);
    if ISO.priceState==1
    xLog(end+1)=X;
    xvLog(end+1)=xv;
    nIter=nIter+1;
    end
    ISO.clientPower=optfun(X);
    
    optfun=@(x) abs(-sum(1./(1+exp(conB.*x))) + sum(5./(1+exp(-genB.*x)))+cos(nIter/100));
    [xv]=fminsearch(optfun,0);

end
nIter
P=optfun(X)

figure;
hold all;
plot(xLog);
plot(xvLog);
plot(abs(xLog-xvLog));
grid on;
ylim([0 6]);
xlabel('Time (Iteration)');
ylabel('Market Price');
legend('Actual','Optimal','Error');
hold off;


