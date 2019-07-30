function [ epoched_data ] = get_epochs( data, onsets, on_idx, tidx, times )

% get specific epoch of data from the time frequency analysis of whole trial,
% locked to the specific event, and return the median over trials
% epoched_data = freq x timepoints x channels matrix

% written by K. Garner, 2019
% data   = condition data (freq x time x trials x channel)
% onsets = the latencies of onset of the event of interest 
% on_idx = the onsets to select for that condition
% tidx = the segment of time from which data is required, relative to the
% events of interest
% times = the times output of newtimef

% first get the nearest times for the each onset, from the frequency
% timepoints
tmp_ons = dsearchn( times', onsets(on_idx)');
% get temporal resolution given by times
res = max( diff(times) );

% how far back to go?
back      = round( abs(tidx(1)) / res );
forward   = round( abs(tidx(2)) / res );

% now get the index to extract timepoints from data  
tmp_tidx  = [ tmp_ons - back, tmp_ons + forward ] ;

% do the extraction by looping through each trials tidx and adding to the
% epoched data matrix
dims  = size( data );
epoched_data = zeros( dims(1), min(diff(tmp_tidx'))+1, dims(3), dims(4) );
% freqs by time x trials x channels

for iTidx = 1:size(tmp_tidx, 1)
   
    epoched_data(:, :, iTidx, :) = data(:, tmp_tidx(iTidx,1):tmp_tidx(iTidx,2), iTidx, :);
      
end

% epoched_data = squeeze( median ( epoched_data, 3 ) );


end