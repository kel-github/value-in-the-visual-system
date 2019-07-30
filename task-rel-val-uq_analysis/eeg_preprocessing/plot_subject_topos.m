function [] = plot_subject_topos( topo_dat, hz, hz_idx )

% topo_dat = a n (hz) x channel matrix
% hz_idx   = the hz for each n in topo_dat

load([pwd '/' 'Utils' '/' 'BESA_64_chanlocs'], 'chanlocs');

for iPlot = 1:size( topo_dat, 1 )
    
    subplot( 1, size( topo_dat, 1 ), iPlot );
    topoplot( topo_dat(iPlot, :), ...
              chanlocs, ...
              'maplimits', 'absmax', ...
              'electrodes', 'on' );
    colorbar;
    title( sprintf( '%.2f Hz', hz( hz_idx( iPlot ) ) ) );
end

suptitle( sprintf( '%.2f Hz left - %.2f Hz right', hz( hz_idx(1) ), hz( hz_idx(1) ) ) );


