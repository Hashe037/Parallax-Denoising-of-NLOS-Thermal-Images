%find accuracy of the two images

function[acc] = calc_acc_ref(frame,frame_ref,frame_refm)

%whole image correlation
frame_refn = double(frame_ref)/norm(double(frame_ref),'fro'); %normalize
frame_n = double(frame)/norm(double(frame),'fro'); %normalize

%accuracy defined as normalized cross-correlation
acc = corr2(frame_n,frame_refn);

