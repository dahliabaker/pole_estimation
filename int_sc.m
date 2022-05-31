%integration function for s/c approaching body


function stated = int_sc(t,state_wPhi)

%to include SRP, increase n to 7, change xd, add row and column to A
n = 10;
%x y z xdot ydot zdot a d w wdot
state = state_wPhi(1:n);

phi_flat = state_wPhi(n+1:(n^2+n));
phi = reshape(phi_flat,n,n);


xdot = state(4);
ydot = state(5);
zdot = state(6);
wdot = state(10);
%not considering any accelerations yet so phi doesn't change

xd = [xdot; ydot; zdot; 0; 0; 0; 0; 0; wdot; 0; zeros(3,1); zeros(3,1); zeros(3,1)];

A = eye(10,10);
    
phidot = A*phi;
phidot_flat = reshape(phidot,n^2,1);
stated = [xd; phidot_flat];
end