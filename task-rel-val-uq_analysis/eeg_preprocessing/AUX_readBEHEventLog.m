function [events] = AUX_readBEHEventLog(fpath, fname, method)

%%% trig events
% 1 a = cresp - 1 = H, 2 = N
% 2 b = tgt loc - 1 = left, 2 = right
% 3 c = rel - 1 = lvl, 2 = hvh, 3 = lvh, 4 = hvl
% 4 d = left val - 1 = high, 2 = low
% 5 e = right val - 1 = high, 2 = low
% 6 f = left freq - 1 = 7.5, 2 = 5.5
% 7 g = right freq - 1 = 7.5, 2 = 5.5
% 8 h = resp - 1 = correct, 2 = incorrect, 9 = missing
% 9 i = trial number
% DBL CHECKED 8th NOV 2017

fid = fopen([fpath '/' fname]);
tmp = textscan(fid, '%d %d %d %d %d %d %d %d %d %d\n'); 
[rows,~] = size(tmp{1});

for x = 1:rows
    trials(x,:) = [tmp{3}(x), tmp{2}(x), tmp{6}(x), tmp{7}(x), tmp{8}(x)]; 
    % gives 1) cond, 2) tgt_loc, 3) left freq, 4) right freq, 5) resp, 
    % have sanity checked these are read out the correct way
end

clear tmp

    % empty events vector
    [ntrials, ~] = size(trials);
    events = zeros(1, ntrials);

switch method
    
    
        case 'freq by conds'
              
            events = events';
            % order = cond, tgt_loc, left freq, right freq, resp
            order = [ 1 2 3 4 5];
            for count_events = 1:length(events)
                
                for count_tmp = 1:length(order)
                    tmp( count_tmp ) = num2str(trials( count_events, order( count_tmp )));
                end
                events(count_events) = str2num(tmp);
                clear tmp
            end
            % remove incorrect trials
            events(trials(:,5) == 9 | trials(:,5) == 2 ) = 999;
            events = events';
            
        case 'f1lvf1r'     
            
%             events = events';
%             for count_events = 1:length(events)
%                 
%                 events(count_events) = trials(count_events, 2);
%             end
%             % remove incorrect trials
%             events(trials(:,8) == 9 | trials(:,8) == 2 ) = 999;
%             events = events';
               
        case 'all'
        

%             events = events';
%             % cond, left_val, right_val, left_f, right_f, tgt_loc, cor_resp,
%             % resp
%             for count_events = 1:length(events)
%                 for count_info = 1:length(trials(count_events,:))
%                     tmp(count_info) = num2str(trials(count_events,count_info));
%                 end
%                 events(count_events) = str2num(tmp);
%             end
%             % remove incorrect trials
%             events(trials(:,8) == 9) = 999;
%             events = events';
        
     case 'errors'
        

        events = events';
        events(1:ntrials) = 10;
        % remove incorrect trials
        events(trials(:,5) == 9) = 999;
        events = events';
         
        
end