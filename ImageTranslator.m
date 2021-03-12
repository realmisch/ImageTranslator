function [CenterPath] = ImageTranslator(image,res,orientation,tol)
    I_color = image;
    I = rgb2gray(I_color);
    I_dbl = double(I);
    [ylim,xlim]=size(I_dbl);
    %orientation='down';

    %res=1;
    paintit=1;
    resvar=100-res;

    %Checks orientation and changes image. Orientation from bottom of image.
    %'down' is default
    if strcmp(orientation,'Up')==1
        I_dbl=flip(I_dbl);
    elseif strcmp(orientation,'Left')==1
        I_dbl=imrotate(I_dbl,270);
    elseif strcmp(orientation,'Right')==1
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
            if paintit>=100 && I_dbl(j,i)<220
                I_dbl(j,i)=255;
                paintit=paintit-100;
            elseif I_dbl(j,i)<200
                paintit=paintit+resvar;
            end
        end
    end

    CenterPath=draw_func(I_dbl,tol);
end