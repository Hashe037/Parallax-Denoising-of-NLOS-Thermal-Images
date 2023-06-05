%Perform the second algorithm of the paper which is parallax reflection
%path denoising (PRP-D) in Section 5. Given a set of possible source radial 
%position (rp) and angles (thetaq), PRP-D denoises each scattering epi in 
%the MLRS-denoised (Section 4) light field cube with a given denoising 
%function (this code uses median). In addition, PRP-D can estimate
%the location of the hidden sources with the 3D object radiance map which
%we also call the Parallax Map (pmap).
%
%This code is meant to be run after the MLRS algorithm "perform_mlrs.m" in
%"run_denoising_reconstruction_script.m". Also, "prpdParams.filtered_prp"
%says whether to do the filtered version of PRP-D, which is much faster and
%less-blurry at the cost of a priori knowledge of estimated object location
%(can be found with a single-pass of non-filtered PRP-D as explained in
%Section 5.4)
%
%--------------------------------------------------------------------------
% Input Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -lfield_cube_mlrs -- light field cube of MLRS-denoised data (numXi x numEta x numTheta)
% -cubeParams -- structure that holds important info about light field cube
% -prpdParams -- structure that holds important info about PRP-D. The MOST
% IMPORTANT parameters is the "prpdParams.filtered_prp" which says whether
% to use a single rp or multiple (single rp is used in the paper)
% -datafolder -- where data is stored
% -save_prpd,save_pmap -- whether to save data (overwrites previous) or
% just load it in
%
%--------------------------------------------------------------------------
% Outputs (saved or in workspace)) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -lfield_cube_den -- fully-denoised light field cube (numXi x numEta x numTheta)
% -pmap -- estimate of hidden object locations (numRp x numY x numThetaq)
%
%--------------------------------------------------------------------------
% Possible Future Improvements %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% - Improve run-time of "prp_epi.m". Majority of time is spent finding the
% nearest location of the mirror angle min(abs(thetai-thetas_range))
% so implementing a faster search would help greatly with the runtime.
% Perhaps can save the search ahead of time in a dictionary.
%
% - Improving object localization. Ideally can implement an improved peakfinding/local-maxima to find
% location of estimated sources in pmap. Right now we just find the
% max-value of the pmap and assume there is only 1 hidden source.
%
% - Using more sophisticated denoising function. As mentioned in Eq. 15 in
% the paper, we just use a median filter for the given model of noise and
% surface inhomogeneities. A more sophisticated denoising function can be
% implemented (such as TV denoising) for the PRPs with a more exact model.
%
% - Improving PRP width utilization. Increasing prp width in prpdParams
% essentially allows for more smoothing; however, more
% physically-meaningful algorithms can be used instead, such as
% deconvolution.
%

function[lfield_cube_den,pmap] ...
    = perform_prpd(lfield_cube_mlrs,cubeParams,prpdParams,datafolder,save_prpd,save_pmap)

%% other params (shouldn't have to change)
%save file locations
prpd_location = strcat(datafolder,"/",prpdParams.search_name,"/lfield_cube_den",".mat"); %location of existing prp-d light field
prpd_filt_location = strcat(datafolder,"/",prpdParams.search_name,"/lfield_cube_den_rp",num2str(prpdParams.rp_filt),".mat"); %where to save prpd
pmap_location = strcat(datafolder,"/",prpdParams.search_name,"/pmat.mat"); %parallax map location to save/load in
pmap_filt_location = strcat(datafolder,"/",prpdParams.search_name,"/pmat_rp",num2str(prpdParams.rp_filt),".mat"); %parallax map location to save/load in

%prpd parameters
minlength = 400; %minimum length to be considered a PRP in light field
eta_slice_ave = 0; %how many yslices to add over (double this) (for averaging)

%pmap params
mf_pmap = 0; %1 if do 3D median filtering on total pmap
mf_pmap_win = [5,5,5]; %window size
mf_pmap_2d = 0; %1 if do 2D median filerting on each scattering EPI 
mf_pmap_win_2d = [5,5]; %window size

%% find the search ranges for denoising
searchParams = retrieve_searchParams(prpdParams.search_name);

%% optional: shorten rp_range to just be singular value (filtered version)
%This is typically done after a first-pass with the entire range, finding
%the rp value that has the highest source radiance, and then rerunning with
%just that value.
if prpdParams.filtered_prp
    searchParams.rp_range = prpdParams.rp_filt;
    fprintf('Shortening rp range to %i values \n',length(prpdParams.rp_filt))
end

%% perform PRP-D algorithm
% return_folder = cd(datafolder);
numSlices = size(lfield_cube_mlrs,2);
prp_width = prpdParams.prp_width;

pmap = zeros(length(searchParams.rp_range),length(searchParams.eta_range),...
    length(searchParams.thetaq_range)); %instantiate pmap
lfield_cube_den = NaN(size(lfield_cube_mlrs)); %denoised 3d light field

fprintf('Performing PRP-D and 3D parallax map generation \n')
tic
% ticBytes(gcp)
parfor eta_slice = 1:numSlices %each x/theta slice
    scat_epi = lfield_cube_mlrs(:,eta_slice,:); %scattering EPI for given eta value
    
    % if eta_slice_ave>0 %do some eta coordinate averaging (if needed)
    %     min_eta = max(1,eta_slice-eta_slice_ave);
    %     max_eta = min(numSlices,eta_slice+eta_slice_ave);
    %     scat_epi = squeeze(mean(lfield_cube_mlrs(:,min_eta:max_eta,:),2));
    % end
    
    %perform actual denoising of single scattering EPI
    [lfield_cube_den(:,eta_slice,:),pmap(:,eta_slice,:),~] = prpd_epi(scat_epi,...
    cubeParams, searchParams, prp_width, ...
    1, @denoise_fun_median, false, ...
    minlength,minlength);

    fprintf('Eta slice %d done \n',eta_slice)
end
% tocBytes(gcp)
fprintf('PRP-D is Done! \n')

%%% 3-D median smooth houghp (entire 3-D light field)
if mf_pmap == 1
    pmap = medfilt3(pmap,mf_pmap_win);
    fprintf('3-D Median Filtering is Done! \n')
end

%%% 2-D median smooth houghp (each scattering EPI)
if mf_pmap_2d == 1
    for eta_slice = 1:size(lfield_cube_mlrs,2)
        pmap = medfilt2(pmap,mf_pmap_win_2d);
    end
    fprintf('2-D Median Filtering is Done! \n')
end
toc

%% save results
if save_pmap
    if prpdParams.filtered_prp
        save(pmap_filt_location,'pmap','searchParams')
    else
        save(pmap_location,'pmap','searchParams')
    end
    fprintf('Saving pmap is done \n')
end

%if need to save PRP-D
if save_prpd
    if prpdParams.filtered_prp
        save(prpd_filt_location,'lfield_cube_den','prpdParams')
    else
        save(prpd_location,'lfield_cube_den','prpdParams')
    end
    fprintf('Saving lfield_cube_den is done \n')
end












