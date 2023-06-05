%perform 2-D TV denoising over each picture in pics

function[pics_tv] = perform_tv(pics,mu)

opts = struct();
opts.maxIter = 100;
opts.gdIter = 5;
opts.TV_type = 'Iso';
opts.p = 1;
opts.iter_tol = 5e-4;
opts.data_fit_tol = 0.2;
opts.breg_tol = 1e-1;
opts.nnls = false;
opts.diagnostics = false;

numPics = size(pics,1);
pics_tv = zeros(size(pics));
opts.mu = mu;
opts.lambda = 2*opts.mu;
parfor camind=1:numPics %go through each picture
    pic = squeeze(double(pics(camind,:,:)));
    pic = replace_image_nans(pic);
    [pics_tv(camind,:,:),~] = recon2D(pic, [], opts);
end


