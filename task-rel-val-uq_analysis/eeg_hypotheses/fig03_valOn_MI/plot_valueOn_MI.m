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
datNm = sprintf('sub%d_to_sub%d_MI_valueOn_m500to1000_winSize%d.mat', sIDs(1), sIDs(end), winSize);
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
Nhem = 2;
Nmi = 3;
col_map = [ 27, 158, 119; ...
            217, 95, 2; ...
            117, 112, 179 ]/255';
x = linspace(-500, 1500, size( mu_mi, 1) );


% Plot
% -------------------------------------------------------------------------
subplot( 1, Nhem, 1 )
ha = shadedErrorBar( x, mu_mi(:, 1, 1)', se_mi(:, 1, 1)', 'lineprops', { '-', 'markerfacecolor', col_map(:, 1) } );
hold on
hb = shadedErrorBar( x, mu_mi(:, 2, 1)', se_mi(:, 2, 1)', 'lineprops', { '-', 'markerfacecolor', col_map(:, 2) } );
hc = shadedErrorBar( x, mu_mi(:, 3, 1)', se_mi(:, 3, 1)', 'lineprops', { '-', 'markerfacecolor', col_map(:, 3) } );
set(ha.mainLine, 'Color', col_map(:, 1));
set(ha.patch, 'FaceColor', col_map(:, 1));
set(hb.mainLine, 'Color', col_map(:, 2));
set(hb.patch, 'FaceColor', col_map(:, 2));
set(hc.mainLine, 'Color', col_map(:, 3));
set(hc.patch, 'FaceColor', col_map(:, 3));
xlabel( 'time' );
ylabel( 'MI' );
ylim([-.15, .15] );
a = gca;
plot(a.XLim, [0 0], 'k--');
plot([0, 0], a.YLim, 'k--');
a.FontSize = 10;
h = gca;
legend(h, {'hh', 'lh', 'hl'}, 'Location', 'best'); 

subplot( 1, Nhem, 2 )
ha = shadedErrorBar( x, mu_mi(:, 1, 2)', se_mi(:, 1, 2)', 'lineprops', { '-', 'markerfacecolor', col_map(:, 1) } );
hold on
hb = shadedErrorBar( x, mu_mi(:, 2, 2)', se_mi(:, 2, 2)', 'lineprops', { '-', 'markerfacecolor', col_map(:, 2) } );
hc = shadedErrorBar( x, mu_mi(:, 3, 2)', se_mi(:, 3, 2)', 'lineprops', { '-', 'markerfacecolor', col_map(:, 3) } );
set(ha.mainLine, 'Color', col_map(:, 1));
set(ha.patch, 'FaceColor', col_map(:, 1));
set(hb.mainLine, 'Color', col_map(:, 2));
set(hb.patch, 'FaceColor', col_map(:, 2));
set(hc.mainLine, 'Color', col_map(:, 3));
set(hc.patch, 'FaceColor', col_map(:, 3));
xlabel( 'time' );
ylabel( 'MI' );
ylim([-.15, .15] );
a = gca;
plot(a.XLim, [0 0], 'k--');
plot([0, 0], a.YLim, 'k--');
a.FontSize = 10;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PLOT DATA THAT DROVE IDXs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GET DATA
% -------------------------------------------------------------------------
% for each mi, and hemisphere, get the average and se over subjects
mu_cond_dat = squeeze( mean ( cond_dat_by_sub, 1 ) );
n = size( mu_cond_dat, 1 );
se_cond_dat = squeeze( std( cond_dat_by_sub, [], 1 ) ./ sqrt( n ) );

% Set variables for plot
% -------------------------------------------------------------------------
addpath( '~/Dropbox/MATLAB/shadedErrorBar-master');
Nhem = 2;
Ncond = 4;
col_map = [ 166, 206, 227; ...
            31, 120, 180; ...
            178, 223, 138; ...
            51, 160, 44]'/255;
x = linspace(-500, 1500, size( mu_cond_dat, 1) );

