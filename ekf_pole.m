%ekf filter - image based spin pole estimation

%Samuel Matez
%Extended Kalman Filter
%created - 05/30/22
%last edited - 05/31/22

% inputs  
%       - X_0 = initial state
%       - P_0 = initial covariance
%       - t_0 = initial time (usually zero)
%       - dt  = timestep
%       - pred_img = predicted image
%       - obs_img = actual optical image 

% outputs 
%       - X_plus = state estimate at all times (all images processed and indexed accordingly)
%       - P_plus = 3D matrix of covariance matrices 'at all times' (3rd index is timestep index)

function [x_plus,P_plus] = ekf_pole(X_0,P_0,time,pred_img,obs_img,dyn)

n = length(X_0);%gonna be 9 for now (r,v,omegax,y,z)
m = 3;   
%initialize at time zero (i = 1)
i                = 2;
x_plus(:,i-1)    = X_0';
P_plus(:,:,i-1)  = P_0;

P_minus(:,:,i-1) = P_0;
R(i-1)       = 1e-3; %explicitly defined measurement noise covariances (NEED 
% TO FIX THIS FOR NEW PROBLEM AND FOR PROPER SIZED MATRIX)
opts = odeset('RelTol',1e-13,'AbsTol',1e-14);
%Q = diag([u(1)^2, u(2)^2, u(3)^2]); %measurement noise (not included in initial ekf draft)

r = zeros(m,length(time));
    
phi_save = zeros(n,n,length(time));

while i <= length(time)
    %read the next observation
    R      = R(1);
    
    %Prep for time update (flatten phi and concatenate with state vector, associated time vector)
    phi = eye(n,n);
    phi = reshape(phi, (n)^2, 1);
    int_state = [x_plus(:,i-1); phi];
    timevec = [time(i-1) time(i)];


    [~,state_wstm] = ode45(@ode_ekf_pole, timevec, int_state, opts, dyn);

%     num = length(state_wstm(:,1));
    %state(1,1:56) = state_wstm(num,1:56);
    x_minus(:,i) = state_wstm(end,1:n)';
    r_sc = x_minus(1:3,i);
    v_sc = x_minus(4:6,i);
    %cutting off seventh row
    thingtoreshape = state_wstm(end,n+1:end);
    phi = reshape(thingtoreshape,n,n);

    phi_save(:,:,i) = phi;
    %define gamma
%     gamma(1:3,1:3) = (.5)*((time(i) - time(i-1))^2)*eye(3,3);
%     gamma(4:6,1:3) = (time(i) - time(i-1))*eye(3,3);
    
    %time update to covariance
    
    P_minus(:,:,i) = (phi)*(P_plus(:,:,i-1))*(phi'); %+ gamma*Q*(gamma');

    %Prep measurements (i-1 so we assume first image is at 5 deg or t1 rather than t0)
    pred = pred_img(:,:,i-1); %Later generate using render file
    obs = obs_img(:,:,i-1);
    [~,r_angle,~] = maskmatch(obs,pred);
    omega = x_minus(7:9,i);
    omega_hat = [0 , sind(r_angle) , cosd(r_angle)]';
    %line below needs to be figured out based on position and used to rotate omega_hat estimate in
    %the line beneath it which has the DCm (which also needs to be fixed)
%     theta = atan(x_minus(2)/x_minus(1)); % ONLY IF EQUAORIAL
%   NP = [cos(theta) -sin(theta) 0; sin(theta) cos(theta) 0; 0 0 1]; %assume position is only in x direction for this
    r(:,i) = omega_hat/norm(omega_hat) - omega/norm(omega);  %NP*omega_hat - omega; Use the commented one once the camera frame is done correctly
    H = [zeros(3,3) zeros(3,3) eye(3)];
    K    = P_minus(:,:,i)*(H')*pinv(H*P_minus(:,:,i)*(H') + R);

    %Measurement update
    x_plus(:,i) = x_minus(:,i) + K*r(:,i);
    P_plus(:,:,i) = (eye(n,n) - K*H)*P_minus(:,:,i)*(eye(n,n) - K*H)' + K*R*K'; %Bucy-Jordan Form (Use this)
    %P_plus(:,:,i) = (eye(n,n) - K*H)*P_minus(:,:,i); %Compact form
       
           
    i = i+1;
end

end




