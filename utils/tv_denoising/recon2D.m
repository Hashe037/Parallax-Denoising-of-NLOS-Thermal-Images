function [x_hat,out,opts] = recon2D(Y, model, opts)
% -----------------------------------
% USAGE:
%       ** Under construction **
% 
% Author: Abhinav V. Sambasivan, UMN-TC
% -----------------------------------

% Extract forward model
if nargin < 2 || isempty(model)
    % Denoising case
    B = @(x) x;
    BtB = @(x) x;
    Bty = Y;
    L = 1;
else
    % Inverse Problem
    % Convert to operators to functions
    if ~isa(model.fwd,'function_handle')
        model.N = size(model.fwd, 2);
        model.adj = @(x) (model.fwd)'*x;  
        model.fwd = @(x) model.fwd*x;              
    end
    B = model.fwd;
    BtB = @(X) model.adj(B(X));
    Bty = model.adj(Y);
    L = lipschtiz(BtB, model.N);
end

if nargin < 3
    opts = [];
end

% Extract optimization parameters
if isfield(opts, 'mu'),         mu = opts.mu;           else, mu = 5e-2; end
if isfield(opts, 'lambda'),     lambda = opts.lambda;   else, lambda = 2*mu; end
if isfield(opts, 'maxIter'),    maxIter = opts.maxIter; else, maxIter = 5e2; end
if isfield(opts, 'gdIter'),     gdIter = opts.gdIter;   else, gdIter = 5; end
if isfield(opts, 'TV_type'),    TV_type = opts.TV_type; else, TV_type = 'Aniso'; end
if isfield(opts, 'p'),          p = opts.p;             else, p = 1; end
if isfield(opts, 'start_iter'), start_iter = opts.start_iter; ...
                                                        else, start_iter = 0; end
if ~isfield(opts, 'nnls'),          opts.nnls = true; end
if ~isfield(opts, 'time'),          opts.time = 0; end
if ~isfield(opts, 'display'),       opts.display = true; end
if ~isfield(opts, 'diagnostics'),   opts.diagnostics = true; end
if ~isfield(opts, 'iter_tol'),      opts.iter_tol = 1e-3; end
if ~isfield(opts, 'data_fit_tol'),  opts.data_fit_tol = 0.1 ; end
if ~isfield(opts, 'breg_tol'),      opts.breg_tol = 0.02; end

if strcmpi(TV_type, 'iso') && p > 1
    error('Isotropic TV works only with degree, p = 1')
end

% Step size for GD in primal update
% L = 2*L;          % any scalar > 1 should work for the multiplier
eta = 0.5/(mu*L+4*lambda);

% Some useful variables and options
print_steps = 40;
disp_steps = min(20, ceil(maxIter/100));
padval = 'replicate';       % circular, 0, symmetric are few other options

% Problem dimensions
scene_dim = size(Y);        % Observed light-field size.

% Define some required variables/functions
y_norm = norm(Y(:));
D = @(x,dim) Diff_op(x, dim, p, padval);
D_adj = @(x,dim) Diff_adj(x, dim, p, padval);
A = @(x) primal_denoise(x, BtB, D, D_adj, scene_dim, lambda, mu);
shrink = @(y) sign(y).*max(abs(y) - (1/lambda), 0);

if opts.diagnostics
    fprintf('\n\n***********************************************************\n');
    fprintf('**      Entering Regularized Reconstruction Algorithm    **\n');
    fprintf('***********************************************************\n');
    fprintf('\n SOLVING: \n')
    fprintf('\tX_hat = arg min_{X} 0.5*mu*|| Y - B(X) ||^2 + || D^p(X) ||_1, \n')
    fprintf(' where\n\t - Forward model, B(.):\t\t %s', func2str(B))
    fprintf('\n\t - Regularization, D_p(.):\t %stropic TV of degree p = %d',...
        TV_type, p)
    
    fprintf('\n\n * Optimization parameters:\n')
    fprintf(['\t mu = %.2e, \t(Data fit Penalty)',...
        '\n\t lambda = %.2e, \t(Contraint Penalty)',...
        '\n\t gdIter = %d, \t\t(for Primal Update)',...
        '\n\t step-size = %.2f, \t(for Primal Update)',...
        '\n\t maxIter = %d\n'], mu, lambda, gdIter, eta, maxIter)
    
