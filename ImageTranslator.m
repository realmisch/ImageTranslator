function [CenterPath] = ImageTranslator(image,res,orientation,tol,geodesics,stretch)
    I_color = image;
    I = rgb2gray(I_color);
    I_dbl = double(I);
    I_dbl = imsharpen(I_dbl,'Radius',5,'Amount',tol,'threshold',0.1);
    [ylim,xlim]=size(I_dbl);

    %Checks orientation and changes image. Orientation from bottom of image.
    %'Down' is default
    if strcmp(orientation,'Up')==1
        I_dbl=flip(I_dbl);
    elseif strcmp(orientation,'Left')==1
        I_dbl=imrotate(I_dbl,270);
    elseif strcmp(orientation,'Right')==1
        I_dbl=imrotate(I_dbl,90);
    end

    %Rescaling image to fit bounds
    if strcmp(stretch,'Vert')==1
        I_dbl=imresize(I_dbl,[640 NaN]);
        [ylim,xlim]=size(I_dbl);
    elseif strcmp(stretch,'Hor')==1
        I_dbl=imresize(I_dbl,[NaN 875]);
        [ylim,xlim]=size(I_dbl);
    elseif strcmp(stretch,'Both')==1
        I_dbl=imresize(I_dbl,[640 875]);
        [ylim,xlim]=size(I_dbl);
    end
    
    if ylim>640
        scale=640/ylim;
        I_dbl=imresize(I_dbl,scale);
        [ylim,xlim]=size(I_dbl);
    end
    if xlim>875
        scale=875/xlim;
        I_dbl=imresize(I_dbl,scale);
        [ylim,xlim]=size(I_dbl);
    end
    I_dbl=flip(I_dbl);
    Edges=edge(I_dbl,'Canny',0.9);
    %Determines if a pixel is painted or not from resolution parameters
    for i=1:1:xlim
        for j=1:1:ylim
            %Bender is in charge of gambling
            bender=randi([0,99]);
            if Edges(j,i)==1
                I_dbl(j,i)=0;
            elseif bender>res
                I_dbl(j,i)=255;
            end
        end
    end
    
    %Returns the path to call
    CenterPath=draw_func(I_dbl,tol,geodesics);
end