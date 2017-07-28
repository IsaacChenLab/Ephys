function MC_lfpPrepareFiles(file,chs)

global CAT;
global DATE;
global DATA_DIR;

%R1=25;
R2=50;

h1=waitbar(0,'Preparing files');
for i=1:length(file)
    d=1;
%    flfs=sprintf('L%s_%s_%d.mat',CAT,DATE,file(i));
    flfs2=sprintf('L2%s_%s_%d.mat',CAT,DATE,file(i));
    for ch=chs,
        clear rawData* lfpData* xtime;
        waitbar(((i-1)*length(chs)+d)/(length(chs)*length(file)),h1);
    % get raw data
        [rawData,xtime,Hz,totalMs]=MC_loadElectrodes(file(i),ch);
        
%         s=sprintf('lfpData_%d=decimate(rawData,R1);',ch);
%         eval(s);
%         cd(DATA_DIR);
%         cd('lfpFiles');
%         if ~exist(flfs,'file'),
%             s=sprintf('save %s lfpData_%d;',flfs,ch);
%         else
%             s=sprintf('save %s -append lfpData_%d;',flfs,ch);
%         end
%         eval(s);

        s=sprintf('lfpData_%d=decimate(rawData,R2);',ch);
        eval(s);
        
        cd(DATA_DIR);
        cd('lfpFiles2');
        if ~exist(flfs2,'file'),
            s=sprintf('save %s lfpData_%d;',flfs2,ch);
        else
            s=sprintf('save %s -append lfpData_%d;',flfs2,ch);
        end
        eval(s);

        d=d+1;
    end
%     LFP_time=decimate(xtime,R1);
%     LFP_Hz=Hz/R1;
%     % save time
%     s=sprintf('save %s -append LFP_time totalMs LFP_Hz;',flfs);
%     cd(DATA_DIR);
%     cd('lfpFiles');
%     eval(s);
    
    LFP_time=decimate(xtime,R2);
    LFP_Hz=Hz/R2;
    s=sprintf('save %s -append LFP_time totalMs LFP_Hz;',flfs2);
    cd(DATA_DIR);
    cd('lfpFiles2');
    eval(s);
end
close(h1);

return;