end

tic

% Output error metrics
out.relres = [];
out.gradval = [];
out.constraint_error = [];
out.TV_val = [];
out.time = 0;

% Initialize variables
x = Y;
if opts.diagnostics
    if isfield(opts, 'init')
        fprintf('\n * Using warm restart initialization')
        x = opts.init;
        opts = rmfield(opts,'init');
    else
        fprintf('\n * Using observations as initialization')
        x = Y;
        opts.time = 0;
    end
    if opts.display
        figure(2),
        p1.ax = subplot(1,2,1);
        p1.img = imagesc(Y(:,:,1));
        colorbar(p1.ax)
        %     caxis(p1.ax, [cmin cmax])
        title(p1.ax, 'Noisy observations');
        
        p2.ax = subplot(1,2,2);
        p2.img = imagesc(x(:,:,1));
        colorbar(p2.ax)
        %     caxis(p1.ax, [cmin cmax])
        %     title(p2.ax, 'Reconstruction: Iter 0');
    end
end
x_hat = zeros(size(x));

% Initialize TV variables
d1 = single(zeros(scene_dim));

if isa(Y, 'gpuArray')
    d1 = gpuArray(d1);
    if opts.diagnostics
        fprintf('\n * Using GPU acceleration\n')
    end
else
    if opts.diagnostics
        fprintf('\n * Using CPU for computations\n')
    end
end
d2 = d1;

% Initialize Bregman variables
breg1 = d1;
breg2 = d1;

if opts.diagnostics
    fprintf('\n==========================================');
    fprintf('===========================================\n');
    fprintf([' Iteration, k     Relative Data-fit Error',...
        '    Constraint error   AnisoTV norm of X_k',])
    fprintf('\n==========================================');
    fprintf('===========================================\n');
end
convg = false;
for k=1:maxIter
    
    % Update Primal - x^{k+1}
    b = vec(mu*Bty + ...
        lambda*(D_adj(d1-breg1,1) +...
        D_adj(d2-breg2,2)) );
    
    % Run GD (or variant to solve primal problem)
    x = x(:);
    for gd = 1:gdIter
        x = x - eta*(A(x) - b);
        if opts.nnls
            x = max(x,0);
        end
    end
    out.gradval(k) = gather(norm( vec(A(x) - b) )/norm(b(:)) );
    
    x = reshape(x, scene_dim);
    
    % ---------------------------------------
    % Update TV gradient - d_TV^{k+1}
    switch lower(TV_type)
        case 'iso'
            t1 = D(x,1);
            t2 = D(x,2);
            s = sqrt( (t1 + breg1).^2 + (t2 + breg2).^2 ) + eps;
            d1 = max(s - (1/lambda), 0).*(t1 + breg1)./s;
            d2 = max(s - (1/lambda), 0).*(t2 + breg2)./s;
        case 'aniso'
            d1 = shrink(D(x,1)+breg1);
            d2 = shrink(D(x,2)+breg2);
        otherwise
            error('Invalid TV type! Use only "iso" or "aniso"')
    end
    
    % ---------------------------------------
    % Update Bregman Variables - breg^{k+1}
    breg1 = breg1 + D(x,1) - d1;
    breg2 = breg2 + D(x,2) - d2;
    
    % Compute relative convergence gap
    r = norm( x(:) - x_hat(:) ) / norm( x(:) );
    
    % Compute Errors
    out.constraint_error(k) = gather(...
        norm(vec(d1 - D(x,1))) + ...
        norm(vec(d2 - D(x,2))) ) ...
        / gather( norm( vec(D(x,1)) ) + norm( vec(D(x,2)) ) );
    
    out.relres(k) = gather(norm( vec(B(x) - Y) )/y_norm);
    
    out.TV_val(k) = gather( norm(vec(D(x,1))) + ...
        norm(vec(D(x,2))) );
    
    % Check for convergence
    convg = r < opts.iter_tol && out.relres(k) < opts.data_fit_tol ...
        && out.constraint_error(k)< opts.breg_tol;
    
    if opts.diagnostics
        % Print error values
        if convg || (mod(k,ceil(maxIter/print_steps)) == 1) || (k == maxIter)
            fprintf('%4d/%4d:\t\t%f \t\t%8f \t  %f\n', k+start_iter,...
                maxIter+start_iter, out.relres(k),...
                out.constraint_error(k), out.TV_val(k))
        end
        
        % Update figure
        if opts.display && (convg || mod(k, disp_steps) == 0 || k == maxIter)
            p2.img.CData = gather(x(:,:,1));
            p2.ax.Title.String = sprintf('Reconstruction: Iter %d',k+start_iter);
            drawnow
        end
    end
    x_hat = x;
    
    if convg
        break;
    end
    %%%%%%%%%%%%
