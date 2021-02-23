function [matff] = dots()


%note full range is approximately rangex=875 full rangey=610
%but you should measure yours
matff=[0 0; 100 100; 100 200; 105 200; 105 100; 105 105; 200 105; 200 100; 100 100];

    
%draw matff in animation
% note this shows what it would look like with perfect control and lines
% being drawn.  Actual results will differ because of backlash and
% the drawing mechanics of an etch-a-sketch
figure
h=animatedline;
axis([0 875 0 640])

for i=1:length(matff)
    addpoints(h,matff(i,1),matff(i,2))
    
    pause(1) %delays when it appears on screen so that you can watch how it will draw.  If you want it to be instant then make pause 0.

end
end

