%denoise functions to take the median value
function denoise_vals = denoise_fun_median(trace_vals)
    denoise_vals = ones(size(trace_vals))*median(trace_vals);
end