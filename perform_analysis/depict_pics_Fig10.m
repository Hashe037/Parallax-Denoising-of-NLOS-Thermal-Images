%Depicts pictures to compare methods as shown in Fig. 10 of the paper
%
%Saves images in working folder
%
%run "loadin_data.m" first
%--------------------------------------------------------------------------
%
%% parameters 
%picture indices to analyze
frame1 = 35;
frame2 = 50;
frame3 = 65;

same_scale = 0; %rescale all the images

%whether to change the lower limit of PRP-D c-axis
change_caxis = 0; %whether to change the caxis of prpd
prpd_caxis_lower = -.2; %lower value of colormap for PRP-D to help deal with outliers

%outlier removal
remove_outliers = 1; %whether to remove outliers for PRP-D
remove_outliers_other = 1; %wether to remove outliers for rest of variables too

save_images = 1; %whether to save images in folder

pausetime = .5; %how much to pause in between figures

percentiles_den = [1,99.5]; %percentiles to use for outliers in denoised 
percentiles_other = [1,99.5]; %percentiles for other

%% if rescale all images to have the same top/bottom limits
if same_scale
    %rescale the raw images over all the frames
    frames_r = {};
    minv_raw = 100000;
    maxv_raw = 0;
    for frame= frame1:frame3
        minv_raw = min(minv_raw,double(min(min(min(pics_raw(frame,:,:))))));
        maxv_raw = max(maxv_raw,double(max(max(max(pics_raw(frame,:,:))))));
    end

    %rescale raw TV
    minv_rawtv = double(min(min(min(pics_tv(frame1:frame3,:,:)))));
    maxv_rawtv = double(max(max(max(pics_tv(frame1:frame3,:,:)))));
%     frames_lfield_tv_r = (double(pics_tv)-min_val)./(max_val-min_val)*255 ;
    
    %rescale frs TV
    minv_mlrstv = double(min(min(min(pics_mlrs_tv(frame1:frame3,:,:)))));
    maxv_mlrstv = double(max(max(max(pics_mlrs_tv(frame1:frame3,:,:)))));

    %rescale se frames
    emi_frames_r = [];
    minv_emi = 100000;
    maxv_emi = 0;
    for frame= frame1:frame3
        frame_emi = squeeze(pics_se(frame,:,:));
        minv_emi = min(minv_emi,double(min(min(frame_emi))));
        maxv_emi = max(maxv_emi,double(max(max(frame_emi))));
    end
    
    %rescale emi/frs frames
    mlrs_frames_r = [];
    minv_mlrs = 100000;
    maxv_mlrs = 0;
    for frame= frame1:frame3
        frame_mlrs = squeeze(pics_mlrs(frame,:,:));
        minv_mlrs = min(minv_mlrs,double(min(min(frame_emi))));
        maxv_mlrs = max(maxv_mlrs,double(max(max(frame_emi))));
    end

    %rescale PRP-D version
    minv_prpd = 100000;
    maxv_prpd = 0;
    denoised_pics_r = [];
    for frame= frame1:frame3 
        frame_den = squeeze(pics_den(frame,:,:));
        frame_den = remove_denoised_outliers_percentile(frame_den);
        minv_prpd = min(minv_prpd,double(min(min(frame_den))));
        maxv_prpd = max(maxv_prpd,double(max(max(frame_den))));
    end
%     
    %rescale the ref frames
    ref_frames_r = [];
    minv_ref = 100000;
    maxv_ref = 0;
    for frame= frame1:frame3
        minv_ref = min(minv_ref,double(min(min(min(pics_ground(frame,:,:))))));
        maxv_ref = max(maxv_ref,double(max(max(max(pics_ground(frame,:,:))))));
    end
end

%% load their components
% if ~same_scale
if remove_outliers_other
    frame1_raw = remove_denoised_outliers_percentile(squeeze(pics_raw(frame1,:,:)),percentiles_other);
    frame2_raw = remove_denoised_outliers_percentile(squeeze(pics_raw(frame2,:,:)),percentiles_other);
    frame3_raw = remove_denoised_outliers_percentile(squeeze(pics_raw(frame3,:,:)),percentiles_other);
