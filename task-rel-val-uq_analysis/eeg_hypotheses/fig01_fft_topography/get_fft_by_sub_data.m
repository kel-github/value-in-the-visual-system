%%% for each participant, get the fft power data from the pre-target period
%%% written by K. Garner, June 2019
%%% (c) free to use and share, please cite and use responsibly

sIDs = [202, 204, 205, 207, 208, 213, 214, 215];
% SETUP ENVIRONMENT-RELATED VARIABLES
% -------------------------------------------------------------------------
PLACE = 'QBI';

% Set matrix to collate subject variables
subs = numel(sIDs);
chan = 64;
hz   = 2048;
scfg = 2;
raw_fft_by_sub = zeros( subs, chan, hz, scfg );
pwr_fft_by_sub = zeros( subs, chan, hz, scfg );

for count_subs = 1:length(sIDs)
    
    sID = sIDs(count_subs);
    
switch PLACE
    case 'home'        
        
        cPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/eeg_hypotheses/fig01_fft_topography';
        bPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/';
        dPath = sprintf('~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/eeg/sub-%d', sID); % filepath for data (subject's folder)
        fftPath = 'fft';
        uPath    = 'Utils'; 
%       don't need the below for data extraction, just for plotting in the next step 
 %       eName    = 'Biosemi_64_eeglab_elp_2.ced'; % custom electrode location file made coutesy of intel from SA
 %       spl_file = 'eyeChanRem_Ep_LP_ICARej_int_avRef_mnRj_mrk_p_13071.spl';
    case 'QBI'
      
        cPath = '/home/kgarner/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/eeg_hypotheses/fig01_fft_topography';
        bPath = '/home/kgarner/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/';
        dPath = sprintf('/home/kgarner/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/eeg/sub-%d', sID); % filepath for data (subject's folder)
        sPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/hypotheses/fig01_orth_topography/';
        fftPath = 'fft';        
        uPath = 'Utils'; 
        %eName = 'Biosemi_64_eeglab_elp_2.ced'; % ectrode location file made coutesy of intel from SA
        %spl_file = 'eyeChanRem_Ep_LP_ICARej_int_avRef_mnRj_mrk_p_13071.spl';
    case 'psych'
   
        cPath = '/home/kellygarner/Dropbox/task-rel-val-uq_analysis/eeg_hypotheses/step01_fft';
        bPath = '/home/kellygarner/Dropbox/task-rel-val-uq_analysis/ANALYSIS/';
        dPath = sprintf('/home/kgarner/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/eeg/sub-%d', sID); % filepath for data (subject's folder)
        fftPath = 'fft'; 
        uPath = 'Utils'; 
%         eName = 'Biosemi_64_eeglab_elp_2.ced'; % ectrode location file made coutesy of intel from SA        
%         spl_file = 'eyeChanRem_Ep_LP_ICARej_int_avRef_mnRj_mrk_p_13071.spl';
end



    fftName = sprintf('p%d_bl_FFT', sID);
    load([dPath '/' fftPath '/' fftName]);
    
    % add sub_pwr = a chan x hz x spatial config matrix, to the overall
    % subject matrix
    raw_fft_by_sub( count_subs, :, :, : ) = sub_pwr;
    pwr_fft_by_sub( count_subs, :, :, : ) = pwr;
    
end

% save in this format for topo plotting and SNR comps
fftFname = sprintf('RelVal-FFTDat_sub%d-sub%d', sIDs(1), sIDs(end));
save([sPath '/' fftFname], 'raw_fft_by_sub', 'pwr_fft_by_sub', 'hz');