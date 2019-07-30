
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
% - GET DATA FOR EPOCH OF INTEREST  - INIT PERIOD (1000 to 2000ms) REL TO TRIAL ONSET; 
% - CALC FFT AND PWR FOR F1 LEFT (F1, F2)
% - PERFORM SAME FOR F2 LEFT
% - PLOT TOPO OF POWER
% - STANDARDISE SELECTED ELECTRODES (FOR EACH FREQ, [ADD ELECTRODES], SEE PILOT - )
% - SAVE A MAT FILE WITH SUB DAT WITH PWR AT EACH FREQUENCY & 4 surrounding
% bins - FOR PLOTTING IN .R

% DBLE CHECKED CONDITION ALLOCATIONS - 8th NOV 2017

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

% - GET DATA FOR EPOCH OF INTEREST  - INIT PERIOD (1000 to 2000ms) REL TO TRIAL ONSET; 
% -------------------------------------------------------------------------

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


% GET DATA FOR EPOCHS (BL and 3 x 1 SEC)
% -------------------------------------------------------------------------
epoch_tidxs = [ -1051 -50; 1000 2000 ]; 

bl_tidx = dsearchn( EEG.times', epoch_tidxs(1,:)'); 
blf1L_data = EEG.data( :, bl_tidx(1):bl_tidx(2), condvec == 1 );
blf2L_data = EEG.data( :, bl_tidx(1):bl_tidx(2), condvec == 2 );

% COMPUTE BL FFT
% -------------------------------------------------------------------------
nfft = ceil( EEG.srate/.5 );
hz = linspace(0, EEG.srate, nfft); %

blf1L_power = mean( abs( fft( blf1L_data, nfft, 2 ) ) .^2, 3 );
blf2L_power = mean( abs( fft( blf2L_data, nfft, 2 ) ) .^2, 3 );

% concatenate for later reference
bl_pwr = cat(3, blf1L_power, blf2L_power);

% PLOT SUBS BL PWR SPECTRUM AS A SANITY CHECK
% HZ IDX
hz_idx = [1, 40];
hz_idx = dsearchn( hz', hz_idx' );
% ELECTRODES OF INT
elecs_of_int = {'P7', 'P5', 'P3', 'P1', 'Pz', 'P2', 'P4', 'P8' ...
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
% PLOT BASELINE FFT AS SANITY CHECK
plot_fft_basic( bl_pwr, hz, hz_idx, cidx, chan_ord, 'baseline', sID);
print( sprintf([ lPath '/' 'sub%d_baseline_fft_tm1050_m50.pdf' ], sID), '-dpdf', '-fillpage' );

% NOW GET DATA FROM EACH EPOCH AND COMPUTE POWER DIFFERENCE, 
% THEN TAKE AVERAGE ACROSS VARIABLES - STORE IN OUT VARIABLE
% -------------------------------------------------------------------------
n_epochs = 1; % just in case add more epochs later

for count_epochs = 1:n_epochs
    
    c_tidx = dsearchn( EEG.times', epoch_tidxs(count_epochs+1,:)'); 
     
    % get data for each epoch
    f1L_data = EEG.data( :, c_tidx(1):c_tidx(2), condvec == 1 );
    f2L_data = EEG.data( :, c_tidx(1):c_tidx(2), condvec == 2 );
    
    % COMPUTE FFT
    % -------------------------------------------------------------------------------------------------------------------------------------------
    f1L_power = mean( abs( fft( f1L_data, nfft, 2 ) ) .^2, 3 );
    f2L_power = mean( abs( fft( f2L_data, nfft, 2 ) ) .^2, 3 );

end
% concatenate for reference in next step
sub_pwr = cat(3, f1L_power, f2L_power); 
% PLOT TRIAL FFT AS SANITY CHECK
plot_fft_basic( sub_pwr, hz, hz_idx, cidx, chan_ord, 'trial start', sID);
print( sprintf([ lPath '/' 'sub%d_fft_t1000_2000.pdf' ], sID), '-dpdf', '-fillpage' );

% NOW COMPUTE PWR CHANGE (OUTPUT IS AVERAGE PWR CHANGE)
t_forms = size(sub_pwr, 3); % total spatial configurations to get
pwr = zeros(n_epochs, chans, length(hz), t_forms);

for count_epochs = 1:n_epochs
    
    for count_forms = 1:2
     
        bl_tmp = bl_pwr(:,:,count_forms);
        tmp = sub_pwr(:,:,count_forms);
        pwr( count_epochs, :, : , count_forms ) = ((tmp - bl_tmp) ./ bl_tmp) * 100;    
    end
end

% SANITY CHECK PLOT
chan_lidx = [ 8, 11 ];
plot_fft_localised( squeeze(pwr), hz, hz_idx, cidx, chan_ord, chan_lidx, 'prcnt pwr', sID);
print( sprintf([ lPath '/' 'sub%d_prcnt_Chnge.pdf' ], sID), '-dpdf', '-fillpage' );

% save in this format for later concatenation with subs and topo plotting
fft_dir = [dPath '/' 'fft'];
if ~exist(fft_dir, 'dir')
    mkdir(fft_dir)
end
fname = sprintf('p%d_bl_FFT', sID);
save([fft_dir '/' fname], 'pwr', 'hz', 'sub_pwr');

% PLOT INDIVIDUAL SUBJECT TOPO (2: F1 @ F1 Left - F1 Right, F2 @ F2
% Left - F2 Right
hz_idx = dsearchn( hz', [16.67, 25]' );
topo_dat = zeros( size( pwr, 4 ), size( pwr, 2 ) );
for iDat = 1:size( topo_dat, 1 )
    topo_dat( iDat, : ) = pwr(1, :, hz_idx(iDat), 1 ) - pwr(1, :, hz_idx(iDat), 2 );
end
% remove unlikely values
unlikely = 100;
topo_dat( topo_dat > unlikely ) = NaN;
plot_subject_topos( topo_dat, hz, hz_idx );
print( sprintf([ lPath '/' 'sub%d_top_%dHzLm%dHzR.pdf' ], sID, floor( hz( hz_idx(1) ) ), floor( hz( hz_idx(1) ) ) ), '-dpdf', '-fillpage' );

% now convert to longform and write csv
freqs_idx = find(hz > 12 & hz < 30);

% columns = sID, epoch, form, elec, freq, pwr 
sub_lf_pwr = zeros(length(freqs_idx)*n_epochs*t_forms*n_elecs, 6);

count_rows = 0;
for count_epochs = 1:n_epochs
    
    for count_forms = 1:t_forms
        
        for count_elecs = 1:length(cidx)
            
            for count_freqs = 1:length(freqs_idx)
                
                count_rows = count_rows + 1;
                
                sub_lf_pwr(count_rows, :) = [sID, count_epochs, count_forms, count_elecs, hz(freqs_idx(count_freqs)), pwr(count_epochs, cidx(count_elecs), freqs_idx(count_freqs), count_forms)];
            end
        end
    end
end
                
fname = sprintf('p%d_bl_FFT_lf', sID);
save([fft_dir '/' fname], 'sub_lf_pwr', 'chan_ord');




