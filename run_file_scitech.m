%% least squares estimation
%just estimating the pole from images
%no spacecraft
%load('Models/error_50.mat')
%%

% addpath '/Users/dahliabaker/Documents/GradSchool/Research/YORP'
% %pull a model based on length n
% 
% n=50;
% for i= 1:n
%     mkdir("sim_img_"+string(i))
%     r = plyread("Models/psyche_"+string(i)+".ply");
% 
%     tcon= boundary(r.vertex.x,r.vertex.y,r.vertex.z);
% 
%     %but I don't actually care if an image gets shown, I don't need it
%     for j = 1:72
%         figure(j);
%         set(gcf,'Units','pixels','Position',[0 0 1024 1024]);
%         model = trisurf(tcon,r.vertex.x,r.vertex.y,r.vertex.z,'facecolor',[0.5,0.5,0.5],'edgecolor',[0.5,0.5,0.5]);
%         view(-5*(j-1),0)
%         %view([50000,0,0])
%        
%         xlim([-34.9089 34.9089])
%         ylim([-34.9089 34.9089])
%         zlim([-34.9089 34.9089])
%         axis('equal')
% 
%         b = light;
%         set(gca,'Color','k');
%         set(gcf,'Units','pixels','Position',[0,0,1024,1024])
%         camroll(90)
%         %pbaspect([1 1 1])
%         %ax.CameraViewAngle = 0.8;
%         F = getframe;
%         RGB = frame2im(F);
% %         c = centerCropWindow2d(size(RGB),[1024 1024]);
% %         RGB = imcrop(RGB,c);
%         RGB = imresize(RGB,[1024,1024]);
%         imshow(RGB,'Border','tight');
%         disp(j)
%         saveas(gcf,"sim_img_"+string(i)+"/sim_"+string(j),'jpeg');%,'Resolution',72);
%         close all
%     end
% end

%%
%just first model for now
n=20;
for i = 1:n
    %pull wrong pole estimate
    alpha= 36+(rx(i)*pi);
    delta = -8+ (ry(i)*pi);
    r = [];
    for j = 1:72
        x_b(j,:) = [alpha,delta,5*(j-1),0.0238];%assume we are starting at the prime meridian
    
        %process with all images, save the alpha and delta guesses
        obs_img = 'psyche_automated_images/render'+string(j)+'.png';
        pred_img = 'sim_img_'+string(i)+'/sim_'+string(j)+'.jpg';
        [alpha_guess(j),delta_guess(j),r(j)] = meas_model_lod(x_b(j,:),obs_img,pred_img);
%         disp('current pole estimate: ')
%         disp(alpha_guess(j))
%         disp(' degrees longitude')
%         disp(delta_guess(j))
%         disp(' degrees latitude')
        %alpha = alpha_guess(j);
        %delta = delta_guess(j);
    end
    alpha_guess_hist(i,1:72) = alpha_guess;
    delta_guess_hist(i,1:72) = delta_guess;
    alpha_guess_final(i) = alpha;
    delta_guess_final(i) = delta;
    rot_guess(i,:) = r(:);
end

%%

%calculate stats
for i = 1:n
    alpha_guess_err(i,:) = alpha_guess_hist(i,:)-36;
    delta_guess_err(i,:) = delta_guess_hist(i,:)+8;
    alpha_average(i) = mean(alpha_guess_hist(i,:));
    delta_average(i) = mean(delta_guess_hist(i,:));
    std_err_a(i) = std(alpha_guess_hist(i,:));
    std_err_d(i) = std(delta_guess_hist(i,:));
    rot_guess_avg(i) = mean(rot_guess(i,:));
    std_err_rot(i) = std(rot_guess(i,:));
end

%%
figure(1)
grid on
subplot(2,1,1)
hold on
scatter(1:n,alpha_average-36,'filled','r')
errorbar(alpha_average-36,std_err_a)
grid on
title('Longitude Pole Estimate Error, \Delta \alpha','FontSize',12)
ylabel('Degrees Error')
ylim([-90 90])
hold off
subplot(2,1,2)
hold on
scatter(1:n,delta_average+8,'filled','b')
errorbar(delta_average+8,std_err_d)
grid on
title('Latitude Pole Estimate Error, \Delta\delta','FontSize',12)
ylabel('Degrees Error')
xlabel('Case Number')
ylim([-30 30])
hold off
%%
figure(2)
hold on
scatter(1:50,rot_guess_avg,50,'filled','k')
title('Average Correction for Rotation Angle in Camera Frame','FontSize',16)
ylabel('Theta (degrees)')
xlabel('Case Number')
grid on


%% 
figure(3)
subplot(2,1,1)
scatter(1:50,alpha_average,30,'filled','b')
ylabel('Inertial Longitude (degrees)')
xlabel('MC Case')
title('Longitude Estimate','FontSize',16)
grid on
subplot(2,1,2)
scatter(1:50, delta_average,30,'filled','b')
ylabel('Inertial Latitude (degrees)')
xlabel('MC Case')
title('Latitude Estimate','FontSize',16)
grid on
%now least squares to get a real answer

%%
figure(4)
subplot(2,1,1)
scatter(hd,(alpha_average-36),30,'filled','r')
ylabel('Longitude Error (degrees)')
xlabel('Hausdorff Distance (m)')
title('Longitude vs Shape Model Error','FontSize',16)
grid on
subplot(2,1,2)
scatter(hd,delta_average+8,30,'filled','b')
ylabel('Latitude Error (degrees)')
xlabel('Hausdorff Distance (m)')
title('Latitude vs Shape Model Error','FontSize',16)
grid on


