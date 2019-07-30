% DEPENDENCIES-------------------------------------------------------------
% MATLAB R2017a
% EEGLAB 13.5.4b
% ERPLAB 5.0.0.0
% -------------------------------------------------------------------------

% _________________________________________________________________________
% PERFORM ORTHOG FFT
% -------------------------------------------------------------------------
% - LOAD (BL_ThrRj_ICARej_Ep_int_avRef_mrk_p_%d.set, BL_ThrRj_ICARej_Ep_int_avRef_mrk_p_%d.fdt) PREPROCESSED DATA
% - REMOVE HEOG/VEOG CHANNELS
% - GET DATA FOR EPOCH OF INTEREST  - INIT PERIOD (1000 to 2500ms) REL TO TRIAL ONSET; 
% - CALC TIME/FREQ FOR F1 LEFT (F1, F2)
% - PERFORM SAME FOR F2 LEFT

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

% REMOVE HEOG/VEOG CHANNELS
% -------------------------------------------------------------------------
[chans, ~, ~] = size(EEG.data);
eye_chan_idx = chans-5: chans;
EEG = pop_select( EEG, 'nochannel', eye_chan_idx );
cmm = [cmm; sprintf('Removed eye channels \n')];

[chans, ~, ~] = size(EEG.data); % NEW CHANNEL REF

% ORGANISE EPOCHS OF INTEREST
% 1) event, 2) cond, 3) tgt_loc, 4) left freq, 5) right freq, 6) resp

f1lf2r = [ 111121; ...
           112121; ...
           121121; ...
           122121; ...
           131121; ...
           132121; ...
           141121; ...
           142121 ];
           
f2lf1r = [ 111211; ...
           112211; ...
           121211; ...
           122211; ...
           131211; ...
           132211; ...
           141211; ...
           142211 ];

% find which epochs contain which markers
epochvect = zeros(1,EEG.trials); % trial vector
t = 1; % event to mark from
for i=1:EEG.trials
   
    if length(EEG.epoch(i).eventtype) == 5 % if we have all the events in that trial % NEED TO DOUBLE CHECK THIS WORKS OK
        epochvect(i) = EEG.epoch(i).eventtype{t};
    end
end

% now divide into freq by location conditions
condvec = zeros(1,EEG.trials);
add = 0; % add values if you want to index 1st or 2nd or 3rd event and so on
for i = 1:EEG.trials
    
    for j = 1:length(f1lf2r)
        if epochvect(i) == f1lf2r(j)+add
            condvec(i) = 1;
            break
        end
    end
    
    if condvec(i) == 1
    else
        for j = 1:length(f2lf1r)
            if epochvect(i) == f2lf1r(j)+add
                condvec(i) = 2;
                break
            end
        end
    end
end


% - GET DATA FOR EPOCH OF INTEREST  - INIT PERIOD (1000 to 2500ms) REL TO TRIAL ONSET; 
% -------------------------------------------------------------------------
epoch_length = [-1.5   3.5];
EEG = pop_epoch( EEG, {'111121', '111211', '112121' , '112211' , '121121' , '121211' , '122121' ,   '122211' , '131121', '131211' , '132121' , '132211' , '141121' , '141211',  '142121', '142211'}, epoch_length);
cmm = [EEG.etc.mycomments; sprintf('Epoched %.1f to %.1f \n', epoch_length(1), epoch_length(2))];

epoch_tidxs = [ -1051 -51; 1000 2500 ]; 
bl_tidx     = dsearchn( EEG.times', epoch_tidxs(1,:)' ); 
%datfin      = dsearchn( EEG.times', epoch_tidxs(2,2)' );

