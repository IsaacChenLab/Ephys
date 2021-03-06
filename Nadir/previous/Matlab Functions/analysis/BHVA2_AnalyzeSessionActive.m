function rez=BHVA2_AnalyzeSessionActive (fn)

try
    load (fn);
catch
    error ('file could not be loaded');
end
if ~(exist('EVENTS','var') && exist ('LICKS','var'))
    error ('the loaded session does not contain appropriate variables');
end

rt=Rate(LICKS,10)/10;
f=figure;
plot (rt);
hold on;
[x1 ~]=ginput(1);
line([x1 x1],[min(rt) max(rt)]);
[x2 ~]=ginput(1);
close (f);
MX=round(10*max(x1,x2));
MN=round(10*min(x1,x2));

for i=1:3
    try
        ev=eval(['EVENTS{' num2str(i) '}']);
        EV=ev(ev<MX);
        EV=EV(EV>MN);
        eval (['EVENTS{' num2str(i) '}=EV;']);
    catch
    end
end

for i=1:3
    try
        eval (['ev' num2str(i) '=MC_smooth(XCorr (EVENTS{' num2str(i) '},LICKS,[-5 10],.1)'',0.5);']);
    catch
    end
end

mx=0;
for i=1:3
    try
        mx=max(mx,max(eval(['ev' num2str(i)])));
    catch
    end
end
figure

legend={'REWARD'; 'CSP'; 'CSM'};
for i=1:3
    try
        subplot (2,2,i);
        plot (-5:.1:10,eval(['ev' num2str(i)]));
        axis ([-5 10 0 mx]);
        title (legend{i});
    catch
    end
end

if exist('ev3','var')
    subplot (2,2,4)
else
    subplot(2,2,3:4)
end

plot (0:10:LICKS(end),rt);
hold on
line([x1*10 x1*10],[min(rt) max(rt)],'Color','r');
line([x2*10 x2*10],[min(rt) max(rt)],'Color','r');
axis ([0 LICKS(end) 0 max(rt)]);
title ('Licking rate');

%%%% percent hits/miss
ev=[];
for i=1:length(EVENTS{1})
    if ~isempty(find(LICKS>EVENTS{1}(i) & LICKS<EVENTS{1}(i)+1))
        ev(end+1)=EVENTS{1}(i);
    end
end
EVENTS{1}=ev;
for i=2:3
    try
        ev=eval(['EVENTS{' num2str(i) '}']);
        n=0;
        for j=1:length(ev)
            if ~isempty (find(EVENTS{1}>ev(j) & EVENTS{1}<ev(j)+5))
                n=n+1;
            end
        end
        eval(['rez.ev' num2str(i) '=n/length(ev);']);
        eval (['n' num2str(i-1) '=n;']);
    catch
    end
end
rez.cor=(n1+n2)/(length(EVENTS{2})+length(EVENTS{3}));
lp=sum(ev2(51:62));
blp=sum(ev2(41:50));
lm=sum(ev3(51:62));
blm=sum(ev3(41:50));
rez.dis=(lp-lm)/(lp+lm);
rez.percent_lp=lp/blp;
rez.percent_lm=lm/blm;
