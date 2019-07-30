% DEPENDENCIES-------------------------------------------------------------
% MATLAB R2017a
% EEGLAB 13.5.4b
% ERPLAB 5.0.0.0
% EYECATCH 
% -------------------------------------------------------------------------

% ______________________________________________________________________
% RECODE MARKERS AND REMOVE GHOST TRIGGERS (FROM BIOSEMI SYSTEM)
% -------------------------------------------------------------------------
    % SETUP THE WORKING ENVIRONMENT (VEL, PBIC, HOME)
    % LOAD SubjectSpecificVariables (everything that is subject-dependent)
    % LOAD (p_*.set,p_*.fdt) PREPROCESSED DATA
    % FILTER FOR ICA (HIGHPASS 1HZ)
    % RUN ICA 
    % DETECT AND PLOT EYE BLINK COMPONENTS - SAVE 
    % DBLE CHECKED NOV 2017
%
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
redRank         = out.bChan;
if ~any(redRank)
    rank = 63;
else
    rank = 63 - length(redRank);
end


filename = sprintf('ManRj_Ep_int_avRef_mrk_p_%d.set', sID);
EEG = pop_loadset('filename',filename,'filepath',sPath,'loadmode','all');
EEG = eeg_checkset(EEG);


% check whether the input-output txt structure exists
if ~isfield(EEG.etc, 'mycomments'), EEG.etc.mycomments = {};    end
if ~isfield(EEG.etc, 'intxt'),      EEG.etc.intxt = {};         end
if ~isfield(EEG.etc, 'outxt'),      EEG.etc.outxt = {};         end


% FILTER AT 1.0 Hz TO REMOVE DRIFT (FOR ICA)
% ---------------------------------------
hif = 1.0;
ord	= 2;

EEG  = pop_basicfilter( EEG,  1:EEG.nbchan ,...
    'Boundary', 'off',...
    'Cutoff',  hif,...
    'Design', 'butter',...
    'Filter', 'highpass',...
    'Order',  ord );
EEG = eeg_checkset( EEG );
cmm = [EEG.etc.mycomments; sprintf('Highpass filtered for ICA at %1.3f Hz, order %d\n',hif,ord)];

% RUN ICA
% -------------------------------------------------
EEG = pop_runica(EEG, 'chanind', 1:64, 'pca', rank);
EEG = eeg_checkset( EEG );
cmm = [EEG.etc.mycomments; sprintf('Binica ICA \n')];


% UPDATE FILE INFORMATION
% -------------------------------------------------
filename = ['ICA_' filename];
EEG.etc.mycomments  = [EEG.etc.mycomments; cmm];
EEG.setname         = filename;
EEG.filename        = [EEG.setname];
EEG.filepath        = EEG.filepath;

% SAVE THE MODIFIED DATASET
% -------------------------------------------------
EEG                 = eeg_checkset(EEG);
EEG = pop_saveset(EEG,'filename', EEG.filename, 'filepath', EEG.filepath);

% DETECT EYEBLINK ICAS, PLOT AND SAVE TO SUBJECT STRUCTURE
% ---------------------------------------------------
eyeDetector = pr.eyeCatch;
[eyeIC, similarity, scalpmapObj] = eyeDetector.detectFromEEG(EEG);
out.eyeIC = eyeIC; % save eye IC's to sub struct, save file
save(sprintf([lPath '/' sinfo_FName],sID), 'out');

scalpmapObj.plot(eyeIC); % plot eye ICs
% save plot
plot_fname = sprintf([lPath '/s%d_eyeComps.png'], sID);
saveas(gcf, plot_fname);

clear EEG