%Perform SE process (first-stage of MLRS) in Section 4.1 of paper.
%Estimates and subtracts the self-emissive radiance term of the wall. This
%is estimated by the median across scattering angles theta for each scattering
%position xi (Eq. 7 in paper)
%
%--------------------------------------------------------------------------
% Inputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% -lfield_cube -- raw light field cube to be processed (numXi x numEta x numTheta)
% -lfield_mapping -- mapping information from light field to pixel
% coordinates (numImages x numPixels x 3)
% -xi_width -- whether to implement averaging across xi for smoother
% results (0 means none)
% -fun_size -- how many theta components to analyze in the moving median
% filter
% -verbal -- whether to communicate process or not
%
%--------------------------------------------------------------------------
% Outputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% -lfield_cube_emi -- light field cube with JUST self-emissive term
% -lfield_cube_se -- light field cube WITHOUT self-emissive term
% -pics_raw -- raw pictures of light field cube
% -pics_emi -- pictures with JUST self-emissive term (in pixel coordinates)
% -pics_se -- pictures WITHOUT self-emissive term (in pixel coordinates)
%
%--------------------------------------------------------------------------
% Future Modifications %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% - More sophisticated estimation. Can easily implement/replace median
% filter with a more complex filter (TV denoising, low-rank approximation). 
%

function[lfield_cube_emi,lfield_cube_se,pics_raw,pics_emi,pics_se] ...
    = se_process(lfield_cube,lfield_mapping,xi_width,fun_size,verbal)

xi_count = size(lfield_cube,1);
eta_count = size(lfield_cube,2);

%% using a moving median function to find self-radiant term
lfield_cube_emi = zeros(size(lfield_cube)); %emissive term light field
for eta_slice = 1:size(lfield_cube,2) %each eta_slice of scattering light field (constant eta value)
    
    %moving median
    for xi_ind = 1:xi_count %each xi index (spatial scattering location)
        if xi_ind <= xi_width
            lfield_cube_emi(xi_ind,eta_slice,:) = movmedian(mean(lfield_cube(xi_ind:(xi_ind+xi_width),eta_slice,:),1,'omitnan'),fun_size,'omitnan');
        elseif xi_ind > size(lfield_cube,1)-xi_width
            lfield_cube_emi(xi_ind,eta_slice,:) = movmedian(mean(lfield_cube((xi_ind-xi_width):xi_ind,eta_slice,:),1,'omitnan'),fun_size,'omitnan');
        else
            lfield_cube_emi(xi_ind,eta_slice,:) = movmedian(mean(lfield_cube((xi_ind-xi_width):(xi_ind+xi_width),eta_slice,:),1,'omitnan'),fun_size,'omitnan');
        end
    end
    %account for some differences in moving median and nan values in actual light field
    lfield_cube_emi(:,eta_slice,:) = squeeze(lfield_cube_emi(:,eta_slice,:)).*squeeze(lfield_cube(:,eta_slice,:))./squeeze(lfield_cube(:,eta_slice,:));
    
end

if verbal
    fprintf('Performed self-emissive term estimation in SE process \n')
end

%% remove self-emissive term 
lfield_cube_se = zeros(size(lfield_cube)); %noemi = se
for eta_slice=1:eta_count
    lfield_cube_se(:,eta_slice,:) = squeeze(lfield_cube(:,eta_slice,:))-squeeze(lfield_cube_emi(:,eta_slice,:));
end

if verbal
    fprintf('Performed self-emissive removal in SE process \n')
end

%% convert to picture frames

lfield_cell = {lfield_cube,lfield_cube_se,lfield_cube_emi};
[pics_cell] = convert_lfield_to_pics(lfield_cell,lfield_mapping);
pics_raw = pics_cell{1};
pics_se = pics_cell{2};
pics_emi = pics_cell{3};

%interpolate nans on noemi_pics
for i=1:size(pics_se)
    pics_se(i,:,:) = replace_image_nans(squeeze(pics_se(i,:,:))); 
    pics_raw(i,:,:) = replace_image_nans(squeeze(pics_raw(i,:,:))); 
end

if verbal
    fprintf('Converting to images done \n')
end

if verbal
    fprintf('Performed SE Process \n')
end
