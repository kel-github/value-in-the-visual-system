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
sess.colour_order = input('Colour Order? [1, 2, 3 or 4] ');

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
freqs = [12.5 50/3]; %%%%%%%%% testing 12.5 and 16.67 for now - 1.2 seconds gives resolution at 12.5 and 16.67
%%%%%%% closest on golden ration (1.618) = 11 - 12.62, 10.2 = 16.67, 10.9 =
%%%%%%% 12.51, 11.8 = 16.65
frequency_frames(1) = round ( (1000/freqs(1))/(1000/ref_rate) ); %%%%%%% get number of frames before each change
frequency_frames(2) = round ( (1000/freqs(2))/(1000/ref_rate) );

%%%%%%% generate trial structure, open the trial output file
ttrials = 120*4; % per condition * conditions
trials_per_break = 10;
get_trial_log_v1(r_num,sess.date);
trial_fname = sprintf('EEG_RelVal_sub%d_%d_%d_%d_%d%d.csv',r_num, sess.date(1), sess.date(3), sess.date(2), sess.date(4), sess.date(5));
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
screen_grey = 128;
[w, rect] = Screen('OpenWindow', screen_nums, screen_grey); % ,...
Screen(w, 'Flip');
Screen(w, 'FillRect', screen_grey, rect);
[x_center, y_center] = RectCenter(rect);
[x_pix, y_pix] = Screen('WindowSize', w);
Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); %%%%%% blending
ifi = Screen('GetFlipInterval', w); %%%%%%% for controlling timings
% Retreive the maximum priority number
topPriorityLevel = MaxPriority(w);
% allow blending

%%%%%% draw checkerboards for each placeholder
rcycles = 1;
tcycles = 6;
rsize = [0 0 100 100];
hi = 255;
lo = screen_grey;
checks = makeCheckerBoard(rcycles, tcycles, rsize, hi, lo, screen_grey);
[x,y,z] = size(checks);

check_t(1) = Screen('MakeTexture', w, checks(:,:,[1 2]));
check_t(2) = Screen('MakeTexture', w, checks(:,:,[3 4]));
base_rect = rsize;
center_offset = 100;
left_x = x_center - center_offset;
right_x = x_center + center_offset;
place_rects(1,:) = CenterRectOnPointd(base_rect, left_x, y_center);
place_rects(2,:) = CenterRectOnPointd(base_rect, right_x, y_center);
tmp = [148 131 165; 230 93 85; 172 123 48; 226 90 121]; %%%%%%% colours checked for Hills 1.09 - see testing folder
task.shape_col = [tmp(sess.colour_order(1),:); tmp(sess.colour_order(2),:); tmp(sess.colour_order(3),:); tmp(sess.colour_order(4),:)];

% draw discs same colour as background screen to go on checkerboards
disc_size = 50;
disc_rect_base = [0 0 disc_size disc_size];
disc_rects(1,:) = CenterRectOnPointd(disc_rect_base, left_x, y_center);
disc_rects(2,:) = CenterRectOnPointd(disc_rect_base, right_x, y_center);

% draw tgts
tgt_loc_base_rect = [0 0 50 50];
tgt_loc_rects(1,:) = CenterRectOnPointd(tgt_loc_base_rect, left_x, y_center);
tgt_loc_rects(2,:) = CenterRectOnPointd(tgt_loc_base_rect, right_x, y_center);
tgt_size = 20;
target_col = {[screen_grey screen_grey screen_grey],[100 100 100]};
target_center_left = x_center - center_offset; %%%%%% place to center target on
target_center_right = x_center + center_offset;
tgts = {'H','N'};
dsts = {'K','Z'};
x_offset = 6;   % correct for room 1.09, iiyama 27"
y_offset = 12; % correct for room 1.09, iiyama 27"

