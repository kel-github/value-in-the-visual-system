%%% plot the value onset modulation index, for left and right channels, averaged
%%% across subjects
%%% plot the condition averages that drove the modulation index
%%% written by K. Garner, June 2019
%%% (c) free to use and share, please cite and use responsibly

clear all
sIDs = [202, 204, 205, 207, 208, 213, 214, 215];

% SETUP ENVIRONMENT-RELATED VARIABLES
% -------------------------------------------------------------------------
PLACE = 'home';

switch PLACE
    case 'home'                
        cPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/eeg_hypotheses/fig03_valOn_MI';
        dPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/hypotheses/fig03_valOn_MI';
        uPath    = 'Utils'; 
        
    case 'QBI'
        addpath('~/Documents/MATLAB/eeglab13_6_5b');
        cPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/eeg_hypotheses/fig03_valOn_MI';
        dPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/hypotheses/fig03_valOn_MI';
        uPath    = 'Utils'; 
    case 'psych'
        cPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/eeg_hypotheses/fig03_valOn_MI';
        dPath = '~/Dropbox/QBI/val-ssvep-UQ/task-rel-val-uq_analysis/ANALYSIS/hypotheses/fig03_valOn_MI';
        uPath    = 'Utils'; 
end

winSize = 768;
datNm = sprintf('sub%d_to_sub%d_MI_valueOn_allFrq_m500to1000_winSize%d.mat', sIDs(1), sIDs(end), winSize);
load([ dPath '/' datNm ]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOT MODULATION IDXs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET DATA
% -------------------------------------------------------------------------
% for each mi, and hemisphere, get the average and se over subjects
mu_mi = squeeze( mean ( mi_by_sub, 1 ) );
n = size( mi_by_sub, 1 );
se_mi = squeeze( std( mi_by_sub, [], 1 ) ./ sqrt( n ) );

% Set variables for plot
% -------------------------------------------------------------------------
addpath( '~/Dropbox/MATLAB/shadedErrorBar-master');
addpath( '~/Dropbox/MATLAB/Colormaps');
Nhem = 2;
Nmi = 3;
time = linspace(-500, 1500, size( mu_mi, 2) );
f = linspace(-2, 2, size( mu_mi, 1));
m = 100;
cm_inferno = viridis(m);

% Plot
% -------------------------------------------------------------------------
minDat = min(min(min(min(mu_mi))));
maxDat = max(max(max(max(mu_mi))));
sp_idx = [1, 3, 5];
for i = 1:size(mu_mi, 3)

    subplot( size(mu_mi, 3), Nhem, sp_idx(i) );
    imagesc( time, f, mu_mi(:, :, i, 1), [minDat, maxDat]);
    set(gca,'ydir', 'normal');
    colormap(gca, cm_inferno);
    colorbar
end

sp_idx = [2, 4, 6];
for i = 1:size(mu_mi, 3)

    subplot( size(mu_mi, 3), Nhem, sp_idx(i) );
    imagesc( time, f, mu_mi(:, :, i, 2), [minDat, maxDat]);
    set(gca,'ydir', 'normal');
    colormap(gca, cm_inferno);
    colorbar
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOT DATA THAT DROVE IDXs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET DATA
% -------------------------------------------------------------------------
% for each mi, and hemisphere, get the average and se over subjects
mu_cond_dat = squeeze( mean ( cond_dat_by_sub, 1 ) );
n = size( cond_dat_by_sub, 1 );
se_cond_dat = squeeze( std( cond_dat_by_sub, [], 1 ) ./ sqrt( n ) );

% Set variables for plot
% -------------------------------------------------------------------------

addpath( '~/Dropbox/MATLAB/shadedErrorBar-master');
addpath( '~/Dropbox/MATLAB/Colormaps');
Nhem = 2;
Nmi = 3;
time = linspace(-500, 1500, size( mu_mi, 2) );
f = linspace(-2, 2, size( mu_mi, 1));
m = 100;
cm_inferno = viridis(m);

% Plot
% -------------------------------------------------------------------------
minDat = min(min(min(min(mu_cond_dat))));
maxDat = max(max(max(max(mu_cond_dat))));
sp_idx = [1, 3, 5, 7];
for i = 1:size(mu_cond_dat, 3)

    subplot( size(mu_cond_dat, 3), Nhem, sp_idx(i) );
    imagesc( time, f, mu_cond_dat(:, :, i, 1), [minDat, maxDat]);
    set(gca,'ydir', 'normal');
    colormap(gca, cm_inferno);
    colorbar
end

sp_idx = [2, 4, 6, 8];
for i = 1:size(mu_cond_dat, 3)

    subplot( size(mu_cond_dat, 3), Nhem, sp_idx(i) );
    imagesc( time, f, mu_cond_dat(:, :, i, 2), [minDat, maxDat]);
    set(gca,'ydir', 'normal');
    colormap(gca, cm_inferno);
    colorbar
end
