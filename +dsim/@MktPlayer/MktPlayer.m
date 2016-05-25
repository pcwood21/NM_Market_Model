classdef MktPlayer < dsim.Agent

	properties
		Pmax=0;
		Pmin=0;
        oldPmin=0;
        PrMax=0;
        PrMin=0;
		Lambda=0;
		Power=0;
		ISOid=0;
        timeConst=0;
        timeMag=0;
        timeShift=0;
        predictVariance=0;
        predictOffset=0;
        predictLAConst=inf;
        APmax=0;
        APmin=0;
	end
	
	methods
		function obj=MktPlayer(Pmax,Pmin,PrMax,PrMin,ISOid)
			obj.Pmax=Pmax;
			obj.Pmin=Pmin;
            obj.PrMax=PrMax;
            obj.PrMin=PrMin;
			obj.ISOid=ISOid;
		end
		
		function init(obj)
			newMsg=struct();
			newMsg.id=obj.id;
			newMsg.type='register';
			obj.sendComm(newMsg,obj.ISOid);
        end
        
        function setTimeFun(obj,timeConst,timeMag,timeShift)
           obj.timeConst=timeConst; 
           obj.timeMag=timeMag;
           obj.timeShift=timeShift;
        end
		
		function execute(obj,time)

			%Receive Bid
			while obj.hasWaitingMsg()
				msg=obj.recv();
				bestOffer=msg.lambda;
                offer=msg.testLambda;
				obj.Lambda=bestOffer;
				obj.Power=obj.calcPower(offer,time);
				newMsg=struct();
				newMsg.Power=obj.Power;
				newMsg.id=obj.id;
				newMsg.txTime=time;
                newMsg.seqNum=msg.seqNum;
				newMsg.type='powerLevel';
                %fprintf(1,'Mkt %d Price/Power: $%2.1f,%2.1f at %d for %d\n',obj.id,round(obj.Lambda,1),round(obj.Power,1),time,msg.sTime);
				obj.sendComm(newMsg,obj.ISOid);
			end
		
		end
		
		function p=calcPower(obj,offer,time)
            lPmin=obj.Pmin+obj.APmin;
            if lPmin < 0
                lPmin=lPmin+obj.timeMag*sin((time+obj.timeShift)/obj.timeConst);
            end
            lPmax=obj.Pmax+obj.APmax;
            if lPmax > 0
                lPmax=lPmax+obj.timeMag*sin((time+obj.timeShift)/obj.timeConst);
                lPmin=lPmin+obj.timeMag*sin((time+obj.timeShift)/obj.timeConst);
            end
            %scalepr=@(pr) ((pr-obj.PrMin)/(obj.PrMax-obj.PrMin)-0.5)*6;
            %powfun=@(pr) (lPmax-lPmin)*1/(1+exp(scalepr(pr)))+lPmin;
            
            %Adjust pmin/pmax as f(time)
            
            %Calc power amount
            pr=offer;
            p=(lPmax-lPmin)*1/(1+exp(((pr-obj.PrMin)/(obj.PrMax-obj.PrMin)-0.5)*6))+lPmin;
            
        end
        
        function p=calcUnadjustedPower(obj,offer,time)
            lPmin=obj.Pmin;
            if lPmin < 0
                lPmin=lPmin+obj.timeMag*sin((time+obj.timeShift)/obj.timeConst);
            end
            lPmax=obj.Pmax;
            if lPmax > 0
                lPmax=lPmax+obj.timeMag*sin((time+obj.timeShift)/obj.timeConst);
                lPmin=lPmin+obj.timeMag*sin((time+obj.timeShift)/obj.timeConst);
            end
            %scalepr=@(pr) ((pr-obj.PrMin)/(obj.PrMax-obj.PrMin)-0.5)*6;
            %powfun=@(pr) (lPmax-lPmin)*1/(1+exp(scalepr(pr)))+lPmin;
            
            %Adjust pmin/pmax as f(time)
            
            %Calc power amount
            pr=offer;
            p=(lPmax-lPmin)*1/(1+exp(((pr-obj.PrMin)/(obj.PrMax-obj.PrMin)-0.5)*6))+lPmin;
            
        end

        function setPredictParams(obj,var,off,LA)
            obj.predictVariance=var;
            obj.predictOffset=off;
            obj.predictLAConst=LA;
        end
        
        function p=predictPower(obj,offer,time,lookaheadTime)
            %DSim=dsim.DSim.getInstance();
            %lookaheadTime=time-DSim.currentTime;
            pBase=obj.calcUnadjustedPower(offer,time);
            p=(pBase*(1+obj.predictOffset)+pBase*obj.predictVariance*randn())*(lookaheadTime/obj.predictLAConst);
        end
		
	end

end
