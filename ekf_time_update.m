% EKF time update one time step (Not full EKF)
%
% inputs:
% X_plus = previous best estimate of state
% P_plus = previous covariance
% dt     = change in time over timestep
% n      = number of states, length of state vector
function [X_minus,P_minus] = ekf_time_update(x_plus,P_plus,dt,n,dyn)

    phi = eye(n,n);
    phi = reshape(phi, n^2, 1);
    int_state = [x_plus; phi];
    timevec = [0 dt];

    opts = odeset('RelTol',1e-13,'AbsTol',1e-14);
    [~,state_wstm] = ode45(@ode_ekf_pole, timevec, int_state, opts, dyn);

%     num = length(state_wstm(:,1));
    %state(1,1:56) = state_wstm(num,1:56);
    X_minus = state_wstm(end,1:n)';
    phi_dot = state_wstm(end,n+1:n^2);
    phi_dot = reshape(phi,n,n);
    P_minus = phi_dot*P_plus*phi_dot'; %+ gamma*Q*gamma';

end