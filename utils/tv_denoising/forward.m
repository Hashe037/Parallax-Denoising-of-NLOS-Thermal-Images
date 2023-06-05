
function Y = forward(X, b_ker, theta_in)
% -----------------------------------
% Description:
% USAGE:
%       ** Under construction **
% 
% Author: Abhinav V. Sambasivan, UMN-TC
% -----------------------------------
Y = X;
S = length(b_ker);

X = X.*cosd(theta_in);
for idx = 1:size(X,2)
    Y(:,idx) = conv(X(:,idx), b_ker, 'same')/S;
end

end

