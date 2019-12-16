%% Clear and addpath
clear; clc;
addpath(genpath('E:\KTH\P2\Image Processing\Project3'))
%% Uniform Quantizer
uniform_quantizer = @(x,ssize) round(x/ssize)*ssize;
%% Intra-frame coding
frame_size=[176,144];
frames=yuv_import_y('mother-daughter_qcif.yuv',frame_size,50);
%imagesc(video1{1})
steps=[2^3,2^4,2^5,2^6];
[recon_frames,enc_dct16]=intra_coding(frames,steps,frame_size);
[psnr_intra,bitrates]=intra_eval(frames,recon_frames,enc_dct16_quan,steps);
%% Plot
figure;
subplot(1,3,1); imshow(uint8(frames{1})); title('Original Frame');
subplot(1,3,2); imshow(uint8(recon_frames{2,1})); title('Frame with quantization step 16');
subplot(1,3,3); imshow(uint8(recon_frames{4,1})); title('Frame with quantization step 64');
%% PSNR curve
figure;
plot(bitrates_fore,psnr_intra_fore); 
hold on
plot(bitrates,psnr_intra);
hold off 
legend('Foreman','Mother-daughter')
ylabel('PSNR value in dB')
xlabel('Bit-rates in kbps')
title('PSNR versus bitrate curve for Intra-frame video coder')
%% Inter-mode Video Coder with Motion Compensation



