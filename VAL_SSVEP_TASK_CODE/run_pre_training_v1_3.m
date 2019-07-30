%%%%%%%%%%%%%%%%%% K. Garner, August 2016
%%%% NOTES: All colours/dims calibrated for ViewSonic G225 450 mm x 350 mm
%%%% (with viewing distance of 570 mm) - for colour test see
%%%% resolution: 1600 x 1200
%%%% colour_lum_testViewSonicG225s_Hills109_DupDisp_2016_08_08.m in same
%%%% folder.
%%%% task teaches participants which colour is high value and which is low,
%%%% for subsequent orienting task
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEPENDENCIES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Psychtoolbox 3.0.13
% Matlab R2016a
% run on (get specs from Sara for Hills 64 PC).


% clear all the things
clear all
clear mex

% initialise mex files etc
KbCheck;
KbName('UnifyKeyNames');
GetSecs;
AssertOpenGL
Screen('Preference', 'SkipSyncTests', 0);
%PsychDebugWindowConfiguration;
dbug = input('Debug Mode? (1 or 0) ');
sess.sub_num = input('Subject Number? ');
sess.date = clock;
sess.session = input('Session? ');
sess.response_order = input('Response Order? ');
sess.colour_order = input('Colour Order? [1, 2] or [2, 1] ');
sess.diode = input('Diode? ' );

% time cheats
expand_time = 1;

% randomisation seed
r_num = [num2str(sess.sub_num) num2str(sess.session)];
r_num = str2double(r_num);
rand('state',r_num);
randstate = rand('state');
parent = cd;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MONITOR SETTINGS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
monitor = 0;
ref_rate = 60;
resolution = [1024 768]; % might change this with psychtoolbox - get stuff
freqs = [12.5 50/3]; %%%%%%%%% testing 12.5 and 16.67 for now - 1.2 seconds (analysis) gives resolution at 12.5 and 16.67 at 512 hz sampling
%%%%%%% closest on golden ration (1.618) = 11 - 12.62, 10.2 = 16.67, 10.9 =
%%%%%%% 12.51, 11.8 = 16.65
frequency_frames(1) = round ( (1000/freqs(1))/(1000/ref_rate) ); %%%%%%% get number of frames before each change
frequency_frames(2) = round ( (1000/freqs(2))/(1000/ref_rate) );
% actually wound up ~ 12 and 15 hz because of refresh rate being slightly under 60hz (closer to 59.88)
ttrials = 80;
trials.order(1,1:80) = repmat([1, 2], 1, ttrials/2);
trials.order(2,1:80) = repmat([1, 2, 2, 1], 1, ttrials/4);
trials.order(3,1:2:32*2) = 1;
trials.order = trials.order(:,randperm(ttrials));

trial_fname = sprintf('EEG_RelVal_preTrain_sub%d_%d_%d_%d_%d%d.csv',r_num, sess.date(1), sess.date(3), sess.date(2), sess.date(4), sess.date(5));
tfid = fopen(trial_fname);
results_log_fname = sprintf('EEG_RelVal_preTrain_resp_log_sub%d_%d_%d_%d_%d%d.csv',r_num, sess.date(1), sess.date(3), sess.date(2), sess.date(4), sess.date(5));
rsid = fopen(results_log_fname, 'w');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  SCREEN/DRAWING  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
screen_nums = Screen('Screens');
screen_nums = max(screen_nums);
% get black and white
white = WhiteIndex(screen_nums);
black = BlackIndex(screen_nums);
grey = white*0.5;

[w, rect] = Screen('OpenWindow', screen_nums, black); % ,...
Screen(w, 'Flip');
Screen(w, 'FillRect', black, rect);
[x_center, y_center] = RectCenter(rect);
[x_pix, y_pix] = Screen('WindowSize', w);
Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); %%%%%% blending
ifi = Screen('GetFlipInterval', w); %%%%%%% for controlling timings
% Retreive the maximum priority number
topPriorityLevel = MaxPriority(w);
% allow blending

%%%%%% draw checkerboards for each placeholder
rcycles = 2;
tcycles = 6;
rsize = [0 0 100 100]; % 100 pixels = approx 2.5 degrees visual angle on CRT monitor 
hi = 255;
lo = black;
checks = makeCheckerBoard(rcycles, tcycles, rsize, hi, lo, black);
[x,y,z] = size(checks);

check_t(1) = Screen('MakeTexture', w, checks(:,:,[1 2]));
check_t(2) = Screen('MakeTexture', w, checks(:,:,[3 4]));
base_rect = rsize;

