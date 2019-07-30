function [ mi, cond_dat ] = get_modulation_pre_tgt_idx_v2( data, freqs, neighbours, cond_idxs, chans_to_average, onsets, lose_dim ) 
% written by K. Garner, 2019
% calculate modularion index (L_trial - R_trial) / (L_trial + R_trial)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% inputs
% ---------------------------------------------------------
% data = frequency x times x trials x channels
% freqs = frequencies to extract
% neighbours = if lose_dim = 1, how many frequency neighbours to include in
% average (0 if none)?
% if lose_dim = 0, which f +/- value do you want to include in the plot?
% cond_idxs = a n x m matrix, with conditions to be compared on the rows
% (and the condition that forms the baseline measure, to which the other
% conditions will be compared, and m is the variants/counterbalances of
% that n
% chans_to_average = which channels should be averaged over - this should
% be a nchan x nfrq x nform matrix, where nform is how many physical
% displays made up the experiment/have had channels selected for
% onsets = a structure generated from the preprocessing and saved with the
% participants tf data. Contains the info about conditions
% lose_dim = do you want to average over the frequency dimension? (1 for
% ye, 0 for no)


% outputs
% ---------------------------------------------------------
% mi = modulation index for left and right side separately, for ll-hh/ll+hh
% and so on
% has fields - name (name of mi)
%            - left = modulation index on left, for that condition
%            comparison
%            - right = as above, but for right side
% cond_dat = values used to calculate modulation indexs
% has fields - idx = event values that form the condition
%            - names = names of conditions entered into values
%            - l_channel_f1_f1l_dat = tf data, aggregated across the left
%            channels for f1 (16.67 hz), when f1 was on the left
%            the remaining fields can be deduced from there.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% extract correct frequencies 
% ---------------------------------------------------------
t_frqs = onsets.freqs;

if any(lose_dim) % if collapsing across frequencies
    tmp = dsearchn( t_frqs', freqs' );
    nu_data = zeros( numel(freqs),  size(data, 2), size(data, 3), size(data, 4) );
    for i = 1:numel(tmp)
        frq_idx = tmp(i)-neighbours:tmp(i)+neighbours;
        nu_data( i, :, :, : ) = mean(data( frq_idx, :, :, : ), 1);
    end
    clear tmp

else
    tmp = [dsearchn( t_frqs', [ freqs(1) - neighbours, freqs(1) + neighbours ]' ), ... 
           dsearchn( t_frqs', [ freqs(2) - neighbours, freqs(2) + neighbours ]' ) ]; % each column is the range for one set of frequencies
    
    nu_data = zeros( numel(freqs), tmp(2) - tmp(1) + 1,  size(data, 2), size(data, 3), size(data, 4) );
    % gives a f1|f2 x frequencies x timepoints x trials x channels
    % matrix
    for iFrq = 1:size(tmp, 2)
        nu_data( iFrq, :, :, :, : ) = data( tmp(1, iFrq):tmp(2, iFrq), :, :, : );
    end
    clear tmp
end

% extract the tf data for each condition and frequency, averaging over left
% and right channels, and trials
% ---------------------------------------------------------------------------
events_idx = onsets.cidx; % unique events
events = onsets.condvec;
foi_idx = [1, 2, 2, 1]; % hard coded!
nConds = 4;
if any(lose_dim)
    for iConds = 1:nConds
        % sanity check correct conditions
        cond_dat(iConds).idx = cond_idxs(iConds,:);
        cond_dat(iConds).names = onsets.condvec_label( cond_dat(iConds).idx );
        
        % for each group of electrodes (3 rd dim of chans to average over), average
        % over the relevant channels for those frequencies, given the display
        cond_dat(iConds).l_channel_f1_f1l_dat = mean( mean( squeeze( nu_data( foi_idx(1), :, find(ismember(events, cond_dat(iConds).idx([1, 3]))), chans_to_average(:, 1, 1) ) ), 3 ), 2);
        cond_dat(iConds).r_channel_f2_f1l_dat = mean( mean( squeeze( nu_data( foi_idx(2), :, find(ismember(events, cond_dat(iConds).idx([1, 3]))), chans_to_average(:, 2, 1) ) ), 3 ), 2);
        cond_dat(iConds).l_channel_f2_f2l_dat = mean( mean( squeeze( nu_data( foi_idx(3), :, find(ismember(events, cond_dat(iConds).idx([2, 4]))), chans_to_average(:, 1, 2) ) ), 3 ), 2);
        cond_dat(iConds).r_channel_f1_f2l_dat = mean( mean( squeeze( nu_data( foi_idx(4), :, find(ismember(events, cond_dat(iConds).idx([2, 4]))), chans_to_average(:, 2, 2) ) ), 3 ), 2);
    end
else
    for iConds = 1:nConds
        % sanity check correct conditions
        cond_dat(iConds).idx = cond_idxs(iConds,:);
        cond_dat(iConds).names = onsets.condvec_label( cond_dat(iConds).idx ); 
        % for each group of electrodes (5th dim - chans to average over), average
        % over the relevant channels for the frequencies, given the display
        % ( i.e. get freq x time), the freq dimension has the frequency of
        % interest in the middle
        cond_dat(iConds).l_channel_f1_f1l_dat = mean( mean( squeeze( nu_data( foi_idx(1), :, :, find(ismember(events, cond_dat(iConds).idx([1, 3]))), chans_to_average(:, 1, 1) ) ) , 3 ), 4);
        cond_dat(iConds).r_channel_f2_f1l_dat = mean( mean( squeeze( nu_data( foi_idx(2), :, :, find(ismember(events, cond_dat(iConds).idx([1, 3]))), chans_to_average(:, 2, 1) ) ),  3 ), 4);
        cond_dat(iConds).l_channel_f2_f2l_dat = mean( mean( squeeze( nu_data( foi_idx(3), :, :, find(ismember(events, cond_dat(iConds).idx([2, 4]))), chans_to_average(:, 1, 2) ) ),  3 ), 4); 
        cond_dat(iConds).r_channel_f1_f2l_dat = mean( mean( squeeze( nu_data( foi_idx(4), :, :, find(ismember(events, cond_dat(iConds).idx([2, 4]))), chans_to_average(:, 2, 2) ) ),  3 ), 4);
    end   
end


% now compute the modulation idxs for each frequency, then average over
% frequency, to leave left and right, over time
nIdxs = 3;
idx_names = { 'll_by_hh', 'll_by_lh', 'll_by_hl' };
if any( lose_dim )
    for iIdx = 1:nIdxs
        
        mi(iIdx).names = idx_names( iIdx );
        mi(iIdx).left = mean(  cat(2, ( cond_dat( 1 ).l_channel_f1_f1l_dat - cond_dat( iIdx + 1 ).l_channel_f1_f1l_dat ) ./ ( cond_dat( 1 ).l_channel_f1_f1l_dat + cond_dat( iIdx + 1 ).l_channel_f1_f1l_dat ) , ...
            ( cond_dat( 1 ).l_channel_f2_f2l_dat - cond_dat( iIdx + 1 ).l_channel_f2_f2l_dat ) ./ ( cond_dat( 1 ).l_channel_f2_f2l_dat + cond_dat( iIdx + 1 ).l_channel_f2_f2l_dat ) ), ...
            2 );
        mi(iIdx).right = mean(  cat(2, ( cond_dat( 1 ).r_channel_f1_f2l_dat - cond_dat( iIdx + 1 ).r_channel_f1_f2l_dat ) ./ ( cond_dat( 1 ).r_channel_f1_f2l_dat + cond_dat( iIdx + 1 ).r_channel_f1_f2l_dat ) , ...
            ( cond_dat( 1 ).r_channel_f2_f1l_dat - cond_dat( iIdx + 1 ).r_channel_f2_f1l_dat ) ./ ( cond_dat( 1 ).r_channel_f2_f1l_dat + cond_dat( iIdx + 1 ).r_channel_f2_f1l_dat ) ), ...
            2 );
        
    end
else
    
    for iIdx = 1:nIdxs
        
        mi(iIdx).names = idx_names( iIdx );
        mi(iIdx).left = mean(  cat(3, ( cond_dat( 1 ).l_channel_f1_f1l_dat - cond_dat( iIdx + 1 ).l_channel_f1_f1l_dat ) ./ ( cond_dat( 1 ).l_channel_f1_f1l_dat + cond_dat( iIdx + 1 ).l_channel_f1_f1l_dat ) , ...
            ( cond_dat( 1 ).l_channel_f2_f2l_dat - cond_dat( iIdx + 1 ).l_channel_f2_f2l_dat ) ./ ( cond_dat( 1 ).l_channel_f2_f2l_dat + cond_dat( iIdx + 1 ).l_channel_f2_f2l_dat ) ), ...
            3 );
        mi(iIdx).right = mean(  cat(3, ( cond_dat( 1 ).r_channel_f1_f2l_dat - cond_dat( iIdx + 1 ).r_channel_f1_f2l_dat ) ./ ( cond_dat( 1 ).r_channel_f1_f2l_dat + cond_dat( iIdx + 1 ).r_channel_f1_f2l_dat ) , ...
            ( cond_dat( 1 ).r_channel_f2_f1l_dat - cond_dat( iIdx + 1 ).r_channel_f2_f1l_dat ) ./ ( cond_dat( 1 ).r_channel_f2_f1l_dat + cond_dat( iIdx + 1 ).r_channel_f2_f1l_dat ) ), ...
            3 );
        
    end
   
end


