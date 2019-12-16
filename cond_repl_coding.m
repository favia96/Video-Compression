function [recon_frames,psnr_cond_repl,bitrates_cond_repl] = cond_repl_coding(frames,frame_size,video_height,video_width,steps,block_size,fps)
    
    % coding part
    for i = 1 : length(steps)
        for j = 1 : length(frames)
            curr_frame = frames{j};
            dct16{j} = mat2cell(curr_frame, repmat(block_size, 1, frame_size(2)/block_size), ...
            repmat(block_size, 1, frame_size(1)/block_size)); 
            
            for m = 1 : size(dct16{j},1)
                for n = 1 : size(dct16{j},2)
                    enc_dct16{j}{m,n} = blkproc(dct16{j}{m,n},[block_size/2 block_size/2],@dct2);
                    enc_dct16_quan{i,j}{m,n} = mid_tread_quant(enc_dct16{j}{m,n},steps(i));
                    dec_idct16{i,j}{m,n} = blkproc(enc_dct16_quan{i,j}{m,n},[block_size/2 block_size/2],@idct2);
                end
            end
            recon_frames{i,j} = cell2mat(dec_idct16{i,j});
        end
    end
    
    % selection mode part
    hist_intra = zeros(length(steps),length(frames),block_size,block_size,video_height/block_size,video_width/block_size);
    coeff = enc_dct16_quan;

    for i = 1 : length(steps)
        for j = 1 : length(frames)
            mse_intra(i,j) = my_mse(recon_frames{i,j},frames{j});
            
            for index1 = 1 : video_height/block_size % 1 : 9
                for index2 = 1 : video_width/block_size % 1 : 11
                    
                    hist_intra(i,j,:,:,index1,index2) = coeff{i,j}{index1,index2};
                    mse_intra_mode(i,j,index1,index2) = my_mse(recon_frames{i,j}((index1-1)*block_size+1:index1*block_size,(index2-1)*block_size+1:index2*block_size),frames{j}((index1-1)*block_size+1:index1*block_size,(index2-1)*block_size+1:index2*block_size));
                    
                    if j >= 2
                        mse_copy_mode(i,j,index1,index2) = my_mse(recon_frames{i,j-1}((index1-1)*block_size+1:index1*block_size,(index2-1)*block_size+1:index2*block_size),frames{j}((index1-1)*block_size+1:index1*block_size,(index2-1)*block_size+1:index2*block_size));
                    else
                        mse_copy_mode(i,j,index1,index2) = mse_intra_mode(i,j,index1,index2);
                    end
                end
            end
        end
    end
    
    bitrates = zeros(length(steps),length(frames),block_size,block_size);
    
    for i = 1 : length(steps)
        for j = 1 : length(frames)
            for block_index1 = 1 : block_size % 1 : 16
                for block_index2 = 1 : block_size  % 1 : 16
                    prob = reshape(hist_intra(i,j,block_index1,block_index2,:,:,:),1,(video_height/block_size)*(video_width/block_size));
                    prob = hist(prob,min(prob):steps(i):max(prob));
                    prob = prob./sum(prob);
                    bitrates(i,j,block_index1,block_index2) = -sum(prob.*log2(prob+eps)); % bitrate for each block
                        
                    J_intra_mode(i,j,block_index1,block_index2) = mse_intra_mode(i,j,block_index1,block_index2) + 0.2*steps(i).^2 * (bitrates(i,j,block_index1,block_index2) + 1);

                    if j >= 2
                        J_copy_mode(i,j,block_index1,block_index2) = mse_copy_mode(i,j,block_index1,block_index2) + 0.2*steps(i).^2 * (bitrates(i,j-1,block_index1,block_index2) + 1);
                    else
                        J_copy_mode(i,j,block_index1,block_index2) = J_intra_mode(i,j,block_index1,block_index2);
                    end
                    
                    if J_intra_mode(i,j,block_index1,block_index2) > J_copy_mode(i,j,block_index1,block_index2)
                        enc_dct16_quan{i,j}{m,n} = enc_dct16_quan{i,j-1}{m,n}; % copy from previous frame
                    end
                end
            end
        end
    end
    
    % idct 
    for i = 1 : length(steps)
        for j = 1 : length(frames)
            for m = 1 : size(dct16{j},1)
                for n = 1 : size(dct16{j},2)
                   dec_idct16{i,j}{m,n} = blkproc(enc_dct16_quan{i,j}{m,n},[block_size/2 block_size/2],@idct2);
                end
            end
            recon_frames{i,j} = cell2mat(dec_idct16{i,j});
        end
    end
    
    [psnr_cond_repl, bitrates_cond_repl] = intra_eval(frames,video_height,video_width,recon_frames,enc_dct16_quan,steps,block_size,fps,1);
    % bitrates_cond_repl = bitrates_cond_repl + length(frames)*9*11;

end

