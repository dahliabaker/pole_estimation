function [hFig] = figureSetup(obj)
%% simulation parameters
% select colormap 
cmap = gray(1024);

% set baseline color
baselineColor = repmat(rand(length(obj.f.v),1),1,3);

%% camera parameters
camerafov = 0.8;% degrees
imageRes = [1024,1024];

scale = 1+.75*contains(pwd,'kound');

%% setup figure
% create empty figure
hFig = figure();
hFig.Name = "Optical Image (truth)";
hFig.InvertHardcopy = "off";

% set window size to desired resolution
hFig.Position = [50, 50, imageRes/scale];

% plot shape model
obj_patch = patch("Faces",obj.f.v,"Vertices",obj.v,"HandleVisibility","off");

% set the shape model color to the baseline
obj_patch.FaceVertexCData = baselineColor;
obj_patch.EdgeColor = "none";
obj_patch.FaceColor = "flat";

% hold current axes (optional)
hold(hFig.CurrentAxes,"on");

% set plot camera parameters
camva(camerafov)% camera field of view
camtarget([0,0,0])% camera target (what it is looking at)
camproj("perspective")% camera perspective (this setting is the realistic one)
campos([100,0,0])% default camera position

% set plot axes
axis tight equal
axis off% turn the axes labels off
set(gca,'LooseInset',get(gca,'TightInset'));% remove padding of the plot axes
colormap(cmap)
hFig.CurrentAxes.Color = "k";% set the axes background color to black
hFig.Color = "k";% set the figure background color to black