%%%%% draw a fixation consisting of two arrows, one pointing left, one
%%%%% right
alert_fix_pix = 6;
alert_fix_off = 2;
alert_fix_x = [-alert_fix_off -(alert_fix_off+alert_fix_pix) -(alert_fix_off+alert_fix_pix) -alert_fix_off alert_fix_off alert_fix_off+alert_fix_pix alert_fix_off+alert_fix_pix alert_fix_off];
alert_fix_y = [-alert_fix_pix 0 0 alert_fix_pix -alert_fix_pix 0 0 alert_fix_pix];
alert_fix_coords = [alert_fix_x; alert_fix_y];
alert_fix_cols = {[200 200 200; 200 200 200; 200 200 200; 200 200 200; 50 50 50; 50 50 50; 50 50 50; 50 50 50]', ...
                  [50 50 50; 50 50 50; 50 50 50; 50 50 50; 200 200 200; 200 200 200; 200 200 200; 200 200 200]', ...
                  [200 200 200; 200 200 200; 200 200 200; 200 200 200; 200 200 200; 200 200 200; 200 200 200; 200 200 200]'};%%%%% dark/light grey
base = 3;
alert_fix_width = alert_fix_pix;
reward_fix_width = 8;
alert_fix_check_coords = CenterRectOnPointd([0 0 100 100], x_center, y_center); % starting w 50 pixels, will calibrate lower as we go
%%%%%% feedback info
feeds_vals = [0 50 500];
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
time.fix = .05*expand_time;
time.target_on = .2*expand_time;
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  TRIGGERS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% trigger code courtesy of Sara Assecondi
%%%%%%%% initialise
L = lab_init_sa; % INIT LABJACK

%%%%%% trigger codes (1-8)
trial_start = 1;	
cue_on = 2;
tgt_on = 3;
resp = 4;
feed_on = 5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  RUN EXPERIMENT   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear sess 

HideCursor;
%%%%%%% run trials
% dummy_trials = 3;

% variables for blocks and rewards
 count_blocks = 0;
 count_rewards = 0;
 
 %%%%%%% start screen
 Screen('TextStyle', w, 1);
 Screen('TextSize', w, 30);
 instructions = sprintf('Press any key to start\n');
 DrawFormattedText(w, instructions, 'Center', 'Center', black, 115);
 Screen('Flip', w);
 while (KbCheck); end; WaitSecs(2);%while (~KbCheck); end
 rons = GetSecs+1;
 %%%%% preparation screen
 instructions = 'earn those pounds!\ntrial starting in...\n';
 vbl = Screen('Flip', w,rons);% chan1ge
 for j = 1:time.rest_total
     
     for frame = 1:frames.rest
         instruct = [instructions num2str(time.rest_total+1 - j)];
         DrawFormattedText(w, instruct, 'Center', 'Center', black, 115);
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
    Screen('TextStyle', w, 0);
    Screen('TextSize', w, 15);

	% set variable to collect triggers for this trial
	trial_trigs = zeros(1,5);		
    
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
    tgt_loc = tgt_loc_rects(cue_dir);
    % select target for that trial
    trials.left_tgt = randperm(length(tgts),1);
    trials.right_tgt = randperm(length(tgts),1);
    if tgt_loc == 1
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
    change_mat = gen_change_mat(left_f, right_f, total_frames_this_trial, val_frames_this_trial, frames.fix, cue_dir, frames.target_on, left_start, right_start);
    [rows,cols] = size(change_mat);
    
        %%%%%%%% baseline period
        Priority(topPriorityLevel);
        vbl = Screen('Flip', w);
            for frame = 1:frames.base    
                Screen('DrawLines', w, alert_fix_coords, alert_fix_width, alert_fix_cols{change_mat(1,3)}, [x_center, y_center], 1); % draw fixation coordinates - get the colour from 3rd column of change mat
                Screen('DrawTexture', w, check_t(change_mat(1,1)), [], place_rects(1,:), [], [], [], screen_grey); % draw left grating - get grating from 1st column of change mat
                Screen('DrawTexture', w, check_t(change_mat(1,2)), [], place_rects(2,:), [], [], [], screen_grey); % draw right grating - get grating from 2nd column of change mat
                Screen('FillOval', w, screen_grey, disc_rects');
                Screen('DrawText', w, ltgt, target_center_left-x_offset, y_center-y_offset, target_col{change_mat(1,4)}); % turn tgts on or off via colour
                Screen('DrawText',w,  rtgt, target_center_right-x_offset, y_center-y_offset, target_col{change_mat(1,4)});
                Screen('DrawingFinished', w);
                vbl = Screen('Flip', w, vbl + (frames.wait_frames - 0.5) * ifi); 
            end
        Priority(0);
        
	    %%% send trial start trigger
		[trial_trigs(1),~] = lab_put_code_sa(L,trial_start);
		
        %%%%%%%% present the active trial 
        Priority(topPriorityLevel);
        vbl = Screen('Flip',w);
            for frame = 1:rows             
                % draw all the things
                Screen('DrawLines', w, alert_fix_coords, alert_fix_width, alert_fix_cols{change_mat(frame,3)}, [x_center, y_center], 1); % draw fixation coordinates - get the colour from 3rd column of change mat
                Screen('DrawTexture', w, check_t(change_mat(frame,1)), [], place_rects(1,:), [], [], [], left_col); % draw left grating - get grating from 1st column of change mat
                Screen('DrawTexture', w, check_t(change_mat(frame,2)), [], place_rects(2,:), [], [], [], right_col); % draw right grating - get grating from 2nd column of change mat
                Screen('FillOval', w, screen_grey, disc_rects');
                Screen('DrawText', w, ltgt, target_center_left-x_offset, y_center-y_offset, target_col{change_mat(frame,4)}); % turn tgts on or off via colour
                Screen('DrawText',w,  rtgt, target_center_right-x_offset, y_center-y_offset, target_col{change_mat(frame,4)});
                Screen('DrawingFinished', w);
                vbl = Screen('Flip', w, vbl + (frames.wait_frames - 0.5) * ifi); 
                
                	% now check whether to send a trigger 
						if frame == val_frames_this_trial
							[trial_trigs(2),~] = lab_put_code_sa(L, cue_on); % send cue on trigger
						elseif frame == tgt_on_frames-1
							[trial_trigs(3),~] = lab_put_code_sa(L, tgt_on); % send tgt on trigger
						elseif frame == tgt_on_frames
                    		rt_start = GetSecs;
                		end
			    	% or whether a response has been made (within the response period) - if so,
					% trunctate the number of rows left 	
                		if frame > resp_period_start && frame < resp_period_end
                    
                   		 	[ press, time_press ] = KbQueueCheck;
                   	 			if press
									[trial_trigs(4),~] = lab_put_code_sa(L,resp); % send response trigger
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
                    Screen('DrawLines', w, alert_fix_coords, alert_fix_width, alert_fix_cols{change_mat(pre_feed_period,3)}, [x_center, y_center], 1); % draw fixation coordinates - get the colour from 3rd column of change mat
                    Screen('DrawTexture', w, check_t(change_mat(pre_feed_period,1)), [], place_rects(1,:), [], [], 0, left_col); % draw left grating - get grating from 1st column of change mat
                    Screen('DrawTexture', w, check_t(change_mat(pre_feed_period,2)), [], place_rects(2,:), [], [], [], right_col); % draw right grating - get grating from 2nd column of change mat
                    Screen('FillOval', w, screen_grey, disc_rects');
                    Screen('DrawText', w, ltgt, target_center_left-x_offset, y_center-y_offset, target_col{change_mat(pre_feed_period,4)}); % turn tgts on or off via colour
                    Screen('DrawText',w,  rtgt, target_center_right-x_offset, y_center-y_offset, target_col{change_mat(pre_feed_period,4)});
                    Screen('DrawingFinished', w);
                    vbl = Screen('Flip', w, vbl + (frames.wait_frames - 0.5) * ifi);
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
           if trial_params{8} 
              feedback_fix_col = feed_col; 
              count_rewards = count_rewards + .2;
           else feedback_fix_col = 200;
           end
       end
           
       % feed back screen 
	   [trial_trigs(5),~] = lab_put_code_sa(L, feed_on); % feedback screen trigger		   
       Priority(topPriorityLevel);
       vbl = Screen('Flip',w);
       for frame = 1:frames.feed
           
           % draw all the things
           Screen('DrawLines', w, alert_fix_coords, alert_fix_width, feedback_fix_col, [x_center, y_center], 1); % draw fixation coordinates - get the colour from 3rd column of change mat
           Screen('DrawTexture', w, check_t(change_mat(rows,1)), [], place_rects(1,:), [], [], [], screen_grey); % draw left grating - get grating from 1st column of change mat
           Screen('DrawTexture', w, check_t(change_mat(rows,2)), [], place_rects(2,:), [], [], [], screen_grey); % draw right grating - get grating from 2nd column of change mat
           Screen('FillOval', w, screen_grey, disc_rects');
           Screen('DrawText', w, ltgt, target_center_left-x_offset, y_center-y_offset, target_col{change_mat(rows,4)}); % turn tgts on or off via colour
           Screen('DrawText',w,  rtgt, target_center_right-x_offset, y_center-y_offset, target_col{change_mat(rows,4)});
           Screen('DrawingFinished', w);
           vbl = Screen('Flip', w, vbl + (frames.wait_frames - 0.5) * ifi);
       end
       Priority(0);

       % interstimulus interval
       Priority(topPriorityLevel);
       vbl = Screen('Flip',w);
       for frame = 1:frames.iti
           
           % draw all the things
           Screen('DrawLines', w, alert_fix_coords, alert_fix_width, alert_fix_cols{change_mat(rows,3)}, [x_center, y_center], 1); % draw fixation coordinates - get the colour from 3rd column of change mat
           Screen('DrawTexture', w, check_t(change_mat(rows,1)), [], place_rects(1,:), [], [], [], screen_grey); % draw left grating - get grating from 1st column of change mat
           Screen('DrawTexture', w, check_t(change_mat(rows,2)), [], place_rects(2,:), [], [], [], screen_grey); % draw right grating - get grating from 2nd column of change mat
           Screen('FillOval', w, screen_grey, disc_rects');
           Screen('DrawText', w, ltgt, target_center_left-x_offset, y_center-y_offset, target_col{change_mat(rows,4)}); % turn tgts on or off via colour
           Screen('DrawText',w,  rtgt, target_center_right-x_offset, y_center-y_offset, target_col{change_mat(rows,4)});
           Screen('DrawingFinished', w);
           vbl = Screen('Flip', w, vbl + (frames.wait_frames - 0.5) * ifi);
       end

       %%%%%%%% write the trial matrix into the change outputfile, clear
       %%%%%%%% the change matrix
       fprintf(clid, 't%d\n', i);
       fprintf(clid, '%d,%d,%d,%d\n', change_mat');
       
       % get starting params for next trial
       left_start = change_mat(rows,1);
       right_start = change_mat(rows,2);
       
       clear change_mat
       %%%%%%%% results output 
       fprintf(rsid, '%d,%d,%d,%f\n', [i cresp trials.resp trials.rt]');
       
       %%%%%%%% write the triggers to the trig output
	   fprintf(trid, '%d\n', trial_trigs');	   
      
       % clear queue
        KbQueueFlush;
        
       %%%%%%%% end of break message
       if ~mod(i, trials_per_break)
           count_blocks = count_blocks + 1;
           Screen('TextStyle', w, 1);
           Screen('TextSize', w, 30);
           points_info = sprintf('you have earned £%.2f!!', count_rewards);
           instructions = sprintf('woo-hoo\n! %d/%d blocks complete\n\n please let the experimenter know you have finished the block',count_blocks,ttrials/trials_per_break);
           
           DrawFormattedText(w, points_info, x_center - 175, y_center - 250, feed_col, 115);
           DrawFormattedText(w, instructions, 'Center', 'Center', black, 115);
           Screen('Flip', w);
           while (KbCheck); end; WaitSecs(2);%while (~KbCheck); end
           
            %%%%% preparation screen 
            instructions = 'earn those pounds!\nnext trial starting in...\n';
            vbl = Screen('Flip', w);
            for j = 1:time.rest_total
                
                for frame = 1:frames.rest
                    instruct = [instructions num2str(time.rest_total+1 - j)];
                    DrawFormattedText(w, instruct, 'Center', 'Center', black, 115);
                    Screen('Flip', w);
                end
            end           
       end
       
end

KbQueueRelease;  % clear queue 
% close log files
fclose('all');

% params = lab_close_sa(params); % CLOSE EXT CONNECTIONS
	
points_info = sprintf('you have earned £%.2f!!', count_rewards);
instructions = sprintf('you are finished - huzzah!');
DrawFormattedText(w, points_info, x_center - 175, y_center - 250, feed_col, 115);
DrawFormattedText(w, instructions, 'Center', 'Center', black, 115);
Screen('Flip', w);
while (KbCheck); end; WaitSecs(2);%while (~KbCheck); end
Screen('CloseAll');
                
                
                