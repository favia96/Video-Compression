%% IMAGE PROCESSING - PROJECT 3, 15.12.2019
%% Federico Favia - Yue Song

%% Initialization
clear ; close all; clc
%addpath(genpath('E:\KTH\P2\Image Processing\Project3'))

%% Part 1: Intra-frame coding
video_width = 176;
video_height = 144;
frame_size = [video_width, video_height];
fps = 30;
number_frames = 50;
frames = yuv_import_y('foreman_qcif.yuv',frame_size,number_frames); % Import luminance of the video

uniform_quantizer = @(x,ssize) round(x/ssize)*ssize;
block_size = 8;
block = 16;
steps = 2.^(3:6);

[recon_frames, enc_dct16, enc_dct16_quan] = intra_coding(frames,steps,frame_size,block_size);
[psnr_intra, bitrates] = intra_eval(frames,video_height,video_width,recon_frames,enc_dct16_quan,steps,block,block_size,fps);

figure('name','Intra-frame coding 1st frame');
subplot(1,3,1); imshow(uint8(frames{1})); title('Original Frame');
subplot(1,3,2); imshow(uint8(frames{1})); title('Frame with quantization step 16');
subplot(1,3,3); imshow(uint8(frames{1})); title('Frame with quantization step 64');
sgtitle(sprintf('Intra-frame coding video step=%.f',steps(2)));

% show reconstructed video
implay(uint8(reshape(cell2mat(recon_frames(2,:)),video_height,video_width,number_frames)),fps);

%% Part 2: Intra-frame and Conditional replenishment coding
lagrangian = @(n,q,r) n+0.2*(q^2)*r; %lambda = 0.2*(q^2);


