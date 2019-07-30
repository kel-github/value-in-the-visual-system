%%% for each participant, get the MI for value from the value onset period
%%% written by K. Garner, June 2019
%%% (c) free to use and share, please cite and use responsibly

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all

sIDs = [202, 203, 204, 205, 207, 208, 213, 214, 215];

% SETUP ENVIRONMENT-RELATED VARIABLES
% -------------------------------------------------------------------------
PLACE = 'psych';

% allocate matrix to collect subject data
n_mi = 3;
n_cond_dat_by_sub = 2;
n_cond_dat = 4;
hem = 2; % hemispheres
tps = 41;
n_freq = 49; % only if not collapsing frequency dimension, 0 if not
if ~any(n_freq)
    mi_by_sub = zeros( numel( sIDs ), tps, n_mi, hem );
    cond_dat_by_sub = zeros( numel( sIDs ), tps, n_cond_dat, hem );
else
    mi_by_sub = zeros( numel( sIDs ), n_freq, tps, n_mi, hem );
    cond_dat_by_sub = zeros( numel( sIDs ), n_freq, tps, n_cond_dat, hem );    
end

% data filename variables
dat_fName = 'p%d_tfr_allTrials_ValOn_m500to1000_winSize%d';
winSize = 768;

if ~any(n_freq)
    % save_fName
    s_fName = 'p%d_MI_valueOn_m500to1000_winSize%d';
    
    % group data save name
    grps_fName = sprintf('sub%d_to_sub%d_MI_valueOn_m500to1000_winSize%d', sIDs(1), sIDs(end), winSize);
else
    % save_fName
    s_fName = 'p%d_MI_valueOn_m500to1000_allFrq_winSize%d';
    
    % group data save name
    grps_fName = sprintf('sub%d_to_sub%d_MI_valueOn_allFrq_m500to1000_winSize%d', sIDs(1), sIDs(end), winSize);
    
end

% Set variables for MI computations
% -------------------------------------------------------------------------
freqs = [ 16.67, 25 ];
neighbours = 2;
lose_dim = 0; % are you collapsing over the frequency dimension?

