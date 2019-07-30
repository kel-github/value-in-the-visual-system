%%%%%%%% K. Garner - September 2016
%%%%%%%% code to generate trial structure for SSVEP reward task - output is
%%%%%%%% a text file that can be used by the presentation code. 
%%%%%%%% v2 generates a trial structure with the classic contingencies - 
%%%%%%%% 2 colours, hvh, lvl, hvl & lvh

function get_trial_log_v2(sub_num,date)
%%%%%%%%%%%% trial numbers
trials_per_cond = 112; % this was for get_trial_log_v1, just leaving in for possible ease of adaptability in future
n_cond = 4;
trials_per_block = 28; % this was for get_trial_log_v1, just leaving in for possible ease of adaptability in future
blocks_per_cond = 4;
frequencies = 2;
colours = 2; % 1 for high and 1 for low

%%%%%%%%%%%%%% generate trial matrix
trial_matrix = zeros(trials_per_cond*n_cond,8);
%%% conditions
trial_matrix(:,1) = ceil([1:(n_cond*trials_per_cond)]./trials_per_cond)'; %%%%%% this was for get_trial_log_v1, 
trial_matrix(:,2) = repmat(ceil([1:(blocks_per_cond*trials_per_block)]./trials_per_block)',4,1); %%%%%%% blocks per condition - this was for get_trial_log_v1, 
trial_matrix(:,3) = repmat([1 2 1 2]',(trials_per_cond*n_cond)/4,1); %%%%%% left value - a vs b
trial_matrix(:,4) = repmat([1 2 2 1]',(trials_per_cond*n_cond)/4,1); %%%%%% right value - a vs b % with left, gives hh, ll, hl, lh displays
trial_matrix(:,5) = repmat([1 1 1 1 2 2 2 2]',(trials_per_cond*n_cond)/8,1); %%%% cue direction - the cue was ultimately not used, but it does give the tgt loc as was 100% predictive
trial_matrix(:,6) = repmat([1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2]',(trials_per_cond*n_cond)/16,1); %%%%%%%% left frequency
trial_matrix(:,7) = repmat([2 2 2 2 2 2 2 2 1 1 1 1 1 1 1 1]',(trials_per_cond*n_cond)/16,1); %%%%%%%% right frequency
%trial_matrix(:,8) = repmat([1 0 1 0 1 0 0 1]',(trials_per_cond*n_cond)/8,1); %%%% reward trials
trial_matrix(:,8) = repmat([1 2 1 2 1 2 2 1]',(trials_per_cond*n_cond)/8,1); %%%

% now remove 20 % of reward trials
idx = find(trial_matrix(:,8) == 1);
idx = sort(idx(randperm(length(idx),floor(length(idx)*.2))));
trial_matrix(idx,8) = 0;
clear idx

% now make 80 % of no reward trials indexed to have a white fixation
idx = find(trial_matrix(:,8) == 2);
idx = sort(idx(randperm(length(idx),floor(length(idx)*.2))));
trial_matrix(idx,8) = 0;
clear idx

%%%%%%%%%%% now shuffle trials
idx = randperm(length(trial_matrix(:,1)));
trial_matrix = trial_matrix(idx, :);
trial_log = trial_matrix;

fid = fopen(sprintf('EEG_RelVal_sub%d_%d_%d_%d_%d%d.csv',sub_num,date(1),date(3),date(2),date(4),date(5)),'w');
fprintf(fid,'%d,%d,%d,%d,%d,%d,%d,%d\n',trial_log');
fclose(fid);
