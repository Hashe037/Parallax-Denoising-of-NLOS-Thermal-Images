%Depict slices of the scattering EPIs as shown in Fig. 9 of the paper.
%
%Saves images in working folder.
%
%run "loadin_data.m" first 
%--------------------------------------------------------------------------
%

%% parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% example images to show alongside
frame = 50;

%eta/yslices of scattering EPIs
yslice1 = 110; %arms and head
yslice2 = 190; %midsection
yslice3 = 301; %legs

%whether to change the lower limit of PRP-D c-axis
change_caxis = 0;
den_caxis_lower = -.4;%3.8; %lower value of colormap for PRP-D to help deal with outliers

same_scale = 0; %rescale all the images

%outlier removal
remove_outliers = 1; %whether to remove outliers for PRP-D
remove_outliers_other = 1; %wether to remove outliers for rest of variables too

save_images = 1; %saves in the folder

percentiles_den = [1,99.5]; %percentiles to use for outliers in denoised 
percentiles_other = [.5,99.5]; %percentiles for other

im_h = 288; im_w = 382;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% define EPIs and frames

%frames
if remove_outliers_other
    pic_raw = remove_denoised_outliers_percentile(reshape(pics_raw(frame,:,:),im_h,im_w),percentiles_other);
    pic_mlrs = remove_denoised_outliers_percentile(reshape(pics_mlrs(frame,:,:),im_h,im_w),percentiles_den);  
else
    pic_raw = reshape(pics_raw(frame,:,:),im_h,im_w);
    pic_mlrs = reshape(pics_mlrs(frame,:,:),im_h,im_w);   
end

if remove_outliers
    pic_den = remove_denoised_outliers_percentile(squeeze(pics_den(frame,:,:)),percentiles_den);
else
    pic_den = squeeze(pics_den(frame,:,:));
end
pic_ground = reshape(pics_ground(frame+cubeParams.ground_offset,:,:),im_h,im_w);

%epis
if remove_outliers_other
    epi_raw1 = remove_denoised_outliers_percentile(squeeze(lfield_cube(:,yslice1,:)),percentiles_other);
    epi_raw2 = remove_denoised_outliers_percentile(squeeze(lfield_cube(:,yslice2,:)),percentiles_other);
    epi_raw3 = remove_denoised_outliers_percentile(squeeze(lfield_cube(:,yslice3,:)),percentiles_other);
    % frs_epi1 = remove_denoised_outliers_percentile(squeeze(lfield_3d_frs(:,yslice1,:)),percentiles_other);
    % frs_epi2 = remove_denoised_outliers_percentile(squeeze(lfield_3d_frs(:,yslice2,:)),percentiles_other);
    % frs_epi3 = remove_denoised_outliers_percentile(squeeze(lfield_3d_frs(:,yslice3,:)),percentiles_other);
    epi_se1 = remove_denoised_outliers_percentile(squeeze(lfield_cube_se(:,yslice1,:)),percentiles_other);
    epi_se2 = remove_denoised_outliers_percentile(squeeze(lfield_cube_se(:,yslice2,:)),percentiles_other);
    epi_se3 = remove_denoised_outliers_percentile(squeeze(lfield_cube_se(:,yslice3,:)),percentiles_other);
    epi_mlrs1 = remove_denoised_outliers_percentile(squeeze(lfield_cube_mlrs(:,yslice1,:)),percentiles_other);
    epi_mlrs2 = remove_denoised_outliers_percentile(squeeze(lfield_cube_mlrs(:,yslice2,:)),percentiles_other);
    epi_mlrs3 = remove_denoised_outliers_percentile(squeeze(lfield_cube_mlrs(:,yslice3,:)),percentiles_other); 
else
    epi_raw1 = squeeze(lfield_cube(:,yslice1,:));
    epi_raw2 = squeeze(lfield_cube(:,yslice2,:));
    epi_raw3 = squeeze(lfield_cube(:,yslice3,:));
    % frs_epi1 = squeeze(lfield_3d_frs(:,yslice1,:));
    % frs_epi2 = squeeze(lfield_3d_frs(:,yslice2,:));
    % frs_epi3 = squeeze(lfield_3d_frs(:,yslice3,:));
    epi_se1 = squeeze(lfield_cube_se(:,yslice1,:));
    epi_se2 = squeeze(lfield_cube_se(:,yslice2,:));
    epi_se3 = squeeze(lfield_cube_se(:,yslice3,:));
    epi_mlrs1 = squeeze(lfield_cube_mlrs(:,yslice1,:));
    epi_mlrs2 = squeeze(lfield_cube_mlrs(:,yslice2,:));
    epi_mlrs3 = squeeze(lfield_cube_mlrs(:,yslice3,:)); 
