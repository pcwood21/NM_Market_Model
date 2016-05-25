function [genList,conList] = addTimeModel(genList,conList,genTC,conTC,genMag,conMag,genTS,conTS,deviation)

   for i=1:length(genList)
       Mkt=genList{i};
       tc=genTC;
       mag=genMag+genMag*deviation*randn();
       TS=genTS+genTS*deviation*randn()*100;
       Mkt.setTimeFun(tc,mag,TS);
       genList{i}=Mkt;
   end
   
   for i=1:length(conList)
       Mkt=conList{i};
       tc=conTC;
       mag=conMag+conMag*deviation*randn();
       TS=conTS+conTS*deviation*randn()*100;
       Mkt.setTimeFun(tc,mag,TS);
       conList{i}=Mkt;
   end
   
end