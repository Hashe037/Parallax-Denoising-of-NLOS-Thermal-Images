# Parallax Denoising of NLOS Thermal Images
Code that supplements the paper "Parallax-Driven Denoising of Passively-Scattered Thermal Images" accepted to the International Conference on Computational Photography (ICCP) 2023. All code is in MATLAB 2023a while the datasets are stored at (to be added after publication).
 
The code is separated into two parts: the first folder "perform_denoising" contains the code that performs the denoising of the scattered light with the two proposed algorithms in the paper. Multi-domain low-rank subtraction (MLRS) switches between light field and image coordinate systems to remove the self-radiance fluctuations on the scattering surface and the fixed-pattern noise (FPN) of the thermal camera. Parallax reflection path denoising (PRP-D) is used after MLRS and denoises the remaining residual and stochastic noise according to realistic constraints of possible object locations. The second folder "perform_analysis" contains the code that depicts the results of the denoising as shown in Fig. 9, 10, 11, and Table 1.

For a more in-depth look into each folder, please visit the "README.md" file for that folder.
 
## MATLAB toolboxs:
Curve Fitting Toolbox <br>
Image Processing Toolbox <br>
Statistics and Machine Learning Toolbox <br>

## Contact
Please contact the main author (Connor Hashemi) through email at hashe037@umn.edu for any questions or comments.

## Citation
If using the code, please use the following citation: <br>
<br>
Connor Hashemi, Takahiro Sasaki, and James R. Leger. "Parallax-Driven Denoising of Passively-Scattered Thermal Imagery." *2023 IEEE International Conference on Computational Photography (ICCP)*. IEEE, 2023. \[Accepted\]

## Special Acknowledgements:
 We want to give special thanks to Abhinav Sambasivan for his code on total-variation (TV) denoising of scattered light that is included in this repository. Link to his [LinkedIn](https://www.linkedin.com/in/abhinavvs/)
