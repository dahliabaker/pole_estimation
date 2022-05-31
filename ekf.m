%ekf filter - image based nav with centerfinding

%Dahlia Baker
%Extended Kalman Filter
%created - 11/27/21
%last edited - 11/27/21

%inputs -


function [x_plus, P_plus] = ekf(x_sc, P_0, measure,truth)
    n = length(x_sc);%gonna be 10
   
   
    %initialize at time zero (i = 1)
    i                = 2;
    x_plus(:,i-1)    = x_sc';
    P_plus(:,:,i-1)  = P_0;
    
    P_minus(:,:,i-1) = P_0;
    R(i-1)       = 1e-3; %explicitly defined measurement noise covariances
    opts = odeset('RelTol',1e-13,'AbsTol',1e-14);
    %Q = diag([u(1)^2, u(2)^2, u(3)^2]); %what is this? do I need to change
    %it? I think its about control input
    
    r = zeros(length(time));
    
    phi_save = zeros(n,n,length(time));
 
    while i <= length(time)
        %read the next observation
        R      = R(1);
        %do the integration for the time step
        %replace phi with right shape thing
        phi = eye(n,n);
        phi = reshape(phi, (n)^2, 1);
        int_state = [x_plus(:,i-1); phi];
        timevec = [time(i-1) time(i)];
        
        [~,state_wstm] = ode45(@int_sc, timevec, int_state, opts);
        num = length(state_wstm(:,1));
        %state(1,1:56) = state_wstm(num,1:56);
        x_minus(:,i) = state_wstm(num,1:n)';
        r_sc = x_minus(1:3,i);
        v_sc = x_minus(4:6,i);
        %cutting off seventh row
        thingtoreshape = state_wstm(num,n+1:end);
        phi = reshape(thingtoreshape,n,n);
        
        phi_save(:,:,i) = phi;
        %define gamma
        gamma(1:3,1:3) = (.5)*((time(i) - time(i-1))^2)*eye(3,3);
        gamma(4:6,1:3) = (time(i) - time(i-1))*eye(3,3);
        
        %time update
        
        P_minus(:,:,i) = (phi)*(P_plus(:,:,i-1))*(phi') + gamma*Q*(gamma');
        
        %compute observations
        %take them from file
%         actual_range = measure(i,3);
%         actual_rangerate = measure(i,4);
        [ri] = meas_model_lod([r_sc;v_sc]', measure(i), x_minus(7:n,i));
        
        r(:,i) = ri-truth(:,i);
        H    = Htilde_sc_rho_rhod_baker(x_minus(1:6,i), [r_obs; v_obs]);
        K    = P_minus(:,:,i)*(H')*pinv(H*P_minus(:,:,i)*(H') + R);
        %measurement update
        x_plus(:,i) = x_minus(:,i) + K*r(:,i);
        P_plus(:,:,i) = (eye(n,n) - K*H)*P_minus(:,:,i)*(eye(n,n) - K*H)' + K*R*K'; %Bucy-Jordan Form
        %P_plus(:,:,i) = (eye(n,n) - K*H)*P_minus(:,:,i); %Compact form
       
           
        i = i+1;
        if(mod(i,100) == 0)
            disp(i);
        end
    end
end