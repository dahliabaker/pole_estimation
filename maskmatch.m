




function [translate,rotate,scale] = maskmatch(obs_img,pred_img)
obs_img = imread(obs_img);
obs_img = rgb2gray(obs_img);
obs_img(obs_img<uint8(10)) = uint8(0);
obs_img = obs_img*1000;
    

pred_img = imread(pred_img);
pred_img = rgb2gray(pred_img);
pred_img(pred_img<uint8(10)) = uint8(0);
pred_img = pred_img*1000;
    
%translation is going to be a matching of COB using centerfind
[cx1,cy1] = centerfind(obs_img);
[cx2,cy2] = centerfind(pred_img);

[ast_edge] = edge(obs_img);
[pred_edge] = edge(pred_img);
ptsOriginal  = detectSURFFeatures(ast_edge);
ptsDistorted = detectSURFFeatures(pred_edge);
%need this to find the fit between them
%computer vision toolbox obvs
%https://www.mathworks.com/help/vision/ug/find-image-rotation-and-scale-using-automated-feature-matching.html

% o_idx = find(ptsOriginal);
% p_idx = find(ptsDistorted);
% 
% [o_v,o_u]  = ind2sub( size(obs_img), o_idx ); 
% [p_v,p_u]  = ind2sub( size(pred_img), p_idx ); 
% % 
% figure(1)
% 
% imshowpair(obs_img,pred_img,'Montage')
% hold on
% scatter(o_u,o_v,'b')
% imshow(pred_img)
% scatter(p_u,p_v,'r')


[featuresOriginal,  validPtsOriginal]  = extractFeatures(obs_img,  ptsOriginal);
[featuresDistorted, validPtsDistorted] = extractFeatures(pred_img, ptsDistorted);

indexPairs = matchFeatures(featuresOriginal, featuresDistorted);

matchedOriginal  = validPtsOriginal(indexPairs(:,1));
matchedDistorted = validPtsDistorted(indexPairs(:,2));

figure;
showMatchedFeatures(obs_img,pred_img,matchedOriginal,matchedDistorted);
title('Putatively matched points (including outliers)');

[tform, inlierIdx] = estimateGeometricTransform2D(matchedDistorted, matchedOriginal, 'similarity');
inlierDistorted = matchedDistorted(inlierIdx, :);
inlierOriginal  = matchedOriginal(inlierIdx, :);

Tinv  = tform.invert.T;

ss = Tinv(2,1);
sc = Tinv(1,1);
scaleRecovered = sqrt(ss*ss + sc*sc);
thetaRecovered = atan2(ss,sc)*180/pi;

% outputView = imref2d(size(obs_img));
% recovered  = imwarp(pred_img,tform,'OutputView',outputView);

% figure, imshowpair(obs_img,recovered,'montage')
% title('Rotation Correction = '+string(thetaRecovered)+' degrees')

cxd = cx2-cx1;
cyd = cy2-cy1;


translate = [cxd,cyd];%x and y amts
rotate = thetaRecovered;%angle about center
scale = scaleRecovered; %any value [0,inf)

end