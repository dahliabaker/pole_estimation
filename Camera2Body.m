% Camera Frame To Body Frame

% Inputs:
% r = psition of camera/spacecraft (row vector)

% Outputs:
% NC = DCM from camera to inertial (3x3)

function [CB] = Camera2Body(r,theta)

[NC] = Camera2Inertial(r)

[NB] = Body2Inertial(theta)

CB = NC'*NB;
BC = CB';

end