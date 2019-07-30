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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% colours - extended display %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% col_a = [148, 131, 165];   % mean = 59.99, sd = 2.71, N=5
% col_b = [230, 93, 85]; % mean = 61.22, sd = 1.77, N=5
% %col_c = [182, 133, 58]; % mean = 67.48, sd = 3.79, N=5
% col_d = [226, 90, 121]; % mean = 60.15, sd = 1.90, N=5
% col_a_adj = (col_a * screen_grey)/255;  % mean = 15.65, sd = 1.56, N=5
% col_b_adj = (col_b * screen_grey)/255;  % mean = 14.75, sd = 1.46, N=5
% col_c_adj = (col_c * screen_grey)/255; % mean = 16.91, sd = 1.71, N=5
% col_d_adj = (col_d * screen_grey)/255;% mean = 15.38, sd = 0.99, N=5
% 
% %%% t2, only col_c needs reducing in luminance - trying...
% col_c = [182, 133, 58]-5; % mean = 62.21, sd = 5.45, N=5
% col_c_adj = (col_c * screen_grey)/255; % mean = 16.55, sd = 1.09, N=5
% 
% %%% t3  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% BEST ONE
% col_c = [182, 133, 58]-10; % mean = 59.54, sd = 2.54, N=5
% col_c_adj = (col_c * screen_grey)/255; % mean = 16.24, sd = 1.31, N=5
% % col c = [172 123 48]
% %%% t4
% col_c = [182, 133, 58]-7.5; % mean = 57.51, sd = 2.6, N=5
% col_c_adj = (col_c * screen_grey)/255; % mean = 14.28, sd = .85, N=5
% 
% %%% t5
% col_c = [182, 133, 58]-8; % mean = 59.47, sd = 1.72, N=5
% col_c_adj = (col_c * screen_grey)/255; % mean = 14.7, sd = .59, N=5
% 
% %%% t6
% col_c = [182, 133, 58]-6; % mean = 59.37, sd = 3.6, N=5
% col_c_adj = (col_c * screen_grey)/255; % mean = 14.7, sd = .85, N=5
% rsize = [0 0 500 500];
% base_rect = rsize;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% colours - extended display %%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
col_a = [148, 131, 165]-7.5;   % mean = 63.35, sd = 6.14, N=4
col_b = [230, 93, 85]-5; % mean = 63.58, sd = 2.85, N=5
col_c = [182, 133, 58]-15; % mean = 61.93, sd = 3.96, N=5
col_d = [226, 90, 121]; % mean = 64.96, sd = 2.91, N=5
col_a_adj = (col_a * screen_grey)/255;  % mean = 15.84, sd = 2.29, N=5
col_b_adj = (col_b * screen_grey)/255;  % mean = 15.18, sd = 2.23, N=5
col_c_adj = (col_c * screen_grey)/255; % mean = 15.53, sd = 3.13, N=5
col_d_adj = (col_d * screen_grey)/255;% mean = 16.68, sd = 1.95, N=5
% t2 
col_a = [148, 131, 165] - 10;
col_a_adj = (col_a * screen_grey)/255;

% t3 
col_a = [148, 131, 165] - 5;
col_a_adj = (col_a * screen_grey)/255;

% t4 
col_a = round([148, 131, 165] - 7.5);
col_a_adj = (col_a * screen_grey)/255;

% t5
col_b = [230, 93, 85]-5;
col_b_adj = (col_b * screen_grey)/255;
col_c = [182, 133, 58]-15;
col_c_adj = (col_c * screen_grey)/255;

% t6
col_d = [226, 90, 121]-2; % mean = 65.17, std = 1.12, N=5
col_d_adj = (col_d * screen_grey)/255;

left_x = x_center;
right_x = x_center;
base_rect = [0 0 500 500];

place_rects(1,:) = CenterRectOnPointd(base_rect, x_center, y_center);
place_rects(2,:) = CenterRectOnPointd(base_rect, x_center, y_center);

vbl = Screen('Flip',w);

for x = 1:5

%     Screen('FillRect', w, col_a, place_rects(1,:)); % draw left grating - get grating from 1st column
%     vbl = Screen('Flip',w); 
%     while (KbCheck); end; while (~KbCheck); end
%     
%     vbl = Screen('Flip',w); 
%     Screen('FillRect', w, col_b, place_rects(1,:));
%     vbl = Screen('Flip',w);    
%     while (KbCheck); end; while (~KbCheck); end
%     
%     vbl = Screen('Flip',w); 
%     Screen('FillRect', w, col_c, place_rects(1,:));
%     vbl = Screen('Flip',w);    
%     while (KbCheck); end; while (~KbCheck); end
    
    vbl = Screen('Flip',w);
    Screen('FillRect', w, col_d, place_rects(1,:));
    vbl = Screen('Flip',w);    
    while (KbCheck); end; while (~KbCheck); end
    
%     vbl = Screen('Flip',w);
%     Screen('FillRect', w, col_a_adj, place_rects(1,:)); % draw left grating - get grating from 1st column 
%     vbl = Screen('Flip',w);
%     while (KbCheck); end; while (~KbCheck); end
%     
%     vbl = Screen('Flip',w);
%     Screen('FillRect', w, col_b_adj, place_rects(1,:)); 
%     vbl = Screen('Flip',w);    
%     while (KbCheck); end; while (~KbCheck); end
%     
%     vbl = Screen('Flip',w);
%     Screen('FillRect', w, col_c_adj, place_rects(1,:));
%     vbl = Screen('Flip',w);    
%     while (KbCheck); end; while (~KbCheck); end
    
    vbl = Screen('Flip',w);
    Screen('FillRect', w, col_d_adj, place_rects(1,:));
    vbl = Screen('Flip',w);    
    while (KbCheck); end; while (~KbCheck); end
    
end

Screen('CloseAll');
    