function d_i = Diff_op(X, dim, p, padval)
% -----------------------------------
% USAGE:
%   Performs the p-th order Finite difference operation of tensor
%   X along the dimension 'dim'.
% 
%   Optional Input:
%       - p: degree of Finite Difference (DEFAULT = 1)
%       - padval:  
%           * 'symmetric' - Pads with mirror reflections of itself
%           * 'circular' - Pads with circular repetition
%           * scalar - Pads with the specified nonzero value
%           * DEFAULT - 'replicate' padding 
% 
%   Output: 
%       Finite difference of X (same dimension as X)
% 
% Author: Abhinav V. Sambasivan, UMN-TC
% -----------------------------------

if dim > ndims(X) || dim < 1
    error('Invalid argument value: dim')
end

if nargin < 3
    p = 1;
    padval = 'replicate';
elseif nargin < 4
    padval = 'replicate';     % Use zero padding by default
end

padsize = p.*double(1:ndims(X) == dim);
d_i = diff(padarray(X, padsize, padval, 'pre'), p, dim);

end