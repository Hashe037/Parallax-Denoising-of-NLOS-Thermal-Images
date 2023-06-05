%calculate snr by the mean of signal over std of noise with reference image

function[snr] = calc_cnr_ref(frame,frame_ref)

%define signal and noise
frame_sig = double(frame(frame_ref));
frame_noise = double(frame(~frame_ref));

%actual CNR
%snr = (mean(frame_sig)-mean(frame_noise))/std(double(frame(:)));

%Weber contrast
% snr = (mean(frame_sig)-mean(frame_noise))/mean(frame_noise);

%Michelson contrast
%snr = (mean(frame_sig)-mean(frame_noise))/(mean(frame_sig)+mean(frame_noise));

%proposed CNR
% also used by pg 107, 110, Chapter 7 Signal, Noise, Signal-to-Noise, and Contrast-to-Noise Ratios
snr = (mean(frame_sig)-mean(frame_noise))/(sqrt(var(frame_sig)+var(frame_noise))); %mean and std of difference between two gaussians

%CNR with std of just background
%snr = (mean(frame_sig)-mean(frame_noise))/var(double(frame_noise(:)));



