function [psnr_intra,bitrates_intra] = intra_eval(frames,video_height,video_width,recon_frames,coeff,steps,block_size,fps,mode)
    
    hist_intra = zeros(length(steps),length(frames),block_size,block_size,video_height/block_size,video_width/block_size);
    for i = 1 : length(steps)
        for j = 1 : length(frames)
            psnr_intra(i,j) = my_mse(recon_frames{i,j},frames{j});
            for index1 = 1 : video_height/block_size % 1 : 9
                for index2 = 1 : video_width/block_size % 1 : 11
                    hist_intra(i,j,:,:,index1,index2) = coeff{i,j}{index1,index2};
                end
            end
        end
    end
    
    bitrates_intra = zeros(length(steps),length(frames),block_size,block_size);
    
    for i = 1 : length(steps) 
        for j = 1 : length(frames)
            for block_index1 = 1 : block_size % 1 : 16
                for block_index2 = 1 : block_size % 1 : 16
                    prob = reshape(hist_intra(i,j,block_index1,block_index2,:,:,:),1,(video_height/block_size)*(video_width/block_size));
                    prob = hist(prob,min(prob):steps(i):max(prob));
                    prob = prob./sum(prob);
                    bitrates_intra(i,j,block_index1,block_index2) = -sum(prob.*log2(prob+eps)); % bitrate for each block
                    
                end
            end
        end
    end
    
    psnr_intra = sum(psnr_intra,2) / length(frames);
    psnr_intra = my_psnr(psnr_intra);
    
    % bitrate for each frame
    bitrates_intra = sum(bitrates_intra,4);
    bitrates_intra = sum(bitrates_intra,3);%if mode == 0 (intra frame)

    bitrates_intra = bitrates_intra*(video_height/block_size)*(video_width/block_size);
    bitrates_intra = sum(bitrates_intra,2)/length(frames);
    
    if mode == 1 % cond replesh
        bitrates_intra = bitrates_intra + length(frames)*(video_height/block_size)*(video_width/block_size); % the one bit more info
    end
    
    bitrates_intra = bitrates_intra*fps/1000; % transform to kbit/S

end