place_rects = CenterRectOnPointd(base_rect, x_center, y_center);
tmp = [[148 131 165]-5; 230 93 85; [182, 133, 58]-5; 226 90 121]; %%%%%%% colours checked for Hills 1.09 (ViewSonic G225s) - see testing folder
task.shape_col = [tmp(sess.colour_order(1),:); tmp(sess.colour_order(2),:)];

disc_size = 50;
disc_rect_base = [0 0 disc_size disc_size];
disc_rects = CenterRectOnPointd(disc_rect_base, x_center, y_center);
oval_cols = {[grey grey grey 0]; [grey grey grey]};

% draw tgts
tgt_loc_base_rect = [0 0 50 50];
tgt_loc_rects = CenterRectOnPointd(tgt_loc_base_rect, x_center, y_center);
tgt_size = 30;
tgt_style = 1;
target_col = {[black black black 0],[black black black]}; % changing targets to white
tgts = {'H','N'};
x_offset = 10;   
y_offset = 10; 

%%%%% draw a fixation consisting of two arrows, one pointing left, one
%%%%% right
alert_fix_pix = 6;
alert_fix_x = [-alert_fix_pix alert_fix_pix 0 0];
alert_fix_y = [0 0 -alert_fix_pix alert_fix_pix];
alert_fix_coords = [alert_fix_x; alert_fix_y];
alert_fix_cols = {[128 128 128; 128 128 128; 128 128 128; 128 128 128]', ...
                  [128 128 128; 128 128 128; 128 128 128; 128 128 128]', ...
                  [128 128 128; 128 128 128; 128 128 128; 128 128 128]'};%%%%% dark/light grey - multiple entries refers to earlier version where fixation changed
  
base = 3;
alert_fix_width = alert_fix_pix;
reward_fix_width = 7;
alert_fix_check_coords = CenterRectOnPointd([0 0 100 100], x_center, y_center); % starting w 50 pixels, will calibrate lower as we go
%%%%%% feedback info
feeds_vals = [255 255 255];
feed_col = [0 255 0];
error_col = [255 0 0];

%%%%%%% define fonts
Screen('TextFont', w, 'Courier New');
Screen('TextSize', w, 20);

%%%%%%% define responses and initiate kb queue
keys = zeros(1,256);
if sess.response_order == 1
    task.responses = KbName({'v','g'});
    keys(task.responses) = 1;
elseif sess.response_order == 2
    task.responses = KbName({'g','v'});
    keys(task.responses) = 1;
end
KbQueueCreate(-1, keys); %%%%%% initiate kb queue

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  TIMINGS    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
time.before_first_trial = 2*expand_time;
time.base = .5*expand_time;
time.val_screen_min = 1.5*expand_time;
time.val_screen_max = 1.7*expand_time;
time.fix = .2*expand_time;
time.target_on = .3*expand_time;
time.resp_period = 1.5*expand_time;
time.pre_feed = 1.5*expand_time;
time.feed = .5*expand_time;
time.iti = 1*expand_time;
time.rest = 1;
time.rest_total = 5;
frames.before_first_trial = round(time.before_first_trial/ifi);
frames.base = round(time.base/ifi);
frames.val_screen_min = round(time.val_screen_min/ifi);
frames.val_screen_max = round(time.val_screen_max/ifi);
frames.fix = round(time.fix/ifi);
frames.target_on = round(time.target_on/ifi);
frames.resp_period = round(time.resp_period/ifi);
frames.pre_feed = round(time.pre_feed/ifi);
frames.feed = round(time.feed/ifi);
frames.iti = round(time.iti/ifi);
frames.rest = round(time.rest/ifi);
frames.wait_frames = 1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  RUN EXPERIMENT   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear sess 

HideCursor;
%%%%%%% run trials
% variables for blocks and rewards
 count_blocks = 0;
 count_rewards = 0;
 
 %%%%%%% start screen
 Screen('TextStyle', w, 1);
 Screen('TextSize', w, 30);
 instructions = sprintf('Press any key to start\n');
 DrawFormattedText(w, instructions, 'Center', 'Center', white, 115);
 Screen('Flip', w);
 key_down = 0;
 while (~key_down)
     key_press = KbCheck;
     if key_press
         key_down = 1;
     end
 end
WaitSecs(1);

 %%%%% preparation screen
 instructions = 'earn those points!\ntrial starting in...\n';
 vbl = Screen('Flip', w);
 for j = 1:time.rest_total
     
     for frame = 1:frames.rest
         instruct = [instructions num2str(time.rest_total+1 - j)];
         DrawFormattedText(w, instruct, 'Center', 'Center', white, 115);
         Screen('Flip', w);
     end
 end
 
  center_start = 1;
  start_points = [1, 2]; % to start checkerboard pattern
  f_start = 1;
  
for i = 1:ttrials
    
      % clear/initiate cue stuff
    KbQueueStart; % start keyboard check queue
    press = 0; % clear the press key
    time_press = 0; % clear the rt time
	
    % define fontsize
    Screen('TextStyle', w, tgt_style);
    Screen('TextSize', w, tgt_size);
    
    %%%%%%% set up variables to collect response/trial info
    % trials.left_tgt, trials.right_tgt, trials.rt, trials.resp
    trials.rt = 0;
    trials.resp = 0;
    
    % calculate specific frames for this trial
    val_frames_this_trial = round((frames.val_screen_max - frames.val_screen_min)*rand(1)+frames.val_screen_min);
    total_frames_this_trial = val_frames_this_trial + frames.fix + frames.target_on + frames.resp_period + frames.pre_feed;
    tgt_on_frames = val_frames_this_trial + frames.fix;
    resp_period_start = val_frames_this_trial + frames.fix + frames.target_on;
    resp_period_end = val_frames_this_trial + frames.fix + frames.target_on + frames.resp_period;   
    
    trial_params = trials.order(:,i)';
    col = task.shape_col(trial_params(1),:);
    f = frequency_frames(trial_params(2));
    trial_tgt_num = randperm(length(tgts) ,1);
    trial_tgt = tgts{trial_tgt_num};
    cresp = trial_tgt_num;
    trials.cor_resp = cresp;
    
    change_mat = zeros(3, total_frames_this_trial);
    f_change = 1:f:(total_frames_this_trial-(f-1));
        for j = 1:length(f_change) %%%%%% allocate display for frame (1 or 2)
            if mod(j,2)
                 change_mat(1,f_change(j):f_change(j)+f-1) = start_points(start_points==f_start);
            else change_mat(1,f_change(j):f_change(j)+f-1) = start_points(start_points~=f_start);
            end
        end   
        
        %%%%% do the ends need to be padded?
        if any(change_mat(1,:) == 0)
            if mod(i,2)
                change_mat(1,change_mat(1,:) == 0) = 2;
            else change_mat(1,change_mat(1,:) == 0) = 1;
            end
        end
        
     change_mat(2, 1:val_frames_this_trial) = 1;
     change_mat(2, val_frames_this_trial+1:val_frames_this_trial+frames.fix ) = 2;
     change_mat(2, val_frames_this_trial+frames.fix+1:end ) = 1;
     change_mat = change_mat';
     [rows,cols] = size(change_mat);
     
     % present fixation
     Priority(topPriorityLevel);
     vbl  = Screen('Flip', w);
     baseline_start = vbl;
     for frame = 1:frames.base
         Screen('DrawLines', w, alert_fix_coords, alert_fix_width, alert_fix_cols{1}, [x_center, y_center], 1); % draw fixation coordinates - get the colour from 3rd column of change mat
         vbl = Screen('Flip', w, vbl + (frames.wait_frames - 0.5) * ifi);
     end
     Priority(0);
     
     
     Priority(topPriorityLevel);
     vbl = Screen('Flip',w);
     active_start = vbl;
     for frame = 1:rows
         % draw all the things
         Screen('DrawTexture', w, check_t(change_mat(frame,1)), [], place_rects, [], [], [],  col); % draw left grating - get grating from 1st column of change mat
         Screen('FillOval', w, oval_cols{change_mat(frame,2)}, disc_rects);
         Screen('DrawText', w, trial_tgt, x_center - x_offset, y_center - y_offset, target_col{change_mat(frame,2)}); % turn tgts on or off via colour
         Screen('DrawingFinished', w);
         [vbl, stim_on, flip_time] = Screen('Flip', w, vbl + (frames.wait_frames - 0.5) * ifi);

         
         % now check whether to start rt timing
         if frame == tgt_on_frames
             rt_start = GetSecs;
         end
         % or whether a response has been made (within the response period) - if so,
         % trunctate the number of rows left
         if frame > resp_period_start && frame < resp_period_end
             
             [ press, time_press ] = KbQueueCheck;
             if press
                 break
             end
         end
     end
     
     
     % if participant responded, continue to the end of the loop (if
     % not this would have been executed above)
     if press
         
         rows = frame + frames.pre_feed;
         change_mat = change_mat(1:rows,:);
         for pre_feed_period = frame+1:rows

         % draw all the things
         Screen('DrawTexture', w, check_t(change_mat(pre_feed_period,1)), [], place_rects, [], [], [],  col); % draw left grating - get grating from 1st column of change mat
         Screen('FillOval', w, oval_cols{change_mat(pre_feed_period,2)}, disc_rects);
         Screen('DrawText', w, trial_tgt, x_center, y_center, target_col{change_mat(pre_feed_period,2)}); % turn tgts on or off via colour
         Screen('DrawingFinished', w);
         [vbl, stim_on, flip_time] = Screen('Flip', w, vbl + (frames.wait_frames - 0.5) * ifi);  
         end
     end
     Priority(0);
     
     
     %%%%%%%% now collate the response, and the time
     if press
         resps_time = time_press(time_press > 1);
         resps_time = resps_time(1);
         resps_id = KbName(time_press > 1);
         resps_id = resps_id(1);
         trials.rt = resps_time - rt_start;
         if KbName(resps_id) == task.responses(1)
             trials.resp = 1;
         elseif KbName(resps_id) == task.responses(2)
             trials.resp = 2;
         end
     else
         trials.rt = NaN;
         trials.resp = NaN;
     end
     
     % get feedback settings
     if trials.resp ~= cresp
         feedback_fix_col = error_col;
     else
         if trials.order(3,i);
             feedback_fix_col = feed_col;
             count_rewards = count_rewards + 50;
         else feedback_fix_col = 200;
         end
     end
      
     % present fixation
     Priority(topPriorityLevel);
     vbl  = Screen('Flip', w);
     baseline_start = vbl;
     for frame = 1:frames.base
         Screen('DrawLines', w, alert_fix_coords, alert_fix_width, alert_fix_cols{1}, [x_center, y_center], 1); % draw fixation coordinates - get the colour from 3rd column of change mat
         vbl = Screen('Flip', w, vbl + (frames.wait_frames - 0.5) * ifi);
     end
     Priority(0);
     
     % present feedback
     Priority(topPriorityLevel);
     vbl  = Screen('Flip', w);
     baseline_start = vbl;
     for frame = 1:frames.base
         Screen('DrawLines', w, alert_fix_coords, alert_fix_width, feedback_fix_col, [x_center, y_center], 1); % draw fixation coordinates - get the colour from 3rd column of change mat
         vbl = Screen('Flip', w, vbl + (frames.wait_frames - 0.5) * ifi);
     end
     Priority(0);

     % interstimulus interval
     Priority(topPriorityLevel);
     vbl = Screen('Flip',w);
     isi_start = vbl;
       for frame = 1:frames.iti
           
         Screen('DrawLines', w, alert_fix_coords, alert_fix_width, alert_fix_cols{1}, [x_center, y_center], 1); % draw fixation coordinates - get the colour from 3rd column of change mat
         vbl = Screen('Flip', w, vbl + (frames.wait_frames - 0.5) * ifi);
       end
       
        fprintf(rsid, '%d,%d,%d,%f\n', [i cresp trials.resp trials.rt]');
              % clear queue
       KbQueueFlush;
       
       %%%%%%%% end of break message
       if ~mod(i, 10)
           count_blocks = count_blocks + 1;
           Screen('TextStyle', w, 1);
           Screen('TextSize', w, 30);
           points_info = sprintf('you have earned %d points!!', count_rewards);
           instructions = sprintf('woo-hoo\n! %d/%d blocks complete\n\n press any key to continue',count_blocks,ttrials/10);
           
           DrawFormattedText(w, points_info, x_center - 175, y_center - 250, feed_col, 115);
           DrawFormattedText(w, instructions, 'Center', 'Center', white, 115);
           Screen('Flip', w);
           key_down = 0;
           while (~key_down)
               key_press = KbCheck;
               if key_press
                   key_down = 1;
               end
           end
           WaitSecs(1);
           
            %%%%% preparation screen 
            instructions = 'earn those points!\nnext trial starting in...\n';
            vbl = Screen('Flip', w);
            for j = 1:time.rest_total
                
                for frame = 1:frames.rest
                    instruct = [instructions num2str(time.rest_total+1 - j)];
                    DrawFormattedText(w, instruct, 'Center', 'Center', white, 115);
                    Screen('Flip', w);
                end
            end           
       end
       
end

KbQueueRelease;  % clear queue 
% close log files
fclose('all');

