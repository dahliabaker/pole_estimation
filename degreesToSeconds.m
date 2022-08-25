% Rotation to Time Converter 
%
% Input:
% theta = angle of rotation (degrees)
%
% Output:
% time = time of rotation (seconds)

function [time] = degreesToSeconds(theta)

deg_per_hr = 360/4.296057;
deg_per_sec = deg_per_hr/3600;
time = theta/deg_per_sec;

end