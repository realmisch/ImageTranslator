%James Nellis 
%vxn5069
%2021
clear
clc

I_color = imread('shield.png');
I = rgb2gray(I_color);
I_dbl = double(I);
[ylim,xlim]=size(I_dbl);
orientation='right';

%Shade Values for every pixel
s=[];    
s=zeros([875,640]);

res=10;
paint=1;

if strcmp(orientation,'up')==1
    I_dbl=flip(I_dbl);
elseif strcmp(orientation,'left')==1
    I_dbl=imrotate(I_dbl,270);
elseif strcmp(orientation,'right')==1
    I_dbl=imrotate(I_dbl,90);
end

%Rescaling image to fit bounds
if ylim>640
    scale=640/ylim;
    I_dbl=imresize(I_dbl,scale);
    I_dbl=flip(I_dbl);
    [ylim,xlim]=size(I_dbl);
end
if xlim>875
    scale=875/xlim;
    I_dbl=imresize(I_dbl,scale);
    I_dbl=flip(I_dbl);
    [ylim,xlim]=size(I_dbl);
end

%Getting shading values for every pixel
for i=1:1:xlim
    for j=1:1:ylim
        if I_dbl(j,i)<65
            s(j,i)=3;
        elseif I_dbl(j,i)<200
            s(j,i)=2;
        elseif I_dbl(j,i)<0
            s(j,i)=1;
        else 
            s(j,i)=0;
        end
        if paint>=res && s(j,i)~=0
            s(j,i)=0;
            paint=0;
        elseif s(j,i)~=0
            paint=paint+(res^0.5);
        end
    end
end

CenterPath=draw_func(s,I_dbl);
%figure(3);
%imshow(I);