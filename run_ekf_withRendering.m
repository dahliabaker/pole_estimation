% Run EKF with image rendering
clc, clear, close all;

% Run file for ekf_ploe.m
clc, clear, close all;

tic

rng(1);

X_0 = [100 0 0 0 0 0 1/sqrt(2) 1/sqrt(2) 0]';
P_0 = eye(9);
dtheta = 5;
time = 0:dtheta:6*dtheta; %(360-dtheta); % Currently the angle, not the time (Probably needs fixing)
n = 9;
dyn = 0; % Set desired dynamics model

load('bennu200kData.mat')
camParams.imageRes = [1024 1024];
camParams.fov = 0.8;

[hFig,obj_patch] = figureSetup(obj,'figName',camParams);
[hFig2,obj_patch2] = figureSetup(obj,'figName',camParams);
% rotate(obj_patch,[0 0 1],5,[0 0 0]);
% [faceCenters,faceNormals] = calculateFaceNormals(obj_patch.Faces,obj_patch.Vertices);
% shadows = getShadows(obj_patch.Faces,obj_patch.Vertices,faceNormals,[1 0 0]');
%     % reset obj_patch color to black (zeros)
% obj_patch.FaceVertexCData(shadows>0,:) = repmat(shadows(shadows>0),1,3);
% obs_img = getframe(hFig) % Cant seem to get this to display

    % getframe get both images ^^^
    % ekf measurement update step

for i = 1:length(time)


    [x_minus,P_minus] = ekf_time_update(X_0,P_0,dtheta,n,dyn);
    omega_minus(i,:) = x_minus(n-2:n);
    
    %Store pre-rotated obj for pred img rotation?

    % Generate Observed Img
    rotate(obj_patch,[0 0 1],dtheta,[0 0 0]);
    [faceCenters,faceNormals] = calculateFaceNormals(obj_patch.Faces,obj_patch.Vertices);
    shadows = getShadows(obj_patch.Faces,obj_patch.Vertices,faceNormals,[1 0 0]');

    obj_patch.FaceVertexCData(shadows>0,:) = repmat(shadows(shadows>0),1,3);
    obs_img_struct = getframe(hFig);
    obs_img = obs_img_struct.cdata;
    
    %Generate Predicted Image
    rotate(obj_patch2,omega_minus(i,:),dtheta,[0 0 0]);
    [faceCenters,faceNormals] = calculateFaceNormals(obj_patch2.Faces,obj_patch2.Vertices);
    shadows = getShadows(obj_patch2.Faces,obj_patch2.Vertices,faceNormals,[1 0 0]');

    obj_patch2.FaceVertexCData(shadows>0,:) = repmat(shadows(shadows>0),1,3);
    pred_img_struct = getframe(hFig2);
    pred_img = pred_img_struct.cdata;
    
    %Grayscale
    pred_img_gray = mat2gray(pred_img);
    obs_img_gray = mat2gray(obs_img);

    %EKF measurement update
    [x_plus(i,:),P_plus(:,:,i)] = ekf_measurement_update(x_minus,P_minus,obs_img_gray(:,:,1),pred_img_gray(:,:,1),n);

    %Reset predicted back to observed
    rotate(obj_patch2,omega_minus(i,:),-dtheta,[0 0 0]);
    rotate(obj_patch2,[1 0 0],dtheta,[0 0 0]);
end

toc



