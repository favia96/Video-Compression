function [recon_frames,enc_dct16,enc_dct16_quan] = intra_coding(frames,steps,frame_size,block_size)
    
    for i = 1 : length(steps)
        for j = 1 : length(frames)
            curr_frame = frames{j};
            dct16{j} = mat2cell(curr_frame, repmat(2*block_size, 1, frame_size(2)/(2*block_size)), ...
            repmat(2*block_size, 1, frame_size(1)/(2*block_size))); 
            
            for m = 1 : size(dct16{j},1)
                for n = 1 : size(dct16{j},2)
                    enc_dct16{j}{m,n} = blkproc(dct16{j}{m,n},[block_size block_size],@dct2);
                    enc_dct16_quan{i,j}{m,n} = mid_tread_quant(enc_dct16{j}{m,n},steps(i));
                    dec_idct16{i,j}{m,n} = blkproc(enc_dct16_quan{i,j}{m,n},[block_size block_size],@idct2);
                end
            end
            recon_frames{i,j} = cell2mat(dec_idct16{i,j});
        end
    end
    
end