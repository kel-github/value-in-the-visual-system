%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% REL VAL/FREQ TAG EXP v1.1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% K. Garner, August 2016
%%%% NOTES: All colours/dims calibrated for ViewSonic G225 450 mm x 350 mm
%%%% (with viewing distance of 570 mm) - for colour test see
%%%% resolution: 1600 x 1200
%%%% colour_lum_testViewSonicG225s_Hills109_DupDisp_2016_08_08.m in same
%%%% folder.
%%%% Run with 512 Hz sample rate, aux (if want diode input), 64 channels
%%%% and 8 externals.
%%%% v1_2 - changed background and fixation colours
%%%% v1_3 - changing placeholders so that they are circles, superimposing
%%%% the targets on top. Also removing the cue, to see if the task can be
%%%% completed without it
%%%% v1_3 - has also been modified to call get_trial_log_v2 instead of v1
%%%% v1_4 - puts the checkerboards back to the same start point for each
%%%% trial, adds a grey checkerboard period prior to value onset
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DEPENDENCIES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Psychtoolbox 3.0.14
% Matlab R2017b
% run on (get specs for QBI EEG lab).

% clear all the things
clear all
clear mex

% initialise mex files etc
KbCheck;
KbName('UnifyKeyNames');
GetSecs;
AssertOpenGL
Screen('Preference', 'SkipSyncTests', 1);
%PsychDebugWindowConfiguration;
dbug = input('Debug Mode? (1 or 0) ');
sess.sub_num = input('Subject Number? ');
sess.date = clock;
sess.session = input('Session? ');
sess.response_order = input('Response Order? ');
sess.colour_order = input('Colour Order? [1, 2] or [2, 1] ');
sess.diode = input('Diode?' );

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
%ref_rate = 60;
ref_rate = 100;
resolution = [1024 768]; % might change this with psychtoolbox - get stuff
% freqs = [1/(.0167*8) 1/(.0167*11)];
freqs = [1/(.01*6) 1/(.01*4)]; 
frequency_frames(1) = round ( (1000/freqs(1))/(1000/ref_rate) ); %%%%%%% get number of frames before each change
frequency_frames(2) = round ( (1000/freqs(2))/(1000/ref_rate) );

%%%%%%% generate trial structure, open the trial output file
ttrials = 112*4; % per condition * conditions
trials_per_break = 28;
get_trial_log_v2(r_num,sess.date);
trial_fname = sprintf('EEG_RelVal_sub%d_%d_%d_%d_%d%d.csv', r_num, sess.date(1), sess.date(3), sess.date(2), sess.date(4), sess.date(5));
tfid = fopen(trial_fname);

%%%%%%% open log files for writing to
sess_log_fname = sprintf('EEG_RelVal_sess_log_sub%d_%d_%d_%d_%d%d.csv',r_num, sess.date(1), sess.date(3), sess.date(2), sess.date(4), sess.date(5));
ssid = fopen(sess_log_fname, 'w');
fprintf(ssid,'resp order: %d\ncolour order: %d%d', sess.response_order, sess.colour_order(1), sess.colour_order(2));
fclose(ssid);
change_log_fname = sprintf('EEG_RelVal_change_log_sub%d_%d_%d_%d_%d%d.csv',r_num, sess.date(1), sess.date(3), sess.date(2), sess.date(4), sess.date(5));
clid = fopen(change_log_fname, 'w');
results_log_fname = sprintf('EEG_RelVal_resp_log_sub%d_%d_%d_%d_%d%d.csv',r_num, sess.date(1), sess.date(3), sess.date(2), sess.date(4), sess.date(5));
rsid = fopen(results_log_fname, 'w');
trig_log_fname = sprintf('EEG_RelVal_trig_log_sub%d_%d_%d_%d_%d%d.csv',r_num, sess.date(1), sess.date(3), sess.date(2), sess.date(4), sess.date(5));
trid = fopen(trig_log_fname, 'w');

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
center_offset = 205; % center of placeholder is 5.5 vis degrees from fixation - calibrated to ViewSonic monitor - G225s 
                     % (change to 5.5 degrees to fit with Muller/Hillyard
                     % SSVEP studies) 
                     % reducing visual angle diff to be in line with
                     % previous behavioural studies
