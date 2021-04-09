function [CenterPath] = draw_func(image,tol,geodesics)
newpath=1;
while newpath==1
    CompletedPath=Pathfinder3(image,tol,geodesics);
	f1=figure
    h=animatedline;
    axis([0,875,0,640])
    set(gca,'xtick',[],'ytick',[])
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
    drawpopup=questdlg('Would you like to edit the image?','Edit Figure','Yes','No','No');
    switch drawpopup
        case 'Yes'
            help=msgbox('Press "Enter" when you are finished','Help');
            figure(f1)
            d=drawfreehand('Color','w','LineWidth',10,'InteractionsAllowed','None','Multiclick',true);
            if findobj(help)==1
                delete(help)
            end
            dpoints=d.Position;
            delete(d);
            hold on
            userx=dpoints(:,1);
            usery=dpoints(:,2);
            userline=animatedline('Color','w','LineWidth',10);
            for v=1:length(userx)
                addpoints(userline,userx(v),usery(v))
            end
            saveas(gcf,'Outputimg.png')
            compareimg=double(rgb2gray(imcrop(imread('Outputimg.png'),[115.51 49.51 676.98 532.98])));
            compareimg=imresize(compareimg,[640 875]);
            image=flip(compareimg);
            close(f1)
            newpath=1;
            imwrite(compareimg,'Outputimg.png');
        case 'No'
            saveas(gcf,'Outputimg.png')
            CenterPath=cat(1,x,y);
            newpath=0;
    end
end
end

