%Script that performs parallax denoising on LWIR light field cube.
%Specifically the MLRS and PRP-D algorithms as explained in Sections 4,5 of
%the paper "Parallax-Driven Denoising of Passively-Scattered Thermal
%Imagery". This script recreates the denoised data as shown in the paper.
%The link to the datasets is given here: BLANKBLANKBLANK
%
%If you just want to analyze results and already-denoised light fields in 
%the paper, this script is NOT needed. Please refer to folder "perform_analysis"
%
%The SE (subtract-emissive) process removes the self-emissive radiance from
%the wall while the FRS (first-rank subtraction) process removes the FPN 
%(fixed-pattern noise). Both of these make the the MLRS (multi-domain
%low-rank subtraction) algorithm. After MLRS, the PRP-D (parallax
%reflection path denoising) denoises the light field cube from stochastic
%noise and surface inhomogeneities. You also construct a 3D parallax map
%which gives an estimate of the hidden heated object locations and shape.
%
%To run this script, please first adjust the "user parameters" section and
%then run each process as you see fit. The algorithms can either save the
%results or load them onto the workspace (and still save results).
%--------------------------------------------------------------------------

%required path
addpath('./mlrs')
addpath('./prpd')
addpath(genpath('../utils'))

%% user parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mainfolder = 'E:\lfield_data\condensed'; %folder right before the datafolder
datafolder = strcat(mainfolder,'\bmason_bare_rtemp_pos1'); %holds light field cube
mappingfile = strcat(mainfolder,'\lfield_mapping.mat'); %mat file for the lfield -> pics mapping
cubeparamsfile = strcat(datafolder,'\cubeParams.mat'); %parameters about the light field cube

prpdParams = struct();
prpdParams.search_name = "prpd_normal"; %params for range of rp and thetaq values in PRP-D
% "prpd_normal" for high-resolution PRP-D, "prpd_head" for thicker PRP width and more accurate depth-location
prpdParams.prp_width = .5; %delta theta of PRP (.5 is normal). Larger means more averaging and smoother results.
prpdParams.filtered_prp = 1; %1 to perform PRP-D at single rp value, 0 to perform PRP-D across all rp
prpdParams.rp_filt = 3500; %SINGLE VALUE %if "filtered_prp", this is the single filtered rp value to denoise across
%"single_rp" should be calculated beforehand by the estimated location of the object in the full "normal" PRP radiance map
%typically 2250 for pos1 (in paper), 1750 for pos0, and 3000 for pos2

save_mlrs = 1; %if 1, will save the MLRS results to datafolder (overwrite previous ones)
save_prpd = 1; %if 1, will save the PRP-D results to datafolder (overwrite previous ones)
save_pmap = 1; %if 1, will save the PRP-D 3D map results to datafolder (overwrite previous ones)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% load in data
cube_name = 'lfield_cube';
cube_dest = strcat(datafolder,'\',cube_name,'.mat');
load(cube_dest) %loads lfield_cube
load(mappingfile) %loads lfield_mapping
load(cubeparamsfile) %loads cubeParams
fprintf('Loaded in raw light field and mapping function \n')

%% run denoising (MLRS + PRP-D)
%note: you can pick-and-choose which algorithms to run as long as the data
%in the cells above are loaded in

%make directory for the MLRS results (if not created already)
mlrs_folder = strcat(datafolder,'\mlrs_results');
if ~exist(mlrs_folder, 'dir')
   mkdir(mlrs_folder)
end

do_mlrs = 1; %1 if using MLRS routine, 0 if using the raw light field
if do_mlrs
    [lfield_cube_mlrs,fpn_pic,se_pics,emi_pics,mlrs_pics] ...
        = perform_mlrs(lfield_cube,cubeParams,lfield_mapping,datafolder,save_mlrs); %Section 4 of paper.
    fprintf('perform_mlrs.m is complete! \n\n\n')
else %just load mlrs in
    cube_dest = strcat(datafolder,'\mlrs_results\lfield_cube_mlrs.mat');
    try
        load(cube_dest)
    catch
        error('Error: cannot load in MLRS cube. If MLRS is not desired, load in raw cube \n')
    end
    fprintf('Loaded in MLRS light field \n')
end

%make directory for the denoised results (if not created already)
den_folder = strcat(datafolder,'\',prpdParams.search_name);
if ~exist(den_folder, 'dir')
   mkdir(den_folder)
end

%runs PRP-D algorithm based on parameters set for the light field cube
[lfield_cube_den,pmap] ...
    = perform_prpd(lfield_cube_mlrs,cubeParams,prpdParams,datafolder,save_prpd,save_pmap);
fprintf('perform_prpd.m is complete! \n\n\n')

beep

