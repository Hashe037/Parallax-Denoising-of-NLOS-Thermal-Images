%Perform the parallax reflection path denoising (PRP-D) algorithm on a
%single scattering EPI. This goes through all PRPs in the search range and
%denoises for the constant source radiance according to a denoising
%function. 
%
%--------------------------------------------------------------------------
% Inputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% scat_epi -- scattered EPI (constant eta) denoising over (numXi X numTheta)
% cubeParams -- holds the light field cube parameters
% searchParams -- holds the PRP-D search parameters
% prp_width -- width of prp (Delta Theta brdf in Eq 12 in paper)
% do_denoising -- whether to do denoising or just return PMap
% denoise_fun -- function that denoises over each PRP 
% nozero -- treat zero-values in light field as nans
% p_len_min -- minimum length of PRP in order to be denoised
% p_len_cutoff -- if PRP is smaller than this but more than p_len_min, make PRP this length then denoise
%
%--------------------------------------------------------------------------
% Outputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% scat_epi_den -- denoised EPI (numXi X numTheta)
% pmap_epi -- estimated object locations of EPI (numRp x numThetaq)
% p_len -- how many non-nan light field elements are in each prp (numRp x numThetaq)
%
%--------------------------------------------------------------------------
%todo/improvements
%Slowest part is [~, thetas_ind] = min(abs(thetas_range-thetai)); so if we
%can speed that up it would be beneficial
%-add factor considering PRP width? Gaussian? Deblurring?

function [scat_epi_den,pmap_epi,p_len]= prpd_epi(scat_epi,...
    cubeParams,searchParams,prp_width,...
    do_denoising, denoise_fun, nozero, ...
    p_len_min, p_len_cutoff)


%% instantiate parameters
xi_range = cubeParams.xi_range;
theta_range = cubeParams.theta_range;
rp_range = searchParams.rp_range;
thetaq_range = searchParams.thetaq_range;

scat_epi_den = NaN(length(xi_range),length(theta_range)); %holds denoised scattering EPI
pmap_epi = zeros(length(rp_range),length(thetaq_range)); %holds the pmap data for scattering EPI
p_len = zeros(length(rp_range),length(thetaq_range)); %holds prp lengths (non-nan elements in EPI)

%% go through each search index p,q
for rp_ind=1:length(rp_range)
    rp = rp_range(rp_ind); %radial position of hidden source
    for thetaq_ind = 1:length(thetaq_range)
        thetaq = thetaq_range(thetaq_ind); %angle of hidden source
        
        %go through PRP
        prp_subs = []; %holds subscripts of PRP elements
        prp_vals = []; %holds value of PRP elements
        for xi_ind = 1:length(xi_range) %fix xi value, find corresponding thetas
            xi = xi_range(xi_ind);
            
            thetai = atand((xi-rp*sind(thetaq))/(rp*cosd(thetaq))); %corresponding mirror angle (incident mirror angle)
            %check if mirror angle is inside the scattering theta range
            if (thetai > theta_range(1) && thetai < theta_range(end)) 
                %this next line takes the longest time
                [~, thetas_ind] = min(abs(theta_range-thetai)); %find closest thetas element to the thetai

                %analyze corresponding PRP point
                if ~isnan(scat_epi(xi_ind,thetas_ind)) %point is not nan                                                     
                    prp_subs(end+1,:) = [xi_ind,thetas_ind]; %add index to prp indices
                    if nozero && scat_epi(xi_ind,thetas_ind)==0 %don't include zeros so skip this
                        prp_subs = prp_subs(1:end-1,:); %delete last element

                    %only one element (can't double count) or at
                    %least not double counting from previous ????
                    elseif (size(prp_subs,1)==1 || sum(any(prp_subs(end,:)==prp_subs(1:end-1,:))) ~= 4)
                        prp_vals(end+1) = scat_epi(xi_ind,thetas_ind); %add value to PRP
                        pmap_epi(rp_ind,thetaq_ind) = pmap_epi(rp_ind,thetaq_ind)+scat_epi(xi_ind,thetas_ind); %add corresponding point

                        %find brdf blur components (width of PRP)
                        if prp_width ~= 0
                            thetai_l = thetai-prp_width/2; %find the lower thetai from BRDF
                            thetai_u = thetai+prp_width/2; %find upper bound
                            [~, thetas_ind_l] = min(abs(theta_range-thetai_l)); %find index
                            [~, thetas_ind_u] = min(abs(theta_range-thetai_u)); %find index
                            for ind=thetas_ind_l:thetas_ind_u %go through each index
                                if ind ~= thetas_ind %not same value as before
                                    theta_w = 1;%exp(-1/2*((thetas_range(ind)-thetai)/brdfwidth)^2); %perhaps add gaussian weight
                                    add_val = theta_w*scat_epi(xi_ind,ind);
                                    if ~isnan(add_val)
                                        prp_subs(end+1,:) = [xi_ind,ind]; %add point to point list
                                        pmap_epi(rp_ind,thetaq_ind) = pmap_epi(rp_ind,thetaq_ind)+add_val; %add on to transform
                                        prp_vals(end+1) = add_val; %add on to trace
                                    end
                                end
                            end
                        end

                    else %point is invalid so just ignore
                        prp_subs = prp_subs(1:end-1,:); %delete last element
                    end
                end
            end
        end
                   
        %% denoise and normalize the given PRP       
        p_len(rp_ind,thetaq_ind) = size(prp_subs,1); %total length or PRP
        
        if p_len(rp_ind,thetaq_ind) > p_len_min %long enough PRP to denoise
            
            %perform denoising
            if do_denoising
                %some elements but not long enough. This is the case of PRPs that
                %are not long enough but if we remove them then the resulting
                %imagery is misleading. Therefore we add on to the PRP the minimum
                %value until it reaches the minimum length. That way it can still
                %be included in denoising.
                if p_len(rp_ind,thetaq_ind) < p_len_cutoff
                    len_dif = p_len_cutoff-p_len(rp_ind,thetaq_ind); %len difference
                    [minv,minind] = min(prp_vals); %find min
                    [minsubr,minsubc] = ind2sub(size(scat_epi_den),minind); %find min sub
                    prp_subs = [prp_subs;repmat([minsubr,minsubc],len_dif,1)]; %add on to trace
                    prp_vals = [prp_vals,repmat(minv,1,len_dif)];
                end

                %denoise PRPs
                denoised_vals = denoise_fun(prp_vals); %the denoised values
                prp_inds = sub2ind(size(scat_epi_den),prp_subs(:,1),prp_subs(:,2));
                scat_epi_den(prp_inds) = max(scat_epi_den(prp_inds),denoised_vals');
                pmap_epi(rp_ind,thetaq_ind) = max(denoised_vals(:)); %take HoughP as max value
            else %if not denoising to save time, just take average value to save as HoughP
                pmap_epi(rp_ind,thetaq_ind) = pmap_epi(rp_ind,thetaq_ind)/(p_len(rp_ind,thetaq_ind));
            end
        else % not long enough PRP so set houghp value to zero, don't change lfield_d values
            pmap_epi(rp_ind,thetaq_ind) = 0;
        end
    end
end


