left_x = x_center - center_offset;
right_x = x_center + center_offset;
y_pos = y_center + ((center_offset/5.5)*3.5);
place_rects(1,:) = CenterRectOnPointd(base_rect, left_x, y_pos);
place_rects(2,:) = CenterRectOnPointd(base_rect, right_x, y_pos);
tmp = [[148 131 165]-5; 230 93 85; [182, 133, 58]-5; 226 90 121]; %%%%%%% colours checked for Hills 1.09 (ViewSonic G225s) - see testing folder
task.shape_col = [tmp(sess.colour_order(1),:); tmp(sess.colour_order(2),:)];

% % draw discs same colour as background screen to go on checkerboards
disc_size = 50;
disc_rect_base = [0 0 disc_size disc_size];
disc_rects(1,:) = CenterRectOnPointd(disc_rect_base, left_x, y_pos);
disc_rects(2,:) = CenterRectOnPointd(disc_rect_base, right_x, y_pos);
oval_cols = {[grey grey grey 0]; [grey grey grey]};

% draw tgts
tgt_loc_base_rect = [0 0 50 50];
tgt_loc_rects(1,:) = CenterRectOnPointd(tgt_loc_base_rect, left_x, y_pos);
tgt_loc_rects(2,:) = CenterRectOnPointd(tgt_loc_base_rect, right_x, y_pos);
tgt_size = 30;
tgt_style = 1;
target_col = {[black black black 0],[black black black]}; % changing targets to white
% target_center_left = x_center - center_offset; %%%%%% place to center target on
% target_center_right = x_center + center_offset;
tgts = {'H','N'};
dsts = {'K','Z'};
x_txt_pos = round([disc_rects(1,1) + (disc_size/4); disc_rects(2,1) + (disc_size/4)]);
%y_txt_pos = round([disc_rects(1,2) + (disc_size/10); disc_rects(2,2) + (disc_size/10)]);
y_txt_pos = round([disc_rects(1,2); disc_rects(2,2)]);
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
Screen('TextSize', w, 18);

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
time.base = 1.5*expand_time;
time.val_screen_min = 2.2*expand_time;
time.val_screen_max = 2.7*expand_time;
time.grey_stim = 1.5;
time.fix = .2*expand_time;
time.target_on = .1*expand_time;
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
frames.grey_stim = round(time.grey_stim/ifi);
frames.fix = round(time.fix/ifi);
frames.target_on = round(time.target_on/ifi);
frames.resp_period = round(time.resp_period/ifi);
frames.pre_feed = round(time.pre_feed/ifi);
frames.feed = round(time.feed/ifi);
frames.iti = round(time.iti/ifi);
frames.rest = round(time.rest/ifi);
frames.wait_frames = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  TRIGGERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set up eeg stuff
port_address = hex2dec('D050');
ioObj        = io64();
status       = io64(ioObj);
io64( ioObj, port_address, 0); % set port to off

%%%%%% trigger codes (1-4)
trial_start = 1;	
val_on = 2;
tgt_on = 3;
resp = 4;
feed_on = 5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%    test trigger timings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
test_base_rect = [0 0 150 150]; % double check this - 
if sess.diode
    test_cols = [black black black; 255 255 255];
else
    test_cols =  [black black black; black black black];
end

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
 left_start = 1;
 right_start = 2;
  
