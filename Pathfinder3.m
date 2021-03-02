function [Path] = Pathfinder3(shade)
    %Pathfinder Version 3.0
    %Now with shades!
    %James Nellis 2021
    [ylim,xlim]=size(shade);

    archive=ones([ylim,xlim]);      %Tracks which pixels have been checked
    sumcheck=sum(archive,'all');    %Checks algorithm progress
    i=1;                            %x-coordinate
    j=1;                            %y-coordinate
    count=1;                        %Path coordinate pair number
    xlist=[];                       %List of x-coordinates to visit
    ylist=[];                       %List of y-coordinates to visit
    radius=1;                       %Box-search radius

    %No need to visit whitespace, sets all whitespace to 'checked'
    for w=1:xlim
        for v=1:ylim
            if shade(v,w)==0
                archive(v,w)=0;
            end
        end
    end

    %Main Pathfinder
    while sumcheck~=0
        disp(ceil(sumcheck*0.0001))
        %MrHouse is in charge of gambling, random probability if a shade
        %pixel is visited
        mrhouse=randi([1,100]);
        %Creating the path, with probabilities for non-blackspace pixels
        if archive(j,i)==1 && shade(j,i)==3
            xlist(count)=i;
            ylist(count)=j;
            count=count+1;
        elseif archive(j,i)==1 && shade(j,i)==2 && mrhouse>96
            xlist(count)=i;
            ylist(count)=j;
            count=count+1;
        elseif archive(j,i)==1 && shade(j,i)==1 && mrhouse>99
            xlist(count)=i;
            ylist(count)=j;
            count=count+1;
        end
        archive(j,i)=0;
        %Finding the next pixel using a box-search algorithm
        while archive(j,i)==0
            for m=-radius:1:radius
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
                if archive(j,i)==1
                    break
                end
            end
            %If a pixel is found, reset algorithm, if not, look harder and
            %farther
            if archive(j,i)==0
                radius=radius+1;
            else
                radius=1;
            end
        end
        sumcheck=sum(archive,'all');
        %"Good Enough" Approximation
        if sumcheck<500
            sumcheck=0;
        end
    end
    %Return the Path
    Path=cat(1,xlist,ylist);
end