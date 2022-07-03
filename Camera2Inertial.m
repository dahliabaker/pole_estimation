% Camera Frame To Inertial Frame (Given Inertial Position of Camera)

% Inputs:
% r = psition of camera/spacecraft (row vector)

% Outputs:
% NC = DCM from camera to inertial (3x3)

function [NC] = Camera2Inertial(r)

Cz = r/norm(r);
Cx = cross(Cz,[0 0 1]);
Cy = cross(Cz,Cx);

NC = [Cx ; Cy ; Cz];

end