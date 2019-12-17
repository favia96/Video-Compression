%% IMAGE PROCESSING - PROJECT 3, 15.12.2019
%% Federico Favia - Yue Song

%% Initialization
clear ; close all; clc
%addpath(genpath('E:\KTH\P2\Image Processing\Project3'))

%% Part 1: Intra-frame coding
% parameters of video
video_width = 176;
video_height = 144;
frame_size = [video_width, video_height];
fps = 30;
number_frames = 50;

% Import luminance of the video
frames = yuv_import_y('foreman_qcif.yuv',frame_size,number_frames); % try with mother daughter too

% uniform_quantizer = @(x,ssize) round(x/ssize)*ssize;
block_size = 16;
steps = 2.^(3:6);

%% 
[recon_frames_intra, enc_dct16, enc_dct16_quan] = intra_coding(frames,steps,frame_size,block_size);
[psnr_intra, bitrates_intra] = intra_eval(frames,video_height,video_width,recon_frames_intra,enc_dct16_quan,steps,block_size,fps,0);

%% Plot
figure('name','Intra-frame coding 1st frame');
subplot(1,3,1); imshow(uint8(frames{1})); title('Original Frame');
subplot(1,3,2); imshow(uint8(recon_frames{2,1})); title('Frame with qtz step 16');
subplot(1,3,3); imshow(uint8(recon_frames{4,1})); title('Frame with qtz step 64');
sgtitle(sprintf('Intra-frame coding video steps = (%.f, %.f)',steps(2),steps(4)));

%% PSNR curves
figure('name','PSNR vs bitrate intra frame')
plot(bitrates_fore,psnr_intra_fore); %after saved them
hold on
plot(bitrates,psnr_intra);
hold off 
legend('Foreman','Mother-daughter')
ylabel('PSNR value [dB]')
xlabel('Bit-rates [kbps]')
title('PSNR versus bitrate curve for Intra-frame video coder')

%% show reconstructed video Foreman
implay(uint8(reshape(cell2mat(recon_frames(2,:)),video_height,video_width,number_frames)),fps);

%% Part 2: Intra-frame and Conditional replenishment coding
[recon_frames,psnr_cond_repl,bitrates_cond_repl,J_intra_mode,J_copy_mode] = cond_repl_coding(frames,frame_size,video_height,video_width,steps,block_size,fps);

%%
figure('name','Intra-frame coding 1st frame');
subplot(1,3,1); imshow(uint8(frames{15})); title('Original Frame');
subplot(1,3,2); imshow(uint8(recon_frames{2,15})); title('Frame with qtz step 16');
subplot(1,3,3); imshow(uint8(recon_frames{4,15})); title('Frame with qtz step 64');
sgtitle(sprintf('Intra-frame coding video steps = (%.f, %.f)',steps(2),steps(4)));

%% PSNR curves
figure('name','PSNR vs bitrate cond rep')
plot(bitrates_cond_repl,psnr_cond_repl,'-*');
hold on
plot(bitrates_intra,psnr_intra,'-*');
hold off 
legend('cond repl','intra coder')
ylabel('PSNR value [dB]')
xlabel('Bit-rates [kbps]')
title('PSNR versus bitrate curve for Cond. repl. video coder')

%%
figure()
plot(reshape(J_intra_mode(2,10,:,:),1,99));
hold on
plot(reshape(J_copy_mode(2,10,:,:),1,99));
hold off 
legend('cond repl','intra coder')



