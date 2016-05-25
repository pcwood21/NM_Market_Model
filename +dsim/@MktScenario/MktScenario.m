classdef MktScenario < dsim.Agent
    %MKTSCENARIO Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        scenarioTimes=[];
        scenarioFuncs={};
    end
    
    methods
        function obj=MktScenario()
        end
        
        function init(obj)
            for i=1:length(obj.scenarioTimes)
                obj.queueAtTime(obj.scenarioTimes(i));
            end
        end
        
        function execute(obj,time)
            DSim=dsim.DSim.getInstance();
            for i=1:length(obj.scenarioTimes)
                if time==obj.scenarioTimes(i)
                    funhandle=obj.scenarioFuncs{i};
                    funhandle(DSim);
                end
            end
        end
        
        function addEvent(obj,time,handle)
            obj.scenarioTimes(end+1)=time;
            obj.scenarioFuncs{end+1}=handle;
        end
        
    end
    
end

