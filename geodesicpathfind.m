function [xpoints,ypoints] = geodesicpathfind(x1,y1,x2,y2,mask,I)
mask=flip(mask);
mask=bwmorph(mask,'clean');
body=bwlabel(mask);
[ylim,xlim]=size(I);
bw1=zeros([ylim,xlim]);
bw2=bw1;

x=[x1,x2];
y=[y1,y2];

bw1(y(1),x(1))=1;
bw2(y(2),x(2))=1;
seed1=(bw1==1);
seed2=(bw2==1);
method='quasi-euclidean';

D1=bwdistgeodesic(mask,seed1,method);
D2=bwdistgeodesic(mask,seed2,method);
D=D1+D2;
D=round(D*8)/8;
D(isnan(D))=inf;
paths=(imregionalmin(D));
smoothcheck=bwlabel(paths);
P=false(size(I));
P=imoverlay(P,mask,[1 0 0]);

thin=bwmorph(paths,'skel',inf);
branches=bwmorph(thin,'branchpoints');

xlist=[];
ylist=[];
cury=y(1);
curx=x(1);
curpnt=[y(1),x(1)];
count=1;
r=1;
pnt=1;
[row,col]=find(thin==1);
nopnt=length(row);

while pnt<nopnt
    min=inf;
    for m=1:length(row)
        dist=sqrt(((curx-col(m)).^2)+((cury-row(m)).^2));
        if dist<min
            min=dist;
            x1=col(m);
            y1=row(m);
            m=1;
        end
    end
    curx=x1;
    cury=y1;
    xlist(count)=x1;
    ylist(count)=y1;
    if count>1 && branches(ylist(count-1),xlist(count-1))==1
        m=1;
        bw1(y(1),x(1))=0;
        bw1(ylist(count),xlist(count))=1;
        seed1=bw1==1;
        D1=bwdistgeodesic(mask,seed1,method);
        D2=bwdistgeodesic(mask,seed2,method);
        D=D1+D2;
        D=round(D*8)/8;
        D(isnan(D))=inf;
        paths=(imregionalmin(D));
        cury=ylist(count);
        curx=xlist(count);
        curpnt=[cury,curx];
        count=1;
        r=1;
        pnt=1;
        [row,col]=find(thin==1);
        nopnt=length(row);
    end
    thin(cury,curx)=0;
    count=count+1;
    pnt=pnt+1;
    [row,col]=find(thin==1);
end


xpoints=xlist;
ypoints=ylist;
end

