function [hFig,obj_patch] = figureSetup(obj,figName,camParams)
%% simulation parameters
% select colormap 
cmap = gray(1024);

% set baseline color
baselineColor = repmat(rand(length(obj.f.v),1),1,3);

%% camera parameters
scale = 1+.75*contains(pwd,'kound');

%% setup figure
% create empty figure
hFig = figure();
hFig.Name = figName;
hFig.InvertHardcopy = "off";

% set window size to desired resolution
hFig.Position = [50, 50, camParams.imageRes/scale];

% plot shape model
obj_patch = patch("Faces",obj.f.v,"Vertices",obj.v,"HandleVisibility","off");

% set the shape model color to the baseline
obj_patch.FaceVertexCData = baselineColor;
obj_patch.EdgeColor = "none";
obj_patch.FaceColor = "flat";

% hold current axes (optional)
hold(hFig.CurrentAxes,"on");

% set plot camera parameters
camva(camParams.fov)% camera field of view
hFig.CurrentAxes.CameraTarget = [0,0,0];% camera target (what it is looking at)
camproj("perspective")% camera perspective (this setting is the realistic one)
pos = [100,0,0];
hFig.CurrentAxes.CameraPosition = pos;% default camera position
[ obsLong, obsLat, ~] = cart2sph(pos(1),pos(2),pos(3));
if obsLong == 0 && obsLat > 0 
    hFig.CurrentAxes.CameraUpVector = [0 -1 0; 1 0 0; 0 0 1]*[0 1 0]';
else
    hFig.CurrentAxes.CameraUpVector = [0 0 1];
end
% set plot axes
axis tight equal
axis off% turn the axes labels off
set(gca,'LooseInset',get(gca,'TightInset'));% remove padding of the plot axes
colormap(cmap)
hFig.CurrentAxes.Color = "k";% set the axes background color to black
hFig.Color = "k";% set the figure background color to black


