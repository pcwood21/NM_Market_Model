function [genList,conList] = addPredictModel(genList,conList,predictVariance,predictOffset,predictLAConst)

   for i=1:length(genList)
       Mkt=genList{i};
       Mkt.setPredictParams(predictVariance,-1*predictOffset,predictLAConst);
       genList{i}=Mkt;
   end
   
   for i=1:length(conList)
       Mkt=conList{i};
       Mkt.setPredictParams(predictVariance,predictOffset,predictLAConst);
       conList{i}=Mkt;
   end
   
end