% GET ELECTRODES OF INTEREST
% -------------------------------------------------------------------------
% ELECTRODES OF INT
elecs_of_int = {'TP7', 'CP5', 'CP3', 'CP1', 'CPz', 'CP2', 'CP4', 'CP6', 'TP8', ...
                'P7', 'P5', 'P3', 'P1', 'Pz', 'P2', 'P4', 'P6', 'P8' ...
                'P9', 'PO7', 'PO3', 'POz' , 'PO4', 'PO8', 'P10', ...
                'O1', 'Oz', 'O2'};
n_elecs      = length(elecs_of_int);
cidx = [];
chan_ord = cell(1, n_elecs);
count_chan_ord = 0;
for i = 1:length(EEG.chanlocs)

    if any(strcmp(EEG.chanlocs(i).labels, elecs_of_int))
        cidx = [cidx i];
        count_chan_ord = count_chan_ord + 1;
        chan_ord{count_chan_ord} = EEG.chanlocs(i).labels;
    end
end

% COMPUTE sFFT w HANNING TAPER
% -------------------------------------------------------------------------
tlimits   = [EEG.xmin EEG.xmax]*1000;
frames    = EEG.pnts;
winSize   = 768; % temporal window size in samples
srate     = EEG.srate;
freq_rng  = [12 30]; % range of frequencies to compute
cycles    = 0; % wavelet cycle
detrend   = 'off'; % have already baseline corrected in temporal domain
baseline  =  epoch_tidxs(1, :);
basenorm  = 'on';
plotersp  = 'on';
plotitc   = 'off';
plotphase = 'off';
padratio  = 16;
scale     = 'abs';

chan_lidx     = [ 12, 16 ]; % for breaking down plots (start idx for central and right electrodes from chan ord)
sub_plot_vect = [ 1:3:(12*3), 2:3:(4*3), 3:3:(3*12) ]; % specific to electrodes chosen, choose this hard coding for yourself
hz_idx        = [ 16, 25 ]; 

nfrq         = length(freq_rng(1): ((srate/winSize) / padratio) : freq_rng(2) );
nTps          = 200; % eeglab default
sub_tf_data   = zeros( nfrq, nTps, length( cidx ), max( condvec ) );

for iCond = 1:max(condvec)
    
    clf;
    figure;
    count_plots = 0;
    for iChan = 1:length(cidx)
        
        count_plots = count_plots + 1;
        
        subplot( min(chan_lidx), size(chan_lidx, 2) + 1, sub_plot_vect( count_plots ) );
        
        [ersp, itc, powbase, times, freqs, ~, ~, tfdata] = newtimef( EEG.data( cidx(iChan), :, condvec == iCond ), ...
            frames,...
            tlimits,...
            srate,...
            cycles,...
            'detrend', detrend,...
            'baseline', baseline', ...
            'winsize', winSize, ...
            'freqs', freq_rng, ...
            'basenorm', basenorm, ...
            'plotersp', plotersp, ...
            'plotitc', plotitc, ...
            'plotphase', plotphase, ...
            'padratio', padratio, ...
            'scale', scale );
     
        title( chan_ord{ iChan } );
     
        if iChan > 1
          
            xlabel('');
            ylabel('');
           % set(gca, 'YTickLabel', [], 'XTickLabel', []);
        end
        
        % save data to matrix for saving
        sub_tf_data( :, :, iChan, iCond ) = mean( abs( tfdata .^ 2 ), 3 );
        
    end
    
    %suptitle( sprintf( 'sub %d', sID ) );
    print( sprintf([ lPath '/' 'sub%d_%dHzL_sFFTHann.pdf' ], sID, hz_idx( iCond )), '-dpdf', '-fillpage' );
end
hz = freqs; % for saving
t  = times;

tfr_dir = [dPath '/' 'tfr'];
if ~exist(tfr_dir, 'dir')
    mkdir(tfr_dir)
end
fname = sprintf('p%d_TFR_winSize%d', sID, winSize);
save([tfr_dir '/' fname], 'sub_tf_data', 'hz', 't', 'chan_ord', 'cidx');
clear sub_tf_data                             