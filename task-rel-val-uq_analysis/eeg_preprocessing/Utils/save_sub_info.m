% write subject specific variables
% see https://docs.google.com/spreadsheets/d/1hVctPr8uQSuAIubm2ObOjHG9_pooVAueaszJ68Dbocw/edit#gid=0
clear all
save_dir = '/Volumes/ANALYSIS/E6_EEG_RV_1/';

% subs = [13071, 13081, 13091, 13101, 13111, 13121, 13131, 13141, 13151, 13161,...
%         13171, 13181, 13191, 13201, 13211, 13221, 13231, 13241, 13251, 14261,...
%         14271, 14281, 14291, 14301, 14311, 14321, 14331];
    
subs = [14261];

HEOGS =     { [65, 66], [65, 66], [65, 66], [65, 66], [65, 66], [65, 66], [65, 66], [65, 66],...
              [67, 68], [65, 66], [65, 66], [65, 66], [65, 66], [65, 66], [65, 66], [65, 66],...
              [66, 65], [65, 66], [65, 66], [65, 66], [65, 66], [65, 66], [65, 66], [65, 66],...
              [65, 66], [65, 66], [65, 66] };
          
VEOGS =     { [67, 68], [67, 68], [67, 68], [67, 68], [67, 68], [67, 68], [67, 68], [67, 68],...
              [69, 70], [67, 68], [67, 68], [67, 68], [67, 68], [67, 68], [67, 68], [67, 68],...
              [67, 68], [67, 68], [67, 68], [67, 68], [67, 68], [67, 68], [67, 68], [67, 68],...
              [67, 68], [67, 68], [67, 68] };
    
ref_chans = { [69, 70], [69, 70], [69, 70], [69, 70], [69, 70], [69, 70], [69, 70], [69, 70],...
              [65, 66], [69, 70], [70, 69], [69, 70], [69, 70], [69, 70], [69, 70], [69, 70],...
              [70, 69], [69, 70], [70, 69], [69, 70], [69, 70], [69, 70], [69, 70], [69, 70],...
              [69, 70], [70, 69], [69, 70] };
          
          
    
for x = 1:length(subs)
    
   clear out
   out.sID = subs(x);
   out.fName_EEG = dir(sprintf([save_dir 'SUB_%d/BDF/*.bdf'],subs(x)));
   out.fName_BEH = {sprintf('event_out_s%d.txt', subs(x))};
   out.uniqueEvents = [1 2 3 4];
   out.refChan = ref_chans{x};
   out.HEOG = HEOGS{x};
   out.VEOG = VEOGS{x};
   
   
   save_name = sprintf([save_dir 'SUB_%d/LOG/sinfo_%d.mat'], subs(x), subs(x));
   save(save_name, 'out');

end
        