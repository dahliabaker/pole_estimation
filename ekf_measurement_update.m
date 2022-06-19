% EKF Measurement Update (with image rendering)

function [x_plus,P_plus] = ekf_measurement_update(x_minus,P_minus,n)

pole_est = x_minus(n-2:n);

obj = load('bennu200kData.mat')

[hFig,obj_patch] = figureSetup(obj,'figName',camParams);
rotate(obj_patch,[0 0 1],5,[0 0 0]);
[faceCenters,faceNormals] = calculateFaceNormals(obj_patch.Faces,obj_patch.Vertices);
shadows = getShadows(obj_patch.Faces,obj_patch.Vertices,faceNormals,[1 0 0]);

    % reset obj_patch color to black (zeros)
obj_patch.FaceVertexCData(shadows>0,:) = repmat(shadows(shadows>0),1,3);
    % getframe get both images 
    % ekf measurement update step


end