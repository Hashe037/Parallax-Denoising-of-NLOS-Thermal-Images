%Convert images back to the light field with simple lfield_mapping

function[lfield_cell,lfield_cube_hits] = convert_pics_to_lfield(pics_cell,lfield_mapping,cube_size)

lfield_cube_hits = zeros(cube_size);
numPics = size(lfield_mapping,1);
numPoints = size(lfield_mapping,2);

%find number of light fields
if iscell(pics_cell)
    numLfields = length(pics_cell);
    for i=1:numLfields
        lfield_cell{i} = NaN(cube_size);
    end
else
    numLfields = 1;
    lfield_cell = NaN(cube_size);
end

for camind=1:numPics %go through each picture
    for pointind=1:numPoints %each point
        lfield_cube_hits(lfield_mapping(camind,pointind,1),lfield_mapping(camind,pointind,2),lfield_mapping(camind,pointind,3)) ...
            = lfield_cube_hits(lfield_mapping(camind,pointind,1),lfield_mapping(camind,pointind,2),lfield_mapping(camind,pointind,3))+1;
        if numLfields == 1 %not a cell
           lfield_cell(lfield_mapping(camind,pointind,1),lfield_mapping(camind,pointind,2),lfield_mapping(camind,pointind,3))= pics_cell(camind,pointind);
        else
           for lfield_ind = 1:numLfields
                lfield_cell{lfield_ind}(lfield_mapping(camind,pointind,1),lfield_mapping(camind,pointind,2),lfield_mapping(camind,pointind,3))= pics_cell{lfield_ind}(camind,pointind);
           end
        end
    end   
end

%% normalize
% lfield_cube(lfield_cube_hits==0) = NaN; %all elements that were not hit are a zero
if numLfields == 1 %not a cell
   lfield_cell = lfield_cell./lfield_cube_hits;
else
   for lfield_ind = 1:numLfields
        lfield_cell{lfield_ind} = lfield_cell{lfield_ind}./lfield_cube_hits;
   end
end

