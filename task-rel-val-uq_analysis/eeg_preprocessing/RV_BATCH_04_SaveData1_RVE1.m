% DEPENDENCIES-------------------------------------------------------------
% MATLAB R2017a
% EEGLAB 13.5.4b
% ERPLAB 5.0.0.0
% -------------------------------------------------------------------------

% _________________________________________________________________________
% SAVE DATA, RE-REF TO AVERAGE AND EPOCH
% -------------------------------------------------------------------------
    % LOAD Subject Specific Variables (everything that is subject-dependent)
    % LOAD (mrk_p_*.set, mrk_p_*.fdt) PREPROCESSED DATA
    % RE-REF TO THE AVERAGE
    % INTERP ELECTRODES 
    % EPOCH
    % REMOVE TRIALS W LARGE VOLTAGE FLUCTUATIONS
    % SAVE FOR ICA
    % DBLE CHECKED NOV 2017 & MARCH 2019

% Copyright (C) 2019, K. Garner
% _________________________________________________________________________


% LOAD SUBJECT-RELATED VARIABLES
% -------------------------------------------------------------------------
cd(dPath);
load(sprintf([lPath '/' sinfo_FName],sID));
cd(cPath);
 
% UNPACK SUBJECT-SPECIFIC VARIABLES
fName_EEG       = out.fName_EEG;
fName_BEH       = out.fName_BEH;
uniqueEvents    = out.uniqueEvents;
refChan         = out.refChan;
trigLog         = out.trigLog;
bChan           = out.bChan;

% LOAD p_*.SET DATA
% ----------------------------------
filename = sprintf('mrk_p_%d.set', sID);
EEG = pop_loadset('filename',filename,'filepath',sPath,'loadmode','all');
EEG = eeg_checkset(EEG);

% check whether the input-output txt structure exists
if ~isfield(EEG.etc, 'mycomments'), EEG.etc.mycomments = {};    end
if ~isfield(EEG.etc, 'intxt'),      EEG.etc.intxt = {};         end
if ~isfield(EEG.etc, 'outxt'),      EEG.etc.outxt = {};         end
cmm = EEG.etc.mycomments;

% INTERPOLATE ELECTRODES
% ----------------------------------
if ~isempty(bChan)
    EEG = pop_interp(EEG, bChan, 'spherical');
    cmm = [EEG.etc.mycomments; sprintf('Interped channels \n')];
else
    cmm = [EEG.etc.mycomments; sprintf('No bad channels to interp \n')];
end

% RE-REF TO AVERAGE
% -----------------------------------
EEG = pop_reref( EEG, [], 'exclude', 65:70);
EEG = eeg_checkset( EEG );
cmm = [cmm; sprintf('Refd to average \n')];
filename = sprintf('avRef_mrk_p_%d.set', sID);
    
EEG.etc.mycomments  = [EEG.etc.mycomments; cmm];
EEG.setname         = filename;
EEG.filename        = [EEG.setname];
EEG.filepath        = sPath;
EEG = pop_saveset(EEG,'filename', EEG.filename, 'filepath', EEG.filepath);


% UPDATE FILE INFORMATION
% -------------------------------------------------
filename = ['int_' filename];
EEG.etc.mycomments  = cmm;
EEG.setname         = filename;
EEG.filename        = [EEG.setname];
EEG.filepath        = EEG.filepath;
EEG                 = eeg_checkset(EEG);

% SAVE THE MODIFIED DATASET
% -------------------------------------------------
EEG = eeg_checkset(EEG);
EEG = pop_saveset(EEG,'filename', EEG.filename, 'filepath', EEG.filepath);

% EPOCH DATA  
% -------------------------------------------------------------------------
epoch_length = [-1.5   6.5];
EEG = pop_epoch( EEG, {'111121', '111211', '112121' , '112211' , '121121' , '121211' , '122121' ,   '122211' , '131121', '131211' , '132121' , '132211' , '141121' , '141211',  '142121', '142211'}, epoch_length);
cmm = [EEG.etc.mycomments; sprintf('Epoched %.1f to %.1f \n', epoch_length(1), epoch_length(2))];


% UPDATE FILE INFORMATION
% -------------------------------------------------
filename = ['Ep_' filename];
EEG.etc.mycomments  = cmm;
EEG.setname         = filename;
EEG.filename        = EEG.setname;
EEG.filepath        = EEG.filepath;
EEG                 = eeg_checkset(EEG);

% SAVE THE MODIFIED DATASET
% -------------------------------------------------
EEG = eeg_checkset(EEG);
EEG = pop_saveset(EEG,'filename', EEG.filename, 'filepath', EEG.filepath);

clear EEG

