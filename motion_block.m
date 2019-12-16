function [mVecsIndexes,mVecs]=motion_block(frame, next_frame)
bSize=16;
shifts=[1:10;1:10];
[vid_height, vid_width] = size(next_frame);
dy_max = max(shifts(1,:));
dx_max = max(shifts(2,:));

err = zeros(vid_height/bSize,vid_width/bSize,length(shifts));
mVecsIndexes = zeros(1,vid_height/bSize*vid_width/bSize);
mVecs = zeros(2,vid_height/bSize*vid_width/bSize);
index = 1;
% MSE calculation
for i=1:vid_height/bSize    
    for j=1:vid_width/bSize     
        for d=1:length(shifts)           
            rows = 1+dy_max+(i-1)*bSize : 1+dy_max+(i-1)*bSize + bSize-1;
            cols = 1+dx_max+(j-1)*bSize : 1+dx_max+(j-1)*bSize + bSize-1;
            
            shifted_rows = rows + shifts(1,d);  % rows + dy
            shifted_cols = cols + shifts(2,d);  % rows + dx
            
            ref_rows = rows-dy_max;
            ref_cols = cols-dx_max;                     
            Diff2 = (frame(shifted_rows,shifted_cols)-next_frame(ref_rows,ref_cols)).^2;
            err(i,j,d) = sum(Diff2(:))/numel(Diff2);
        end
        %MIN MSE
        temp = find(err(i,j,:) == min(err(i,j,:)));
        if length(temp) > 1  
            temp = temp(1,1);  
        end
        mVecsIndexes(1,index) = temp;
        mVecs(:,index) = shifts(:,temp);
        index = index+1;
    end
end
end