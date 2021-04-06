function [Path] = Pathfinder3(I_dbl,tol,geodesics)
    %Pathfinder Version 3.0
    %Now with User Control!
    %James Nellis 2021
    [ylim,xlim]=size(I_dbl);
    disp(geodesics)

    archive=ones([ylim,xlim]);      %Tracks which pixels have been checked
    sumcheck=sum(archive,'all');    %Checks algorithm progress
    initsumcheck=sum(archive,'all');   %initial number of pixels
    output='%3.2f%% Complete\n';
    i=1;                            %x-coordinate
    j=1;                            %y-coordinate
    count=1;                        %Path coordinate pair number
    xlist=([50000]);                %List of x-coordinates to visit
    ylist=([50000]);                %List of y-coordinates to visit
    radius=1;                       %Box-search radius
    wait=waitbar((1-sumcheck/initsumcheck),'Creating Path','Name','Progress Bar','CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
    setappdata(wait,'canceling',0);
    tolerance=tol;
    Edges=edge(I_dbl,'Sobel');
    mask2=zeros([ylim,xlim]);
    check=0;
    
    %No need to visit whitespace, sets all whitespace to 'checked'
    for w=1:xlim
        for v=1:ylim
            if I_dbl(v,w)>=220
                archive(v,w)=0;
            end
            if Edges(v,w)==1
                I_dbl(v,w)=0;
            end
            if mod(w,10)==0
                mask2(v,w)=1;
            end
            if mod(v,10)==0
                mask2(v,w)=1;
            end
        end
    end
    
    if geodesics==1
        mask=(I_dbl<200);
        mask2=mask2+mask;
    end
    
    tic
    timeout=toc;
    %Main Pathfinder
    while sumcheck~=0
        jump=0;
        percent=1-sumcheck/initsumcheck;
        if mod(100*(percent),1)==0
            percentage=sprintf('%3.f%% Complete',percent*100);
            waitbar(percent,wait,percentage);
            drawnow
        end
        fprintf(output,100*(1-sumcheck/initsumcheck))
        if getappdata(wait,'canceling')
            break
        end
        
        %Bender is in charge of gambling, random probability if a shade
        %pixel is visited. "I'm gonna make my own park with Blackjack..."
        bender=randi([0,99]);
        
        %Dynamic shading with 255 possible shades
        Probability=(1-(I_dbl(j,i)*tolerance)/255)*100;
        
        %Creating the path, with probabilities for non-blackspace pixels
        if archive(j,i)==1 && Probability>bender
            xlist(count)=i;
            ylist(count)=j;
            count=count+1;
        end
        archive(j,i)=0;
        
        %Finding the next pixel using a box-search algorithm
        while archive(j,i)==0
            for m=-radius:radius
                cury=j;
                curx=i;
                xindex=i+m;
                yindex=j+m;
                if xindex<=0 || xindex>xlim || yindex<=0 || yindex>ylim
                    %We have fallen off the Flat Earth and found a turtle
                elseif i-radius>0 && archive(yindex,i-radius)==1
                    %Searching Right Side of the box
                    i=i-radius;
                    j=yindex;
                elseif i+radius<=xlim && archive(yindex,i+radius)==1
                    %Searching Left Side of the box
                    i=i+radius;
                    j=yindex;
                elseif j-radius>0 && archive(j-radius,xindex)==1
                    %Searching Bottom of the box
                    i=xindex;
                    j=j-radius;
                elseif j+radius<=ylim && archive(j+radius,xindex)==1
                    %Searching Top of the box
                    i=xindex;
                    j=j+radius;
                end
                %Stops chasing windmills when it found one
                if archive(j,i)==1 %|| timeout>=60
                    break
                end
            end
            %If a pixel is found, reset algorithm, if not, look harder and
            %farther
            if archive(j,i)==0
                radius=radius+1;
            elseif archive(j,i)==1 && geodesics==1 && radius>2
                radius=1;
                xpoints=[i,curx];
                ypoints=[j,cury];
                planner=bwdistgeodesic(mask,xpoints,ypoints,'quasi-euclidean');
                planner(isnan(planner))=inf;
                [row,col]=find(planner==1);
                dist=(((row-cury).^2)+((col-curx).^2)).^0.5;
                distpath=cat(2,cat(2,row,col),dist);
                orderedpath=sortrows(distpath,3);
                for k=2:length(row)-1
                    jump=distpath(k,3)-distpath(k-1,3);
                    if jump>10
                        gridplanner=bwdistgeodesic(cast(mask2,'logical'),xpoints,ypoints,'quasi-euclidean');
                        gridplanner(isnan(gridplanner))=inf;
                        [row,col]=find(gridplanner==1);
                        dist=(((row-cury).^2)+((col-curx).^2)).^0.5;
                        distpath=cat(2,cat(2,row,col),dist);
                        orderedpath=sortrows(distpath,3);
                        break
                    end
                end
                for u=1:length(row)-1
                   xlist(count)=distpath(u,2);
                   ylist(count)=distpath(u,1);
                   archive(ylist(count),xlist(count))=0;
                   count=count+1;
                end
            else
                radius=1;
                check=0;
            end
            if radius>=10000 && check==0
                radius=0;
                check=1;
            elseif radius>=10000 && check==1
                break
            end
        end
        if radius>10000
            sumcheck=0;
            disp(geodesics)
            fprintf('Radius too big')
        else
            sumcheck=sum(archive,'all');
        end
        
        %Timeout to stop the path if it is taking too long
        timeout=toc;
        %"Good Enough" Approximation
        if sumcheck<100 %|| timeout>=60
            sumcheck=0;
            fprintf('100%% Complete\n');
        end
    end
    %Return the Path
    if getappdata(wait,'canceling')==0
        finish=waitbar(1,'Complete','Name','Progress Bar');
        pause(1)
        close(finish)
    end
    delete(wait)
    Path=cat(1,xlist,ylist);
end