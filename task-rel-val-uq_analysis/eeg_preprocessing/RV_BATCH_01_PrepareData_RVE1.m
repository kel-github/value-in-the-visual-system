% DEPENDENCIES-------------------------------------------------------------
% MATLAB R2017a
% EEGLAB 13.5.4b
% ERPLAB 5.0.0.0
% -------------------------------------------------------------------------

% _________________________________________________________________________
% PREPARE .SET DATA FOR SUBSEQUENT ANALYSIS AND SAVE IN .SET FORMAT
%------------------------------------------------------------------
    % SETUP THE WORKING ENVIRONMENT (VEL, HOME)
    % LOAD sID_info (everything that is subject-dependent)
    % LOAD .bdf DATA
    % Keep Right Mastoid, Left Mastoid, VEOG and
	% average VEOG and subtract HEOG (1-2) -
	% REMOVE EXTRA CHANNELS
	% sub specific
    % CONVERT BIOSEMI TRIGGERS TO NUMERIC: removing trg chan 1
    % ADD CHANNEL LOCATIONS
    % REREFERENCE TO THE AVERAGE
    % FILTER AT 0.01 to remove drift
    % UPDATE FILE INFORMATION
    % SAVE THE MODIFIED DATASET: as p_*.set
% ALL CODE DOUBLE CHECKED - 8th Nov 2017 - KG
%
% Copyright (C)2016, K.Garner, Sara Assecondi
% _________________________________________________________________________

% SETUP ENVIRONMENT-RELATED VARIABLES
% -------------------------------------------------------------------------

%PLACE   = PLACE; % change this so that it reads in sub num from run file
sID     = sID; 



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
VEOG            = out.VEOG;
HEOG            = out.HEOG;

% Set 
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

for iFile = 1:length(fileOrder)
    %[filepath, filename, ext] = fileparts(char(fName_EEG{iFile}));
    
    EDF = openbdf([rPath filesep char(fName_EEG(fileOrder(iFile)).name)]);
    trgChan = EDF.Head.NS; 
    
    % LOAD .bdf DATA
    % ----------------------------------
    EEG = pop_readbdf([rPath filesep char(fName_EEG(fileOrder(iFile)).name)],[],trgChan,refChan,'on');
    EEG = eeg_checkset(EEG);
    
    filename        = fName_EEG(fileOrder(iFile)).name(1:end-4); % remove bdf extension

    EEG.setname     = filename;
    EEG.filepath    = rPath;
    
    % check whether the input-output txt structure exists
    if ~isfield(EEG.etc, 'mycomments'), EEG.etc.mycomments = {};    end
    if ~isfield(EEG.etc, 'intxt'),      EEG.etc.intxt = {};         end
    if ~isfield(EEG.etc, 'outxt'),      EEG.etc.outxt = {};         end
    cmm = [];
    
       % ADD CHANNEL LOCATIONS
    % ----------------------------
    EEG.etc.intxt{end+1} = {fullfile(uPath,eName),'File of channel locations'};
    EEG.etc.outxt{end+1} = {};
    
    EEG = pop_chanedit(EEG,'load',{EEG.etc.intxt{end}{1} 'filetype' 'chanedit'});
    EEG = eeg_checkset(EEG);
    cmm = [cmm;  sprintf('Load channel info from %s\n',EEG.etc.intxt{end}{1})];  
    
    
    % REMOVE EXTRA CHANNELS
    % ------------------------------------
    % Keep Right Mastoid, Left Mastoid, VEOG and HEOG
    labels = {EEG.chanlocs.labels};
    noext_labels = {'EX1', 'EX2'};
    for l = 1:length(noext_labels)
        noext_idx(l) = find(strcmpi(labels,noext_labels{l}));
    end
    unused_idx = noext_idx;
    EEG = pop_select( EEG,'nochannel',labels(unused_idx));
    EEG = eeg_checkset( EEG );
    cmm = [EEG.etc.mycomments; sprintf(['Removed %d unused channels ' repmat('%s\t',1,length(unused_idx))],length(unused_idx),labels{unused_idx})];
        
    clear labels noext_idx   
    
    
    % FILTER AT 0.1 Hz TO REMOVE DRIFT - Itthipuripat et al
    % (https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3652224/) filtered at 2
    % but this attenuates a little frequencies ~5
    % ---------------------------------------
    hif = 0.1;
    ord	= 2;
    EEG  = pop_basicfilter( EEG,  1:EEG.nbchan ,...
        'Boundary', 'boundary',...
        'Cutoff',  hif,...
        'Design', 'butter',...
        'Filter', 'highpass',...
        'Order',  ord );
    EEG = eeg_checkset( EEG );
    cmm = [cmm; sprintf('Highpass filtered at %1.3f Hz, order %d\n',hif,ord)]; 
    
    % BANDPASS FILTER TO REMOVE LINE NOISE
    % ---------------------------------------
    notch = 50;    
    EEG = pop_basicfilter( EEG,  1:EEG.nbchan ,...
        'Cutoff', notch, ...
        'Design', 'notch', ...
        'Filter', 'PMnotch', ...
        'Order',  180 ); % GUI: 30-Oct-2017 11:59:56
    
    EEG = eeg_checkset( EEG );
    cmm = [EEG.etc.mycomments; sprintf('Notch filtered at %1.3f Hz\n', notch)];
    EEG = eeg_checkset(EEG);
    
    % UPDATE FILE INFORMATION
    % -------------------------------------------------
    EEG.etc.mycomments  = [EEG.etc.mycomments; cmm];
    EEG.setname         = filename;
    EEG.filename        = [EEG.setname '.set'];
    EEG.filepath        = sPath;
    EEG                 = eeg_checkset(EEG);
    
    
    % SAVE THE MODIFIED DATASET
    % -------------------------------------------------
    EEG = pop_saveset(EEG,'filename', EEG.filename, 'filepath', EEG.filepath);
    
    clear EEG
    
end