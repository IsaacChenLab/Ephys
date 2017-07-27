function [sharpMat,sharpTimes,FileTimes]=MC_swFindSharp(file,ch)

SEC_CHUNKS = 60e3; %ms for presentation in chunks

%try,
[sharpMat,sharpTimes,FileTimes]=deal(nan);
[sharpTimes]=deal([]);
f1=figure('Units','normalized','position',[0.1 0.5 0.8 0.4]);
Time=[]; rawData=[]; events=[];
Total_ms=0;
% over files
for i=1:length(file)
    % get raw data
    [rd,totalMs,Hz,T]=MC_loadLFP(file(i),ch);
    rawData=[rawData; rd];
    Time=[Time; T+Total_ms];
    clear rd T;
    [ev,tt,dHz]=MC_loadDigital(file(i)); clear tt;
    ev=MC_bin(ev,dHz/Hz);
    events=[events; ev];
    Total_ms=Total_ms+totalMs;
    FileTimes(i)=Total_ms;
end
[sw,swT]=MC_loadSWS(file);
rawlimits=[min(rawData) max(rawData(100:end-100)) mean(rawData) std(rawData)];

%[events]=MC_loadEvents(file);
%events=(sum(events,2)>0);

CHUNKS=SEC_CHUNKS * Hz / 1e3;
periods=floor(size(rawData,1)/CHUNKS);
last=mod(size(rawData,1),CHUNKS);
for i=1:periods,
    inx=[1:CHUNKS]+(i-1)*CHUNKS;
    [st]=MC_swFindTimes(Time(inx),rawData(inx),rawlimits,events(inx),Hz,f1,swT);   
    sharpTimes=[sharpTimes; st];
end  
inxf=[periods*CHUNKS+1 : periods*CHUNKS+last];
filler=nan(length(inx)-length(inxf),1); 
[st]=MC_swFindTimes(Time(inx)+SEC_CHUNKS,[rawData(inxf); filler],rawlimits,[events(inxf); filler],Hz,f1,swT);    
sharpTimes=[sharpTimes; st];

if ~MC_accept('save?')
    [sharpMat,sharpTimes,FileTimes]=deal(nan);
    close(f1);
    return;
end

clear rawData Time;

close(f1);

% final sparse matrix of ones where the spike has occured
sharpMat=sparse(Total_ms,1);
for i=1:size(sharpTimes,1)
    sharpMat(round(sharpTimes))=1;
end


% catch,
%     warning(lasterr);
%     [swsMat,swsTimes,remMat,remTimes,FileTimes]=deal(nan);
%     return;
% end
% 
return;


