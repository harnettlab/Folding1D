%Draw a curve, figure out local curvature using 2d curvature
%Color plot curvature using conditional color plot ccplot function
%Translate the curvature to fraction of segments oriented out
%
th=0:0.01:(2*pi);
rho=10/1.7*( 0.5*sin(2.5*(th+pi/10)).^2+1);
%rho=1;
%polar(th,rho)
[x y]=pol2cart(th,rho);
k=LineCurvature2D([x',y']);
%map=colormap(jet);
%ccplot(x,y,k',map)
%excellent but what are units of curvature, 1/same units of plot
%axis equal
segscale=1;%Multiplier, higher means more segments will be generated
cmax=max(abs(k))*segscale %highest curvature determines the segment chord length
%negative curvature is overestimated and this opens out the star too much

%and number of segments needed
%Curvature is linear with fraction of convex-out segments,
%k=ma+b where a is the fraction of convex-out.
%Find m and b with two points (k,a) = (0,0.5) --it's flat at equal segment fraction
%and (cmax,1)--it's a circle at all-convex-out
%2pi/cmax=L*360/segangle puts cmax in units of segment chord length L
%cmax=2pi*(segangle/360)/L
%invert it: a=(k-b)/m
%b=-cmax, m=2*cmax/1 so a=(k+cmax)/(2*cmax)


%solve for L--the maximum segment chord length for a given segangle, usually 30 deg
segangle=30;
L=2*pi/max(abs(k))*segangle/360/segscale;
arclen=arclength(x,y);%calc how many segments are needed
N=ceil(arclen/L);
%If I didn't have access to the function that made
%the original curve, I would try to interpolate
%th=linspace(0,2*pi,N);%regenerate the plot with N points
%rho=10/1.7*(0.5*sin(2.5*(th+pi/10)).^2+1);
%[x y]=pol2cart(th,rho);
[x,y]=linspacearc(x,y,N);%new FIXED IT, thank you Mathworks contributors
k=LineCurvature2D([x',y']);%get curvature of resampled curve
map=colormap(jet);
h=ccplot(x,y,k',map)
set(h,'Marker','x')
axis equal
%looking like it's trying but something is distorted
%for one, I am not going along the curve in equal increments SEE ABOVE FIX,
%linspacearc
a=(k+cmax)/(2*cmax); %calculate positive segment fraction
figure(4)
plot(a)
		 
seq=vecdither(a);%figure out the best sequence to match k
vecdraw(seq,segangle,L); %then draw the macaroni
hold on
plot(x-x(1),y-y(1),'m')
%distx=x(1:(end-1))-x(2:end);
%disty=y(1:(end-1))-y(2:end);
%dist=sqrt(distx.^2+disty.^2);
%figure()
%plot(dist); %yup uneven sampling is causing distortion
%--oversampling the curved parts compared to the radial stretches
%title('Distance between adjacent points along curve')%ideally a constant straight line