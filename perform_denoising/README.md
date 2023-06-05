"run_denoising_reconstruction_script.m" runs the denoising algorithm in script form for a particular set of user parameters as defined in the first section of the code. The main parameter to change is the "mainfolder" and "datafolder" which dictate where the data is stored and where the denoising results should be saved. All parameters are described in the code.

## File Breakdown
### mlrs folder
- perform_mlrs.m: contains code that runs both the SE and FRS process which makes up the multi-domain low-rank subtraction (MLRS) algorithm described in Section 4 of the paper.  
- se_process.m: contains code about the subtract-emissive (SE) process which is the first stage of MLRS. This removes the surface self-radiance fluctuations assuming that the emission is Lambertian (i.e. constant across scattering angle).  
- frs_process.m: contains code about the first-rank subtraction (FRS) process which is the second stage of MLRS. This removes the fixed-pattern noise (FPN) assuming it is low-rank across camera images and that it is much stronger than the scattered radiance from NLOS object.  

### prpd folder
- perform_prpd.m: contains code that runs the parallax reflection path denoising (PRP-D) described in Section 5 of the paper.  
- prpd_epi.m: contains the actual PRP-D algorithm code for a single scattering EPI.  
- denoise_fun_lowermed.m/denoise_fun_median.m: example denoising functions for PRP-D. The paper uses denoise_fun_median (median filter).  