end

if remove_outliers
    epi_den1 = remove_denoised_outliers_percentile(squeeze(lfield_cube_den(:,yslice1,:)),percentiles_den);
    epi_den2 = remove_denoised_outliers_percentile(squeeze(lfield_cube_den(:,yslice2,:)),percentiles_den);
    epi_den3 = remove_denoised_outliers_percentile(squeeze(lfield_cube_den(:,yslice3,:)),percentiles_den);
else
    epi_den1 = squeeze(lfield_cube_den(:,yslice1,:));
    epi_den2 = squeeze(lfield_cube_den(:,yslice2,:));
    epi_den3 = squeeze(lfield_cube_den(:,yslice3,:));
end
epi_ground1 = squeeze(lfield_cube_ground(:,yslice1,:));
epi_ground2 = squeeze(lfield_cube_ground(:,yslice2,:));
epi_ground3 = squeeze(lfield_cube_ground(:,yslice3,:));

%the min/maxes
if same_scale
    minv_raw = min(min([epi_raw1(:),epi_raw2(:),epi_raw3(:)])); 
    maxv_raw = max(max([epi_raw1(:),epi_raw2(:),epi_raw3(:)])); 
%     minv_frs = min(min([frs_epi1(:),frs_epi2(:),frs_epi3(:)])); 
%     maxv_frs = max(max([frs_epi1(:),frs_epi2(:),frs_epi3(:)])); 
    minv_emi = min(min([epi_se1(:),epi_se2(:),epi_se3(:)])); 
    maxv_emi = max(max([epi_se1(:),epi_se2(:),epi_se3(:)])); 
    minv_mlrs = min(min([epi_mlrs1(:),epi_mlrs2(:),epi_mlrs3(:)])); 
    maxv_mlrs = max(max([epi_mlrs1(:),epi_mlrs2(:),epi_mlrs3(:)])); 
    minv_den = min(min([epi_den1(:),epi_den2(:),epi_den3(:)])); 
    maxv_den = max(max([epi_den1(:),epi_den2(:),epi_den3(:)])); 
    minv_ref = min(min([epi_ground1(:),epi_ground2(:),epi_ground3(:)])); 
    maxv_ref = max(max([epi_ground1(:),epi_ground2(:),epi_ground3(:)])); 
end

%% show and save images
color_font = 32;
title_font = 32;

%%% camera frames
figure,set( gcf, 'Unit', 'Normalized','Position', [0.1,0.1,0.8,0.8] ) ;
if same_scale %dont scale raw
%     imagesc(frame_raw,[minv_raw,maxv_raw])
    imagesc(pic_raw)
else
    imagesc(pic_raw)
end
axis image,title('Raw Image','FontSize',title_font),colormap hot;
set(gca,'xtick',[]); set(gca,'xticklabel',[]); set(gca,'ytick',[]); set(gca,'yticklabel',[])
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'raw_im.png')
end
% figure,set( gcf, 'Unit', 'Normalized','Position', [0.1,0.1,0.8,0.8] ) ;
% if same_scale
%     imagesc(frame_frs,[minv_frs,maxv_frs])
% else
%     imagesc(frame_frs)
% end
% axis image,title('FRS Image','FontSize',title_font),colormap hot
% set(gca,'xtick',[]); set(gca,'xticklabel',[]); set(gca,'ytick',[]); set(gca,'yticklabel',[])
% c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
% c.Ticks = [c.Limits(1),c.Limits(2)];
% if save_images
%     saveas(gcf,'frs_im.png')
% end
figure,set( gcf, 'Unit', 'Normalized','Position', [0.1,0.1,0.8,0.8] ) ;
if same_scale
    imagesc(pic_den,[minv_den,maxv_den])
else
    imagesc(pic_den)
end
axis image,title('PRP-D Image','FontSize',title_font),colormap hot
set(gca,'xtick',[]); set(gca,'xticklabel',[]); set(gca,'ytick',[]); set(gca,'yticklabel',[])
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
if change_caxis
    caxis([den_caxis_lower,max(max(pic_den))])
