function [normd_tf_dat] = norm_epoch(bl_data, data)
    % perform normalisation (pwr change) on time frequency data
    % K. Garner, 2019
    % 100 * ( (activity tf - median baseline tf) / median baseline tf)
    % data    = epoched condition median timefrequency data in a freq x timepoints x chans
    % bl_data = freq x timepoints x channels data
    
    % median bl_dat over timepoints, and then repeat bl_dat to make same size as data
    bl_dat = median(bl_data, 2);
    bl_dat = repmat(bl_dat, 1, size(data, 2), 1);
    % now apply normalisation to all of data
    data         = 100 * ( ( data - bl_dat ) ./ bl_dat );    
    normd_tf_dat = data;
       
end
    
    
    
    
    
    
    
    
    

