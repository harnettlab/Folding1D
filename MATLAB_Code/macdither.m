function xout=macdither(a,N)
%macdither: dither a 1-dimensional grayscale pattern
%ranging from 0 to 1, into a 1-bit sequence
%a is an integer btw 0 and 1
%N=50; %sequence length
x=ones(1,N)*a;
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