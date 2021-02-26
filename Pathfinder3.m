function [Path] = Pathfinder3(shade)
    
    [ylim,xlim]=size(shade);
    
    archive=ones([ylim,xlim]);
    sumcheck=sum(archive,'all');
    i=1;
    j=1;
    count=1;
    xlist=[];
    ylist=[];
    log=[1,1];
    radius=1;
    
    while sumcheck~=0
        mrhouse=randi([1,100]);
        if archive(j,i)==1 && shade(j,i)==3
            xlist(count)=i;
            ylist(count)=j;
            count=count+1;
        elseif archive(j,i)==1 && shade(j,i)==2 && mrhouse>60
            xlist(count)=i;
            ylist(count)=j;
            count=count+1;
        elseif archive(j,i)==1 && shade(j,i)==1 && mrhouse>80
            xlist(count)=i;
            ylist(count)=j;
            count=count+1;
        end
        archive(j,i)=0;
        
        for m=-radius:1:radius
            
            
    end
    
end