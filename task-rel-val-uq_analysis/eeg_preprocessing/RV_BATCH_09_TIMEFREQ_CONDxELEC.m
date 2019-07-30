% DEPENDENCIES-------------------------------------------------------------
% MATLAB R2017a
% EEGLAB 13.5.4b
% ERPLAB 5.0.0.0
% -------------------------------------------------------------------------

% Copyright (C)2019, K. Garner
% _________________________________________________________________________

% LOAD SUBJECT-RELATED VARIABLES
% -------------------------------------------------------------------------
cd(dPath);
load(sprintf([lPath '/' sinfo_FName],sID));
cd(cPath);

% LOAD PREPROCESSED DATA
% -------------------------------------------------------------------------
fPath = sPath;
filename = sprintf('BL_ThrRj_ICARej_ManRj_Ep_int_avRef_mrk_p_%d.set', sID); 
EEG = pop_loadset('filename',filename,'filepath',fPath,'loadmode','all');
EEG = eeg_checkset(EEG);

% check whether the input-output txt structure exists
if ~isfield(EEG.etc, 'mycomments'), EEG.etc.mycomments = {};    end
if ~isfield(EEG.etc, 'intxt'),      EEG.etc.intxt = {};         end
if ~isfield(EEG.etc, 'outxt'),      EEG.etc.outxt = {};         end

cmm = EEG.etc.mycomments;

% EPOCH BASELINE PLUS FIRST 3 SECONDS OF TRIAL
% -------------------------------------------------------------------------
% ELECTRODES OF INT
elecs_of_int = {'PO7', 'PO3', 'POz' , 'O1', 'Oz', 'O2', 'PO4', 'PO8'};
n_elecs      = length(elecs_of_int);
chan_idx = [];
chan_ord = cell(1, length(elecs_of_int));
count_chan_ord = 0;
for i = 1:length(EEG.chanlocs)

    if any(strcmp(EEG.chanlocs(i).labels, elecs_of_int))
        chan_idx = [chan_idx i];
        count_chan_ord = count_chan_ord + 1;
        chan_ord{count_chan_ord} = EEG.chanlocs(i).labels;
    end
end

% DEFINE CONDITION MARKERS 
% _________________________________________________________________________

% 1) event, 2) cond, 3) tgt_loc, 4) left freq, 5) right freq, 6) resp

% RELATIVE VALUE CONTRAST 
% -------------------------------------------------------------------------
% keep left and right target conditions in separate blocks for now
llf1l_f1tgt = 111121; % tgt on the left
llf2l_f2tgt = 111211;
hhf1l_f1tgt = 121121; 
hhf2l_f2tgt = 121211;
lhf1l_f1tgt = 131121; 
lhf2l_f2tgt = 131211;
hlf1l_f1tgt = 141121; 
hlf2l_f2tgt = 141211;

llf1l_f2tgt = 112121; % tgt on the right
llf2l_f1tgt = 112211;
hhf1l_f2tgt = 122121; 
hhf2l_f1tgt = 122211;
lhf1l_f2tgt = 132121; 
lhf2l_f1tgt = 132211;
hlf1l_f2tgt = 142121; 
hlf2l_f1tgt = 142211;


all_conds = [ llf1l_f1tgt, llf2l_f2tgt, ...
              hhf1l_f1tgt, hhf2l_f2tgt, ...
              lhf1l_f1tgt, lhf2l_f2tgt, ...
              hlf1l_f1tgt, hlf2l_f2tgt, ... 
              llf1l_f2tgt, llf2l_f1tgt, ...
              hhf1l_f2tgt, hhf2l_f1tgt, ...
              lhf1l_f2tgt, lhf2l_f1tgt, ...
              hlf1l_f2tgt, hlf2l_f1tgt ];

% find which epochs contain which markers
[epochvect, value_ons, trgt_ons, rt_ons, feedback_ons, RT_lats] = deal(zeros(1,EEG.trials)); % trial vector for each epoch (val on [2], tgt on [3], resp [4], feed on [5])
n_epochs = 1; % can change later if needed
start_trg = 1;
value_trg = 2;
trgt_trg  = 3;
resp_trg  = 4;
feed_trg  = 5;

time.pre_feed = 1.5*1000; % convert to ms
t = 1; % which event label do you want from the event structure for each epoch? 1 | 2 | 3 | 4 | 5

