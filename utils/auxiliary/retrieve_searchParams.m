%retrieve the search parameters with a given denoising name (den_name)

%--------------------------------------------------------------------------
%inputs:
%den_name--string holding the name of the denoising metrics
%--------------------------------------------------------------------------
%outputs:
%rp_search_range--range of radial distances from the center of rotation to
%the object (r_p in paper, mm)
%thetaq_search_range--range of incident angles to search over (theta_q
%in paper, degrees)
%eta_search_range--range of object heights (same as eta-value on wall) (eta in
%paper, mm)


function[searchParams] = retrieve_searchParams(den_name)

%define search params structure
searchParams = struct();

%y/eta values are constant no matter what denoising parameter
eta_search_min = -15*1000; %mm
eta_search_max = 5*1000; %mm
eta_search_reso = 51;

if strcmp(den_name,"prpd_normal") %larger than den1 to show more consistant imagery
    thetaq_look_min = -25;%-90;
    thetaq_look_max = 65; %deg
    thetaq_look_reso = 181; %deg
    rp_look_min = 1*1000; %mm
    rp_look_max = 4*1000; %mm
    rp_look_res = 250;
    fprintf('Using prpd_normal searchParams \n')
elseif strcmp(den_name,"prpd_head") %den accounting for correct human head width
    thetaq_look_min = -25;%-90; %deg
    thetaq_look_max = 65; %deg
    thetaq_look_reso = 31;%161;
    rp_look_min = 1*1000; %mm
    rp_look_max = 4*1000; %mm
    rp_look_res = 250;
    fprintf('Using prpd_head searchParams \n')
elseif strcmp(den_name,"prpd_highdef") %finer r_p than normal
    thetaq_look_min = -25;%-90; %deg
    thetaq_look_max = 65; %deg
    thetaq_look_reso = 181;
    rp_look_min = 1*1000; %mm
    rp_look_max = 4*1000; %mm
    rp_look_res = 100;
    fprintf('Using prpd_highdef searchParams \n')
else
    error(strcat("Error: ",den_name," is not a valid set of search parameters"))
end

%create search ranges
searchParams.rp_range = rp_look_min:rp_look_res:rp_look_max;
searchParams.thetaq_range = -1*linspace(thetaq_look_min,thetaq_look_max,thetaq_look_reso);
searchParams.eta_range = linspace(eta_search_min,eta_search_max,eta_search_reso);


