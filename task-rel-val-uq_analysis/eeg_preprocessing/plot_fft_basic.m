function [] = plot_fft_basic(  pwr, hz, hz_idx, cidx, chan_ord, epoch, sID)

% pwr      = chan x freqs x formations datatframe
% hz       = hz from fft
% hz_idx   =  idx of hz range of interest
% cidx     = idx of channels of interest
% chan_ord = string of channel labels (in cidx order)
% lPath    = sub log path
% epoch    = string denoting period of trial the data is from
% ts       = vector of times in integer (ms)
% sID      = sub ID for title

figure;
for iPlot = 1:size( pwr, 3 )
    subplot( 1, size( pwr, 3 ), iPlot );
    plot( hz( hz_idx(1):hz_idx(2) ), pwr(cidx,  hz_idx(1):hz_idx(2), iPlot) );
    xlabel('hz');
    ylabel('pwr');
    ylim([0, 1*(10^6)]); 
    xticks([0 10 16.67 25 40]);
    %legend( chan_ord, 'Location', 'northeast');
    if iPlot == 1
        
        title( '16.67 Hz Left, 25 Hz right' );
    else
        title( '25 Hz Left, 16.67 Hz right' );
    end
    suptitle( sprintf( 'sub %d %s' , sID, epoch ) );
    
end

end