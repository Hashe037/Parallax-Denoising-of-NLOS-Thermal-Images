%Perform the FRS process (second-stage of MLRS) in Section 4.2 of paper.
% 
%The fixed-pattern noise (FPN) of the microbolometer camera is reduced by
%subtracted the low-rank approximation (using SVD) of the images. While 
% this is best performed when the images already have had the
%self-radiant term subtracted using the SE process in Section 4.1, this can also
%be done on its own which still extracts the FPN fairly accurately.
%
%Note that while theoretically the PCA should be calculated across all
%images, we found it is best to just focus on a few images that have the
%most varying mapping function from light field to pixel coordinates. This
%is so that FRS is extracting the noise structure across pixels rather than
%the noise structure across the scattering surface. 
%--------------------------------------------------------------------------
% Inputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% -pics -- the pictures being proccessed (ideally with SE first)
% -start_frame/end_frame -- the indices of the images to use for PCA (note
% that ALL images will have the FPN subtracted but just a few are used to
% calculate FPN)
% -zero_mean -- whether to make each image zero-mean. This is best used if
% the pictures still have the self-radiant term and we are just performing
% FRS without the SE process
% -verbal -- whether to communicate the stages or not
% 
%--------------------------------------------------------------------------
% Outputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -pics_mlrs -- the resulting pictures
% -pic_fpn -- the FPN "image," or the spatial pattern across the pixels
% -coeffs_fpn -- the gain/coeff multiple across each image in pics
%
%--------------------------------------------------------------------------

function[pics_mlrs,pic_fpn,coeffs_fpn]  = ... 
    frs_process(pics,start_frame,end_frame,zero_mean,verbal)

pic_size = size(pics);

%% Trim and reshape pictures to matrix form (numPics x numPixels)
pics_trim = pics(start_frame:end_frame,:,:);
if zero_mean %make each image zero-mean (only do for JUST FRS without the SE process)
    for i=1:size(pics_trim,1)
        pics_trim(i,:,:) = pics_trim(i,:,:)-mean(mean(pics_trim(i,:,:),'omitnan'),'omitnan'); %zero mean
    end
end
pics_mat = reshape(pics_trim,size(pics_trim,1),size(pics_trim,2)*size(pics_trim,3));

%% Find SVD and take the first-rank as FPN
%Note a more sophisticated
[~,~,V] = svd(pics_mat,'econ');
pic_fpn = reshape(V(:,1),pic_size(2),pic_size(3)); %FPN "image" (l^{fpn}(\xi',\eta') in math)

if verbal
    fprintf('Calculated FPN \n')
end
%% Remove first component and reassamble
% S(1,1) = 0; %remove first component
coeffs_fpn = zeros(size(pics,1),1); %FPN coefficients 
pics_mlrs = zeros(size(pics)); %pictures with SE and FRS processes
for camind = 1:size(pics,1)
    if zero_mean %make zero-mean then make projection
        zmean_pic = pics(camind,:,:)-mean(mean(pics(camind,:,:)));
        coeffs_fpn(camind) = nansum(nansum(pic_fpn.*(squeeze(zmean_pic))));
        pics_mlrs(camind,:,:) = squeeze(zmean_pic)-coeffs_fpn(camind).*pic_fpn; %projection and zero-mean
    else %take projection
        coeffs_fpn(camind) = nansum(nansum(pic_fpn.*(squeeze(pics(camind,:,:)))));
        pics_mlrs(camind,:,:) = squeeze(pics(camind,:,:))-coeffs_fpn(camind).*pic_fpn; 
    end
end

if verbal
    fprintf('Removed FPN by projection \n')
end

if verbal
    fprintf('Performed FRS Process \n')
end
