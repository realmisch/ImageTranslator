function [Path] = Pathfinder2(shade)
    
    [ylim,xlim]=size(shade);
    %archive tracks which points have or have not been visited
    archive=ones([ylim,xlim]);
    
    res=3;          %Resolution variable, determines size of spiral sample
    i=1;            %x-coordinate
    j=1;            %y-coordinate
    count=2;        %counter for the point number in the path
    xlist=[];       %list of x-values for the path in sequential order
    ylist=[];       %list of y-values for the path in sequential order
    log=[1,1];      %Storage for last point visited by algorithm
    sumcheck=1;     %Checks how many points need to be visited
    shade(1,1)=3;   %setting starting point to black to start algorithm
    
    xlist(1)=1;     %Setting the drawing to start at (1,1)
    ylist(1)=1;
    
    %Setting all non-blackspace as "seen" for speed purposes. Will remove 
    %when shading is added    
    for v=1:xlim
        for w=1:ylim
            if shade(w,v)~=3
                archive(w,v)=0;
            end
        end
    end
    
    %Main Pathfinder
    while sumcheck~=0
        %Pseudo-timer edited to be more readable in approximate seconds
        disp(ceil(sumcheck*0.0001))
        
        %Commands to run when current point is black and unchecked
        while shade(j,i)==3 && archive(j,i)==1
            xlist(count)=log(1);            
            ylist(count)=log(2);
            xlist(count+1)=i;
            ylist(count+1)=j;
            archive(j,i)=0;
            count=count+1;
            r=1;
            m=0;
            n=0;
            dx=0;
            dy=-1;
            
            %Algorithm to find next point using a spiral search
            while r<=(res^2)
                xindex=i+dx;
                yindex=j+dy;
                if xindex>xlim || xindex<=0 || yindex>ylim || yindex<=0
                    %If the Earth is flat, we fell off. Algorithm out of
                    %bounds
                elseif shade(yindex,xindex)==3 && archive(yindex,xindex)==1
                    archive(j,i)=0;
                    log(1)=xindex;
                    log(2)=yindex;
                end
                %Playing Snake game but pixel perfect
                %Spiral search algorithm
                if xindex-i==yindex-j || (xindex-i<0 && xindex-i==-(yindex-j))
                    dx=-dy;
                    dy=dx;
                elseif (yindex-j<0 && xindex-i==-(yindex-j))
                    dx=-dy;
                    dy=dx;
                end
                r=r+1;
            end
        end
        
        %Random point in local vicinity when Pathfinder is stuck. Will be
        %changed when shading is added
        while shade(j,i)~=3 || archive(j,i)==0
            localx=randi([-1,1]);
            localy=randi([-1,1]);
            i=i+localx;
            j=j+localy;
            
            %Keeping the random points on this "Flat Earth"
            while i<1
                i=i+abs(localx);
            end
            while j<1
                j=j+abs(localy);
            end
            while i>xlim
                i=i-abs(localx);
            end
            while j>ylim
                j=j-abs(localy);
            end
        end
        sumcheck=sum(archive,'all');
        %"Good Enough" Approximation, stops algorithm when less than 20
        %pixels need to be visited
        if sumcheck<20
            sumcheck=0;
        end
    end
    %Return the planned path
    Path=cat(1,xlist,ylist);
end