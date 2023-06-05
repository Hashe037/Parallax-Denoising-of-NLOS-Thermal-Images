%denoise functions to take the 33% value
%this assumes impulse noise that is mostly "on" not off
function denoise_vals = denoise_fun_lowermed(trace_vals)
%     denoise_vals = ones(size(trace_vals))* prctile(trace_vals,33);
    %denoise_vals = ones(size(trace_vals))* mode(trace_vals);
%     denoise_vals = ones(size(trace_vals))* prctile(smooth(trace_vals,5),50);
    denoise_vals = ones(size(trace_vals))* prctile(trace_vals,50);
%     denoise_vals = ones(size(trace_vals))* min(smooth(trace_vals,20));
end