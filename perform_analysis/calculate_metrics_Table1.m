%Calculate and compare the image quality measurements as shown in Table 1
%in the paper for all of the different denoising techniques. The metrics we
%use do not focus on fine features as they are smoothed out by the
%reflection but rather the overall shape of the human and signal. The metrics are calculated 
%from start_frame to end_frame and the final is given by the average over all of them.
%
%The first metric is contrast-to-noise ratio (CNR). This is calculated by
%CNR = (mean of signal - mean of background) / (std of signal + std of background)
%Second is normalized cross correlation (NCC) which is just the normalized
%dot product between the ground truth and the tested image.
%
%run "loadin_data.m" first so that variables are in workspace
%--------------------------------------------------------------------------


%% parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
base_thresh = 1250; %threshold for reference frames to consider object vs background
start_frame = 35; %beginning analysis frame
end_frame = 85; %end analysis frame

%if cropping image, what top/bottom pixels to crop
cut_image = 0;
top_pix = 50;
bot_pix = 275;

%other params
do_save = 0; %save the metric data
show_graphs = 0; %show the graphcs of metrics vs frame number

percentiles_den = [1,99.5]; %percentiles to use for outliers in denoised 
percentiles_other = [1,99.5]; %percentiles for other

quick_mode = 0; %quick means skip a lot of the removing outliers part
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% find metrics and display metrics
%lists that hold the values
ref_list = {};
raw_list = {[],[],[],[]};
mlrs_list = {[],[],[],[]};
tv_raw_list = {[],[],[],[]};
tv_mlrs_list = {[],[],[],[]};
den_list = {[],[],[],[]};
im_h = 288; im_w = 382;

%go through each frame
for pic_ind = start_frame:end_frame
    
    %ground truth/aluminum scattering surface pictures
    pic_ground = reshape(pics_ground(pic_ind+cubeParams.ground_offset,:,:),im_h,im_w);
    pic_ground(isnan(pic_ground)) = min(pic_ground(:));

    %downshift reference frame to account for slight height difference
    pic_ground = imtranslate(pic_ground,[0,10],'FillValues',min(pic_ground(:)));
    pic_ground_mask = pic_ground > base_thresh;
    
    %find other images
    pic_raw = squeeze(pics_raw(pic_ind,:,:));
    % pic_raw(isnan(pic_raw)) = min(pic_raw(:)); %no nans
    pic_raw = replace_image_nans(pic_raw);
    pic_raw = rescale(pic_raw); %rescale from 0-1
    pic_mlrs = squeeze(pics_mlrs(pic_ind,:,:));
    % pic_mlrs(isnan(pic_mlrs)) = min(pic_mlrs(:)); %no nans
    pic_mlrs = replace_image_nans(pic_mlrs); %no nans
    pic_mlrs = rescale(pic_mlrs); %rescale from 0-1
    
    
    %find and remove outliers of denoised image
    pic_den = squeeze(pics_den(pic_ind,:,:));
    % pic_den(isnan(pic_den)) = min(pic_den(:)); %no nans
    pic_den = replace_image_nans(pic_den); %no nans
    pic_den = remove_denoised_outliers_percentile(pic_den,percentiles_den);
    pic_den = rescale(pic_den);
    if ~quick_mode
        pic_raw = remove_denoised_outliers_percentile(pic_raw,percentiles_other);
        pic_raw = rescale(pic_raw);
        pic_mlrs = remove_denoised_outliers_percentile(pic_mlrs,percentiles_other);
        pic_mlrs = rescale(pic_mlrs);
    end

    %load in TV denoised versions if analyzing
    if use_tv==1
        pic_tv = rescale(reshape(pics_tv(pic_ind,:,:),im_h,im_w));
        pic_mlrs_tv = rescale(reshape(pics_mlrs_tv(pic_ind,:,:),im_h,im_w));

        if ~quick_mode
            pic_tv = remove_denoised_outliers_percentile(pic_tv,percentiles_den);
            pic_tv = rescale(pic_tv);
            pic_mlrs_tv = remove_denoised_outliers_percentile(pic_mlrs_tv,percentiles_den);
            pic_mlrs_tv = rescale(pic_mlrs_tv);
        end
    end

    %if cutting down on images
    if cut_image == 1
        pic_ground = pic_ground(top_pix:bot_pix,:);
        pic_ground_mask = pic_ground_mask(top_pix:bot_pix,:);
        pic_raw = pic_raw(top_pix:bot_pix,:);
        pic_mlrs = pic_mlrs(top_pix:bot_pix,:);
        pic_den = pic_den(top_pix:bot_pix,:);
        
        pic_raw = rescale(pic_raw);
        pic_mlrs = rescale(pic_mlrs);
        pic_den = rescale(pic_den);
        
        if use_tv == 1
            pic_tv = pic_tv(top_pix:bot_pix,:);
            pic_mlrs_tv = pic_mlrs_tv(top_pix:bot_pix,:);
            pic_tv = rescale(pic_tv);
            pic_mlrs_tv = rescale(pic_mlrs_tv);
        end
    end

    %calculate metrics
    raw_list{1}(end+1) = calc_cnr_ref(pic_raw, pic_ground_mask);
    mlrs_list{1}(end+1) = calc_cnr_ref(pic_mlrs, pic_ground_mask);
    den_list{1}(end+1) = calc_cnr_ref(pic_den, pic_ground_mask);
    
    raw_list{2}(end+1) = calc_acc_ref(pic_raw, pic_ground, pic_ground_mask);
    mlrs_list{2}(end+1) = calc_acc_ref(pic_mlrs, pic_ground, pic_ground_mask);
    den_list{2}(end+1) = calc_acc_ref(pic_den, pic_ground, pic_ground_mask);
       
    if use_tv==1
        tv_raw_list{1}(end+1) = calc_cnr_ref(pic_tv, pic_ground_mask);
        tv_mlrs_list{1}(end+1) = calc_cnr_ref(pic_mlrs_tv, pic_ground_mask);

        tv_raw_list{2}(end+1) = calc_acc_ref(pic_tv, pic_ground, pic_ground_mask);
        tv_mlrs_list{2}(end+1) = calc_acc_ref(pic_mlrs_tv, pic_ground, pic_ground_mask);
    end
