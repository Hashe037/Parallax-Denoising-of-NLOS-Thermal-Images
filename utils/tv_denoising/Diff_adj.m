function d_i = Diff_adj(X, dim, p, padval)
% -----------------------------------
% USAGE:
%   Performs the p-th order Adjoint operation of Finite difference 
%   of tensor X along the dimension 'dim'.
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

if nargin < 3
    p = 1;
    padval = 'replicate';
elseif nargin < 4
    padval = 'replicate';     % Use zero padding by default
end


d_i = Diff_op(flip(X, dim), dim, p, padval);
d_i = flip(d_i, dim);

end