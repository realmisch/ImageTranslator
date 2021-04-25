function [Path] = Pathfinder3(I_dbl,tol,geodesics,shadeno)
    %Pathfinder Version 3.5
    %Now with Shading and Geodesics!
    %James Nellis 2021
    [ylim,xlim]=size(I_dbl);

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
    %Redundant Edge detection to make them more visible
    Edges=edge(I_dbl,'Sobel');
    check=0;
    %Sum of all unvisited pixels in a continuous body to reduce whitespace
    %lines
    bodysum=1;
    
    %No need to visit whitespace, sets all whitespace to 'checked'
    for w=1:xlim
        for v=1:ylim
            if I_dbl(v,w)>=220
                archive(v,w)=0;
            end
            if Edges(v,w)==1
                I_dbl(v,w)=0;
            end
        end
    end
    
    %Generates masks for geodesics and labels continuous bodies
    mask=(I_dbl<200);
    bodycheck=bwlabel(mask);
 
    %Main Pathfinder
    while sumcheck~=0
        %Percent update bar
        percent=1-sumcheck/initsumcheck;
        if mod(100*(percent),1)==0
            percentage=sprintf('%3.f%% Complete',percent*100);
            waitbar(percent,wait,percentage);
            drawnow
        end
        
        fprintf(output,100*(1-sumcheck/initsumcheck))
        %Cancels function if user presses cancel button
        if getappdata(wait,'canceling')
            break
        end
        
        %Bender is in charge of gambling, random probability if a shade
        %pixel is visited. "I'm gonna make my own park with Blackjack..."
        bender=randi([0,99]);
        
        %Dynamic shading with 255 possible shades
        Probability=(1-(I_dbl(j,i)*tolerance)/255)*100;
        %Quantized Probability to improve distinguishing shades based on
        %user parameter
        qProbability=round(Probability*shadeno)*(1/shadeno);
        
        %Creating the path, with probabilities for non-blackspace pixels
        if archive(j,i)==1 && qProbability>bender
            xlist(count)=i;
            ylist(count)=j;
            count=count+1;
        end
        archive(j,i)=0;
        
        %Finding the next pixel using a box-search algorithm
        while archive(j,i)==0
            cury=j;
            curx=i;
            for b=1:xlim
                for c=1:ylim
                    if bodycheck(c,b)==bodycheck(cury,curx)
                        bodysum=bodysum+archive(c,b);
                    end
                end
            end
            for m=-radius:radius
                xindex=i+m;
                yindex=j+m;
                %Box search algorithm
                if xindex<=0 || xindex>xlim || yindex<=0 || yindex>ylim
                    %We have fallen off the Flat Earth and found a turtle
                elseif i-radius>0 && archive(yindex,i-radius)==1 && (bodycheck(j,i)==bodycheck(cury,curx) || bodysum==0)
                    %Searching Right Side of the box
                    i=i-radius;
                    j=yindex;
                elseif i+radius<=xlim && archive(yindex,i+radius)==1 && (bodycheck(j,i)==bodycheck(cury,curx) || bodysum==0)
                    %Searching Left Side of the box
                    i=i+radius;
                    j=yindex;
                elseif j-radius>0 && archive(j-radius,xindex)==1 && (bodycheck(j,i)==bodycheck(cury,curx) || bodysum==0)
                    %Searching Bottom of the box
                    i=xindex;
                    j=j-radius;
                elseif j+radius<=ylim && archive(j+radius,xindex)==1 && (bodycheck(j,i)==bodycheck(cury,curx) || bodysum==0)
                    %Searching Top of the box
                    i=xindex;
                    j=j+radius;
                end
                
                %Stops chasing windmills when it found a pixel
                if archive(j,i)==1
                    break
                    bodycheck=1;
                end
            end
            
            %If a pixel is found, reset algorithm, if not, look harder and
            %farther
            if archive(j,i)==0
                radius=radius+1;
            else
                radius=1;
                check=0;
            end
            %Reset radius search if algorithm gets stuck
            if radius>=10000 && check==0
                radius=0;
                check=1;
            %If algorithm is stuck again, break algorithm
            elseif radius>=10000 && check==1
                break
                check=0;
            end
        end
        
        %Geodesics search function if the user wants to use them
        if archive(j,i)==1 && geodesics==1 && (abs(curx-i)>1 || abs(cury-j)>1)
            [geox,geoy]=geodesicpathfind(curx,cury,i,j,I_dbl);
            for u=1:length(geox)
                xlist(count)=geox(u);
                ylist(count)=geoy(u);
                archive(ylist(count),xlist(count))=0;
                count=count+1;
            end
        end
           
        %Ends program if it gets stuck
        if radius>10000
            sumcheck=0;
            fprintf('Radius too big')
        else
            sumcheck=sum(archive,'all');
        end
        
        %"Good Enough" Approximation
        if sumcheck<50
            sumcheck=0;
            fprintf('100%% Complete\n');
        end
    end
    
    %Checks if user pressed cancel button on waitbar
    if getappdata(wait,'canceling')==0
        finish=waitbar(1,'Complete','Name','Progress Bar');
        pause(1)
        close(finish)
    end 
    
    %Return the Path
    Path=cat(1,xlist,ylist);
    
    %Close Waitbar
    delete(wait)
end