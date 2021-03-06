function H=line(m,style)
%ecuatia unei drepte este y=m*x+n
%functie cu parametri m,n,style
%pt m dat  (m=tg(alfa)) unghiul dreptei ;n=valoarea lui y(ordonata)
%cind x=0
%daca vreau mai rare n=-5:5 , mai dese n mai mare
%daca vreau o retea peste grid;
%cu acest program vom obtine paralelograme paralele umplute
%deci linii groase paralele (grosimea depinde de n)

if nargin<1
    m=0;
end
if nargin<2
    style='w';
end

scrsz = get(0,'ScreenSize');
f1=figure('Position',scrsz,'color',[0 0 0]);
drawnow;
hold on;
for n=-11:2:11 %pas 2 ca sa fac un interval intre paralelograme.
for i=1:5
    x1(i)=i;
    y1(i)=m*x1(i)+n;
    %disp(x1);
    %disp(y1);
   % X(i)=x1(i);
   % Y(i)=y1(i);
end
%paralelogramul ABCD pe care-l umplu cu fill
    %A
    X(1)=x1(1);
    Y(1)=m*x1(1)+n-1;
    %B
    X(2)=x1(5);
    Y(2)=m*x1(5)+n-1;
    %C
    X(3)=x1(5);
    Y(3)=m*x1(5)+n;
    %D
    X(4)=x1(1);
    Y(4)=m*x1(1)+n;
    %disp(X);
    %disp(Y);
 H=plot(y1,'w');
%fill(X,Y,'g');
for j=1:4
   XX(j)=X(j);
   YY(j)=Y(j);
end
fill(XX,YY,'w');
end
%axis square;
axis fill;
axis off;
%pause(5);clf;