%Visualize the 3-D object radiance map which shows the predicted locations
%of the heated NLOS objects. This is created as a byproduct of the PRP-D
%algorithm. This was also shown in Figure 11 of the paper. Meant to be run
%as a script.
% 
%run "loadin_data.m" first so that variables are in workspace
%--------------------------------------------------------------------------
% Future Modifications %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% - can use more sophisticated peak-finding or filtering (such as Laplacian
% filtering) to isolate the predicted peaks.
%
%% User Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%ground info
ground_rp = 2750; %2000 for pos0, 2750 for pos1, 3250 for pos2
ground_thetaq = -26; %-25 for pos0, -26 for pos1, -27 for pos2

%what slices to make rp/thetao prediction
pmap_etaslices = 80:110; %head of person
%60:90 for pos0, 80:110 for pos1, 115:135 for pos2
pmap_rpslice = 3250; %predicted depth at pos1

%other parameters
do_cartesian = 0; %whether to show in cartesian or stay with polar

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% visualize slice for constant eta (across rp and thetaq)
%define some common params
thetaq_range = searchParams.thetaq_range;
rp_range = searchParams.rp_range;
eta_range = searchParams.eta_range;

%find slice
pmap_slice = squeeze(mean(pmap(:,pmap_etaslices,:),2));
pmap_slice(pmap_slice==0)=nan;

%determine estimated location as max value
[~,maxind] = max(pmap_slice(:));
[maxsubr,maxsubc] = ind2sub(size(pmap_slice),maxind);

fprintf('Estimated rp = %.2f, estimated thetaq = %.2f \n',rp_range(maxsubr),thetaq_range(maxsubc))

if ~do_cartesian
    figure,imagesc(thetaq_range,rp_range,pmap_slice),title(sprintf('rp/thetaq Squeezed from %i to %i eta Values',pmap_etaslices(1),pmap_etaslices(end))), colormap hot
    xlabel('thetaq'),ylabel('rp')
    % hold on, plot3(ground_thetaq,ground_rp,max(pmap_slice(:)),'rx') 
    hold on, plot3(thetaq_range(maxsubc),rp_range(maxsubr),max(pmap_slice(:)),'bx')

else %do cartesian

    xo_reso = 50;
    yo_reso = size(pmap,2); %size of number of y in pmap
    zo_reso = 20;
    [pmap_cart,xo_range,yo_range,zo_range] = pmap_cyltocart(pmap,rp_range,thetaq_range,1:size(pmap,2),xo_reso,yo_reso,zo_reso);

    pmap_cart_slice = squeeze(sum(pmap_cart(:,pmap_etaslices,:),2));
    figure,imagesc(zo_range,xo_range,pmap_cart_slice),title('Xo/Zo  Squeezed'),colormap hot
    xlabel('Zo'),ylabel('Xo')
end


%% visualize slice for constant rp (across eta and thetaq)
%find slice at given rp values
[~,rp_ind] = min(abs(rp_range-pmap_rpslice));
pmap_slice = squeeze(pmap(rp_ind,:,:));
pmap_slice(pmap_slice==0) = nan;

% figure,imagesc(houghp_slice),title(sprintf('y/thetaq Squeezed at rp = %i',rp_val)), colormap hot
figure,imagesc(thetaq_range,eta_range,pmap_slice),title(sprintf('eta/thetaq Squeezed at rp = %i',pmap_rpslice)), colormap hot
xlabel('thetaq'),ylabel('eta')


