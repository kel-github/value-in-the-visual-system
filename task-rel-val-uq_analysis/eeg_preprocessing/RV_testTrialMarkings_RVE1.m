% CHECK PREVIOUS CODE FOR INCORRECT TRIAL MARKERS
% -------------------------------------------------------------------------

% Copyright (C)2016, K. Garner, 
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
% Loop through single files
% LOAD *.TXT LOGS
% ----------------------------------
% set method for event adjustment - 'cue_cond_by_val_by_freq'
NLogs = length(fName_BEH);
trials = [];

for iLog = 1:NLogs
    theseTrials = AUX_readBEHEventLog(lPath, fName_BEH{iLog}, method);
    trials = [trials theseTrials];
    clear theseTrials
end

% LOAD p_*.SET DATA
% ----------------------------------
filename = sprintf('p_%d.set', sID);
EEG = pop_loadset('filename',filename,'filepath',sPath,'loadmode','all');
EEG = eeg_checkset(EEG);

% check whether the input-output txt structure exists
if ~isfield(EEG.etc, 'mycomments'), EEG.etc.mycomments = {};    end
if ~isfield(EEG.etc, 'intxt'),      EEG.etc.intxt = {};         end
if ~isfield(EEG.etc, 'outxt'),      EEG.etc.outxt = {};         end


% GATHER DATA AND MARKERS INFO
% ----------------------------------
intxt = [];
outxt = fullfile(EEG.filepath, ['00-reportMrk_' EEG.setname '.txt']);
% outxt = satool_ExistFilename(outxt);

EEG.etc.intxt{end+1} = {};
EEG.etc.outxt{end+1} = {outxt,'Summary of EEG markers'};

EEG = satool_EventsInfo(EEG, EEG.etc.outxt{end}{1});


% CONVERT ALL THE TRIGGERS TO NUMERIC
nEvents = length(EEG.event);
for iEv = 1:nEvents
    EEG.event(iEv).type = str2num(EEG.event(iEv).type);
end
  
cmm = [EEG.etc.mycomments; sprintf('Converted all markers to numeric \n')];

trgs = unique([EEG.event.type]);

for i = 1:length(trgs)
    if ~ismember(trgs(i),uniqueEvents)
        EEG = pop_eraseventcodes( EEG,sprintf('==%d',trgs(i)));
    end
end
pop_squeezevents(EEG);
cmm = [cmm; sprintf('Remove ghost triggers different from design \n')];


% CREATE TRUE TRIGGER SEQUENCE FROM log FILES
% --------------------------------------------
allTRG = csvread([lPath '/' trigLog{1}]);
allTRG(allTRG == 0) = [];


% SUB 1442 DID NOT HAVE THE FIRST TRIGS OF BLOCK 12 RECORDED IN THE EEG
% FILE - THEREFORE REMOVING FROM TRIGGER SEQUENCE
if sID == 14421
    
    allTRG(1344:1348) = [];
    trials(336:337) = 999; %%% AS MISSING FROM EEG FILES (MANUAL CHECK IN PREPROCESSING SPREADSHEET - EEG_Val_v1_3)
    cmm = [EEG.etc.mycomments; sprintf('Manually removed 1st 2 trials from block 12 - see notes \n')];
end

% CHECK MARKERS AGAINST TRUE TRIGGER SEQUENCE
% --------------------------------------------
nEvents = length(EEG.event);
nTRGs = length(allTRG);
trash = [];
count = 1;

% THIS CODE IS SPECIFIC TO REL VAL
% REAL EVENTS MUST BE AT LEAST 400 ms APART -
% GHOST TRIGGERS ARE REPETITIONS - SO USING LATENCY TO SEPARATE THEM OUT
val = zeros(1,nEvents);
val(1) = 100; % max latency diff value
evsw = zeros(1,nEvents);
evsw(1) = 1; % possible event differences values - i.e. 1, 2, 3, 4 = 1, 1, 1, 1, -3, (or 2, 4 = 2)
for iEvent = 2:nEvents
    
    thisEvent = EEG.event(iEvent-1).latency;
    nextEvent = EEG.event(iEvent).latency;
    thisEventtype = EEG.event(iEvent-1).type;
    nextEventtype = EEG.event(iEvent).type;
    
    evsw(iEvent) = nextEventtype - thisEventtype;
    val(iEvent) = nextEvent - thisEvent;
end
trash = find(val < 100 & ~ismember(evsw, [-3 1 2]));

% COMPARE TO BE SAFE
Ev = zeros(nEvents, 1);
for iEvent = 1:nEvents
    Ev(iEvent) = EEG.event(iEvent).type;
end
Ev(trash) = [];
check = isequal(allTRG, Ev);
if check
else
    txt = sprintf('trigger sequence does not match events for sub %d', sID);
    error(txt);
end

% SANITY CHECK THAT ALL TRIALS ARE PRESENT
if sum(Ev == 1) < 448 && sID ~= 14421
    txt = sprintf('error! trials missing from eeg event file!');
    error(txt);
end

% SANITY CHECK THAT ALL STIM ON AND FEEDBACKS ARE PRESENT
if sum(Ev == 2) < 448 && sID ~= 14421
    txt = sprintf('error! tgt events missing from eeg event file!');
    error(txt);
elseif sum(Ev == 4) < 448 && sID ~= 14421
    txt = sprintf('error! feedback events missing from eeg event file!');
    error(txt); 
end

