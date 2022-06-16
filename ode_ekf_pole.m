% ODE45 for ekf pole filter (9 states)

% Dynamics Selection Key
% 0 = no dynamics (static/stationary) - Theoretical only
% 1 = two-body dynamics about Bennu (or other body if mu is changed)

function state_dot = ode_ekf_pole(t,state,dyn)

n = 9;

x = state(1);
y = state(2);
z = state(3);
xdot = state(4);
ydot = state(5);
zdot = state(6);
w1 = state(7);
w2 = state(8);
w3 = state(9);

mu = 6.67428e-11*7.329e10;

X = [x y z];
r = norm(X);

if dyn == 1
Xddot = (-mu/r^3)*X;

A = [                                                              0,                                                               0,                                                               0, 1, 0, 0, 0, 0, 0
                                                              0,                                                               0,                                                               0, 0, 1, 0, 0, 0, 0
                                                              0,                                                               0,                                                               0, 0, 0, 1, 0, 0, 0
(3*mu*x^2)/(x^2 + y^2 + z^2)^(5/2) - mu/(x^2 + y^2 + z^2)^(3/2),                              (3*mu*x*y)/(x^2 + y^2 + z^2)^(5/2),                              (3*mu*x*z)/(x^2 + y^2 + z^2)^(5/2), 0, 0, 0, 0, 0, 0
                             (3*mu*x*y)/(x^2 + y^2 + z^2)^(5/2), (3*mu*y^2)/(x^2 + y^2 + z^2)^(5/2) - mu/(x^2 + y^2 + z^2)^(3/2),                              (3*mu*y*z)/(x^2 + y^2 + z^2)^(5/2), 0, 0, 0, 0, 0, 0
                             (3*mu*x*z)/(x^2 + y^2 + z^2)^(5/2),                              (3*mu*y*z)/(x^2 + y^2 + z^2)^(5/2), (3*mu*z^2)/(x^2 + y^2 + z^2)^(5/2) - mu/(x^2 + y^2 + z^2)^(3/2), 0, 0, 0, 0, 0, 0
                                                              0,                                                               0,                                                               0, 0, 0, 0, 0, 0, 0
                                                              0,                                                               0,                                                               0, 0, 0, 0, 0, 0, 0
                                                              0,                                                               0,                                                               0, 0, 0, 0, 0, 0, 0];

elseif dyn == 0
    Xddot = [0 0 0];
    A = zeros(9,9);
end

phi_flat = state(n+1:n^2+n);
phi = reshape(phi_flat,n,n);
phi_dot = A*phi;
phi_dot_flat = reshape(phi_dot,1,n^2);

state_dot = [xdot ydot zdot Xddot 0 0 0 phi_dot_flat]';

end