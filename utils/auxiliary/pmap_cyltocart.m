%convert the source radiance map  from cylindrical to cartesian coordinates
%
%output:
%
%pmap_cart -- cartesian withsize xo_reso x yo_reso x zo_reso

function[pmap_cart,xo_range,yo_range,zo_range] = pmap_cyltocart(pmap_cyl,rp_range,thetaq_range,eta_cyl_range,xo_reso,yo_reso,zo_reso)

%% instantiate parameters
pmap_cart = zeros(xo_reso,yo_reso,zo_reso);

% Ro_vals = repmat(Ro_range,1,size(houghp_cyl,2),size(houghp_cyl,3));
% thetao_vals = repmat(thetao_range,size(houghp_cyl,1),1,size(houghp_cyl,3));
% yo_cyl_vals = repmat(yo_cyl_range,size(houghp_cyl,1),size(houghp_cyl,2),1);

%% convert cylindrical ranges to cartesian
%convert 3D cylindrical to 3D cart 
%start by converting to Ro x thetao x yo for simplicity
xo_vals = repmat(rp_range' * sind(thetaq_range),1,1,size(pmap_cyl,2));
zo_vals = repmat(rp_range' * cosd(thetaq_range),1,1,size(pmap_cyl,2));
yo_vals = repmat(eta_cyl_range,size(pmap_cyl,1),1,size(pmap_cyl,3));

%now switch to Ro x yo x thetao
xo_vals = permute(xo_vals,[1,3,2]);
zo_vals = permute(zo_vals,[1,3,2]);
% yo_vals = permute(yo_vals,[1,3,2]);

xo_range = linspace(min(xo_vals(:)),max(xo_vals(:)),xo_reso);
yo_range = linspace(min(yo_vals(:)),max(yo_vals(:)),yo_reso);
zo_range = linspace(min(zo_vals(:)),max(zo_vals(:)),zo_reso);

%% assign the values to the houghp cartesian
for ind = 1:numel(pmap_cyl)
   [~,xo_ind] = min(abs(xo_range-xo_vals(ind)));
   [~,yo_ind] = min(abs(yo_range-yo_vals(ind)));
   [~,zo_ind] = min(abs(zo_range-zo_vals(ind))); 
   pmap_cart(xo_ind,yo_ind,zo_ind) = max(pmap_cart(xo_ind,yo_ind,zo_ind),pmap_cyl(ind));
end

