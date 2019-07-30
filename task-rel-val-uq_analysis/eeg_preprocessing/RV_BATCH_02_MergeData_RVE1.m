% DEPENDENCIES-------------------------------------------------------------
% MATLAB R2016a
% EEGLAB 13.5.4b
% ERPLAB 5.0.0.0
% -------------------------------------------------------------------------

% _________________________________________________________________________
% MERGE .SET DATA IN ONE SINGLE FILE FOR EACH SUBJECT AND SAVE IN .SET FORMAT
% -------------------------------------------------------------------------
    % SETUP THE WORKING ENVIRONMENT (VEL, PBIC, HOME)
    % LOAD sID_info (everything that is subject-dependent)
    % LOAD (p_*.set,p_*.fdt) PREPROCESSED DATA
	% MERGE BLOCKS INTO A SINGLE FILE
    % CONVERT BOUNDARY EVENTS TO NUMERIC -99
    % UPDATE FILE INFORMATION
    % SAVE THE MODIFIED DATASET
%
% Copyright (C)2016, K. Garner, Sara Assecondi
% _________________________________________________________________________

% SETUP ENVIRONMENT-RELATED VARIABLES
sID = sID;

% LOAD SUBJECT-RELATED VARIABLES
% -------------------------------------------------------------------------
cd(dPath);
load(sprintf([lPath '/' sinfo_FName],sID));
cd(cPath);

% UNPACK SUBJECT-SPECIFIC VARIABLES
fName_EEG       = out.fName_EEG;

% Loop through single files
% -------------------------------------------------------------------------
NFiles = length(fName_EEG);  
% Put files in order
fileOrder = zeros(1,4);
for iFile = 1:NFiles
    
    if strcmp('b01_04', fName_EEG(iFile).name(end-9:end-4))
        fileOrder(1) = iFile;
    elseif strcmp('b05_08', fName_EEG(iFile).name(end-9:end-4))
        fileOrder(2) = iFile;
    elseif strcmp('b09_12', fName_EEG(iFile).name(end-9:end-4))
        fileOrder(3) = iFile;
    elseif strcmp('b13_16', fName_EEG(iFile).name(end-9:end-4))
        fileOrder(4) = iFile;
    end

end
if any(sum(fileOrder == 0))
    error(sprintf('file detection issue for sub %d!', sID));
end

idx = fileOrder;
fName_EEG       = fName_EEG(idx); % just make sure files are listed in correct order
fName_BEH       = out.fName_BEH;
uniqueEvents    = out.uniqueEvents;
refChan         = out.refChan;

% Loop through single files
NFiles = length(fName_EEG);   
for iFile = 1:NFiles
    %[filepath, filename, ext] = fileparts(char(files{iFile}));
    filename        = fName_EEG(iFile).name(1:end-4);

    % LOAD p_*.SET DATA
    % ----------------------------------
    EEGout = pop_loadset('filename',[filename '.set'],'filepath',sPath,'loadmode','all');
    EEGout = eeg_checkset(EEGout);
    EEGout = eeg_checkset(EEGout,'eventconsistency');
    
    % REMOVE DATA OUTSIDE BEGIN AND END OF BLOCKS 
    [ALLEEG,EEG] = eeg_store(ALLEEG,EEGout,iFile);
    clear EEGout  
end

% check whether the input-output txt structure exists
if ~isfield(EEG.etc, 'mycomments'), EEG.etc.mycomments = {};    end
if ~isfield(EEG.etc, 'intxt'),      EEG.etc.intxt = {};         end
if ~isfield(EEG.etc, 'outxt'),      EEG.etc.outxt = {};         end

EEG = pop_mergeset(ALLEEG, [1:NFiles], 0);
cmm = [EEG.etc.mycomments; sprintf('Combined single files into one subject file \n')];

% CONVERT BOUNDARY EVENTS TO NUMERIC -99
% ---------------------------------------
bev = find(strcmp('boundary',{EEG.event.type}));
for iEv = 1:length(bev)
    EEG.event(bev(iEv)).type = '-99';
end
EEG = eeg_checkset(EEG,'eventconsistency');
cmm = [cmm; sprintf('Convert boundary events into numeric -99 \n')];

% UPDATE FILE INFORMATION
% -------------------------------------------------
EEG.etc.mycomments  = cmm;
EEG.setname         = sprintf('p_%d', sID);
EEG.filename        = [EEG.setname '.set'];
EEG.filepath        = sPath;
EEG                 = eeg_checkset(EEG);

% SAVE THE MODIFIED DATASET
% -------------------------------------------------
EEG = pop_saveset(EEG,'filename', EEG.filename, 'filepath', EEG.filepath);

clear EEG