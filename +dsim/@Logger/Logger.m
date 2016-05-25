classdef Logger < dsim.Agent

	properties
		samplePeriod=1;
		time=[];
	end
	
	methods
	
		function obj=Logger()
			
		end
		
		function init(obj)
			obj.queueAtTime(0);
		end
		
		function execute(obj,time)
			obj.queueAtTime(time+obj.samplePeriod);
			obj.time(end+1)=time;
			
			mgmtNode=[];
			DSim=dsim.DSim.getInstance();
			for i=1:length(DSim.agentList)
				agent=DSim.agentList{i};
				if isa(agent,'dsim.MgmtServer')
					mgmtNode=agent;
				end
            end
			
			
		end
		
	end
end