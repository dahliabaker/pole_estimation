function [cx_i,cy_i] = centerfind(obs_img)
    
    %make sure the images are passed in already grayscale
    
    %now it's masked
    %time to find center of brightness
    top = 0;
    bottom = 0;
    len = 1:length(obs_img(1,:));
    for k = 1:length(obs_img(1,:))
        top = top+sum(double(obs_img(k,:)).*len);
        bottom = bottom+sum(double(obs_img(k,:)));
    end
    scob = cast((top/bottom),'uint64');

    top = 0;
    bottom = 0;
    len = 1:length(obs_img(:,1));
    for k = 1:length(obs_img(:,1))
        top = top+sum(double(obs_img(:,k)).*len');
        bottom = bottom+sum(double(obs_img(:,k)));
    end

    lcob = cast((top/bottom),'uint64');

    
    cx_i = scob;
    cy_i = lcob;
end



