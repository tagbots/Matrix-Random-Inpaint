% Utility: inpaint_xmask(alg_list, img, snr, delta)
%
% Input:
%   1) alg_list: "call names for my four algos"
%   2) img: test image
%   3) delta: percentage of known entries (see undersampling ratio formula)
%
% Output:
%   1) image_results: results from each algorithm
%   2) M: rank-50 truncated singular-value decomposition (SVD) of img
%   3) inpaintOut: result from inpainting step
%   4) inpaint_psnr: peak SNR of inpainted image

function [image_results, M, inpaintOut, inpaint_psnr, snr] = inpaint_xmask_v2(alg_list, img, delta)

% ======== read and normalize greyscale data

X = imread(img);
X = im2gray(X);
X=double(X)/255;

% ======== rank-50 SVD to allow recovery to arbitrary precision

r = 50;
[U, S, V] = svds(X,r);

clear X;

M = U*S*V';

[m, n] = size(M);

% ======== generate the observation space Omega

rng(1)

p = round(delta*m*n);
% Omega = randperm(sOmega, m*n, p)';

if delta == 1
   Omega=(1:m*n)';
else
   A = zeros(m*n,1);
   A(1:p) = ones(p,1);
   [~,ind] = sort(randn(m*n,1));
   A = A(ind);
   A = reshape(A,m,n);

   [I, J] = find(A);
   Omega = sub2ind([m n], I, J);
end


% ======== restrict image approximation to observed entries

data = M(Omega);

% ======== calculate realized SNR induced by missing observations

snr = 20*log10(norm(data)/norm(data - M(Omega)));

% ======== load mask

maskFile = load('xmask.mat', 'A');
cross = maskFile.A;

% ======== image inpainting and generate observed mask

maskValue = 1; % ------- adjust mask pixel value

% -------- option one: cross mask with random observations

dirtyX = logical(cross(Omega));

inpaintOut = zeros(size(M));
inpaintOut(Omega(~dirtyX)) = maskValue;
inpaintOut(Omega(dirtyX)) = data(dirtyX);

data(~dirtyX) = 0;

% -------- option two: random observations with random mask

% cleanX = logical(~cross);
% 
% inpaintOut = zeros(size(M));
% inpaintOut(Omega) = data;
% inpaintOut(cleanX) = maskValue;
% 
% data(cleanX(Omega)) = 0;

% ======== calculate realized SNR and PSNR of inpainted image

inpaint_psnr = psnr(inpaintOut, M, 1);

% ======== test algorithms on inpainted image

fprintf('recovery starts...\n')

image_results = cell(size(alg_list));

opts = default_opts;
disp('Options used:')
disp(opts)

for k = 1:numel(alg_list)

    alg_name = alg_list{k};
    fhandle = str2func(alg_name);

    % initialize low-rank guess
    start = make_start_x(alg_name, m, n, r, Omega, data);

    fprintf('%s recovery starts...\n', alg_name)

    tic
    [Mout, Out] = fhandle(m, n, r, Omega, data, start, opts);
    ttol = toc;

    % store algo results
    image_results{k} = Mout;

    % error calculation
    relerr = norm(M - Mout, 'fro') / norm(M, 'fro');

    fprintf(['%s relerr = %g, iter = %d, ' 't = %g, reschg = %g\n\n'], ...
        alg_name, relerr, Out.iter, ttol, Out.reschg);

end

fprintf('recovery ends...\n\n')

close all