% condvec(ismember(epochvect, llf1l_f1tgt'+add)) = 1;
% condvec(ismember(epochvect, llf2l_f2tgt'+add)) = 2;
% condvec(ismember(epochvect, hhf1l_f1tgt'+add)) = 3;
% condvec(ismember(epochvect, hhf2l_f2tgt'+add)) = 4;

% condvec(ismember(epochvect, llf1l_f2tgt'+add)) = 9;
% condvec(ismember(epochvect, llf2l_f1tgt'+add)) = 10;
% condvec(ismember(epochvect, hhf1l_f2tgt'+add)) = 11;
% condvec(ismember(epochvect, hhf2l_f1tgt'+add)) = 12;
% condvec(ismember(epochvect, lhf1l_f1tgt'+add)) = 5; % low left/ high right
% condvec(ismember(epochvect, lhf2l_f2tgt'+add)) = 6; % low left / high right
% condvec(ismember(epochvect, hlf1l_f1tgt'+add)) = 7; % high left / low right
% condvec(ismember(epochvect, hlf2l_f2tgt'+add)) = 8; % high left / low right
% condvec(ismember(epochvect, lhf1l_f2tgt'+add)) = 13; % high left / low right
% condvec(ismember(epochvect, lhf2l_f1tgt'+add)) = 14; % high left / low right
% condvec(ismember(epochvect, hlf1l_f2tgt'+add)) = 15; % low left / high right
% condvec(ismember(epochvect, hlf2l_f1tgt'+add)) = 16; % low left / high right 

cond_idxs = [ 1, 2, 9, 10; ...
              3, 4, 11, 12; ...
              5, 6, 15, 16; ... % f1 left, f2 right / f2 left, f1 right / f1 left, f2 right / f2 left, f1 right
              7, 8, 13, 14 ];   % f1 left, f2 right / f2 left, f1 right / f1 left, f2 right / f2 left, f1 right

chans_to_average = [ 1, 5; ...
                     2, 6; ...
                     3, 7; ...
                     4, 8 ];
chans_to_average( :, :, 2 ) = chans_to_average;

% Collate data
% -------------------------------------------------------------------------
for count_subs = 1:length(sIDs)
    
    sID = sIDs(count_subs);
    
    switch PLACE
        case 'home'
            
            cPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/eeg_hypotheses/fig03_valOn_MI';
            bPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/';
            dPath = sprintf('~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/eeg/sub-%d', sID); % filepath for data (subject's folder)
            tfrPath = 'tfr';
            lPath = [ dPath '/' 'log' ];
            uPath = 'Utils';
            sPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/hypotheses/fig03_valOn_MI';

        case 'QBI'
            
            cPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/eeg_hypotheses/fig03_valOn_MI';
            bPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/';
            dPath = sprintf('~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/eeg/sub-%d', sID); % filepath for data (subject's folder)
            tfrPath = 'tfr';
            lPath = [ dPath '/' 'log' ];
            uPath = 'Utils';
            sPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/hypotheses/fig03_valOn_MI';
            
        case 'psych'
            
            cPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/eeg_hypotheses/fig03_valOn_MI';
            bPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/';
            dPath = sprintf('~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/eeg/sub-%d', sID); % filepath for data (subject's folder)
            tfrPath = 'tfr';
            lPath = [ dPath '/' 'log' ];
            uPath = 'Utils';
            sPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/hypotheses/fig03_valOn_MI';
    end
    

    fName = sprintf( dat_fName, sID, winSize );
    load( [ dPath '/' tfrPath '/' fName ] );
    
    
    % step 1 - for each subject, compute mis and allocate to the sub matrix
    % also save MIs and cond_dat in sub folder
    % --------------------------------------------------------------------------------    
    [ mi, cond_dat ] = get_modulation_pre_tgt_idx( value_onset_dat, freqs, neighbours, cond_idxs, chans_to_average, onsets, lose_dim );
    if any(lose_dim)
        for iCond = 1:n_cond_dat
            
            
            cond_dat_by_sub( count_subs, :, iCond, 1 ) = mean( [cond_dat( iCond ).l_channel_f1_f1l_dat, cond_dat( iCond ).l_channel_f2_f2l_dat ], 2 );
            cond_dat_by_sub( count_subs, :, iCond, 2 ) = mean( [cond_dat( iCond ).r_channel_f2_f1l_dat, cond_dat( iCond ).r_channel_f1_f2l_dat ], 2 );
            
        end
        
        for iMI = 1:n_mi
            for iHem = 1:hem
                
                mi_by_sub( count_subs, :, iMI, 1 ) = mi( iMI ).left;
                mi_by_sub( count_subs, :, iMI, 2 ) = mi( iMI ).right;
            end
        end
    else
        
        for iCond = 1:n_cond_dat
            cond_dat_by_sub( count_subs, :, :, iCond, 1 ) = mean( cat( 3, cond_dat( iCond ).l_channel_f1_f1l_dat, cond_dat( iCond ).l_channel_f2_f2l_dat ), 3 );
            cond_dat_by_sub( count_subs, :, :, iCond, 2 ) = mean( cat( 3, cond_dat( iCond ).r_channel_f2_f1l_dat, cond_dat( iCond ).r_channel_f1_f2l_dat ), 3 );
        end
        for iMI = 1:n_mi
            for iHem = 1:hem
                
                mi_by_sub( count_subs, :, :, iMI, 1 ) = mi( iMI ).left;
                mi_by_sub( count_subs, :, :, iMI, 2 ) = mi( iMI ).right;  
    
            end
        end

    end
    % save the sub data
    fName = sprintf( s_fName, sID, winSize );
    save( [ dPath '/' tfrPath '/' fName ], 'mi', 'cond_dat' );

end

% save multi-subject data
save( [sPath '/' grps_fName], 'mi_by_sub', 'cond_dat_by_sub' );