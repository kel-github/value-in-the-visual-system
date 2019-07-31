% DEPENDENCIES-------------------------------------------------------------
% MATLAB R2017a
% EEGLAB 13.5.4b
% ERPLAB 5.0.0.0
% -------------------------------------------------------------------------

% _________________________________________________________________________
% RECODE MARKERS AND REMOVE GHOST TRIGGERS (FROM BIOSEMI SYSTEM)
% -------------------------------------------------------------------------
    % SETUP THE WORKING ENVIRONMENT (VEL, HOME)
    % LOAD SubjectSpecificVariables (everything that is subject-dependent)
    % LOAD (*.txt) LOG FILES
    % LOAD (p_*.set,p_*.fdt) PREPROCESSED DATA
    % GATHER DATA AND MARKERS INFO
    % CONVERT MARKERS TO NUMERIC TYPE
    % REMOVE TRIGGERS THAT DO NOT BELONG TO THE DATASET
    % CREATE TRUE TRIGGER SEQUENCE FROM log FILES
    % CHECK MARKERS AGAINST TRUE TRIGGER SEQUENCE
    % RECODE RESPONSE MARKERS ACCORDING TO CORRECTNESS
    % GATHER UPDATED DATA AND MARKERS INFO
    % UPDATE FILE INFORMATION
    % SAVE THE MODIFIED DATASET AS (mrk_p_*.set,mrk_p_*.fdt)
    % DOUBLE CHECKED NOV 8th 2017
%
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

if ismember( sID, sub_adjusts )
    fName_ADJ  = out.fName_Ons;
end

% Loop through single files
% LOAD *.TXT LOGS
% ----------------------------------
% set method for event adjustment - 'cue_cond_by_val_by_freq'
method = 'freq by conds';
trials = AUX_readBEHEventLog(lPath, fName_BEH, method); 

% each 8 digit entry to the trials vector equates to:
% 1) cond,  2) tgt_loc, 3) left freq, 4) right freq, 5) resp

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

% tmp bug fix: if the first event has latency less than 2, then get rid of it
for iEv = 1:nEvents
   if EEG.event(iEv).latency < 2 
       
      EEG.event(iEv) = []; 
      break
   end
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
allTRG = csvread( [ lPath '/' trigLog ] );
TRGseq = allTRG(:,2);
TRGseq(TRGseq == 0) = []; % remove absent responses

% CHECK MARKERS AGAINST TRUE TRIGGER SEQUENCE
% --------------------------------------------
nEvents = length(EEG.event);
nTRGs = length(TRGseq);
trash = [];
count = 1;

% THIS CODE IS SPECIFIC TO REL VAL
% REAL EVENTS MUST BE AT LEAST 400 ms APART -
% GHOST TRIGGERS FROM BHAM INCARNATIONS ARE REPETITIONS - SO USING LATENCY TO SEPARATE THEM OUT
val = zeros(1,nEvents);
val(1) = 100; % max latency diff value
evsw = zeros(1,nEvents);
evsw(1) = 1; % possible event differences values - i.e. 1, 2, 3, 4, 5 = 1, 1, 1, 1, -3, (or 2, 4 = 2)
for iEvent = 2:nEvents
    
    thisEvent = EEG.event(iEvent-1).latency;
    nextEvent = EEG.event(iEvent).latency;
    thisEventtype = EEG.event(iEvent-1).type;
    nextEventtype = EEG.event(iEvent).type;
    
    evsw(iEvent) = nextEventtype - thisEventtype;
    val(iEvent) = nextEvent - thisEvent;
end
trash = find(val < 100 & ~ismember(evsw, [-4 1 2]));

% COMPARE TO BE SAFE
Ev = zeros(nEvents, 1);
for iEvent = 1:nEvents
    Ev(iEvent) = EEG.event(iEvent).type;
end
Ev(trash) = [];
check = isequal(TRGseq, Ev);
if check
else
    txt = sprintf('trigger sequence does not match events for sub %d', sID);
    error(txt);
end
% %  
if any(trash)
    EEG = pop_editeventvals(EEG,'delete',trash);
    cmm = [cmm; sprintf('Remove extra ghost triggers different from logs \n')];
end

