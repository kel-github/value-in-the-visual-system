%%%%%% K. Garner, June 2016. Written for EEG/Rel Val v1 (pilot)
%%%%%% Given two frequencies, and a duration (in frames), this function
%%%%%% generates a change matrix to be used to control the display from
%%%%%% run_freq-Val_exp - allocates left and right frequencies, the cue
%%%%%% colour for any frame (3 - neutral, 1 = left, 2 = right), 
%%%%%% and the tgt colour for any frame (1 = background, 2 = on)
function [out] = gen_change_mat(f1,f2,epoch,val_frame,fix_frame,cue_dir,tgt_frame,f1_start,f2_start)

out = zeros(4,epoch);

start_points = [1 2];

%%%%%%% get frames on which f1 should change
    f1_change = 1:f1:(epoch-(f1-1));
        for i = 1:length(f1_change) %%%%%% allocate display for frame (1 or 2)
            if mod(i,2)
                 out(1,f1_change(i):f1_change(i)+f1-1) = start_points(start_points==f1_start);
            else out(1,f1_change(i):f1_change(i)+f1-1) = start_points(start_points~=f1_start);
            end
        end    
     %%%%% do the ends need to be padded?
            if any(out(1,:) == 0)
                if mod(i,2)
                     out(1,out(1,:) == 0) = 2;
                else out(1,out(1,:) == 0) = 1;
                end
            end
        
     f2_change = 1:f2:(epoch-(f2-1));
         for i = 1:length(f2_change) %%%%%% allocate display for frame (1 or 2)
            if mod(i,2)
                     out(2,f2_change(i):f2_change(i)+f2-1) = start_points(start_points==f2_start);
                else out(2,f2_change(i):f2_change(i)+f2-1) = start_points(start_points~=f2_start);
            end
          end
      %%%%% do the ends need to be padded?
            if any(out(2,:) == 0)
                if mod(i,2)
                     out(2,out(2,:) == 0) = 2;
                else out(2,out(2,:) == 0) = 1;
                end
            end
    
     %%%%%%%%% add the cue colour changes  
     out(3,1:val_frame) = 3;
     out(3,val_frame+1:val_frame+fix_frame) = cue_dir;
     out(3,val_frame+fix_frame+1:end) = 3;
     
     %%%%%%%%% add the target colour changes
     out(4,1:val_frame+fix_frame) = 1;
     out(4,val_frame+fix_frame+1:val_frame+fix_frame+tgt_frame) = 2;
     out(4,val_frame+fix_frame+tgt_frame+1:end) = 1;
     
     out = out';
end



