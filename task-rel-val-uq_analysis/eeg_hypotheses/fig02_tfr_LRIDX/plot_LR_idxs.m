%%% plot, the time frequency representation of the power difference 
%%% between fi: stimulation left - stimulation right conditions
%%% for each subject at potential channel of interest, and then averaged
%%% across subjects
%%% written by K. Garner, June 2019
%%% (c) free to use and share, please cite and use responsibly
clear all
sIDs = [202, 204, 205, 207, 208, 213, 214, 215];
% SETUP ENVIRONMENT-RELATED VARIABLES
% -------------------------------------------------------------------------
PLACE = 'psych';

switch PLACE
    case 'home'                
        cPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/eeg_hypotheses/fig02_tfr_LRIDX';
        dPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/hypotheses/fig02_tfr_LRIDX';
        uPath    = 'Utils'; 

    case 'QBI'
        addpath('~/Documents/MATLAB/eeglab13_6_5b');
        cPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/eeg_hypotheses/fig02_tfr_LRIDX';
               dPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/hypotheses/fig02_tfr_LRIDX';
        uPath    = 'Utils'; 
    case 'psych'
        addpath('~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/eeglab13_6_5b');
        cPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/eeg_hypotheses/fig02_tfr_LRIDX';
        dPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/hypotheses/fig02_tfr_LRIDX';
        lPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/eeg/sub-%d/log';
        uPath    = 'Utils'; 
end

eeglab
winSize = 1024;
datNm = sprintf('RelVal-TFRDat_LR_winSize%d_sub%d-sub%d.mat', winSize, sIDs(1), sIDs(end));
load([ dPath '/' datNm ]);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for each sub, compute (f1 left - f1 right) / ( f1 left + f1 right )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sub_tfr_LRidx = (tfr_by_sub( :, :, :, :, 1 ) - tfr_by_sub( :, :, :, :, 2 )) ./ ( tfr_by_sub( :, :, :, :, 1 ) + tfr_by_sub( :, :, :, :, 2 ) );

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for each subject, plot the LRidx, across channels
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

chns_of_int = { 'P9', 'P7', 'P5', 'P3', 'P1', 'PO7', 'PO3', 'O1', ...
                'Pz', 'POz', 'Oz', ...
                'P2', 'P4', 'P6', 'P8', 'P10','PO4', 'PO8', 'O2',  };

chan_idx = zeros(1, numel( chns_of_int ) );
for iChan = 1:numel( chns_of_int ) 
    
   chan_idx( iChan ) = find( strcmp( chan_ord, chns_of_int{ iChan } ) );
    
end

% set up subplot indices
nrows = 8;
ncols = 3;
pIdx = [1:3:(nrows*ncols), 2:3:(3*3), 3:3:(nrows*ncols)] ;

nsubs = size( sub_tfr_LRidx, 1 );
nChans = numel( chan_idx );

for iSub = 1:nsubs
   
    figure;

    for iChan = 1:nChans
        
        tmp = squeeze(sub_tfr_LRidx( iSub, :, :, chan_idx(iChan) ));
        subplot( nrows, ncols, pIdx( iChan ) )
        imagesc( t, hz, tmp, [min(min(tmp)), max(max(tmp))]);
        set(gca,'ydir', 'normal');
        colorbar
        title( chns_of_int{  iChan  } )
        hold on
        % add vertical dotted line over zero, and across frequencies of
        % interest
        h = gca;
        line([0 0], h.YLim, 'LineStyle', ':', 'Color', [0 0 0]);
        line(h.XLim, [16.67, 16.67], 'LineStyle', ':', 'Color', [0 0 0]);
        line(h.XLim, [25, 25], 'LineStyle', ':', 'Color', [0 0 0]);
        hold off
    end
    
    print( sprintf([ lPath '/' 'TFR_winSize%d_ORTH_Contrast_sub-%d' ], sIDs( iSub), winSize, sIDs( iSub )), '-dpdf', '-fillpage');
    
end

% SAVE THE PLOTS IN DECENT SIZE

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% average across subs and plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pltDat = squeeze( mean( sub_tfr_LRidx, 1 ) ) ;

figure;

for iChan = 1:nChans
    
    tmp = pltDat( :, :, chan_idx(iChan) );
    subplot( nrows, ncols, pIdx( iChan ) )
    imagesc( t, hz, tmp, [min(min(tmp)), max(max(tmp))]);
    set(gca,'ydir', 'normal');
    colorbar
    title( chns_of_int{  iChan  } )
    hold on
    % add vertical dotted line over zero, and across frequencies of
    % interest
    h = gca;
    line([0 0], h.YLim, 'LineStyle', ':', 'Color', [0 0 0]);
    line(h.XLim, [16.67, 16.67], 'LineStyle', ':', 'Color', [0 0 0]);
    line(h.XLim, [25, 25], 'LineStyle', ':', 'Color', [0 0 0]);
    hold off
end
print(sprintf([dPath '/' 'TFRLRidx_winSize%d_subs%d-to-%d'], winSize, sIDs(1), sIDs(end)), '-dpdf', '-fillpage');
