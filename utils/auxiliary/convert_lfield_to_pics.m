%Convert light field to images (pixel coordinate frames)

function [pics_cell] = convert_lfield_to_pics(lfield_cell,lfield_mapping)

numPics = size(lfield_mapping,1);
numPoints = size(lfield_mapping,2);
im_h = 288; im_w = 382;

%find number of light fields
if iscell(lfield_cell)
    numLfields = length(lfield_cell);
    for i=1:numLfields
        pics_cell{i} = NaN(numPics,im_h*im_w);
    end
else
    numLfields = 1;
    pics_cell = NaN(numPics,im_h*im_w);
end

%% apply mapping
for camind=1:numPics %go through each picture
    %go through each point and find the corresponding denoised element
    for pointind = 1:numPoints
        lfield_inds = lfield_mapping(camind,pointind,:);
        if numLfields == 1 %not a cell
            pics_cell(camind,point_ind) = lfield_cell(lfield_inds(1),lfield_inds(2),lfield_inds(3));
        else
            for lfield_ind = 1:numLfields
                pics_cell{lfield_ind}(camind,pointind) = lfield_cell{lfield_ind}(lfield_inds(1),lfield_inds(2),lfield_inds(3));
            end
        end
    end
end


%% reshape so pictures are correct size
if numLfields == 1 %not a cell
    pics_cell = reshape(pics_cell,numPics,im_h,im_w);
else %is a cell
    for lfield_ind = 1:numLfields
        pics_cell{lfield_ind} = reshape(pics_cell{lfield_ind},numPics,im_h,im_w);
    end
end