%     frame1_frs = remove_denoised_outliers_percentile(reshape(database(frame1,:,:),im_h,im_w),percentiles_other);
%     frame2_frs = remove_denoised_outliers_percentile(reshape(database(frame2,:,:),im_h,im_w),percentiles_other);
%     frame3_frs = remove_denoised_outliers_percentile(reshape(database(frame3,:,:),im_h,im_w),percentiles_other);
    frame1_emi = remove_denoised_outliers_percentile(squeeze(pics_se(frame1,:,:)),percentiles_other);
    frame2_emi = remove_denoised_outliers_percentile(squeeze(pics_se(frame2,:,:)),percentiles_other);
    frame3_emi = remove_denoised_outliers_percentile(squeeze(pics_se(frame3,:,:)),percentiles_other);
    frame1_mlrs = remove_denoised_outliers_percentile(squeeze(pics_mlrs(frame1,:,:)),percentiles_other);
    frame2_mlrs = remove_denoised_outliers_percentile(squeeze(pics_mlrs(frame2,:,:)),percentiles_other);
    frame3_mlrs = remove_denoised_outliers_percentile(squeeze(pics_mlrs(frame3,:,:)),percentiles_other);
    frame1_raw_tv = remove_denoised_outliers_percentile(squeeze(pics_tv(frame1,:,:)),percentiles_other);
    frame2_raw_tv = remove_denoised_outliers_percentile(squeeze(pics_tv(frame2,:,:)),percentiles_other);
    frame3_raw_tv = remove_denoised_outliers_percentile(squeeze(pics_tv(frame3,:,:)),percentiles_other);
else
    frame1_raw = frames{frame1};
    frame2_raw = frames{frame2};
    frame3_raw = frames{frame3};
%     frame1_frs = reshape(database(frame1,:,:),im_h,im_w);
%     frame2_frs = reshape(database(frame2,:,:),im_h,im_w);
%     frame3_frs = reshape(database(frame3,:,:),im_h,im_w);
    frame1_emi = squeeze(pics_se(frame1,:,:));
    frame2_emi = squeeze(pics_se(frame2,:,:));
    frame3_emi = squeeze(pics_se(frame3,:,:));
    frame1_mlrs = squeeze(pics_mlrs(frame1,:,:));
    frame2_mlrs = squeeze(pics_mlrs(frame2,:,:));
    frame3_mlrs = squeeze(pics_mlrs(frame3,:,:));
    frame1_raw_tv = squeeze(pics_tv(frame1,:,:));
    frame2_raw_tv = squeeze(pics_tv(frame2,:,:));
    frame3_raw_tv = squeeze(pics_tv(frame3,:,:));
end
if remove_outliers
    frame1_den = remove_denoised_outliers_percentile(squeeze(pics_den(frame1,:,:)),percentiles_den);
    frame2_den = remove_denoised_outliers_percentile(squeeze(pics_den(frame2,:,:)),percentiles_den);
    frame3_den = remove_denoised_outliers_percentile(squeeze(pics_den(frame3,:,:)),percentiles_den);
    frame1_mlrs_tv = remove_denoised_outliers_percentile(squeeze(pics_mlrs_tv(frame1,:,:)),percentiles_den);
    frame2_mlrs_tv = remove_denoised_outliers_percentile(squeeze(pics_mlrs_tv(frame2,:,:)),percentiles_den);
    frame3_mlrs_tv = remove_denoised_outliers_percentile(squeeze(pics_mlrs_tv(frame3,:,:)),percentiles_den);
else
    frame1_den = squeeze(pics_den(frame1,:,:));
    frame2_den = squeeze(pics_den(frame2,:,:));
    frame3_den = squeeze(pics_den(frame3,:,:));
    frame1_mlrs_tv = squeeze(pics_mlrs_tv(frame1,:,:));
    frame2_mlrs_tv = squeeze(pics_mlrs_tv(frame2,:,:));
    frame3_mlrs_tv = squeeze(pics_mlrs_tv(frame3,:,:));
end

frame1_ref = reshape(pics_ground(frame1+cubeParams.ground_offset,:,:),im_h,im_w);
frame2_ref = reshape(pics_ground(frame2+cubeParams.ground_offset,:,:),im_h,im_w);
frame3_ref = reshape(pics_ground(frame3+cubeParams.ground_offset,:,:),im_h,im_w);


%% show and save images
color_font = 12;
title_font = 12;

%define figure
figure,set( gcf, 'Unit', 'Normalized','Position', [0.1,0.1,0.4,0.5] ) ;
set(gca,'LooseInset',get(gca,'TightInset'));
ax = gca;

%%%raw images
if same_scale
    imagesc(frame1_raw,[minv_raw maxv_raw])
else
    imagesc(frame1_raw)
end
title('Raw Frame 1','FontSize',title_font),axis image,colormap hot
set(gca,'xtick',[]),set(gca,'ytick',[]),ax.Visible = 'off';
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'raw_frame1.png')
end
pause(pausetime)
if same_scale
    imagesc(frame2_raw,[minv_raw maxv_raw])
else
    imagesc(frame2_raw)
