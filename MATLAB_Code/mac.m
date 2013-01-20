function[points,sequence]=mac(inputx,inputy)
%CKH 10-13-2012
%inputx and inputy describe a curve to be matched by macaroni-style segments
%Simple version picks least bad macaroni orientation at each segment and
%never goes back to optimize.

%Improve; try making it work its way along the input curve
%so there aren't loops

%Next (Chris) try Monte Carlo, make wrong choice sometimes e-(energy/kt) where kt
%is whatever and energy is sum of squares of least distance to curve

%Other idea is to:
%Make lookup table of patterns that are less than the "correlation length"
%and pick the pattern that's the best match

%Generate a test curve for inputx and inputy
theta=linspace(0,2*pi,180);
inputx=cos(theta);
inputy=sin(theta);

%Uses John d'Errico's arclength.m file and license:
L=arclength(inputx,inputy);

%Keep same segment length from previous expt but
%inputx=0.97*inputx;
%inputy=0.97*inputy;%scale the circle see what happens in an inflatable
%structure test.

N=input('How many segments to use for fitting?') %10
segangle=input('What is the arc angle in degrees of each segment?') %30

Seglength=L/N;
%Seglength=L/N*1.2; %inefficiency of fitting makes the number of segments not reach the end
%A small increase in segment length helps
ArcN=ceil(segangle*10); %to draw segments, use one point per 0.1 degree

%Create a macaroni arc for rotating
Arcx=linspace(0,Seglength,ArcN); %Draw a non-rotated segment
Arcradius=Seglength/2/sind(segangle/2);
Arcy=sqrt(Arcradius^2-(Arcx-Seglength/2).^2)-cosd(segangle/2)*Arcradius;
%figure(1)
%plot(Arcx,Arcy)
Narcy=-1*Arcy;%Negative arc, if this is used make a -1 in the seq

%Translate the given curve to start at 0,0
CurveToFitx=inputx-inputx(1);
CurveToFity=inputy-inputy(1);

%Pick angle of entire collection by having first macaroni start and end right on the
%curve. That means dumbly following the curve until the first point greater
%than segment-length distance from 0,0 is found. Let that point
%determine the angle to rotate the first arc.
j=0;
compareLength=-1;%for startup
while ((compareLength<0)&j<length(CurveToFitx))
    j=j+1;
    compareLength=sqrt(CurveToFitx(j)^2+CurveToFity(j)^2)-Seglength;
end

startangle=atan2(CurveToFity(j),CurveToFitx(j)); %angle in radians to rotate Arcx,Arcy for first segment
[posArcTH,posArcR]=cart2pol(Arcx,Arcy); %Get arc coordinates to polar for rotation
%Now try it with the negative arc
[negArcTH,negArcR]=cart2pol(Arcx,Narcy);

cumulativeAngle=startangle;
cumulativePosAngle=startangle;%variables needed to start up the process below
cumulativeNegAngle=startangle;
points=[];
sequence=[];


for i=1:N  %go over the entire collection of macaroni segments
  %Determine which arc is a better fit using least-squares
  %And using John d'Errico's distance2curve function
  if(i>1)%set up angles so it's a smooth transition from one macaroni to the next
      if(Segment(i-1).orientation==1)%prev segment was positive
          cumulativePosAngle=cumulativeAngle-segangle*pi/180;
          cumulativeNegAngle=cumulativeAngle;
      else %prev segment was negative
          cumulativePosAngle=cumulativeAngle;
          cumulativeNegAngle=cumulativeAngle+segangle*pi/180;
      end
  end    
  [NextPosArcx,NextPosArcy]=pol2cart(posArcTH+cumulativePosAngle,posArcR);
  [NextNegArcx,NextNegArcy]=pol2cart(negArcTH+cumulativeNegAngle,negArcR);
  if (i>1)% shift arc to endpoint of prev segment after rotating it
      NextPosArcx=NextPosArcx+Segment(i-1).arcx(end);
      NextPosArcy=NextPosArcy+Segment(i-1).arcy(end);
      NextNegArcx=NextNegArcx+Segment(i-1).arcx(end);
      NextNegArcy=NextNegArcy+Segment(i-1).arcy(end);
  end    
  [xyp,poserror]=distance2curve([CurveToFitx',CurveToFity'],[NextPosArcx',NextPosArcy']);
  TotalPosError=sum(poserror.^2);
  [xyn,negerror]=distance2curve([CurveToFitx',CurveToFity'],[NextNegArcx',NextNegArcy']);
  TotalNegError=sum(negerror.^2);
  %Should instead grab and compare it to the "next" segment of the curve rather than
  %the entire curve? what if it keeps fitting the same segment over and
  %over and thinks that's great! Yes, that is what can sometimes happen, try lots of 180 degree arcs.
  if TotalPosError < TotalNegError
    Segment(i).orientation =1; %Positive orientation is best fit
    Segment(i).arcx=NextPosArcx;
    Segment(i).arcy=NextPosArcy;
    Segment(i).rotangle=cumulativePosAngle;
    %xyp(end) is the pair of points on CurveToFit that is nearest to the
    %end of the arc. Walk along CurveToFit to select the next segment to
    %fit.
  else %negative orientation is the best fit
    Segment(i).orientation =-1; 
    Segment(i).arcx=NextNegArcx;
    Segment(i).arcy=NextNegArcy;
    Segment(i).rotangle=cumulativeNegAngle;
  end
  cumulativeAngle=Segment(i).rotangle;
  points=[points,[Segment(i).arcx;Segment(i).arcy]];%save points for plotting and etc
  sequence=[sequence,Segment(i).orientation];
end  
figure(2)
plot(CurveToFitx,CurveToFity)
hold on
plot(points(1,:),points(2,:),'r-')
%want to show where endpoints of macaroni segments went
for i=1:N
    plot(Segment(i).arcx(1),Segment(i).arcy(1),'rx')
end  
axis equal
segstr=sprintf('%d',N);
anglestr=sprintf('%d',segangle);
title(strcat(segstr, ' segments, ', anglestr,' degree segment angle'));
hold off




