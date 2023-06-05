figure,imagesc(squeeze(se_pics(80,:,:)))
figure,imagesc(squeeze(emi_pics(40,:,:)))

etaslice = 200;
figure,imagesc(squeeze(lfield_cube(:,etaslice,:)))
% figure,imagesc(squeeze(lfield_cube_se(:,etaslice,:)))
% figure,imagesc(squeeze(lfield_cube_noemi(:,etaslice,:)))
figure,imagesc(squeeze(lfield_cube_mlrs(:,etaslice,:)))
figure,imagesc(squeeze(lfield_cube_den(:,etaslice,:)))
figure,imagesc(squeeze(lfield_3d_d(:,etaslice,:)))