end
title('Raw Frame 2','FontSize',title_font),axis image,colormap hot
set(gca,'xtick',[]),set(gca,'ytick',[]),ax.Visible = 'off';
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'raw_frame2.png')
end
pause(pausetime)
if same_scale
    imagesc(frame3_raw,[minv_raw maxv_raw])
else
    imagesc(frame3_raw)
end
title('Raw Frame 3','FontSize',title_font),axis image,colormap hot
set(gca,'xtick',[]),set(gca,'ytick',[]),ax.Visible = 'off';
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'raw_frame3.png')
end
pause(pausetime)

%%%TV denoising on raw images
if same_scale
    imagesc(frame1_raw_tv,[minv_rawtv maxv_rawtv])
else
    imagesc(frame1_raw_tv)
end
title('TV-D on Raw Frame 1','FontSize',title_font),axis image,colormap hot
set(gca,'xtick',[]),set(gca,'ytick',[]),ax.Visible = 'off';
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'tv_frame1.png')
end
pause(pausetime)
if same_scale
    imagesc(frame2_raw_tv,[minv_rawtv maxv_rawtv])
else
    imagesc(frame2_raw_tv)
end
title('TV-D on Raw Frame 2','FontSize',title_font),axis image,colormap hot
set(gca,'xtick',[]),set(gca,'ytick',[]),ax.Visible = 'off';
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'tv_frame2.png')
end
pause(pausetime)
if same_scale
    imagesc(frame3_raw_tv,[minv_rawtv maxv_rawtv])
else
    imagesc(frame3_raw_tv)
end
title('TV-D on Raw Frame 3','FontSize',title_font),axis image,colormap hot
set(gca,'xtick',[]),set(gca,'ytick',[]),ax.Visible = 'off';
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'tv_frame3.png')
end
pause(pausetime)

% %%%FRS images
% if same_scale
%     imagesc(frame1_frs,[minv_frs maxv_frs])
% else
%     imagesc(frame1_frs)
% end
% title('FRS Frame 1','FontSize',title_font),axis image,colormap hot
% set(gca,'xtick',[]),set(gca,'ytick',[]),ax.Visible = 'off';
% c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
% c.Ticks = [c.Limits(1),c.Limits(2)];
% if save_images
%     saveas(gcf,'frs_frame1.png')
% end
% pause(pausetime)
% if same_scale
%     imagesc(frame2_frs,[minv_frs maxv_frs])
% else
%     imagesc(frame2_frs)
% end
% title('FRS Frame 2','FontSize',title_font),axis image,colormap hot
% set(gca,'xtick',[]),set(gca,'ytick',[]),ax.Visible = 'off';
% c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
% c.Ticks = [c.Limits(1),c.Limits(2)];
% if save_images
%     saveas(gcf,'frs_frame2.png')
% end
% pause(pausetime)
% if same_scale
%     imagesc(frame3_frs,[minv_frs maxv_frs])
% else
%     imagesc(frame3_frs)
% end
% title('FRS Frame 3','FontSize',title_font),axis image,colormap hot
% set(gca,'xtick',[]),set(gca,'ytick',[]),ax.Visible = 'off';
% c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
% c.Ticks = [c.Limits(1),c.Limits(2)];
% if save_images
%     saveas(gcf,'frs_frame3.png')
% end
% pause(pausetime)

%%%no emi images
if same_scale
    imagesc(frame1_emi,[minv_emi maxv_emi])
else
    imagesc(frame1_emi)
end
title('SE Frame 1','FontSize',title_font),axis image,colormap hot
set(gca,'xtick',[]),set(gca,'ytick',[]),ax.Visible = 'off';
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'se_frame1.png')
end
pause(pausetime)
if same_scale
    imagesc(frame2_emi,[minv_emi maxv_emi])
else
    imagesc(frame2_emi)
end
title('SE Frame 2','FontSize',title_font),axis image,colormap hot
set(gca,'xtick',[]),set(gca,'ytick',[]),ax.Visible = 'off';
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'se_frame2.png')
end
pause(pausetime)
if same_scale
    imagesc(frame3_emi,[minv_emi maxv_emi])
else
    imagesc(frame3_emi)
end
title('SE Frame 3','FontSize',title_font),axis image,colormap hot
set(gca,'xtick',[]),set(gca,'ytick',[]),ax.Visible = 'off';
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'se_frame3.png')
end
pause(pausetime)

%%%no emi with FRS images
if same_scale
    imagesc(frame1_mlrs,[minv_mlrs maxv_mlrs])
else
    imagesc(frame1_mlrs)
end
title('MLRS Frame 1','FontSize',title_font),axis image,colormap hot
set(gca,'xtick',[]),set(gca,'ytick',[]),ax.Visible = 'off';
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'mlrs_frame1.png')
end
pause(pausetime)
if same_scale
    imagesc(frame2_mlrs,[minv_mlrs maxv_mlrs])
