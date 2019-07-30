%%%%%%%% K. Garner - June 2016
%%%%%%%% code to generate trial structure for SSVEP reward task - output is
%%%%%%%% a text file that can be used by the presentation code. 

%%%%%%%%%%%% trial numbers
trials_per_cond = 120;
n_cond = 4;
trials_per_block = 60;
blocks_per_cond = 2;
frequencies = 2;
colours = 4; % 2 to be associated with reward (1 and 2), 2 (3 and 4) for neutral

%%%%%%%%%%%% reward contingencies
high = (trials_per_block/4)*3;
low = (trials_per_block/4)*1;
mid = trials_per_block/2;

%%%%%%%%%%%%%% generate trial matrix
trial_matrix = zeros(trials_per_cond*n_cond,8);
%%% conditions
trial_matrix(:,1) = ceil([1:(n_cond*trials_per_cond)]./trials_per_cond)'; %%%%%% condition 3:1, 1:1, 1:3, 0:0
trial_matrix(:,2) = repmat(ceil([1:(blocks_per_cond*trials_per_block)]./trials_per_block)',4,1); %%%%%%% blocks per condition
trial_matrix(:,3) = repmat([1 2]',trials_per_block*n_cond,1); %%%%%% left value - a vs b
trial_matrix(:,4) = repmat([2 1]',trials_per_block*n_cond,1); %%%%%% right value - a vs b
trial_matrix(:,5) = repmat([2 2 3 3]',(trials_per_block*n_cond)/2,1); %%%% cue direction
trial_matrix(:,6) = repmat([1 1 1 1 2 2 2 2]',(trials_per_block*n_cond)/4,1); %%%%%%%% left frequency
trial_matrix(:,7) = repmat([2 2 2 2 1 1 1 1]',(trials_per_block*n_cond)/4,1); %%%%%%%% right frequency

%%%%%%%%%%% change colours of condition 4
trial_matrix(trial_matrix(:,1) == 4 & trial_matrix(:,3) == 1,3) = 3;
trial_matrix(trial_matrix(:,1) == 4 & trial_matrix(:,3) == 2,3) = 4;
trial_matrix(trial_matrix(:,1) == 4 & trial_matrix(:,4) == 1,4) = 3;
trial_matrix(trial_matrix(:,1) == 4 & trial_matrix(:,4) == 2,4) = 4;

%%%%%%%%%% allocate reward condition
%%%%%% 3:1 features
% trial_matrix(:,1) == 1 & trial_matrix(:,3) == 1 & trial_matrix(:,5) == 1
% trial_matrix(:,1) == 1 & trial_matrix(:,4) == 1 & trial_matrix(:,5) == 2
tmp = find(trial_matrix(:,1) == 1 & trial_matrix(:,3) == 1 & trial_matrix(:,5) == 1 | trial_matrix(:,1) == 1 & trial_matrix(:,4) == 1 & trial_matrix(:,5) == 2);
trial_matrix(tmp(randperm(length(tmp),high)),8) = 1;
tmp = find(trial_matrix(:,1) == 1 & trial_matrix(:,3) == 2 & trial_matrix(:,5) == 1 | trial_matrix(:,1) == 1 & trial_matrix(:,4) == 2 & trial_matrix(:,5) == 2);
trial_matrix(tmp(randperm(length(tmp),low)),8) = 1;

%%%%%%%%%%%%% 1:1
tmp = find(trial_matrix(:,1) == 2 & trial_matrix(:,3) == 1 & trial_matrix(:,5) == 1 | trial_matrix(:,1) == 2 & trial_matrix(:,4) == 1 & trial_matrix(:,5) == 2);
trial_matrix(tmp(randperm(length(tmp),mid)),8) = 1;
tmp = find(trial_matrix(:,1) == 2 & trial_matrix(:,3) == 2 & trial_matrix(:,5) == 1 | trial_matrix(:,1) == 2 & trial_matrix(:,4) == 2 & trial_matrix(:,5) == 2);
trial_matrix(tmp(randperm(length(tmp),mid)),8) = 1;

%%%%%%%%%%%%% 1:3
tmp = find(trial_matrix(:,1) == 3 & trial_matrix(:,3) == 1 & trial_matrix(:,5) == 1 | trial_matrix(:,1) == 3 & trial_matrix(:,4) == 1 & trial_matrix(:,5) == 2);
trial_matrix(tmp(randperm(length(tmp),low)),8) = 1;
tmp = find(trial_matrix(:,1) == 3 & trial_matrix(:,3) == 2 & trial_matrix(:,5) == 1 | trial_matrix(:,1) == 3 & trial_matrix(:,4) == 2 & trial_matrix(:,5) == 2);
trial_matrix(tmp(randperm(length(tmp),high)),8) = 1;