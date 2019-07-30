function [] = plot_fft_localised(  pwr, hz, hz_idx, cidx, chan_ord, chan_lidx, epoch, sID)
% plot fft with left central and right hemispher channels separated

% pwr       = chan x freqs x formations datatframe
% hz        = hz from fft
% hz_idx    =  idx of hz range of interest
% cidx      = idx of channels of interest
% chan_lidx = a 2 value vector denoting the end of the left, and middle
% chan idxs
% chan_ord  = string of channel labels (in cidx order)
% lPath     = sub log path
% epoch     = string denoting period of trial the data is from
% ts        = vector of times in integer (ms)
% sID       = sub ID for title

figure;
for iPlot = 1:size( pwr, 3 )
    if iPlot == 1        
        subplot( size( pwr, 3 ), 3, 1 );
    else 
        subplot( size( pwr, 3 ), 3, 4 );
    end
    
    plot( hz( hz_idx(1):hz_idx(2) ), pwr(cidx( 1:chan_lidx( 1 ) ) ,  hz_idx(1):hz_idx(2), iPlot) );
    xlabel('hz');
    ylabel('pwr');
    xticks([0 10 16.7 25 40]);
    %legend( chan_ord{ 1:chan_lidx( 1 ) } , 'Location', 'northeast' );
    if iPlot == 1
        
        title( 'Left Chans: 16.67 Hz Left, 25 Hz right' );
    else
        title( 'Left Chans: 25 Hz Left, 16.67 Hz right' );
    end
    suptitle( sprintf( 'sub %d %s' , sID, epoch ) );
    
    
    if iPlot == 1        
        subplot( size( pwr, 3 ), 3, 2 );
    else 
        subplot( size( pwr, 3 ), 3, 5 );
    end
    plot( hz( hz_idx(1):hz_idx(2) ), pwr(cidx( chan_lidx( 1 ) + 1 : chan_lidx( 2 ) ) ,  hz_idx(1):hz_idx(2), iPlot) );
    xticks([0 10 16.7 25 40]);
    title( 'Middle Chans - z line' );
    %legend( chan_ord{ chan_lidx( 1 ) + 1 : chan_lidx( 2 ) } , 'Location', 'northeast');
    
    if iPlot == 1        
        subplot( size( pwr, 3 ), 3, 3 );
    else 
        subplot( size( pwr, 3 ), 3, 6 );
    end
    plot( hz( hz_idx(1):hz_idx(2) ), pwr(cidx( ( chan_lidx( 2 ) + 1 ): numel( cidx ) ) ,  hz_idx(1):hz_idx(2), iPlot) );
    xticks([0 10 16.67 25 40]);
    title( 'Right Chans' );
    %legend( chan_ord{ chan_lidx( 2 ) + 1 : numel( cidx ) } , 'Location', 'northeast');
       
end

end