end
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'den_im.png')
end
figure,set( gcf, 'Unit', 'Normalized','Position', [0.1,0.1,0.8,0.8] ) ;
if same_scale
    imagesc(pic_ground,[minv_ref,maxv_ref])
else
    imagesc(pic_ground)
end
axis image,title('Alumn Image','FontSize',title_font),colormap hot
set(gca,'xtick',[]); set(gca,'xticklabel',[]); set(gca,'ytick',[]); set(gca,'yticklabel',[])
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'ground_im.png')
end

%%% scattering EPIs
figure,set( gcf, 'Unit', 'Normalized','Position', [0.1,0.1,0.8,0.8] ) ;
if same_scale
    imagesc(epi_raw1,[minv_raw,maxv_raw])
else
    imagesc(epi_raw1)
end
title('Raw Slice 1','FontSize',title_font),colormap hot
set(gca,'xtick',[]); set(gca,'xticklabel',[]); set(gca,'ytick',[]); set(gca,'yticklabel',[])
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'raw_slice1.png')
end
if same_scale
    imagesc(epi_raw2,[minv_raw,maxv_raw])
else
    imagesc(epi_raw2)
end
title('Raw Slice 2','FontSize',title_font),colormap hot
set(gca,'xtick',[]); set(gca,'xticklabel',[]); set(gca,'ytick',[]); set(gca,'yticklabel',[])
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'raw_slice2.png')
end
if same_scale
    imagesc(epi_raw3,[minv_raw,maxv_raw])
else
    imagesc(epi_raw3)
end
title('Raw Slice 3','FontSize',title_font),colormap hot
set(gca,'xtick',[]); set(gca,'xticklabel',[]); set(gca,'ytick',[]); set(gca,'yticklabel',[])
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'raw_slice3.png')
end

% figure,set( gcf, 'Unit', 'Normalized','Position', [0.1,0.1,0.8,0.8] ) ;
% if same_scale
%     imagesc(frs_epi1,[minv_frs,maxv_frs])
% else
%     imagesc(frs_epi1)
% end
% title('FRS Slice 1','FontSize',title_font),colormap hot
% set(gca,'xtick',[]); set(gca,'xticklabel',[]); set(gca,'ytick',[]); set(gca,'yticklabel',[])
% c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
% c.Ticks = [c.Limits(1),c.Limits(2)];
% if save_images
%     saveas(gcf,'frs_slice1.png')
% end
% if same_scale
%     imagesc(frs_epi2,[minv_frs,maxv_frs])
% else
%     imagesc(frs_epi2)
% end
% title('FRS Slice 2','FontSize',title_font),colormap hot
% set(gca,'xtick',[]); set(gca,'xticklabel',[]); set(gca,'ytick',[]); set(gca,'yticklabel',[])
% c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
% c.Ticks = [c.Limits(1),c.Limits(2)];
% if save_images
%     saveas(gcf,'frs_slice2.png')
% end
% if same_scale
%     imagesc(frs_epi3,[minv_frs,maxv_frs])
% else
%     imagesc(frs_epi3)
% end
% title('FRS Slice 3','FontSize',title_font),colormap hot,
% set(gca,'xtick',[]); set(gca,'xticklabel',[]); set(gca,'ytick',[]); set(gca,'yticklabel',[])
% c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
% c.Ticks = [c.Limits(1),c.Limits(2)];
% if save_images
%     saveas(gcf,'frs_slice3.png')
% end

figure,set( gcf, 'Unit', 'Normalized','Position', [0.1,0.1,0.8,0.8] ) ;
if same_scale
    imagesc(epi_se1,[minv_emi,maxv_emi])
else
    imagesc(epi_se1)
end
title('SE Slice 1','FontSize',title_font),colormap hot
set(gca,'xtick',[]); set(gca,'xticklabel',[]); set(gca,'ytick',[]); set(gca,'yticklabel',[])
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'se_slice1.png')
end
if same_scale
    imagesc(epi_se2,[minv_emi,maxv_emi])
else
    imagesc(epi_se2)
end
title('SE Slice 2','FontSize',title_font),colormap hot
set(gca,'xtick',[]); set(gca,'xticklabel',[]); set(gca,'ytick',[]); set(gca,'yticklabel',[])
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'se_slice2.png')
end
if same_scale
    imagesc(epi_se3,[minv_emi,maxv_emi])
else
    imagesc(epi_se3)
end
title('SE Slice 3','FontSize',title_font),colormap hot
set(gca,'xtick',[]); set(gca,'xticklabel',[]); set(gca,'ytick',[]); set(gca,'yticklabel',[])
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'se_slice3.png')
end

