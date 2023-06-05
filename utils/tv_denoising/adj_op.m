
function Y = adj_op(X, b_ker, theta_in)
% -----------------------------------
% Description:
% USAGE:
%       ** Under construction **
% 
% Author: Abhinav V. Sambasivan, UMN-TC
% -----------------------------------
Y = X;

for idx = 1:size(X,2)
    Y(:,idx) = conv(X(:,idx).*cosd(theta_in), b_ker(end:-1:1), 'same');
end

Y = Y.*cosd(theta_in) / length(b_ker);
end