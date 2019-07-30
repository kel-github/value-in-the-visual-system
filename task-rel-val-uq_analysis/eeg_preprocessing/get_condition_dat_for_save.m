function [ cDat ] = get_condition_dat_for_save(sID, condition, bl_dat, value_dat, tgt_dat, resps_dat, feed_dat)
% format data for appendage to the sub's overall timefreq longform
% matrix

% allocate the data to the save_data matrix - columns = sub, condition,
% frequencies, channels, event, data
cDat = zeros( sum( [prod(size(bl_dat)), prod(size(value_dat)), prod(size(tgt_dat)), prod(size(resps_dat)), prod(size(feed_dat))] )  , 6 );
r = size(cDat, 1);

% fill with subject and condition data
cDat(1:r, 1) = sID;
cDat(1:r, 2) = condition;

% concatenate the different events so that all epochs are appended on the
% time dimension
allDat = cat(2, bl_dat, value_dat, tgt_dat, resps_dat, feed_dat );

% make the vector that describes which epoch is on which row on the time
% dimension
evIdx  = zeros(1, size(allDat, 2))';
evIdx(1:size(bl_dat, 2)) = 1;
evIdx(sum(evIdx > 0)+1:sum(evIdx > 0)+size(value_dat, 2)) = 2;
evIdx(sum(evIdx > 0)+1:sum(evIdx > 0)+size(tgt_dat, 2)) = 3;
evIdx(sum(evIdx > 0)+1:sum(evIdx > 0)+size(resps_dat, 2)) = 4;
evIdx(sum(evIdx > 0)+1:sum(evIdx > 0)+size(feed_dat, 2)) = 5;

% allocate to the overall cDat matrix (go through frequencies and channels)
for iFreq = 1:size(allDat, 1)
    
    for iChan = 1:size(allDat, 3)
        
        tmp = allDat(iFreq, :, iChan);   % get the data     
        if iFreq == 1 && iChan == 1
            idx = 1:size(tmp, 2);
        else
            idx = sum(cDat(:,3) > 0)+1:sum(cDat(:,3) > 0)+size(tmp,2);
        end
        cDat(idx, 3) = iFreq;
        cDat(idx, 4) = iChan;
        cDat(idx, 5) = evIdx;
        cDat(idx, 6) = tmp;
             
    end
end
end

