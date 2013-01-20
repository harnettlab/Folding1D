%Runs macdraw to calculate effective radius and plot it
myrad=[];
x=0.51:0.01:1;
for a=0.51:0.01:1
    myrad=[myrad,macdraw(a)]
end
hold off
semilogy(x,myrad)
axis ([0.5 1 1 120])
xlabel('Fraction of segments that are convex-out')
ylabel('Log of (effective curvature radius/single segment span)')
title('Effective radius vs segment orientation ratio for 30-degree segments')