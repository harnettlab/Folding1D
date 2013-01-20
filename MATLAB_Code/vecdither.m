function xout=vecdither(a)
%vecdither: dither a grayscale sequence
%into a 1-bit sequence

x=a;
%Optional: rescale a to range between 0 and 1
%x=(a-min(a))/(max(a)-min(a));

N=length(x);
for i=1:N
    oldstate=x(i);
    newstate=round(x(i));%here convert it to 1-bit
    x(i)=newstate;
    quant_error=oldstate-newstate;
    if i<N
       x(i+1)=x(i+1)+quant_error;
    end
end
xout=x;