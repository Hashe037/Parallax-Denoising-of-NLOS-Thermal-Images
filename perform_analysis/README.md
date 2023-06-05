Code to analyze the results in "perform_denoising" or loaded in from the online repository.

"loadin_data.m" is the first code to run and has many of the same variables as in "run_denoising_reconstruction_script.m" in the "perform_denoising" folder. This code will load the necessary files into the MATLAB workspace, so that the other files can use the data. 

### File breakdown
- depict_scat_epis_fig9.m: depicts the scattering EPIs (scattered light field at constant y location) for the different denoising methods. This creates figures used in Fig. 9 of the paper  
- depict_pics_Fig10.m: depicts the denoised pictures from the different denoising methods as shown in Fig. 10 of the paper  
- depict_pmap_Fig11.m: depicts two slices of the 3D source radiance map (head slice of the human and estimated depth of the human) as shown in Fig. 100 of the paper
