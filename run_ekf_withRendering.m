% Run EKF with image rendering
clc, clear, close all;


tic

omega_0 = [1/sqrt(3) 1/sqrt(3) 1/sqrt(3)];

X_0 = [100 0 0 0 0 0 omega_0]';
P_0 = 1e9*eye(9);
dtheta = 10;
time = 0:dtheta:8*dtheta; %(360-dtheta); % Currently the angle, not the time (Probably needs fixing)
n = 9;
dyn = 0; % Set desired dynamics model

load('bennu200kData.mat')
camParams.imageRes = [900 900];
camParams.fov = 0.8;

[hFig,obj_patch] = figureSetup(obj,'figName',camParams);
[hFig2,obj_patch2] = figureSetup(obj,'figName2',camParams);

x_plus = X_0;
P_plus = P_0;

sigma_omega_x = nan(1,length(time))
sigma_omega_x(1) = sqrt(P_plus(n-2,n-2));
sigma_omega_y = nan(1,length(time))
sigma_omega_y(1) = sqrt(P_plus(n-1,n-1));
sigma_omega_z = nan(1,length(time))
sigma_omega_z(1) = sqrt(P_plus(n,n));

for i = 1:length(time)-1

    [x_minus,P_minus] = ekf_time_update(x_plus(:,i),P_plus(:,:,i),dtheta,n,dyn);
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
    
    %Grayscale: Change to rgb2gray
    pred_img_gray = mat2gray(pred_img);
    obs_img_gray = mat2gray(obs_img);

    %EKF measurement update
    [x_plus(:,i+1),P_plus(:,:,i+1)] = ekf_measurement_update(x_minus,P_minus,obs_img_gray(:,:,1),pred_img_gray(:,:,1),n);

    %Reset predicted back to observed
    rotate(obj_patch2,omega_minus(i,:),-dtheta,[0 0 0]);
    rotate(obj_patch2,[0 0 1],dtheta,[0 0 0]);
    omega_plus = x_plus(n-2:n);
%     rotate(obj_patch2,omega_plus,dtheta,[0 0 0]); (Maybe use omega_plus to backprop)

    sigma_omega_x(i+1) = sqrt(P_plus(n-2,n-2,i+1));
    sigma_omega_y(i+1) = sqrt(P_plus(n-1,n-1,i+1));
    sigma_omega_z(i+1) = sqrt(P_plus(n,n,i+1));

end


%% Results
figure()
plot(time,x_plus(n-2:n,:))
xlabel('\theta from inertial (from \theta_0)')
ylabel('pole estimates')
legend('\omega_x','\omega_y','\omega_z')
title('Pole Estimates')
% ylim([-.1,1.1])
errors = x_plus(n-2:n,:)-[zeros(2,length(time)) ; ones(1,length(time))];

figure()
sgtitle('Pole Estimate Errors')
subplot(3,1,1)
plot(time,errors(1,:))
hold on
plot(time,3*sigma_omega_x)
plot(time,-3*sigma_omega_x)
ylim([-3,3])
xlabel('\theta from inertial (from \theta_0)')
ylabel('\epsilon_x')
legend('\omega','+3*\sigma','-3\sigma')

subplot(3,1,2)
plot(time,errors(2,:))
hold on
plot(time,3*sigma_omega_y)
plot(time,-3*sigma_omega_y)
xlabel('\theta from inertial (from \theta_0)')
ylabel('\epsilon_y')
ylim([-3,3])

subplot(3,1,3)
plot(time,errors(3,:))
hold on
plot(time,3*sigma_omega_z)
plot(time,-3*sigma_omega_z)
xlabel('\theta from inertial (from \theta_0)')
ylabel('\epsilon_z')
ylim([-3,3])

for i = 1:length(time)
angle_error(i) = acosd(dot(x_plus(n-2:n,i),[0 0 1])/norm(x_plus(n-2:n,i)));
end

figure()
plot(time,errors)
xlabel('\theta from inertial (from \theta_0)')
ylabel('pole estimate errors')
legend('\omega_x','\omega_y','\omega_z')
title('Pole Estimate Errors')

figure()
plot(time,angle_error)
% ylim([-3e-2,3e-2])
xlabel('\theta from inertial (from \theta_0)')
ylabel('angle between correct pole and estimated pole [deg]')
legend('angular error')
title('Pole Estimate Errors (By Angle)')



toc




