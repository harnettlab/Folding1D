function effrad=macdraw(a)
%CKH 10-30-2012
%Draw some macaroni
N=200; %good for finding effective radius
%N=30;%good for simple plots

segangle=30;%macaroni arc angle
Seglength=1;%x length of macaroni
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

%Get a sequence from macdither algorithm
seq=macdither(a,N);

%set up some things
startangle=0; %angle in radians to rotate Arcx,Arcy for first segment
[posArcTH,posArcR]=cart2pol(Arcx,Arcy); %Get arc coordinates to polar for rotation
%Now try it with the negative arc
[negArcTH,negArcR]=cart2pol(Arcx,Narcy);

cumulativeAngle=startangle;
cumulativePosAngle=startangle;%variables needed to start up the process below
cumulativeNegAngle=startangle;
points=[];

for i=1:N  %go over the entire collection of macaroni segments
  %Determine which arc is a better fit using least-squares
  %And using John d'Errico's distance2curve function
  if(i>1)%set up angles so it's a smooth transition from one macaroni to the next
      if(seq(i-1)==0)%prev segment was positive
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
  if seq(i)==0
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
end  
totalAngle=cumulativeAngle;%total arc angle in radians will help compute effective radius
if cumulativeAngle==0
    effrad=Inf;
else
    effrad=N*Seglength/cumulativeAngle;
end    
figure(2)
hold off
%plot(points(1,:),points(2,:),'r-')
%want to show where endpoints of macaroni segments went
for i=1:N
	if Segment(i).orientation==-1
        plot(Segment(i).arcx,Segment(i).arcy,'r');%plot it in red
    else
		plot(Segment(i).arcx,Segment(i).arcy,'b');%plot it in blue
    end
    hold on
    %plot(Segment(i).arcx(1),Segment(i).arcy(1),'rx')
end  
axis equal
segstr=sprintf('%d',N);
anglestr=sprintf('%d',segangle);
title(strcat(segstr, ' segments, ', anglestr,' degree segment angle'));