for i=1:EEG.trials

    % THIS CODE IS PRETTY UGLY BUT WORKS
    % LOOPS THROUGH ALL TRIALS, CHECKS ALL EVENTS ARE THERE, AND ALLOCATES
    % THE CONDITION TO THE EPOCHVECT, AND THE ONSETS OF THE EVENTS TO THE
    % RESPECTIVE VECTORS
    %%%%% get condition labels
    if length(EEG.epoch(i).eventtype) >= 4 %5 % if we have all the events in that trial
        % check its the 5 events we want
        if ismember(EEG.epoch(i).eventtype{start_trg}, all_conds) && ...
           ismember(EEG.epoch(i).eventtype{value_trg}, all_conds + 100000) && ...
           ismember(EEG.epoch(i).eventtype{trgt_trg},  all_conds + 200000)  && ...
           ismember(EEG.epoch(i).eventtype{resp_trg},  all_conds + 300000)  && ...
           ismember(EEG.epoch(i).eventtype{feed_trg},  all_conds + 400000)
            epochvect(i)    = EEG.epoch(i).eventtype{t};
            value_ons(i)    = EEG.epoch(i).eventlatency{value_trg};
            trgt_ons(i)     = EEG.epoch(i).eventlatency{trgt_trg};
            rt_ons(i)       = EEG.epoch(i).eventlatency{resp_trg};
            %feedback_ons(i) = EEG.epoch(i).eventlatency{resp_trg} + time.pre_feed; %FOR TESTING, DELETE FOR USE
            feedback_ons(i) = EEG.epoch(i).eventlatency{feed_trg};
            RT_lats(i)      = EEG.epoch(i).eventlatency{resp_trg} - EEG.epoch(i).eventlatency{trgt_trg};
            % is the trial possible given task timings?
            if diff([rt_ons(i) feedback_ons(i)]) < time.pre_feed % || % ep3_ons(i) < time.pre_feed 
                epochvect(i)    = NaN;
                value_ons(i)    = NaN;
                trgt_ons(i)     = NaN;
                rt_ons(i)       = NaN;
                feedback_ons(i) = NaN;
                RT_lats(i)      = NaN;
            end
        else
            epochvect(i)    = NaN;
            value_ons(i)    = NaN;
            trgt_ons(i)     = NaN;
            rt_ons(i)       = NaN;
            feedback_ons(i) = NaN;
            RT_lats(i)      = NaN;
        end
    else
        
        epochvect(i)    = NaN;
        value_ons(i)    = NaN;
        trgt_ons(i)     = NaN;
        rt_ons(i)       = NaN;
        feedback_ons(i) = NaN;
        RT_lats(i)      = NaN;
        
    end
end

onsets.epochvect    = epochvect;
onsets.value_ons    = value_ons;
onsets.trgt_ons     = trgt_ons;
onsets.rt_ons       = rt_ons;
onsets.feedback_ons = feedback_ons;

% save RT latencies to sub info
cd(dPath);
load(sprintf([lPath '/' sinfo_FName],sID));
out.RT_lats = RT_lats;
save(sprintf([lPath '/' sinfo_FName],sID), 'out');
cd(cPath);

