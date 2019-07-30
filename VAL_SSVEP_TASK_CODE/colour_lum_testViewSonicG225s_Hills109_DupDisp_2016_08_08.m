 %%%%%%%%%%%%%%%%%%% luminance testing Hills 1.09, 2016_19_07
clear all
clear mex

KbCheck;
KbName('UnifyKeyNames');
GetSecs;
AssertOpenGL;
Screen('Preference', 'SkipSyncTests', 0);
%PsychDebugWindowConfiguration;
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

time_stim_on = 30;
frames_stim_on = round(time_stim_on/ifi);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% colours - extended display %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
col_a = [148, 131, 165];   % 
col_b = [230, 93, 85]; % mean = 30.07, sd = .15, N=4
col_c = [182, 133, 58]; % 
col_d = [226, 90, 121]; % mean = 29.75, sd = .274, N=4
col_a_adj = (col_a * screen_grey)/255;  % 
col_b_adj = (col_b * screen_grey)/255;  % mean = 8.13, sd = .12, N=4
col_c_adj = (col_c * screen_grey)/255; % 
col_d_adj = (col_d * screen_grey)/255;% mean = 8.1, sd = .06, N=4

% t2
col_a = [148, 131, 165]-5;   % mean = 31.02, sd = .29, N=4
col_a_adj = (col_a * screen_grey)/255; % mean = 8.25, sd = .03, N=2
col_c = [182, 133, 58]-5;% mean = 31.67, sd = .46, N=4
col_c_adj = (col_c * screen_grey)/255; % mean = 8.46, sd = .08, N=4
 
cols = [col_a; col_b; col_c; col_d; col_a_adj; col_b_adj; col_c_adj; col_d_adj];
[ncols,~] = size(cols);
left_x = x_center;
right_x = x_center;
base_rect = [0 0 500 500];

place_rects(1,:) = CenterRectOnPointd(base_rect, x_center, y_center);
place_rects(2,:) = CenterRectOnPointd(base_rect, x_center, y_center);

for z = 1:4

for count_cols = 1:ncols
    
    vbl = Screen('Flip',w);
    
    for frame = 1:frames_stim_on
        
        Screen('FillRect', w, cols(count_cols,:), place_rects(1,:)); % draw left grating - get grating from 1st column
        vbl = Screen('Flip',w);
        
        if KbCheck
            WaitSecs(0.1)
            break
        end
                
    end
end
end
Screen('CloseAll'); 
 