for i = 1:ttrials

    % clear/initiate cue stuff
    KbQueueStart; % start keyboard check queue
    press = 0; % clear the press key
    time_press = 0; % clear the rt time
	
    % define fontsize
    Screen('TextStyle', w, tgt_style);
    Screen('TextSize', w, tgt_size);

	% set variable to collect triggers for this trial, and the frames on
	% which they were sent
	trial_trigs = zeros(1,5);		
    trig_frames = zeros(1,5);
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

    %%%%%%%% read in trial info
    trial_params = textscan(tfid,'%d,%d,%d,%d,%d,%d,%d,%d\n',1); 
    %%%%%%%% items 3 and 4 of params set the colour, 5 the cue direction, 6 & 7 = left freq, right freq 
    left_col = task.shape_col(trial_params{3},:);
    right_col = task.shape_col(trial_params{4},:);
    cue_dir = trial_params{5};
    tgt_loc = tgt_loc_rects(cue_dir,:);
    % select target for that trial
    trials.left_tgt = randperm(length(tgts),1);
    trials.right_tgt = randperm(length(tgts),1);
    if cue_dir == 1
        ltgt = tgts{trials.left_tgt};
        rtgt = dsts{trials.right_tgt};
        cresp = trials.left_tgt;
    else
        ltgt = dsts{trials.left_tgt};
        rtgt = tgts{trials.right_tgt};
        cresp = trials.right_tgt;
    end
    left_f = frequency_frames(trial_params{6});
    right_f = frequency_frames(trial_params{7});
    
    %%%%%%% generate change matrix with parameters for whole trial (up to
    %%%%%%% the reward onset)
    change_mat = gen_change_mat(left_f, right_f, total_frames_this_trial, val_frames_this_trial, frames.fix, cue_dir, frames.target_on, 1, 1);
    [rows,cols] = size(change_mat);
    change_mat(1:rows,cols+1:cols+3) = 0; %%%%% add 3 columns for timing info - [VBLTimestamp StimulusOnsetTime FlipTimestamp]
    %%%%%%%%%%%%%%%%%%%%%%%%%%% this bit is specific to timing tests
    change_mat(1:rows,8) = 1;
    tmp = find(change_mat(:,3) ~= 3);
    change_mat(tmp(1),8) = 2;
    tmp = find(change_mat(:,4) ~= 1);
    change_mat(tmp(1),8) = 2;
    clear tmp
    %%%%%%%%%%%%%%%% START PRESENTING THE TRIAL        
        %%%%%%%% baseline period
        Priority(topPriorityLevel);
        vbl  = Screen('Flip', w);
        baseline_start = vbl;
            for frame = 1:frames.base    
                Screen('DrawLines', w, alert_fix_coords, alert_fix_width, alert_fix_cols{change_mat(1,3)}, [x_center, y_center], 1); % draw fixation coordinates - get the colour from 3rd column of change mat
                Screen('DrawTexture', w, check_t(change_mat(1,1)), [], place_rects(1,:), [], [], [], grey); % draw left grating - get grating from 1st column of change mat
                Screen('DrawTexture', w, check_t(change_mat(1,2)), [], place_rects(2,:), [], [], [], grey); % draw right grating - get grating from 2nd column of change mat
                Screen('FillOval', w, oval_cols{change_mat(1,4)}, disc_rects');
                Screen('DrawText', w, ltgt, x_txt_pos(1), y_txt_pos(1), target_col{change_mat(1,4)}); % turn tgts on or off via colour
                Screen('DrawText', w,  rtgt, x_txt_pos(2),  y_txt_pos(2), target_col{change_mat(1,4)});
                Screen('DrawingFinished', w);
                vbl = Screen('Flip', w, vbl + (frames.wait_frames - 0.5) * ifi);  
            end
        Priority(0);
        
	    %%% send trial start trigger
        %[~,~] = lab_put_code_sa(L,trial_start);
        QBI_send_trigger(trial_start, ioObj, port_address)
		trial_trigs(trial_start) = trial_start;       
        
        %%%%%%%% present the active trial 
        Priority(topPriorityLevel);
        Screen('FillRect', w, test_cols(1), test_base_rect); % draw white square for photo diode and flip - duration = .0167
        vbl = Screen('Flip',w);
        active_start = vbl;
            for frame = 1:rows             
                % draw all the things
                Screen('FillRect', w, test_cols(change_mat(frame,8)), test_base_rect); % diode test - duration = .0167     
                Screen('DrawLines', w, alert_fix_coords, alert_fix_width, alert_fix_cols{change_mat(frame,3)}, [x_center, y_center], 1); % draw fixation coordinates - get the colour from 3rd column of change mat
                
                if frame < frames.grey_stim
                    Screen('DrawTexture', w, check_t(change_mat(frame,1)), [], place_rects(1,:), [], [], [], grey); % draw left grating - get grating from 1st column of change mat
                    Screen('DrawTexture', w, check_t(change_mat(frame,2)), [], place_rects(2,:), [], [], [], grey); % draw right grating - get grating from 2nd column of change mat                    
                else
                    Screen('DrawTexture', w, check_t(change_mat(frame,1)), [], place_rects(1,:), [], [], [], left_col); % draw left grating - get grating from 1st column of change mat
                    Screen('DrawTexture', w, check_t(change_mat(frame,2)), [], place_rects(2,:), [], [], [], right_col); % draw right grating - get grating from 2nd column of change mat
                end
                Screen('FillOval', w, oval_cols{change_mat(frame,4)}, disc_rects');
                Screen('DrawText', w, ltgt, x_txt_pos(1),  y_txt_pos(1), target_col{change_mat(frame,4)}); % turn tgts on or off via colour
                Screen('DrawText', w,  rtgt, x_txt_pos(2),  y_txt_pos(2), target_col{change_mat(frame,4)});
                Screen('DrawingFinished', w);
                [vbl, stim_on, flip_time] = Screen('Flip', w, vbl + (frames.wait_frames - 0.5) * ifi); 
                change_mat(frame,cols+1) = vbl;
                change_mat(frame,cols+2) = stim_on;
                change_mat(frame,cols+3) = flip_time;
                
                	% now check whether to send a trigger 
						if frame == frames.grey_stim
 							QBI_send_trigger(val_on, ioObj, port_address);
                            trial_trigs(val_on) = val_on;
                            trig_frames(val_on) = frame;
						elseif frame == tgt_on_frames
                            %[~,~] = lab_put_code_sa(L, tgt_on); % send tgt on trigger   
                            QBI_send_trigger(tgt_on, ioObj, port_address);
                            trial_trigs(tgt_on) = tgt_on;
                            trig_frames(tgt_on) = frame;
                            rt_start = GetSecs;
                		end
			    	% or whether a response has been made (within the response period) - if so,
					% trunctate the number of rows left 	
                		if frame > resp_period_start && frame < resp_period_end
                    
                   		 	[ press, time_press ] = KbQueueCheck;
                   	 			if press
                                 %[~,~] = lab_put_code_sa(L,resp); % send response trigger
                                    QBI_send_trigger(resp, ioObj, port_address);
                                    trial_trigs(resp) = resp;
                                    trig_frames(resp) = frame;
                        				break
                    			end
               			end
            end

            
            % if participant responded, continue to the end of the loop (if
            % not this would have been executed above)
            if press
                            
                rows = frame + frames.pre_feed;
                change_mat = change_mat(1:rows,:);
                change_mat(frame + 1, 8) = 2;
                for pre_feed_period = frame+1:rows

                    % draw all the things
                    Screen('FillRect', w, test_cols(change_mat(pre_feed_period,8)), test_base_rect); % diode test - duration = .0167     
                    Screen('DrawLines', w, alert_fix_coords, alert_fix_width, alert_fix_cols{change_mat(pre_feed_period,3)}, [x_center, y_center], 1); % draw fixation coordinates - get the colour from 3rd column of change mat
                    Screen('DrawTexture', w, check_t(change_mat(pre_feed_period,1)), [], place_rects(1,:), [], [], 0, left_col); % draw left grating - get grating from 1st column of change mat
                    Screen('DrawTexture', w, check_t(change_mat(pre_feed_period,2)), [], place_rects(2,:), [], [], [], right_col); % draw right grating - get grating from 2nd column of change mat
                    Screen('FillOval', w, oval_cols{change_mat(pre_feed_period,4)}, disc_rects');
                    Screen('DrawText', w, ltgt, x_txt_pos(1),  y_txt_pos(1), target_col{change_mat(pre_feed_period,4)}); % turn tgts on or off via colour
                    Screen('DrawText',w,  rtgt, x_txt_pos(2),  y_txt_pos(2), target_col{change_mat(pre_feed_period,4)});
                    Screen('DrawingFinished', w);
                    
                    [vbl, stim_on, flip_time] = Screen('Flip', w, vbl + (frames.wait_frames - 0.5) * ifi); 
                    change_mat(pre_feed_period,cols+1) = vbl;
                    change_mat(pre_feed_period,cols+2) = stim_on;
                    change_mat(pre_feed_period,cols+3) = flip_time;
                   
                end
            else
                pre_feed_period = frame;
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
           if trial_params{8} == 1
              feedback_fix_col = feed_col; 
              count_rewards = count_rewards + 50;
           elseif trial_params{8} == 2
               feedback_fix_col = [255 255 255];
           else feedback_fix_col = grey;
           end
       end
           
      
       Priority(topPriorityLevel);
       Screen('FillRect', w, test_cols(1), test_base_rect); % diode test - duration = .0167
       vbl = Screen('Flip',w);
       feedback_start = vbl;
       % feed back screen
       %[~,~] = lab_put_code_sa(L, feed_on); % feedback screen trigger
       QBI_send_trigger(feed_on, ioObj, port_address);
       trial_trigs(feed_on) = feed_on;
       trig_frames(feed_on) = pre_feed_period;
       
       for frame = 1:frames.feed
           
           % draw all the things
           Screen('DrawLines', w, alert_fix_coords, alert_fix_width, feedback_fix_col, [x_center, y_center], 1); % draw fixation coordinates - get the colour from 3rd column of change mat
           Screen('DrawTexture', w, check_t(change_mat(rows,1)), [], place_rects(1,:), [], [], [], grey); % draw left grating - get grating from 1st column of change mat
           Screen('DrawTexture', w, check_t(change_mat(rows,2)), [], place_rects(2,:), [], [], [], grey); % draw right grating - get grating from 2nd column of change mat
           Screen('FillOval', w, oval_cols{change_mat(rows,4)}, disc_rects');
           Screen('DrawText', w, ltgt, x_txt_pos(1),  y_txt_pos(1), target_col{change_mat(rows,4)}); % turn tgts on or off via colour
           Screen('DrawText',w,  rtgt, x_txt_pos(2),  y_txt_pos(2), target_col{change_mat(rows,4)});
           Screen('DrawingFinished', w);
           vbl = Screen('Flip', w, vbl + (frames.wait_frames - 0.5) * ifi);
       end
       Priority(0);

       % interstimulus interval
       Priority(topPriorityLevel);
       vbl = Screen('Flip',w);
       isi_start = vbl;
       for frame = 1:frames.iti
           
           % draw all the things
           Screen('DrawLines', w, alert_fix_coords, alert_fix_width, alert_fix_cols{change_mat(rows,3)}, [x_center, y_center], 1); % draw fixation coordinates - get the colour from 3rd column of change mat
           Screen('DrawTexture', w, check_t(1), [], place_rects(1,:), [], [], [], grey); % draw left grating - get grating from 1st column of change mat
           Screen('DrawTexture', w, check_t(1), [], place_rects(2,:), [], [], [], grey); % draw right grating - get grating from 2nd column of change mat
           Screen('FillOval', w, oval_cols{change_mat(rows,4)}, disc_rects');
           Screen('DrawText', w, ltgt, x_txt_pos(1),  y_txt_pos(1), target_col{change_mat(rows,4)}); % turn tgts on or off via colour
           Screen('DrawText',w,  rtgt, x_txt_pos(2),  y_txt_pos(2), target_col{change_mat(rows,4)});
           Screen('DrawingFinished', w);
           vbl = Screen('Flip', w, vbl + (frames.wait_frames - 0.5) * ifi);
       end

       %%%%%%%% write the trial matrix into the change outputfile, clear
       %%%%%%%% the change matrix
       fprintf(clid, 't%d\n', i);
       fprintf(clid, '%d,%d,%d,%d,%f,%f,%f,%d\n', change_mat');
       
%        % get starting params for next trial
%        left_start = change_mat(rows,1);
%        right_start = change_mat(rows,2);
       
       clear change_mat
       %%%%%%%% results output 
       fprintf(rsid, '%d,%d,%d,%f,%f,%f,%f,%f\n', [i cresp trials.resp trials.rt baseline_start active_start feedback_start isi_start]');
       
       %%%%%%%% write the triggers to the trig output
       trig_trial_id = repmat(i, 1, numel(trial_trigs));
	   fprintf(trid, '%d,%d,%d\n', [trig_trial_id', trial_trigs', trig_frames']');	   
      
       % clear queue
       KbQueueFlush;
       
       %%%%%%%% end of break message
       if ~mod(i, trials_per_break)
           count_blocks = count_blocks + 1;
           Screen('TextStyle', w, 1);
           Screen('TextSize', w, 30);
           points_info = sprintf('you have earned %d points!!', count_rewards);
           instructions = sprintf('woo-hoo\n! %d/%d blocks complete\n\n please let the experimenter know you have finished the block',count_blocks,ttrials/trials_per_break);
           
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

	
points_info = sprintf('you have earned %d points!!', count_rewards);
instructions = sprintf('you are finished - huzzah!');
DrawFormattedText(w, points_info, x_center - 175, y_center - 250, feed_col, 115);
DrawFormattedText(w, instructions, 'Center', 'Center', white, 115);
Screen('Flip', w);
while (~KbCheck); end; WaitSecs(1);
Screen('CloseAll');

%lab_close_sa(L); % CLOSE EXT CONNECTIONS
                
                
                