end

%find mean values across each metric
for i=1:2
    raw_aves{i} = mean(raw_list{i});
    mlrs_aves{i} = mean(mlrs_list{i});
    den_aves{i} = mean(den_list{i});
    
    if use_tv == 1
        tv_raw_aves{i} = mean(tv_raw_list{i});
        tv_mlrs_aves{i} = mean(tv_mlrs_list{i});
    end
end
if use_tv == 0
    for i=1:2
        tv_raw_aves{i} = nan;
        tv_mlrs_aves{i} = nan;
    end
end

%print results
fprintf('Average Frame CNR: Raw is %f, MLRS is %f, TV on Raw is %f, TV on MLRS is %f, PRP-D on MLRS is %f \n',...
    raw_aves{1}, mlrs_aves{1}, tv_raw_aves{1}, tv_mlrs_aves{1}, den_aves{1})
fprintf('Average Frame ACC: Raw is %f, MLRS is %f, TV on Raw is %f, TV on MLRS is %f, PRP-D on MLRS is %f \n',...
    raw_aves{2}, mlrs_aves{2}, tv_raw_aves{2}, tv_mlrs_aves{2}, den_aves{2})
fprintf('\n')

%if want to save data
if do_save
    save('CNRs_aves.mat','frame1_lfield_cnr','frame2_lfield_cnr','frame3_lfield_cnr',...
        'frame1_lfield_tv_cnr','frame2_lfield_tv_cnr','frame3_lfield_tv_cnr', ...
        'frame1_den_cnr','frame2_den_cnr','frame3_den_cnr')
    fprintf('Saved! \n')
end

if show_graphs
    if use_tv
        figure,title('CNR List'),hold on, 
        plot(raw_list{1}),plot(mlrs_list{1}),plot(tv_raw_list{1}),plot(tv_mlrs_list{1}),plot(den_list{1})
        legend('Raw','MLRS','TV','MLRS + TV','MLRS + PRP-D')

        figure,title('ACC List'),hold on, 
        plot(raw_list{2}),plot(mlrs_list{2}),plot(tv_raw_list{2}),plot(tv_mlrs_list{2}),plot(den_list{2})
        legend('Raw','MLRS','TV','MLRS + TV','MLRS + PRP-D')
    else
        figure,title('CNR List'),hold on, 
        plot(raw_list{1}),plot(mlrs_list{1}),plot(den_list{1})
        legend('Raw','MLRS','MLRS + PRP-D')

        figure,title('ACC List'),hold on, 
        plot(raw_list{2}),plot(mlrs_list{2}),plot(den_list{2})
        legend('Raw','MLRS','MLRS + PRP-D')
    end
end


fprintf('Done \n')
beep