% make the condition vector
% could have done this more succinctly, but wanted to spell it out to make
% clear visually whether have covered all the conditions correctly
add = 0; % adjust this if want to extract epoch centred on a different event
condvec = zeros(1,EEG.trials);
condvec(ismember(epochvect, llf1l_f1tgt'+add)) = 1;
condvec(ismember(epochvect, llf2l_f2tgt'+add)) = 2;
condvec(ismember(epochvect, hhf1l_f1tgt'+add)) = 3;
condvec(ismember(epochvect, hhf2l_f2tgt'+add)) = 4;
condvec(ismember(epochvect, lhf1l_f1tgt'+add)) = 5;
condvec(ismember(epochvect, lhf2l_f2tgt'+add)) = 6;
condvec(ismember(epochvect, hlf1l_f1tgt'+add)) = 7;
condvec(ismember(epochvect, hlf2l_f2tgt'+add)) = 8;

condvec(ismember(epochvect, llf1l_f2tgt'+add)) = 9;
condvec(ismember(epochvect, llf2l_f1tgt'+add)) = 10;
condvec(ismember(epochvect, hhf1l_f2tgt'+add)) = 11;
condvec(ismember(epochvect, hhf2l_f1tgt'+add)) = 12;
condvec(ismember(epochvect, lhf1l_f2tgt'+add)) = 13;
condvec(ismember(epochvect, lhf2l_f1tgt'+add)) = 14;
condvec(ismember(epochvect, hlf1l_f2tgt'+add)) = 15;
condvec(ismember(epochvect, hlf2l_f1tgt'+add)) = 16;

% save UPDATED condvec to sub info
cd(dPath);
load(sprintf([lPath '/' sinfo_FName],sID));
out.cond = condvec;
save(sprintf([lPath '/' sinfo_FName],sID), 'out');
cd(cPath);

% save condvec to onsets
onsets.condvec = condvec;
onsets.condvec_label = {'llf1l_f1tgt', 'llf2l_f2tgt', 'hhf1l_f1tgt', 'hhf2l_f2tgt', ... 
                        'lhf1l_f1tgt', 'lhf2l_f2tgt', 'hlf1l_f1tgt', 'hlf2l_f2tgt', ...
                        'llf1l_f2tgt', 'llf2l_f1tgt', 'hhf1l_f2tgt', 'hhf2l_f1tgt', ...
                        'lhf1l_f2tgt', 'lhf2l_f1tgt', 'hlf1l_f2tgt', 'hlf2l_f1tgt'};
% DEFINE TIMEPOINTS AND SAVE FOR SUBSEQUENT DATA EXTRACTION
% baseline, value on, target on, up to response, up to feedback
onsets.epoch_tidxs= [-550 -50; -500 1000; -500 1000; -1500 0; -1500 0]; % ONLY 1st ONE REQUIRES INTERVALS FOR NOW

% NOW DO TIME/FREQ ANALYSIS OF EVERY TRIAL, 
% SAVE WITH ONSET & CONDITION INFO 

% GET DATA FOR EPOCH (WHOLE TRIAL)
% -------------------------------------------------------------------------
cidx = unique(condvec);
cidx = cidx(cidx > 0 & cidx < 999);
onsets.cidx = cidx;
onsets.condvec = condvec;

% COMPUTE sFFT w HANNING TAPER
% -------------------------------------------------------------------------------------------------------------------------------------------
tf.tlimits   = [EEG.xmin EEG.xmax]*1000;
tf.frames    = EEG.pnts;
tf.winSize   = 768; % temporal window size in samples
tf.srate     = EEG.srate;
tf.freq_rng  = [8 45]; % range of frequencies to compute
tf.cycles    = 0; % wavelet cycle
tf.detrend   = 'off'; % have already baseline corrected in temporal domain
tf.baseline  =  NaN;
tf.basenorm  = 'off';
tf.plotersp  = 'off';
tf.plotitc   = 'off';
tf.plotphase = 'off';
tf.padratio  = 16;
tf.scale     = 'abs';

data   = EEG.data;
clear EEG.data;
nfrq   = length(tf.freq_rng(1): ((tf.srate/tf.winSize) / tf.padratio) : tf.freq_rng(2) );
ntp    = 200; % dbl check this
ntrls  = size(EEG.data, 3);
nchans = length(chan_idx);

tf_dat = zeros(nfrq, ntp, ntrls, nchans);

for iChan = 1:nchans
    [times, freqs,tf_dat(:, :, :, iChan)] = get_time_freq(data(chan_idx(iChan),:,:), tf);
end

% now save time frequency data in the freq x tp x ttrls x tchans, 
% also save condvec, epoch tidxs, 
onsets.freqs = freqs;
onsets.times = times;

tf_dir = [dPath '/' 'tfr'];
if ~exist(tf_dir, 'dir')
    mkdir(tf_dir)
end
fname = sprintf('p%d_tfr_allTrials_winSize%d', sID, tf.winSize);
save( [tf_dir '/' fname], 'tf_dat', 'chan_ord', 'onsets', '-v7.3');

% now extract data from the epochs of interest and save those
value_onset_dat = get_epochs( tf_dat, onsets.value_ons, 1:size(onsets.value_ons, 2), onsets.epoch_tidxs(2, :), onsets.times );
fname = sprintf('p%d_tfr_allTrials_ValOn_m500to1000_winSize%d', sID, tf.winSize);
save( [tf_dir '/' fname], 'value_onset_dat', 'chan_ord', 'onsets', '-v7.3');
clear value_onset_dat

tgt_onset_dat = get_epochs( tf_dat, onsets.trgt_ons,  1:size(onsets.trgt_ons, 2), onsets.epoch_tidxs(3, :), onsets.times );
fname = sprintf('p%d_tfr_allTrials_TgtOn_m500to1000_winSize%d', sID, tf.winSize);
save( [tf_dir '/' fname], 'tgt_onset_dat', 'chan_ord', 'onsets', '-v7.3');
clear tgt_onset_dat

resp_onset_dat = get_epochs( tf_dat, onsets.rt_ons, 1:size(onsets.rt_ons, 2), onsets.epoch_tidxs(4, :), onsets.times );
fname = sprintf('p%d_tfr_allTrials_RespOn_m1500to0_winSize%d', sID, tf.winSize);
save( [tf_dir '/' fname], 'resp_onset_dat', 'chan_ord', 'onsets', '-v7.3');
clear resp_onset_dat

feed_onset_dat = get_epochs( tf_dat, onsets.feedback_ons, 1:size(onsets.feedback_ons, 2), onsets.epoch_tidxs(5, :), onsets.times );
fname = sprintf('p%d_tfr_allTrials_FeedOn_m1500to0_winSize%d', sID, tf.winSize);
save( [tf_dir '/' fname], 'feed_onset_dat', 'chan_ord', 'onsets', '-v7.3');
clear feed_onset_dat

clear EEG tf_dat *_onset_dat 