% IF A SUBJECT WITH VALUE ONSET TIMING ISSUE (see metadatas), LOAD THE
% VALUE ONSET TIMES AND CHANGE WITH TO THE BEHAVIOURALLY RECORDED TIMES
if ismember( sID, sub_adjusts )
    %ons = readmatrix([lPath '/' fName_ADJ])*1000;
    ons = dlmread([lPath '/' fName_ADJ])*1000;
    count = 0;
    for iEvent = 2:nEvents
        
        if EEG.event(iEvent).type == 2
            
            count = count + 1;           
            EEG.event(iEvent).latency = EEG.event(iEvent - 1).latency + ons(count);
        end
    end
    
    pop_squeezevents(EEG);
    EEG = eeg_checkset(EEG,'eventconsistency');
    cmm = [cmm; sprintf('Recode value onsets \n')];
    
    if count ~= 448
        error(sprintf('not all value onsets were found for sub %d!', sID));
    end
    
end


% RECODE TRIGGERS APART FROM RESPONSES
% ---------------------------------------------------
nEV = length(EEG.event);
nInt = length(event_of_int);
nTrials = length(trials);
tmp = zeros(1, nEV);

collate_trls_for_test = zeros(1, nTrials);

for iInt = 1:nInt
    count = 0;
    for iEv = 1:nEV
        
        if EEG.event(iEv).type == event_of_int(iInt)
            count = count+1;
            tmpTrg = num2str(EEG.event(iEv).type);
            if trials(count) ~= 999
                tmpTrg = [num2str(tmpTrg) num2str(trials(count))];
            else
                tmpTrg = num2str(999);
            end
            EEG.event(iEv).type = str2num(tmpTrg);
           
            if event_of_int(iInt) == 1 % collate trials for test
                collate_trls_for_test(count) =  str2num(tmpTrg);
            end
 
        end
    end 
end

% test trials have been correctly allocated
collate_trls_for_test(collate_trls_for_test>999) = collate_trls_for_test(collate_trls_for_test>999)-100000;
check_trls = isequal(collate_trls_for_test, trials);
if check_trls
else
    error(sprintf('trial mismatch for sub %d!', sID));
end
% 
pop_squeezevents(EEG);
EEG = eeg_checkset(EEG,'eventconsistency');
cmm = [cmm; sprintf('Recode response markers \n')];


% RECODE RESPONSE VARIABLES
% ---------------------------------------------------
nEV = length(EEG.event);
count = 0;
for iEv = 1:nEV-1
    
   current_Ev = EEG.event(iEv).type(1);
   next_Ev = EEG.event(iEv+1).type(1);
   
   if  current_Ev > 300000 && current_Ev < 399999 % its a stim onset event
       
       if next_Ev == 4 % then it needs to be recoded as a response variable
           count = count + 1; % sanity check - this happened 417 times, for 13071, as expected
           new_Event = current_Ev + 100000;
           EEG.event(iEv+1).type = new_Event;          
       end
   end
   
   
   
   % if the current event is a 999 and the next a zero, the zero should be
   % recoded as 999
   if current_Ev == 999 
       if next_Ev == 4
           EEG.event(iEv+1).type = 999;
       end
   end
   
end
pop_squeezevents(EEG);
EEG = eeg_checkset(EEG,'eventconsistency');
cmm = [cmm; sprintf('Recode response markers \n')];


% GATHER UPDATED DATA AND MARKERS INFO
% ----------------------------------------
intxt = [];
outxt = fullfile(EEG.filepath, ['00-reportNewMrk_' EEG.setname '.txt']);
%outxt = satool_ExistFilename(outxt);

EEG.etc.intxt{end+1} = {};
EEG.etc.outxt{end+1} = {outxt,'Summary of recoded EEG markers'};

EEG = satool_EventsInfo(EEG,fullfile(EEG.filepath, ['00-reportNewMrk_p_' num2str(sID) '.txt'])); 


% UPDATE FILE INFORMATION
% -------------------------------------------------
EEG.etc.mycomments  = cmm;
EEG.setname         = ['mrk_' filename];
EEG.filename        = [EEG.setname];
EEG.filepath        = sPath;
EEG                 = eeg_checkset(EEG);

% SAVE THE MODIFIED DATASET
% -------------------------------------------------
EEG = pop_saveset(EEG,'filename', EEG.filename, 'filepath', EEG.filepath);

clear EEG
