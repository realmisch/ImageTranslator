function [CenterPath] = draw_func(image,tol,geodesics)
    CompletedPath=Pathfinder3(image,tol,geodesics);
    f=figure('Name','Preview Image');
    h=animatedline;
    axis([0,875,0,640])
    [ysize,xsize]=size(image);
    inaccuracy=0;
    addpoints(h,1,1)
    numpoints=length(CompletedPath);
    for count=1:numpoints
        %Centering the image assuming Etch-A-Sketch bounds
        x(count)=CompletedPath(1,count)+(875-xsize)/2;
        y(count)=CompletedPath(2,count)+(640-ysize)/2;
        addpoints(h,x(count),y(count))
    end
    hrs=numpoints/3600;
    min=mod(numpoints,3600)/60;
    sec=mod(numpoints,60);
    disp(sec)
    ETA=sprintf('Estimated Time to Completion: %2.0f Hr %2.0f Min %2.0f Sec',hrs,min,sec);
    title(ETA)
    saveas(h,'compareimg.png');
    compareimg=imread('compareimg.png');
    dblimg=double(compareimg);
    for x=1:xsize
        for y=1:ysize
            if image(y,x)~=dblimg(y,x)
                inaccuracy=inaccuracy+1;
            end
        end
    end
    inaccalc=100*inaccuracy/(xsize*ysize);
    disp(count)
    fprintf('Path is %3.2f%% Accurate',inaccalc)
    CenterPath=cat(1,x,y);
end

