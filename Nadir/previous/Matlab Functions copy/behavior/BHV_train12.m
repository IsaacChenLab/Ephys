function status=BHV_train5(RWD,ITI,F1,F2,N1,N2,P,SWTIME)
% function status=BHV_train2(RWD,ITI,F1,F2,N1,N2,P,RSP)
% training paradigm:
% two tone frequencies: F1 , F2
% each trial a tone is selected randomly (with P probability for F1 an 1-P
% for F2), and sounded for N1/N2 seconds.
% if the lever is pressed while F1 is sounded (or within RSP seconds after it ends), then reward is delivered for RWD seconds.
% if the lever is pressed while F2 is sounded, the tone extends for N2 more
% seconds.
% inter trial interval for ITI (can be a range, if so selected random) seconds, if the lever is pressed, ITI
% extends for ITI more seconds.

%try,
global EVENTS;
global EVENT_INX;
global SAVE_CLOCK_START;
EVENTS=[];

if nargin<1,
    RWD=0.1;
end
if nargin<2
    ITI=4;
end
if nargin<3
    F1=[0 1 0];
end
if nargin<4,
    F2=[0 0 1];
end
if nargin<5,
    N1=6;
end
if nargin<6,
    N2=3;
end
if nargin<7,
    P=0.5;
end
if nargin<8
    SWTIME=0;
end

close all;

% initiate the das1200 card 
CARD('Initialize');
CARD('lever_up');

scrsz = get(0,'ScreenSize');
f1=figure('Position',scrsz,'color',[0 0 0]);
drawnow;

try,

ps=rand(1e4,1);
ps2=rand(1e4,1);


CARD('lever_bit',24);
d=1;
run_ind=1;
while run_ind,

    if ps(d)<P, % cs plus trial
        CARD('send_dio',21);
        set(gcf,'color',F1); drawnow;
        pause(N1);
        set(gcf,'color',[0 0 0]); drawnow;
        pause(N2);
        CARD('send_dio',20);
        CARD('reward',RWD);
        
    else % cs minus trial
        CARD('send_dio',22);
        press=1;
        first=1;
        set(gcf,'color',F2); drawnow;
        pause(N1);
        set(gcf,'color',[0 0 0]); drawnow;
        pause(N2);
    end
    
    % inter trial interval
    iti=round(ITI+ps2(d)*(ITI));
    CARD('send_dio',23);
    pause(iti);
    d=d+1;
end

catch,
    disp(lasterr);
end

close(f1);
CARD('lever_down');
CARD('destroy');

return;

