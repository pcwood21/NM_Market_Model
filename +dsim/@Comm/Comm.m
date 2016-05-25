classdef Comm < dsim.Agent

	properties
		Bandwidth=0;
		MsgQueue={};
		destAgent=[];
        availDestAgent=[];
		MsgDeliverTime=[];
		Latency=0;
        maxLatency=10;
	end
	
	methods
	
		function obj=Comm(Bandwidth,Latency)
			obj.Bandwidth=Bandwidth;
			obj.Latency=Latency;
		end
		
		function execute(obj,time)
			while obj.hasWaitingMsg()
				obj.sendMsg(obj.recv(),time);
			end
			
			if isempty(obj.MsgDeliverTime)
				return;
			end
			
			nextDeliveryTime=obj.MsgDeliverTime(1);
			
			while time>=nextDeliveryTime
				obj.send(obj.MsgQueue{1},obj.destAgent(1));
				obj.MsgQueue(1)=[];
				obj.destAgent(1)=[];
				obj.MsgDeliverTime(1)=[];
				if isempty(obj.MsgDeliverTime)
					return;
				end
				nextDeliveryTime=obj.MsgDeliverTime(1);
			end
		
		end
		
		function sendMsg(obj,msg,time)
            if ~isfield(msg,'sTime')
                msg.sTime=time;
            end
			newDest=msg.newDest(1);
            msg.newDest(1)=[];
			
			s=whos('msg');
			bytes=s.bytes;
            if ~isempty(obj.MsgDeliverTime) %Queue not empty
                tmax=max(obj.MsgDeliverTime)-obj.Latency;
                time=max(time,tmax);
            end
            netLatency=bytes*8/obj.Bandwidth+obj.Latency;
            if netLatency > obj.maxLatency %Latency cap
                return;
            end
			dtime=time+netLatency;
            obj.destAgent(end+1)=newDest;
			obj.MsgQueue{end+1}=msg;
			obj.MsgDeliverTime(end+1)=dtime;
			obj.queueAtTime(dtime);
		end
		
	end
	

end