% Plot
% -------------------------------------------------------------------------
subplot( 1, Nhem, 1 )
ha = shadedErrorBar( x, mu_cond_dat(:, 1, 1)', se_cond_dat(:, 1, 1)', 'lineprops', { '-', 'markerfacecolor', col_map(:, 1) } );
hold on
hb = shadedErrorBar( x, mu_cond_dat(:, 2, 1)', se_cond_dat(:, 2, 1)', 'lineprops', { '-', 'markerfacecolor', col_map(:, 2) } );
hc = shadedErrorBar( x, mu_cond_dat(:, 3, 1)', se_cond_dat(:, 3, 1)', 'lineprops', { '-', 'markerfacecolor', col_map(:, 3) } );
hd = shadedErrorBar( x, mu_cond_dat(:, 4, 1)', se_cond_dat(:, 4, 1)', 'lineprops', { '-', 'markerfacecolor', col_map(:, 4) } );
set(ha.mainLine, 'Color', col_map(:, 1));
set(ha.patch, 'FaceColor', col_map(:, 1));
set(ha.edge(1), 'Color',  col_map(:, 1));
set(ha.edge(2), 'Color',  col_map(:, 1));
set(hb.mainLine, 'Color', col_map(:, 2));
set(hb.patch, 'FaceColor', col_map(:, 2));
set(hb.edge(1), 'Color',  col_map(:, 2));
set(hb.edge(2), 'Color',  col_map(:, 2));
set(hc.mainLine, 'Color', col_map(:, 3));
set(hc.patch, 'FaceColor', col_map(:, 3));
set(hc.edge(1), 'Color',  col_map(:, 3));
set(hc.edge(2), 'Color',  col_map(:, 3));
set(hd.mainLine, 'Color', col_map(:, 4));
set(hd.patch, 'FaceColor', col_map(:, 4));
set(hd.edge(1), 'Color',  col_map(:, 4));
set(hd.edge(2), 'Color',  col_map(:, 4));
xlabel( 'time' );
ylabel( 'PWR' );
ylim([1, 3.5] );
a = gca;
plot(a.XLim, [0 0], 'k--');
plot([0, 0], a.YLim, 'k--');
a.FontSize = 10;
h = gca;
legend(h, {'ll', 'hh', 'lh', 'hl'}, 'Location', 'best'); 


subplot( 1, Nhem, 2 )
ha = shadedErrorBar( x, mu_cond_dat(:, 1, 2)', se_cond_dat(:, 1, 2)', 'lineprops', { '-', 'markerfacecolor', col_map(:, 1) } );
hold on
hb = shadedErrorBar( x, mu_cond_dat(:, 2, 2)', se_cond_dat(:, 2, 2)', 'lineprops', { '-', 'markerfacecolor', col_map(:, 2) } );
hc = shadedErrorBar( x, mu_cond_dat(:, 3, 2)', se_cond_dat(:, 3, 2)', 'lineprops', { '-', 'markerfacecolor', col_map(:, 3) } );
hd = shadedErrorBar( x, mu_cond_dat(:, 4, 2)', se_cond_dat(:, 4, 2)', 'lineprops', { '-', 'markerfacecolor', col_map(:, 4) } );
set(ha.mainLine, 'Color', col_map(:, 1));
set(ha.patch, 'FaceColor', col_map(:, 1));
set(ha.edge(1), 'Color',  col_map(:, 1));
set(ha.edge(2), 'Color',  col_map(:, 1));
set(hb.mainLine, 'Color', col_map(:, 2));
set(hb.patch, 'FaceColor', col_map(:, 2));
set(hb.edge(1), 'Color',  col_map(:, 2));
set(hb.edge(2), 'Color',  col_map(:, 2));
set(hc.mainLine, 'Color', col_map(:, 3));
set(hc.patch, 'FaceColor', col_map(:, 3));
set(hc.edge(1), 'Color',  col_map(:, 3));
set(hc.edge(2), 'Color',  col_map(:, 3));
set(hd.mainLine, 'Color', col_map(:, 4));
set(hd.patch, 'FaceColor', col_map(:, 4));
set(hd.edge(1), 'Color',  col_map(:, 4));
set(hd.edge(2), 'Color',  col_map(:, 4));
xlabel( 'time' );
ylabel( 'PWR' );
ylim([1, 3.5] );
a = gca;
plot(a.XLim, [0 0], 'k--');
plot([0, 0], a.YLim, 'k--');
a.FontSize = 10;
h = gca;
legend(h, {'ll', 'hh', 'lh', 'hl'}, 'Location', 'best'); 

