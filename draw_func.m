function [] = draw_func(shade,image)

    h=animatedline;
    axis([0,875,0,640])
    [ysize,xsize]=size(image);
    CompletedPath=Pathfinder2(shade);
    for count=1:length(CompletedPath)
        %Centering the image assuming Etch-A-Sketch bounds
        x(count)=CompletedPath(1,count)+(875-xsize)/2;
        y(count)=CompletedPath(2,count)+(640-ysize)/2;
        addpoints(h,x(count),y(count))
    end
end

