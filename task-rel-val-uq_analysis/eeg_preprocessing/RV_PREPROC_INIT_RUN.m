% DEPENDENCIES-------------------------------------------------------------
% MATLAB R2017a
% EEGLAB 13.5.4b
% ERPLAB 5.0.0.0
% -------------------------------------------------------------------------

% _________________________________________________________________________
% MANUAL PREPROCESSING REQUIRED POST RUNNING THIS BATCH

% SUBJECT FILES MUST BE IN ANALYSIS/eeg/sub-%d/
%                       ...bdf/ for bdf files
%                       ...set/ for set files
%                       ...log/ for all log files
%                       ...fft/ for fft output
%                       ...tfr/ for tfr output

% PREPARE MAT FILE WITH SUBJECT SPECIFIC DETAILS
% contains
% out.fName_EEG = list of filenames for that participant (cell)
% out.fName_BEH
% out.uniqueEvents = subject specific events
% out.refChan % reference channels for that subject
% out.bChan % vector of bad channels
% out.VEOG % vector of vertical eye channels
% out.HEOG % vector of horizontal eye channels
% out.trigLog % path/filename of trigger log

% save as 'sub-%d/log/sinfo_%d.mat' where %d is the subject number

% BATCH CODE FOR DATA PREP, MERGE & TRIGGER RECODE, & SAVE NEW DATA INTO
% FORMATS FOR ICA FORMAT (i.e. remove bad chans vs interp bad
% chans)
% -------------------------------------------------------------------------

% Copyright (C)2019, K.Garner
% _________________________________________________________________________

clear all
clc

sIDs = [202, 203, 204, 205, 207, 208, 213, 214, 215];

sinfo_FName = 'sinfo_%d.mat'; % make sure behav files is a cell object
% OPTIONS
% -------------------------------------------------------------------------
batch_01 = 0; % prepare_data = 1; 
batch_02 = 0; % merge_data = 1; % 
batch_03 = 0; % adjust markers; % 
batch_04 = 0; % re-ref, epoch data and save AND remove fluctations > +/- 100 mV;
batch_05 = 0; % ICA
batch_06 = 0; % remove ICA components AND baseline correct 
batch_07 = 0; % get pre-target FFT data across scalp - save sub mat file
batch_08 = 0; % get pre-tgt, orthogonal sFFT
batch_09 = 1; % get tf x condition

% SETUP ENVIRONMENT-RELATED VARIABLES
% -------------------------------------------------------------------------
PLACE = 'psych';
for count_subs = 1:length(sIDs)
    
    sID = sIDs(count_subs);
    
switch PLACE
    case 'home'
        
        eeglab
        cPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/eeg_preprocessing';
        bPath = '~/Dropbox/QBI/val-ssvep-UQ/ANALYSIS/';
        dPath = sprintf('~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/eeg/sub-%d', sID); % filepath for data (subject's folder)
        rPath = [dPath '/bdf'];
        sPath = [dPath '/set'];
        lPath = [dPath '/log'];
        oPath = [dPath '/OUT'];
        uPath = 'Utils'; 
        eName = 'Biosemi_64_eeglab_elp_2.ced'; % custom electrode location file made coutesy of intel from SA
        
    case 'QBI'
        
        addpath('~/Documents/MATLAB/eeglab13_6_5b');
        eeglab  
        cPath = '/home/kgarner/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/eeg_preprocessing';
        bPath = '/home/kgarner/Dropbox/QBI/val-ssvep-UQ/ANALYSIS/';
        dPath = sprintf('/home/kgarner/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/eeg/sub-%d', sID);
        rPath = [dPath '/bdf'];
        sPath = [dPath '/set'];
        lPath = [dPath '/log'];
        oPath = [dPath '/OUT'];
        uPath = 'Utils'; 
        eName = 'Biosemi_64_eeglab_elp_2.ced'; % ectrode location file made coutesy of intel from SA
        
    case 'psych'
        eeglab  
        cPath = '/home/kellygarner/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/eeg_preprocessing';
        bPath = '/home/kellygarner/Dropbox/QBI/val-ssvep-UQ/task-rel-uq_analysis/ANALYSIS/';
        dPath = sprintf('/home/kellygarner/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/eeg/sub-%d', sID);
        rPath = [dPath '/bdf'];
        sPath = [dPath '/set'];
        lPath = [dPath '/log'];
        oPath = [dPath '/OUT'];
        uPath = 'Utils'; 
        eName = 'Biosemi_64_eeglab_elp_2.ced'; % ectrode location file made coutesy of intel from SA
        
end

%-------------------------------------------------------------------------

if batch_01
    RV_BATCH_01_PrepareData_RVE1; 
end
            
if batch_02, RV_BATCH_02_MergeData_RVE1; 
end

if batch_03 
    sub_adjusts = [202, 203, 204, 205, 206, 207, 208]; % which subs need the value onset adjusted?
    method = 'freq by conds'; 
    event_of_int = [ 1 2 3 5 ]; RV_BATCH_03_AdjustMarkers_RVE1; 
end

if batch_04
    RV_BATCH_04_SaveData1_RVE1;
end

if batch_05 
    RV_BATCH_05_ICA_RVE1;
end

if batch_06 
    RV_BATCH_06_REMCOMPS_RVE1;
end

if batch_07
    RV_BATCH_07_FFT_RVE1;
end

if batch_08

    RV_BATCH_08_ORTH_TIMEFREQ;    
end

if batch_09
    
    RV_BATCH_09_TIMEFREQ_CONDxELEC;
end

end
