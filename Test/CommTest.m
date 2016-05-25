function DSim=CommTest
%COMMTEST Summary of this function goes here
%   Detailed explanation goes here

clear DSim;
clc;

bandwidth=1e6; %1 Megabits
msgSize=1440; %bytes

DSim=dsim.DSim.getInstance();

Sender=dsim.CommTester();
Receiver=dsim.CommTester();
DSim.addAgent(Sender);
DSim.addAgent(Receiver);
Receiver2=dsim.CommTester();
DSim.addAgent(Receiver2);


CommSR=dsim.Comm(bandwidth,20e-3);
DSim.addAgent(CommSR);
Sender.commAgentId=CommSR.id;


msg=struct();
msg.payload=zeros((msgSize-176)/8,1);
S=whos('msg');
nBytes=S.bytes;

maxSendRate=(nBytes*8)/bandwidth;

destList=[];
destList(end+1)=Receiver.id;
destList(end+1)=Receiver2.id;

Sender.setSender(msg,maxSendRate*1.3,destList);

DSim.run(2);

figure;
hold all;
plot(Receiver.rxLatencyHist);
plot(Receiver2.rxLatencyHist+0.001);
plot(sum([Receiver.rxLatencyHist' Receiver2.rxLatencyHist']'));

end