figure,set( gcf, 'Unit', 'Normalized','Position', [0.1,0.1,0.8,0.8] ) ;
if same_scale
    imagesc(epi_mlrs1,[minv_mlrs,maxv_mlrs])
else
    imagesc(epi_mlrs1)
end
title('MLRS Slice 1','FontSize',title_font),colormap hot
set(gca,'xtick',[]); set(gca,'xticklabel',[]); set(gca,'ytick',[]); set(gca,'yticklabel',[])
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'mlrs_slice1.png')
end
if same_scale
    imagesc(epi_mlrs2,[minv_mlrs,maxv_mlrs])
else
    imagesc(epi_mlrs2)
end
title('MLRS Slice 2','FontSize',title_font),colormap hot
set(gca,'xtick',[]); set(gca,'xticklabel',[]); set(gca,'ytick',[]); set(gca,'yticklabel',[])
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'mlrs_slice2.png')
end
if same_scale
    imagesc(epi_mlrs3,[minv_mlrs,maxv_mlrs])
else
    imagesc(epi_mlrs3)
end
title('MLRS Slice 3','FontSize',title_font),colormap hot
set(gca,'xtick',[]); set(gca,'xticklabel',[]); set(gca,'ytick',[]); set(gca,'yticklabel',[])
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'mlrs_slice3.png')
end

figure,set( gcf, 'Unit', 'Normalized','Position', [0.1,0.1,0.8,0.8] ) ;
if same_scale
    imagesc(epi_den1,[minv_den,maxv_den])
else
    imagesc(epi_den1)
end
title('PRP-D Slice 1','FontSize',title_font),colormap hot
if change_caxis
    caxis([den_caxis_lower,max(max(lfield_cube_den(:,yslice1,:)))])
end
set(gca,'xtick',[]); set(gca,'xticklabel',[]); set(gca,'ytick',[]); set(gca,'yticklabel',[])
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'den_slice1.png')
end
if same_scale
    imagesc(epi_den2,[minv_den,maxv_den])
else
    imagesc(epi_den2)
end
title('PRP-D Slice 2','FontSize',title_font),colormap hot
if change_caxis
    caxis([den_caxis_lower,max(max(lfield_cube_den(:,yslice2,:)))])
end
set(gca,'xtick',[]); set(gca,'xticklabel',[]); set(gca,'ytick',[]); set(gca,'yticklabel',[])
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'den_slice2.png')
end
if same_scale
    imagesc(epi_den3,[minv_den,maxv_den])
else
    imagesc(epi_den3)
end
title('PRP-D Slice 3','FontSize',title_font),colormap hot
if change_caxis
    caxis([den_caxis_lower,max(max(lfield_cube_den(:,yslice3,:)))])
end
set(gca,'xtick',[]); set(gca,'xticklabel',[]); set(gca,'ytick',[]); set(gca,'yticklabel',[])
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'den_slice3.png')
end

figure,set( gcf, 'Unit', 'Normalized','Position', [0.1,0.1,0.8,0.8] ) ;
if same_scale
    imagesc(epi_ground1,[minv_ref,maxv_ref])
else
    imagesc(epi_ground1)
end
title('Alumn Slice 1','FontSize',title_font),colormap hot
set(gca,'xtick',[]); set(gca,'xticklabel',[]); set(gca,'ytick',[]); set(gca,'yticklabel',[])
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'ground_slice1.png')
end
if same_scale
    imagesc(epi_ground2,[minv_ref,maxv_ref])
else
    imagesc(epi_ground2)
end
title('Alumn Slice 2','FontSize',title_font),colormap hot
set(gca,'xtick',[]); set(gca,'xticklabel',[]); set(gca,'ytick',[]); set(gca,'yticklabel',[])
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'ground_slice2.png')
end
if same_scale
    imagesc(epi_ground3,[minv_ref,maxv_ref])
else
    imagesc(epi_ground3)
end
title('Alumn Slice 3','FontSize',title_font),colormap hot
set(gca,'xtick',[]); set(gca,'xticklabel',[]); set(gca,'ytick',[]); set(gca,'yticklabel',[])
c = colorbar; c.FontSize = color_font; c.FontWeight = 'bold'; c.Ticks = [];
c.Ticks = [c.Limits(1),c.Limits(2)];
if save_images
    saveas(gcf,'ground_slice3.png')
end
