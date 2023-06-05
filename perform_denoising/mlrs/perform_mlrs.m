%Perform the first denoising stage on the light field cube, called
%multi-domain low-rank subtraction (MLRS), which aims to remove the
%self-emissive wall radiance and fixed-pattern noise. MLRS is explained in
%Section 4 of the paper.
%
%This code is meant to be run in "run_denoising_reconstruction_script.m"
%
%--------------------------------------------------------------------------
% Input Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% -lfield_cube -- light field cube of data (numXi x numEta x numTheta)
% -cubeParams -- structure that holds important info about light field cube
% -lfield_mapping -- mapping information from light field to pixel
% coordinates (numImages x numPixels x 3)
% -datafolder -- where light field cube is saved
% -save_mlrs -- whether to save results or just return them (1 or 0)
%
%--------------------------------------------------------------------------
% Outputs (saved to datafolder/mlrs_results iff save_mlrs==1) %%%%%%%%%%%%%
% - lfield_cube_mlrs -- MLRS denoised light field cube (numXi x numEta x numTheta)
% - pic_fpn -- estimated fixed-pattern noise (FPN) in pixel coordinates
% - pics_se -- pictures after SE process (first-stage of MLRS)
% - pics_emi -- pictures of estimated self-emmissive term
% - pics_mlrs -- pictures of MLRS denoised
%
%--------------------------------------------------------------------------
% Possible Modifications %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - While the SE process uses a "moving median" function to estimate the
% self-emissive term in Eq 7, more complex methods can be easily
% implemented by modifying "se_process" code.
%
% - FRS is performed using SVD analysis which is highly susceptible to
% noise and distortion, especially if the desired signal is strong. A more
% sophisticated low-rank approximation method (such as robust PCA) can be
% used in place of SVD (at the cost of increased complexity)
%
% - While MLRS has two parts (SE and FRS), we found that just having one of
% the parts (just SE) works fairly well in this setup since the mapping
% function (lfield_mapping) is not that unique for our setup. Therefore,
% some results are better just using FRS (especially if there is no
% self-radiance fluctuations)
%
%--------------------------------------------------------------------------
% Toolbox Dependencies
% -Statistics and Machine Learning Toolbox (?)
% -Computer Vision Toolbox (?)

% addpath('./utils/mlrs')

function[lfield_cube_mlrs,pic_fpn,pics_se,pics_emi,pics_mlrs] ...
    = perform_mlrs(lfield_cube,cubeParams,lfield_mapping,datafolder,save_mlrs)

%% parameters that can be changed

%name of light field cube to perform preprocessing
cube_name = 'lfield_cube';

%saving locations
pic_fpn_location = "./mlrs_results/pics_fpn"; 
%fpn_coeffs_location = "./fpn_coeffs"; 
lfield_cube_emi_location = "./mlrs_results/lfield_cube_emi"; 
pics_se_location = "./mlrs_results/pics_se"; 
lfield_cube_se_location = "./mlrs_results/lfield_cube_se"; 
pics_emi_location = "./mlrs_results/pics_emi"; 
pics_mlrs_location = "./mlrs_results/pics_mlrs"; 
lfield_cube_mlrs_location = "./mlrs_results/lfield_cube_mlrs"; 

%interpolation of cube parameters
interp_cube_xi = 1;
interp_cube_theta = 1;

%averaging across xi (helps with miscalibration or missampling)
xi_width = 0;

%how many theta values to observe for finding the emissive term
%(large is best but relies on accurate light field capture)
fun_size = 200;

%which camera images to use for FRS calculation
start_pic = 90; %ignore initial pictures due low mapping uniqueness
end_pic = 98; %ignore last several pictures due to lfield artifacts

verbal = 1; %says when each process is done

%% Perform SE process (remove self-radiance term)
[lfield_cube_emi,lfield_cube_se,pics_raw,pics_emi,pics_se] ...
    = se_process(lfield_cube,lfield_mapping,xi_width,fun_size,verbal);
%% perform FRS process on pictures
%perform FRS on SE pictures
%
%cubeParams.frs_only:  -- whether to perform just the second algorithm (FRS) (used if
% little to no surface sefl-radiance fluctations are expected)
if ~cubeParams.frs_only 
    [pics_mlrs,pic_fpn,coeffs_fpn]  = ... 
        frs_process(pics_se,start_pic,end_pic,0,verbal);
else %just use the raw pictures (ignore SE process)
    fprintf('NOTE: Only doing second-stage FRS in MLRS \n')
    [pics_mlrs,pic_fpn,coeffs_fpn]  = ... 
        frs_process(pics_raw,start_pic,end_pic,0,verbal);
end

%% convert back to light field to get MLRS light field
[lfield_cube_mlrs, ~] = convert_pics_to_lfield(pics_mlrs,lfield_mapping,size(lfield_cube));
fprintf('Converted back to lfield \n')

%% interpolate NaN elements between theta's in the x/theta plane that lie between non-nan elements
%must interpolate for a smooth-looking light field cube
%this part takes a while; future work can speed this up or use more
%sophisticated interpolation algorithms

%interpolate along theta for each xi
fprintf('Ratio of nonempty-to-all elements without interpolation is %f \n',sum(~isnan(lfield_cube_mlrs(:)))/numel(lfield_cube_mlrs))
if interp_cube_theta == 1
    lfield_cube_mlrs = interpolate_thetavals(lfield_cube_mlrs);
    fprintf('Complete theta interpolation \n')
    fprintf('Ratio of nonempty-to-all elements is now %f \n',sum(~isnan(lfield_cube_mlrs(:)))/numel(lfield_cube_mlrs))
end

%% interpolate NaN elements in the x/theta plane that lie between non-nan elements
%interpolate along x for each theta
if interp_cube_xi == 1
    lfield_cube_mlrs = interpolate_xivals(lfield_cube_mlrs);
    fprintf('Complete xi interpolation \n')
    fprintf('Ratio of nonempty-to-all elements is now %f \n',sum(~isnan(lfield_cube_mlrs(:)))/numel(lfield_cube_mlrs))
end


%% save data

if save_mlrs
    return_folder = cd(datafolder);

    save(pics_se_location,'pics_se')
    save(lfield_cube_se_location,'lfield_cube_se')
    save(pics_emi_location,'pics_emi')
    save(lfield_cube_emi_location,'lfield_cube_emi')
    save(pic_fpn_location,'pic_fpn')
    save(pics_mlrs_location,'pics_mlrs')
    save(lfield_cube_mlrs_location,'lfield_cube_mlrs')
    
    cd(return_folder);
    fprintf('Saving complete \n ')
end









    