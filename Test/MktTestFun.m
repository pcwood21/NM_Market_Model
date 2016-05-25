function [ residual,genAmt,conAmt ] = MktTestFun( price, conList, genList, time )
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

residual=genAmt+conAmt;

end

