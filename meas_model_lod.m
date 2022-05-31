%measurement model

%Dahlia Baker
%SciTech 
%Fall 2021
%created on - DB,11/22/21
%last edited - DB, 11/29/21

%CenterFinding OpNav - Measurement Model
%Psyche Pole Error Robustness Testing


%input - sc_state: the state of the spacecraft - [x,y,z,xdot,ydot,zdot, SRP]' in what frame tho.
%         
%      - obs_img: simulated via Blender
%      - pred_img: predicted image, simulated via error model in blender at
%      the same time as "observation"
%      - body_state: current assumed pole lat, long, spin place, spin rate
%output - r_i: inertial position vector from spacecraft to body

function [alpha,delta,r] = meas_model_lod(state,obs_img,pred_img)

%centerfinding on observation

[~,r,~] = maskmatch(obs_img,pred_img);


%camera to body frame
w = state(3);
%90 about x
% rot1= [1 0 0; 0 cosd(90) -sind(90); 0 sind(90) cosd(90)];
% %-90 about z
% rot2 = [cosd(-90) -sind(-90) 0; sind(-90) cosd(-90) 0; 0 0 1];
rot1 = [ 0 0 -1; 0 1 0; 1 0 0]';
%opposite rotation now except positive
rot3 = [cosd(w) -sind(w) 0; sind(w) cosd(w) 0; 0 0 1];
% if abs(r)>70
%     r = 0;
% end
%image rotation correction
corr = [cosd(r) -sind(r) 0; sind(r) cosd(r) 0; 0 0 1];

BC = rot3*rot1*corr;

%inertial to body frame
a = state(1);
d = state(2);
% %90 about y
rot1 = [cosd(90) 0 sind(90); 0 1 0; -sind(90) 0 cosd(90)];
%rot1 = eye(3,3);
%-36 about x
rot2 = [1 0 0; 0 cosd(a) -sind(a); 0 sind(a) cosd(a)];
%8 about y
rot3 = [cosd(-d) 0 sind(-d); 0 1 0; -sind(-d) 0 cosd(-d)];

BI = rot3*rot2*rot1;
IB = inv(BI);
CB = inv(BC);

zc = [-1; 0; 0];
zb = BC*zc;
zi = IB*zb;
mi = [1 0];

alpha = acosd(-dot(zi(1:2),mi)/(norm(zi(1:2))*norm(mi))); %longitude
% if zi(2) <0
%     alpha = -alpha;
% end
el = [zi(1) zi(3)];
eq = [1 0];
%delta = acosd(dot(el,eq)/(norm(el)*norm(eq)));

delta = asind(zi(3));


%now we use frame transformation from our sc state and body state to get an
%inertial vector from spacecraft to body


end


function [cx_i,cy_i] = centerfind(obs_img)

    %make sure the images are passed in already grayscale
    obs_img(obs_img<uint8(10)) = uint8(0);
    obs_img = obs_img*1000;
    
    %now it's masked
    %time to find center of brightness
    top = 0;
    bottom = 0;
    len = 1:length(obs_img(1,:));
    for k = 1:length(obs_img(1,:))
        top = top+sum(double(obs_img(k,:)).*len);
        bottom = bottom+sum(double(obs_img(k,:)));
    end
    scob = cast((top/bottom),'uint64');

    top = 0;
    bottom = 0;
    len = 1:length(obs_img(:,1));
    for k = 1:length(obs_img(:,1))
        top = top+sum(double(obs_img(:,k)).*len');
        bottom = bottom+sum(double(obs_img(:,k)));
    end

    lcob = cast((top/bottom),'uint64');

    
    cx_i = scob;
    cy_i = lcob;
end



