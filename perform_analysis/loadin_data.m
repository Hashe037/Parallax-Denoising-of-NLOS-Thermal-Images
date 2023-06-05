%Script to load in denoised results to workspace for further analysis. Run this before
%all other analysis.
%
%--------------------------------------------------------------------------
% User Parameters (similar to "run_denoising_reconstruction) --------------
%
%--------------------------------------------------------------------------
% Variables Saved to Workspace --------------------------------------------
%
% - lfield_cube/pics_raw -- raw 3D light field cube and pics
% (numXi x numEta x numTheta) and (numCams x numPixels)
% - lfield_cube_ground/pics_ground -- ground truth light field cube/pics
% - lfield_cube_se/pics_se -- SE-denoised light field cube/pics (first-stage of MLRS)
% - lfield_cube_emi/pics_emi -- predicted surface self radiance
% - lfield_cube_mlrs/pics_mlrs -- MLRS denoised light field cube/pics
% - lfield_cube_den/pics_den -- MLRS + PRP-D denoised light field cube/pics
% - pics_tv/pics_mlrs_tv -- TV denoised raw/MLRS pictures
% - pmap -- 3D source radiance map (numRp x numEta x numThetaq)
%
%--------------------------------------------------------------------------
%Future Modifications -----------------------------------------------------
% - only save light fields, then process to pictures. Would save some space.
% - process all pictures here (aka replace_image_nans) instead of at
% calculate_metrics_Table1.m

addpath(genpath('../'))

%% user parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mainfolder = 'E:\lfield_data\condensed';
datafolder = strcat(mainfolder,'\bare_rtemp_pos1'); %holds light field cube
groundfolder = strcat(mainfolder,'\ground_pos1'); %ground truth for the person position (aluminmum surface)
mappingfile = strcat(mainfolder,'\lfield_mapping.mat'); %mat file for the lfield -> pics mapping
cubeparamsfile = strcat(datafolder,'\cubeParams.mat'); %parameters about the light field cube

prpdParams = struct();
prpdParams.search_name = "prpd_normal"; %params for range of rp and thetaq values in PRP-D
% "prpd_normal" for high-resolution PRP-D, "prpd_head" for thicker PRP width and more accurate depth-location
prpdParams.filtered_prp = 1; %1 to perform PRP-D at single rp value, 0 to perform PRP-D across all rp
prpdParams.rp_filt = 2250; %SINGLE VALUE %if "filtered_prp", this is the single filtered rp value to denoise across

only_load_essential = 0; %whether to only load the essential light fields in
use_tv = 1; %whether to load in/create the tv-denoised versions or not
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% load data
load(mappingfile) %lfield_mapping
load(strcat(datafolder,'\lfield_cube.mat')); %lfield_cube (raw)
load(cubeparamsfile) %cubeParams
searchParams = retrieve_searchParams(prpdParams.search_name); %searchParams
pmap = load(strcat(datafolder,'\',prpdParams.search_name,'\pmat.mat')); %pmap
pmap = pmap.pmap;

%ground light field (aluminum scattering surface)
lfield_cube_ground = load(strcat(groundfolder,"\lfield_cube.mat"));
lfield_cube_ground = lfield_cube_ground.lfield_cube;

%load denoised light field
denoised_string = strcat(datafolder,'\',prpdParams.search_name,'\lfield_cube_den');
if prpdParams.filtered_prp
    denoised_string = strcat(denoised_string,'_',strcat('rp',num2str(prpdParams.rp_filt)));
end
try
    load(strcat(denoised_string,'.mat'));
catch
    error('Error: Cannot load in light field. Please check the denoised_string variable \n')
end

%load in MLRS stuff
load(strcat(datafolder,'\mlrs_results\lfield_cube_mlrs.mat'))
load(strcat(datafolder,'\mlrs_results\pics_mlrs.mat'))

if ~only_load_essential
    %SE stuff
    load(strcat(datafolder,'\mlrs_results\lfield_cube_se.mat'))
    load(strcat(datafolder,'\mlrs_results\pics_se.mat'))

    %emi stuff
    load(strcat(datafolder,'\mlrs_results\lfield_cube_emi.mat'))
    load(strcat(datafolder,'\mlrs_results\pics_emi.mat'))
end

fprintf('Loaded in variables \n')

%% convert all that is in light field to pixel coordinates
lfield_cell = {lfield_cube_den,lfield_cube,lfield_cube_ground};
[pics_cell] = convert_lfield_to_pics(lfield_cell,lfield_mapping);
pics_den = pics_cell{1};
pics_raw = pics_cell{2};
pics_ground = pics_cell{3};

fprintf('Converted light field to images \n')

%% loadin or create TV denoised version
mlrs_mu = .5;
raw_mu = .5;

raw_tv_name = strcat(datafolder,'\',prpdParams.search_name,'\pics_tv.mat');
mlrs_tv_name = strcat(datafolder,'\',prpdParams.search_name,'\pics_mlrs_tv.mat');

if use_tv
    %find/calculate TV 
    fprintf('Running tv denoising on each image... \n')
    if ~exist(raw_tv_name, 'file') || ~exist(mlrs_tv_name, 'file') %need to calculate TV for each camera picture individually
        pics_tv = perform_tv(pics_raw,raw_mu);
        fprintf('Completed raw tv... \n')
    
        pics_mlrs_tv = perform_tv(pics_mlrs,mlrs_mu);
        fprintf('Completed FRS tv! \n')  
        
        save(raw_tv_name,'pics_tv');
        save(mlrs_tv_name,'pics_mlrs_tv');
    
    else
        load(raw_tv_name); 
        load(mlrs_tv_name);
        fprintf('Loaded in tv! \n')
    end
end

fprintf("Done loading in \n\n")
beep


