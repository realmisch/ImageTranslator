function [CenterPath] = draw_func(image,tol,geodesics,shadeno)
    %Newpath sets draw_func to repeat unless user specifies otherwise
    %Used to automatically path edited images
    newpath=1;
    while newpath==1
        CompletedPath=Pathfinder3(image,tol,geodesics,shadeno);
        f1=figure;
        h=animatedline;
        axis([0,875,0,640])
        %Remove axis visibility for editing
        set(gca,'xtick',[],'ytick',[])
        [ysize,xsize]=size(image);
        
        %Begin plotting path using animatedline
        addpoints(h,1,1)
        numpoints=length(CompletedPath);
        for count=1:numpoints
            %Centering the image assuming Etch-A-Sketch bounds
            x(count)=CompletedPath(1,count)+(875-xsize)/2;
            y(count)=CompletedPath(2,count)+(640-ysize)/2;
            addpoints(h,x(count),y(count))
        end
        %ETA variables based on the number of points
        %Assumes motors process 4.66 pixels per second
        dist0=0;
        for i=2:length(CompletedPath)
            dist0=dist0+((x(i)-x(i-1)).^2+(y(i)-y(i-1)).^2).^0.5;
        end
        hrs=(dist0/4.66)/3600;
        min=mod((dist0/4.66),3600)/60;
        sec=mod((dist0/4.66),60);

        ETA=sprintf('Estimated Time to Completion: %2.0f Hr %2.0f Min %2.0f Sec',hrs,min,sec);
        title(ETA)
        %Question Box if the user wants to edit or not
        drawpopup=questdlg({'Would you like to edit the image?';'WARNING: This will increase the expected time to print'},'Edit Figure','Yes','No','No');
        switch drawpopup
            case 'Yes'
                help=msgbox('Press "Enter" when you are finished','Help');
                figure(f1)
                %Allows user to draw on preview image
                d=drawfreehand('Color','w','LineWidth',7,'InteractionsAllowed','None','Multiclick',true);
                if exist('help','var')
                    delete(help);
                    clear('help');
                end
                %Commands to save the user's drawing as a new image
                dpoints=d.Position;
                delete(d);
                hold on
                userx=dpoints(:,1);
                usery=dpoints(:,2);
                userline=animatedline('Color','w','LineWidth',7);
                for v=1:length(userx)
                    addpoints(userline,userx(v),usery(v))
                end
                saveas(gcf,'Outputimg.png')
                compareimg=double(rgb2gray(imcrop(imread('Outputimg.png'),[115.51 49.51 676.98 532.98])));
                compareimg=imresize(compareimg,[640 875]);
                image=flip(compareimg);
                close(f1)
                imwrite(compareimg,'Outputimg.png');
                %Tell program to repeat with compareimg set as new image
                newpath=1;
            otherwise
                %User does not want to edit
                saveas(gcf,'Outputimg.png')
                CenterPath=cat(1,x,y);
                delete 'Outputimg.png'
                %Tell program to not repeat
                newpath=0;
        end
    end
end

