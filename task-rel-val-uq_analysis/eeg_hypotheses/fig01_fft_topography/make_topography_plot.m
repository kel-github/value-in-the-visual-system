%%% plot, across frequency assignments, the topographical maps of the
%%% SSVEP response
%%% following
%%% written by K. Garner, June 2019
%%% (c) free to use and share, please cite and use responsibly

sIDs = [202, 204, 205, 207, 208, 213, 214, 215];
% SETUP ENVIRONMENT-RELATED VARIABLES
% -------------------------------------------------------------------------
PLACE = 'QBI';

switch PLACE
    case 'home'
        
        cPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/eeg_hypotheses/fig01_fft_topography';
        bPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/';
        dPath = sprintf('~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/eeg/sub-%d', sID); % filepath for data (subject's folder)
        fftPath = 'fft';
        uPath    = 'Utils';
        spl_file = 'uq-ssvep-relval.spl';
    case 'QBI'
        addpath('~/Documents/MATLAB/eeglab13_6_5b');
        %addpath('~/Documents/MATLAB/brewmap');
        cPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/eeg_hypotheses/fig01_fft_topography';
        sPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/hypotheses/fig01_orth_topography/';
        fftPath = 'fft';
        uPath = 'Utils';
        %eName = 'Biosemi_64_eeglab_elp_2.ced'; % ectrode location file made coutesy of intel from SA
        spl_file = 'uq-ssvep-relval.spl';
    case 'psych'
        
        addpath('~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/eeglab13_6_5b');
        %addpath('~/Documents/MATLAB/brewmap');
        cPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/eeg_hypotheses/fig01_fft_topography';
        sPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/hypotheses/fig01_orth_topography/';
        fftPath = 'fft';
        uPath = 'Utils';
        %eName = 'Biosemi_64_eeglab_elp_2.ced'; % ectrode location file made coutesy of intel from SA
        spl_file = 'uq-ssvep-relval.spl';
end

eeglab

datNm = sprintf('RelVal-FFTDat_sub%d-sub%d.mat', sIDs(1), sIDs(end));
load([ sPath '/' datNm ]);

PLOT = 'z';

switch PLOT
    case 'z'
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % MIMIC FIG 2 OF ITTIPURIPAT ET AL https://www.physiology.org/doi/full/10.1152/jn.01051.2012?url_ver=Z39.88-2003&rfr_id=ori:rid:crossref.org&rfr_dat=cr_pub%3dpubmed
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % extract only the frequencies of interest from the matrix of raw fft data
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        hzIdx = dsearchn( hz', [16.67, 25]' );
        frqDat = raw_fft_by_sub( :, :, hzIdx, : ); % this gives subs x chan x freq of interest x formations
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % now perform z-score in the channel dimension
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        chnDim = 2;
        s = std( frqDat, [], chnDim );
        s = repmat(s, [1, 64, 1, 1]);
        mu = mean( frqDat, chnDim );
        mu = repmat(mu, [1, 64, 1, 1]);
        zfrqDat = ( frqDat - mu ) ./ s;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % re-organise data so that it is in left vs right configuration
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % data is currently in sub x chan x freq x config
        tmp = zfrqDat;
        nuzfrqDat = zeros( size( tmp ) );
        % first, put the frequencies that were on the left in the same space in the
        % spatial config dimension
        % frequencies that were presented on the left go in dim 4 #1
        nuzfrqDat( :, :, 1, 1 ) = tmp( :, :, 1, 1 );
        nuzfrqDat( :, :, 2, 1 ) = tmp( :, :, 2, 2 );
        % frequencies presented on the right go in dim 4 # 2
        nuzfrqDat( :, :, 1, 2 ) = tmp( :, :, 2, 1 );
        nuzfrqDat( :, :, 2, 2 ) = tmp( :, :, 1, 2 );
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % average across subs and frequencies
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        pltDat = squeeze ( mean( squeeze( mean( nuzfrqDat, 3 ) ), 1 ) ) ;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % plot the topographies
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        figure;
        tits = {'left', 'right'};
        for iPlot = 1:size( pltDat, 2 )
            
            subplot(1, 2, iPlot)
            draw_topo_plot( pltDat( :, iPlot' ), spl_file, 1, [-2 +2] );
            title(tits{ iPlot });
        end
        h = gcf;
        print(h, [sPath '/' sprintf('zTopo_sub%d-to%d', sIDs(1), sIDs(end))], '-dpng');
        
    case 'pwr'
        
        %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % NOW PLOT PRCNT PWR DIFF FOR LEFT AND RIGHT FREQUENCIES
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % extract only the frequencies of interest from the matrix of prcnt chnge fft data
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        frqDat = pwr_fft_by_sub( :, :, hzIdx, : ); % this gives subs x chan x freq of interest x formations
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % compute difference of f1: f1 left - f1 right, f2: f2 left - f2 right
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        diffDat = zeros( size( frqDat, 1 ), size( frqDat, 2 ), size( frqDat, 3 ) );
        % subtract f1 left from f1 right
        diffDat( :, :, 1 ) = frqDat( :, :, 1, 1 ) - frqDat( :, :, 2, 1 );
        diffDat( :, :, 2 ) = frqDat( :, :, 2, 2 ) - frqDat( :, :, 1, 2 );
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % average across subs
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        pltDat = squeeze ( mean( diffDat, 1 ) );
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  plot the difference topographies for each frequency - add colour bar
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        figure;
        tits = {'f1: f1 L-R', 'f2: f2 L - R'};
        for iPlot = 1:size( pltDat, 2 )
            
            subplot(1, 2, iPlot)
            draw_topo_plot( pltDat( :, iPlot' ), spl_file, 1, [min(min( pltDat ) ), max( max( pltDat ) ) ] );
            title(tits{ iPlot });
        end
        h = gcf;
        print(h, [sPath '/' sprintf('pwrChngTopo_sub%d-to%d', sIDs(1), sIDs(end))], '-dpng');
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  average over both frequencies and plot a single prcnt power change topog
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        pltDat = squeeze( mean( pltDat, 2 ) );
        
        figure;
        draw_topo_plot( pltDat, spl_file, 1, [min( pltDat ), max(  pltDat ) ] );
        h = gcf;
        print(h, [sPath '/' sprintf('pwrChngAcFrqTopo_sub%d-to%d', sIDs(1), sIDs(end))], '-dpng');
        
        
    case 'MI'
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % extract only the frequencies of interest from the matrix of raw fft data
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        hzIdx = dsearchn( hz', [16.67, 25]' );
        frqDat = raw_fft_by_sub( :, :, hzIdx, : ); % this gives subs x chan x freq of interest x formations
         
        pltDat =  ( frqDat( :, :, :, 1 ) - frqDat( :, :, :, 2 ) ) ./ ( frqDat( :, :, :, 1 ) + frqDat( :, :, :, 2 ) );
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % average across subs
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        pltDat = squeeze ( mean( pltDat, 1 ) ); 
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  plot the difference topographies for each frequency - add colour bar
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        figure;
        tits = {'f16.67: L-R', 'f25: R - L'};
        for iPlot = 1:size( pltDat, 2 )
            
            subplot(1, 2, iPlot)
            draw_topo_plot( pltDat( :, iPlot' ), spl_file, 1, [min(min( pltDat ) ), max( max( pltDat ) ) ] );
            title(tits{ iPlot });
        end
        h = gcf;
        print(h, [sPath '/' sprintf('MITopo_sub%d-to%d', sIDs(1), sIDs(end))], '-dpdf', '-fillpage');
        
end