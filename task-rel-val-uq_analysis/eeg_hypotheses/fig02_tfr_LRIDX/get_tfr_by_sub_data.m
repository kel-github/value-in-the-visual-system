%%% for each participant, get the fft power data from the pre-target period
%%% written by K. Garner, June 2019
%%% (c) free to use and share, please cite and use responsibly

sIDs = [202, 204, 205, 207, 208, 213, 214, 215];
% SETUP ENVIRONMENT-RELATED VARIABLES
% -------------------------------------------------------------------------
PLACE = 'QBI';

% Set matrix to load and collate subject variables (hard coded)
winSize = 768;
subs = numel(sIDs);
frqs = 217;
tps  = 200;
chan = 28;
scfg = 2;
tfr_by_sub = zeros( subs, frqs, tps, chan, scfg );

for count_subs = 1:length(sIDs)
    
    sID = sIDs(count_subs);
    
switch PLACE
    case 'home'        
        
        cPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/eeg_hypotheses/fig02_tfr_LRIDX';
        bPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/';
        dPath = sprintf('~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/eeg/sub-%d', sID); % filepath for data (subject's folder)
        tfrPath = 'tfr';
        lPath = [ dPath '/' 'log' ];
        uPath = 'Utils'; 
        sPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/hypotheses/fig02_tfr_LRIDX';
%       don't need the below for data extraction, just for plotting in the next step 
 %       eName    = 'Biosemi_64_eeglab_elp_2.ced'; % custom electrode location file made coutesy of intel from SA
 %       spl_file = 'eyeChanRem_Ep_LP_ICARej_int_avRef_mnRj_mrk_p_13071.spl';
    case 'QBI'
      
        cPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/eeg_hypotheses/fig02_tfr_LRIDX';
        bPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/';
        dPath = sprintf('~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/eeg/sub-%d', sID); % filepath for data (subject's folder)
        tfrPath = 'tfr';
        lPath = [ dPath '/' 'log' ];
        uPath = 'Utils'; 
        sPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/hypotheses/fig02_tfr_LRIDX';
        %eName = 'Biosemi_64_eeglab_elp_2.ced'; % ectrode location file made coutesy of intel from SA
        %spl_file = 'eyeChanRem_Ep_LP_ICARej_int_avRef_mnRj_mrk_p_13071.spl';
    case 'psych'
   
        cPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/eeg_hypotheses/fig02_tfr_LRIDX';
        bPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/';
        dPath = sprintf('~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/eeg/sub-%d', sID); % filepath for data (subject's folder)
        tfrPath = 'tfr';
        lPath = [ dPath '/' 'log' ];
        uPath = ['~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/' 'eeg_preprocessing' '/' 'Utils']; 
        sPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/hypotheses/fig02_tfr_LRIDX'; 
%         eName = 'Biosemi_64_eeglab_elp_2.ced'; % ectrode location file made coutesy of intel from SA        
%         spl_file = 'eyeChanRem_Ep_LP_ICARej_int_avRef_mnRj_mrk_p_13071.spl';
end

    fftName = sprintf('p%d_TFR_winSize%d', sID, winSize);
    load([dPath '/' tfrPath '/' fftName]);
    
    % add sub_pwr = a chan x hz x spatial config matrix, to the overall
    % subject matrix
    tfr_by_sub( count_subs, :, :, :, : ) = sub_tf_data;

end

% save in this format for plotting and transforms
tfrFname = sprintf('RelVal-TFRDat_LR_winSize%d_sub%d-sub%d', winSize, sIDs(1), sIDs(end));
save([sPath '/' tfrFname], 'tfr_by_sub', 'tfr_by_sub', 'hz', 'chan_ord', 't' );