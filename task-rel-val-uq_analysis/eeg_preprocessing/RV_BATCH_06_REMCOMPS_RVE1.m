% DEPENDENCIES-------------------------------------------------------------
% MATLAB R2016a
% EEGLAB 13.5.4b
% ERPLAB 5.0.0.0
% -------------------------------------------------------------------------

% ______________________________________________________________________
% TAKE ICA WEIGHTS FROM 1HZ FILTERED SET AND APPLY TO .1 FILTERED SET
% -------------------------------------------------------------------------
% LOAD SubjectSpecificVariables (everything that is subject-dependent)
% LOAD (ICA_int_avRef_mnRj_mrk_p_*.set,ICA_int_avRef_mnRj_mrk_p_*.fdt) PREPROCESSED DATA
% SAVE ICA INFO
% LOAD NEW SET (Ep_int_avRef_mnRj_mrk_p_*.set,Ep_int_avRef_mnRj_mrk_p_*.set)
% STORE NEW ICA INFO
% REMOVE SPECIFIED COMPONENTS (out.eyeIC);
% BASELINE -500 ms to 0
% REMOVE FLUCTUATIONS > 120 mV
% SAVE THE MODIFIED DATASET AS (LP_ICARej_int_avRef_mnRj_mrk_p_*.set, LP_ICARej_int_avRef_mnRj_mrk_p_*.fdt)

% Copyright (C)2016, K. Garner
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
remComps        = out.eyeIC;

filename = sprintf('ICA_ManRj_Ep_int_avRef_mrk_p_%d.set', sID);
EEG = pop_loadset('filename',filename,'filepath',sPath,'loadmode','all');
EEG = eeg_checkset(EEG);

% check whether the input-output txt structure exists
if ~isfield(EEG.etc, 'mycomments'), EEG.etc.mycomments = {};    end
if ~isfield(EEG.etc, 'intxt'),      EEG.etc.intxt = {};         end
if ~isfield(EEG.etc, 'outxt'),      EEG.etc.outxt = {};         end

% save ICA relevant info
tmp_sphere = EEG.icasphere;
tmp_weights = EEG.icaweights;
tmp_chans_idx = EEG.icachansind;

clear EEG

% load .1 hz filtered data
filename = sprintf('ManRj_Ep_int_avRef_mrk_p_%d.set', sID);
EEG = pop_loadset('filename',filename,'filepath',sPath,'loadmode','all');
EEG = eeg_checkset(EEG);

% ADD ICA INFO
EEG.icasphere = tmp_sphere;
EEG.icaweights = tmp_weights;
EEG.icachansind = tmp_chans_idx;

EEG = eeg_store([],EEG, CURRENTSET); % UPDATE EEG INFO

% REMOVE COMPONENTS
EEG = eeg_checkset( EEG );
EEG = pop_subcomp( EEG, remComps, 0);
cmm = [EEG.etc.mycomments; sprintf('components removed \n')];

% BASELINE AND REMOVE TRIALS WITH > +100mV DEVIATION FROM THE CHANNELS OF
% INTEREST
% ---------------------------------------------------------------------------
EEG = pop_rmbase( EEG, [-500 0]); 
cmm = [EEG.etc.mycomments; sprintf('Baseline removed pre-trial period \n')];

% REMOVE LARGE VOLTAGE FLUCTUATIONS
threshold = 100;
elecs_of_int = {'P7', 'P5', 'P3', 'P1', 'Pz', 'P2', 'P4', 'P8' ...
                'P9', 'PO7', 'PO3', 'POz' , 'PO4', 'PO8', 'P10', ...
                'O1', 'Oz', 'O2'};
n_elecs      = length(elecs_of_int);
cidx = [];

for i = 1:length(EEG.chanlocs)

    if any(strcmp(EEG.chanlocs(i).labels, elecs_of_int))
        cidx = [cidx i];
    end
end

EEG = pop_eegthresh(EEG, 1, cidx , -threshold, threshold, -1.5, 4.5, 0, 1);                    
cmm = [cmm; sprintf('Epoch rejection %d Hz \n', threshold)];


% GET NUMBER OF TRIALS REMOVED AND SAVE TO SUB LOG
trials_remaining = size(EEG.data, 3);
out.trials_remaining = trials_remaining;
cd(dPath);
save(sprintf([lPath '/' sinfo_FName],sID), 'out');
cd(cPath);

% UPDATE FILE INFORMATION
% -------------------------------------------------
filename = ['BL_ThrRj_ICARej_' filename];
EEG.etc.mycomments  = cmm;
EEG.setname         = filename;
EEG.filename        = EEG.setname;
EEG.filepath        = EEG.filepath;
EEG                 = eeg_checkset(EEG);

% SAVE THE MODIFIED DATASET
% -------------------------------------------------
EEG = pop_saveset(EEG,'filename', EEG.filename, 'filepath', EEG.filepath);

clear EEG