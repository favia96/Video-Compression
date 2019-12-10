%% Clear and addpath
clear; clc;
addpath(genpath('E:\KTH\P2\Image Processing\Project3'))
%% Uniform Quantizer
uniform_quantizer = @(x,ssize) round(x/ssize)*ssize;
%% Inter-frame coding
frame_size=[176,144];
frames=yuv_import_y('foreman_qcif.yuv',frame_size,50);
%imagesc(video1{1})
steps=[2^3,2^4,2^5,2^6];
for i=1:length(steps)
    for j=1:length(frames)
    curr_frame=frames{j};
    dct16{j} = mat2cell(curr_frame, repmat(16, 1, frame_size(2)/16), ...
    repmat(16, 1, frame_size(1)/16)); 
    for m=1:size(dct16{j},1)
        for n=1:size(dct16{j},2)
             enc_dct16{j}{m,n}=blkproc(dct16{j}{m,n},[8 8],@dct2);
             enc_dct16_quan{i,j}{m,n}=uniform_quantizer(enc_dct16{j}{m,n},steps(i));
             psnr_dct(i,j,m,n)=psnr(enc_dct16_quan{i,j}{m,n},enc_dct16{j}{m,n});
        end
    end
    end
end
psnr_dct=psnr_dct./numel(psnr_dct)*length(steps);
psnr_dct=sum(psnr_dct,[2,3,4]);

