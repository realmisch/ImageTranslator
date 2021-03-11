function [CenterPath] = draw_func(image)
    CompletedPath=Pathfinder3(image);
    figure(1);
    h=animatedline;
    res=5;
    axis([0,875,0,640])
    [ysize,xsize]=size(image);
    addpoints(h,1,1)
    for count=1:length(CompletedPath)
        %Centering the image assuming Etch-A-Sketch bounds
        x(count)=CompletedPath(1,count)+(875-xsize)/2;
        y(count)=CompletedPath(2,count)+(640-ysize)/2;
        addpoints(h,x(count),y(count))
    end
    CenterPath=cat(1,x,y);
end

