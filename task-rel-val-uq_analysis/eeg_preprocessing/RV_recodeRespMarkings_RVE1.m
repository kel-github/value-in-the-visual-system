
% DEPENDENCIES-------------------------------------------------------------
% MATLAB R2016a
% EEGLAB 13.5.4b
% ERPLAB 5.0.0.0
% -------------------------------------------------------------------------

% _________________________________________________________________________
% RECODE RESPONSE MARKERS (AFTER BUG SPOTTED)
% -------------------------------------------------------------------------
    % SETUP THE WORKING ENVIRONMENT (VEL, HOME)
    % LOAD SubjectSpecificVariables (everything that is subject-dependent)
    % LOAD (mnRj_p_*.set,mnRj_p_*.fdt) PREPROCESSED DATA
    % RECODE RESPONSE MARKERS
    % SAVE FILE AS test_ (for now)
%
% Copyright (C)2016, K. Garner, Sara Assecondi
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
bChan           = out.bchan;

% LOAD p_*.SET DATA
% ----------------------------------
filename = sprintf('mnRj_mrk_p_%d.set', sID);
EEG = pop_loadset('filename',filename,'filepath',sPath,'loadmode','all');
EEG = eeg_checkset(EEG);

% check whether the input-output txt structure exists
if ~isfield(EEG.etc, 'mycomments'), EEG.etc.mycomments = {};    end
if ~isfield(EEG.etc, 'intxt'),      EEG.etc.intxt = {};         end
if ~isfield(EEG.etc, 'outxt'),      EEG.etc.outxt = {};         end

cmm = EEG.etc.mycomments;

% RECODE RESPONSE VARIABLES
% ---------------------------------------------------
nEV = length(EEG.event);

for iEv = 1:nEV-1
    
    current_Ev = str2num( EEG.event(iEv).type );
    next_Ev = str2num( EEG.event(iEv+1).type );
    
    if ~any(current_Ev)
        current_Ev = 999;
    end
    
    if ~any(next_Ev)
        next_Ev = 999;
    end
    
    if  current_Ev > 200000000 && current_Ev < 299999999 % its a stim onset event
        
        if next_Ev == 999 % then it needs to be recoded as a response variable
            
            new_Event = num2str(current_Ev + 100000000);
            EEG.event(iEv+1).type = new_Event;
        elseif next_Ev > current_Ev && next_Ev < 400000000
            
            new_Event = num2str(current_Ev + 100000000);
            EEG.event(iEv+1).type = new_Event;
        end
    elseif current_Ev == 999
        
        if next_Ev > 300000000 && next_Ev < 399999999 % get rid of incorrect responses
            
            new_Event = num2str(999);
            EEG.event(iEv+1).type = new_Event;
        end    
    end

end
pop_squeezevents(EEG);
EEG = eeg_checkset(EEG,'eventconsistency');
cmm = [cmm; sprintf('Recode response markers \n')];


% UPDATE FILE INFORMATION
% -------------------------------------------------
EEG.etc.mycomments  = cmm;
EEG.setname         = filename;
EEG.filename        = [EEG.setname];
EEG.filepath        = EEG.filepath;

% SAVE THE MODIFIED DATASET
% -------------------------------------------------
EEG = eeg_checkset(EEG);
EEG = pop_saveset(EEG,'filename', EEG.filename, 'filepath', EEG.filepath);

