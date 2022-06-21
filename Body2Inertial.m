% Camera Frame To Inertial Frame (Given Inertial Position of Camera)

% Inputs:
% theta = angle of rotation from inertial frame (scalar)
% OR
% time = time since body and inertial frame are aligned (scalar)

% Outputs:
% NB = DCM from body to inertial (3x3)

function [NB] = Body2Inertial(theta)

b1 = [cos(theta), sin(theta), 0];
b2 = [-sin(theta), cos(theta), 0];
b3 = [0 , 0 , 1];

BN = [b1; b2; b3];

NB = BN';
end