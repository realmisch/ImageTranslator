%James Nellis 
%vxn5069
%2021
clear
clc

I_color = imread('shield.png');
I = rgb2gray(I_color);
I_dbl = double(I);
[ylim,xlim]=size(I_dbl);

%Shade Values for every pixel
s=[];    
s=zeros([875,640]);

%Rescaling image to fit bounds
if ylim>640
    scale=640/ylim;
    I_dbl=imresize(I_dbl,scale);
    I_dbl=flip(I_dbl);    
    [ylim,xlim]=size(I_dbl);
elseif xlim>875
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
    end
end

figure(1);
draw_func(s,I_dbl)
figure(3);
imshow(I);