else
    imagesc(frame2_mlrs)
end
title('MLRS Frame 2','FontSize',title_font),axis image,colormap hot
set(gca,'xtick',[]),set(gca,'ytick',[]),ax.Visible = 'off';
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'mlrs_frame2.png')
end
pause(pausetime)
if same_scale
    imagesc(frame3_mlrs,[minv_mlrs maxv_mlrs])
else
    imagesc(frame3_mlrs)
end
title('MLRS Frame 3','FontSize',title_font),axis image,colormap hot
set(gca,'xtick',[]),set(gca,'ytick',[]),ax.Visible = 'off';
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'mlrs_frame3.png')
end
pause(pausetime)

%%%TV denoising with FRS first
if same_scale
    imagesc(frame1_mlrs_tv,[minv_mlrstv maxv_mlrstv])
else
    imagesc(frame1_mlrs_tv)
end
title('TV-D on MLRS Frame 1','FontSize',title_font),axis image,colormap hot
set(gca,'xtick',[]),set(gca,'ytick',[]),ax.Visible = 'off';
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'tvmlrs_frame1.png')
end
pause(pausetime)
if same_scale
    imagesc(frame2_mlrs_tv,[minv_mlrstv maxv_mlrstv])
else
    imagesc(frame2_mlrs_tv)
end
title('TV-D on MLRS Frame 2','FontSize',title_font),axis image,colormap hot
set(gca,'xtick',[]),set(gca,'ytick',[]),ax.Visible = 'off';
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'tvmlrs_frame2.png')
end
pause(pausetime)
if same_scale
    imagesc(frame3_mlrs_tv,[minv_mlrstv maxv_mlrstv])
else
    imagesc(frame3_mlrs_tv)
end
title('TV-D on MLRS Frame 3','FontSize',title_font),axis image,colormap hot
set(gca,'xtick',[]),set(gca,'ytick',[]),ax.Visible = 'off';
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'tvmlrs_frame3.png')
end
pause(pausetime)

%%%prp-d images
if same_scale
    imagesc(frame1_den,[minv_prpd maxv_prpd])
else
    imagesc(frame1_den)
end
title('PRP-D Frame 1','FontSize',title_font),axis image,colormap hot
set(gca,'xtick',[]),set(gca,'ytick',[]),ax.Visible = 'off';
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if change_caxis
    caxis([prpd_caxis_lower,max(max(frame1_den))])
end
if save_images
    saveas(gcf,'prpd_frame1.png')
end
pause(pausetime)
if same_scale
    imagesc(frame2_den,[minv_prpd maxv_prpd])
else
    imagesc(frame2_den)
end
title('PRP-D Frame 2','FontSize',title_font),axis image,colormap hot
set(gca,'xtick',[]),set(gca,'ytick',[]),ax.Visible = 'off';
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if change_caxis
    caxis([prpd_caxis_lower,max(max(frame2_den))])
end
if save_images
    saveas(gcf,'prpd_frame2.png')
end
pause(pausetime)
if same_scale
    imagesc(frame3_den,[minv_prpd maxv_prpd])
else
    imagesc(frame3_den)
end
title('PRP-D Frame 3','FontSize',title_font),axis image,colormap hot
set(gca,'xtick',[]),set(gca,'ytick',[]),ax.Visible = 'off';
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if change_caxis
    caxis([prpd_caxis_lower,max(max(frame3_den))])
end
if save_images
    saveas(gcf,'prpd_frame3.png')
end
pause(pausetime)

%%%reference/aluminum scattering surface
if same_scale
    imagesc(frame1_ref,[minv_ref maxv_ref])
else
    imagesc(frame1_ref)
end
title('Alumn Frame 1','FontSize',title_font),axis image,colormap hot
set(gca,'xtick',[]),set(gca,'ytick',[]),ax.Visible = 'off';
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'ground_frame1.png')
end
pause(pausetime)
if same_scale
    imagesc(frame2_ref,[minv_ref maxv_ref])
else
    imagesc(frame2_ref)
end
title('Alumn Frame 2','FontSize',title_font),axis image,colormap hot
set(gca,'xtick',[]),set(gca,'ytick',[]),ax.Visible = 'off';
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'ground_frame2.png')
end
pause(pausetime)
if same_scale
    imagesc(frame3_ref,[minv_ref maxv_ref])
else
    imagesc(frame3_ref)
end
title('Alumn Frame 3','FontSize',title_font),axis image,colormap hot
set(gca,'xtick',[]),set(gca,'ytick',[]),ax.Visible = 'off';
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'ground_frame3.png')
end