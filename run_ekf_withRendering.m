% Run EKF with image rendering
clc, clear, close all;

load('bennu200kData.mat')
camParams.imageRes = [1024 1024];
camParams.fov = 0.8;

[hFig,obj_patch] = figureSetup(obj,'figName',camParams);
rotate(obj_patch,[0 0 1],5,[0 0 0]);
[faceCenters,faceNormals] = calculateFaceNormals(obj_patch.Faces,obj_patch.Vertices);
shadows = getShadows(obj_patch.Faces,obj_patch.Vertices,faceNormals,[1 0 0]');
    % reset obj_patch color to black (zeros)
obj_patch.FaceVertexCData(shadows>0,:) = repmat(shadows(shadows>0),1,3);
    % getframe(hFig)
    % getframe get both images ^^^
    % ekf measurement update step


