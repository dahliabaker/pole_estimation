% EKF Measurement Update (with image rendering)

function [x_plus,P_plus] = ekf_measurement_update(x_minus,P_minus,obs,pred,n)

pole_est = x_minus(n-2:n);
[~,r_angle,~] = maskmatch(obs,pred);
omega = x_minus(7:9,i);
omega_hat = [0 , sind(r_angle) , cosd(r_angle)]';

r(:,i) = omega_hat/norm(omega_hat) - omega/norm(omega);  %NP*omega_hat - omega; Use the commented one once the camera frame is done correctly
H = [zeros(3,3) zeros(3,3) eye(3)];
K    = P_minus(:,:,i)*(H')*pinv(H*P_minus(:,:,i)*(H') + R);

%Measurement update
x_plus(:,i) = x_minus(:,i) + K*r(:,i);
P_plus(:,:,i) = (eye(n,n) - K*H)*P_minus(:,:,i)*(eye(n,n) - K*H)' + K*R*K'; %Bucy-Jordan Form (Use this)
%P_plus(:,:,i) = (eye(n,n) - K*H)*P_minus(:,:,i); %Compact form

    %Below lines are only so function can run, results are not useful at this time
x_plus = x_minus;
P_plus = P_minus;

end