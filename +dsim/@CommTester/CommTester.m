classdef CommTester < dsim.Agent
    %COMMTESTER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        rxTimeHist=[];
        rxLatencyHist=[];
        isSender=0;
        sendRate=0.1;
        nextSendTime=0;
        sendMsg=[];
        destAgent=0;
        nextDest=1;
    end
    
    methods
        function obj=CommTester()
        end
        
        function setSender(obj,msg,rate,dest)
            obj.sendMsg=msg;
            obj.sendRate=rate;
            obj.destAgent=dest;
            obj.isSender=1;
        end
        
        function init(obj)
            obj.queueAtTime(obj.sendRate);
        end
        
        function execute(obj,time)
            if obj.hasWaitingMsg()
                msg=obj.recv();
                obj.rxTimeHist(end+1)=time;
                obj.rxLatencyHist(end+1)=time-msg.sTime;
            end
            
            if time>=obj.nextSendTime && obj.isSender
                obj.nextSendTime=time+obj.sendRate;
                obj.queueAtTime(obj.nextSendTime);
                nDest=length(obj.destAgent);
                obj.sendComm(obj.sendMsg,obj.destAgent(obj.nextDest));
                obj.nextDest=mod(obj.nextDest,nDest)+1;
            end
        end
        
    end
    
end

