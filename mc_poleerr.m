%SciTech MC Pole Error
%Dahlia Baker
%11/10/2021

%I claimed that I would run a monte carlo of pole error in precession and
%nutation in order to find correlated results on shape model error


%how many monte carlos? Let's try ten to start

%variable I want to change - spin pole RA and dec
clear all
close all
%clc
n = 50;
CB_new = [];
%using Psyche as a model
rx = rand(n,1)./10;
ry = rand(n,1)./10;
for i = 1:n
    err(:,:,i) = eul2rotm([rx(i)*pi,ry(i)*pi,0],'ZYX');
    CB_new{i} = zeros(3,3,72);
end


%%

load_script = 'psyche_noerr.mat';
img_path = ["psyche_automated_images"];%;"mv_bennu/bennu_automated_images_2"];
fov_angle = 0.8;
phase = 0; %phase of test case - can be an
ext = 200; %length of ray extension
limb = 1; %1 for include terminator, 0 for limb-only
IR = 0;%0 if no IR data, 1 if yes
density = 5; %number of degrees between silhouette sampled points
body = 'itoka';
if IR == 0
    IRdat = [];
    ir_list = [];
else
    load('10phase_sim_itokawa/IRedgedata.mat')
    IRdat = irSilhoutte;
    load('ir_list_i.mat')
    ir_list = ir_imgs;
end
    
%%
load(load_script);
addpath('../limbtracing_debug/scripts/');

%%
for i = 1:length(img_path)
    addpath(img_path(i));   
end


for i = 1:n
    
    
    for j = 1:72
        CB_new{i}(:,:,j) = CB(:,:,j)*err(:,:,i);
    end
    
    
    [limb_starts, limb_ends, edge_points_bc] = image_to_limbs_orex(img_name, r, fov_angle,CB_new{i},sun_pos,phase,limb,ext,IR,IRdat,density,body,ir_list);


%     figure(4)
%     hold on
%     xlabel('X axis')
%     ylabel('Y axis')
%     zlabel('Z axis')
%     color = ['r','b','c','m','y','k'];
%     color = [color, color, color, color, color, color, color, color, color, color, color, color];
% 
%     for j = 1:72
%         %uncomment below to also plot ray lines with the shape points
%     %      for i = 1:4:72
%     %          line([limb_starts{j}(i,1) limb_ends{j}(i,1)], [limb_starts{j}(i,2) limb_ends{j}(i,2)],[limb_starts{j}(i,3) limb_ends{j}(i,3)],'Color', [1,0,0,0.2],'LineWidth',1);
%     %      end
%     %         for i = 1:108
%     %             line([limb_starts{j}(i,1) limb_ends{j}(i,1)], [limb_starts{j}(i,2) limb_ends{j}(i,2)],[limb_starts{j}(i,3) limb_ends{j}(i,3)],'Color', color(j),'LineWidth',1);
%     %         end
%             scatter3(edge_points_bc{j}(:,1),edge_points_bc{j}(:,2),edge_points_bc{j}(:,3),'filled')
%             drawnow;
%             %disp(j)
% 
% 
% 
%     end
%     axis('equal')
     for k = 1:length(limb_starts)
        limb_starts{k} = limb_starts{k}./5;
        limb_ends{k} = limb_ends{k}./5;
     end
    
    [~,shapePnts{i}, shapePntNhats{i}] = shape_from_limbs_orex(limb_starts,limb_ends, r, 10,2,0,[0,0,-1]);

    ptCloud{i} = pointCloud(shapePnts{i},'Normal',shapePntNhats{i});
    figure()
    pcshow(ptCloud{i})
    xlabel('X Axis')
    ylabel('Y Axis')
    zlabel('Z Axis')
    p{i} = [ptCloud{i}.Location(:,1), ptCloud{i}.Location(:,2), ptCloud{i}.Location(:,3)];

    t = boundary(p{i}(:,1),p{i}(:,2),p{i}(:,3));
    %[t,tnorm]=MyRobustCrust(p{i});
    
    h = trisurf(t,p{i}(:,1),p{i}(:,2),p{i}(:,3),'facecolor','c','edgecolor','b');
    
    
     plywrite("Models/psyche_"+string(i)+".ply",h.Faces,h.Vertices);
     %plywrite("Models/psyche_noerr.ply",h.Faces,h.Vertices)
% 
%     
    measured = pcread("Models/psyche_"+string(i)+".ply");
    reference = pcread('Models/psyche_noerr.ply');
    [hd(i), D{i}] = HausdorffDist(reference.Location,measured.Location,0);
    for j = 1:length(D{i}(1,:))
        pt_err{i}(j) = min(D{i}(:,j));
    end
%     
end

save('Models/error_50.mat','err','rx','ry','CB','hd','D','pt_err','-v7.3');




%% now time to pull observations from this
addpath '/Users/dahliabaker/Documents/GradSchool/Research/YORP'
%pull a model based on length n
close all
clc

n=1;
for i= 1:n
    
    r = plyread("Models/psyche_"+string(i)+".ply");

    tcon= boundary(r.vertex.x,r.vertex.y,r.vertex.z);

    %but I don't actually care if an image gets shown, I don't need it
    for j = 1:72
        figure(j);
        set(gcf,'Units','pixels','Position',[0 0 1024 1024]);
        model = trisurf(tcon,r.vertex.x,r.vertex.y,r.vertex.z,'facecolor',[0.5,0.5,0.5],'edgecolor',[0.5,0.5,0.5]);
        view(-5*(j-1),0)
        %view([50000,0,0])
       
        xlim([-34.9089 34.9089])
        ylim([-34.9089 34.9089])
        zlim([-34.9089 34.9089])
        axis('equal')

        b = light;
        set(gca,'Color','k');
        set(gcf,'Units','pixels','Position',[0,0,1024,1024])
        camroll(90)
        %pbaspect([1 1 1])
        %ax.CameraViewAngle = 0.8;
        F = getframe;
        RGB = frame2im(F);
%         c = centerCropWindow2d(size(RGB),[1024 1024]);
%         RGB = imcrop(RGB,c);
        RGB = imresize(RGB,[1024,1024]);
        imshow(RGB,'Border','tight');
        disp(j)
        saveas(gcf,"sim_img/sim_"+string(j),'jpeg');%,'Resolution',72);
    end
end


%% running the least squares filter
%psyche reasonable position
%position on 11.28.21 in sun centered inertial frame
x_p = [3.921521826e8, 2.573972524485084e8,-1.449759943561614e6, -1.042304214089917e1, -1.245914214693120e1,8.650504106107100e-1];
x_sc = x_p+[500,0,0,0,0];%we put ourselves on the vector between psyche and the sun

%but permute the estimate based on our incorrect shape model!

%the error is saved
%rx is long error - process this first
alpha= 36+(rx(i)*pi);
delta = -8 + (ry(i)*pi);

x_b = [alpha,delta,0,0.0238];%assume we are starting at the prime meridian


x_state = [x_sc,x_b];% n = 10
P_0 = 1e-6*eye(10,10);
measure = [];
u = [];

i = 1;
t0 = 0;
x0 = x_state;

time = 0:210:(210*71);
%the measurements are image file names, will be processed in the filter
for j = 1:72
    img(j) = "sim_img/sim_"+string(j)+".png";
    truth(j) = "psyche_automated_images/render"+string(j)+".png";
end
%measurements are what?
%the correct orientation images

%the predicted images are the wrong ones

%precalculate the ri for the truth images, pass that in





