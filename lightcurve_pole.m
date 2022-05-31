%   Dahlia Baker
%   Lightcurve Pole Extraction
%   Following procedures from 
%       "Silhouette Based 3D Shape Reconstruction of a Small Body from a
%       Spacecraft"
%   Created - 5/24/2021
%   Last Edited - 5/24/2021, DB
%
%   Using DAMIT software and Psyche Lightcurve Data

clear all
close all
clc
%% Pull Lightcurve data from file
load('A109.mat');
load('out_lcs_A109');

%%
j = 1;
for i = 1:length(a109(:,1))
    if a109(i,1) > 210
        JD(j) = a109(i,1)-a109(3,1);
        lcb(j) = a109(i,2);
        j = j+1;
    end
end

%% plot calculated brightness alongside actual lightcurve

figure()
hold on
grid on
obs = scatter(JD(1:102),lcb(1:102));
calc = scatter(JD(1:102),out_lcs_A109(1:102)');
xlabel('Time since JD epoch (day)','FontSize',14)
ylabel('Relative Intensity, \chi^2','FontSize',14)
title('Psyche Lightcurve Modeled vs Observed','FontSize',16)
legend([obs,calc],{'Observed','Modeled'});


%% pole estimation

% ecliptic polar angle - small beta tilde
% longitude - small lambda
% angular rotation speed - small omega


