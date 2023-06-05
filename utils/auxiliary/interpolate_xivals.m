%interpolate NaN elements between xi's in the xi/theta plane that lie
%between non-nan elements. Interpolation goes as linear interpolation and
%is just meant for the light field to have less holes in it, though this is
%also used in the analysis.
%
%--------------------------------------------------------------------------
%todo
%-could use a more complex interpolation method

function[lfield_cube] = interpolate_xivals(lfield_cube)

nonnan_perc = .15;
nonnan_num = 10;

%go through each y/phi slice
for eta_ind = 1:size(lfield_cube,2)
    %go along xi-direction
    for theta_ind = 1:size(lfield_cube,3)
        %find indices to interpolate
        row_vals = squeeze(lfield_cube(:,eta_ind,theta_ind)); %all values
        if sum(~isnan(row_vals)) > nonnan_num %at least 10 elements have to be not nan
            nan_list = isnan(row_vals); %1 if nan, 0 if not
            nan_list_diff = diff(nan_list); %take differentiable
            %find first index
            if ~isnan(row_vals(1))
                startind = 1;
            else
                startind = find(nan_list_diff==-1,1,'first')+1; %find first negative gradient which means nan to not nan (start right after here)
            end
            %find end index
            if ~isnan(row_vals(end))
                endind = length(row_vals);
            else
                endind = find(nan_list_diff==1,1,'last')-1; %find last positive gradient which means not nan to nan (end right before here)
            end
            %trim row_vals
            row_vals = row_vals(startind:endind);
            %interpolate
            if sum(~isnan(row_vals)) > nonnan_perc*length(row_vals) %criteria to allow interpolating
                nanx = isnan(row_vals);
                t = 1:numel(row_vals);
                row_vals(nanx) = interp1(t(~nanx),row_vals(~nanx),t(nanx));

                %add back nans to row_vals and put in lfield cube
                lfield_cube(:,eta_ind,theta_ind) = [NaN(startind-1,1); row_vals; NaN(size(lfield_cube,1)-endind,1)];
            end
        end
    end
end