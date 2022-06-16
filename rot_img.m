function [img_rot_gray,rot_add] = rot_img(img,rand_stdev)
%Input image to be rotated (string)
%Output image after rotation (string)
% 
% img_mat = imread(img); 
cov = rand_stdev^2;
rot_add = cov*randn; %Random rotation (degrees)
img_rot_mat = imrotate(img,rot_add); %Adding randomized rotation btw images
img_rot_gray = mat2gray(img_rot_mat);
% img_rot = imsave(@img_rot_mat);  %Save new rotated image (output)

end