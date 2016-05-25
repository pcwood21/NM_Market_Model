%Cost-curves for consumers

Pmin=0.05;
Pmax=0.3;
PrMin=0;
PrMax=150;

scalepr=@(pr) ((pr-PrMin)/(PrMax-PrMin)-0.5)*6;
powfun=@(pr) (Pmax-Pmin)*1/(1+exp(scalepr(pr)))+Pmin;

Pr=PrMin-10:(PrMax-PrMin)/100:PrMax+10;
P=zeros(length(Pr),1);

for i=1:length(Pr)
    P(i)=powfun(Pr(i));
end

figure;
plot(Pr,P);
xlabel('Price');
ylabel('Power');


%Parameters for a generator, where negative power is supply
Pmin=-10;
Pmax=0;
PrMin=30;
PrMax=45;

scalepr=@(pr) ((pr-PrMin)/(PrMax-PrMin)-0.5)*6;
powfun=@(pr) (Pmax-Pmin)*1/(1+exp(scalepr(pr)))+Pmin;

Pr=PrMin-10:(PrMax-PrMin)/100:PrMax+10;
P=zeros(length(Pr),1);

for i=1:length(Pr)
    P(i)=powfun(Pr(i));
end

figure;
plot(Pr,P);
xlabel('Price');
ylabel('Power');



%Cost-curves for fixed consumers

Pmin=0.29;
Pmax=0.31;
PrMin=-3000;
PrMax=3000;

scalepr=@(pr) ((pr-PrMin)/(PrMax-PrMin)-0.5)*6;
powfun=@(pr) (Pmax-Pmin)*1/(1+exp(scalepr(pr)))+Pmin;

Pr=0:0.5:150;
P=zeros(length(Pr),1);

for i=1:length(Pr)
    P(i)=powfun(Pr(i));
end

figure;
plot(P,Pr);
xlabel('Power');
ylabel('Price');
xlim([0 0.5]);