% EKF Measurement Update

function [x_plus,P_plus] = ekf_measurement_update(x_minus,P_minus,obs,pred,n)

x_sc = x_minus(1:3)';
DCM = Camera2Inertial(x_sc);

[~,r_angle,~] = maskmatch(obs,pred);
omega = x_minus(n-2:n);
omega_hat_cam = [cosd(r_angle) , sind(r_angle) , 0]; %Check camera frame, 0 should be in z location
% tform*[0 0 1] try this
omega_hat = DCM*omega_hat_cam';

R = 1e0*eye(3);

r = omega_hat/norm(omega_hat);  %NP*omega_hat - omega; Use the commented one once the camera frame is done correctly
H = [zeros(3,3) zeros(3,3) eye(3)];
K = P_minus*(H')*inv(H*P_minus*(H') + R);

%Measurement update
x_plus = [x_minus(1:6); 0; 0; 0] + K*r/norm(K*r) % + x_minus;
P_plus = (eye(n,n) - K*H)*P_minus*(eye(n,n) - K*H)' + K*R*K'; %Bucy-Jordan Form (Use this)
%P_plus(:,:,i) = (eye(n,n) - K*H)*P_minus(:,:,i); %Compact form

end