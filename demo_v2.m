% for a pure image inpainting test,
% specify delta = 1 and select the additive noise test.

clear; close all; clc

% ========= random tests =======
fprintf('--- random matrix completion ---\n')

% --------- problem size -------
m = 100;
n = 100;
p = round(delta*m*n);
r = 50;
delta_percent=100*delta;

fprintf('problem size: m = %d, n = %d, p = %d, r = %d\n\n', m, n, p, r)

test_list = cell(2,1);
test_list{1} = 'inpaint_addnoise';
test_list{2} = 'inpaint_xmask';

alg_list = cell(4,1);
alg_list{1} = 'NIHT_Matrix';
alg_list{2} = 'CGIHT_Matrix';
alg_list{3} = 'ASD';
alg_list{4} = 'ScaledASD';

img_list = cell(12,1);
img_list{1} = 'boat.png';
img_list{2} = 'barb.png';
img_list{3} = 'lena.png';
img_list{4} = 'aerial.tiff';
img_list{5} = 'baboon.tiff';
img_list{6} = 'bubbles.tiff';
img_list{7} = 'couple.tiff';
img_list{8} = 'GGB2.jpg';
img_list{9} = 'oakland.tiff';
img_list{10} = 'peppers.tiff';
img_list{11} = 'straw.tiff';
img_list{12} = 'airplane.tiff';

% ======== user input

% fprintf('1. NIHT, 2. CGIHT, 3. ASD, 4. ScaledASD (suggested:))\n')
% alg = input('Select an algorithm number from 1 to 4: ');

fprintf(['1. boat, 2. barb, 3. lena, 4. aerial, 5. baboon, 6. bubbles,' ...
    ' 7. couple, 8. GGB, 9. oakland, 10. peppers, 11. straw, 12. airplane \n'])

img = input('Select an image number from 1 to 12: ');

mytest = input(['Choose a test to conduct on the inpainted image:\n' ...
    '1. Additive noise (inpaint_addnoise)\n' ...
    '2. Cross mask (inpaint_xmask): ']);

% ======== run image inpainting tests

if mytest == 1
    snr = input('Enter desired SNR in dB (example: 5, 10, 20, 30): ');
    [image_results, M, inpaintOut, inpaint_psnr] = inpaint_addnoise_v2(alg_list, ...
        img_list{img}, delta, snr);

elseif mytest == 2
    [image_results, M, inpaintOut, inpaint_psnr, snr] = inpaint_xmask_v2(alg_list, ...
        img_list{img}, delta);
else
end

fprintf('\n')

figure;
subplot(2, 3, 1)
imshow(M, [])
title('Original')

subplot(2, 3, 2)
imshow(inpaintOut, [])
title({['Realized SNR = ', num2str(snr), ' dB'], ['PSNR = ', num2str(inpaint_psnr, '%.2f'), ' dB']})

for k=1:4
    recovered_psnr = psnr(image_results{k}, M);
    subplot(2, 3, k+2)
    imshow(image_results{k}, [])
    title({alg_list{k},['PSNR = ', num2str(recovered_psnr, '%.2f'), ' dB']}, 'Interpreter', 'none')
end

fig_filename = ['tiles_alg',test_list(mytest),'_snr',num2str(snr),'_observed', num2str(delta_percent), '.png'];

% 'percent_rank', num2str(r),

%exportgraphics(gcf, fig_filename, 'Resolution', 300);

% % --------- NIHT_Matrix ---------
% fprintf('NIHT starts ...\n')
% matrix_completion('NIHT_Matrix', m, n, p, r)
% fprintf('NIHT over ...\n\n')
% 
% % ---------- CGIHT_Matrix -------
% fprintf('CGIHT starts ...\n')
% matrix_completion('CGIHT_Matrix', m, n, p, r)
% fprintf('CGIHT over ...\n\n')
% 
% % ----------- ASD --------------
% fprintf('ASD starts ...\n')
% matrix_completion('ASD', m, n, p, r)
% fprintf('ASD over ...\n\n')
% 
% % -------- ScaledASD ------------
% fprintf('ScaledASD starts ...\n')
% matrix_completion('ScaledASD', m, n, p, r)
% fprintf('ScaledASD over ...\n\n')
% 
% % ========= image inpainting ======
% fprintf('--- random/cross inpainting ---\n')