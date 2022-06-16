%run_ekf_pole

% Run file for ekf_ploe.m
clc, clear, close all;

tic

rng(1);

X_0 = [100 0 0 0 0 0 1/sqrt(2) 1/sqrt(2) 0];
P_0 = eye(9);
dtheta = 5;
time = 0:dtheta:(360-dtheta); %Currently the angle, not the time (Probably needs fixing)

% Load predicted images and create lenght(time) layered matrix of grayscale
% image values (loop below)
for j = 1:length(time)
    stringj = string(j);
    %If running from non-Matez device, change below filename as necessary
    pred_img_j = 'C:\Users\matez\OneDrive - UCB-O365\Documents\ASEN_ORCCA_Research\bennu_dataset\bennu_automated_images\render';
    pred_img_j = strcat(pred_img_j,stringj);
    pred_img_j = strcat(pred_img_j,'.png');
    pred_img_color = imread(pred_img_j); %Colored image
    pred_img_gray = mat2gray(pred_img_color); %Convert to grayscale
    pred_img(:,:,j) = pred_img_gray(:,:,1); %Convert to single layer matrix
end

%% Rotate randomly
%They must be rotated for the observed set (for test case)
%ROTATE RANDOMLY AND STORE

rand_stdev = 1; %standard deviation of rotations (edit as necessary, possible tuning parameter)

for j = 1:length(time)
[img_rot_gray,rot_add(j)] = rot_img(pred_img(:,:,j),rand_stdev);
img_rot_gray_scaled = imresize(img_rot_gray,size(pred_img(:,:,j)));
obs_img(:,:,j) = img_rot_gray_scaled; %LOOP AND INDEX
end

% ABOVE - Preparation of Data
% BELOW - Run Filter

%% Run EKF

dyn = 0; %Which Dynamics Model?
[x_plus,P_plus] = ekf_pole(X_0,P_0,time,pred_img,obs_img,dyn);

% Do fun stuff with results :)
figure()
plot(1:length(x_plus),x_plus(7:9,:))
xlabel('step')
ylabel('pole estimate')

toc