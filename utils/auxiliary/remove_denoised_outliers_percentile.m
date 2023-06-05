%Remove outliers in the denoised images. Outliers arise from multiple
%sources, but can greatly affect the rescaling and other metrics. We
%mostly care about outliers that are below a certain value, as this likely
%means it should be part of the background or hasn't been denoised.

function[frame] = remove_denoised_outliers_percentile(frame,percentile)

[~,outliers_inds1] = rmoutliers(frame(:),'percentiles',[percentile(1) 100]); %detect outliers by quartiles
[~,outliers_inds2] = rmoutliers(frame(:),'percentiles',[0 percentile(2)]); %detect outliers by quartiles

outlier_floor = min(frame(~outliers_inds1)); %minimum value of non-outliers
outlier_ceil= max(frame(~outliers_inds2)); %minimum value of non-outliers

% outliers = frame(outliers_inds); %outlier values    
frame(frame<outlier_floor) = outlier_floor;  %only get rid of low outliers
frame(frame>outlier_ceil) = outlier_ceil;  %only get rid of low outliers