end
out.time = opts.time + toc;

if opts.diagnostics
    fprintf('==========================================');
    fprintf('===========================================\n');
    if convg
        fprintf(['Algorithm has converged!\n',...
            'Relative convergence gap: ||X_k - X_{k-1}||/||X_k|| = %f\n',...
            '\nReconstruction Successfull!'], r)
    else
        fprintf(['\nOptimization terminated since MaxIter was reached!\n',...
            'Relative convergence gap: ||X_k - X_{k-1}||/||X_k|| = %f\n'],...
            r)
        fprintf('Result summary: \n\t')
        if out.relres(k) >= opts.data_fit_tol
            fprintf(['- Data-fit contraint violated (tol = %f). ',...
                'Consider increasing mu (or) running longer.\n\t'],opts.data_fit_tol)
        end
        if out.constraint_error(k) >= opts.breg_tol
            fprintf(['- Bregman contraint violated (tol = %f). ',...
                'Consider increasing lambda (or) runnning longer.\n\t'],opts.breg_tol)
        end
        if r >= opts.iter_tol
            fprintf(['- Iterates have not converged yet (tol = %f). '...
                'Consider running longer.\n'], opts.iter_tol)
        end
    end
    fprintf('\nTotal Time taken = %.3f seconds\n', out.time)
    fprintf('*************************************************************\n');
    
end

% Record and report status of reconstruction
out.status = ' ';
if convg
    out.status = sprintf('Converged in %d iterations',k+start_iter);
else
    out.status = sprintf('%s- MaxIter reached.\n',out.status);
end

if out.relres(k) >= opts.data_fit_tol
    out.status = sprintf('%s - Data-fit constraint violated.\n', out.status);   end
if out.constraint_error(k) >= opts.breg_tol
    out.status = sprintf('%s - Bregman constraint violated.', out.status);   end
end

function L = lipschtiz(f, dim)
% -----------------------------------------------------------
% Calculate the Lipschitz constant of a (symmetric) linear operator
% using the power method. 
%   Input: 
%       - f is a function handle, 
%       - dim is the dimension of x (Assume x is a nonnegative quantity)
%   Output:
%       L - Lipschitz constant of f
% 
% NOTE: dimensions of x and f(x) need to be the same
% -----------------------------------------------------------
x = rand([dim,1]);      x = x/norm(x(:));
x_prev = x;
err = 1;
k = 1;
while err > 1e-3 && k <= 20
    x = f(x);       x = x/norm(x(:));
    err = norm(x(:) - x_prev(:))/norm(x(:));
    x_prev = x;
    k = k+1;
end
L = sum(vec(x.*f(x)))/norm(x(:));
end

function A = primal_denoise(X, BtB, D, D_adj, dim, lambda, mu)
% ---------------------------------------------------------
% Performs the Linear operation corresponding to Eq (4.2) of 
% Spilt Bregman paper (Goldstein et al.)
% 
% USAGE:
%   Inputs:
%       X - 2D lightfield (each column is a 1D lightfield)
%       lambda > 0 - TV constraint penalty 
%       mu > 0 - Datafit (or LS) penalty
% 
%   Output: 
%       A - same size as vec(X) 
% ---------------------------------------------------------

X = reshape(X, dim);

A = mu*BtB(X) + ...
    lambda * (D_adj(D(X,1), 1 ) + ...
              D_adj(D(X,2), 2 ) );

A = A(:);
end

% Vectorize a matrix/tensor 
function x = vec(X)
x = X(:);
end